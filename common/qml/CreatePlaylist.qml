import QtQuick 2.0
import QtQuick.Controls 2.5

Rectangle {
    id: rootRect
    width: parent.width
    height: parent.height

    property string backgroundColor     : QmlAdapter.colors.backgroundLight
    property string backgroundDarkColor : QmlAdapter.colors.backgroundDark
    property string progressActiveColor : QmlAdapter.colors.progressActive
    property string foregroundColor     : QmlAdapter.colors.foreground

    property int    margins             : 10 * QmlAdapter.scalefactor
    property int    imageWidth          : 30 * QmlAdapter.scalefactor
    property int    imageHeight         : 30 * QmlAdapter.scalefactor

    property var    onSubmitButtonAction: function(imageSource, playlisttTitle) {}

    color: backgroundColor

    Item {
        id: header
        width: rootRect.width
        height: rootRect.height * 2/10
        anchors {
            top: rootRect.top
        }

        Text {
            anchors {
                fill: parent
                margins: rootRect.margins
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Enter the playlist name:"
            color: rootRect.foregroundColor
            font {
                pointSize: 6 * QmlAdapter.scalefactor
            }
        }
        Separator {
            anchors.bottom: header.bottom
        }
    }

    Item {
        id: body
        width: rootRect.width
        height: rootRect.height * 6/10
        anchors {
            top: header.bottom
        }

        Item {
            id: image
            width: body.width * 2/10
            height: body.height
            anchors {
                top: body.top
                left: body.left
                leftMargin: margins
                bottom: body.bottom
            }

            Image {
                id: playlistImage
                anchors.centerIn: image
                fillMode: Image.PreserveAspectFit
                sourceSize.width: imageWidth
                sourceSize.height: imageHeight
                source: QmlAdapter.getImagePath("heart.svg") // Default image
                MouseArea {
                    anchors.fill: playlistImage
                    onClicked: {
                        console.log("image playlist clicked and wanna be changed!!");
                    }
                }
            }
        }

        Item {
            id: title
            width: body.width * 8/10
            height: body.height
            anchors {
                top: body.top
                left: image.right
                right: body.right
                margins: margins
                bottom: body.bottom
            }

            TextInput {
                id: titleInput
                width: title.width
                height: playlistImage.implicitHeight
                anchors.centerIn: title
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: rootRect.foregroundColor
                focus: true
                clip: true
            }

            Separator {
                id: bottomBorder
                color: rootRect.progressActiveColor
                anchors.bottom: titleInput.bottom
            }
        }
    }

    Button {
        id: submitButton
        width: rootRect.width
        height: rootRect.height * 2/10

        anchors {
            top: body.bottom
            bottom: rootRect.bottom
        }

        background: Rectangle {
            color: rootRect.backgroundDarkColor
        }

        contentItem: Item {
            anchors.fill: parent

            Separator {
                anchors.top: parent.top
            }

            Text {
                text: "Submit"
                color: rootRect.progressActiveColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
            }
        }
        onClicked: {
            if (titleInput.text && playlistImage.source) {
                rootRect.onSubmitButtonAction(playlistImage.source, titleInput.text);
            }
        }
    }
}
