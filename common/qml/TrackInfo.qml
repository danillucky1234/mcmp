import QtQuick 2.0
import QtQuick.Controls 2.5
import QtMultimedia 5.9

Rectangle {
    id: trackInfoPage

    property string backgroundColor         	          : QmlAdapter.colors.backgroundLight
    property string foregroundColor         	          : QmlAdapter.colors.foreground
    property string progressActiveColor     	          : QmlAdapter.colors.progressActive
    property string progressBackgroundColor 	          : QmlAdapter.colors.progressBackground

    property string settingsIconPath        	          : QmlAdapter.getImagePath("threeDots.svg")
    property string backButtonPath          	          : QmlAdapter.getImagePath("circle-left.svg")
    property int    imageWidth              	          : 25 * QmlAdapter.scalefactor
    property int    imageHeight             	          : 25 * QmlAdapter.scalefactor
    property int    margins                 	          : QmlAdapter.scalefactor
    property int    textSize                	          : 6 * QmlAdapter.scalefactor

    property bool   isPlaying                             : true
    property int    playbackMode                          : 0
    // Track meta information
    property string title                   	          : ""
    property string author                  	          : ""
    property string image                   	          : ""
    property int    duration                	          : 0
    property int    progress                	          : 0

    property var    backButtonAction        	          : function() {}
    property var    onProgressBarClickedAction            : function(value) {}
    property var    onPrevButtonClickedAction             : function() {}
    property var    onPlayButtonClickedAction             : function() {}
    property var    onNextButtonClickedAction             : function() {}
    property var    onPlaybackModeButtonClickedAction     : function() {}
    property var    onAddToFavoritesButtonClickedAction   : function() {}

    color: trackInfoPage.backgroundColor

    function getTextFromMsec(msec) {
        let utilDate = new Date();
        utilDate.setTime(msec);
        return Qt.formatTime(utilDate, "mm:ss");
    }

    Rectangle {
        id: trackTitle
        width: trackInfoPage.width
        height: trackInfoPage.height * 1/10
        anchors {
            top: trackInfoPage.top
        }
        color: trackInfoPage.backgroundColor

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Do nothing. Handle clicks under component
            }
        }

        Button {
            id: backButton
            width: trackTitle.width * 2/10
            height: trackTitle.height
            anchors {
                top: trackTitle.top
                left: trackTitle.left
                bottom: trackTitle.bottom
            }

            background: Rectangle {
                color: trackInfoPage.backgroundColor
            }

            contentItem: Item {
                anchors.fill: parent
                width: imageWidth
                height: imageHeight

                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: trackInfoPage.imageWidth
                    sourceSize.height: trackInfoPage.imageHeight
                    source: trackInfoPage.backButtonPath
                }
            }
            onClicked: trackInfoPage.backButtonAction()
        }

        Item {
            id: trackTitleItem
            width: trackTitle.width - backButton.width
            height: trackTitle.height / 2
            anchors {
                top: trackTitle.top
                left: backButton.right
            }

            Text {
                anchors {
                    left: trackTitleItem.left
                    leftMargin: margins
                    verticalCenter: trackTitleItem.verticalCenter
                }

                text: trackInfoPage.title
                font.pointSize: trackInfoPage.textSize
                color: trackInfoPage.foregroundColor
            }
        }

        Item {
            id: authorItem
            width: trackTitleItem.width
            height: trackTitleItem.height
            anchors {
                top: trackTitleItem.bottom
                left: backButton.right
                bottom: trackTitle.bottom
            }

            Text {
                anchors {
                    left: authorItem.left
                    leftMargin: margins
                    verticalCenter: authorItem.verticalCenter
                }

                text: trackInfoPage.author
                font.pointSize: textSize
                color: trackInfoPage.foregroundColor
            }
        }
    }

    Rectangle {
        id: trackImage
        width: trackInfoPage.width
        height: trackInfoPage.height * 7/10
        anchors {
            top: trackTitle.bottom
        }
        color: trackInfoPage.backgroundColor
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Do nothing. Handle clicks under component
            }
        }

        Image {
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            sourceSize.width:  10 * trackInfoPage.imageWidth
            sourceSize.height: 10 * trackInfoPage.imageHeight
            source: trackInfoPage.image
        }
    }

    Rectangle {
        id: slider
        width: trackInfoPage.width
        height: trackInfoPage.height * 0.5/10
        anchors {
            top: trackImage.bottom
        }
        color: trackInfoPage.backgroundColor
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Do nothing. Handle clicks under component
            }
        }
        Item {
            id: currentText
            width: slider.width * 1.5/10
            height: slider.height
            anchors {
                top: slider.top
                left: slider.left
                margins: trackInfoPage.margins
            }

            Text {
                anchors.centerIn: currentText
                verticalAlignment: Qt.AlignVCenter
                text: trackInfoPage.getTextFromMsec(trackInfoPage.progress)
                color: trackInfoPage.foregroundColor
            }
        }

        CustomSlider {
            width: slider.width * 7/10
            height: slider.height / 2
            anchors {
                top: slider.top
                left: currentText.right
                right: durationItem.left
                topMargin: (slider.height / 2) - (height / 2)
            }

            from: 0
            to: trackInfoPage.duration
            value: trackInfoPage.progress

            backgroundColor: trackInfoPage.progressBackgroundColor
            foregroundColor: trackInfoPage.progressActiveColor
            cursorColor: trackInfoPage.foregroundColor

            onMoved: trackInfoPage.onProgressBarClickedAction(value)
        }

        Item {
            id: durationItem
            width: slider.width * 1.5/10
            height: slider.height
            anchors {
                top: slider.top
                right: slider.right
                margins: trackInfoPage.margins
            }

            Text {
                anchors.centerIn: durationItem
                verticalAlignment: Qt.AlignVCenter
                text: trackInfoPage.getTextFromMsec(trackInfoPage.duration)
                color: trackInfoPage.foregroundColor
            }
        }
    }

    Rectangle {
        id: trackControllers
        width: trackInfoPage.width
        height: trackInfoPage.height * 1.5/10
        anchors {
            top: slider.bottom
            left: trackInfoPage.left
            right: trackInfoPage.right
            bottom: trackInfoPage.bottom
        }
        color: trackInfoPage.backgroundColor

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Do nothing. Handle clicks under component
            }
        }

        Button {
            id: playbackModeButton
            width: trackControllers.width * 2/10
            height: trackControllers.height
            anchors {
                top: trackControllers.top
                left: trackControllers.left
                bottom: trackControllers.bottom
            }

            property var modes: {
                "CURRENT_ITEM_ONCE"   : Playlist.CurrentItemOnce,
                "CURRENT_ITEM_IN_LOOP": Playlist.CurrentItemInLoop,
                "SEQUENTIAL"          : Playlist.Sequential,
                "LOOP"                : Playlist.Loop,
                "RANDOM"              : Playlist.Random,

                0: "CURRENT_ITEM_ONCE",
                1: "CURRENT_ITEM_IN_LOOP",
                2: "SEQUENTIAL",
                3: "LOOP",
                4: "RANDOM",
            }
            property var allowedModes: [ "CURRENT_ITEM_IN_LOOP", "LOOP", "RANDOM" ]
            property int currentMode : 1
            property var playbackModes: [
                {
                    source: QmlAdapter.getImagePath("repeat_one.svg"),
                    mode:   Playlist.CurrentItemInLoop
                },
                {
                    source: QmlAdapter.getImagePath("repeat.svg"),
                    mode:   Playlist.Loop
                },
                {
                    source: QmlAdapter.getImagePath("shuffle.svg"),
                    mode:   Playlist.Random
                }
            ]

            background: Rectangle {
                color: trackInfoPage.backgroundColor
            }

            contentItem: Item {
                anchors.fill: parent
                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width:  trackInfoPage.imageWidth
                    sourceSize.height: trackInfoPage.imageHeight
                    source: playbackModeButton.playbackModes[playbackModeButton.currentMode].source
                }
            }
            onClicked: function() {
                playbackModeButton.currentMode = ++playbackModeButton.currentMode % playbackModeButton.playbackModes.length;
                trackInfoPage.onPlaybackModeButtonClickedAction(playbackModeButton.playbackModes[playbackModeButton.currentMode].mode);
            }
            Component.onCompleted: {
                let convertedMode = playbackModeButton.allowedModes.indexOf(playbackModeButton.modes[trackInfoPage.playbackMode]);
                if (convertedMode !== -1) {
                    playbackModeButton.currentMode = convertedMode;
                } else {
                    playbackModeButton.visible = false;
                    console.warn("Unexpected playback mode (" + trackInfoPage.playbackMode + ") was received");
                }
            }
        }

        ListView {
            id: buttons
            height: trackControllers.height
            anchors {
                top: trackControllers.top
                left: playbackModeButton.right
                right: addToFavoritesButton.left
                bottom: trackControllers.bottom
            }
            interactive: false
            orientation: Qt.Horizontal

            model: ListModel {
                ListElement {
                    getSource: function() {
                        return QmlAdapter.getImagePath("previous.svg");
                    }
                    action: function() {
                        trackInfoPage.onPrevButtonClickedAction();
                    }
                }

                ListElement {
                    getSource: function() {
                        return trackInfoPage.isPlaying ? QmlAdapter.getImagePath("circle-pause.svg") : QmlAdapter.getImagePath("circle-play.svg");
                    }
                    action: function() {
                        trackInfoPage.onPlayButtonClickedAction();
                    }
                }

                ListElement {
                    getSource: function() {
                        return QmlAdapter.getImagePath("next.svg");
                    }
                    action: function() {
                        trackInfoPage.onNextButtonClickedAction();
                    }
                }
            }

            delegate: Button {
                width: buttons.width / buttons.model.count
                height: trackControllers.height
                background: Rectangle {
                    color: trackInfoPage.backgroundColor
                }
                contentItem: Item {
                    anchors.fill: parent
                    Image {
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width:  trackInfoPage.imageWidth
                        sourceSize.height: trackInfoPage.imageHeight
                        source: model.getSource()
                    }
                }
                onClicked: model.action()
            }
        }
        Button {
            id: addToFavoritesButton
            width: playbackModeButton.width
            height: playbackModeButton.height
            anchors {
                top: trackControllers.top
                right: trackControllers.right
                bottom: trackControllers.bottom
            }
            background: Rectangle {
                color: trackInfoPage.backgroundColor
            }

            contentItem: Item {
                anchors.fill: parent
                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width:  trackInfoPage.imageWidth
                    sourceSize.height: trackInfoPage.imageHeight
                    source: QmlAdapter.getImagePath("heart.svg")
                }
            }
            onClicked: function() {
                trackInfoPage.onAddToFavoritesButtonClickedAction();
            }
        }
    }
}
