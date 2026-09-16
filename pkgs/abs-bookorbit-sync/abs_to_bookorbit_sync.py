#!/usr/bin/env python3
"""
Audiobookshelf -> BookOrbit One-Way Progress & History Sync
Syncs playback progress, read status, and listening sessions from ABS into BookOrbit.

All credentials and targets are loaded exclusively from environment variables.
"""

import os
import re
import sqlite3
import sys
from datetime import datetime
import psycopg2
from psycopg2.extras import execute_batch

# Configuration strictly from Environment / Secrets
ABS_DB_PATH = os.environ.get("ABS_DB_PATH", "/var/lib/audiobookshelf/config/absdatabase.sqlite")
POSTGRES_HOST = os.environ.get("POSTGRES_HOST", "127.0.0.1")
POSTGRES_PORT = int(os.environ.get("POSTGRES_PORT", "5422"))
POSTGRES_USER = os.environ.get("POSTGRES_USER", "bookorbit")
POSTGRES_DB = os.environ.get("POSTGRES_DB", "bookorbit")
POSTGRES_PASSWORD = os.environ.get("POSTGRES_PASSWORD")
BOOKORBIT_USER_ID = int(os.environ.get("BOOKORBIT_USER_ID", "1"))

if not POSTGRES_PASSWORD:
    print("Error: POSTGRES_PASSWORD environment variable is required.", file=sys.stderr)
    sys.exit(1)

def norm(s):
    if not s:
        return ""
    s = s.lower()
    s = re.sub(r"^(the|a|an)\s+", "", s)
    return re.sub(r"[^a-z0-9]", "", s)

def load_bookorbit_catalog(bo_cur):
    bo_cur.execute("""
        SELECT b.id, bm.title, b.folder_path, b.primary_file_id
        FROM books b
        JOIN book_metadata bm ON b.id = bm.book_id;
    """)
    rows = bo_cur.fetchall()
    catalog = {}
    for bid, title, folder_path, primary_file_id in rows:
        entry = {
            "book_id": bid,
            "title": title,
            "primary_file_id": primary_file_id,
            "folder_path": folder_path
        }
        n_title = norm(title)
        if n_title:
            catalog[n_title] = entry
        if folder_path:
            folder_name = norm(folder_path.rstrip("/").split("/")[-1])
            if folder_name and folder_name not in catalog:
                catalog[folder_name] = entry
    return catalog

def match_book(title, catalog):
    n_title = norm(title)
    if n_title in catalog:
        return catalog[n_title]
    if len(n_title) > 6:
        for k, entry in catalog.items():
            if n_title in k or k in n_title:
                return entry
    return None

