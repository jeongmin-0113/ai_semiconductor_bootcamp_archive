/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "ap_main.h"

int ap_main(void) {
	led_t led_power = { GPIOB, GPIO_PIN_15 };
	led_t led_stop = { GPIOB, GPIO_PIN_14 };
	led_t led_run = { GPIOB, GPIO_PIN_13 };
	led_t led_clear = { GPIOC, GPIO_PIN_4 };

	button_t btn_power = { GPIOC, GPIO_PIN_0, RELEASED };
	button_t btn_run_stop = { GPIOC, GPIO_PIN_1, RELEASED };
	button_t btn_clear = { GPIOC, GPIO_PIN_3, RELEASED };

	enum {
		STOP, RUN, CLEAR
	};
	int state = STOP;

	/* USER CODE END 2 */

	/* Infinite loop */
	/* USER CODE BEGIN WHILE */
	while (1) {
		switch (state) {
		case STOP:
			if (button_getState(&btn_run_stop) == ACT_PUSH) {
				state = RUN;
			} else if (button_getState(&btn_clear) == ACT_RELEASE) {
				state = CLEAR;
			}

			led_on(&led_power);
			led_off(&led_run);
			led_on(&led_stop);
			led_off(&led_clear);
			break;
		case RUN:
			if (button_getState(&btn_run_stop) == ACT_PUSH) {
				state = STOP;
			}

			led_on(&led_power);
			led_on(&led_run);
			led_off(&led_stop);
			led_off(&led_clear);
			break;
		case CLEAR:
			led_on(&led_power);
			led_off(&led_run);
			led_off(&led_stop);
			led_on(&led_clear);
			HAL_Delay(200);

			state = STOP;
			break;
		default:
			state = STOP;
			break;
		}
	}

	return 0;
}
