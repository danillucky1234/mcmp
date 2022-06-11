import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: tracksInPlaylist
    width: parent.width
    height: parent.height

    property string backgroundColor     : QmlAdapter.colors.backgroundLight
    property string foregroundColor     : QmlAdapter.colors.foreground

    property string settingsIconPath    : ""
    property string backButtonPath      : QmlAdapter.getImagePath("circle-left.svg")
    property int    imageWidth          : 25 * QmlAdapter.scalefactor
    property int    imageHeight         : 25 * QmlAdapter.scalefactor
    property int    margins             : QmlAdapter.scalefactor
    property int    itemsOnPage         : 10
    property int    titleHeight       	: tracksInPlaylist.height / 18

    property alias  tracksModel         : tracksPage.tracksModel
    property string title       		: ""

    property var    settingsButtonAction: function(index, modelData) {}
    property var    playSound           : function(path) {}
    property var    backButtonAction    : function() {}

    color: backgroundColor

    Rectangle {
        id: playlistTitle
        width: tracksInPlaylist.width
        height: tracksInPlaylist.titleHeight
        color: tracksInPlaylist.backgroundColor
        anchors {
            top: tracksInPlaylist.top
        }

        Button {
            id: backButton
            width: parent.width / 8
            height: parent.height
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }

            background: Rectangle {
                color: tracksInPlaylist.color
            }

            contentItem: Item {
                anchors.fill: parent
                width: imageWidth
                height: imageHeight

                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: imageWidth
                    sourceSize.height: imageHeight
                    source: tracksInPlaylist.backButtonPath
                }
            }
            onClicked: backButtonAction()
        }

        Item {
            width: playlistTitle.width - backButton.width
            height: playlistTitle.height
            anchors {
                top: parent.top
                left: backButton.right
                bottom: parent.bottom
                leftMargin: 3 * tracksInPlaylist.margins
            }
            Text {
                verticalAlignment: Qt.AlignVCenter
                anchors.fill: parent

                text: tracksInPlaylist.title
                color: tracksInPlaylist.foregroundColor
                font.pointSize: 8 * QmlAdapter.scalefactor
            }
        }
        Separator {
            anchors.bottom: parent.bottom
            height: QmlAdapter.scalefactor
        }
    }

    TracksPage {
        id: tracksPage
        width: tracksInPlaylist.width
        height: tracksInPlaylist.height - playlistTitle.height

        anchors {
            top: playlistTitle.bottom
        }

        backgroundColor: tracksInPlaylist.backgroundColor
        foregroundColor: tracksInPlaylist.foregroundColor
        settingsIconPath: tracksInPlaylist.settingsIconPath
        settingsButtonAction: function(index, modelData) {
            tracksInPlaylist.settingsButtonAction(index, modelData);
        }
        tracksModel: {}
        itemsOnPage: tracksInPlaylist.itemsOnPage

        playSound: function(index){ tracksInPlaylist.playSound(index); }
    }
}
