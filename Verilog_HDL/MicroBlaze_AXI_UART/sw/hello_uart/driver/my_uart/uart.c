/*
 * uart.c
 *
 *  Created on: 2026. 11. 24.
 *      Author: kccistc
 */
#include "uart.h"

uint8_t UART_RxAvailable(UART_Typedef* uart) {
	return (uart->SR & (1 << 1)) ? 1 : 0;
}

void UART_Transmit(UART_Typedef* uart, uint8_t tx_data) {
	while (uart->SR & (1 << 0))
		; // busy면 대기
	uart->TDR = tx_data; // busy 풀리면 tx 전송
}

void UART_Receive(UART_Typedef* uart, uint8_t* rx_data) {
//	while (!UART_RxAvailable(uart)); // done == 1이 될때까지 대기
	*rx_data = (uint8_t) uart->RDR;
}
