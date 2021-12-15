import QtQuick 2.12
import Qt.labs.qmlmodels 1.0
import QtQuick.Controls 2.5

    TableView {
        anchors.fill: parent
        columnSpacing: 1
        rowSpacing: 1
        boundsBehavior: Flickable.StopAtBounds

        model: TableModel {
            TableModelColumn { display: "checked" }
            TableModelColumn { display: "amount" }
            TableModelColumn { display: "fruitType" }
            TableModelColumn { display: "fruitName" }
            TableModelColumn { display: "fruitPrice" }

            // Each row is one type of fruit that can be ordered
            rows: [
                {
                    // Each property is one cell/column.
                    checked: "ACK",
                    amount: 1,
                    fruitType: "Apple",
                    fruitName: "Granny Smith",
                    fruitPrice: 1.50
                },
                {
                    checked: true,
                    amount: 4,
                    fruitType: "Orange",
                    fruitName: "Navel",
                    fruitPrice: 2.50
                },
                {
                    checked: false,
                    amount: 1,
                    fruitType: "Banana",
                    fruitName: "Cavendish",
                    fruitPrice: 3.50
                }
            ]
        }
        delegate: DelegateChooser {
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
    }
