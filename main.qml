import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

import io.qt.libki_jamex.backend 1.0

Window {
    id: mainWindow
    width: 1024
    height: 768
    visible: true
    visibility: "Maximized"
    title: qsTr("Libki Jamex Payment Processor")

    BackEnd {
        id: backend
    }

    PaymentWindow {
        id:  popupWindow
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
                    }

                    Text{}

                    Button {
                        id: login
                        text: qsTr("Log in")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        enabled: textFieldUsername.length && textFieldPassword.length
                        onClicked: {
                            var username = backend.userName
                            var password = backend.userPassword
                            var api_key = backend.serverApiKey
                            var server_address = backend.serverAddress
                            var path = '/api/public/authenticate/'
                            var url = server_address + path + api_key + "?username=" + username + "&password=" + password;
                            console.log("AUTHENTICATION URL: " + url)
                            request(url, function (o) {
                                //TODO: HANDLE BAD LOGINS/BAD API KEYS
                                //TODO: HANDLE LOGIN SUCCESS

                                // log the json response
                                console.log(o.responseText);

                                // translate response into object
                                var d = eval('new Object(' + o.responseText + ')');
                            })

                            //var window = popupWindow.createObject(mainWindow);
                            //mainWindow.hide();
                            //conn.target = window;
                        }
                    }
                }
            }
        }

        Connections {
            id: conn
            onVisibleChanged: {
                mainWindow.show();
                mainWindow.visibility = 'Maximized';
            }
        }
    }

    function request(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                if ( myxhr.readyState === 4 ) callback(myxhr)
            }
        })(xhr);
        xhr.open('GET', url, true);
        xhr.send('');
    }
}
