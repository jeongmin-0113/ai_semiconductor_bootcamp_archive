/*
 * stopwatch.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "stopwatch.h"

typedef enum {
	STOP, RUN, CLEAR
} stopwatch_t;

static stopwatch_t stopwatch_state;

static uint16_t __counter = 0;	// 0 ~ 9999 (loop)
static uint32_t prevTime = 0;

static led_t led_stop;
static led_t led_run;
static led_t led_clear;

static button_t btn_run_stop;
static button_t btn_clear;

// extern: 외부에 선언되어있는 변수를 가져온다
extern TIM_HandleTypeDef htim3;

/* stopwatch state control function */
static void Stopwatch_setState(stopwatch_t state) {
	stopwatch_state = state;
}

static stopwatch_t Stopwatch_getState() {
	return stopwatch_state;
}

/* counter control function */
static void Stopwatch_incCounter() {
	__counter++;
}

static void Stopwatch_clearCounter() {
	__counter = 0;
}

static void Stopwatch_setCounter(uint16_t t) {
	__counter = t;
}

uint16_t Stopwatch_getCounter() {
	return __counter;
}

/* stopwatch control function */
void Stopwatch_init() {
	stopwatch_state = STOP;
	Stopwatch_clearCounter();
	prevTime = 0;

	led_init(&led_stop, GPIOB, GPIO_PIN_14);
	led_init(&led_run, GPIOB, GPIO_PIN_13);
	led_init(&led_clear, GPIOC, GPIO_PIN_4);

	button_init(&btn_run_stop, GPIOC, GPIO_PIN_1);
	button_init(&btn_clear, GPIOC, GPIO_PIN_3);

	HAL_TIM_Base_Start_IT(&htim3);
}

static void Stopwatch_stop() {
	if (button_getState(&btn_run_stop) == ACT_PUSH) {
		Stopwatch_setState(RUN);
		prevTime = HAL_GetTick();
	} else if (button_getState(&btn_clear) == ACT_RELEASE) {
		Stopwatch_setState(CLEAR);
	}

	led_off(&led_run);
	led_on(&led_stop);
	led_off(&led_clear);
}

static void Stopwatch_run() {
	if (button_getState(&btn_run_stop) == ACT_PUSH) {
		Stopwatch_setState(STOP);
	}

	led_on(&led_run);
	led_off(&led_stop);
	led_off(&led_clear);

//	if (HAL_GetTick() - prevTime >= 100) {
//		prevTime = HAL_GetTick();
//		if (Stopwatch_getCounter() != 9999) {
//			Stopwatch_incCounter();
//		} else {
//			Stopwatch_clearCounter();
//		}
//	}
}

void Stopwatch_timer() {
	if ((stopwatch_state == RUN) && (HAL_GetTick() - prevTime >= 100)) {
		prevTime = HAL_GetTick();
		if (Stopwatch_getCounter() != 9999) {
			Stopwatch_incCounter();
		} else {
			Stopwatch_clearCounter();
		}
	}
}

static void Stopwatch_clear() {
	Stopwatch_clearCounter();

	led_off(&led_run);
	led_off(&led_stop);
	led_on(&led_clear);
	HAL_Delay(100);

	Stopwatch_setState(STOP);
}

void Stopwatch_Task(void) {
	uint16_t num = Stopwatch_getCounter();
	fnd_set_num(num);

	switch (Stopwatch_getState()) {
	case STOP:
		Stopwatch_stop();
		break;
	case RUN:
		Stopwatch_run();
		break;
	case CLEAR:
		Stopwatch_clear();
		break;
	default:
		Stopwatch_stop();
		break;
	}
}

