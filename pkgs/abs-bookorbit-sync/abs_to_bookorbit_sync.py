#!/usr/bin/env python3
"""Audiobookshelf -> BookOrbit listening state sync.

Reads the Audiobookshelf SQLite database in read-only mode and writes listening
progress, audiobook resume positions and listening sessions into BookOrbit's
Postgres database. All configuration comes from the environment.
"""

import json
import os
import re
import sqlite3
import sys
import time
from datetime import datetime, timedelta, timezone

import psycopg2
from psycopg2.extras import execute_values

ABS_DB_PATH = os.environ.get("ABS_DB_PATH", "/var/lib/audiobookshelf/config/absdatabase.sqlite")
ABS_PATH_ROOT = os.environ.get("ABS_PATH_ROOT", "/media/storage/media/books").rstrip("/")
BO_PATH_ROOT = os.environ.get("BO_PATH_ROOT", "/books").rstrip("/")
ABS_USER_ID = os.environ.get("ABS_USER_ID", "").strip()
BOOKORBIT_USER_ID = int(os.environ.get("BOOKORBIT_USER_ID", "1"))
SESSION_SOURCE = os.environ.get("SESSION_SOURCE", "manual")

POSTGRES_HOST = os.environ.get("POSTGRES_HOST", "127.0.0.1")
POSTGRES_PORT = int(os.environ.get("POSTGRES_PORT", "5422"))
POSTGRES_USER = os.environ.get("POSTGRES_USER", "bookorbit")
POSTGRES_DB = os.environ.get("POSTGRES_DB", "bookorbit")
POSTGRES_PASSWORD = os.environ.get("POSTGRES_PASSWORD")

DRY_RUN = os.environ.get("SYNC_DRY_RUN", "").strip().lower() in ("1", "true", "yes", "on")

AUDIO_FORMATS = {"mp3", "m4b", "m4a", "flac", "ogg", "opus", "aac", "wav", "aa", "aax"}

REQUIRED_TABLES = (
    "books",
    "book_metadata",
    "book_files",
    "user_book_status",
    "reading_progress",
    "audiobook_progress",
    "reading_sessions",
)


def log(message):
    print(message, flush=True)


def now():
    return datetime.now(timezone.utc)


def parse_ts(value):
    """Audiobookshelf writes ISO-ish text with a space before the offset."""
    if value in (None, ""):
        return None
    if isinstance(value, (int, float)):
        return datetime.fromtimestamp(value, tz=timezone.utc)
    text = str(value).strip()
    text = re.sub(r"\s+([+-]\d{2}:?\d{2})$", r"\1", text)
    text = re.sub(r"\s+(Z)$", r"+00:00", text)
    try:
        parsed = datetime.fromisoformat(text)
    except ValueError:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed


def clamp(value, low, high):
    return max(low, min(high, value))


def percent(position, duration):
    if not position or not duration or float(duration) <= 0:
        return None
    return clamp((float(position) / float(duration)) * 100.0, 0.0, 100.0)


def to_bookorbit_path(abs_path):
    path = (abs_path or "").strip()
    if not path.startswith(ABS_PATH_ROOT + "/"):
        return None
    return BO_PATH_ROOT + path[len(ABS_PATH_ROOT):]


def norm_title(title):
    if not title:
        return ""
    text = title.lower().strip()
    text = re.sub(r"^(the|a|an)\s+", "", text)
    return re.sub(r"[^a-z0-9]", "", text)


def source_file_paths(audio_files, ebook_file):
    """Absolute paths of the Audiobookshelf files attached to a book."""
    paths = []
    for blob in (audio_files, ebook_file):
        if not blob:
            continue
        try:
            data = json.loads(blob)
        except (TypeError, ValueError):
            continue
        if isinstance(data, dict):
            data = [data]
        for entry in data or []:
            if not isinstance(entry, dict):
                continue
            metadata = entry.get("metadata")
            if not isinstance(metadata, dict):
                metadata = entry
            path = metadata.get("path") or entry.get("path")
            if path:
                paths.append(path)
    return paths


def abs_columns(abs_cur, table):
    return {row[1] for row in abs_cur.execute("PRAGMA table_info(%s)" % table).fetchall()}


def postgres_columns(cur, table):
    cur.execute(
        "SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = %s",
        (table,),
    )
    return {row[0] for row in cur.fetchall()}


