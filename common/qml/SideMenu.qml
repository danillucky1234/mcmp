import QtQuick 2.0
import QtQuick.Controls 2.5

Rectangle {
    id: side
    width: parent.width
    height: parent.height

    property string backgroundColor        : QmlAdapter.colors.backgroundLight
    property string foregroundColor        : QmlAdapter.colors.foreground

    property int    imageWidth             : 12 * QmlAdapter.scalefactor
    property int    imageHeight            : 12 * QmlAdapter.scalefactor
    property int    margins                : 5 * QmlAdapter.scalefactor

    property var    onRadioClicked         : function() {}
    property var    onSettingsClicked      : function() {}

    color: side.backgroundColor

    Menue {
        id: sideMenu
        anchors.fill: parent

        property int items: 10
        background: side.backgroundColor

        model: ListModel {
            ListElement {
                text: "Radio"
                action: function() {side.onRadioClicked();}
            }
            ListElement {
                text: "Settings"
                action: function() {side.onSettingsClicked();}
            }
        }

        delegate: Button {
            width: sideMenu.width
            height: sideMenu.height / sideMenu.items

            background: Rectangle {
                color: side.backgroundColor
            }

            contentItem: Rectangle {
                anchors.fill: parent
                color: side.backgroundColor

                Item {
                    id: image
                    width: parent.width * 2/10
                    height: parent.height
                    anchors {
                        top: parent.top
                        left: parent.left
                    }

                    Image {
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width:  side.imageWidth
                        sourceSize.height: side.imageHeight
                        source: QmlAdapter.getImagePath("circle.svg")
                    }
                }

                Item {
                    id: caption
                    width: parent.width * 8/10
                    height: parent.height
                    anchors {
                        top: parent.top
                        left: image.right
                        right: parent.right
                        rightMargin: side.margins

                        bottom: parent.bottom
                    }

                    Text {
                        anchors {
                            fill: parent
                        }
                        verticalAlignment: Qt.AlignVCenter
                        text: model.text
                        color: side.foregroundColor
                        font.pointSize: 5 * QmlAdapter.scalefactor
                    }
                }
                Separator {
                    anchors.bottom: parent.bottom
                }
            }

            onClicked: model.action()
        }
    }
}
