/*
 * distance.c
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */
#include "distance.h"

#define start_btn_port	GPIOC
#define start_btn_pin	GPIO_PIN_0
#define trig_port		GPIOC
#define trig_pin		GPIO_PIN_5
#define echo_port		GPIOC
#define echo_pin		GPIO_PIN_6

uint32_t dist_us, dist_cm;

button_t btn_start;

extern TIM_HandleTypeDef htim10;

uint32_t dist_getDistCm() {
	return dist_cm;
}

void dist_init() {
	dist_cm = 0;
	dist_us = 0;

	button_init(&btn_start, start_btn_port, start_btn_pin);
	SR04_init(trig_port, trig_pin, echo_port, echo_pin, &htim10);
}

void dist_task() {
	static uint32_t prevTime = 0;
	echo_state_t state = SR04_getState();

	SR04_getResult(&dist_us);

	switch (state) {
	case STATE_IDLE:
		if (HAL_GetTick() - prevTime < 60) {
			return;
		}
		if (button_getState(&btn_start) != ACT_PUSH) {
			return;
		}
		prevTime = HAL_GetTick();
		SR04_start();
		break;
	case STATE_DONE:
		dist_cm = dist_us / 58;
		break;
	default:
		break;
	}
}

void dist_ISR() {
	SR04_echoISR();
}