def connect_postgres():
    last_error = None
    for attempt in range(1, 6):
        try:
            return psycopg2.connect(
                host=POSTGRES_HOST,
                port=POSTGRES_PORT,
                user=POSTGRES_USER,
                password=POSTGRES_PASSWORD,
                dbname=POSTGRES_DB,
                connect_timeout=10,
            )
        except psycopg2.OperationalError as error:
            last_error = error
            log("Postgres not reachable (attempt %d/5): %s" % (attempt, str(error).strip().splitlines()[0]))
            time.sleep(3)
    raise SystemExit("Error: could not connect to BookOrbit Postgres: %s" % last_error)


def load_catalog(cur):
    """BookOrbit books, their audio files, and the two matching keys."""
    cur.execute("SELECT id, primary_file_id FROM books")
    primary = {book_id: file_id for book_id, file_id in cur.fetchall()}

    cur.execute("SELECT book_id, title FROM book_metadata")
    titles = {}
    for book_id, title in cur.fetchall():
        key = norm_title(title)
        if key and key not in titles:
            titles[key] = book_id

    cur.execute(
        """
        SELECT id, book_id, absolute_path, COALESCE(sort_order, 0), COALESCE(duration_seconds, 0),
               LOWER(COALESCE(format, '')), COALESCE(role, 'content')
        FROM book_files
        """
    )
    by_path = {}
    audio_by_book = {}
    for file_id, book_id, abs_path, sort_order, duration, file_format, role in cur.fetchall():
        if not abs_path:
            continue
        by_path[abs_path] = (book_id, file_id)
        if file_format in AUDIO_FORMATS and role == "content":
            audio_by_book.setdefault(book_id, []).append((file_id, float(duration or 0), sort_order, file_id))
    for files in audio_by_book.values():
        files.sort(key=lambda item: (item[2], item[3]))

    return {"primary": primary, "titles": titles, "by_path": by_path, "audio_by_book": audio_by_book}


def resolve_book(paths, title, catalog):
    for path in paths:
        mapped = to_bookorbit_path(path)
        if mapped and mapped in catalog["by_path"]:
            book_id, file_id = catalog["by_path"][mapped]
            return book_id, file_id, "path"

    key = norm_title(title)
    book_id = catalog["titles"].get(key) if key else None
    if book_id is not None:
        files = catalog["audio_by_book"].get(book_id)
        if files:
            primary = catalog["primary"].get(book_id)
            file_id = primary if any(item[0] == primary for item in files) else files[0][0]
            return book_id, file_id, "title"

    return None, None, None


def audio_position(book_id, position_seconds, catalog):
    """Map a book-wide playback position onto (file_id, offset inside that file)."""
    files = catalog["audio_by_book"].get(book_id) or []
    if not files:
        return None, position_seconds
    remaining = max(0.0, float(position_seconds or 0))
    for file_id, duration, _sort_order, _tiebreak in files:
        if duration and remaining > duration:
            remaining -= duration
            continue
        return file_id, remaining
    file_id, duration, _sort_order, _tiebreak = files[-1]
    return file_id, duration if duration else remaining


def read_abs_progress(abs_cur):
    """Read every book progress row, tolerating Audiobookshelf schema drift."""
    has_progress_column = "progress" in abs_columns(abs_cur, "mediaProgresses")
    select_progress = ", mp.progress" if has_progress_column else ", NULL"

    where = ""
    params = ()
    if ABS_USER_ID:
        where = " WHERE mp.userId = ?"
        params = (ABS_USER_ID,)

    abs_cur.execute(
        """
        SELECT b.title, b.audioFiles, b.ebookFile, mp.userId, mp.currentTime, mp.duration,
               mp.isFinished, mp.finishedAt, mp.updatedAt, mp.mediaItemType%s
        FROM mediaProgresses mp
        JOIN books b ON mp.mediaItemId = b.id%s
        """
        % (select_progress, where),
        params,
    )
    return abs_cur.fetchall(), has_progress_column


def read_abs_sessions(abs_cur):
    where = "WHERE ps.timeListening > 10"
    params = ()
    if ABS_USER_ID:
        where += " AND ps.userId = ?"
        params = (ABS_USER_ID,)

    abs_cur.execute(
        """
        SELECT ps.id, ps.userId, ps.startTime, ps.currentTime, ps.duration, ps.timeListening,
               ps.createdAt, ps.updatedAt, b.title, b.audioFiles, b.ebookFile
        FROM playbackSessions ps
        JOIN books b ON ps.mediaItemId = b.id
        %s
        """
        % where,
        params,
    )
    return abs_cur.fetchall()


