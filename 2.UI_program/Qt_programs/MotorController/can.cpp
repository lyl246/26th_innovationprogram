#include "can.h"
#include "motor.h"
#include "ref.h"
#include "sensor.h"
#include <QString>
 #include <QtCore/QString>
#include <qstring>

extern myMotor motor;extern myRef ref;extern mySensor sensor;

QByteArray Sensorbuf;//CAN 读取力传感器的串口数据缓冲区

//查找可用的串口
void myCan::SearchSerial(){
    foreach (const QSerialPortInfo &info,QSerialPortInfo::availablePorts())
    {
        QSerialPort serial;
        serial.setPort(info);
        if(serial.open(QIODevice::ReadWrite))
        {
            this->start_addComboBox(serial.portName());
            serial.close();
        }
    }
}

void myCan::OpenClose_Serial(int SerialName){
    if(ifSerialOpen[SerialName] == false )
    {
        serial[SerialName] = new QSerialPort;
        serial[SerialName]->setPortName(this->SerialNames[SerialName]);//设置串口名
        serial[SerialName]->open(QIODevice::ReadWrite);//打开串口
        serial[SerialName]->setBaudRate(QSerialPort::Baud115200);//设置波特率为115200
        serial[SerialName]->setDataBits(QSerialPort::Data8);//设置数据位8
        serial[SerialName]->setParity(QSerialPort::NoParity);//设置校验位
        serial[SerialName]->setStopBits(QSerialPort::OneStop);//设置停止位
        serial[SerialName]->setFlowControl(QSerialPort::NoFlowControl);//设置为无流控制
        //连接信号槽函数
        if(SerialName==0)
        {QObject::connect(serial[SerialName],&QSerialPort::readyRead,this,&ReadMotorData);}
        else if(SerialName==1)
        {QObject::connect(serial[SerialName],&QSerialPort::readyRead,this,&ReadSensorData);}
    }
    else
    {
        //关闭串口
        serial[SerialName]->clear();
        serial[SerialName]->close();
        serial[SerialName]->deleteLater();
    }
    ifSerialOpen[SerialName]=!ifSerialOpen[SerialName];
}
//CAN 读取串口数据
void myCan::ReadMotorData(){
    QByteArray buf;
    buf = serial[SerialMotor]->readAll();
    motor.ReadMotorPara(buf);
    this->start_showMotorPara();
    buf.clear();
}

void myCan::ReadSensorData(){
    QByteArray tmpHead; tmpHead.resize(4); tmpHead[0]=0xfe; tmpHead[1]=0x01; tmpHead[2]=0x51;  tmpHead[3]=0x00;
    QByteArray buf = serial[Forcesensor]->readAll();    //添加循环，，并按头尾校验
    Sensorbuf.append(buf);                              //逐个拼接到通信序列中，找帧头
    int headpos=Sensorbuf.indexOf(tmpHead);             //按帧头的位置截取数据
    if(this->FrameCheck(Sensorbuf.mid(headpos,12))){    //若校验成功
        sensor.ReadSensorPara(Sensorbuf.mid(headpos,12));               //添加并校验成功
        this->start_showSensorPara();
        Sensorbuf.remove(0,headpos+12);                    //用remove，把序列中已解析的数据删除，
    }
    if(Sensorbuf.size()>=100){
        Sensorbuf.clear();
        //qDebug()<<"Too many data without useful infor";   //若太久没有找到有用的帧头，则清空内容并qDebug报错
    }
}
//帧头帧尾检验
bool myCan::FrameCheck(QByteArray recbuf){
    QByteArray PackHeader=recbuf.mid(0,4);
    QByteArray PackEnd=recbuf.mid(8,4);
    QByteArray tmpHead; tmpHead.resize(4); tmpHead[0]=0xfe; tmpHead[1]=0x01; tmpHead[2]=0x51;  tmpHead[3]=0x00;
    QByteArray tmpEnd;  tmpEnd.resize(4);  tmpEnd[0]=0xcf;  tmpEnd[1]=0xfc;  tmpEnd[2]=0xcc;   tmpEnd[3]=0xff;
    if((PackHeader==tmpHead)&& (PackEnd==tmpEnd))
    {   //qDebug()<<"true!";
        return true;}
    else
    {   //qDebug()<<"false!";
        return false;}
}
//给电机发送数据
void myCan::SendData(QByteArray hexbuf){
    serial[SerialMotor]->write(hexbuf);//QByteArray
}

//打开文件，准备写入操作
void myCan::StartSave(){
    //QString tmpfilename="C:/IOCData/"+ QString::number(this->filenum,10,0) +".txt";
    //保存数据，还没写完，要把maxtorque弄成变量，浮点——>QString
    QString tmpfilename="C:/IOCData/21/"+QString::number(ref.Max_Torque,'f',1) + "/"+QString::number(this->filenum,10,0) +".txt";
    this->file.setFileName(tmpfilename);
    this->file.open(QIODevice::WriteOnly|QIODevice::Text);
    this->filenum++;                    //组数增加一
}
//对已打开的文件进行写入操作，此处写入两个变量
void myCan::AddSave(float data){
    std::string res2 = std::to_string(data);   //传入信号转为string类型
    const char* res3 = res2.c_str();           //char*
    this->file.write(res3);
    file.write(",");
}
//关闭文件，停止写入操作（add仍在继续，只是无效）
void myCan::StopSave(){
    file.write("\n");
    this->file.close();
}
//“添加电机串口名”的信号函数，发信号给widget类中的槽函数
void start_addcombobox(int portName){
}
//“显示力传感器数据”的信号函数，发信号给widget类中的槽函数
void start_showSensorPara(){
}
//“显示电机数据”的信号函数，发信号给widget类中的槽函数
void start_showMotorPara(){
}
