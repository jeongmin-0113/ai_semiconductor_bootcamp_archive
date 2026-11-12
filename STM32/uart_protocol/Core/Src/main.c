/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : main.c
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2026 STMicroelectronics.
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 *
 ******************************************************************************
 */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "driver/led/led.h"
#include "driver/uart_protocol/uart_protocol.h"
#include "driver/DHT11/DHT11.h"
#include "driver/HCSR04/HCSR04.h"

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
TIM_HandleTypeDef htim10;

UART_HandleTypeDef huart2;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART2_UART_Init(void);
static void MX_TIM10_Init(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

led_t led0, led1, led2, led3;
dht11_data_t TH_data;
uint8_t distStartFlag = 0;

void packet_doFunc(uint8_t cmd, uint8_t *payload, uint8_t payload_len) {
	switch (cmd) {
	case CMD_LED0_SET: {
		// led 0 control
		// cmd = 0x10, payload = 1/0 (len = 1byte)
		// payload == 1 -> led on / payload == 0 -> led off
		uint8_t tx_payload = 0;

		if (payload_len >= 1) {
			if (payload[0] == 1) {
				led_on(&led0);
			} else {
				led_off(&led0);
			}
			tx_payload = RSP_OK;
		} else {
			tx_payload = RSP_ERROR;
		}

		UART_protocol_send(cmd + CMD_RSP_BASE, &tx_payload, 1);

		break;
	}
	case CMD_LED1_SET: {
		// led 1 control
		uint8_t tx_payload = 0;

		if (payload_len >= 1) {
			if (payload[0] == 1) {
				led_on(&led1);
			} else {
				led_off(&led1);
			}
			tx_payload = RSP_OK;
		} else {
			tx_payload = RSP_ERROR;
		}
		UART_protocol_send(cmd + CMD_RSP_BASE, &tx_payload, 1);
		break;
	}
	case CMD_LED2_SET: {
		// led 2 control
		uint8_t tx_payload = 0;
		if (payload_len >= 1) {
			if (payload[0] == 1) {
				led_on(&led2);
			} else {
				led_off(&led2);
			}
			tx_payload = RSP_OK;
		} else {
			tx_payload = RSP_ERROR;
		}
		UART_protocol_send(cmd + CMD_RSP_BASE, &tx_payload, 1);
		break;
	}
	case CMD_LED3_SET: {
		// led 3 control
		uint8_t tx_payload = 0;
		if (payload_len >= 1) {
			if (payload[0] == 1) {
				led_on(&led3);
			} else {
				led_off(&led3);
			}
			tx_payload = RSP_OK;
		} else {
			tx_payload = RSP_ERROR;
		}
		UART_protocol_send(cmd + CMD_RSP_BASE, &tx_payload, 1);
		break;
	}
	case CMD_LED_STATUS_REQ: {
		// led 0~3 state
		uint8_t tx_payload[4] = { 0, };
		led_t *led[] = { &led0, &led1, &led2, &led3 };
		for (int i = 0; i < 4; i++) {
			tx_payload[i] = (uint8_t) ((led_getState(led[i])) ? 1 : 0);
		}
		UART_protocol_send(cmd + CMD_RSP_BASE, tx_payload, 4);
		break;
	}
	case CMD_TEMP_HUMID_REQ: {
		// temp humid req
		dht11_status_t s = dht11_read(&TH_data);
//
//		// 테스트용 더미 데이터
//		uint8_t d_tInt = 21;
//		uint8_t d_tDec = 1;
//		uint8_t d_hInt = 48;
//		uint8_t d_hDec = 0;

		if (s == DHT11_OK) {
			uint8_t tx_payload[] = { TH_data.t_int, TH_data.t_dec,
					TH_data.h_int, TH_data.h_dec };
			UART_protocol_send(cmd + CMD_RSP_BASE, tx_payload, 4);
		} else {
			uint8_t tx_payload = RSP_ERROR;
			UART_protocol_send(cmd + CMD_RSP_BASE, &tx_payload, 1);
		}
		break;
	}
	case CMD_DISTANCE_REQ: {
		// sr04 req
		if (distStartFlag == 0) {
			if (HCSR04_start() == HCSR04_OK) {
				distStartFlag = 1;
			} else {
				uint8_t tx_payload = RSP_ERROR;
				UART_protocol_send(CMD_DISTANCE_REQ + CMD_RSP_BASE, &tx_payload,
						1);
			}
		}

		// 테스트용 더미 데이터
//		uint16_t dummy_distance = 287; // 0x11f (01 / 1f)
//		uint8_t tx_payload[2];
//
//		tx_payload[0] = (uint8_t) (dummy_distance >> 8); 	// 상위 8bit
//		tx_payload[1] = (uint8_t) (dummy_distance & 0xff);	// 하위 8bit
//
//		UART_protocol_send(cmd + CMD_RSP_BASE, tx_payload, 2);
		break;
	}
	}
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
	if (huart->Instance == USART2) {
		// interrupt service
		uart_protocol_it(); // 1 byte마다 인터럽트 걸리게 해서 데이터 받겠다~
	}
}

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
	if (GPIO_Pin == GPIO_PIN_6) {
		HCSR04_echoISR();
	}
}
/* USER CODE END 0 */

