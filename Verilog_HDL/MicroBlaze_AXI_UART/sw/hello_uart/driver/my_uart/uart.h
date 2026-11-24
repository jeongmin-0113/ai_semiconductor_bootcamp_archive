/*
 * uart.h
 *
 *  Created on: 2026. 11. 24.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_MY_UART_UART_H_
#define SRC_DRIVER_MY_UART_UART_H_

#include <stdint.h>
#include "sleep.h"

typedef struct {
	uint32_t SR;
	uint32_t TDR;
	uint32_t RDR;
	uint32_t CR;
} UART_Typedef;

uint8_t UART_RxAvailable(UART_Typedef* uart);
void UART_Transmit(UART_Typedef* uart, uint8_t tx_data);
void UART_Receive(UART_Typedef* uart, uint8_t* rx_data);

#endif /* SRC_DRIVER_MY_UART_UART_H_ */
