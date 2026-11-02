/*
 * watch.h
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */

#ifndef SRC_AP_WATCH_WATCH_H_
#define SRC_AP_WATCH_WATCH_H_

#include "../../driver/led/led.h"
#include "../../driver/button/button.h"
#include "../../driver/fnd/fnd.h"

typedef struct {
	uint8_t hour;
	uint8_t min;
	uint8_t sec;
	uint8_t msec;
} watch_t;

void Watch_init();
watch_t* Watch_getCounter();
void Watch_task();
void Watch_ISR();

#endif /* SRC_AP_WATCH_WATCH_H_ */
