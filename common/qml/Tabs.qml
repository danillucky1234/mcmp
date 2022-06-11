import QtQuick 2.0
import QtQuick.Controls 2.0
import 'qrc:/customComponents/' as Custom

ListView {
    id: tabs
    width: parent.width
    height: parent.height
    property string background          : ""
    property string foreground          : ""
    property string activeBackground    : ""
    property string activeForeground    : ""
    property string separatorColor      : ""

    orientation: ListView.Horizontal
    interactive: false

    model: []
    currentIndex: 0
    delegate: Item {
        width: tabs.width / tabs.count
        height: parent.height

        Custom.TabButton {
            anchors.fill: parent
            titleText: model.text
            backgroundColor: currentIndex === index ? activeBackground : background
            foregroundColor: currentIndex === index ? activeForeground : foreground
            separatorColor: tabs.separatorColor
            isActive: currentIndex === index
            onClickAction: model.onClickAction
        }
        MouseArea {
            id: mouseArea

            anchors.fill: parent
            enabled: currentIndex !== index
            onClicked: {
                currentIndex = index
            }
        }
    }
}
