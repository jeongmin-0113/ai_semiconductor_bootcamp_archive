/*
 * event.c
 *
 *  Created on: 2026. 11. 10.
 *      Author: kccistc
 */
#include "event.h"
#include "../../../driver/button/button.h"

button_t btn_runstop, btn_clear;

void event_init() {
	btn_status = BTN_NO; // init
	button_init(&btn_runstop, GPIOC, GPIO_PIN_0);
	button_init(&btn_clear, GPIOC, GPIO_PIN_1);
}

void event_task() {
	if (button_getState(&btn_runstop) == ACT_RELEASE) {
		btn_status = BTN_RUN_STOP;
	} else if (button_getState(&btn_clear) == ACT_RELEASE) {
		btn_status = BTN_CLEAR;
	}
}
