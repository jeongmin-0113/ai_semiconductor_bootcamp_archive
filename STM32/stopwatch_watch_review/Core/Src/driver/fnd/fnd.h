/*
 * fnd.h
 *
 *  Created on: 2026. 10. 14.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_FND_FND_H_
#define SRC_DRIVER_FND_FND_H_

#include "stm32f4xx_hal.h"

#define ALL_SET		10
#define ALL_RESET	11
#define ONLY_DP		12

#define FND_DIGIT_1 0
#define FND_DIGIT_2 1
#define FND_DIGIT_3 2
#define FND_DIGIT_4 3

void fnd_show_number();
void fnd_show_segment();
void fnd_set_num(uint16_t n);
uint16_t fnd_get_num(void);
uint16_t fnd_getDp();
void fnd_setDp(uint16_t i);
void fnd_resetDp(uint16_t i);
void fnd_show_number_time() ;


#endif /* SRC_DRIVER_FND_FND_H_ */
