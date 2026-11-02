/*
 * distance.h
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */

#ifndef SRC_AP_SERVICE_DISTANCE_DISTANCE_H_
#define SRC_AP_SERVICE_DISTANCE_DISTANCE_H_

#include "../../../driver/SR04/SR04.h"
#include "../../../driver/button/button.h"

uint32_t dist_getDistCm();
void dist_init();
void dist_task();
void dist_ISR();

#endif /* SRC_AP_SERVICE_DISTANCE_DISTANCE_H_ */
