/*
 * main.c
 *
 *  Created on: 2026. 11. 24.
 *      Author: kccistc
 */
#include "xparameters.h"
#include "xil_printf.h"
#include "sleep.h"
#include "xgpio.h"
#include <stdint.h>
#include "button/button.h"
#include "driver/my_uart/uart.h"



#define GPIO_BTN_DEV_ID XPAR_AXI_GPIO_BTN_DEVICE_ID
#define GPIO_LED_DEV_ID XPAR_AXI_GPIO_LED_DEVICE_ID
#define GPIO_SW_DEV_ID 	XPAR_AXI_GPIO_SW_DEVICE_ID
#define GPIO_FND_DEV_ID XPAR_AXI_GPIO_FND_DEVICE_ID

#define UART_BASEADDR 	XPAR_UART_0_S00_AXI_BASEADDR
#define UART0			((UART_Typedef *) UART_BASEADDR)

XGpio GPIO_LED, GPIO_SW, GPIO_BTN;

int main(void) {
//	uint16_t sw_data;

//	button_init(&GPIO_BTN);

	// axi gpio init
	XGpio_Initialize(&GPIO_LED, GPIO_LED_DEV_ID);
	XGpio_Initialize(&GPIO_SW, GPIO_SW_DEV_ID);
	XGpio_Initialize(&GPIO_BTN, GPIO_BTN_DEV_ID);

	// gpio in (1) out (0) setting
	XGpio_SetDataDirection(&GPIO_LED, 1, 0x0000); // 0x0000: 16bit output
	XGpio_SetDataDirection(&GPIO_SW, 1, 0xffff); // 0xffff: 16bit input
	XGpio_SetDataDirection(&GPIO_BTN, 1, 0xf); // 0xf: 4bit input

	uint8_t tx_data = 'a';
	uint8_t rx_data;

	while (1) {
//		sw_data = XGpio_DiscreteRead(&GPIO_SW, 1);
//
//		// 1s on
//		XGpio_DiscreteWrite(&GPIO_LED, 1, sw_data);
//		usleep(200000);
//
//		// 1s off
//		XGpio_DiscreteWrite(&GPIO_LED, 1, sw_data);
//		usleep(200000);

		UART_Transmit(UART0, tx_data);

		if (tx_data == 'z')
			tx_data = 'a';
		else
			tx_data++;

		sleep(1);

		if (UART_RxAvailable(UART0)) {
			UART_Receive(UART0, &rx_data);
			xil_printf("received %c\n\r", rx_data);
		}

	}

	return 0;
}
