import QtQuick 2.12
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls 2.5
import QtQuick.Controls
import QtQuick.Layouts 1.12
import QtQuick.Dialogs

import "functions.js" as Functions

ColumnLayout {
    id: printJobsTable
    anchors.fill: parent
    spacing: 10

    signal load(string username, string password, string apiKey, string serverAddress)
    onLoad: function (username, password, apiKey, serverAddress) {
        printJobsModel.load(username, password, apiKey, serverAddress)
    }

    signal unload
    onUnload: function () {
        refreshPrintJobsTimer.running = false
        printJobsModel.clear()
    }

    Text {
        id: printButtonWarning
        text: qsTr('If enough funds are available, printing will start immediately when the "print" button is clicked.')
    }

    TableView {
        id: printJobsTableView

        anchors.fill: parent
        topMargin: 10
        columnSpacing: 10
        rowSpacing: 10
        anchors.top: printButtonWarning.bottom
        anchors.topMargin: printButtonWarning.height + 5

        Timer {
            id: refreshPrintJobsTimer
            interval: 5000
            running: false
            repeat: true
            onTriggered: printJobsModel.refreshPrintJobsTable()
        }

        Dialog {
            id: popupDialog
            title: qsTr("Job printed")
            modal: true
            focus: true

            parent: Overlay.overlay

            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 3)
            standardButtons: Dialog.Ok

            Text {
                id: popupDialogText
                text: qsTr("Your print job has been submitted.")
            }
        }

        Dialog {
            id: dialog
            title: qsTr("Print preview")
            modal: true
            visible: false
            width: parent.width
            height: parent.height
            standardButtons: Dialog.Ok
            property var dialogPrintJobId
            contentItem: Item {
                Image {
                    id: printPreviewImage
                    height: parent.height
                    width: parent.width
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        delegate: DelegateChooser {
            DelegateChoice {
                // First row is always the header, labels only
                row: 0
                delegate: Label {
                    text: model.display
                    width: 200
                }
            }
            DelegateChoice {
                column: 4
                delegate: Button {
                    text: "Preview"
                    property var printJobId: model.display
                    onClicked: {
                        dialog.dialogPrintJobId = printJobId
                        dialog.visible = true
                        printPreviewImage.source = Functions.build_print_preview_url(
                                    printJobsModel.myServerAddress,
                                    printJobsModel.myApiKey,
                                    printJobsModel.myUsername,
                                    printJobsModel.myPassword, printJobId)
                    }
                }
            }
            DelegateChoice {
                column: 5
                delegate: Button {
                    text: qsTr("Print")
                    enabled: libkiBalance.currentLibkiBalance
                             + paymentWindow.currentJamexMachineBalance
                             >= printJobsModel.prices[model.display]
                    property var printJobId: model.display
                    onClicked: {
                        let print_job_cost = printJobsModel.prices[printJobId]
                        let libki_balance = libkiBalance.balance
                        let jamex_balance = paymentWindow.currentJamexMachineBalance

                        if (print_job_cost > libki_balance + jamex_balance) {
                            popupDialogText.text = qsTr("Insufficient funds!")
                            popupDialog.open()
                            return
                        }

                        // The current balance isn't enough to pay for the job, we need to transfer some funds first
                        if (print_job_cost > libki_balance) {
                            let amount_needed = print_job_cost - libki_balance
                            paymentWindow.transferAmount(amount_needed * 100)

                            // The above call is asynchronus, wait until the amount has transferred
                            let i = 1
                            while (print_job_cost > libki_balance) {
                                libki_balance = libkiBalance.balance
                                console.log(i + ": " + libki_balance)
                                i++
                            }
                        }

                        const url = Functions.build_print_release_url(
                                      printJobsModel.myServerAddress,
                                      printJobsModel.myApiKey,
                                      printJobsModel.myUsername,
                                      printJobsModel.myPassword, printJobId)

                        Functions.request(url, function (o) {
                            // translate response into an object
                            var d = eval('new Object(' + o.responseText + ')')
                            console.log("PRINT JOB RELEASE RESPONSE: " + o.responseText)

                            if (d.success) {
                                popupDialogText.text = qsTr(
                                            "Your print job has been submitted.")
                            } else {
                                if (d.error === "INVALID_API_KEY") {
                                    popupDialogText.text = qsTr(
                                                "Unable to authenticate. API key is invalid.")
                                } else if (d.error === "INVALID_USER") {
                                    popupDialogText.text = qsTr(
                                                "Unable to find user.")
                                } else if (d.error === "INSUFFICIENT_FUNDS") {
                                    popupDialogText.text = qsTr(
                                                "Insufficient funds.")
                                } else {
                                    popupDialogText.text = d.error
                                }
                            }

                            printJobsModel.load(printJobsModel.myUsername,
                                                printJobsModel.myPassword,
                                                printJobsModel.myApiKey,
                                                printJobsModel.myServerAddress)

                            popupDialog.open()
                        }, 'POST')
                    }
                }
            }

            DelegateChoice {
                column: 6
                delegate: Button {
                    text: qsTr("Cancel")
                    enabled: true //Should be status == "Held"
                    property var printJobId: model.display
                    onClicked: {
                        confirmCancelDialog.printJobId = printJobId
                        confirmCancelDialog.open()
                    }
                }
            }

            DelegateChoice {
                delegate: Label {
                    text: model.display
                    width: 200
                }
            }
        }

        Dialog {
            id: confirmCancelDialog
            title: qsTr("Cancel print job?")
            modal: true
            focus: true

            parent: Overlay.overlay

            property var printJobId

            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 3)
            standardButtons: Dialog.Yes | Dialog.No

            onAccepted: {
                console.log("Ok clicked: " + printJobId)

                const url = Functions.build_print_cancel_url(
                              printJobsModel.myServerAddress,
                              printJobsModel.myApiKey,
                              printJobsModel.myUsername,
                              printJobsModel.myPassword, printJobId)

                Functions.request(url, function (o) {
                    // translate response into an object
                    var d = eval('new Object(' + o.responseText + ')')
                    console.log("PRINT JOB CANCEL RESPONSE: " + o.responseText)

                    if (d.success) {
                        popupDialogText.text = qsTr(
                                    "Your print job has been canceled.")
                    } else {
                        if (d.error === "INVALID_API_KEY") {
                            popupDialogText.text = qsTr(
                                        "Unable to authenticate. API key is invalid.")
                        } else if (d.error === "INVALID_USER") {
                            popupDialogText.text = qsTr("Unable to find user.")
                        } else {
                            popupDialogText.text = d.error
                        }
                    }

                    printJobsModel.load(printJobsModel.myUsername,
                                        printJobsModel.myPassword,
                                        printJobsModel.myApiKey,
                                        printJobsModel.myServerAddress)

                    popupDialog.open()
                }, 'POST')
            }
        }

        model: TableModel {
            id: printJobsModel

            TableModelColumn {
                display: "pages"
            }
            TableModelColumn {
                display: "copies"
            }
            TableModelColumn {
                display: "created_on"
            }
            TableModelColumn {
                display: "cost"
            }
            TableModelColumn {
                display: "print_job_id"
            }
            TableModelColumn {
                display: "print_job_id"
            }
            TableModelColumn {
                display: "cancel_print_job_id"
            }

            property var headerRow: {
                "copies": qsTr("Copies"),
                "print_file_id": qsTr("Preview"),
                "pages": qsTr("Pages"),
                "print_job_id": "",
                "cancel_print_job_id": "",
                "created_on": qsTr("Created on"),
                "cost": qsTr("Cost")
            }

            property var prices: ({})

            property string urlTemplate: "%1/api/printstation/v1_0/print_jobs?api_key=%2&username=%3&password=%4"

            property string myApiKey: ""
            property string myServerAddress: ""
            property string myUsername: ""
            property string myPassword: ""

            signal load(string username, string password, string apiKey, string serverAddress)
            onLoad: function (username, password, apiKey, serverAddress) {
                myUsername = username
                myPassword = password
                myApiKey = apiKey
                myServerAddress = serverAddress

                printJobsModel.setRow(0, headerRow)

                printJobsModel.refreshPrintJobsTable()

                refreshPrintJobsTimer.running = true
            }

            function refreshPrintJobsTable() {
                var xhr = new XMLHttpRequest
                var url = urlTemplate.arg(myServerAddress).arg(myApiKey).arg(
                            myUsername).arg(myPassword)
                console.log("URL: " + url)
                xhr.open("GET", url)
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        let data = JSON.parse(xhr.responseText)
                        let j = 1


                        /* Clearing the table and creating all the updated rows at once causes drawing flicker,
                       to prevent this we update one row at a time and clear any remaining rows */
                        for (var i in data) {
                            const copies = data[i].copies
                            const cost = data[i].cost
                            const created_on = data[i].created_on
                            const pages = data[i].pages
                            const print_file_id = data[i].print_file_id
                            const print_job_id = data[i].print_job_id

                            prices[print_job_id] = cost

                            let rowData = {
                                "copies": copies,
                                "cost": qsTr("$") + parseFloat(cost).toFixed(2),
                                "created_on": created_on,
                                "pages": pages,
                                "print_file_id": print_file_id,
                                "print_job_id": print_job_id,
                                "cancel_print_job_id": print_job_id
                            }

                            if (j < printJobsModel.rowcount) {
                                printJobsModel.setRow(j, rowData)
                            } else {
                                printJobsModel.appendRow(rowData)
                            }
                            j++
                        }

                        if (printJobsModel.rowCount > j) {
                            printJobsModel.removeRow(
                                        j, printJobsModel.rowCount - j)
                        }
                    }
                }
                xhr.send()
            }
        }
    }
}
