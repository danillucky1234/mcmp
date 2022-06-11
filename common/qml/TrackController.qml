import QtQuick 2.0
import QtQuick.Controls 2.0

Button {
    id: trackController
    width: parent.width
    height: parent.height

    property string color                   : ""
    property string trackName               : ""
    property string author                  : ""
    property string textColor               : ""
    property string progressActiveColor     : ""
    property string progressBackgroundColor : ""
    property string playButtonSource        : ""
    property int    progress                : 0
    property int    duration                : 0

    property var    onPlayButtonClickedAction   : function() {}
    property var    onProgressBarClickedAction  : function() {}

    property int    imageWidth          : 30 * QmlAdapter.scalefactor
    property int    imageHeight         : 30 * QmlAdapter.scalefactor
    property int    textSize            : 5 * QmlAdapter.scalefactor
    property int    margins             : 8 * QmlAdapter.scalefactor

    background: Rectangle {
        color: trackController.color
    }

    CustomSlider {
        id: progressBackground
        width: parent.width
        height: parent.height / 8

        from: 0
        to: duration
        value: progress

        backgroundColor: progressBackgroundColor
        foregroundColor: progressActiveColor
        cursorColor: textColor

        onMoved: onProgressBarClickedAction(value)
    }

   Button {
       id: playButton
       width: trackController.width / 10
       height: trackController.height - progressBackground.height
       anchors {
           top: progress.bottom
           left: trackController.left
           bottom: trackController.bottom
           leftMargin: margins
       }

       background: Rectangle {
           color: trackController.color
       }

       contentItem: Item {
           anchors.fill: parent
           width: imageWidth
           height: imageHeight
           Image {
               id: playButtonImage
               anchors.centerIn: parent

               fillMode: Image.PreserveAspectFit
               sourceSize.width: imageWidth
               sourceSize.height: imageHeight
               source: playButtonSource
           }
       }
       onClicked: onPlayButtonClickedAction()
   }


   Item {
       id: trackTitleItem
       width: trackController.width - playButton.width
       height: (trackController.height - progressBackground.height) / 2
       anchors {
           top: progressBackground.bottom
           left: playButton.right
       }

       Text {
           anchors {
               left: parent.left
               leftMargin: margins
               verticalCenter: parent.verticalCenter
           }

           text: trackName
           font.pointSize: textSize
           color: textColor
       }
   }

   Item {
       id: authorItem
       width: trackTitleItem.width
       height: trackTitleItem.height
       anchors {
           top: trackTitleItem.bottom
           left: playButton.right
           bottom: trackController.bottom
       }

       Text {
           anchors {
               left: parent.left
               leftMargin: margins
               verticalCenter: parent.verticalCenter
           }

           text: author
           font.pointSize: textSize
           color: textColor
       }
   }
}
