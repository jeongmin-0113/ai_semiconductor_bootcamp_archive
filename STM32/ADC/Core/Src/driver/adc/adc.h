/*
 * adc.h
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_ADC_ADC_H_
#define SRC_DRIVER_ADC_ADC_H_

#include "stm32f4xx_hal.h"

void adc_init(ADC_HandleTypeDef* adc);
uint16_t adc_getCds();
void adc_getJoyXY(uint16_t* posX, uint16_t* poxY);

#endif /* SRC_DRIVER_ADC_ADC_H_ */
