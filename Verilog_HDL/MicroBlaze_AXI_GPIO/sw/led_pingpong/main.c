/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
//#include "platform.h"
#include "xil_printf.h"
#include <stdint.h>
#include "sleep.h"

#define GPIOA_BASEADDR	0x44a00000
#define GPIOB_BASEADDR	0x44a10000
#define GPIOC_BASEADDR	0x44a20000
#define GPIOD_BASEADDR	0x44a30000
#define GPIOE_BASEADDR	0x44a40000

#define GPIOA			((GPIO_TypeDef *)GPIOA_BASEADDR)
#define GPIOB			((GPIO_TypeDef *)GPIOB_BASEADDR)
#define GPIOC			((GPIO_TypeDef *)GPIOC_BASEADDR)
#define GPIOD			((GPIO_TypeDef *)GPIOD_BASEADDR)
#define GPIOE			((GPIO_TypeDef *)GPIOE_BASEADDR)

typedef struct {
	uint32_t CR;
	uint32_t ODR;
	uint32_t IDR;
} GPIO_TypeDef;

int main()
{
    // gpioa의 control register 접근
    GPIOA->CR = 0x0f;
    GPIOB->CR = 0x0f;
    GPIOC->CR = 0x0f;
    GPIOD->CR = 0x0f;
    GPIOE->CR = 0X00;

    uint16_t mask = 0;
    uint8_t flag = 1;

    while (1) {
    	if (mask == 0) {
    		if (!flag) {
    			flag = 1;
    			mask = 0x8000;
    		} else {
    			flag = 0;
    			mask = 0x0001;
    		}
    	}
    	else {
    		if (!flag) mask = mask << 1;
    		else mask = mask >> 1;
    	}

    	GPIOA->ODR = mask & 0x000f;
    	GPIOB->ODR = (mask & 0x00f0) >> 4;
    	GPIOC->ODR = (mask & 0x0f00) >> 8;
    	GPIOD->ODR = (mask & 0xf000) >> 12;

    	usleep(100000); // sleep : 1s 단위 / usleep: us 단위
    }

    return 0;
}
