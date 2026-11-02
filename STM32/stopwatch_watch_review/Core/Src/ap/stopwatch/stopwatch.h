/*
 * stopwatch.h
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */

#ifndef SRC_AP_STOPWATCH_STOPWATCH_H_
#define SRC_AP_STOPWATCH_STOPWATCH_H_

#include "../../driver/led/led.h"
#include "../../driver/button/button.h"
#include "../../driver/fnd/fnd.h"
#include "../watch/watch.h"

typedef enum {
	STOP, RUN, CLEAR
} stopwatch_t;

void Stopwatch_init(void);
void Stopwatch_Task(void);
uint16_t Stopwatch_getCounter();
void Stopwatch_timer();
stopwatch_t Stopwatch_getState();
void Stopwatch_ISR(void);

#endif /* SRC_AP_STOPWATCH_STOPWATCH_H_ */
