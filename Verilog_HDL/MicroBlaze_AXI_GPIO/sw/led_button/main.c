/*
 * main.c
 *
 *  Created on: 2026. 11. 20.
 *      Author: kccistc
 */

#include <stdio.h>
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
	volatile uint32_t CR;
	volatile uint32_t ODR;
	volatile uint32_t IDR;
} GPIO_TypeDef;

int main()
{
    // gpioa�� control register ����
    GPIOA->CR = 0x0f; // output mode
    GPIOB->CR = 0x0f; // output mode
    GPIOC->CR = 0x0f; // output mode
    GPIOD->CR = 0x0f; // output mode
    GPIOE->CR = 0X00; // input mode

    uint16_t mask = 0;
    uint8_t flag = 0;

    while (1) {
    	if ((GPIOE->IDR & 0x02) > 0) {
    		flag = 0;
    	} else if ((GPIOE->IDR & 0x04) > 0) {
    		flag = 1;
    	}

    	if (mask == 0) {
    		if (!flag) mask = 0x0001;
    		else mask = 0x8000;
    	}
    	else {
    		if (!flag) mask = mask << 1;
    		else mask = mask >> 1;
    	}

    	GPIOA->ODR = mask & 0x000f;
    	GPIOB->ODR = (mask & 0x00f0) >> 4;
    	GPIOC->ODR = (mask & 0x0f00) >> 8;
    	GPIOD->ODR = (mask & 0xf000) >> 12;

    	usleep(100000); // sleep : 1s ���� / usleep: us ����
    }

    return 0;
}
