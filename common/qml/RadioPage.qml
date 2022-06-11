import QtQuick 2.0
import QtQuick.Controls 2.5
import QtMultimedia 5.9

Rectangle {
    id: radioPage
    width: parent.width
    height: parent.height

    property string backgroundColor          : QmlAdapter.colors.backgroundLight
    property string foregroundColor          : QmlAdapter.colors.foreground
    property string progressBackgroundColor  : QmlAdapter.colors.progressBackground

    property int    margins                  : QmlAdapter.scalefactor
    property int    imageWidth          	 : 25 * QmlAdapter.scalefactor
    property int    imageHeight         	 : 25 * QmlAdapter.scalefactor
    property string backButtonPath           : QmlAdapter.getImagePath("circle-left.svg")
    property string playButtonPath           : QmlAdapter.getImagePath("circle-play.svg")

    property var    backButtonAction         : function() {}

    color: radioPage.backgroundColor

    Rectangle {
        id: header
        width: radioPage.width
        height: radioPage.height * 1/10
        color: radioPage.backgroundColor
        anchors {
            top: radioPage.top
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Button {
            id: backButton
            width: parent.width / 8
            height: parent.height
            anchors {
                top: header.top
                left: header.left
                bottom: header.bottom
            }

            background: Rectangle {
                color: radioPage.backgroundColor
            }

            contentItem: Item {
                anchors.fill: parent
                width: radioPage.imageWidth
                height: radioPage.imageHeight

                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: radioPage.imageWidth
                    sourceSize.height: radioPage.imageHeight
                    source: radioPage.backButtonPath
                }
            }
            onClicked: backButtonAction()
        }

        Item {
            width: header.width - backButton.width
            height: header.height
            anchors {
                top: header.top
                left: backButton.right
                leftMargin: 3 * radioPage.margins
                verticalCenter: header.verticalCenter
            }
            Text {
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter

                text: "Online radio"
                color: radioPage.foregroundColor
                font.pointSize: 8 * QmlAdapter.scalefactor
            }
        }
        Separator {
            anchors.bottom: parent.bottom
            height: QmlAdapter.scalefactor
        }
    }

    MediaPlayer {
        id: player
        audioRole: MediaPlayer.MusicRole
        onError: {
            console.log("Radio media player error: " + errorString);
        }
        signal stateChanged();
        function playPause() {
            let isPlaying = player.playbackState == MediaPlayer.PlayingState;
            if(isPlaying) {
                player.pause();
            } else {
                player.play();
            }
            stateChanged();
        }
    }

    function markColor(text, color) {
        if (!color) color = "#0000ff";
        let result = '<span style="color:%color%">' + text + '</span>';
        return result.replace('%color%', color);
    }

    Rectangle {
        id: body
        width: radioPage.width * 9/10
        height: radioPage.height * 7/10
        anchors {
            top: header.bottom
            horizontalCenter: radioPage.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }
        color: radioPage.backgroundColor

        Rectangle {
            id: radioImage
            width: body.width
            height: body.height * 3/10

            anchors {
                top: body.top
                left: body.left
            }

            color: radioPage.backgroundColor

            Item {
                anchors.fill: radioImage
                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width:  4 * radioPage.imageWidth
                    sourceSize.height: 4 * radioPage.imageHeight
                    source: QmlAdapter.getImagePath("radio.svg")
                }
            }
        }

        GridView {
            id: radioStationButtons
            width: body.width
            height: body.height * 7/10
            anchors {
                top: radioImage.bottom
                left: body.left
                right: body.right
                bottom: body.bottom
            }
            clip: true

            property int currentStationIndex: -1

            model: ListModel {
                ListElement {
                    country: "Germany"
                    station: "Antenne Bayern"
                    source: "https://s3-webradio.antenne.de/antenne/stream/mp3?aw_0_1st.playerid=radio.fm"
                }
                ListElement {
                    country: "USA"
                    station: "Smooth Jazz USA"
                    source: "https://us4.internet-radio.com/proxy/wsjf?mp=/stream"
                }
                ListElement {
                    country: "Bolivia"
                    station: "Black Rabbit"
                    source: "https://streamer.radio.co/sc70f66113/listen"
                }
                ListElement {
                    country: "USA"
                    station: "All Classical Network"
                    source: "https://wpr-ice.streamguys1.com/wpr-hd2-mp3-96"
                }
            }

            cellWidth:  radioStationButtons.width / 4
            cellHeight: radioStationButtons.height / 4
            delegate: Button {
                width: radioStationButtons.cellWidth - 10
                height: radioStationButtons.cellHeight - 10

                background: Rectangle {
                    color: radioPage.progressBackgroundColor
                    border {
                        color: "black"
                    }
                    radius: 20
                }

                contentItem: Item {
                    anchors.fill: parent
                    Text {
                        id: indicator
                        height: parent.height
                        anchors {
                            top: parent.top
                            left: parent.left
                        }
                        verticalAlignment: Qt.AlignVCenter

                        text: "•"
                        color: "green"
                        visible: radioStationButtons.currentStationIndex === index
                        font.pointSize: 20 * radioPage.margins
                    }

                    Text {
                        width: parent.width * 9/10
                        height: parent.height
                        anchors {
                            top: parent.top
                            left: indicator.right
                            right: parent.right
                            rightMargin: 3 * radioPage.margins
                        }
                        verticalAlignment: Qt.AlignVCenter

                        text: model.station + "\n" + markColor(model.country)
                        textFormat: Text.RichText
                        wrapMode: Text.WordWrap
                        font.pointSize: 4.5 * radioPage.margins
                    }
                    Separator {
                        anchors.bottom: parent.bottom
                    }
                }
                onClicked: {
                    console.log("Button " + index + " was clicked!");
                    console.log("model.source: " + model.source);
                    player.source = model.source;
                    radioStationButtons.currentStationIndex = index;
                    player.playPause();
                }
            }
        }
    }

    Rectangle {
        id: footer
        width: radioPage.width
        height: radioPage.height * 2/10
        anchors {
            top: body.bottom
            bottom: radioPage.bottom
            left: radioPage.left
            right: radioPage.right
        }

        color: radioPage.backgroundColor

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Button {
            id: playButton
            width: footer.width / 3
            height: footer.height
            visible: radioStationButtons.currentStationIndex !== -1
            anchors {
                horizontalCenter: footer.horizontalCenter
                top: footer.top
                bottom: footer.bottom
            }

            background: Rectangle {
                color: radioPage.backgroundColor
            }

            contentItem: Item {
                anchors.fill: parent
                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width:  3 * radioPage.imageWidth
                    sourceSize.height: 3 * radioPage.imageHeight
                    source: radioPage.playButtonPath
                }
            }
            onClicked: {
                console.log("playpause was clicked");
                player.playPause();
            }

            Connections {
                target: player

                function onStateChanged() {
                    if (player.playbackState == MediaPlayer.PlayingState) {
                        radioPage.playButtonPath = QmlAdapter.getImagePath("circle-pause.svg");
                    } else {
                        radioPage.playButtonPath = QmlAdapter.getImagePath("circle-play.svg");
                    }
                }
            }
        }
    }
}