def newest_by(rows, key, time_index):
    """Collapse rows that target the same BookOrbit key onto the newest one."""
    chosen = {}
    for row in rows:
        row_key = key(row)
        current = chosen.get(row_key)
        if current is None or row[time_index] > current[time_index]:
            chosen[row_key] = row
    return list(chosen.values())


def build_plans(progress_rows, session_rows, catalog):
    status_rows = []
    progress_rows_out = []
    audiobook_rows_out = []
    unmatched = []
    source_users = set()
    fallback_matches = 0

    for row in progress_rows:
        (
            title,
            audio_files,
            ebook_file,
            user_id,
            current_time,
            duration,
            is_finished,
            finished_at,
            updated_at,
            media_item_type,
            progress_fraction,
        ) = row

        if media_item_type and media_item_type != "book":
            continue

        book_id, file_id, how = resolve_book(source_file_paths(audio_files, ebook_file), title, catalog)
        if book_id is None:
            unmatched.append(title)
            continue
        if how == "title":
            fallback_matches += 1

        source_users.add(user_id)
        updated = parse_ts(updated_at) or now()
        current_time = float(current_time or 0)
        duration = float(duration or 0)

        if progress_fraction is not None:
            percentage = clamp(float(progress_fraction) * 100.0, 0.0, 100.0)
        else:
            percentage = percent(current_time, duration)

        if is_finished:
            status_rows.append(
                (BOOKORBIT_USER_ID, book_id, "read", "auto", parse_ts(finished_at) or updated, updated)
            )
            continue

        if percentage is None or percentage <= 0:
            continue

        status_rows.append((BOOKORBIT_USER_ID, book_id, "reading", "auto", None, updated))

        position_file, offset = audio_position(book_id, current_time, catalog)
        position_file = position_file or file_id
        progress_rows_out.append(
            (
                position_file,
                BOOKORBIT_USER_ID,
                percentage,
                offset,
                percentage,
                updated,
                updated,
                now(),
            )
        )
        audiobook_rows_out.append(
            (BOOKORBIT_USER_ID, book_id, percentage, position_file, offset, 1, updated, now())
        )

    session_rows_out = []
    session_unmatched = 0
    session_undated = 0
    for row in session_rows:
        (
            session_id,
            user_id,
            start_time,
            current_time,
            duration,
            time_listening,
            created_at,
            updated_at,
            title,
            audio_files,
            ebook_file,
        ) = row

        book_id, file_id, how = resolve_book(source_file_paths(audio_files, ebook_file), title, catalog)
        if book_id is None:
            session_unmatched += 1
            continue
        if how == "title":
            fallback_matches += 1

        started = parse_ts(created_at) or parse_ts(updated_at)
        if started is None:
            session_undated += 1
            continue
        listened = max(0, int(time_listening or 0))
        ended = parse_ts(updated_at) or started
        earliest_end = started + timedelta(seconds=listened)
        if ended < earliest_end:
            ended = earliest_end

        duration = float(duration or 0)
        position_file, _offset = audio_position(book_id, current_time, catalog)
        delta = None
        end_progress = None
        if duration > 0:
            delta = clamp(((float(current_time or 0) - float(start_time or 0)) / duration) * 100.0, 0.0, 100.0)
            end_progress = percent(current_time, duration)

        session_rows_out.append(
            (
                BOOKORBIT_USER_ID,
                book_id,
                position_file or file_id,
                "abs:%s" % session_id,
                SESSION_SOURCE,
                "listen",
                started,
                ended,
                listened,
                delta,
                end_progress,
            )
        )

    return {
        "status": newest_by(status_rows, lambda row: (row[0], row[1]), 5),
        "progress": newest_by(progress_rows_out, lambda row: (row[0], row[1]), 6),
        "audiobook": newest_by(audiobook_rows_out, lambda row: (row[0], row[1]), 6),
        "sessions": newest_by(session_rows_out, lambda row: row[3], 7),
        "unmatched": unmatched,
        "session_unmatched": session_unmatched,
        "session_undated": session_undated,
        "fallback_matches": fallback_matches,
        "source_users": sorted(str(user) for user in source_users),
    }


STATUS_SQL = """
INSERT INTO user_book_status AS ubs (user_id, book_id, status, source, finished_at, updated_at)
VALUES %s
ON CONFLICT (user_id, book_id) DO UPDATE
SET status = EXCLUDED.status,
    finished_at = COALESCE(EXCLUDED.finished_at, ubs.finished_at),
    updated_at = EXCLUDED.updated_at
WHERE EXCLUDED.updated_at > ubs.updated_at
"""

