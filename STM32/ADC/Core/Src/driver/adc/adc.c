/*
 * adc.c
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */
#include "adc.h"
#include <stdint.h>
#include <stdbool.h>

#define ADC_CH_SIZE 4
#define ADC_CDS_IDX 0
#define ADC_JOY_X_IDX 2
#define ADC_JOY_Y_IDX 3

bool isRunDMA = false;
volatile uint16_t adcArr[ADC_CH_SIZE] = {0,};

void adc_init(ADC_HandleTypeDef* adc) {
	if (isRunDMA) return;
	HAL_ADC_Start_DMA(adc, (uint32_t*) adcArr, ADC_CH_SIZE); // DMA 시작
	isRunDMA = true;
}

uint16_t adc_getCds() {
	return adcArr[ADC_CDS_IDX];
}

void adc_getJoyXY(uint16_t* posX, uint16_t* posY) {
	*posX = adcArr[ADC_JOY_X_IDX];
	*posY = adcArr[ADC_JOY_Y_IDX];
}
