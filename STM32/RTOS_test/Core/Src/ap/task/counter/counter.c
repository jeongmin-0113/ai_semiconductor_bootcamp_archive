/*
 * counter.c
 *
 *  Created on: 2026. 11. 10.
 *      Author: kccistc
 */
#include "counter.h"
#include "../event/event.h"
#include "../../../driver/fnd/fnd.h"

enum {
	STOP, RUN, CLEAR
};
static uint16_t number = 0;
static int state = STOP;

extern btn_status_t btn_status;

void counter_init() {
	number = 0;
	state = STOP;
}

void counter_task() {
	switch (state) {
	case STOP:
		if (btn_status == BTN_RUN_STOP) {
			state = RUN;
			btn_status = BTN_NO;
		} else if (btn_status == BTN_CLEAR) {
			state = CLEAR;
			btn_status = BTN_NO;
		}
		break;
	case RUN:
		if (btn_status == BTN_RUN_STOP) {
			state = STOP;
			btn_status = BTN_NO;
		}
		number++;
		break;
	case CLEAR:
		state = STOP;
		number = 0;
		break;
	default:
		break;
	}
	fnd_set_num(number);

}

