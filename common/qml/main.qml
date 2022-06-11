import QtQuick 2.0
import QtQuick.Controls 2.15

ApplicationWindow {
    id: mainroot
    width: 640
    height: 480
    visible: true

    MusicPlayer {
        width: mainroot.width
        height: mainroot.height
    }
}