PROGRESS_SQL = """
INSERT INTO reading_progress AS rp
    (book_file_id, user_id, percentage, position_seconds, narration_percentage, narration_updated_at, last_read_at, updated_at)
VALUES %s
ON CONFLICT (book_file_id, user_id) DO UPDATE
SET percentage = EXCLUDED.percentage,
    position_seconds = EXCLUDED.position_seconds,
    narration_percentage = EXCLUDED.narration_percentage,
    narration_updated_at = EXCLUDED.narration_updated_at,
    last_read_at = EXCLUDED.last_read_at,
    updated_at = EXCLUDED.updated_at
WHERE EXCLUDED.last_read_at > rp.last_read_at
"""

AUDIOBOOK_SQL = """
INSERT INTO audiobook_progress AS abp
    (user_id, book_id, percentage, current_file_id, position_seconds, revision, captured_at, updated_at)
VALUES %s
ON CONFLICT (user_id, book_id) DO UPDATE
SET percentage = EXCLUDED.percentage,
    current_file_id = EXCLUDED.current_file_id,
    position_seconds = EXCLUDED.position_seconds,
    revision = abp.revision + 1,
    captured_at = EXCLUDED.captured_at,
    updated_at = EXCLUDED.updated_at
WHERE EXCLUDED.updated_at > abp.updated_at
"""

SESSION_SQL = """
INSERT INTO reading_sessions
    (user_id, book_id, book_file_id, session_id, source, session_type, started_at, ended_at, duration_seconds, progress_delta, end_progress)
VALUES %s
ON CONFLICT (user_id, session_id) DO NOTHING
"""


def write_rows(cur, sql, rows, label):
    if not rows:
        log("%s: nothing to write" % label)
        return 0
    execute_values(cur, sql, rows, page_size=500)
    log("%s: %d row(s)" % (label, len(rows)))
    return len(rows)


def sync():
    if not POSTGRES_PASSWORD:
        raise SystemExit("Error: POSTGRES_PASSWORD environment variable is required.")
    if not os.path.exists(ABS_DB_PATH):
        raise SystemExit("Error: Audiobookshelf database not found at %s" % ABS_DB_PATH)

    abs_conn = sqlite3.connect("file:%s?mode=ro" % ABS_DB_PATH, uri=True)
    abs_cur = abs_conn.cursor()

    conn = connect_postgres()
    conn.autocommit = False
    cur = conn.cursor()

    try:
        for table in REQUIRED_TABLES:
            if not postgres_columns(cur, table):
                raise SystemExit("Error: BookOrbit table %s is missing; the sync targets an incompatible schema." % table)

        catalog = load_catalog(cur)
        conn.rollback()

        progress_rows, has_progress_column = read_abs_progress(abs_cur)
        session_rows = read_abs_sessions(abs_cur)
        plans = build_plans(progress_rows, session_rows, catalog)

        log(
            "ABS: %d progress row(s) (progress column %s), %d session(s) over 10s"
            % (len(progress_rows), "present" if has_progress_column else "absent", len(session_rows))
        )
        log(
            "matched: %d progress, %d session(s) (title fallback %d, ABS user(s) %s)"
            % (
                len(plans["status"]),
                len(plans["sessions"]),
                plans["fallback_matches"],
                ", ".join(plans["source_users"]) or "none",
            )
        )

        write_rows(cur, STATUS_SQL, plans["status"], "user_book_status")
        write_rows(cur, PROGRESS_SQL, plans["progress"], "reading_progress")
        write_rows(cur, AUDIOBOOK_SQL, plans["audiobook"], "audiobook_progress")
        write_rows(cur, SESSION_SQL, plans["sessions"], "reading_sessions")

        if DRY_RUN:
            conn.rollback()
            log("dry run: rolled back, nothing written")
        else:
            conn.commit()
            log("committed")
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()
        abs_conn.close()

    if plans["unmatched"]:
        log(
            "skipped %d progress row(s) with no BookOrbit book: %s"
            % (len(plans["unmatched"]), ", ".join(sorted(plans["unmatched"])[:15]))
        )
    if plans["session_unmatched"]:
        log("skipped %d session(s) with no BookOrbit book" % plans["session_unmatched"])
    if plans["session_undated"]:
        log("skipped %d session(s) with unreadable timestamps" % plans["session_undated"])


def main(argv):
    global DRY_RUN
    if "--dry-run" in argv[1:]:
        DRY_RUN = True
    sync()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
