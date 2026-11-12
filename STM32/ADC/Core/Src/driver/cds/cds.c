/*
 * cds.c
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */
#include "cds.h"
#include "../adc/adc.h"

void cds_init(ADC_HandleTypeDef* adc) {
	adc_init(adc); // DMA 시작
}

// 조도 센서 값 반환 (밝을수록 높은 값)
uint16_t cds_getPercentage() {
	uint16_t value = 0;
	adc_getCds(&value);
	return 100 - (value * 100 / 4096);
}
