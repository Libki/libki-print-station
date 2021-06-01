import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12

import "functions.js" as Functions

import io.qt.libki_jamex.backend 1.0

Window {
    id: mainWindow
    width: 1024
    height: 768
    visible: true
    //visibility: "Maximized"
    title: qsTr("Libki Jamex Payment Processor")
    property var pWindow
    Component.onCompleted: function() {
        pWindow = paymentWindow.createObject(mainWindow);
        conn.target = pWindow;
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("Unable to log in")
        text: ""
        icon: StandardIcon.Warning
        modality: Qt.WindowModal
    }

    BackEnd {
        id: backend
    }

    PaymentWindow {
        id:  paymentWindow
    }

    Row {
        id: loginScreen
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        StackLayout {
            id: stackLayout
            x: 0
            y: 0
            width: parent.width
            height: parent.height
            currentIndex: 0

            Column {
                id: loginForm
                x: 0
                y: 0
                width: parent.width
                height: parent.height

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
                        onEditingFinished: backend.userName = text
                        Keys.onReturnPressed: function() {
                            backend.userName = text
                            textFieldPassword.focus = true
                        }
                    }

                    Label {
                        id: labelPassword
                        text: qsTr("Password:")
                    }

                    TextField {
                        id: textFieldPassword
                        echoMode: TextInput.Password
                        placeholderText: qsTr("Enter password")
                        onEditingFinished: backend.userPassword = text
                        Keys.onReturnPressed: function() {
                            backend.userPassword = text
                            login.clicked()
                        }
                    }

                    Text{}

                    Button {
                        id: login
                        text: qsTr("Log in")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        enabled: textFieldUsername.length && textFieldPassword.length
                        onClicked: function() {
                            var username = backend.userName
                            var password = backend.userPassword
                            var api_key = backend.serverApiKey
                            var server_address = backend.serverAddress
                            var path = '/api/public/authenticate_user/'
                            var url = server_address + path + "?api_key=" + api_key + "&username=" + username + "&password=" + password;
                            console.log("AUTHENTICATION URL: " + url)
                            Functions.request(url, function (o) {
                                // log the json response
                                console.log(o.responseText);
                                // translate response into object
                                var d = eval('new Object(' + o.responseText + ')');

                                if ( d.success ) {
                                    mainWindow.hide();
                                    pWindow.visible = true;
                                    pWindow.show();
                                } else {
                                    if ( d.error === "SIP_ACS_OFFLINE" ) {
                                        messageDialog.text = qsTr("Unable to authenticate. ILS is offline for SIP.");
                                    } else if ( d.error === "SIP_AUTH_FAILURE" ) {
                                        messageDialog.text = qsTr("Unable to authenticate. ILS login for SIP failed.");
                                    } else if ( d.error === "INVALID_API_KEY" ) {
                                        messageDialog.text = qsTr("Unable to authenticate. API key is invalid.");
                                    } else if ( d.error === "FEE_LIMIT" ) {
                                        messageDialog.text("Unable to log in, you own too many fees.");
                                    } else if ( d.error === "INVALID_USER" || d.error == "INVALID_PASSWORD" || d.error == "BAD_LOGIN"){
                                        messageDialog.text = qsTr("Username & password do not match.");
                                    } else {
                                        messageDialog.text = qsTr("Unable to authenticate. Error code: " ) + d.error;
                                    }

                                    textFieldUsername.text = ""
                                    textFieldPassword.text = ""
                                    backend.userName = ""
                                    backend.userPassword = ""

                                    messageDialog.visible = true

                                    textFieldUsername.focus = true
                                }
                            })
                        }
                    }
                }
            }
        }

        Connections {
            id: conn
            function onVisibleChanged() {
                if ( ! pWindow.visible ) {
                    textFieldUsername.text = ""
                    textFieldPassword.text = ""
                    backend.userName = ""
                    backend.userPassword = ""

                    mainWindow.show();
                    //mainWindow.visibility = 'Maximized';
                    textFieldUsername.focus = true
                }
            }
        }
    }
}
