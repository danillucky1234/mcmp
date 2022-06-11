import QtQuick 2.0
import QtQuick.Controls 2.0
import QtMultimedia 5.9

Rectangle {
    id: trackComponent
    width: parent.width
    height: parent.height

    property string path				: ""
    property string textColor           : ""

    property alias  settingsIcon        : settingsIcon.source
    property int    imageWidth          : 30 * QmlAdapter.scalefactor
    property int    imageHeight         : 30 * QmlAdapter.scalefactor
    property int    textSize            : 5 * QmlAdapter.scalefactor
    property int    margins             : 4 * QmlAdapter.scalefactor
    property var    settingsButtonAction: function(){}

    property var    utilDate            : new Date();

    function convertMsecToString(msecs) {
        utilDate.setTime(msecs);
        return Qt.formatTime(utilDate, "mm:ss");
    }

    // To extract metadata from audioFile
    MediaPlayer {
        id: player
        audioRole: MediaPlayer.MusicRole
        source: path

        onError: {
            console.log("Track component. MediaPlayer error: " + errorString);
        }
    }
    Connections {
        target: player.metaData
        function onMetaDataChanged() {
            trackTitleText.text = player.metaData.title || QmlAdapter.getBaseNameFromPath(player.source);
            authorText.text = player.metaData.albumArtist || player.metaData.contributingArtist || QmlAdapter.unknownAuthor;
            durationText.text = convertMsecToString(player.duration);
        }
    }

    Item {
        id: trackTitleItem
        width: trackComponent.width - settingsIcon.width
        height: trackComponent.height / 2
        anchors {
            top: trackComponent.top
            left: trackComponent.left
            right: settingsItem.left
        }

        Text {
            id: trackTitleText
            anchors {
                left: parent.left
                leftMargin: margins
                verticalCenter: parent.verticalCenter
            }

            text: ""
            font.pointSize: textSize
            color: textColor
        }
    }

    Item {
        id: authorItem
        width: trackTitleItem.width - durationItem.width
        height: trackComponent.height / 2
        anchors {
            top: trackTitleItem.bottom
            left: trackComponent.left
        }

        Text {
            id: authorText
            anchors {
                left: parent.left
                leftMargin: margins
                verticalCenter: parent.verticalCenter
            }

            text: ""
            font.pointSize: textSize
            color: textColor
        }
    }

    Item {
        id: durationItem
        width: trackComponent.width / 15
        height: authorItem.height
        anchors {
            top: trackTitleItem.bottom
            right: settingsItem.left
        }

        Text {
            id: durationText
            anchors{
                right: parent.right
                verticalCenter: parent.verticalCenter

            }
            text: ""
            font.pointSize: textSize
            color: textColor
        }
    }

    Button {
        id: settingsItem
        width: trackComponent.width / 10
        height: trackComponent.height
        anchors {
            top: trackComponent.top
            right: trackComponent.right
            bottom: trackComponent.bottom
        }

        background: Rectangle {
            color: trackComponent.color
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
        onClicked: {
            settingsButtonAction();
        }
    }
}
