/*
 * stopwatch.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "stopwatch.h"

static stopwatch_t stopwatch_state;

static watch_t stopwatch_data;

static led_t led_run;
static led_t led_stop;

static button_t btn_run_stop;
static button_t btn_clear;

// extern: 외부에 선언되어있는 변수를 가져온다
extern TIM_HandleTypeDef htim3;

/* stopwatch state control function */
static void Stopwatch_setState(stopwatch_t state) {
	stopwatch_state = state;
}

stopwatch_t Stopwatch_getState() {
	return stopwatch_state;
}

/* counter control function */
static void Stopwatch_incHour() {
	if (stopwatch_data.hour != 23) {
		stopwatch_data.hour++;
	} else {
		stopwatch_data.hour = 0;
	}
}

static void Stopwatch_incMin() {
	if (stopwatch_data.min != 59) {
		stopwatch_data.min++;
	} else {
		stopwatch_data.min = 0;
		Stopwatch_incHour();
	}
}

static void Stopwatch_incSec() {
	if (stopwatch_data.sec != 59) {
		stopwatch_data.sec++;
	} else {
		stopwatch_data.sec = 0;
		Stopwatch_incMin();
	}
}

static void Stopwatch_incMsec() {
	if (stopwatch_data.msec != 99) {
		stopwatch_data.msec++;
	} else {
		stopwatch_data.msec = 0;
		Stopwatch_incSec();
	}
}

static void Stopwatch_clearData() {
	stopwatch_data.hour = 0;
	stopwatch_data.min = 0;
	stopwatch_data.sec = 0;
	stopwatch_data.msec = 0;
}

//static void Stopwatch_setCounter(uint16_t t) {
//	__counter = t;
//}

watch_t* Stopwatch_getData() {
	return &stopwatch_data;
}

/* stopwatch control function */
void Stopwatch_init() {
	stopwatch_state = STOP;
	Stopwatch_clearData();

	led_init(&led_run, GPIOB, GPIO_PIN_13);
	led_init(&led_stop, GPIOC, GPIO_PIN_4);

	button_init(&btn_run_stop, GPIOC, GPIO_PIN_1);
	button_init(&btn_clear, GPIOC, GPIO_PIN_3);

	HAL_TIM_Base_Start_IT(&htim3);
}

static void Stopwatch_stop() {
	if (button_getState(&btn_run_stop) == ACT_PUSH) {
		Stopwatch_setState(RUN);
	} else if (button_getState(&btn_clear) == ACT_RELEASE) {
		Stopwatch_setState(CLEAR);
	}

	led_off(&led_run);
	led_on(&led_stop);
}

static void Stopwatch_run() {
	if (button_getState(&btn_run_stop) == ACT_PUSH) {
		Stopwatch_setState(STOP);
	}

	led_on(&led_run);
	led_off(&led_stop);

	if (stopwatch_data.msec > 50) {
		fnd_setDp(FND_DIGIT_2);
	} else {
		fnd_resetDp(FND_DIGIT_2);
	}
}

static void Stopwatch_clear() {
	Stopwatch_clearData();

	led_off(&led_run);
	led_off(&led_stop);

	Stopwatch_setState(STOP);
}

void Stopwatch_Task(void) {
	uint16_t num;
	num = (stopwatch_data.sec * 100) + stopwatch_data.msec;
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

void Stopwatch_ISR(void) {
	Stopwatch_incMsec();
}

