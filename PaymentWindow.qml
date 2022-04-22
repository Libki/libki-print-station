import Qt.labs.platform

import QtQuick 2.12
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls 2.5 as MyControls
import QtQuick.Controls
import QtQuick.Layouts 1.12
import QtQuick.Dialogs

import "functions.js" as Functions

import io.qt.libki_jamex.backend 1.0

RowLayout {
    id: paymentWindow

    property double currentJamexMachineBalance: 0

    // https://doc.qt.io/qt-5/qml-qtquick-controls2-dialog.html
    MyControls.Dialog {
        id: paymentWindowMessageDialog
        modal: true
        focus: true
        standardButtons: MyControls.Dialog.Ok

        parent: Overlay.overlay

        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)

        Text {
            id: paymentWindowMessageDialogText
        }
    }

    onVisibleChanged: function() {
        transferFundsButton.enabled
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateJamexBalanceAmount()
    }

    function updateJamexBalanceAmount() {
        var jbalance_float = parseFloat(backend.jamexBalance)

        let balance_changed = jbalance_float != currentJamexMachineBalance

        currentJamexMachineBalance = jbalance_float

        var jbalance = jbalance_float.toFixed(2)
        if (jamexBalanceAmount.text.substring(1) != jbalance) {
            jamexBalanceAmount.text = qsTr("$") + jbalance
            amountToTransferSpinbox.to = jbalance * 100

            var balanceForLibki = amountToTransferSpinbox.value / 100
            var remainder = jbalance - balanceForLibki
            balanceToReturn.text = qsTr("$") + remainder.toFixed(2)
        }

        if ( balance_changed ) mainWindow.balanceChanged()
    }

    function deductAmount(amount) {
        let a = amount.toFixed(2)
        backend.jamexDeductAmount = a
        const success = backend.jamexDeductAmount
        return success
    }

    function transferFunds() {
        var username = backend.userName
        var funds = amountToTransferSpinbox.value / 100
        var api_key = backend.serverApiKey
        var server_address = backend.serverAddress
        var path = '/api/public/user_funds/'

        let url = Functions.build_add_user_funds_url(server_address, api_key,
                                                     username, funds)

        if (amountToTransferSpinbox.value == 0) {
            return
        }

        transferFundsButton.enabled = false

        var balanceForLibki = amountToTransferSpinbox.value / 100
        var amount_to_deduct = balanceForLibki.toFixed(2)

        backend.jamexDeductAmount = amount_to_deduct
        var success
        success = backend.jamexDeductAmount
        if (success === "false") {
            paymentWindowMessageDialogText.text = qsTr(
                        "Unable to deduct amount from coinbox. Please ask staff for help")
            transferFundsButton.enabled = true
        } else {

            //backend.jamexDisableChangeCardReturn;
            waitDialog.open()
            Functions.request(url, function (o) {
                waitDialog.close()
                // translate response into an object
                var d = eval('new Object(' + o.responseText + ')')

                let messageText
                if (d.success) {
                    messageText = qsTr("Funds have been transferred!")
                } else {
                    if (d.error === "INVALID_API_KEY") {
                        messageText = qsTr(
                                    "Unable to authenticate. API key is invalid.")
                    } else if (d.error === "INVALID_USER") {
                        messageText = qsTr("Unable to find user.")
                    } else if ( d && d.error ) {
                        messageText = qsTr(
                                    "Unable to add funds. Error code: ") + d.error
                    } else {
                        messageText = qsTr("Unable to connect to server.")
                    }

                    // Return the funds, they did not get applied to their Libki funds balance
                    backend.jamexAddAmount = amount_to_deduct //FIXME:
                    success = backend.jamexAddAmount
                }

                amountToTransferSpinbox.value = 0
                transferFundsButton.enabled = true

                paymentWindowMessageDialogText.text = messageText
                paymentWindowMessageDialog.open()

                success = backend.jamexReturnBalance
                success = backend.jamexEnableChangeCardReturn
            }, 'POST')
        }
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
            editable: true

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
            text: qsTr("Transfer funds to Libki account")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            onClicked: transferFunds(true)
        }
    }
}
