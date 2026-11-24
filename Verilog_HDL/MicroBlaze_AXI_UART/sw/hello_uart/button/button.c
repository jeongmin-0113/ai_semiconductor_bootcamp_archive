/*
 * button.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: rhoblack
 */

#include "button.h"

#define GPIO_BTN_DEV_ID XPAR_AXI_GPIO_BTN_DEVICE_ID

XGpio GPIO_BTN;

void button_init(button_t *btn, XGpio* GPIOx, uint16_t GPIO_Pin)
{
	btn->GPIOx = GPIOx;
	btn->GPIO_Pin = GPIO_Pin;
	btn->prevState = RELEASED;

	XGpio_Initialize(btn->GPIOx, XPAR_AXI_GPIO_BTN_DEVICE_ID);
	uint32_t dirData = XGpio_GetDataDirection(btn->GPIOx, 1);
	dirData |= (1<<GPIO_Pin);
	XGpio_SetDataDirection(btn->GPIOx, 1, dirData); // 0xf: 4bit input
}

button_state_t button_getState(button_t *btn)
{
	int curState;

	curState = ((XGpio_DiscreteRead(btn->GPIOx, 1) & (1<<btn->GPIO_Pin)) == 0) ? 0 : 1;

	if ((btn->prevState == RELEASED) && (curState == PUSHED)) {
		btn->prevState = PUSHED;
		usleep(5000); // 5ms debounce code
		return ACT_PUSH;
	}
	else if ((btn->prevState == PUSHED) && (curState == RELEASED)) {
		btn->prevState = RELEASED;
		usleep(5000); // 5ms debounce code
		return ACT_RELEASE;
	}
	return NO_ACT;
}
