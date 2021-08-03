#include "traderbot.h"

#include <QThread>



TraderBot::TraderBot(QObject *parent) : QObject(parent)
{

    m_webSocket = new QWebSocket();

    connect(m_webSocket, &QWebSocket::connected, this, &TraderBot::onConnectedToExhange);
    connect(m_webSocket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(onSocketError(QAbstractSocket::SocketError)));
    connect(m_webSocket, &QWebSocket::textMessageReceived, this, &TraderBot::onSocketMessageReceived);
}

QStringList TraderBot::getTradesForId(int traderId)
{
    std::shared_lock<std::shared_mutex> lock(m_traderMapMutex);

    auto result = m_traderIdMap.values(traderId);

    qDebug() << "get id " << traderId << " found " << result;

    return result;
}

void TraderBot::connectToExchange()
{
    m_webSocket->open(QUrl("wss://stream.binance.com:9443/ws"));
}

void TraderBot::onSocketError(QAbstractSocket::SocketError error)
{
    qDebug() << error;
}

void TraderBot::onConnectedToExhange()
{
    qDebug() << "connected";
    emit exchangeConnectionStateChanged(true);
}

void TraderBot::onSocketMessageReceived(QString message)
{
    QJsonDocument response = QJsonDocument::fromJson(message.toUtf8());
    QJsonObject ob = response.object();

    QThread::msleep(1);

    if (ob.value("e") == "trade")
    {
        emit newTrade(QJsonDocument(ob).toJson());

        if (m_enableTraderTracking)
            addTradeToMap(ob);
    }
}

void TraderBot::addTradeToMap(QJsonObject trade)
{
    int buyerId = trade.value("b").toInt();
    int sellerId = trade.value("a").toInt();
    QString tradeString = QJsonDocument(trade).toJson();

    {
        std::unique_lock<std::shared_mutex> lock(m_traderMapMutex);
        m_traderIdMap.insertMulti(buyerId, tradeString);
        m_traderIdMap.insertMulti(sellerId, tradeString);

        qDebug() << "Added traderID " << buyerId;
        qDebug() << "Added traderID " << sellerId;
    }

}

void TraderBot::subscribeToTrades(const QString &tradeSymbol)
{
    QJsonObject json;

    json["method"] = QString("SUBSCRIBE");
    json["id"] = 1;
    json["params"] = QJsonArray() << QString(tradeSymbol + "@trade");

    m_webSocket->sendTextMessage(QJsonDocument(json).toJson());
}

void TraderBot::enableTraderTracking(bool enable)
{
    m_enableTraderTracking = enable;
}
