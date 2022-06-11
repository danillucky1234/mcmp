import QtQuick 2.0
import QtQuick.Controls 2.12
import 'qrc:/' as Custom

Item {
    property string titleText           : ""
    property string backgroundColor     : ""
    property string foregroundColor     : ""
    property string separatorColor      : ""

    property int    textSize            : 6 * QmlAdapter.scalefactor
    property bool   isActive            : false
    property var    onClickAction       : function(){}

    Button {
        id: tabButton
        width: parent.width
        height: parent.height
        anchors.fill: parent

        background: Rectangle {
            color: backgroundColor
        }

        contentItem: Item {
            anchors.fill: parent
            Text {
                anchors.centerIn: parent
                text: titleText
                color: foregroundColor
                font.pointSize: textSize
            }
        }
        onClicked: {
            onClickAction();
        }
    }
    Custom.Separator {
        anchors.bottom: parent.bottom
        color: separatorColor
        visible: isActive
    }
}
