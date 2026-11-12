/*
 * joystick.h
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_JOYSTICK_JOYSTICK_H_
#define SRC_DRIVER_JOYSTICK_JOYSTICK_H_

#include "stm32f4xx_hal.h"

void joystick_init(ADC_HandleTypeDef* adc);
void joystick_getValue(int8_t* weightX, int8_t* weightY);

#endif /* SRC_DRIVER_JOYSTICK_JOYSTICK_H_ */
