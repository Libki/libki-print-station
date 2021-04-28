import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

Component {
    id:  popupWindow
    Window {
        title: "Popup window"
        width: 400
        height: 400
        visible: true
        flags: Qt.Dialog
        modality: Qt.ApplicationModal
        Text {
            anchors.centerIn: parent
            text: "Close me to show main window"
        }
    }
}
