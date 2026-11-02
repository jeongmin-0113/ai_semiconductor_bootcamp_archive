/*
 * button.h
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_BUTTON_BUTTON_H_
#define SRC_DRIVER_BUTTON_BUTTON_H_

#include "stm32f4xx_hal.h"

typedef enum {
	NO_ACT,		// 아무것도 안하고 있을 때의 동작
	ACT_PUSH,	// 누르기 시작했을때의 동작
	ACT_RELEASE // 누르고 있다가 뗐을 때의 동작
} button_state_t;

enum {
	PUSHED = 0, RELEASED
};

typedef struct {
	GPIO_TypeDef *GPIOx;
	uint16_t GPIO_Pin;
	int prevState;
} button_t;

void button_init(button_t *btn, GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
button_state_t button_getState(button_t *btn);


#endif /* SRC_DRIVER_BUTTON_BUTTON_H_ */
