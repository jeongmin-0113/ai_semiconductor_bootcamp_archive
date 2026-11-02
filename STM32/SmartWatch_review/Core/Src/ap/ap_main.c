/*
 * ap_main.c
 *
 *  Created on: 2026. 11. 2.
 *      Author: kccistc
 */
#include "ap_main.h"

typedef enum {
	S_CALENDAR = 0,
	S_TEMP_HUMID,
	S_RULER,
	S_STOPWATCH
} smartWatch_state_t;

smartWatch_state_t smartWatch_state = S_CALENDAR;

void calendar_task() {

}

void tempHumid_task() {

}

void ruler_task() {

}

void stopwatch_task() {

}

int ap_main(void) {

	while (1) {
		timeClock_task();

		switch (smartWatch_state) {
		case S_CALENDAR:
			TimeClock_calendar_task();
			break;
		case S_TEMP_HUMID:
			tempHumid_task();
			break;
		case S_RULER:
			ruler_task();
			break;
		case S_STOPWATCH:
			stopwatch_task();
			break;
		default:
			break;
		}
	}

	return 0;
}
