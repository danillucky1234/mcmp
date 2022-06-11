import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: playlistComponent
    width: parent.width
    height: parent.height

    property string title               : ""
    property string tracksCount         : ""
    property string textColor           : ""

    property alias  playlistIcon        : playlistImage.source
    property alias  settingsIcon        : settingsIcon.source
    property int    imageWidth          : 27 * QmlAdapter.scalefactor
    property int    imageHeight         : 27 * QmlAdapter.scalefactor
    property int    margins             : QmlAdapter.scalefactor
    property var    settingsButtonAction: function(){}
    property bool   isShowSettings      : true

    Item {
        id: image
        width: isShowSettings ? parent.width / 8 : parent.width / 7
        height: parent.height
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: margins
            bottom: parent.bottom
        }

        Image {
            id: playlistImage
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            sourceSize.width: imageWidth
            sourceSize.height: imageHeight
            source: ""
        }
    }

    Item {
        id: titleText
        width: isShowSettings ? parent.width - image.width - settings.width : parent.width - image.width
        height: parent.height
        anchors {
            top: parent.top
            left: image.right
            bottom: parent.bottom
            right: settings.left
            leftMargin: 8 * QmlAdapter.scalefactor
        }
        Item {
            width: parent.width
            height: parent.height / 2
            anchors {
                top: parent.top
            }

            Text {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: margins
                }
                text: title
                font.pointSize: 6 * QmlAdapter.scalefactor
                color: textColor
            }
        }

        Item {
            width: parent.width
            height: parent.height / 2
            anchors {
                bottom: parent.bottom
            }

            Text {
                anchors {
                    topMargin: margins
                    top: parent.top
                }
                text: tracksCount + " tracks"
                font.pointSize: 4 * QmlAdapter.scalefactor
                color: "#F2F2EB"
            }
        }
    }

    Button {
        id: settings
        width: parent.width / 10
        height: parent.height
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        visible: isShowSettings

        background: Rectangle {
            color: playlistComponent.color
        }

        contentItem: Item {
            anchors.fill: parent
            width: imageWidth
            height: imageHeight
            Image {
                id: settingsIcon
                anchors.centerIn: parent

                fillMode: Image.PreserveAspectFit
                sourceSize.width: imageWidth
                sourceSize.height: imageHeight
                source: ""
            }
        }
        onClicked: settingsButtonAction()
    }
}
