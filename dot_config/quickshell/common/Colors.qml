pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property alias md3: jsonAdapter.md3
    property alias custom: jsonAdapter.custom

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/quickshell/generated/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonAdapter

            readonly property Md3 md3: Md3 {}
            readonly property Custom custom: Custom {}
        }
    }

    component Md3: JsonObject {
        property string background: "#151217"
        property string error: "#ffb4ab"
        property string error_container: "#93000a"
        property string inverse_on_surface: "#332f35"
        property string inverse_primary: "#705289"
        property string inverse_surface: "#e8e0e8"
        property string on_background: "#e8e0e8"
        property string on_error: "#690005"
        property string on_error_container: "#ffdad6"
        property string on_primary: "#402357"
        property string on_primary_container: "#f1daff"
        property string on_primary_fixed: "#290c41"
        property string on_primary_fixed_variant: "#573a70"
        property string on_secondary: "#372c3f"
        property string on_secondary_container: "#eeddf6"
        property string on_secondary_fixed: "#211829"
        property string on_secondary_fixed_variant: "#4e4256"
        property string on_surface: "#e8e0e8"
        property string on_surface_variant: "#cdc4ce"
        property string on_tertiary: "#4c2529"
        property string on_tertiary_container: "#ffdadc"
        property string on_tertiary_fixed: "#321015"
        property string on_tertiary_fixed_variant: "#663a3f"
        property string outline: "#968e98"
        property string outline_variant: "#4b454d"
        property string primary: "#ddb9f8"
        property string primary_container: "#573a70"
        property string primary_fixed: "#f1daff"
        property string primary_fixed_dim: "#ddb9f8"
        property string scrim: "#000000"
        property string secondary: "#d1c1d9"
        property string secondary_container: "#4e4256"
        property string secondary_fixed: "#eeddf6"
        property string secondary_fixed_dim: "#d1c1d9"
        property string shadow: "#000000"
        property string surface: "#151217"
        property string surface_bright: "#3c383e"
        property string surface_container: "#221e24"
        property string surface_container_high: "#2d292e"
        property string surface_container_highest: "#383339"
        property string surface_container_low: "#1e1a20"
        property string surface_container_lowest: "#100d12"
        property string surface_dim: "#151217"
        property string surface_tint: "#ddb9f8"
        property string surface_variant: "#4b454d"
        property string tertiary: "#f3b7bc"
        property string tertiary_container: "#663a3f"
        property string tertiary_fixed: "#ffdadc"
        property string tertiary_fixed_dim: "#f3b7bc"
    }

    component Custom: JsonObject {
        property string source_color: "#a58cb7"
        property string term_blue: "#b8c4ff"
        property string term_blue_container: "#374379"
        property string term_blue_source: "#89b4fa"
        property string term_blue_value: "#89b4fa"
        property string term_cyan: "#80d4d7"
        property string term_cyan_container: "#004f52"
        property string term_cyan_source: "#94e2d5"
        property string term_cyan_value: "#94e2d5"
        property string term_green: "#91d5ad"
        property string term_green_container: "#035233"
        property string term_green_source: "#a6e3a1"
        property string term_green_value: "#a6e3a1"
        property string term_magenta: "#dbb9f9"
        property string term_magenta_container: "#563b71"
        property string term_magenta_source: "#cba6f7"
        property string term_magenta_value: "#cba6f7"
        property string term_orange: "#ffb59d"
        property string term_orange_container: "#723520"
        property string term_orange_source: "#fab387"
        property string term_orange_value: "#fab387"
        property string term_red: "#fbb0d8"
        property string term_red_container: "#6c3455"
        property string term_red_source: "#f38ba8"
        property string term_red_value: "#f38ba8"
        property string term_yellow: "#f5bd6f"
        property string term_yellow_container: "#633f00"
        property string term_yellow_source: "#f9e2af"
        property string term_yellow_value: "#f9e2af"
    }
}
