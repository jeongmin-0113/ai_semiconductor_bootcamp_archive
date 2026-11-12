/*
 * counter.c
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */
#include "counter.h"
#include "../../../driver/joystick/joystick.h"
#include "../../../driver/lcd/lcd.h"
#include <stdio.h>

extern ADC_HandleTypeDef hadc1;
extern I2C_HandleTypeDef hi2c1;

static int counterX = 0, counterY = 0;

void counter_init() {
	counterX = 0;
	counterY = 0;
	joystick_init(&hadc1);
	Lcd_init(&hi2c1);

	// 초기 출력
	char buff[30];
	sprintf(buff, "X: %-+4d", counterX);
	Lcd_writeStringXY(0, 0, buff);
	sprintf(buff, "Y: %-+4d", counterY);
	Lcd_writeStringXY(1, 0, buff);
}

static void counter_disp(int curX, int curY) {
	char buff[30];

	if (counterX != curX) {
		sprintf(buff, "X: %-+4d             ", curX);
		Lcd_writeStringXY(0, 0, buff);
		counterX = curX;
	}

	if (counterY != curY) {
		sprintf(buff, "Y: %-+4d            ", curY);
		Lcd_writeStringXY(1, 0, buff);
		counterY = curY;
	}
}

void counter_task() {
	int8_t aX = 0, aY = 0;
	uint32_t prevTime = 0;

	if (HAL_GetTick() - prevTime < 1000) return;
	prevTime = HAL_GetTick();
	joystick_getValue(&aX, &aY);

	int curX = counterX + (aX*3);
	int curY = counterY + (aY*3);

	counter_disp(curX, curY);
}
