#ifndef TCPSERVER_H
#define TCPSERVER_H

#include <QTcpServer>
#include <QTcpSocket>
#include <QSet>
#include <QMap>

class TcpServer : public QTcpServer
{
    Q_OBJECT
public:
    explicit TcpServer(QObject *parent = 0);

private slots:
    void readyRead();
    void disconnected();
    void sendUserList();

protected:
    void incomingConnection(qintptr handle) Q_DECL_OVERRIDE;

private:
    QSet<QTcpSocket*> clients;
    QMap<QTcpSocket*, QString> users;
};

#endif // TCPSERVER_H
