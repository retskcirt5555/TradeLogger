import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import TraderBot 1.0
import QtCharts 2.3

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Retskcirts TraderBot")

    Rectangle {
        id: background
        color: "#323242"
        anchors.fill: parent
    }

    Timer {
        id: tradeAddTimer

        running: false
        repeat: false
        interval: 10
        property var lastTrade

        onTriggered: {
            traderBot.addToChart(lastTrade)
        }
    }

    TraderBot {
        id: traderBot

        property var startTime: 0
        property var lastTime
        property var timeView: timeSlider.value

        onExchangeConnectionStateChanged: connectButton.text = connected ? "Connected" : "Connect"
        onNewTrade: {

            if (tradeAddTimer.running)
                return;

            tradeAddTimer.lastTrade = trade;
                tradeAddTimer.start();
        }




        function addToChart(trade)
        {
            var row = JSON.parse(trade);
            testModel.insert(0, row);

            var price = row["p"];
            var time = row["t"];
            var quantity = row["q"];
           // var marketMaker = row["m"];

            livePriceLine.append(time, price);
            quantitySeries.append(time, quantity);

            if (startTime == 0)
            {
                startTime = time;
                priceAxis.max = price;
                priceAxis.min = price;
                quantityAxis.min = quantity;
                quantityAxis.max = quantity;
            }

            startTime = time - timeView;

            lastTime = time;

            if (price > priceAxis.max)
                priceAxis.max = price;
            if (price < priceAxis.min)
                priceAxis.min = price;
            if (quantity > quantityAxis.max)
                quantityAxis.max = quantity;
            if (quantity < quantityAxis.min)
                quantityAxis.min = quantity;


            if (testModel.count < timeSlider.to)
            {
               // chart.update();
                return;
            }

            testModel.remove(testModel.count - 1);
            livePriceLine.removePoints(0, 1);
            quantitySeries.removePoints(0, 1);

           // chart.update();

        }

    }

    ListModel {
        id: testModel

    }

    ListModel {
        id: tradesForIdModel

        function updateTradeList()
        {
            clear();
            var tradeList = traderBot.getTradesForId(searchField.text);

            for (var i = 0; i < tradeList.length; ++i) {
                insert(0, JSON.parse(tradeList[i]));
                console.log(tradeList[i]);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            id: topBar

            Button {
                id: connectButton
                text: "Connect"
                onClicked: traderBot.connectToExchange();
            }

            RowLayout {
                TextField {
                    id: symbolText
                }

                Button {
                    id: subscribeToVeChain
                    text: "Subscribe to symbol"
                    onClicked: traderBot.subscribeToTrades(symbolText.text);
                }
            }

            RowLayout {
                TextField {
                    id: searchField
                }

                Button {
                    id: searchButton
                    text: "Search"
                    onClicked: {
                        tradesForIdModel.updateTradeList();
                    }
                }
            }
        }

        Label {
            id: timeSliderValue
            text: timeSlider.value
        }

        Slider {
            id: timeSlider
            implicitWidth: 300
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            from: 10
            to: 100000
            value: 100
            stepSize: 1

        }

        ChartView {
            id: chart

            implicitWidth: 600
            implicitHeight: 400
            Layout.fillWidth: true
            Layout.fillHeight: true
            antialiasing: true

            theme: ChartView.ChartThemeDark


            ValueAxis {
                id: priceAxis
            }

            ValueAxis {
                id: quantityAxis
            }

            ValueAxis {
                id: timeAxis

                min: traderBot.startTime
                max: traderBot.lastTime

            }

            LineSeries {
                id: livePriceLine
                name: "Live Price"
                axisX: timeAxis
                axisY: priceAxis

//                markerSize: 2
//                borderWidth: 0
            }

           LineSeries {
                id: quantitySeries

                name: "Quantity"
                axisX: timeAxis
                axisY: quantityAxis
            }
        }

        RowLayout {
            ListView {
                id: list
                implicitWidth: 300
                implicitHeight: 300
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 32
                model: testModel
                spacing: 10

                ScrollBar.vertical: ScrollBar {}
//                highlight: Rectangle {
//                    // width: 180; height: 40
//                    color: "lightsteelblue"; radius: 5
//                    y: list.currentItem.y
////                    Behavior on y {
////                        SpringAnimation {
////                            spring: 3
////                            damping: 0.2
////                        }
////                    }
//                }

                focus: true
                highlightFollowsCurrentItem: true

//                add: Transition {
//                    NumberAnimation { properties: "x"; from: 100; duration: 500; easing.type: Easing.OutBack }
//                }

//                move: Transition {
//                    NumberAnimation { properties: "x,y"; duration: 500; easing.type: Easing.OutBack }
//                }

                //            addDisplaced: Transition {
                //                NumberAnimation { properties: "x,y"; duration: 1000 }
                //            }


                delegate: Rectangle {
                    implicitWidth: childrenRect.width + 10
                    implicitHeight: childrenRect.height + 10

                    color: "transparent"
                    border.width: 1
                    //radius: 6
                    border.color: m ? "limegreen" : "gold"

                    RowLayout {
                        x: 5
                        y: 5

                        ColumnLayout {
                            Label {
                                text: "Price"
                                color: "grey"
                            }
                            Label {
                                text: p
                                color: "white"
                                font.bold: true
                                font.pointSize: 12
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Quantity"
                                color: "grey"
                            }
                            Label {
                                text: q
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Market Maker"
                                color: "grey"
                            }
                            Label {
                                text: m
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Buyer ID"
                                color: "grey"
                            }
                            Label {
                                text: b
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Seller ID"
                                color: "grey"
                            }
                            Label {
                                text: a
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Trade Time"
                                color: "grey"
                            }
                            Label {
                                text: new Date(T)
                                color: "white"
                            }
                        }
                    }
                }
            }



            ListView {
                id: idTradeList
                implicitWidth: 300
                implicitHeight: 300
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 32
                model: tradesForIdModel
                spacing: 10

                ScrollBar.vertical: ScrollBar {}
                highlight: Rectangle {
                    // width: 180; height: 40
                    color: "lightsteelblue"; radius: 5
                    y: idTradeList.currentItem.y
                    Behavior on y {
                        SpringAnimation {
                            spring: 3
                            damping: 0.2
                        }
                    }
                }

                focus: true
                highlightFollowsCurrentItem: true

//                add: Transition {
//                    NumberAnimation { properties: "x"; from: 100; duration: 500; easing.type: Easing.OutBack }
//                }

//                move: Transition {
//                    NumberAnimation { properties: "x,y"; duration: 500 }
//                }

                //            addDisplaced: Transition {
                //                NumberAnimation { properties: "x,y"; duration: 1000 }
                //            }


                delegate: Rectangle {
                    implicitWidth: childrenRect.width + 10
                    implicitHeight: childrenRect.height + 10

                    color: "transparent"
                    border.width: 1
                    //radius: 6
                    border.color: m ? "limegreen" : "gold"

                    RowLayout {
                        x: 5
                        y: 5

                        ColumnLayout {
                            Label {
                                text: "Price"
                                color: "grey"
                            }
                            Label {
                                text: p
                                color: "white"
                                font.bold: true
                                font.pointSize: 12
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Quantity"
                                color: "grey"
                            }
                            Label {
                                text: q
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Market Maker"
                                color: "grey"
                            }
                            Label {
                                text: m
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Buyer ID"
                                color: "grey"
                            }
                            Label {
                                text: b
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Seller ID"
                                color: "grey"
                            }
                            Label {
                                text: a
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Label {
                                text: "Trade Time"
                                color: "grey"
                            }
                            Label {
                                text: new Date(T)
                                color: "white"
                            }
                        }
                    }
                }
            }
        }
    }
}
