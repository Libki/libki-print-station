import Qt.labs.platform

import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12

import QtQuick 2.12
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls 2.5
import QtQuick.Controls
import QtQuick.Layouts 1.12
import QtQuick.Dialogs

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
    property double currentJamexMachineBalance: 0

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
        var jbalance_float = parseFloat(backend.jamexBalance)
        currentJamexMachineBalance = jbalance_float
        var jbalance = jbalance_float.toFixed(2)
        if (jamexBalanceAmount.text.substring(1) != jbalance) {
            jamexBalanceAmount.text = qsTr("$") + jbalance
            amountToTransferSpinbox.to = jbalance * 100

            var balanceForLibki = amountToTransferSpinbox.value / 100
            var remainder = jbalance - balanceForLibki
            balanceToReturn.text = qsTr("$") + remainder.toFixed(2)
        }
    }

    function deductAmount(amount) {
        let a = amount.toFixed(2)
        console.log("AMOUNT TO DEDUCT: " + a)
        backend.jamexDeductAmount = a
        const success = backend.jamexDeductAmount
        return success
    }

    function transferFunds() {
        transferFundsButton.enabled = false
        var username = backend.userName
        var funds = amountToTransferSpinbox.value / 100
        var api_key = backend.serverApiKey
        var server_address = backend.serverAddress
        var path = '/api/public/user_funds/'

        let url = Functions.build_add_user_funds_url(server_address, api_key,
                                                     username, funds)

        if (amountToTransferSpinbox.value == 0) {
            transferFundsButton.enabled = true
            return
        }

        //backend.jamexDisableChangeCardReturn;
        Functions.request(url, function (o) {
            // translate response into an object
            var d = eval('new Object(' + o.responseText + ')')

            var success
            console.log("PAYMENT RESPONSE:")
            console.log(d)

            if (d.success) {
                var balanceForLibki = amountToTransferSpinbox.value / 100
                var amount_to_deduct = balanceForLibki.toFixed(2)

                paymentDialog.text = qsTr("Funds have been transferred!")
                paymentDialog.visible = true

                console.log("AMOUNT TO DEDUCT: " + amount_to_deduct)
                backend.jamexDeductAmount = amount_to_deduct
                success = backend.jamexDeductAmount
                if (success === "false") {
                    // Must pass string, not bool
                    paymentDialog.text = qsTr(
                                "Unable to deduct amount from Jamex machine. Please ask staff for help")
                    paymentDialog.visible = true
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

            amountToTransferSpinbox.value = 0

            transferFundsButton.enabled = true
        }, 'POST')
    }

    GridLayout {
        id: transferFundsGrid
        rows: 4
        columns: 2

        Text {
            text: qsTr("Balance in machine:")
        }

        Text {
            id: jamexBalanceAmount
            text: qsTr("$") + parseFloat(backend.jamexBalance).toFixed(2)
        }

        Label {
            id: labelAmountToTransfer
            text: qsTr("Amount to transfer:")
        }

        SpinBox {
            id: amountToTransferSpinbox
            from: 0
            value: 0
            to: backend.jamexBalance * 100
            stepSize: 1
            editable: backend.JamexBalance > 0

            property int decimals: 2

            validator: DoubleValidator {
                bottom: Math.min(amountToTransferSpinbox.from,
                                 amountToTransferSpinbox.to)
                top: Math.max(amountToTransferSpinbox.from,
                              amountToTransferSpinbox.to)
            }

            textFromValue: function (value, locale) {
                return Number(value / 100).toLocaleString(
                            locale, 'f', amountToTransferSpinbox.decimals)
            }

            valueFromText: function (text, locale) {
                return Number.fromLocaleString(locale, text) * 100
            }

            onValueModified: {
                var jamexBalance = jamexBalanceAmount.text.substring(1)
                var balanceForLibki = amountToTransferSpinbox.value / 100
                var remainder = jamexBalance - balanceForLibki
                balanceToReturn.text = qsTr("$") + remainder.toFixed(2)
            }
        }

        Text {
            text: qsTr("Balance to return:")
        }

        Text {
            id: balanceToReturn
            text: "$0.00"
        }

        Text {}

        Button {
            id: transferFundsButton
            text: qsTr("Transfer funds")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            onClicked: transferFunds(true)
        }
    }
}
