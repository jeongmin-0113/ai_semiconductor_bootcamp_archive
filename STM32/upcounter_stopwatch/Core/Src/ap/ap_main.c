/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "ap_main.h"

uint16_t clock_mode = STOPWATCH;

// 주기적으로 발생하는 인터럽트 콜백
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
	if (htim->Instance == TIM3) { // 1ms
		Stopwatch_timer();
		switch (clock_mode) {
		case STOPWATCH:
			fnd_show_number_old();
			break;
		case WATCH:
			fnd_show_number_time();
			break;
		}
	}
	if (htim->Instance == TIM2) { // 0.5s
		if (!fnd_getDotFlag()) {
			fnd_setDotFlag();
		} else {
			fnd_resetDotFlag();
			Watch_incCounter();
		}
	}
}

int ap_main(void) {
	button_t btn_mode;
	led_t led_mode;

	led_init(&led_mode, GPIOB, GPIO_PIN_15);
	button_init(&btn_mode, GPIOC, GPIO_PIN_0);
	Stopwatch_init();
	Watch_init();

	/* Infinite loop */
	/* USER CODE BEGIN WHILE */
	while (1) { // super loop (모든 동작 무한반복)
		switch (clock_mode) {
		case STOPWATCH:
			if (button_getState(&btn_mode) == ACT_PUSH) {
				clock_mode = WATCH;
				fnd_set_num(Watch_getCounter());
				led_on(&led_mode);
			}
			Stopwatch_Task();
			break;
		case WATCH:
			if (button_getState(&btn_mode) == ACT_PUSH) {
				clock_mode = STOPWATCH;
				fnd_set_num(Stopwatch_getCounter());
				led_off(&led_mode);
			}
			Watch_task();
			break;
		}
	}

	return 0;
}
