/*
 * SR04.c
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */
#include "SR04.h"

#define RISE_TIMEOUT_MS	5
#define FALL_TIMEOUT_MS	50

GPIO_TypeDef *trig_port;
uint16_t trig_pin;

GPIO_TypeDef *echo_port;
uint16_t echo_pin;

TIM_HandleTypeDef *sr04_htim;

// 인터럽트 내부에서 실행되는 변수들은 컴파일러 최적화될 수 있음
// 컴파일러 최적화로 값 사라지는거 방지하기 위해 volatile
volatile uint32_t riseCnt, fallCnt;

volatile echo_state_t state;

uint32_t start_ms;

echo_state_t SR04_getState() {
	return state;
}

void SR04_init(GPIO_TypeDef *t_port, uint16_t t_pin, GPIO_TypeDef *e_port,
		uint16_t e_pin, TIM_HandleTypeDef *htim) {

	trig_port = t_port;
	trig_pin = t_pin;
	echo_port = e_port;
	echo_pin = e_pin;
	sr04_htim = htim;

	riseCnt = 0;
	fallCnt = 0;

	state = STATE_IDLE;

	delay_init();
	HAL_GPIO_WritePin(trig_port, trig_pin, GPIO_PIN_RESET);
	HAL_TIM_Base_Start(sr04_htim);
}

bool echo_is_high() {
	return HAL_GPIO_ReadPin(echo_port, echo_pin) == GPIO_PIN_SET;
}

void SR04_echoISR(void) {
	// sr04 htim의 타이머 카운터 값을 가져옴
	uint32_t cnt = __HAL_TIM_GET_COUNTER(sr04_htim);
	bool isHigh = echo_is_high();

	if ((state == STATE_WAIT_RISE) && isHigh) {
		// isr이 걸린 시점에서 echo가 high -> rising edge
		riseCnt = cnt;
		state = STATE_WAIT_FALL;
	} else if ((state == STATE_WAIT_FALL) && !isHigh) {
		// isr이 걸린 시점에서 echo가 low -> failing edge
		fallCnt = cnt;
		state = STATE_DONE;
	}
}

sr04_status_t SR04_start(void) {
	if ((state == STATE_WAIT_RISE) || (state == STATE_WAIT_FALL)) {
		return SR04_ERR_BUSY;
	}
	if (echo_is_high()) {
		return SR04_ERR_BUSY;
	}
	HAL_GPIO_WritePin(trig_port, trig_pin, GPIO_PIN_SET);
	delay_us(15); // 10us 동안 1 전송
	HAL_GPIO_WritePin(trig_port, trig_pin, GPIO_PIN_RESET);
	state = STATE_WAIT_RISE;
	start_ms = HAL_GetTick();
	return SR04_OK;
}

uint32_t timer_diff(uint32_t start, uint32_t end) {
	// arr *auto reload register에 설정된 값 = 65535
	uint32_t arr_max = __HAL_TIM_GET_AUTORELOAD(sr04_htim);
	if (end >= start)
		return end - start;
	else
		return (arr_max - start) + end + 1;
}

sr04_status_t SR04_getResult(uint32_t *echo_us) {
	uint32_t elapsed_ms = HAL_GetTick() - start_ms;
	switch (state) {
	case STATE_WAIT_RISE:
		if (elapsed_ms >= RISE_TIMEOUT_MS) {
			state = STATE_IDLE;
			return SR04_ERR_NO_ECHO;
		}
		return SR04_IN_PROGRESS;
		break;
	case STATE_WAIT_FALL:
		if (elapsed_ms >= FALL_TIMEOUT_MS) {
			state = STATE_IDLE;
			return SR04_ERR_NO_ECHO;
		}
		return SR04_IN_PROGRESS;
		break;
	case STATE_DONE:
		*echo_us = timer_diff(riseCnt, fallCnt); // us * 0.017 -> cm 나온다
		state = STATE_IDLE;
		return SR04_OK;
		break;
	case STATE_IDLE:
	default:
		return SR04_ERR_NOT_STARTED;
		break;
	}
}
