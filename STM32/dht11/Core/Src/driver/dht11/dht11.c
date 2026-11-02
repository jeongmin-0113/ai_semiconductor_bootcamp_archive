/*
 * dht11.c
 *
 *  Created on: 2026. 10. 27.
 *      Author: kccistc
 */
#include "../../driver/dht11/dht11.h"

#define RESPONSE_TIMEOUT_US	100
#define BIT_ONE_US			40

GPIO_TypeDef *dht11_gpio;
uint16_t dht11_pin;

//typedef enum {
//	IDLE, START, WAIT, SYNC_LOW, SYNC_HIGH, BIT_LOW, BIT_HIGH, STOP
//} DHT11_state_t;
//
//void dht11_read_frame(uint8_t *buf, uint8_t size) {
//	DHT11_state_t dht11State = WAIT;
//	uint8_t bitIdx = 0;
//	uint32_t bitStartTime = 0;
//
//	while (1) {
//
//		GPIO_PinState cur = HAL_GPIO_ReadPin(dht11_gpio, dht11_pin);
//
//		switch (dht11State) {
//		case WAIT:
//			if (cur == 0) {
//				dht11State = SYNC_LOW;
//			}
//			break;
//		case SYNC_LOW:
//			if (cur == 1) {
//				dht11State = SYNC_HIGH;
//			}
//			break;
//		case SYNC_HIGH:
//			if (cur == 0) {
//				dht11State = BIT_LOW;
//				bitIdx = 0;
//			}
//			break;
//		case BIT_LOW:
//			if (cur == 1) {
//				dht11State = BIT_HIGH;
//				bitStartTime = usCounter;
//			}
//			break;
//		case BIT_HIGH:
//			if (cur == 0) {
//				if (usCounter - bitStartTime >= 5) {
//					buf[bitIdx / 8] |= (1 << (7 - (bitIdx % 8)));
//				} else {
//					buf[bitIdx / 8] &= ~(1 << (7 - (bitIdx % 8)));
//				}
//				bitIdx++;
//				if (bitIdx >= size * 8) {
//					dht11State = STOP;
//				} else {
//					dht11State = BIT_LOW;
//				}
//			}
//			break;
//		case STOP:
//			if (cur == 1) {
//				dht11State = WAIT;
//				return;
//			}
//			break;
//		default:
//			dht11State = WAIT;
//			return;
//			break;
//		}
//	}
//}

static void pin_set_output() {
	GPIO_InitTypeDef GPIO_InitStruct = { 0 };

	GPIO_InitStruct.Pin = GPIO_PIN_8;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(dht11_gpio, &GPIO_InitStruct);
}

static void pin_set_input() {
	GPIO_InitTypeDef GPIO_InitStruct = { 0 };

	GPIO_InitStruct.Pin = GPIO_PIN_8;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(dht11_gpio, &GPIO_InitStruct);
}

void dht11_init(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	dht11_gpio = GPIOx;
	dht11_pin = GPIO_Pin;
	delay_init();
	HAL_GPIO_WritePin(dht11_gpio, dht11_pin, GPIO_PIN_SET);
}


static GPIO_PinState line_read(void) {
	return HAL_GPIO_ReadPin(dht11_gpio, dht11_pin);
}

static int32_t wait_while(GPIO_PinState level, uint32_t timeout_us) {
	uint32_t start = delay_get_cycle();

	while (line_read() == level) {
		// start로부터 기다린 시간
		if (delay_elapsed_us(start) > timeout_us) {
			return -1;
		}
	}
	return (int32_t) delay_elapsed_us(start);
}

static dht11_status_t dht11_readFrame(uint8_t *buf) {
	// timeout 나기 전까지 gpio pin reset을 기다리기 (timeout = -1)
	if (wait_while(GPIO_PIN_SET, RESPONSE_TIMEOUT_US) < 0) {
		// timeout (-1)
		return DHT11_ERR_NO_RESPONSE;
	}

	// low 80 대기 / high 80 대기
	// timeout 나기 전까지 gpio pin reset을 기다리기 (timeout = -1)
	if (wait_while(GPIO_PIN_RESET, RESPONSE_TIMEOUT_US) < 0) {
		// timeout (-1)
		return DHT11_ERR_NO_RESPONSE;
	}
	// timeout 나기 전까지 gpio pin reset을 기다리기 (timeout = -1)
	if (wait_while(GPIO_PIN_SET, RESPONSE_TIMEOUT_US) < 0) {
		// timeout (-1)
		return DHT11_ERR_NO_RESPONSE;
	}

	// bit 40개 수신
	for (int i = 0; i < 40; i++) {
		if (wait_while(GPIO_PIN_RESET, RESPONSE_TIMEOUT_US) < 0) {
			// timeout (-1)
			return DHT11_ERR_NO_RESPONSE;
		}
		int32_t high_us = wait_while(GPIO_PIN_SET, RESPONSE_TIMEOUT_US);
		if (high_us < 0) {
			return DHT11_ERR_NO_RESPONSE;
		}
		uint8_t bit = (high_us > BIT_ONE_US) ? 1 : 0;
		buf[i / 8] = (uint8_t) (buf[i / 8] << 1 | bit);
	}

	return DHT11_OK;
}

dht11_status_t dht11_read(dht11_data_t *d) {
	uint8_t buf[5] = { 0, };
	// pin을 output 모드로 바꾸겠다
	pin_set_output();
	HAL_GPIO_WritePin(dht11_gpio, dht11_pin, GPIO_PIN_RESET); // LOW
	HAL_Delay(18); // 18ms delay
	HAL_GPIO_WritePin(dht11_gpio, dht11_pin, GPIO_PIN_SET); // high
	pin_set_input(); // pin -> input 모드

	//		dht11_read_frame(buf, 5); // frame 단위로 온습도 데이터를 buf로 읽는다
	dht11_status_t s = dht11_readFrame(buf);
	if (s != DHT11_OK) {
		return s;
	}

	uint8_t checksum = (uint8_t) (buf[0] + buf[1] + buf[2] + buf[3]);
	if (checksum != buf[4]) {
		return DHT11_ERR_CHECKSUM;
	}

	d->h_int = buf[0];
	d->h_dec = buf[1];
	d->t_int = buf[2];
	d->t_dec = buf[3];

	return DHT11_OK;
}
