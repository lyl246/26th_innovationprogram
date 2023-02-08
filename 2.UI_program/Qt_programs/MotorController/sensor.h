#ifndef SENSOR_H
#define SENSOR_H

#include <string.h>
#include<stdint.h>
#include <QtGlobal>

class mySensor{

private:
    float GetRealValue(uint8_t buf0, uint32_t f);
public:
    float force=0.0;
    void ReadSensorPara(QByteArray recbuf);

};
#endif // SENSOR_H
