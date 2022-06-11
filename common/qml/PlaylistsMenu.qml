import QtQuick 2.0
import QtQuick.Controls 2.5

Rectangle {
    id: popup
    width: parent.width
    height: parent.height

    property string backgroundColor         : QmlAdapter.colors.backgroundLight
    property string backgroundDarkColor     : QmlAdapter.colors.backgroundDark
    property string foregroundColor         : QmlAdapter.colors.foreground
    property string progressActiveColor     : QmlAdapter.colors.progressActive

    property int    margins                 : 20 * QmlAdapter.scalefactor
    property string settinsIconPath         : QmlAdapter.getImagePath("threeDots.svg")
    property int    itemsOnPage             : 10

    property string headerText              : "Select the playlist you want to add the track to"

    property alias  playlistsModel          : playlistsPage.playlistsModel
    property var    addToPlaylistAction     : function(playlistIndex) {}
    property var    createPlaylistAction    : function() {}

    color: backgroundColor

    Rectangle {
        id: header
        width: popup.width
        height: popup.height / 10
        anchors {
            top: popup.top
            left: popup.left
            right: popup.right
        }
        color: popup.backgroundDarkColor

        Text {
            text: popup.headerText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors {
                fill: header
                margins: popup.margins
            }
            color: popup.foregroundColor
            wrapMode: Text.WordWrap
            font {
                pointSize: 6 * QmlAdapter.scalefactor
            }
        }
        Separator {
            anchors.bottom: header.bottom
        }
    }

    PlaylistsPage {
        id: playlistsPage
        width: popup.width
        height: popup.height * 8/10
        anchors {
            top: header.bottom
        }

        backgroundColor: popup.backgroundColor
        foregroundColor: popup.foregroundColor
        settingsIconPath: popup.settinsIconPath
        itemsOnPage: popup.itemsOnPage
        playlistsModel: popup.playlistsModel
        onPlaylistClickedAction: function(title, playlistIndex) {
            addToPlaylistAction(playlistIndex);
        }
        isShowSettings: false
    }

    Button {
        id: footer
        width: popup.width
        height: popup.height / 10
        anchors {
            top: playlistsPage.bottom
            left: popup.left
            right: popup.right
            bottom: popup.bottom
        }

        background: Rectangle {
            color: popup.backgroundColor
        }
        contentItem: Rectangle {
            color: backgroundDarkColor
            anchors.fill: parent
            Separator {
                anchors.top: parent.top
            }

            Text {
                text: "Create a new playlist"
                color: popup.progressActiveColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
            }
        }

        onClicked: createPlaylistAction()
    }

}
