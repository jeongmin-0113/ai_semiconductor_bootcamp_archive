/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */
#include "ap_main.h"
#include "service/temp_humid/temp_humid.h"
#include "service/distance/distance.h"
#include "service/Display/Display.h"

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
	if (GPIO_Pin == GPIO_PIN_6) {
		dist_ISR();
	}
}

int ap_main(void) {
	TH_init();
	dist_init();
	Disp_init();

	while(1) {
		TH_task();
		dist_task();
		Disp_task();
	}

	return 0;
}
