//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark
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

    Variants {
        model: Quickshell.screens
        delegate: Component {
            Omadeck {}
        }
    }
}

