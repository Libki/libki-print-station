import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

import io.qt.libki_jamex.backend 1.0

Component {
    id:  paymentWindow
    Window {
        title: qsTr("Libki Jamex Payment Processor")
        width: 800
        height: 800
        visible: false

        onVisibilityChanged: function(){
            console.log("USERNAME: " + backend.userName);
        }

        BackEnd {
            id: backend
        }

        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: updateJamexBalanceAmount()
        }
        function updateJamexBalanceAmount() {
            var jbalance = backend.jamexBalance;
            if ( jamexBalanceAmount.text != jbalance) {
                console.log("JAMEX BALANCE CHANGED!");
                jamexBalanceAmount.text = jbalance.toFixed(2);
                spinbox.to = jbalance * 100;
                console.log("JAMEX BALANCE: " + jbalance );
            }
        }

        GridLayout {
            id: transferFundsGrid
            rows: 4
            columns: 2
            anchors.top: libkiLogo.bottom
            anchors.horizontalCenterOffset: 0
            anchors.verticalCenterOffset: 0
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: qsTr("Machine balance")
            }

            Text {
                id: jamexBalanceAmount
                text: parseFloat(backend.jamexBalance).toFixed(2)
            }

            Label {
                id: labelAmountToTransfer
                text: qsTr("Amount to tranfer:")
            }

            SpinBox {
                id: spinbox
                from: 0
                value: 0
                to: backend.jamexBalance * 100
                stepSize: 1
                editable: true

                property int decimals: 2

                validator: DoubleValidator {
                    bottom: Math.min(spinbox.from, spinbox.to)
                    top:  Math.max(spinbox.from, spinbox.to)
                }

                textFromValue: function(value, locale) {
                    return Number(value / 100).toLocaleString(locale, 'f', spinbox.decimals)
                }

                valueFromText: function(text, locale) {
                    return Number.fromLocaleString(locale, text) * 100
                }

                onValueModified: {
                    var jamexBalance = jamexBalanceAmount.text;
                    console.log("JAMX BAL: " + jamexBalance);
                    var balanceForLibki = spinbox.value / 100;
                    console.log("FOR LIBKI: " + balanceForLibki );
                    var remainder = jamexBalance - balanceForLibki;
                    console.log("REMAIN: " + remainder );
                    balanceToReturn.text = remainder.toFixed(2);
                }
            }


            Text {
                text: qsTr("Balance to return")
            }

            Text {
                id: balanceToReturn
                text: qsTr("0.00")
            }

            Text{}

            Button {
                text: qsTr("Transfer funds")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                onClicked: {
                    var username = backend.userName
                    var api_key = backend.serverApiKey
                    var server_address = backend.serverAddress
                    var path = '/api/public/authenticate/'
                    var url = server_address + path + api_key + "?username=" + username + "&password=" + password;
                    console.log("AUTHENTICATION URL: " + url)
                    request(url, function (o) {
                        // log the json response
                        console.log(o.responseText);
                        // translate response into object
                        var d = eval('new Object(' + o.responseText + ')');

                        if ( d.success ) {
                            var window = paymentWindow.createObject(mainWindow);
                            mainWindow.hide();
                            conn.target = window;
                        } else {
                            if ( d.error == "SIP_ACS_OFFLINE" ) {
                                messageDialog.text = qsTr("Unable to authenticate. ILS is offline for SIP.");
                            } else if ( d.error == "SIP_AUTH_FAILURE" ) {
                                messageDialog.text = qsTr("Unable to authenticate. ILS login for SIP failed.");
                            } else if ( d.error == "FEE_LIMIT" ) {
                                messageDialog.text("Unable to log in, you own too many fees.");
                            } else if ( d.error == "INVALID_USER" || d.error == "INVALID_PASSWORD" || d.error == "BAD_LOGIN"){
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


