/*
 * StopWatch.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: rhoblack
 */

#include "StopWatch.h"

static void StopWatch_stop();
static void StopWatch_run();
static void StopWatch_clear();
static void StopWatch_setState(stopWatch_state_t s);
static void StopWatch_incMSec(void);
static void StopWatch_clearTime(void);

static stopwatch_t stopWatch_data; // core data
static stopWatch_state_t stopWatch_state;

static button_t btn_run_stop;
static button_t btn_clear;

stopwatch_t* Stopwatch_getTimeData() {
	return &stopWatch_data;
}

static void StopWatch_setState(stopWatch_state_t s) {
	stopWatch_state = s;
}

stopWatch_state_t StopWatch_getState(void) {
	return stopWatch_state;
}

static void StopWatch_incMSec(void) {
	if (stopWatch_data.msec < 99) {
		stopWatch_data.msec++;
		return;
	}
	stopWatch_data.msec = 0;
	if (stopWatch_data.sec < 59) {
		stopWatch_data.sec++;
		return;
	}
	stopWatch_data.sec = 0;
	if (stopWatch_data.min < 59) {
		stopWatch_data.min++;
		return;
	}
	stopWatch_data.min = 0;
	if (stopWatch_data.hour < 23) {
		stopWatch_data.hour++;
		return;
	}
	stopWatch_data.hour = 0;
}

static void StopWatch_clearTime(void) {
	stopWatch_data.hour = 0;
	stopWatch_data.min = 0;
	stopWatch_data.sec = 0;
	stopWatch_data.msec = 0;
}

void StopWatch_init(void) {
	stopWatch_state = STOP;

	button_init(&btn_run_stop, GPIOC, GPIO_PIN_1);
	button_init(&btn_clear, GPIOC, GPIO_PIN_3);

	StopWatch_clearTime();
}

void StopWatch_task(void) {
	switch (stopWatch_state) {
	case STOP:
		StopWatch_stop();
		break;
	case RUN:
		StopWatch_run();
		break;
	case CLEAR:
		StopWatch_clear();
		break;
	default:
		StopWatch_stop();
		break;
	}

//	uint16_t num = (stopWatch_data.sec * 100) + stopWatch_data.msec;
//	fnd_set_num(num);
}

static void StopWatch_stop() {
	if (button_getState(&btn_run_stop) == ACT_PUSH) {
		StopWatch_setState(RUN);
	} else if (button_getState(&btn_clear) == ACT_RELEASE) {
		StopWatch_setState(CLEAR);
	}
}

static void StopWatch_run() {
	if (button_getState(&btn_run_stop) == ACT_PUSH) {
		StopWatch_setState(STOP);
	}
}

static void StopWatch_clear() {
	StopWatch_clearTime();
	StopWatch_setState(STOP);
}

void StopWatch_ISR(void) {
	if (stopWatch_state == RUN) {
		StopWatch_incMSec();
	}
}


