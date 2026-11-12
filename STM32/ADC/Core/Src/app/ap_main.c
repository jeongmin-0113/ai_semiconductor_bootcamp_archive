/*
 * ap_main.c
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */
#include "ap_main.h"
#include "service/counter/counter.h"

void ap_main(void) {
	counter_init();
	while (1) {

		counter_task();
	}
}
