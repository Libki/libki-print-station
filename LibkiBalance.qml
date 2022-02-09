import QtQuick 2.0
import QtQuick.Layouts 1.12

import "functions.js" as Functions

GridLayout {
    rows: 1
    columns: 2
    anchors.top: parent.top + (parent.top / 4)

    property string username
    property string password
    property string apiKey
    property string serverAddress

    property string balance

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

        balance = "0.00"
        libkiBalanceAmount.text = ""

        refreshLibkiBalanceTimer.running = false
    }

    Timer {
        id: refreshLibkiBalanceTimer
        interval: 500
        running: false
        repeat: true
        onTriggered: refreshLibkiBalance()
    }

    function refreshLibkiBalance() {
        const url = Functions.build_user_funds_available_url(serverAddress,
                                                             apiKey, username,
                                                             password)
        console.log("LIBKI BALANCE URL: " + url)

        Functions.request(url, function (o) {
            var data = eval('new Object(' + o.responseText + ')')
            console.log(data.funds)

        balance = data.funds
        libkiBalanceAmount.text = qsTr("$") + parseFloat(balance).toFixed(2)
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
