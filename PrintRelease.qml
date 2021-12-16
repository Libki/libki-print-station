import QtQuick 2.12
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls 2.5
import QtQuick.Controls

TableView {
    id: printJobsTable

    anchors.fill: parent
    topMargin: 10
    columnSpacing: 10
    rowSpacing: 10

    signal load(string username, string password, string apiKey, string serverAddress)
    onLoad: function (username, password, apiKey, serverAddress) {
        printJobsModel.load(username, password, apiKey, serverAddress)
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
            column: 3
            delegate: Button {
                text: "Preview"
                property var printFileId: model.display
                onClicked: {
                    console.log("PREVIEW: " + printFileId)
                }
            }
        }
        DelegateChoice {
            column: 4
            delegate: Button {
                text: "Print"
                property var printJobId: model.display
                onClicked: {
                    console.log("PRINT: " + printJobId)
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
            display: "print_file_id"
        }
        TableModelColumn {
            display: "print_job_id"
        }

        property var headerRow: {
            "copies": qsTr("Copies"),
            "print_file_id": qsTr("Preview"),
            "pages": qsTr("Pages"),
            "print_job_id": qsTr("Release"),
            "created_on": qsTr("Created on")
        }

        property string urlTemplate: "%1/api/jamex/v1_0/print_jobs?api_key=%2&username=%3&password=%4"

        signal load(string username, string password, string apiKey, string serverAddress)
        onLoad: function (username, password, apiKey, serverAddress) {
            console.log("USERNAME: " + username)
            console.log("PASSWORD: " + password)
            console.log("API: " + apiKey)
            console.log("SERVER ADDRESS: " + serverAddress)
            var xhr = new XMLHttpRequest
            var url = urlTemplate.arg(serverAddress).arg(apiKey).arg(
                        username).arg(password)
            console.log("URL: " + url)
            xhr.open("GET", url)
            xhr.onreadystatechange = function () {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var data = JSON.parse(xhr.responseText)
                    console.log(data)
                    model.clear()
                    printJobsModel.appendRow(headerRow)
                    for (var i in data) {
                        console.log(data[i])
                        printJobsModel.appendRow(data[i])
                    }
                }
            }
            xhr.send()
        }
    }
}
