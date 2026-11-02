/*
 * TimeClock.c
 *
 *  Created on: 2026. 10. 19.
 *      Author: rhoblack
 */
#include "TimeClock.h"
#include "../../../driver/DS3231/ds3231.h"
#include <stdbool.h>

ds3231_datetime_t rtc_datetime = { .date = { .year = 26, .month = 10,
		.date = 22, .day = 5 }, .time = { .hour = 11, .min = 44, .sec = 30 } };

static TimeClock_t rtc_time; // 중심 데이터
static TimeDate_t rtc_date;

bool dateFirstFlag = false;

extern I2C_HandleTypeDef hi2c1;

void TimeClock_setDateFirstFlag() {
	dateFirstFlag = true;
}

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

void TimeClock_dispTime(void) {
	char buff[30];
	sprintf(buff, "Time: %02d:%02d:%02d", rtc_time.hour, rtc_time.min,
			rtc_time.sec);
	Lcd_writeStringXY(0, 0, buff);
}

void TimeClock_dispDate(void) {
	char *day_of_week[7] = {
			"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"
	};

	char buff[30];
	sprintf(buff, "20%02d-%02d-%02d [%s]", rtc_date.year, rtc_date.month,
			rtc_date.date, day_of_week[rtc_date.day-1]);
	Lcd_writeStringXY(1, 0, buff);
}

void TimeClock_task(void) {
	static uint32_t prevTime = 0;

	if (HAL_GetTick() - prevTime < 1000 - 1) {
		return;
	}
	prevTime = HAL_GetTick();
	ds3231_getTime(&rtc_time);
	TimeClock_dispTime();

}

void TimeClock_calendar_task() {
	static uint32_t prevTime = 0;


	// 1시간 간격으로 get
	if ((HAL_GetTick() - prevTime < 3600000 - 1) & !dateFirstFlag) {
		return;
	}
	ds3231_getDate(&rtc_date);
	TimeClock_dispDate();
}
