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

void Stopwatch_init(void);
void Stopwatch_Task(void);
uint16_t Stopwatch_getCounter();
void Stopwatch_timer();

#endif /* SRC_AP_STOPWATCH_STOPWATCH_H_ */
