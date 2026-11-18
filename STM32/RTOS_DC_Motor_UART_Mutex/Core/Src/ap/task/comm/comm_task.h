/*
 * comm_task.h
 *
 *  Created on: 2026. 11. 12.
 *      Author: kccistc
 */

#ifndef SRC_AP_TASK_COMM_COMM_TASK_H_
#define SRC_AP_TASK_COMM_COMM_TASK_H_

#include "../../message.h"

typedef struct {
	comm_status_t status;
	int speed;
} comm_data_t;

void comm_task_init();
void comm_task();


#endif /* SRC_AP_TASK_COMM_COMM_TASK_H_ */
