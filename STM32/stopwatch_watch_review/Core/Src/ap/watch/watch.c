/*
 * watch.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "watch.h"

static void Watch_incHour();
static void Watch_incMin();
static void Watch_incSec();
static void Watch_incMsec();

static watch_t watch_data;

//static uint16_t watch_counter = 0;

extern TIM_HandleTypeDef htim4;

//void Watch_setCounter(uint16_t t) {
//	watch_counter = t;
//}

watch_t* Watch_getCounter() {
	return &watch_data;
}

static void Watch_incMsec() {
	if (watch_data.msec != 99) {
		watch_data.msec++;
	} else {
		watch_data.msec = 0;
		Watch_incSec();
	}
}

static void Watch_incSec() {
	if (watch_data.sec != 59) {
		watch_data.sec++;
	} else {
		watch_data.sec = 0;
		Watch_incMin();
	}
}

static void Watch_incMin() {
	if (watch_data.min != 59) {
		watch_data.min++;
	} else {
		watch_data.min = 0;
		Watch_incHour();
	}
}

static void Watch_incHour() {
	if (watch_data.hour != 23) {
		watch_data.hour++;
	} else {
		watch_data.hour = 0;
	}
}

void Watch_init() {
	watch_data.hour = 0;
	watch_data.min = 0;
	watch_data.sec = 0;
	watch_data.msec = 0;

	HAL_TIM_Base_Start_IT(&htim4);
}

static void Watch_dispTime() {
	uint16_t num;
	num = (watch_data.min * 100) + watch_data.sec;
	fnd_set_num(num);

	if (watch_data.msec < 50) { // 0.5초마다 dp 깜빡이기
		fnd_setDp(FND_DIGIT_2);
	} else {
		fnd_resetDp(FND_DIGIT_2);
	}
}

// use in isr
void Watch_ISR() {
	Watch_incMsec();
}

// use in ap main
void Watch_task() {
	Watch_dispTime();
}
