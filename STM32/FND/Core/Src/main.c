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

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

#define A_GPIO	GPIOA
#define A_PIN	GPIO_PIN_6
#define B_GPIO	GPIOA
#define B_PIN	GPIO_PIN_9
#define C_GPIO	GPIOB
#define C_PIN	GPIO_PIN_5
#define D_GPIO	GPIOB
#define D_PIN	GPIO_PIN_10
#define E_GPIO	GPIOA
#define E_PIN	GPIO_PIN_8
#define F_GPIO	GPIOA
#define F_PIN	GPIO_PIN_7
#define G_GPIO	GPIOB
#define G_PIN	GPIO_PIN_3
#define DP_GPIO	GPIOB
#define DP_PIN	GPIO_PIN_4

#define D1_GPIO	GPIOA
#define D1_PIN	GPIO_PIN_5
#define D2_GPIO	GPIOB
#define D2_PIN	GPIO_PIN_6
#define D3_GPIO	GPIOC
#define D3_PIN	GPIO_PIN_7
#define D4_GPIO	GPIOA
#define D4_PIN	GPIO_PIN_10

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

void on_0() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_SET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_SET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_SET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_RESET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_1() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_RESET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_RESET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_RESET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_RESET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_RESET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_2() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_RESET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_SET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_SET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_RESET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_SET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_3() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_SET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_RESET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_RESET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_SET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_4() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_RESET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_RESET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_RESET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_SET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_SET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_5() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_RESET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_SET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_RESET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_SET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_SET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_6() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_RESET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_SET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_SET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_SET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_SET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_7() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_RESET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_RESET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_RESET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_RESET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_8() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_SET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_SET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_SET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_SET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void on_9() {
	HAL_GPIO_WritePin(A_GPIO, A_PIN, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(B_GPIO, B_PIN, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(C_GPIO, C_PIN, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(D_GPIO, D_PIN, GPIO_PIN_SET); // D
	HAL_GPIO_WritePin(E_GPIO, E_PIN, GPIO_PIN_RESET); // E
	HAL_GPIO_WritePin(F_GPIO, F_PIN, GPIO_PIN_SET); // F
	HAL_GPIO_WritePin(G_GPIO, G_PIN, GPIO_PIN_SET); // G
	HAL_GPIO_WritePin(DP_GPIO, DP_PIN, GPIO_PIN_RESET); // DP
}

void turn_on(int place, int num) {
	switch (num) {
	case 0:
		on_0();
		break;
	case 1:
		on_1();
		break;
	case 2:
		on_2();
		break;
	case 3:
		on_3();
		break;
	case 4:
		on_4();
		break;
	case 5:
		on_5();
		break;
	case 6:
		on_6();
		break;
	case 7:
		on_7();
		break;
	case 8:
		on_8();
		break;
	case 9:
		on_9();
		break;
	}

	HAL_GPIO_WritePin(D1_GPIO, D1_PIN, GPIO_PIN_SET); // D1
	HAL_GPIO_WritePin(D2_GPIO, D2_PIN, GPIO_PIN_SET); // D2
	HAL_GPIO_WritePin(D3_GPIO, D3_PIN, GPIO_PIN_SET); // D3
	HAL_GPIO_WritePin(D4_GPIO, D4_PIN, GPIO_PIN_SET); // D4

	switch (place) {
	case 1:
		HAL_GPIO_WritePin(D1_GPIO, D1_PIN, GPIO_PIN_RESET); // D1
		break;
	case 2:
		HAL_GPIO_WritePin(D2_GPIO, D2_PIN, GPIO_PIN_RESET); // D2
		break;
	case 3:
		HAL_GPIO_WritePin(D3_GPIO, D3_PIN, GPIO_PIN_RESET); // D3
		break;
	case 4:
		HAL_GPIO_WritePin(D4_GPIO, D4_PIN, GPIO_PIN_RESET); // D4
		break;
	}

	HAL_Delay(1);
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
	/* USER CODE BEGIN 2 */
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET); // D1
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, GPIO_PIN_SET); // D2
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, GPIO_PIN_SET); // D3
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_SET); // D4

	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, GPIO_PIN_SET); // A
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9, GPIO_PIN_SET); // B
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_5, GPIO_PIN_SET); // C
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, GPIO_PIN_SET); // D
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_8, GPIO_PIN_SET); // E
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, GPIO_PIN_SET); // F
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_3, GPIO_PIN_SET); // G
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_4, GPIO_PIN_SET); // DP
	/* USER CODE END 2 */

	/* Infinite loop */
	/* USER CODE BEGIN WHILE */
	int i = 0;
	int t = 0;

	while (1) {
		int i_1, i_10, i_100, i_1000;
		while (i < 10000) {
			i++;

			i_1 = i % 10;
			i_10 = (i / 10) % 10;
			i_100 = (i / 100) % 10;
			i_1000 = (i / 1000) % 10;

			t = 0;
			while (t < 100) {
				for (int j = 1; j < 5; j++) {
					t ++;
					switch (j) {
					case 1:
						turn_on(j, i_1000);
						break;
					case 2:
						turn_on(j, i_100);
						break;
					case 3:
						turn_on(j, i_10);
						break;
					case 4:
						turn_on(j, i_1);
						break;
					}
				}
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
	__HAL_RCC_GPIOB_CLK_ENABLE();
	__HAL_RCC_GPIOC_CLK_ENABLE();

	/*Configure GPIO pin Output Level */
	HAL_GPIO_WritePin(GPIOA,
			GPIO_PIN_5 | GPIO_PIN_6 | GPIO_PIN_7 | GPIO_PIN_8 | GPIO_PIN_9
					| GPIO_PIN_10, GPIO_PIN_RESET);

	/*Configure GPIO pin Output Level */
	HAL_GPIO_WritePin(GPIOB,
	GPIO_PIN_10 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_6,
			GPIO_PIN_RESET);

	/*Configure GPIO pin Output Level */
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, GPIO_PIN_RESET);

	/*Configure GPIO pins : PA5 PA6 PA7 PA8
	 PA9 PA10 */
	GPIO_InitStruct.Pin = GPIO_PIN_5 | GPIO_PIN_6 | GPIO_PIN_7 | GPIO_PIN_8
			| GPIO_PIN_9 | GPIO_PIN_10;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

	/*Configure GPIO pins : PB10 PB3 PB4 PB5
	 PB6 */
	GPIO_InitStruct.Pin = GPIO_PIN_10 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5
			| GPIO_PIN_6;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

	/*Configure GPIO pin : PC7 */
	GPIO_InitStruct.Pin = GPIO_PIN_7;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

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
