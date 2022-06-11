import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    width: parent.width
    height: parent.height

    color: background

    property string background  : ""
    property alias model        : menu.model
    property alias delegate     : menu.delegate

    ScrollView {
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ListView {
            id: menu
            anchors.fill: parent
            clip: true  // While swipe item's do not overlap another ui
        }
    }
}
