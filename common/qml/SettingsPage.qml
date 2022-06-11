import QtQuick 2.0
import QtQuick.Controls 2.5

Rectangle {
    id: settings
    width: parent.width
    height: parent.height

    property string backgroundColor        : QmlAdapter.colors.backgroundLight
    property string foregroundColor        : QmlAdapter.colors.foreground

    property int    imageWidth             : 18 * QmlAdapter.scalefactor
    property int    imageHeight            : 18 * QmlAdapter.scalefactor
    property int    margins                : 5 * QmlAdapter.scalefactor

    property var    onThemeChanged         : function() {}
    property var    onBackButtonClicked    : function() {}
    property var    onSendBugReportClicked : function() {}

    color: settings.backgroundColor

    Menue {
        id: settingsMenu
        width: settings.width * 7 / 10
        height: settings.height
        anchors {
            centerIn: settings
        }

        property int items: 10

        background: settings.backgroundColor

        model: ListModel {
            ListElement {
                text: "Change theme"
                getSource: function() {return QmlAdapter.getImagePath("brush.svg");}
                action: function() { settings.onThemeChanged(); }
            }
            ListElement {
                text: "Send bug report"
                getSource: function() {return QmlAdapter.getImagePath("send.svg");}
                action: function() {settings.onSendBugReportClicked();}
            }
            ListElement {
                text: "Back"
                getSource: function() {return QmlAdapter.getImagePath("circle-left.svg");}
                action: function() { settings.onBackButtonClicked(); }
            }
        }

        delegate: Button {
            width: settingsMenu.width
            height: settingsMenu.height / settingsMenu.items

            background: Rectangle {
                color: settings.backgroundColor
            }

            contentItem: Rectangle {
                anchors.fill: parent
                color: settings.backgroundColor

                Item {
                    id: image
                    width: parent.width * 2/10
                    height: parent.height
                    anchors {
                        top: parent.top
                        left: parent.left
                    }

                    Image {
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width:  settings.imageWidth
                        sourceSize.height: settings.imageHeight
                        source: model.getSource()
                    }
                }

                Item {
                    id: caption
                    width: parent.width * 8/10
                    height: parent.height
                    anchors {
                        top: parent.top
                        left: image.right
                        right: parent.right
                        rightMargin: settings.margins

                        bottom: parent.bottom
                    }

                    Text {
                        anchors {
                            fill: parent
                        }
                        verticalAlignment: Qt.AlignVCenter
                        text: model.text
                        color: settings.foregroundColor
                        font.pointSize: 6 * QmlAdapter.scalefactor
                    }
                }
                Separator {
                    anchors.bottom: parent.bottom
                }
            }

            onClicked: model.action()
        }
    }
}
