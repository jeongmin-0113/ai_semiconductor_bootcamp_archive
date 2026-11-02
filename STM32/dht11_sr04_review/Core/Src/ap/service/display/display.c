/*
 * display.c
 *
 *  Created on: 2026. 10. 28.
 *      Author: rhoblack
 */


#include "display.h"
#include "../temp_humid/temp_humid.h"
#include "../distance/distance.h"
#include "../../../driver/lcd/lcd.h"
#include <stdio.h>

extern I2C_HandleTypeDef hi2c1;

void display_init(void)
{
	Lcd_init(&hi2c1);
}

void display_tempHumid(void)
{
	static uint32_t prevTime = 0;
	if (HAL_GetTick() - prevTime < 1000) {
		return;
	}
	prevTime = HAL_GetTick();

	char buff[30];
	dht11_data_t thData;

	TH_getTempHumid(&thData);
	sprintf(buff, "T:%2u.%01u'C H:%2u.%01u%%", thData.t_int, thData.t_dec, thData.h_int, thData.h_dec);
	Lcd_writeStringXY(1, 0, buff);
}

void display_distance(void) {
	char buff[30];
	static uint16_t prevDist = 0;
	uint16_t distance_cm = 0;

	if ((distance_get(&distance_cm) == DISTANCE_OK) && (prevDist != distance_cm)) {
		prevDist = distance_cm;
		sprintf(buff, "distance: %3d cm", prevDist);
		Lcd_writeStringXY(1, 0, buff);
	}
}

void display_task(void) {
	display_tempHumid();
	display_distance();
}
