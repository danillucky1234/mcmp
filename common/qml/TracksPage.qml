import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    id: page
    width: parent.width
    height: parent.height

    property string backgroundColor     : ""
    property string foregroundColor     : ""
    property string settingsIconPath    : ""
    property int    itemsOnPage         : 10
    property alias  tracksModel         : tracksMenu.model
    property var    settingsButtonAction: function() {}
    property var    playSound           : function(path) {}

    signal settingsButtonClicked(var data);

    Menue {
        id: tracksMenu
        anchors {
            fill: parent
        }
        background: backgroundColor

        delegate: Button {
            width: tracksMenu.width
            height: tracksMenu.height / page.itemsOnPage

            Item {
                anchors.fill: parent

                Track {
                    anchors.fill: parent
                    color: backgroundColor
                    textColor: foregroundColor
                    settingsIcon: page.settingsIconPath
                    settingsButtonAction: function() {
                        page.settingsButtonAction(index, modelData)
                    }
                    path: modelData
                }
                Separator {
                    anchors.bottom: parent.bottom
                    height: QmlAdapter.scalefactor
                }
            }
            onClicked: playSound(index)
        }
    }
}
