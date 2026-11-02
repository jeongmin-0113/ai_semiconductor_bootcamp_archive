/*
 * StopWatch.h
 *
 *  Created on: 2026. 10. 16.
 *      Author: rhoblack
 */

#ifndef SRC_AP_STOPWATCH_STOPWATCH_H_
#define SRC_AP_STOPWATCH_STOPWATCH_H_

#include "../../driver/button/button.h"
#include "../../driver/led/led.h"
#include "../../driver/fnd/fnd.h"

typedef struct {
	uint8_t hour;
	uint8_t min;
	uint8_t sec;
	uint8_t msec;
} stopwatch_t;

typedef enum {
	STOP, RUN, CLEAR
} stopWatch_state_t;

void StopWatch_init(void);
void StopWatch_task(void);
void StopWatch_ISR(void);
stopwatch_t* Stopwatch_getTimeData();
stopWatch_state_t StopWatch_getState(void);

#endif /* SRC_AP_STOPWATCH_STOPWATCH_H_ */
