import QtQuick 2.0
import QtQuick.Controls 2.5

Rectangle {
    id: trackSettings
    width: parent.width
    height: parent.height

    property string backgroundColor  : QmlAdapter.colors.backgroundLight
    property string foregroundColor  : QmlAdapter.colors.foreground

    property int    margins          : 10 * QmlAdapter.scalefactor
    property int    imageWidth       : 30 * QmlAdapter.scalefactor
    property int    imageHeight      : 30 * QmlAdapter.scalefactor

    property alias  model            : trackSettingsMenu.model

    Menue {
        id: trackSettingsMenu
        anchors.fill: parent

        background: trackSettings.backgroundColor

        model: trackSettings.model

        delegate: Button {
            width: trackSettingsMenu.width
            height: trackSettingsMenu.height / trackSettings.model.count

            background: Rectangle {
                color: trackSettings.backgroundColor
            }

            contentItem: Item {
                anchors.fill: parent
                Item {
                    width: parent.width * 7/10
                    height: parent.height
                    anchors {
                        left: parent.left
                        leftMargin: margins
                        verticalCenter: parent.verticalCenter
                    }
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Qt.AlignVCenter
                        wrapMode: Text.WordWrap
                        color: trackSettings.foregroundColor
                        text: model.text
                    }
                }
                Item {
                    width: parent.width * 3/10
                    height: parent.height
                    anchors.right: parent.right
                    Image {
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: imageWidth
                        sourceSize.height: imageHeight
                        source: model.getSource()
                    }
                }
                Separator {
                    height: parent.height / 95
                    anchors.bottom: parent.bottom
                    visible: index !== (trackSettings.model.count - 1)
                }
            }
            onClicked: model.action()
        }
    }
}
