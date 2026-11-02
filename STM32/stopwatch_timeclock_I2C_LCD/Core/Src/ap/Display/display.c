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

static led_t ledTimeClock, ledStopWatch;
static led_t ledSwRun;
static led_t ledSwStop;

void Disp_init(void) {
	led_init(&ledTimeClock, GPIOB, GPIO_PIN_15);
	led_init(&ledStopWatch, GPIOB, GPIO_PIN_14);
	led_init(&ledSwStop, GPIOB, GPIO_PIN_13);
	led_init(&ledSwRun, GPIOC, GPIO_PIN_4);
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
	Disp_showWatchTime();
}

void Disp_setStopwatchTime(time_t *pTime) {
	pStopWatchTime = pTime;
	Disp_showStopWatchTime();
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
	num = (pStopWatchTime->min % 10 * 1000) + (pStopWatchTime->sec * 10) + (pStopWatchTime->msec / 10 % 10);
	fnd_set_num(num);

	fnd_set_dp(FND_DIGIT_1, FND_DP_ON);
	fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);

	if (pStopWatchTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_3, FND_DP_ON);
	} else {
		fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
	}
}

void Disp_ISR(void) {
	fnd_show_number();
}
