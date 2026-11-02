/*
 * temp_humid.h
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */

#ifndef SRC_AP_TEMP_HUMID_TEMP_HUMID_H_
#define SRC_AP_TEMP_HUMID_TEMP_HUMID_H_

#include "../../../driver/DHT11/DHT11.h"

#define dht_port	GPIOC
#define dht_pin		GPIO_PIN_8

void TH_init(void);
void TH_task(void);
void TH_getTempHumid(dht11_data_t *th);

#endif /* SRC_AP_TEMP_HUMID_TEMP_HUMID_H_ */
