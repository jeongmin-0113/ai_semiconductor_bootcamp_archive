/*
 * Display.c
 *
 *  Created on: 2026. 10. 20.
 *      Author: rhoblack
 */

#include "Display.h"
#include "../../../driver/fnd/fnd.h"
#include "../../../driver/led/led.h"
#include "../../../driver/lcd/lcd.h"
#include "../distance/distance.h"

enum {
	TIME_CLOCK_MODE, TEMP_HUMID_MODE, DISTANCE_MODE, STOP_WATCH_MODE
};
enum {
	STOPWATCH_STOP, STOPWATCH_RUN
};

extern I2C_HandleTypeDef hi2c1;

stopWatchTime_t *pStopWatchTime;
timeClockTime_t *pTimeClockTime;
timeClockDate_t *pTimeClockDate;
tempHumid_t *pTempHumid;
uint16_t distance_cm;
led_t ledMode1, ledMode2;
led_t ledStopWatchRun, ledStopWatchStop;

int8_t prevState = STOP_WATCH_MODE;

void Disp_init(void) {
	led_init(&ledMode1, GPIOB, GPIO_PIN_15);
	led_init(&ledMode2, GPIOB, GPIO_PIN_14);
	led_init(&ledStopWatchRun, GPIOC, GPIO_PIN_4);
	led_init(&ledStopWatchStop, GPIOB, GPIO_PIN_13);
	Lcd_init(&hi2c1);
	prevState = STOP_WATCH_MODE;
}

void Disp_setMode(int mode) {
	// 시계 -> 온습도 -> 거리 -> 스탑워치 -> 시계
	switch (mode) {
	case TIME_CLOCK_MODE:
		led_off(&ledMode1);
		led_off(&ledMode2);
		break;
	case TEMP_HUMID_MODE:
		led_off(&ledMode1);
		led_on(&ledMode2);
		break;
	case DISTANCE_MODE:
		led_on(&ledMode1);
		led_off(&ledMode2);
		break;
	case STOP_WATCH_MODE:
		led_on(&ledMode1);
		led_on(&ledMode2);
		break;
	default:
		break;
	}
}

void Disp_setTimeClockTime(timeClockTime_t *pTime, int mode) {
	pTimeClockTime = pTime;
	Disp_timeClockTime_lcd();
	if (mode == TIME_CLOCK_MODE) {
		Disp_timeClockTime();
	}
}

void Disp_setStopWatchTime(stopWatchTime_t *pTime) {
	pStopWatchTime = pTime;
	Disp_stopWatchTime();
}

void Disp_setTimeClockDate(timeClockDate_t *pDate) {
	pTimeClockDate = pDate;
	Disp_timeClockDate();
}

void Disp_stopWatchTime(void) {
	char stopwatchStr[30];
	static stopWatchTime_t prevStopwatch = { 0, };
	uint16_t num;

	num = ((pStopWatchTime->min % 10) * 1000) + (pStopWatchTime->sec * 10)
			+ (pStopWatchTime->msec / 10 % 10);
	fnd_set_num(num);

	if (pStopWatchTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_3, FND_DP_ON);
	} else {
		fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
	}

	fnd_set_dp(FND_DIGIT_1, FND_DP_ON);
	fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);

	if ((memcmp(&prevStopwatch, pStopWatchTime, sizeof(stopWatchTime_t)) != 0)
			| (prevState != STOP_WATCH_MODE)) {
		memcpy(&prevStopwatch, pStopWatchTime, sizeof(stopWatchTime_t));

		sprintf(stopwatchStr, "SW  :%02d:%02d:%02d:%02d", pStopWatchTime->hour,
				pStopWatchTime->min, pStopWatchTime->sec, pStopWatchTime->msec);
		Lcd_writeStringXY(1, 0, stopwatchStr);
		prevState = STOP_WATCH_MODE;
	}
}

void Disp_timeClockTime(void) {
	uint16_t num;

	num = (pTimeClockTime->min * 100) + pTimeClockTime->sec;
	fnd_set_num(num);

	if (pTimeClockTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_2, FND_DP_ON);
	} else {
		fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);
	}
	fnd_set_dp(FND_DIGIT_1, FND_DP_OFF);
	fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
}

