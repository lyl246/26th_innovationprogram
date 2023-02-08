#include "sensor.h"
#include "motor.h"
#include <string.h>
#include <stdint.h>
#include <QtGlobal>

extern myMotor motor;
//解析包中数据
void mySensor::ReadSensorPara(QByteArray recbuf){
    uint8_t buf[4];
    for(int i=0;i<=3;i++){
        QByteArray tmp=recbuf.mid(i+4,1);
        QString hexstr = tmp.toHex();
        buf[i] = uint8_t( hexstr.toInt(NULL,16));             //表示以16进制方式读取字符串
    }    
    uint32_t f=(buf[0]<<24)|(buf[1]<<16)|(buf[2]<<8)|(buf[3]);
    this->force=this->GetRealValue(buf[0],f);
}

//补码和源码转化
float mySensor::GetRealValue(uint8_t buf0, uint32_t f){
    float force=0.0;
    if ((buf0&0x80)==0){                                    //第一位是0，正数
        force=f*0.01;
    }
    else{
        uint32_t tmp=~(f-1);
        tmp=tmp&0x7fffffff;                                 //负数的补码求源码
        force=tmp*(-0.01);                                  //原码折算成float
    }
    return force;
}
