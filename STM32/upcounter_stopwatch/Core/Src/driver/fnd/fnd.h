/*
 * fnd.h
 *
 *  Created on: 2026. 10. 14.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_FND_FND_H_
#define SRC_DRIVER_FND_FND_H_

#include "stm32f4xx_hal.h"

void fnd_show_number();
void fnd_show_number_old();
void fnd_set_num(uint16_t n);
uint16_t fnd_get_num(void);
uint16_t fnd_getDotFlag();
void fnd_setDotFlag();
void fnd_resetDotFlag();
void fnd_show_number_time() ;


#endif /* SRC_DRIVER_FND_FND_H_ */
