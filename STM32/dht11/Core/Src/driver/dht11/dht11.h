/*
 * dht11.h
 *
 *  Created on: 2026. 10. 27.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_DHT11_DHT11_H_
#define SRC_DRIVER_DHT11_DHT11_H_

#include "stm32f4xx_hal.h"
#include "../../common/delay/delay.h"

typedef struct {
	uint8_t h_int;
	uint8_t h_dec;
	uint8_t t_int;
	uint8_t t_dec;
} dht11_data_t;

typedef enum {
	DHT11_OK = 0, DHT11_ERR_NO_RESPONSE, DHT11_ERR_TIMEOUT, DHT11_ERR_CHECKSUM
} dht11_status_t;

void dht11_init(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
dht11_status_t dht11_read(dht11_data_t *d);

#endif /* SRC_DRIVER_DHT11_DHT11_H_ */
