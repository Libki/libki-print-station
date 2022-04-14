import Qt.labs.platform

import QtQuick 2.12
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls 2.5 as MyControls
import QtQuick.Controls
import QtQuick.Layouts 1.12
import QtQuick.Dialogs
import QtQuick.Window 2.15

import "functions.js" as Functions

import io.qt.libki_jamex.backend 1.0

Window {
    id: mainWindow
    width: 1000
    height: 800
    visible: true
    visibility: backend.mainWindowVisibility
    title: qsTr("Libki Print Station")
    onClosing: function (close) {
        if (backend.appPreventExit == "yes") {
            close.accepted = mainWindow.allowClose
        } else {
            close.accepted = true
        }
    }

    property bool allowClose: false

    MyControls.Dialog {
        id: messageDialog
        title: qsTr("Unable to log in")
        modal: true
        focus: true

        parent: Overlay.overlay

        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 3)

        Text {
            id: messageDialogText
        }
    }

    BackEnd {
        id: backend
    }

    Row {
        id: actionsScreen
        visible: false

        ColumnLayout {
            id: actionsLayout
            anchors.fill: parent
            spacing: 6

            GroupBox {
                id: paymentGroupBox
                implicitWidth: mainWindow.width
                title: qsTr("1. Add funds via coinbox")

                label: Label {
                    font.pointSize: 14
                    x: paymentGroupBox.leftPadding
                    width: paymentGroupBox.availableWidth
                    text: paymentGroupBox.title
                    background: Rectangle {
                        color: "#EEAE0D"
                    }

                    elide: Text.ElideRight
                }

                PaymentWindow {
                    id: paymentWindow
                }
            }

            GroupBox {
                id: fundsGroupBox
                implicitWidth: mainWindow.width
                title: qsTr("2. Funds available for printing")

                label: Label {
                    font.pointSize: 14
                    x: fundsGroupBox.leftPadding
                    width: fundsGroupBox.availableWidth
                    text: fundsGroupBox.title
                    background: Rectangle {
                        color: "#EEAE0D"
                    }

                    elide: Text.ElideRight
                }

                LibkiBalance {
                    id: libkiBalance
                }
            }

            GroupBox {
                id: releaseGroupBox
                implicitWidth: mainWindow.width
                title: qsTr("3. Release print jobs to printer")

                label: Label {
                    font.pointSize: 14
                    x: releaseGroupBox.leftPadding
                    width: releaseGroupBox.availableWidth
                    text: releaseGroupBox.title
                    background: Rectangle {
                        color: "#EEAE0D"
                    }

                    elide: Text.ElideRight
                }

                Layout.minimumWidth: mainWindow.width
                Layout.minimumHeight: 500
                Layout.preferredWidth: parent.width
                PrintRelease {
                    id: printRelease
                }
            }

            GroupBox {
                id: logoutGroupBox
                implicitWidth: mainWindow.width
                title: qsTr("4. Log out")

                label: Label {
                    id: logoutTitle
                    font.pointSize: 14
                    x: logoutGroupBox.leftPadding
                    width: logoutGroupBox.availableWidth
                    text: logoutGroupBox.title
                    background: Rectangle {
                        color: "#EEAE0D"
                    }

                    elide: Text.ElideRight
                }

                Row {
                    topPadding: 10
                    Button {
                        text: qsTr("Log out")
                        anchors.top: logoutGroupBox.top
                        onClicked: function () {
                            backend.userName = ""
                            backend.userPassword = ""

                            printRelease.unload()
                            libkiBalance.unload()

                            loginScreen.visible = true
                            actionsScreen.visible = false

                            textFieldUsername.clear()
                            textFieldPassword.clear()
                            textFieldUsername.focus = true

                            var success
                            success = backend.jamexReturnBalance
                            success = backend.jamexEnableChangeCardReturn
                        }
                    }
                }
            }
        }
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

                Text {
                    anchors.top: libkiLogo.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: descriptionText
                    text: qsTr("Printing Center")
                }

                GridLayout {
                    id: usernamePasswordGrid
                    rows: 3
                    columns: 2
                    anchors.top: descriptionText.bottom
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
                        Keys.onReturnPressed: usernamePasswordGrid.jumpToPasswordField()
                        Keys.onEnterPressed: usernamePasswordGrid.jumpToPasswordField()
                    }
                    function jumpToPasswordField() {
                        backend.userName = textFieldUsername.text
                        textFieldPassword.focus = true
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
                        Keys.onEnterPressed: usernamePasswordGrid.attemptLogin()
                        Keys.onReturnPressed: usernamePasswordGrid.attemptLogin()
                    }
                    function attemptLogin() {
                        if (textFieldUsername.text == backend.appBackdoorUsername
                                && textFieldPassword.text == backend.appBackdoorPassword) {
                            mainWindow.allowClose = true
                            Qt.quit()
                        } else {
                            backend.userPassword = textFieldPassword.text
                            login.clicked()
                        }
                    }

                    Text {}

                    Button {
                        id: login
                        text: qsTr("Log in")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        enabled: textFieldUsername.length
                                 && textFieldPassword.length
                        onClicked: function () {
                            var username = backend.userName
                            var password = backend.userPassword
                            var api_key = backend.serverApiKey
                            var server_address = backend.serverAddress
                            var path = '/api/public/authenticate_user/'
                            var url = server_address + path + "?api_key=" + api_key
                                    + "&username=" + username + "&password=" + password
                            console.log("AUTHENTICATION URL: " + url)
                            Functions.request(url, function (o) {
                                // log the json response
                                console.log(o.responseText)
                                // translate response into object
                                var d = eval('new Object(' + o.responseText + ')')

                                if (d.success) {
                                    loginScreen.visible = false
                                    actionsScreen.visible = true
                                    printRelease.load(username, password,
                                                      api_key, server_address)
                                    libkiBalance.load(username, password,
                                                      api_key, server_address)
                                } else {
                                    if (d.error === "SIP_ACS_OFFLINE") {
                                        messageDialogText.text = qsTr(
                                                    "Unable to authenticate. ILS is offline for SIP.")
                                    } else if (d.error === "SIP_AUTH_FAILURE") {
                                        messageDialogText.text = qsTr(
                                                    "Unable to authenticate. ILS login for SIP failed.")
                                    } else if (d.error === "INVALID_API_KEY") {
                                        messageDialogText.text = qsTr(
                                                    "Unable to authenticate. API key is invalid.")
                                    } else if (d.error === "FEE_LIMIT") {
                                        messageDialogText.text(
                                                    "Unable to log in, you own too many fees.")
                                    } else if (d.error === "INVALID_USER"
                                               || d.error == "INVALID_PASSWORD"
                                               || d.error == "BAD_LOGIN") {
                                        messageDialogText.text = qsTr(
                                                    "Username & password do not match.")
                                    } else {
                                        messageDialogText.text = qsTr(
                                                    "Unable to authenticate. Error code: ")
                                                + d.error
                                    }

                                    textFieldUsername.text = ""
                                    textFieldPassword.text = ""
                                    backend.userName = ""
                                    backend.userPassword = ""

                                    messageDialog.open()

                                    textFieldUsername.focus = true
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}
