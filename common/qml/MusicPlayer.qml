import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQml.Models 2.15
import QtMultimedia 5.9

Rectangle {
    id: mainroot

    property bool isFirstTheme: true
    property string trackPath: ""
    property int playlistIndex

    Header {
        id: header
        width: mainroot.width
        height: mainroot.height / 18
        title: "aMusicPlayer"
        menuIcon: QmlAdapter.getImagePath("menu.svg")
        backgroundColor: QmlAdapter.colors.backgroundDark
        foregroundColor: QmlAdapter.colors.foreground
        menuButtonAction: function() {
            if (side.sourceComponent) {
                side.sourceComponent = undefined;
            } else {
                side.sourceComponent = sideMenuComponent;
            }
        }
        Separator {
            id: headerSeparator
            anchors.bottom: header.bottom
        }
    }

    Tabs {
        id: tabsHeader
        width: parent.width
        height: header.height
        anchors {
            top: header.bottom
        }

        background: QmlAdapter.colors.backgroundDark
        foreground: QmlAdapter.colors.foreground
        activeBackground: QmlAdapter.colors.backgroundLight
        activeForeground: QmlAdapter.colors.foreground
        separatorColor: "#FFED75"

        currentIndex: swipeView.currentIndex
        model: ListModel {
            ListElement {
                text: "Tracks"
                onClickAction: function() {
                    isActive = true;
                }
            }
            ListElement {
                text: "Playlists"
                onClickAction: function() {
                    isActive = true;
                }
            }
        }
        Separator {
            id: tabSeparator
            anchors.bottom: tabsHeader.bottom
        }
    }

    Playlist {
        id: playlist
        playbackMode: Playlist.Loop
        property string currentPlaylistName: ""
        function refillPlaylist(tracks) {
            playlist.clear();
            for (let track of tracks) {
                playlist.addItem(track);
            }
        }

        onError: {
            console.log("Playlist error: " + errorString);
        }
    }

    MediaPlayer {
        id: player
        audioRole: MediaPlayer.MusicRole
        notifyInterval: 50 // Smooth progress change
        playlist: playlist

        onError: {
            console.log("MediaPlayer error: " + errorString);
        }
        signal stateChanged();
        function playPause(index) {
            if (player.playlist.currentIndex !== index) {
                // Click on another track
                player.playlist.currentIndex = index;
                player.play();
            } else {
                // Click on the same track
                let isPlaying = player.playbackState == MediaPlayer.PlayingState;
                if(isPlaying) {
                    player.pause();
                } else {
                    player.play();
                }
            }
            stateChanged();
        }
    }

    SwipeView {
        id: swipeView
        currentIndex: tabsHeader.currentIndex ? tabsHeader.currentIndex : 0
        width: parent.width
        height: {
            let true_height = parent.height - tabsHeader.height - header.height;
            return bottomController.visible ? true_height - bottomController.height : true_height;
        }
        anchors {
            top: tabsHeader.bottom
        }

        Item {
            TracksPage {
                id: tracksPage
                backgroundColor: QmlAdapter.colors.backgroundLight
                foregroundColor: QmlAdapter.colors.foreground
                settingsIconPath: QmlAdapter.getImagePath("threeDots.svg")
                settingsButtonAction: function(trackId, path) {
                    console.log("index of the track: " + trackId);
                    console.log("path  to the track: " + path);
                    popup.sourceComponent = trackSettingsPopupComponent;
                    settingsButtonClicked({"trackId": trackId, "trackPath": path}); // Memorize the trackId so that it can be easily deleted later
                }

                tracksModel: TracksModel
                itemsOnPage: bottomController.visible ? 9 : 10
                playSound: function(index) {
                    const playlistName = "ALL_TRACKS";
                    if(player.playlist.currentPlaylistName !== playlistName) {
                        // Reset the playlist
                        console.log("playlist changed to " + playlistName);
                        player.playlist.currentPlaylistName = playlistName;
                        playlist.refillPlaylist(TracksModel.getTracks());
                    }

                    player.playPause(index);
                }
            }
        }

        Item {
            PlaylistsPage {
                id: playlistsPage
                backgroundColor: QmlAdapter.colors.backgroundLight
                foregroundColor: QmlAdapter.colors.foreground
                settingsIconPath: QmlAdapter.getImagePath("threeDots.svg")
                itemsOnPage: bottomController.visible ? 9 : 10
                playlistsModel: PlaylistsModel
                onPlaylistClickedAction: function(title, playlistIndex) {
                    mainroot.playlistIndex = playlistIndex;
                    let sqlitePlaylistIndex = playlistIndex + 1; // Increment playlistIndex because in database id of playlists starts from 1
                    let query = "SELECT path FROM Tracks WHERE playlistId = " + sqlitePlaylistIndex;
                    let tracksInPlaylist = QmlAdapter.executeQuery(query);

                    let tracksModel = [];
                    for (let track of tracksInPlaylist) {
                        tracksModel.push(track["path"]);
                    }
                    // Fill Playlist model
                    PlaylistsModel.setTracksByIndex(tracksModel, playlistIndex);

                    mainScreen.sourceComponent = tracksInPlaylistComponent;
                    playlistOpen({"playlistIndex": playlistIndex}); // Emit signal
                }
            }
        }
        onCurrentIndexChanged: {
            tabsHeader.currentIndex = currentIndex;
        }
    }

    Loader {
        id: background
        width: mainroot.width
        height: mainroot.height
        x: 0
        y: 0
        z: 1

        Rectangle {
            id: bodyHover
            anchors.fill: parent
            opacity: 0.2
            color: "#778899"
            visible: false
            z: 1
            MouseArea{
                id: bodyHoverMouseArea
                anchors.fill: parent
                onClicked: { }
            }
        }
    }

    Loader {
        id: mainScreen
        anchors {
            top: header.bottom
        }
    }

    Loader {
        id: popup
        anchors.centerIn: parent
        z: 1

        onSourceChanged: {
            bodyHover.visible = status === Loader.Ready
        }
        onStatusChanged: {
            bodyHover.visible = !!source && status === Loader.Ready
        }
    }

    Loader {
        id: side
        z: 1
        onSourceChanged: {
            bodyHover.visible = status === Loader.Ready
        }
        onStatusChanged: {
            bodyHover.visible = !!source && status === Loader.Ready
        }
    }

    function hidePopup() {
       // Hide popup and background
       bodyHover.visible = false;
       popup.sourceComponent = undefined;
    }

    function hideSidePanel() {
        bodyHover.visible = false;
        side.sourceComponent = undefined;
    }

    Component {
        id: sideMenuComponent
        SideMenu {
            width: mainroot.width / 2.5
            height: mainroot.height
            anchors {
                top: mainroot.top
                left: mainroot.left
                bottom: mainroot.bottom
            }
            onRadioClicked: function() {
                console.log("radio button was clicked");
                player.stop();
                mainScreen.sourceComponent = radioPageComponent;
                hideSidePanel();
            }
            onSettingsClicked: function() {
                console.log("settings button was clicked");
                mainScreen.sourceComponent = settingsComponent;
                hideSidePanel();
            }

            Connections {
                target: bodyHoverMouseArea
                function onClicked() {
                    hideSidePanel();
                }
            }
        }
    }

    Component {
        id: createPlaylistPopupComponent
        CreatePlaylist {
            id: createPlaylist
            width: mainroot.width / 1.5
            height: mainroot.height / 2.5

            onSubmitButtonAction: function(imageSource, title) {
                let fullImagePath = QmlAdapter.getImagePath(QmlAdapter.getBaseNameFromPath(imageSource) + ".svg");
                let base64Icon = QmlAdapter.getBase64FromImage(fullImagePath);
                let getCountOfPlaylists = function() {
                    let getPlaylistCountQuery = "SELECT COUNT(1) as count FROM Playlists;";
                    let result = QmlAdapter.executeQuery(getPlaylistCountQuery);
                    return result[0].count;
                };
                let countOfPlaylists_1 = getCountOfPlaylists();
                QmlAdapter.addNewPlaylistToDatabase([title, base64Icon]);
                let countOfPlaylists_2 = getCountOfPlaylists();
                if (countOfPlaylists_2 > countOfPlaylists_1) {
                    QmlAdapter.addNewTrackToPlaylist([mainroot.trackPath, countOfPlaylists_2 - 1]); // Add track to new playlist
                }
                PlaylistsModel.modelReset(); // Update model
                hidePopup();
            }

            Connections {
                target: bodyHoverMouseArea
                function onClicked() { hidePopup(); }
            }
        }
    }

    Component {
        id: playlistsPopupComponent
        PlaylistsMenu {
            id: playlistsMenu
            width: mainroot.width / 1.5
            height: mainroot.height / 1.5

            playlistsModel: PlaylistsModel
            addToPlaylistAction: function(playlistIndex) {
                QmlAdapter.addNewTrackToPlaylist([mainroot.trackPath, playlistIndex]);
                PlaylistsModel.modelReset(); // Update model
                hidePopup();
            }
            itemsOnPage: 6
            createPlaylistAction: function() {
                popup.sourceComponent = createPlaylistPopupComponent;
            }

            Connections {
                target: bodyHoverMouseArea
                function onClicked() { hidePopup(); }
            }
        }
    }

    Component {
        id: trackSettingsPopupComponent
        TrackSettings {
            id: popupTrack
            width: mainroot.width / 2
            height: mainroot.height / 3

            property int 	trackId   : 0
            property string trackPath : ""
            model: ListModel {
                ListElement {
                    text: "Add to playlist"
                    getSource: function() {return QmlAdapter.getImagePath("square-plus.svg");}
                    action: function() {
                        popup.sourceComponent = playlistsPopupComponent;
                        mainroot.trackPath = popupTrack.trackPath;
                    }
                }
                ListElement {
                    text: "Save to favorites"
                    getSource: function() {return QmlAdapter.getImagePath("star.svg");}
                    action: function() {
                        QmlAdapter.addNewTrackToPlaylist([popupTrack.trackPath, 0]); // 0 - index of the "Favorites" playlist
                        PlaylistsModel.modelReset(); // Update model
                        hidePopup();
                    }
                }
            }

            Connections {
                target: bodyHoverMouseArea
                function onClicked() { hidePopup(); }
            }

            Connections {
                target: tracksPage
                function onSettingsButtonClicked(data) {
                    popupTrack.trackId = data.trackId;
                    popupTrack.trackPath = data.trackPath;
                }
            }
        }
    }

    Component {
        id: tracksInPlaylistComponent
        TracksInPlaylist {
            id: tracksInPlaylist
            width: mainroot.width
            height: swipeView.height + header.height
            titleHeight: tabsHeader.height
            property int playlistIndex

            title: PlaylistsModel.getTitle(tracksInPlaylist.playlistIndex)
            tracksModel: PlaylistsModel.getTracks(tracksInPlaylist.playlistIndex)
            settingsIconPath: QmlAdapter.getImagePath("threeDots.svg")
            itemsOnPage: bottomController.visible ? 9 : 10
            playSound: function(index) {
                const playlistName = tracksInPlaylist.title;
                if(player.playlist.currentPlaylistName !== playlistName) {
                    // Playlist reset
                    console.log("playlist changed to " + playlistName);
                    player.playlist.currentPlaylistName = playlistName;
                    player.playlist.refillPlaylist(tracksModel);
                }
                player.playPause(index);
            }
            backButtonAction: function() {
                mainScreen.sourceComponent = undefined;
            }

            settingsButtonAction: function(trackId, path) {
                mainroot.trackPath = path;
                popup.sourceComponent = trackInPlaylistSettingsComponent;
            }

            Connections {
                target: playlistsPage
                function onPlaylistOpen(data) {
                    tracksInPlaylist.playlistIndex = data.playlistIndex;
                }
            }
        }
    }

    Component {
        id: trackInPlaylistSettingsComponent
        TrackSettings {
            id: popupTrack
            width: mainroot.width / 2
            height: mainroot.height / 2

            property int 	trackId   : 0
            property string trackPath : ""
            model: ListModel {
                ListElement {
                    text: "Delete track from playlist"
                    getSource: function() {return QmlAdapter.getImagePath("trash-can.svg");}
                    action: function() {
                        QmlAdapter.deleteTrackFromPlaylist([mainroot.trackPath, mainroot.playlistIndex]);
                        PlaylistsModel.modelReset();
                        hidePopup();
                        mainScreen.sourceComponent = undefined; // Close tracks in playlist window
                    }
                }
                ListElement {
                    text: "Add to playlist"
                    getSource: function() {return QmlAdapter.getImagePath("square-plus.svg");}
                    action: function() {
                        popup.sourceComponent = playlistsPopupComponent;
                    }
                }
                ListElement {
                    text: "Save to favorites"
                    getSource: function() {return QmlAdapter.getImagePath("star.svg");}
                    action: function() {
                        QmlAdapter.addNewTrackToPlaylist([mainroot.trackPath, 0]); // 0 - index of the "Favorites" playlist
                        PlaylistsModel.modelReset(); // Update model
                        hidePopup();
                    }
                }
            }

            Connections {
                target: bodyHoverMouseArea
                function onClicked() { hidePopup(); }
            }
        }
    }

    Component {
        id: settingsComponent
        SettingsPage {
            width: mainroot.width
            height: swipeView.height + header.height

            onThemeChanged: function(){mainroot.changeTheme();}
            onBackButtonClicked: function() {
                mainScreen.sourceComponent = undefined;
            }
            onSendBugReportClicked: function() {
                QmlAdapter.sendBugReport();
            }
        }
    }

    Component {
        id: trackInfoComponent
        TrackInfo {
            id: trackInfo
            width: mainroot.width
            height: swipeView.height + header.height
            backButtonAction: function() {
                mainScreen.sourceComponent = undefined;
            }
            isPlaying: player.playbackState == MediaPlayer.PlayingState
            playbackMode: player.playlist.playbackMode
            onProgressBarClickedAction: (progress) => { player.seek(progress); }
            onPrevButtonClickedAction: function() {
                player.seek(player.position - 10000); // -10s
            }
            onPlayButtonClickedAction: function() {
                player.playPause(player.playlist.currentIndex);
                trackInfo.isPlaying = (player.playbackState == MediaPlayer.PlayingState);
            }
            onNextButtonClickedAction: function() {
                player.seek(player.position + 10000); // +10s
            }
            onPlaybackModeButtonClickedAction: function(mode) {
                console.log("new playbackMode: " + mode);
                player.playlist.playbackMode = mode;
            }
            onAddToFavoritesButtonClickedAction: function() {
                QmlAdapter.addNewTrackToPlaylist([player.playlist.currentItemSource, 0]);
                PlaylistsModel.modelReset(); // Update model
            }

            progress: player.position
            duration: player.duration
            title: player.metaData.title || QmlAdapter.getBaseNameFromPath(player.playlist.currentItemSource) || QmlAdapter.unknownTitle
            author: player.metaData.author || player.metaData.albumArtist || player.metaData.composer || player.metaData.contributingArtist || QmlAdapter.unknownAuthor
            image: player.metaData.coverArtUrlLarge || player.metaData.coverArtUrlLarge || QmlAdapter.getImagePath("icon.png")

            Connections {
                target: player.metaData
                function onMetaDataChanged() {
                    trackInfo.title = player.metaData.title || QmlAdapter.getBaseNameFromPath(player.playlist.currentItemSource) || QmlAdapter.unknownTitle;
                    trackInfo.author = player.metaData.albumArtist || player.metaData.contributingArtist || QmlAdapter.unknownAuthor;
                    player.stateChanged(); // Refresh trackInfo image
                    console.log("metadata of the current track:\n" + JSON.stringify(player.metaData));
                }
            }

            Connections {
                target: player
                function onStatusChanged() {
                    if (player.status == MediaPlayer.EndOfMedia) {
                        trackInfo.isPlaying = false;
                    }
                }
                function onStateChanged() {
                    trackInfo.isPlaying = (player.playbackState == MediaPlayer.PlayingState);
                }
            }
        }
    }

    Component {
        id: radioPageComponent
        RadioPage {
            id: radioPage
            width: mainroot.width
            height: swipeView.height + header.height

            backButtonAction: function() {
                mainScreen.sourceComponent = undefined;
            }
        }
    }

    TrackController {
        id: bottomController
        width: parent.width
        height: parent.height / 10
        anchors.bottom: parent.bottom;
        visible: player.playbackState !== MediaPlayer.StoppedState && mainScreen.sourceComponent != trackInfoComponent

        trackName: player.metaData.title || QmlAdapter.unknownTitle
        author: player.metaData.author || player.metaData.albumArtist || player.metaData.composer || QmlAdapter.unknownAuthor
        color: QmlAdapter.colors.backgroundDark
        textColor: QmlAdapter.colors.foreground
        progressActiveColor: QmlAdapter.colors.progressActive
        progressBackgroundColor: QmlAdapter.colors.progressBackground
        playButtonSource: QmlAdapter.getImagePath("circle-pause.svg")
        progress: player.position
        duration: player.duration
        onPlayButtonClickedAction: function() { player.playPause(player.playlist.currentIndex); }
        onProgressBarClickedAction: (progress) => { player.seek(progress); }
        onClicked: {
            mainScreen.sourceComponent = trackInfoComponent;
        }
        Connections {
            target: player.metaData
            function onMetaDataChanged() {
                bottomController.trackName = player.metaData.title || QmlAdapter.getBaseNameFromPath(player.playlist.currentItemSource) || QmlAdapter.unknownTitle;
                bottomController.author = player.metaData.albumArtist || player.metaData.contributingArtist || QmlAdapter.unknownAuthor;
                player.stateChanged(); // Refresh bottomController image
                console.log("metadata of the current track:\n" + JSON.stringify(player.metaData));
            }
        }

        Connections {
            target: player

            function onStatusChanged() {
                if (player.status == MediaPlayer.EndOfMedia) {
                    console.log("end of the media signal was handled");
                    bottomController.playButtonSource = QmlAdapter.getImagePath("circle-play.svg");
                }
            }
            function onStateChanged() {
                if (player.playbackState == MediaPlayer.PlayingState) {
                    bottomController.playButtonSource = QmlAdapter.getImagePath("circle-pause.svg");
                } else {
                    bottomController.playButtonSource = QmlAdapter.getImagePath("circle-play.svg");
                }
            }
        }
    }

    function changeTheme() {
        isFirstTheme = !isFirstTheme;
        let theme = isFirstTheme ? "default.json" : "dracula.json";
        QmlAdapter.setTheme(theme);
    }
}
