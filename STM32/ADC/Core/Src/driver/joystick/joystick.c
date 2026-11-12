/*
 * joystick.c
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */
#include "joystick.h"
#include "../adc/adc.h"

static int8_t joystick_calcWeight(uint16_t adc)
{
    if      (adc <= 10)   return -3;
    else if (adc <= 1000) return -2;
    else if (adc <= 1900) return -1;
    else if (adc <= 2100) return  0;
    else if (adc <= 3000) return  1;
    else if (adc <= 4000) return  2;
    else                  return  3;
}

void joystick_init(ADC_HandleTypeDef* adc) {
   adc_init(adc);
}

void joystick_getValue(int8_t* weightX, int8_t* weightY)
{
    uint16_t posX = 0, posY = 0;
    adc_getJoyXY(&posX, &posY);

    *weightX = joystick_calcWeight(posX);
    *weightY = joystick_calcWeight(posY);
}



