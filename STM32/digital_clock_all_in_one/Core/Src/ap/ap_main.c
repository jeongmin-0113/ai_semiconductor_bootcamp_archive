/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: rhoblack
 */

#include "ap_main.h"
#include "../driver/fnd/fnd.h"
#include "../driver/button/button.h"
#include "../driver/led/led.h"
#include "../driver/button/button.h"
#include "../driver/lcd/lcd.h"
#include "../common/queue/queue_buffer.h"
#include "service/sound/sound.h"
#include "service/temp_humid/temp_humid.h"
#include "service/distance/distance.h"
#include "service/Display/Display.h"
#include "service/StopWatch/StopWatch.h"
#include "service/TimeClock/TimeClock.h"

#define BTN_EVENT_BUF_SIZE	16

enum {
	TIME_CLOCK_MODE, TEMP_HUMID_MODE, DISTANCE_MODE, STOP_WATCH_MODE
};

extern TIM_HandleTypeDef htim3;
extern TIM_HandleTypeDef htim4;

btn_event_t buf_btnEvent[BTN_EVENT_BUF_SIZE];
queue_buf_t q_btnEvent;
btn_event_t btnEvent;

button_t btnMode, btnRunStop, btnClear;

int modeState = TIME_CLOCK_MODE;
stopWatch_state_t stopWatchState;

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
	if (htim->Instance == TIM3) {
		//fnd_show_number();
//		Disp_ISR();
	} else if (htim->Instance == TIM4) {
		TimeClock_ISR();
		StopWatch_ISR();
	}
}

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
	if (GPIO_Pin == GPIO_PIN_6) {
		dist_ISR();
	}
}

void ap_init(void) {
	StopWatch_init();
	TimeClock_init();
	Disp_init();
	sound_init();
	TH_init();
	dist_init();

	queue_buf_init(&q_btnEvent, buf_btnEvent, sizeof(btn_event_t),
	BTN_EVENT_BUF_SIZE);
	button_init(&btnMode, GPIOC, GPIO_PIN_0);
	button_init(&btnRunStop, GPIOC, GPIO_PIN_1);
	button_init(&btnClear, GPIOC, GPIO_PIN_3);

	HAL_TIM_Base_Start_IT(&htim3);
	HAL_TIM_Base_Start_IT(&htim4);
}

void ap_timeClockMode(void) {
	if (btnEvent == BTN_MODE) {
		// 시계 -> 온습도 -> 거리 -> 스탑워치 -> 시계
		modeState = TEMP_HUMID_MODE;
	}

	TimeClock_t *pTimeClockTime = TimeClock_getTimeData();
	Disp_setTimeClockTime((timeClockTime_t*) pTimeClockTime, modeState);

	TimeDate_t *pTimeClockDate = TimeClock_getDateData();
	Disp_setTimeClockDate((timeClockDate_t*) pTimeClockDate);

	Disp_setMode(modeState);
}

void ap_stopWatchMode(void) {
	if (btnEvent == BTN_MODE) {
		// 시계 -> 온습도 -> 거리 -> 스탑워치 -> 시계
		modeState = TIME_CLOCK_MODE;
	}
	StopWatch_task(&btnEvent);

	stopWatchState = StopWatch_getState();
	Disp_setStopWatchState(stopWatchState);

	Disp_setMode(modeState);

	TimeClock_t *pTimeClockTime = TimeClock_getTimeData();
	Disp_setTimeClockTime((timeClockTime_t*) pTimeClockTime, modeState);

	stopWatch_t *pStopWatchTime = StopWatch_getTimeData();
	Disp_setStopWatchTime((stopWatchTime_t*) pStopWatchTime);
}

void ap_tempHumidMode(void) {
	if (btnEvent == BTN_MODE) {
		// 시계 -> 온습도 -> 거리 -> 스탑워치 -> 시계
		modeState = DISTANCE_MODE;
	}

	TH_task();

	TimeClock_t *pTimeClockTime = TimeClock_getTimeData();
	Disp_setTimeClockTime((timeClockTime_t*) pTimeClockTime, modeState);

	dht11_data_t pTempHumid = { 0, };
	TH_getTempHumid(&pTempHumid);
	Disp_setTempHumid((tempHumid_t*) &pTempHumid);

	Disp_setMode(modeState);
}

void ap_distanceMode(void) {
	if (btnEvent == BTN_MODE) {
		// 시계 -> 온습도 -> 거리 -> 스탑워치 -> 시계
		modeState = STOP_WATCH_MODE;
	}

	if (btnEvent == BTN_RUN_STOP) {
		dist_request();
	}

	dist_task();

	TimeClock_t *pTimeClockTime = TimeClock_getTimeData();
	Disp_setTimeClockTime((timeClockTime_t*) pTimeClockTime, modeState);

	Disp_setDistance();

	Disp_setMode(modeState);
}

void buttonEventListener() {
	static uint32_t prevTime = 0;
	btn_event_t btn_cur = BTN_NONE;
	if (button_getState(&btnMode) == ACT_RELEASE) {
		btn_cur = BTN_MODE;
		queue_push(&q_btnEvent, &btn_cur);
	}
	if (button_getState(&btnRunStop) == ACT_RELEASE) {
		btn_cur = BTN_RUN_STOP;
		queue_push(&q_btnEvent, &btn_cur);
	}
	if (button_getState(&btnClear) == ACT_RELEASE) {
		btn_cur = BTN_CLEAR;
		queue_push(&q_btnEvent, &btn_cur);
	}

	if (HAL_GetTick() - prevTime >= 1000) {
		prevTime = HAL_GetTick();
		if (!queue_isEmpty(&q_btnEvent)) {
			queue_pop(&q_btnEvent, &btnEvent);

			if (btnEvent == BTN_MODE) {
				sound_button();
			}
			if (btnEvent == BTN_RUN_STOP) {
				sound_runstop();
			}
			if (btnEvent == BTN_CLEAR) {
				sound_clear();
			}
		}
	} else {
		btnEvent = BTN_NONE;
	}
}

int ap_main(void) {
	ap_init();
	sound_boot();

	while (1) // super loop
	{
		buttonEventListener();

		TimeClock_task();

		switch (modeState) {
		case TIME_CLOCK_MODE:
			ap_timeClockMode();
			break;
		case STOP_WATCH_MODE:
			ap_stopWatchMode();
			break;
		case TEMP_HUMID_MODE:
			ap_tempHumidMode();
			break;
		case DISTANCE_MODE:
			ap_distanceMode();
			break;
		default:
			break;
		}
	}
	return 0;
}