/**
 * @brief  The application entry point.
 * @retval int
 */
int main(void) {

	/* USER CODE BEGIN 1 */

	/* USER CODE END 1 */

	/* MCU Configuration--------------------------------------------------------*/

	/* Reset of all peripherals, Initializes the Flash interface and the Systick. */
	HAL_Init();

	/* USER CODE BEGIN Init */

	/* USER CODE END Init */

	/* Configure the system clock */
	SystemClock_Config();

	/* USER CODE BEGIN SysInit */

	/* USER CODE END SysInit */

	/* Initialize all configured peripherals */
	MX_GPIO_Init();
	MX_USART2_UART_Init();
	MX_TIM10_Init();
	/* USER CODE BEGIN 2 */
	led_init(&led0, GPIOB, GPIO_PIN_15);
	led_init(&led1, GPIOB, GPIO_PIN_14);
	led_init(&led2, GPIOB, GPIO_PIN_13);
	led_init(&led3, GPIOC, GPIO_PIN_4);

	uart_protocol_init(&huart2, packet_doFunc);
	dht11_init(GPIOC, GPIO_PIN_8);
	HCSR04_init(GPIOC, GPIO_PIN_5, GPIOC, GPIO_PIN_6, &htim10);

	/* USER CODE END 2 */

	/* Infinite loop */
	/* USER CODE BEGIN WHILE */
	while (1) {
		if (distStartFlag) {
			uint32_t dist_us = 0;
			hcsr04_status_t state = HCSR04_getResult(&dist_us);

			if (state == HCSR04_OK) {
				uint8_t tx_payload[2];
				uint32_t dist_cm = dist_us / 58;

				tx_payload[0] = (uint8_t) (dist_cm >> 8); 	// 상위 8bit
				tx_payload[1] = (uint8_t) (dist_cm & 0xff);	// 하위 8bit

				UART_protocol_send(CMD_DISTANCE_REQ + CMD_RSP_BASE, tx_payload,
						2);
				distStartFlag = 0;
			} else if (state == HCSR04_ERR_NO_ECHO) {
				uint8_t tx_payload = RSP_ERROR;
				UART_protocol_send(CMD_DISTANCE_REQ + CMD_RSP_BASE, &tx_payload,
						1);
				distStartFlag = 0;
			}
		}

		/* USER CODE END WHILE */

		/* USER CODE BEGIN 3 */
	}
	/* USER CODE END 3 */
}

/**
 * @brief System Clock Configuration
 * @retval None
 */
void SystemClock_Config(void) {
	RCC_OscInitTypeDef RCC_OscInitStruct = { 0 };
	RCC_ClkInitTypeDef RCC_ClkInitStruct = { 0 };

	/** Configure the main internal regulator output voltage
	 */
	__HAL_RCC_PWR_CLK_ENABLE();
	__HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

	/** Initializes the RCC Oscillators according to the specified parameters
	 * in the RCC_OscInitTypeDef structure.
	 */
	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
	RCC_OscInitStruct.HSEState = RCC_HSE_ON;
	RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
	RCC_OscInitStruct.PLL.PLLM = 4;
	RCC_OscInitStruct.PLL.PLLN = 100;
	RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
	RCC_OscInitStruct.PLL.PLLQ = 4;
	if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
		Error_Handler();
	}

	/** Initializes the CPU, AHB and APB buses clocks
	 */
	RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK
			| RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
	RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
	RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

	if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_3) != HAL_OK) {
		Error_Handler();
	}
}

