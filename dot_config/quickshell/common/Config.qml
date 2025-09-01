pragma Singleton

import QtQuick

QtObject {
    id: config

    // Bar dimensions
    readonly property int barHeight: 40
    readonly property int barRadius: 1
    readonly property string barBackgroundColor: "#161217"

    // Bar layout spacing
    readonly property int barContentLeftMargin: 8
    readonly property int barContentRightMargin: 8
    readonly property int barContentSpacing: 4

    // BarGroup styling
    readonly property int groupBackgroundMarginLeft: 4
    readonly property int groupBackgroundMarginRight: 4
    readonly property int groupBorderWidth: 1
    readonly property int groupRadius: 4
    readonly property string groupBorderColor: "transparent"
    readonly property int groupColumnSpacing: 4
    readonly property int groupRowSpacing: 12
    readonly property int groupImplicitWidthPadding: 8

    // Workspace indicators
    readonly property int workspaceSpacing: 4
    readonly property int workspaceWidth: 24
    readonly property int workspaceHeight: 20
    readonly property int workspaceRadius: 4
    readonly property int workspaceFontSize: 12
    readonly property int workspaceBorderWidth: 2
    readonly property string workspaceActiveColor: "#89b4fa"
    readonly property string workspaceActiveBrightColor: "#89b4fa"
    readonly property string workspaceOccupiedColor: "#4a5568"
    readonly property string workspaceEmptyColor: "#2d3748"
    readonly property string workspaceActiveBorderColor: "#89b4fa"
    readonly property string workspaceActiveTextColor: "#ffffff"
    readonly property string workspaceOccupiedTextColor: "#e2e8f0"
    readonly property string workspaceEmptyTextColor: "#718096"

    // Battery indicator
    readonly property int batteryFontSize: 12
    readonly property int batterySpacing: 4
    readonly property string batteryTextColor: "white"

    // Clock widget
    readonly property string clockTextColor: "white"
    readonly property int clockFontSize: 14

    // Animation durations
    readonly property int colorAnimationDuration: 200
}
