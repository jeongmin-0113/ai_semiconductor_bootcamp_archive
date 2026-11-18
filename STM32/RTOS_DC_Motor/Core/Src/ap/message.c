/*
 * message.c
 *
 *  Created on: 2026. 11. 12.
 *      Author: kccistc
 */
#include "message.h"

void message_push(uint32_t info) {
	osMessagePut(BtnQueueHandle, info, 10);
}

void message_pop(uint32_t* info) {

}
