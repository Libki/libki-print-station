import Qt.labs.platform

import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12

import "functions.js" as Functions

import io.qt.libki_jamex.backend 1.0

RowLayout {
    id: paymentWindow

    //        onVisibilityChanged: function() {
    //            // Change / card return should always been enabled when this window is shown or hidden
    //           var success = backend.jamexEnableChangeCardReturn;
    //            // If this window is hidden, we are back at the login screen and should attempt to return
    //            // the change or balance in case the user
    //            if ( ! this.visible ) {
    //                success = backend.jamexReturnBalance;
    //            }
    //        }
    BackEnd {
        id: backend
    }

    MessageDialog {
        id: paymentDialog
        title: qsTr("Payment confirmed")
        text: ""
        modality: Qt.WindowModal
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateJamexBalanceAmount()
    }
    function updateJamexBalanceAmount() {
        var jbalance = parseFloat(backend.jamexBalance).toFixed(2)
        if (jamexBalanceAmount.text != jbalance) {
            jamexBalanceAmount.text = jbalance
            spinbox.to = jbalance * 100

            var balanceForLibki = spinbox.value / 100
            var remainder = jbalance - balanceForLibki
            balanceToReturn.text = remainder.toFixed(2)
        }
    }

    GridLayout {
        id: transferFundsGrid
        rows: 4
        columns: 2

        Text {
            text: qsTr("Machine balance")
        }

        Text {
            id: jamexBalanceAmount
            text: parseFloat(backend.jamexBalance).toFixed(2)
        }

        Label {
            id: labelAmountToTransfer
            text: qsTr("Amount to transfer:")
        }

        SpinBox {
            id: spinbox
            from: 0
            value: 0
            to: backend.jamexBalance * 100
            stepSize: 1
            editable: parseFloat(jamexBalanceAmount.text) > 0

            property int decimals: 2

            validator: DoubleValidator {
                bottom: Math.min(spinbox.from, spinbox.to)
                top: Math.max(spinbox.from, spinbox.to)
            }

            textFromValue: function (value, locale) {
                return Number(value / 100).toLocaleString(locale, 'f',
                                                          spinbox.decimals)
            }

            valueFromText: function (text, locale) {
                return Number.fromLocaleString(locale, text) * 100
            }

            onValueModified: {
                var jamexBalance = jamexBalanceAmount.text
                var balanceForLibki = spinbox.value / 100
                var remainder = jamexBalance - balanceForLibki
                balanceToReturn.text = remainder.toFixed(2)
            }
        }

        Text {
            text: qsTr("Balance to return")
        }

        Text {
            id: balanceToReturn
            text: "0.00"
        }

        Text {}

        Button {
            text: qsTr("Transfer funds")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            enabled: spinbox.value > 0
            onClicked: {
                var username = backend.userName
                var funds = spinbox.value / 100
                var api_key = backend.serverApiKey
                var server_address = backend.serverAddress
                var path = '/api/public/user_funds/'
                var url = server_address + path + "?api_key=" + api_key
                        + "&username=" + username + "&funds=" + funds

                //backend.jamexDisableChangeCardReturn;
                Functions.request(url, function (o) {
                    // translate response into an object
                    var d = eval('new Object(' + o.responseText + ')')

                    var success

                    if (d.success) {
                        var balanceForLibki = spinbox.value / 100
                        var amount_to_deduct = balanceForLibki.toFixed(2)

                        paymentDialog.text = qsTr(
                                    "Funds have been transferred!")
                        paymentDialog.visible = true

                        console.log("AMOUNT TO DEDUCT: " + amount_to_deduct)
                        backend.jamexDeductAmount = amount_to_deduct
                        success = backend.jamexDeductAmount
                        if (success === "false") {
                            // Must pass string, not bool
                            MessageDialog.text = qsTr(
                                        "Unable to deduct amount from Jamex machine. Please ask staff for help")
                            MessageDialog.visible = true
                        }
                    } else {
                        if (d.error === "INVALID_API_KEY") {
                            mssageDialog.text = qsTr(
                                        "Unable to authenticate. API key is invalid.")
                        } else if (d.error === "INVALID_USER") {
                            messageDialog.text(qsTr("Unable to find user."))
                        } else {
                            messageDialog.text = qsTr(
                                        "Unable to add funds. Error code: ") + d.error
                        }

                        messageDialog.visible = true
                    }

                    success = backend.jamexReturnBalance
                    success = backend.jamexEnableChangeCardReturn

                    backend.userName = ""
                    backend.userPassword = ""

                    paymentWindow.hide()
                }, 'POST')
            }
        }
    }
}
