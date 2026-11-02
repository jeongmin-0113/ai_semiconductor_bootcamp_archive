/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "ap_main.h"

uint16_t clock_mode = STOPWATCH;
static button_t btn_mode;

static led_t led_stopwatch;
static led_t led_watch;

// 주기적으로 발생하는 인터럽트 콜백
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
	if (htim->Instance == TIM3) { // 1ms -> 0.001s
		fnd_show_segment();
	}
	if (htim->Instance == TIM4) { // 10ms -> 0.01s
		Watch_ISR();
		if (Stopwatch_getState() == RUN) {
			Stopwatch_ISR();
		}
	}
}

int ap_main(void) {

	led_init(&led_watch, GPIOB, GPIO_PIN_15);
	led_init(&led_stopwatch, GPIOB, GPIO_PIN_14);

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
			}

			led_on(&led_stopwatch);
			led_off(&led_watch);

			Stopwatch_Task();
			break;
		case WATCH:
			if (button_getState(&btn_mode) == ACT_PUSH) {
				clock_mode = STOPWATCH;
			}

			led_off(&led_stopwatch);
			led_on(&led_watch);

			Watch_task();
			break;
		default:
			clock_mode = STOPWATCH;
			break;
		}

	}

	return 0;
}
