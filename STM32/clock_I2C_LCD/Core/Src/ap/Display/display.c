/*
 * display.c
 *
 *  Created on: 2026. 10. 20.
 *      Author: kccistc
 */
#include "display.h"

enum {
	TIME_CLOCK_MODE, STOP_WATCH_MODE
};

typedef enum {
	STOPWATCH_STOP, STOPWATCH_RUN, STOPWATCH_CLEAR
} stopWatch_state_t;

time_t *pStopWatchTime;
time_t *pWatchTime;

char watchBuff[30];
char stopwatchBuff[30];

static led_t ledTimeClock, ledStopWatch;
static led_t ledSwRun;
static led_t ledSwStop;

void Disp_init(void) {
	led_init(&ledTimeClock, GPIOB, GPIO_PIN_15);
	led_init(&ledStopWatch, GPIOB, GPIO_PIN_14);
	led_init(&ledSwStop, GPIOB, GPIO_PIN_13);
	led_init(&ledSwRun, GPIOC, GPIO_PIN_4);

	Lcd_init();
	sprintf(watchBuff, "Time:00:00:00:00");
	sprintf(stopwatchBuff, "SW  :00:00:00:00");
	Lcd_writeStringXY(0, 0, watchBuff);
	Lcd_writeStringXY(1, 0, stopwatchBuff);
}

void Disp_setMode(int mode) {
	if (mode == TIME_CLOCK_MODE) {
		led_on(&ledTimeClock);
		led_off(&ledStopWatch);
	} else {
		led_off(&ledTimeClock);
		led_on(&ledStopWatch);
	}
}

void Disp_setStopWatchState(int state) {
	if (state == STOPWATCH_RUN) {
		led_off(&ledSwStop);
		led_on(&ledSwRun);
	} else {
		led_on(&ledSwStop);
		led_off(&ledSwRun);
	}
}

void Disp_setWatchTime(time_t *pTime) {
	pWatchTime = pTime;
//	Disp_showWatchTime();
}

void Disp_setStopwatchTime(time_t *pTime) {
	pStopWatchTime = pTime;
//	Disp_showStopWatchTime();
}

void Disp_showWatchTime(void) {
	uint16_t num = (pWatchTime->min * 100) + pWatchTime->sec;
	fnd_set_num(num);

	fnd_set_dp(FND_DIGIT_1, FND_DP_OFF);
	fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);

	if (pWatchTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_2, FND_DP_ON);
	} else {
		fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);
	}
}

void Disp_showStopWatchTime(void) {
	uint16_t num;
//	num = (pStopWatchTime->sec * 100) + pStopWatchTime->msec;
	num = (pStopWatchTime->min % 10 * 1000) + (pStopWatchTime->sec * 10)
			+ (pStopWatchTime->msec / 10 % 10);
	fnd_set_num(num);

	fnd_set_dp(FND_DIGIT_1, FND_DP_ON);
	fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);

	if (pStopWatchTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_3, FND_DP_ON);
	} else {
		fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
	}
}

void Disp_updateLcd(void) {
	char watchTmpBuff[30];
	char stopwatchTmpBuff[30];

	sprintf(watchTmpBuff, "Time:%02d:%02d:%02d:%02d", pWatchTime->hour,
			pWatchTime->min, pWatchTime->sec, pWatchTime->msec);

	sprintf(stopwatchTmpBuff, "SW  :%02d:%02d:%02d:%02d", pStopWatchTime->hour,
			pStopWatchTime->min, pStopWatchTime->sec, pStopWatchTime->msec);

	if (strcmp(watchBuff, watchTmpBuff) != 0) {
		strcpy(watchBuff, watchTmpBuff);
		Lcd_writeStringXY(0, 0, watchBuff);
	}
	if (strcmp(stopwatchBuff, stopwatchTmpBuff) != 0) {
		strcpy(stopwatchBuff, stopwatchTmpBuff);
		Lcd_writeStringXY(1, 0, stopwatchBuff);
	}
}

void Disp_ISR(void) {
	fnd_show_number();
}
