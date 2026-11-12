/*
 * cds.h
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_CDS_CDS_H_
#define SRC_DRIVER_CDS_CDS_H_

#include "stm32f4xx_hal.h"

void cds_init(ADC_HandleTypeDef* adc);
uint16_t cds_getPercentage();

#endif /* SRC_DRIVER_CDS_CDS_H_ */
