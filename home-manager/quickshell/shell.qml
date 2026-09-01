//@ pragma UseQApplication
import QtQuick
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Component {
            Bar {}
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            Osd {}
        }
    }
}
