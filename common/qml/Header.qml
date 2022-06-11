import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: header
    width: parent.width
    height: parent.height

    property alias  menuIcon            : menuIconImage.source
    property string title               : ""
    property int    imageWidth          : 25 * QmlAdapter.scalefactor
    property int    imageHeight         : 25 * QmlAdapter.scalefactor
    property string backgroundColor     : ""
    property string foregroundColor     : ""
    property var    menuButtonAction    : function(){}

    color: header.backgroundColor

    Row {
        anchors.fill: parent

        Button {
            id: menuIconRect
            width: parent.width / 4
            height: parent.height

            background: Rectangle {
                color: backgroundColor
            }
            contentItem: Item {
                anchors.centerIn: menuIconRect
                width: imageWidth
                height: imageHeight
                Image {
                    id: menuIconImage
                    sourceSize.width: imageWidth
                    sourceSize.height: imageHeight
                    anchors.centerIn: parent
                    source: ""
                }
            }
            onClicked: {
                menuButtonAction();
            }
        }

        Rectangle {
            id: titleRect
            width: parent.width / 2
            height: parent.height
            color: backgroundColor

            Text {
                anchors.centerIn: parent
                color: foregroundColor
                text: title
                font.pointSize: QmlAdapter.scalefactor * 8
            }
        }

        Item {
            id: searchIconRect
            width: parent.width / 4
            height: parent.height
        }
    }
}
