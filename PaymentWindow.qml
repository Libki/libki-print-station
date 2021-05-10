import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

import io.qt.libki_jamex.backend 1.0

Component {
    id:  paymentWindow
    Window {
        title: qsTr("Libki Jamex Payment Processor")
        width: 400
        height: 400
        visible: true
        modality: Qt.ApplicationModal

        Text {
            anchors.centerIn: parent
            text: "Close me to show main window"
        }

        onVisibilityChanged: function(){
            console.log("USERNAME: " + backend.userName);
        }

        BackEnd {
            id: backend
        }
    }
}