void Disp_timeClockTime_lcd(void) {
	char timeStr[30];
	static timeClockTime_t prevTime = { 0, };

	if (memcmp(&prevTime, pTimeClockTime, sizeof(timeClockDate_t)) == 0) {
		return;
	}
	memcpy(&prevTime, pTimeClockTime, sizeof(timeClockDate_t));

	sprintf(timeStr, "%02d:%02d:%02d", pTimeClockTime->hour,
			pTimeClockTime->min, pTimeClockTime->sec);
	Lcd_writeStringXY(0, 0, timeStr);
}

void Disp_timeClockDate(void) {
	char dateStr[30];
	static timeClockDate_t prevDate = { 0, };

	if ((memcmp(&prevDate, pTimeClockDate, sizeof(timeClockDate_t)) != 0)
			| (prevState != TIME_CLOCK_MODE)) {
		memcpy(&prevDate, pTimeClockDate, sizeof(timeClockDate_t));

		const char *str_day[7] = { "SUN", "MON", "TUE", "WED", "THU", "FRI",
				"SAT" };

		sprintf(dateStr, "20%02d-%02d-%02d (%s)", pTimeClockDate->year,
				pTimeClockDate->month, pTimeClockDate->date,
				str_day[(pTimeClockDate->day - 1) % 7]);
		Lcd_writeStringXY(1, 0, dateStr);
		prevState = TIME_CLOCK_MODE;
	}
}

void Disp_setStopWatchState(int state) {
	if (state == STOPWATCH_RUN) {
		led_on(&ledStopWatchRun);
		led_off(&ledStopWatchStop);
	} else {
		led_off(&ledStopWatchRun);
		led_on(&ledStopWatchStop);
	}
}

void Disp_setTempHumid(tempHumid_t *pData) {
	pTempHumid = pData;
	Disp_tempHumid();
}

void Disp_tempHumid(void) {
//	static uint32_t prevTime = 0;
	char buff[30];
	static tempHumid_t prevThData = { 0, };
	uint16_t num;

	num = (pTempHumid->t_int * 100) + pTempHumid->t_dec;
	fnd_set_num(num);

	fnd_set_dp(FND_DIGIT_2, FND_DP_ON);
	fnd_set_dp(FND_DIGIT_1, FND_DP_OFF);
	fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);

//	if (HAL_GetTick() - prevTime < 1000) {
//		return;
//	}
//	prevTime = HAL_GetTick();

	if ((memcmp(&prevThData, pTempHumid, sizeof(tempHumid_t)) != 0)
			| (prevState != TEMP_HUMID_MODE)) {
		memcpy(&prevThData, pTempHumid, sizeof(tempHumid_t));
		sprintf(buff, "T:%2u.%01u'C H:%2u.%01u%%", prevThData.t_int,
				prevThData.t_dec, prevThData.h_int, prevThData.h_dec);
		Lcd_writeStringXY(1, 0, buff);
		prevState = TEMP_HUMID_MODE;
	}
}

void Disp_setDistance() {
	char buff[30];
	static uint16_t prevDist = 0;
	uint16_t num;

//	if ((prevDist != distance_cm) | (prevState != DISTANCE_MODE)) {
//		prevDist = distance_cm;
//		sprintf(buff, "distance: %3d cm", prevDist);
//		Lcd_writeStringXY(1, 0, buff);
//		prevState = DISTANCE_MODE;
//	}

	if (((distance_get(&distance_cm) == DISTANCE_OK)
			&& (prevDist != distance_cm)) | (prevState != DISTANCE_MODE)) {
		prevDist = distance_cm;
		sprintf(buff, "distance: %3d cm", prevDist);
		Lcd_writeStringXY(1, 0, buff);

		num = prevDist;
		fnd_set_num(num);

		fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);
		fnd_set_dp(FND_DIGIT_1, FND_DP_OFF);
		fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
		prevState = DISTANCE_MODE;
	}
}

void Disp_ISR(void) {
	fnd_show_number();
}

