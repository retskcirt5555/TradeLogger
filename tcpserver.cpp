#include "tcpserver.h"

#include <QRegExp>
#include <QDateTime>

TcpServer::TcpServer(QObject *parent) :
    QTcpServer(parent)
{

}

void TcpServer::readyRead()
{
    QTcpSocket *client = (QTcpSocket*)sender();
    while(client->canReadLine()) {
        QString line = QString::fromUtf8(client->readLine()).trimmed();
        //qDebug() << "Read line:" << line;

        QRegExp meRegex("^/me:(.*)$");

        if(meRegex.indexIn(line) != -1) {
            QString user = meRegex.cap(1);
            users[client] = user;
            foreach(QTcpSocket *client, clients)
                client->write(QString("Server:" + user + " has joined.\n").toUtf8());
            sendUserList();
        } else if (users.contains(client)) {
            QString message = line;
            QString user = users[client];
            qDebug() << "User:" << user;
            qDebug() << "Message:" << message;

            foreach(QTcpSocket *otherClient, clients)
                otherClient->write(QString(user + ":" + message + "\n").toUtf8());
        } else {
            qWarning() << "Got bad message from client:" << client->peerAddress().toString() << line;
        }
    }
}

void TcpServer::disconnected()
{
    QTcpSocket *client = (QTcpSocket*)sender();
    qDebug() << "Client disconnected:" << client->peerAddress().toString();

    clients.remove(client);

    QString user = users[client];
    users.remove(client);

    sendUserList();
    foreach(QTcpSocket *client, clients)
        client->write(QString("Server:" + user + " has left.\n").toUtf8());
}

void TcpServer::sendUserList()
{
    QStringList userList;
    foreach(QString user, users.values())
        userList << user;

    foreach(QTcpSocket *client, clients)
        client->write(QString("/users:" + userList.join(",") + "\n").toUtf8());
}

void TcpServer::incomingConnection(qintptr handle)
{
    QTcpSocket *client = new QTcpSocket(this);
    client->setSocketDescriptor(handle);

    addPendingConnection(client);

    clients.insert(client);

    qDebug() << "New client from:" << client->peerAddress().toString() << " @ " << QDateTime::currentDateTime().toString();

    connect(client, SIGNAL(readyRead()), this, SLOT(readyRead()));
    connect(client, SIGNAL(disconnected()), this, SLOT(disconnected()));
}
