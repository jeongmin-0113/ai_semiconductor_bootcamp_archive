/*
 * temphum.h
 *
 *  Created on: 2026. 10. 27.
 *      Author: kccistc
 */

#ifndef SRC_AP_TEMPHUM_TEMPHUM_H_
#define SRC_AP_TEMPHUM_TEMPHUM_H_

#include "../../driver/dht11/dht11.h"


void temphum_init(void);
dht11_data_t* temphum_getData(uint8_t sec);

#endif /* SRC_AP_TEMPHUM_TEMPHUM_H_ */
