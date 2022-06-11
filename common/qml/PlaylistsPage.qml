import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    id: playlistsPage
    width: parent.width
    height: parent.height

    property string backgroundColor       : ""
    property string foregroundColor       : ""
    property string settingsIconPath      : ""
    property int    itemsOnPage           : 10
    property alias  playlistsModel        : playlistsMenu.model
    property var    onPlaylistClickedAction : function(playlistModel) {}
    property bool   isShowSettings        : true

    signal playlistOpen(var data)

    Menue {
        id: playlistsMenu
        anchors {
            fill: parent
        }
        background: backgroundColor

        delegate: Button {
            width: playlistsMenu.width
            height: playlistsMenu.height / playlistsPage.itemsOnPage

            Playlist {
                anchors.fill: parent
                color: backgroundColor
                textColor: foregroundColor
                title: model.title
                tracksCount: model.count
                playlistIcon: model.playlistIcon
                settingsIcon: settingsIconPath
                isShowSettings: playlistsPage.isShowSettings
            }
            Separator {
                anchors.bottom: parent.bottom
                height: QmlAdapter.scalefactor
            }
            onClicked: onPlaylistClickedAction(model.title, index)
        }
    }
}
