/*
 * temp_humid.c
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */
#include "temp_humid.h"


dht11_data_t TH_data;

void TH_init(void) {
	dht11_init(dht_port, dht_pin);
}

void TH_task(void) {
	static uint32_t prevTime = 0;
	if (HAL_GetTick() - prevTime < 2000) {
		return;
	}
	prevTime = HAL_GetTick();
	dht11_read(&TH_data);
}

void TH_getTempHumid(dht11_data_t *th) {
	*th = TH_data;
}