def sync():
    if not os.path.exists(ABS_DB_PATH):
        print(f"Error: Audiobookshelf database not found at {ABS_DB_PATH}", file=sys.stderr)
        sys.exit(1)

    # 1. Connect to ABS (Read-Only URI mode)
    abs_conn = sqlite3.connect(f"file:{ABS_DB_PATH}?mode=ro", uri=True)
    abs_cur = abs_conn.cursor()

    # 2. Connect to BookOrbit Postgres
    bo_conn = psycopg2.connect(
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        dbname=POSTGRES_DB
    )
    bo_cur = bo_conn.cursor()

    catalog = load_bookorbit_catalog(bo_cur)

    # 3. Query Progress & Completed Books from ABS
    abs_cur.execute("""
        SELECT b.id, b.title, mp.currentTime, mp.duration, mp.progress, mp.isFinished, mp.finishedAt, mp.updatedAt
        FROM mediaProgresses mp
        JOIN books b ON mp.mediaItemId = b.id;
    """)
    progress_rows = abs_cur.fetchall()

    completed_to_apply = []
    in_progress_to_apply = []

    for _, title, current_time, duration, progress, is_finished, finished_at, updated_at in progress_rows:
        matched = match_book(title, catalog)
        if not matched:
            continue

        bid = matched["book_id"]
        primary_file_id = matched["primary_file_id"]

        if is_finished == 1:
            completed_to_apply.append((
                BOOKORBIT_USER_ID,
                bid,
                "read",
                finished_at,
                datetime.utcnow()
            ))
        elif current_time and current_time > 0 and duration and duration > 0:
            pct = min(100.0, max(0.0, (current_time / duration) * 100.0))
            in_progress_to_apply.append({
                "user_id": BOOKORBIT_USER_ID,
                "book_id": bid,
                "primary_file_id": primary_file_id,
                "position_seconds": current_time,
                "percentage": pct,
                "last_read_at": updated_at
            })

    # Apply Completed Books (preserving historical finish dates)
    if completed_to_apply:
        execute_batch(bo_cur, """
            INSERT INTO user_book_status (user_id, book_id, status, finished_at, updated_at)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (user_id, book_id) DO UPDATE
            SET status = EXCLUDED.status,
                finished_at = COALESCE(EXCLUDED.finished_at, user_book_status.finished_at),
                updated_at = EXCLUDED.updated_at;
        """, completed_to_apply)

    # Apply In-Progress Books
    for item in in_progress_to_apply:
        bo_cur.execute("""
            INSERT INTO user_book_status (user_id, book_id, status, updated_at)
            VALUES (%s, %s, 'reading', %s)
            ON CONFLICT (user_id, book_id) DO UPDATE
            SET status = 'reading',
                updated_at = EXCLUDED.updated_at
            WHERE user_book_status.status != 'read';
        """, (item["user_id"], item["book_id"], item["last_read_at"]))

        if item["primary_file_id"]:
            bo_cur.execute("""
                INSERT INTO reading_progress (book_file_id, user_id, percentage, position_seconds, last_read_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (book_file_id, user_id) DO UPDATE
                SET percentage = EXCLUDED.percentage,
                    position_seconds = EXCLUDED.position_seconds,
                    last_read_at = EXCLUDED.last_read_at,
                    updated_at = EXCLUDED.updated_at;
            """, (
                item["primary_file_id"],
                item["user_id"],
                item["percentage"],
                item["position_seconds"],
                item["last_read_at"],
                datetime.utcnow()
            ))

    # 4. Sync Listening Sessions
    abs_cur.execute("""
        SELECT ps.id, b.title, ps.startTime, ps.currentTime, ps.duration, ps.timeListening, ps.createdAt, ps.updatedAt
        FROM playbackSessions ps
        JOIN books b ON ps.mediaItemId = b.id
        WHERE ps.timeListening > 10;
    """)
    session_rows = abs_cur.fetchall()

    sessions_to_insert = []
    for sid, title, start_time, current_time, duration, time_listening, created_at, updated_at in session_rows:
        matched = match_book(title, catalog)
        if not matched:
            continue

        bid = matched["book_id"]
        primary_file_id = matched["primary_file_id"]

        progress_delta = 0.0
        end_progress = 0.0
        if duration and duration > 0:
            progress_delta = max(0.0, (current_time - start_time) / duration)
            end_progress = min(1.0, max(0.0, current_time / duration))

        sessions_to_insert.append((
            BOOKORBIT_USER_ID,
            bid,
            primary_file_id,
            str(sid),
            created_at,
            updated_at,
            time_listening,
            progress_delta,
            end_progress,
            "abs"
        ))

    if sessions_to_insert:
        execute_batch(bo_cur, """
            INSERT INTO reading_sessions (
                user_id, book_id, book_file_id, session_id,
                started_at, ended_at, duration_seconds,
                progress_delta, end_progress, source
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (session_id) DO NOTHING;
        """, sessions_to_insert)

    bo_conn.commit()
    bo_cur.close()
    bo_conn.close()
    abs_conn.close()
    print("ABS to BookOrbit sync completed.")

if __name__ == "__main__":
    sync()
