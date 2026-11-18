/*
 * message.h
 *
 *  Created on: 2026. 11. 12.
 *      Author: kccistc
 */

#ifndef SRC_AP_TASK_MESSAGE_H_
#define SRC_AP_TASK_MESSAGE_H_

#include "cmsis_os.h" // message 쓰기 위해 추가

extern osMessageQId BtnQueueHandle;
extern osMessageQId CommQueueHandle;
extern osMutexId lcdMutexHandle;

typedef enum {
	BTN_NO, BTN_RUN_STOP, BTN_LEFT, BTN_RIGHT
} btn_status_t;

typedef enum { COMM_NO, COMM_STOP, COMM_RUN, COMM_SPEED } comm_status_t;

#endif /* SRC_AP_TASK_MESSAGE_H_ */
