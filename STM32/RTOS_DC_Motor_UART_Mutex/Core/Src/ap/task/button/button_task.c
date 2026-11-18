/*
 * button_task.c
 *
 *  Created on: 2026. 11. 12.
 *      Author: kccistc
 */
#include "button_task.h"
#include "../../../driver/button/button.h"
#include "../../message.h"
#include "../../../driver/lcd/lcd.h"

static button_t btn_runstop, btn_left, btn_right;

void button_task_init(void) {
	button_init(&btn_runstop, GPIOC, GPIO_PIN_0);
	button_init(&btn_left, GPIOC, GPIO_PIN_1);
	button_init(&btn_right, GPIOC, GPIO_PIN_2);
}

void button_task(void) {
	if (button_getState(&btn_runstop) == ACT_RELEASE) {
		osMessagePut(BtnQueueHandle, BTN_RUN_STOP, 10);
		if (osMutexWait(lcdMutexHandle, osWaitForever) == osOK) {
			Lcd_writeStringXY(1, 0, "Button Task RUN   ");
			osMutexRelease(lcdMutexHandle);
		}
	} else if (button_getState(&btn_left) == ACT_RELEASE) {
		// full 이면 10ms 동안 full 풀릴때까지 기다리고 10ms 넘으면 걍 사라짐
		osMessagePut(BtnQueueHandle, BTN_LEFT, 10);
		if (osMutexWait(lcdMutexHandle, osWaitForever) == osOK) {
			Lcd_writeStringXY(1, 0, "Button Task LEFT   ");
			osMutexRelease(lcdMutexHandle);
		}
	} else if (button_getState(&btn_right) == ACT_RELEASE) {
		osMessagePut(BtnQueueHandle, BTN_RIGHT, 10);
		if (osMutexWait(lcdMutexHandle, osWaitForever) == osOK) {
			Lcd_writeStringXY(1, 0, "Button Task RIGHT   ");
			osMutexRelease(lcdMutexHandle);
		}
	}
}
