/*
 * watch.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "watch.h"

static uint16_t watch_counter = 0;

extern TIM_HandleTypeDef htim2;

void Watch_setCounter(uint16_t t) {
	watch_counter = t;
}

uint16_t Watch_getCounter() {
	return watch_counter;
}

void Watch_incCounter() {
	if (watch_counter != 3599) {
		watch_counter++;
	} else {
		watch_counter = 0;
	}
}

void Watch_init() {
	watch_counter = 0;

	HAL_TIM_Base_Start_IT(&htim2);
}

void Watch_task() {
	fnd_set_num(watch_counter);
}
