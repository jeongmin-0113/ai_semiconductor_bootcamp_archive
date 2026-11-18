/*
 * dc_motor.c
 *
 *  Created on: 2026. 11. 11.
 *      Author: kccistc
 */
#include "dc_motor.h"

uint16_t motor_speed = 0;

void motor_init(motor_t *motor, TIM_HandleTypeDef *htim, uint32_t ch,
		GPIO_TypeDef *GPIO1, uint16_t GPIO1_Pin, GPIO_TypeDef *GPIO2,
		uint16_t GPIO2_Pin) {
	motor->htim = htim;
	motor->ch = ch;
	motor->GPIO1 = GPIO1;
	motor->GPIO1_Pin = GPIO1_Pin;
	motor->GPIO2 = GPIO2;
	motor->GPIO2_Pin = GPIO2_Pin;

}
void motor_setSpeed(uint16_t speed) {
	if (speed > 1000)
		speed = 1000;
	else if (speed <= 0)
		speed = 1;

	motor_speed = speed;
}

void motor_stop(motor_t* motorL, motor_t* motorR) {
	HAL_TIM_PWM_Stop(motorL->htim, motorL->ch);
	HAL_TIM_PWM_Stop(motorR->htim, motorR->ch);
}

void motor_forward(motor_t* motorL, motor_t* motorR) {
	// left
	__HAL_TIM_SET_COMPARE(motorL->htim, motorL->ch, motor_speed - 1);
	HAL_GPIO_WritePin(motorL->GPIO1, motorL->GPIO1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(motorL->GPIO2, motorL->GPIO2_Pin, GPIO_PIN_RESET);

	// right
	__HAL_TIM_SET_COMPARE(motorR->htim, motorR->ch, motor_speed - 1);
	HAL_GPIO_WritePin(motorR->GPIO1, motorR->GPIO1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(motorR->GPIO2, motorR->GPIO2_Pin, GPIO_PIN_RESET);

	HAL_TIM_PWM_Start(motorL->htim, motorL->ch);
	HAL_TIM_PWM_Start(motorR->htim, motorR->ch);
}

void motor_backward(motor_t* motorL, motor_t* motorR) {
	// left
	__HAL_TIM_SET_COMPARE(motorL->htim, motorL->ch, motor_speed - 1);
	HAL_GPIO_WritePin(motorL->GPIO1, motorL->GPIO1_Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(motorL->GPIO2, motorL->GPIO2_Pin, GPIO_PIN_SET);

	// right
	__HAL_TIM_SET_COMPARE(motorR->htim, motorR->ch, motor_speed - 1);
	HAL_GPIO_WritePin(motorR->GPIO1, motorR->GPIO1_Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(motorR->GPIO2, motorR->GPIO2_Pin, GPIO_PIN_SET);

	HAL_TIM_PWM_Start(motorL->htim, motorL->ch);
	HAL_TIM_PWM_Start(motorR->htim, motorR->ch);
}

void motor_right(motor_t* motorL, motor_t* motorR) {
	// left -> stop
	__HAL_TIM_SET_COMPARE(motorL->htim, motorL->ch, motor_speed - 1);
	HAL_GPIO_WritePin(motorL->GPIO1, motorL->GPIO1_Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(motorL->GPIO2, motorL->GPIO2_Pin, GPIO_PIN_RESET);

	// right -> run
	__HAL_TIM_SET_COMPARE(motorR->htim, motorR->ch, motor_speed - 1);
	HAL_GPIO_WritePin(motorR->GPIO1, motorR->GPIO1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(motorR->GPIO2, motorR->GPIO2_Pin, GPIO_PIN_RESET);

	HAL_TIM_PWM_Start(motorL->htim, motorL->ch);
	HAL_TIM_PWM_Start(motorR->htim, motorR->ch);
}

void motor_left(motor_t* motorL, motor_t* motorR) {
	// left -> run
	__HAL_TIM_SET_COMPARE(motorL->htim, motorL->ch, motor_speed - 1);
	HAL_GPIO_WritePin(motorL->GPIO1, motorL->GPIO1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(motorL->GPIO2, motorL->GPIO2_Pin, GPIO_PIN_RESET);

	// right -> stop
	__HAL_TIM_SET_COMPARE(motorR->htim, motorR->ch, motor_speed - 1);
	HAL_GPIO_WritePin(motorR->GPIO1, motorR->GPIO1_Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(motorR->GPIO2, motorR->GPIO2_Pin, GPIO_PIN_RESET);

	HAL_TIM_PWM_Start(motorL->htim, motorL->ch);
	HAL_TIM_PWM_Start(motorR->htim, motorR->ch);
}
