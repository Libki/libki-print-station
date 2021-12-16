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

    signal load(string username, string password, string apiKey)
    onLoad: function (username, password, apiKey) {
        printJobsModel.load(username, password, apiKey)
    }

    delegate: DelegateChooser {
        DelegateChoice {
            row: 0
            delegate: Label {
                text: model.display
                width: 200
            }
        }
        DelegateChoice {
            column: 0
            delegate: CheckBox {
                checked: model.display
                onToggled: model.display = checked
            }
        }
        DelegateChoice {
            column: 1
            delegate: SpinBox {
                value: model.display
                onValueModified: model.display = value
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

        signal load(string username, string password, string apiKey)
        onLoad: function (username, password, apiKey) {
            console.log("USERNAME: " + username)
            console.log("PASSWORD: " + password)
            console.log("API: " + apiKey)
            model.appendRow({
                "copies": 1,
                "print_file_id": 25,
                "pages": 1,
                "print_job_id": 34,
                "created_on": "2021-11-17T13:06:17"
                            })
        }

        property var headerRow: {
            "copies": "Copies",
            "print_file_id": "Preview",
            "pages": "Pages",
            "print_job_id": "Release",
            "created_on": "Created on"
        }

        // Each row is one type of fruit that can be ordered
        rows: [
            headerRow, {
                "copies": 1,
                "print_file_id": 25,
                "pages": 1,
                "print_job_id": 34,
                "created_on": "2021-11-17T13:06:17"
            }, {
                "pages": 1,
                "print_job_id": 33,
                "created_on": "2021-11-17T13:06:12",
                "copies": 1,
                "print_file_id": 24
            }, {
                "pages": 1,
                "print_job_id": 32,
                "created_on": "2021-11-17T12:46:35",
                "print_file_id": 23,
                "copies": 1
            }, {
                "pages": 1,
                "print_job_id": 31,
                "created_on": "2021-11-17T11:53:26",
                "print_file_id": 22,
                "copies": 1
            }, {
                "print_file_id": 21,
                "copies": 1,
                "pages": 1,
                "print_job_id": 30,
                "created_on": "2021-11-17T11:52:23"
            }, {
                "created_on": "2021-11-17T11:41:57",
                "pages": 1,
                "print_job_id": 29,
                "copies": 1,
                "print_file_id": 20
            }]
    }
}
