/*
 * comm_task.c
 *
 *  Created on: 2026. 11. 12.
 *      Author: kccistc
 */
#include "comm_task.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "usart.h"
#include "../../../driver/lcd/lcd.h"

extern UART_HandleTypeDef huart2;

static uint8_t rx_data = 0;
static uint8_t rx_index = 0;
static uint8_t rx_done = 0;
static char rx_buff[32] = { 0, };

comm_data_t data;

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
	if (huart->Instance == USART2) {
		if (rx_data == '*') {
			rx_buff[rx_index++] = '\0';
			rx_done = 1;
		} else {
			rx_buff[rx_index++] = rx_data;
		}
		HAL_UART_Receive_IT(&huart2, &rx_data, 1);
	}
}

void comm_task_init() {
	rx_index = 0;
	rx_done = 0;
	HAL_UART_Receive_IT(&huart2, &rx_data, 1);
}

void comm_task() {
	if (rx_done) {
		if (strcmp(rx_buff, "RUN") == 0) {
			// rx buff == RUN (같으면 0 다르면 1 or -1)
			data.status = COMM_RUN;

			osMessagePut(CommQueueHandle, (uint32_t) &data, 10);
			if (osMutexWait(lcdMutexHandle, osWaitForever) == osOK) {
				Lcd_writeStringXY(1, 0, "Comm Task RUN    ");
				osMutexRelease(lcdMutexHandle);
			}
		} else if (strcmp(rx_buff, "STOP") == 0) {
			// rx buff == STOP (같으면 0 다르면 1 or -1)
			data.status = COMM_STOP;

			osMessagePut(CommQueueHandle, (uint32_t) &data, 10);
			if (osMutexWait(lcdMutexHandle, osWaitForever) == osOK) {
				Lcd_writeStringXY(1, 0, "Comm Task STOP    ");
				osMutexRelease(lcdMutexHandle);
			}
		} else if (strncmp(rx_buff, "SPD", 3) == 0) {
			int speed = atoi(&rx_buff[3]); // SPD990에서 990만 추출해서 int형으로 변환
			data.status = COMM_SPEED;
			data.speed = speed;

			osMessagePut(CommQueueHandle, (uint32_t) &data, 10);
			if (osMutexWait(lcdMutexHandle, osWaitForever) == osOK) {
				char buf[30];
				sprintf(buf, "Comm Task SPEED %3d", data.speed);
				Lcd_writeStringXY(1, 0, buf);
				osMutexRelease(lcdMutexHandle);
			}
		} else {
			// 상정하지 않은 값 온 경우
//			osMessagePut(CommQueueHandle, COMM_NO, 10);
		}
		rx_done = 0;
		rx_index = 0;
	}
}
