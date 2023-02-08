#ifndef TIMER_H
#define TIMER_H
#include <QWidget>
#include <QTimer>
#include "ui_widget.h"
#include "widget.h"
class myTimer : public QTimer
{
    Q_OBJECT
private:
    float dt=0.01;
public:
    //explicit myTimer(QWidget *parent = nullptr);

    /* 用于模拟生成实时数据的定时器 */
    QTimer* m_timer;
    float time_ref=0;
    myTimer(float delta_t);//构造函数，开启以delta_t的定时器,并开始计时
    void TimerStart();      //定时器开始计时
    void TimerStop();       //定时器停止计时
signals:
    void start_emit();
public slots:
    void slotTimeout();     //定时器超时服务函数

};

#endif // TIMER_H