/**
 * @brief TIM10 Initialization Function
 * @param None
 * @retval None
 */
static void MX_TIM10_Init(void) {

	/* USER CODE BEGIN TIM10_Init 0 */

	/* USER CODE END TIM10_Init 0 */

	/* USER CODE BEGIN TIM10_Init 1 */

	/* USER CODE END TIM10_Init 1 */
	htim10.Instance = TIM10;
	htim10.Init.Prescaler = 100 - 1;
	htim10.Init.CounterMode = TIM_COUNTERMODE_UP;
	htim10.Init.Period = 65535;
	htim10.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
	htim10.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
	if (HAL_TIM_Base_Init(&htim10) != HAL_OK) {
		Error_Handler();
	}
	/* USER CODE BEGIN TIM10_Init 2 */

	/* USER CODE END TIM10_Init 2 */

}

/**
 * @brief USART2 Initialization Function
 * @param None
 * @retval None
 */
static void MX_USART2_UART_Init(void) {

	/* USER CODE BEGIN USART2_Init 0 */

	/* USER CODE END USART2_Init 0 */

	/* USER CODE BEGIN USART2_Init 1 */

	/* USER CODE END USART2_Init 1 */
	huart2.Instance = USART2;
	huart2.Init.BaudRate = 115200;
	huart2.Init.WordLength = UART_WORDLENGTH_8B;
	huart2.Init.StopBits = UART_STOPBITS_1;
	huart2.Init.Parity = UART_PARITY_NONE;
	huart2.Init.Mode = UART_MODE_TX_RX;
	huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	huart2.Init.OverSampling = UART_OVERSAMPLING_16;
	if (HAL_UART_Init(&huart2) != HAL_OK) {
		Error_Handler();
	}
	/* USER CODE BEGIN USART2_Init 2 */

	/* USER CODE END USART2_Init 2 */

}

/**
 * @brief GPIO Initialization Function
 * @param None
 * @retval None
 */
static void MX_GPIO_Init(void) {
	GPIO_InitTypeDef GPIO_InitStruct = { 0 };
	/* USER CODE BEGIN MX_GPIO_Init_1 */

	/* USER CODE END MX_GPIO_Init_1 */

	/* GPIO Ports Clock Enable */
	__HAL_RCC_GPIOH_CLK_ENABLE();
	__HAL_RCC_GPIOA_CLK_ENABLE();
	__HAL_RCC_GPIOC_CLK_ENABLE();
	__HAL_RCC_GPIOB_CLK_ENABLE();

	/*Configure GPIO pin Output Level */
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_8,
			GPIO_PIN_RESET);

	/*Configure GPIO pin Output Level */
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13 | GPIO_PIN_14 | GPIO_PIN_15,
			GPIO_PIN_RESET);

	/*Configure GPIO pins : PC4 PC5 PC8 */
	GPIO_InitStruct.Pin = GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_8;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

	/*Configure GPIO pins : PB13 PB14 PB15 */
	GPIO_InitStruct.Pin = GPIO_PIN_13 | GPIO_PIN_14 | GPIO_PIN_15;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

	/*Configure GPIO pin : PC6 */
	GPIO_InitStruct.Pin = GPIO_PIN_6;
	GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING_FALLING;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

	/* EXTI interrupt init*/
	HAL_NVIC_SetPriority(EXTI9_5_IRQn, 0, 0);
	HAL_NVIC_EnableIRQ(EXTI9_5_IRQn);

	/* USER CODE BEGIN MX_GPIO_Init_2 */

	/* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
 * @brief  This function is executed in case of error occurrence.
 * @retval None
 */
void Error_Handler(void) {
	/* USER CODE BEGIN Error_Handler_Debug */
	/* User can add his own implementation to report the HAL error return state */
	__disable_irq();
	while (1) {
	}
	/* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
