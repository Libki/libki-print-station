import QtQuick 2.0
import QtQuick.Layouts 1.12

import "functions.js" as Functions

GridLayout {
    id: libkiBalance

    rows: 1
    columns: 2
    anchors.top: parent.top + (parent.top / 4)

    property string username
    property string password
    property string apiKey
    property string serverAddress

    property string balance
    property double currentLibkiBalance: 0

    signal load(string u, string p, string a, string s)
    onLoad: function (u, p, a, s) {
        username = u
        password = p
        apiKey = a
        serverAddress = s

        refreshLibkiBalanceTimer.running = true
    }

    signal unload
    onUnload: function () {
        username = ""
        password = ""

        balance = ""
        libkiBalanceAmount.text = ""

        refreshLibkiBalanceTimer.running = false
    }

    Timer {
        id: refreshLibkiBalanceTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: refreshLibkiBalance()
    }

    function refreshLibkiBalance() {
        const url = Functions.build_user_funds_available_url(serverAddress,
                                                             apiKey, username,
                                                             password)

        Functions.request(url, function (o) {
            var data = eval('new Object(' + o.responseText + ')')

            let first_check = balance === "";
            balance = parseFloat(data.funds)
            let evaluate_print_buttons = balance != currentLibkiBalance
            currentLibkiBalance = balance
            libkiBalanceAmount.text = qsTr("$") + currentLibkiBalance.toFixed(2)

            if (first_check || evaluate_print_buttons) {
                mainWindow.balanceChanged()
            }
        }, 'GET')
    }

    Text {
        id: libkiBalanceLabel
        font.pointSize: 18
        text: qsTr("Balance in your Libki account:")
    }

    Text {
        id: libkiBalanceAmount
        font.pointSize: 18
    }
}
