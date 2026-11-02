/*
 * Display.c
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */
#include "Display.h"

extern I2C_HandleTypeDef hi2c1;

void Disp_init(void) {
	Lcd_init(&hi2c1);
}

void Disp_task(void) {
	char buff[30];
	dht11_data_t temp_humid;
	static uint32_t prevTime = 0;

	if (HAL_GetTick() - prevTime < 1000) {
		return;
	}
	prevTime = HAL_GetTick();

	TH_getTempHumid(&temp_humid);
	sprintf(buff, "T: %2u.%1u'C H: %2u%%", temp_humid.t_int, temp_humid.t_dec,
			temp_humid.h_int);
	Lcd_writeStringXY(1, 0, buff);
}
