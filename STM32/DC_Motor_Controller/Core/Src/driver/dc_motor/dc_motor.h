/*
 * dc_motor.h
 *
 *  Created on: 2026. 11. 11.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_DC_MOTOR_DC_MOTOR_H_
#define SRC_DRIVER_DC_MOTOR_DC_MOTOR_H_

#include "stm32f4xx_hal.h"

#define MOTOR_LEFT1_GPIO	GPIOB
#define MOTOR_LEFT1_PIN		GPIO_PIN_6
#define MOTOR_LEFT2_GPIO	GPIOA
#define MOTOR_LEFT2_PIN		GPIO_PIN_7
#define MOTOR_RIGHT1_GPIO	GPIOA
#define MOTOR_RIGHT1_PIN	GPIO_PIN_5
#define MOTOR_RIGHT2_GPIO	GPIOA
#define MOTOR_RIGHT2_PIN	GPIO_PIN_6

typedef struct {
	TIM_HandleTypeDef *htim;
	uint32_t ch;
	GPIO_TypeDef *GPIO1;
	uint16_t GPIO1_Pin;
	GPIO_TypeDef *GPIO2;
	uint16_t GPIO2_Pin;
} motor_t;

typedef enum {
	STOP, FORWARD, BACKWARD, LEFT, RIGHT
} motor_state_t;

void motor_init(motor_t *motor, TIM_HandleTypeDef *htim, uint32_t ch,
		GPIO_TypeDef *GPIO1, uint16_t GPIO1_Pin, GPIO_TypeDef *GPIO2,
		uint16_t GPIO2_Pin);
void motor_setSpeed(uint16_t speed);
void motor_stop(void);
void motor_forward(void);
void motor_backward(void);
void motor_right(void);
void motor_left(void);

#endif /* SRC_DRIVER_DC_MOTOR_DC_MOTOR_H_ */
