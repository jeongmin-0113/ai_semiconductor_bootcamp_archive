/*
 * TimeClock.c
 *
 *  Created on: 2026. 10. 19.
 *      Author: rhoblack
 */
#include "TimeClock.h"
#include "../../driver/fnd/fnd.h"
#include "../../driver/DS3231/ds3231.h"

ds3231_datetime_t rtc_datetime = { .date = { .year = 26, .month = 10,
		.date = 22, .day = 5 }, .time = { .hour = 11, .min = 44, .sec = 30 } };

static TimeClock_t timeClockData; // 중심 데이터
static TimeDate_t timeDateData;

extern I2C_HandleTypeDef hi2c1;

void TimeClock_init(void) {
	ds3231_init(&hi2c1);
	ds3231_getDateTime(&rtc_datetime);

	timeClockData.hour = rtc_datetime.time.hour;
	timeClockData.min = rtc_datetime.time.min;
	timeClockData.sec = rtc_datetime.time.sec;
	timeClockData.msec = 0;

	timeDateData.day = rtc_datetime.date.day;
	timeDateData.date = rtc_datetime.date.date;
	timeDateData.month = rtc_datetime.date.month;
	timeDateData.year = rtc_datetime.date.year;
}

TimeClock_t* TimeClock_getTimeData(void) {

	timeClockData.hour = rtc_datetime.time.hour;
	timeClockData.min = rtc_datetime.time.min;
	timeClockData.sec = rtc_datetime.time.sec;

	return &timeClockData;
}

TimeDate_t* TimeClock_getDateData(void) {

	timeDateData.day = rtc_datetime.date.day;
	timeDateData.date = rtc_datetime.date.date;
	timeDateData.month = rtc_datetime.date.month;
	timeDateData.year = rtc_datetime.date.year;

	return &timeDateData;
}

static void TimeClock_incMSec(void) {
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

void TimeClock_ISR(void) {
	TimeClock_incMSec();
}

void TimeClock_task(void) {
	static int8_t prevSec = 0;
	static int8_t prevHour = 0;

	if (timeClockData.sec == prevSec) {
		return;
	}
	prevSec = timeClockData.sec;
	ds3231_getTime(&rtc_datetime.time);

	if (timeClockData.hour == prevHour) {
		return;
	}
	prevHour = timeClockData.hour;
	ds3231_getDate(&rtc_datetime.date);
}

