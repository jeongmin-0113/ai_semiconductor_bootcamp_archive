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

void Watch_incCounter();
void Watch_init();
uint16_t Watch_getCounter();
void Watch_task();

#endif /* SRC_AP_WATCH_WATCH_H_ */
