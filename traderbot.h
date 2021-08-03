#ifndef TRADERBOT_H
#define TRADERBOT_H

#include <QObject>
#include <QWebSocket>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <mutex>
#include <shared_mutex>
#include "tcpserver.h"
//#include "neuralnetwork.h"


class TraderBot : public QObject
{
    Q_OBJECT
public:
    explicit TraderBot(QObject *parent = nullptr);

    Q_INVOKABLE QStringList getTradesForId(int traderId);

public slots:
    void connectToExchange();
    void subscribeToTrades(const QString &tradeSymbol);
    void enableTraderTracking(bool enable = true);

private slots:
     void onSocketError(QAbstractSocket::SocketError error);
     void onConnectedToExhange();
     void onSocketMessageReceived(QString message);
     void addTradeToMap(QJsonObject trade);


signals:
     void exchangeConnectionStateChanged(bool connected);
     void newTrade(QString trade);

     void prediction(float prediction);

private:
    QWebSocket *m_webSocket;

    mutable std::shared_mutex m_traderMapMutex;
    QMap<int, QString> m_traderIdMap;
    bool m_enableTraderTracking = false;

  //  Perceptron m_perceptron;

};

#endif // TRADERBOT_H
