import QtQuick 2.12
import QtQuick.Controls 2.12

Slider {
    id: control
    property string backgroundColor: ""
    property string foregroundColor: ""
    property string cursorColor    : ""

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        width: control.width
        height: parent.height
        radius: Math.min(width, height) / 2

        color: backgroundColor

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius

            color: foregroundColor
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: parent.width / 30
        height: 0
        radius: Math.min(width, height) / 2
        color: cursorColor
        border.color: "#BDBEBF"
    }
}
