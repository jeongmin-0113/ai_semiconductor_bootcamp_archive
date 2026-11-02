/*
 * display.h
 *
 *  Created on: 2026. 10. 20.
 *      Author: kccistc
 */

#ifndef SRC_AP_DISPLAY_DISPLAY_H_
#define SRC_AP_DISPLAY_DISPLAY_H_

#include "../../driver/fnd/fnd.h"
#include "../../driver/led/led.h"
#include "../../driver/lcd/lcd.h"
#include <stdio.h>
#include <string.h>

typedef struct {
	uint8_t hour;
	uint8_t min;
	uint8_t sec;
	uint8_t msec;
} time_t;

void Disp_init(void);
void Disp_setMode(int mode);
void Disp_setWatchTime(time_t *pTime);
void Disp_setStopwatchTime(time_t *pTime);
void Disp_showWatchTime(void);
void Disp_showStopWatchTime(void);
void Disp_ISR(void);
void Disp_setStopWatchState(int state);
void Disp_updateLcd(void);

#endif /* SRC_AP_DISPLAY_DISPLAY_H_ */
