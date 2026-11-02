/*
 * temphum.c
 *
 *  Created on: 2026. 10. 27.
 *      Author: kccistc
 */
#include "temphum.h"

dht11_data_t measure_data;

void temphum_init(void) {
	measure_data.h_dec = 0;
	measure_data.h_int = 0;
	measure_data.t_dec = 0;
	measure_data.t_int = 0;
}


static void temphum_measure(void) {
	dht11_read(&measure_data);
}

dht11_data_t* temphum_getData(uint8_t sec) {
	if ((sec % 2) == 1) {
		return &measure_data;
	}

	temphum_measure();
	return &measure_data;
}
