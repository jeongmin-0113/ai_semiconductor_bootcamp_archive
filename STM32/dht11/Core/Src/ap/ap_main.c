/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: rhoblack
 */

#include "ap_main.h"
#include "StopWatch/StopWatch.h"
#include "TimeClock/TimeClock.h"
#include "Display/Display.h"
#include "AnalogClock/AnalogClock.h"
#include "TempHum/temphum.h"
#include "../driver/fnd/fnd.h"
#include "../driver/button/button.h"
#include "../driver/led/led.h"

enum {
	TIME_CLOCK_MODE, STOP_WATCH_MODE
};

extern TIM_HandleTypeDef htim4;

button_t btnMode;

int modeState = TIME_CLOCK_MODE;
stopWatch_state_t stopWatchState;

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
	if (htim->Instance == TIM4) {
		TimeClock_ISR();
	}
}

void ap_init(void) {
	TimeClock_init();
	Disp_init();
	dht11_init(GPIOC, GPIO_PIN_8);

	HAL_TIM_Base_Start_IT(&htim4);
}

int ap_main(void) {
	ap_init();

	while (1) // super loop
	{
		TimeClock_task();

		TimeClock_t *pTimeClockTime = TimeClock_getTimeData();
		dht11_data_t *th = temphum_getData(pTimeClockTime->sec);
		Disp_setTempHum((dht11Data_t*) th);
	}
	return 0;
}
