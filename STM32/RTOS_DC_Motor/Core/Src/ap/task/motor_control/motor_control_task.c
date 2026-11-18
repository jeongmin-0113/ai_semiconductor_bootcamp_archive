/*
 * motor_control_task.c
 *
 *  Created on: 2026. 11. 12.
 *      Author: kccistc
 */
#include "motor_control_task.h"
#include "../../../driver/dc_motor/dc_motor.h"
#include "../../message.h"

motor_t motorL, motorR;
motor_state_t manual_state = STOP;

extern TIM_HandleTypeDef htim3;

void motor_control_task_init(void) {
	motor_init(&motorL, &htim3, TIM_CHANNEL_1, MOTOR_LEFT1_GPIO,
	MOTOR_LEFT1_PIN, MOTOR_LEFT2_GPIO, MOTOR_LEFT2_PIN);
	motor_init(&motorR, &htim3, TIM_CHANNEL_3, MOTOR_RIGHT1_GPIO,
	MOTOR_RIGHT1_PIN, MOTOR_RIGHT2_GPIO, MOTOR_RIGHT2_PIN);
	motor_setSpeed(900);
}

void motor_control_task(void) {
	osEvent evt;
	btn_status_t btn_status = BTN_NO;
	evt = osMessageGet(BtnQueueHandle, 100);
	if (evt.status == osEventMessage) {
		btn_status = evt.value.v;
	}

	switch (manual_state) {
	case STOP:
		if (btn_status == BTN_RUN_STOP) {
			manual_state = FORWARD;
		}
		motor_stop(&motorL, &motorR);
		break;
	case FORWARD:
		if (btn_status == BTN_RUN_STOP) {
			manual_state = STOP;
		} else if (btn_status == BTN_RIGHT) {
			manual_state = RIGHT;
		} else if (btn_status == BTN_LEFT) {
			manual_state = LEFT;
		}

		motor_forward(&motorL, &motorR);
		break;
	case BACKWARD:
		if (btn_status == BTN_RUN_STOP) {
			manual_state = STOP;
		} else if (btn_status == BTN_RIGHT) {
			manual_state = FORWARD;
		} else if (btn_status == BTN_LEFT) {
			manual_state = FORWARD;
		}

		motor_backward(&motorL, &motorR);
		break;
	case RIGHT:
		if (btn_status == BTN_RUN_STOP) {
			manual_state = STOP;
		} else if (btn_status == BTN_RIGHT) {
			manual_state = BACKWARD;
		}

		motor_right(&motorL, &motorR);
		break;
	case LEFT:
		if (btn_status == BTN_RUN_STOP) {
			manual_state = STOP;
		} else if (btn_status == BTN_LEFT) {
			manual_state = BACKWARD;
		}

		motor_left(&motorL, &motorR);
		break;
	default:
		motor_stop(&motorL, &motorR);
		break;
	}

}
