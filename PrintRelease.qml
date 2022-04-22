import Qt.labs.platform
import QtQuick 2.12
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls 2.5
import QtQuick.Controls as MyControls
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
        printJobsModel.clear()
    }

    signal balanceChanged
    onBalanceChanged: function () {
        printJobsTableView.triggerEvaluateEnabled()
    }

    Text {
        id: printButtonWarning
        text: qsTr('If enough funds are available, printing will start immediately when the "print" button is clicked.')
    }

    Button {
        id: refreshPrintJobsTableButton
        text: qsTr("Refresh")
        enabled: true
        onClicked: {
            printJobsModel.refreshPrintJobsTable()
        }
    }

    function release_print_job(print_job_id, selected_printer) {
        const url = Functions.build_print_release_url(
                      printJobsModel.myServerAddress, printJobsModel.myApiKey,
                      printJobsModel.myUsername, printJobsModel.myPassword,
                      print_job_id, selected_printer)

        waitDialog.open()
        Functions.request(url, function (o) {
            waitDialog.close()
            // translate response into an object
            var d = eval('new Object(' + o.responseText + ')')

            if (d.success) {
                popupDialogText.text = qsTr(
                            "Your print job has been submitted.")
            } else {
                if (d.error === "INVALID_API_KEY") {
                    popupDialogText.text = qsTr(
                                "Unable to authenticate. API key is invalid.")
                } else if (d.error === "INVALID_USER") {
                    popupDialogText.text = qsTr("Unable to find user.")
                } else if (d.error === "INSUFFICIENT_FUNDS") {
                    popupDialogText.text = qsTr("Insufficient funds.")
                } else if (d.error) {
                    popupDialogText.text = d.error
                } else {
                    popupDialogText.text = qsTr("Unable to connect to server.")
                }
            }

            printJobsModel.refreshPrintJobsTable()
            popupDialog.open()
        }, 'POST')
    }

    TableView {
        id: printJobsTableView

        property var printers
        property var printJobs

        signal evaluateEnabled(int rowChanged)
        function triggerEvaluateEnabled(rowChanged) {
            evaluateEnabled(rowChanged)
        }

        anchors.fill: parent
        topMargin: 20
        columnSpacing: 10
        rowSpacing: 10
        anchors.top: printButtonWarning.bottom
        anchors.topMargin: printButtonWarning.height + refreshPrintJobsTableButton.height + 5

        // Column 4 is "Printer" ComboBox inside a Rectangle,
        // it's layout doesn't work for some reason
        // so we need to force its width
        columnWidthProvider: function (column) {
            if (column == 4)
                return 200
        }

        onWidthChanged: printJobsTableView.forceLayout()

        MyControls.Dialog {
            id: popupDialog
            title: qsTr("Job printed")
            modal: true
            focus: true

            parent: Overlay.overlay

            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 3)
            standardButtons: MyControls.Dialog.Ok

            Text {
                id: popupDialogText
                text: ""
            }
        }

        MyControls.Dialog {
            id: dialog
            title: qsTr("Print preview")
            modal: true
            visible: false
            width: parent.width
            height: parent.height
            standardButtons: MyControls.Dialog.Ok
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
                delegate: Rectangle {
                    id: printerSelectContainer
                    property var selectedPrinter: model.display
                    property var myModel: model
                    ComboBox {
                        id: cb
                        editable: false
                        width: 200
                        property var innerModel: printerSelectContainer.myModel
                        model: {
                            let options = []
                            let printers = printJobsTableView.printers
                            let indexToSelect = 0
                            let i = 0
                            for (var p in printers) {
                                let printer = printers[p]
                                let public_printer_name = printer["public_printer_name"]
                                options.push(public_printer_name)
                                if (printerSelectContainer.selectedPrinter == p) {
                                    indexToSelect = i
                                }
                                i++
                            }

                            this.currentIndex = indexToSelect
                            return options
                        }
                        onActivated: {
                            let selected_printer = cb.currentText
                            let print_jobs_model = printJobsModel
                            let row = cb.innerModel.row
                            let modelRow = print_jobs_model.rows[row]
                            let pages = modelRow.pages
                            let copies = modelRow.copies

                            let printer_data
                            let printer
                            let printers = printJobsTableView.printers
                            for (var p in printers) {
                                let a_printer = printers[p]
                                let public_printer_name = a_printer["public_printer_name"]

                                if (public_printer_name == selected_printer) {
                                    console.log("MATCH FOUND!")
                                    printer = p
                                    printer_data = a_printer
                                    break
                                }
                            }

                            let cost_per_page = printer_data.cost_per_page
                            let cost = copies * pages * cost_per_page

                            let cost_float = parseFloat(cost)

                            let libki_balance = libkiBalance.currentLibkiBalance

                            let jamex_balance = paymentWindow.currentJamexMachineBalance
                            if (jamex_balance < 0)
                                // Jamex reports a balance of -1 if not connected
                                jamex_balance = 0

                            modelRow.printer = p
                            modelRow.printer_data = printer_data
                            modelRow.cost = qsTr("$") + cost_float.toFixed(2)
                            modelRow.cost_float = cost_float

                            let current_index = cb.currentIndex
                            printJobsModel.setRow(row, modelRow)
                            cb.currentIndex = current_index
                            printJobsTableView.triggerEvaluateEnabled(row)
                        }
                    }
                }
            }
            DelegateChoice {
                column: 6
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
                column: 7
                delegate: Button {
                    id: printButton
                    text: qsTr("Print")
                    enabled: false

                    property var printJobId: model.display
                    property var myModel: model

                    Connections {
                        // printJobsTableView emits a signal to tell each print button to evaluate if it should be enabled
                        target: printJobsTableView
                        onEvaluateEnabled: function (rowChanged) {
                            let row = printButton.myModel.row
                            let do_eval = (!rowChanged) || (row == rowChanged)

                            if (do_eval) {
                                let print_jobs_model_row = printJobsModel.rows[row]

                                let cost_float = print_jobs_model_row.cost_float

                                let libki_balance = libkiBalance.currentLibkiBalance

                                let jamex_balance = paymentWindow.currentJamexMachineBalance
                                if (jamex_balance < 0)
                                    // Jamex reports a balance of -1 if not connected
                                    jamex_balance = 0

                                let has_funds_to_print = libki_balance + jamex_balance >= cost_float
                                printButton.enabled = has_funds_to_print
                            }
                        }
                    }

                    onClicked: {
                        let row = printButton.myModel.row
                        let print_jobs_model_row = printJobsModel.rows[row]

                        let cost_float = print_jobs_model_row.cost_float
                        let libki_balance = libkiBalance.balance
                        let jamex_balance = paymentWindow.currentJamexMachineBalance

                        if (jamex_balance < 0)
                            // Jamex reports a balance of -1 if not connected
                            jamex_balance = 0

                        if (cost_float > libki_balance + jamex_balance) {
                            popupDialogText.text = qsTr("Insufficient funds!")
                            popupDialog.open()
                            return
                        }

                        let selected_printer = print_jobs_model_row.printer

                        // The current balance isn't enough to pay for the job, we need to transfer some funds first
                        if (cost_float > libki_balance) {
                            let additional_funds_needed = cost_float - libki_balance

                            let username = backend.userName
                            let api_key = backend.serverApiKey
                            let server_address = backend.serverAddress
                            let url = Functions.build_add_user_funds_url(
                                    server_address, api_key, username, additional_funds_needed)

                            //backend.jamexDisableChangeCardReturn;
                            let success = paymentWindow.deductAmount(additional_funds_needed)

                            if (success === "false") {
                                popupDialogText.text = qsTr(
                                            "Unable to deduct amount from Jamex machine. Please ask staff for help")
                                popupDialog.open()
                                success = backend.jamexEnableChangeCardReturn
                            } else {
                                waitDialog.open();
                                Functions.request(url, function (o) {
                                    waitDialog.close();
                                    // translate response into an object
                                    var d = eval('new Object(' + o.responseText + ')')

                                    if (d.success) {
                                        popupDialogText.text = qsTr(
                                                    "Funds have been transferred, print job released!")
                                    } else {
                                        if (d.error === "INVALID_API_KEY") {
                                            popupDialogText.text = qsTr(
                                                        "Unable to authenticate. API key is invalid.")
                                        } else if (d.error === "INVALID_USER") {
                                            popupDialogText.text(
                                                        qsTr("Unable to find user."))
                                        } else if (d.error) {
                                            popupDialogText.text = qsTr(
                                                        "Unable to add funds. Error code: ")
                                                    + d.error
                                        } else {
                                            popupDialogText.text = qsTr(
                                                        "Unable to connect to server.")
                                        }

                                        // Return the funds, they did not get applied to their Libki funds balance
                                        backend.jamexAddAmount = additional_funds_needed
                                        success = backend.jamexAddAmount

                                        success = backend.jamexEnableChangeCardReturn
                                    }

                                    popupDialog.open()

                                    success = backend.jamexEnableChangeCardReturn

                                    if (d.success) {
                                        release_print_job(printJobId,
                                                          selected_printer)
                                    }
                                }, 'POST')
                            }
                        } else {
                            waitDialog.close()
                            release_print_job(printJobId, selected_printer)
                        }
                    }
                }
            }

            DelegateChoice {
                column: 8
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

        MyControls.Dialog {
            id: confirmCancelDialog
            title: qsTr("Cancel print job?")
            modal: true
            focus: true

            parent: Overlay.overlay

            property var printJobId

            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 3)
            standardButtons: MyControls.Dialog.Yes | MyControls.Dialog.No

            onAccepted: {
                const url = Functions.build_print_cancel_url(
                              printJobsModel.myServerAddress,
                              printJobsModel.myApiKey,
                              printJobsModel.myUsername,
                              printJobsModel.myPassword, printJobId)

                waitDialog.open()
                Functions.request(url, function (o) {
                    waitDialog.close()
                    // translate response into an object
                    var d = eval('new Object(' + o.responseText + ')')

                    if (d.success) {
                        popupDialogText.text = qsTr(
                                    "Your print job has been canceled.")
                    } else {
                        if (d.error === "INVALID_API_KEY") {
                            popupDialogText.text = qsTr(
                                        "Unable to authenticate. API key is invalid.")
                        } else if (d.error === "INVALID_USER") {
                            popupDialogText.text = qsTr("Unable to find user.")
                        } else if ( d.error ) {
                            popupDialogText.text = d.error
                        } else {
                            popupDialogText.text = qsTr("Unable to connect to server.")
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
                display: "id"
            }
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
                display: "printer"
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
                "id": qsTr("ID"),
                "copies": qsTr("Copies"),
                "print_file_id": qsTr("Preview"),
                "pages": qsTr("Pages"),
                "print_job_id": "",
                "cancel_print_job_id": "",
                "created_on": qsTr("Created on"),
                "printer": qsTr("Printer"),
                "cost": qsTr("Cost")
            }

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
            }

            function refreshPrintJobsTable() {
                var xhr = new XMLHttpRequest
                var url = urlTemplate.arg(myServerAddress).arg(myApiKey).arg(
                            myUsername).arg(myPassword)
                xhr.open("GET", url)
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if ( ! xhr.responseText ) return
                        let data = JSON.parse(xhr.responseText)

                        printJobsModel.clear()
                        printJobsModel.appendRow(headerRow)

                        let print_jobs = data["print_jobs"]
                        printJobsTableView.printJobs = print_jobs

                        let printers = data["printers"]
                        printJobsTableView.printers = printers

                        for (var i in print_jobs) {
                            let copies = print_jobs[i].copies
                            let created_on = print_jobs[i].created_on
                            let pages = print_jobs[i].pages
                            let print_file_id = print_jobs[i].print_file_id
                            let print_job_id = print_jobs[i].print_job_id
                            let printer = print_jobs[i].printer
                            let print_job = print_jobs[i]
                            let printer_data = printers[printer]
                            let cost_per_page = parseFloat(
                                    printer_data['cost_per_page'])
                            let cost_float = copies * pages * cost_per_page
                            let cost = cost_float.toFixed(2)

                            let libki_balance = libkiBalance.currentLibkiBalance

                            let jamex_balance = paymentWindow.currentJamexMachineBalance
                            if (jamex_balance < 0)
                                // Jamex reports a balance of -1 if not connected
                                jamex_balance = 0

                            let row_data = {
                                "id": print_job_id,
                                "copies": copies,
                                "pages": pages,
                                "cost_per_page": cost_per_page,
                                "print_file_id": print_file_id,
                                "pages": pages,
                                "print_job_id": print_job_id,
                                "cancel_print_job_id": print_job_id,
                                "created_on": created_on,
                                "printer": printer,
                                "cost": qsTr("$") + cost,
                                "cost_float": cost_float,
                                "print_job": print_jobs[i],
                                "printers": printers
                            }
                            printJobsModel.appendRow(row_data)
                        }
                    }
                }
                xhr.send()
            }
        }
    }
}
