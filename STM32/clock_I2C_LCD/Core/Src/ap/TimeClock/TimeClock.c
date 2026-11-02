/*
 * TimeClock.c
 *
 *  Created on: 2026. 10. 19.
 *      Author: rhoblack
 */
#include "TimeClock.h"
#include "../../driver/fnd/fnd.h"

static TimeClock_t timeClockData; // 중심 데이터

TimeClock_t* TimeClock_getTimeData() {
	return &timeClockData;
}

void TimeClock_init(void)
{
	timeClockData.hour = 0;
	timeClockData.min = 0;
	timeClockData.sec = 0;
	timeClockData.msec = 0;
}

static void TimeClock_incMSec(void)
{
	if (timeClockData.msec < 99) {
		timeClockData.msec++;
		return;
	}
	timeClockData.msec = 0;
	if (timeClockData.sec < 59) {
		timeClockData.sec++;
		return;
	}
	timeClockData.sec = 0;
	if (timeClockData.min < 59) {
		timeClockData.min++;
		return;
	}
	timeClockData.min = 0;
	if (timeClockData.hour < 23) {
		timeClockData.hour++;
		return;
	}
	timeClockData.hour = 0;
}

void TimeClock_ISR(void)
{
	TimeClock_incMSec();
}

void TimeClock_task(void)
{

}









