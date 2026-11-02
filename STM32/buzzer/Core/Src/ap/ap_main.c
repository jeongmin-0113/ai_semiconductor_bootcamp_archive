/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 30.
 *      Author: kccistc
 */
#include "ap_main.h"

extern I2C_HandleTypeDef hi2c1;

int ap_main(void) {

	button_t btn1, btn2, btn3;
	char buff[30];
	uint32_t cnt = 0;
	uint8_t state = 0;

	sound_init();
	button_init(&btn1, GPIOC, GPIO_PIN_0);
	button_init(&btn2, GPIOC, GPIO_PIN_1);
	button_init(&btn3, GPIOC, GPIO_PIN_3);
	Lcd_init(&hi2c1);
	sound_boot();

	while (1) {
		if (button_getState(&btn1) == ACT_RELEASE) {
			sound_button();
			state = 0;
		}
		if (button_getState(&btn2) == ACT_RELEASE) {
			sound_error();
			state = 1;
			cnt++;
		}

		if (button_getState(&btn3) == ACT_RELEASE) {
			sound_alarm();
			state = 2;
		}

		sprintf(buff, "Power On!!");
		Lcd_writeStringXY(0, 0, buff);
//		switch (state) {
//		case 0:
//
//			break;
//		case 1:
//			sprintf(buff, "Error!");
//			break;
//		case 2:
//			sprintf(buff, "Alart!");
//			break;
//		default:
//			sprintf(buff, "Power On!");
//			break;
//		}

		sprintf(buff, "Count: %4d", cnt);
		Lcd_writeStringXY(1, 0, buff);

		HAL_Delay(10);
	}

	return 0;
}
