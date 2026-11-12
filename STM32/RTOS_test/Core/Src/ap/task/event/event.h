/*
 * event.h
 *
 *  Created on: 2026. 11. 10.
 *      Author: kccistc
 */

#ifndef SRC_AP_TASK_EVENT_EVENT_H_
#define SRC_AP_TASK_EVENT_EVENT_H_

typedef enum {
	BTN_NO, BTN_RUN_STOP, BTN_CLEAR
} btn_status_t;

extern btn_status_t btn_status;

void event_init();
void event_task();

#endif /* SRC_AP_TASK_EVENT_EVENT_H_ */
