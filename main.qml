import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

Window {
    width: 1024
    height: 768
    visible: true
    title: qsTr("Hello World")

    Row {
        id: row
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        Column {
            id: column
            x: 0
            y: 0
            width: parent.width
            height: parent.height
            anchors.top: parent.top
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            BorderImage {
                anchors.top: parent.top
                anchors.topMargin: parent.height / 5
                id: libkiLogo
                source: "libki.png"
                border.bottom: 0
                border.top: 0
                anchors.horizontalCenter: parent.horizontalCenter
            }

            GridLayout {
                id: usernamePasswordGrid
                rows: 3
                columns: 2
                anchors.top: libkiLogo.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Label {
                    id: labelUsername
                    text: qsTr("Username:")
                }

                TextField {
                    id: textFieldUsername
                    focus: true
                    placeholderText: qsTr("Enter username")
                }

                Label {
                    id: labelPassword
                    text: qsTr("Password:")
                }

                TextField {
                    id: textFieldPassword
                    echoMode: TextInput.Password
                    placeholderText: qsTr("Enter password")
                }

                Text{}

                Button {
                    id: login
                    text: qsTr("Log in")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    enabled: textFieldUsername.length && textFieldPassword.length
                }
            }
        }
    }
}
