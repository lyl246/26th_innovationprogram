#ifndef CAN_H
#define CAN_H
#include <QFile>
#include <QObject>
#include <qtextstream.h>
#include <QtSerialPort/QSerialPort>
#include <QtSerialPort/QSerialPortInfo>
#include <QtGlobal>
#include <string.h>
#define SerialMotor 0
#define Forcesensor 1
class myCan : public QObject
{
    Q_OBJECT
private:
    QFile file;//("C:/IOCdata/1.txt");
    QString SerialNames[2]={"COM5","COM6"};       //设置两个串口的名称,顺序为电机，力传感器
    bool FrameCheck(QByteArray recbuf);
public:  
    /* 用来记录第几组数据 */
    int filenum=1;
    bool ifSerialOpen[2]={false,false};//false表示未打开串口
    QString recbuf;
    QSerialPort *serial [2];
    /*数据：搜索，开启串口，读取发送数据、存储的函数*/
    void SearchSerial();
    void OpenClose_Serial(int SerialName);
    void ReadMotorData();
    void ReadSensorData();
    void SendData(QByteArray hexbuf);//发送8位HEX16进制数组
    void sendMessage();
    /*程序：新建txt文件，添加新数据，关闭txt文件*/
    void StartSave();
    void AddSave(float data);
    void StopSave();
signals:
    void start_addComboBox(QString portName);
    void start_showMotorPara();
    void start_showSensorPara();
};
#endif // CAN_H
