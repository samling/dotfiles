pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property alias wallust: wallustAdapter

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/quickshell/generated/wallust.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: wallustAdapter

            property string background: "#151217"
            property string foreground: "#e8e0e8"
            property string cursor: "#ddb9f8"
            property string color0: "#100d12"
            property string color1: "#221e24"
            property string color2: "#2d292e"
            property string color3: "#383339"
            property string color4: "#4b454d"
            property string color5: "#573a70"
            property string color6: "#705289"
            property string color7: "#968e98"
            property string color8: "#4b454d"
            property string color9: "#573a70"
            property string color10: "#705289"
            property string color11: "#8b6ca1"
            property string color12: "#a485b9"
            property string color13: "#c29ed1"
            property string color14: "#ddb9f8"
            property string color15: "#f1daff"
        }
    }
}
