/*
 * Display.h
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */

#ifndef SRC_AP_DISPLAY_DISPLAY_H_
#define SRC_AP_DISPLAY_DISPLAY_H_

#include <stdio.h>
#include "../../../driver/lcd/lcd.h"
#include "../temp_humid/temp_humid.h"
#include "../distance/distance.h"

void Disp_init(void);
void Disp_task(void);

#endif /* SRC_AP_DISPLAY_DISPLAY_H_ */
