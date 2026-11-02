/*
 * fnd.c
 *
 *  Created on: 2026. 10. 14.
 *      Author: kccistc
 *
 *      순서: define -> 자료형 정의 -> 함수
 */

#include "fnd.h"

#define D1_GPIO	GPIOA
#define D1_PIN	GPIO_PIN_5
#define D2_GPIO	GPIOB
#define D2_PIN	GPIO_PIN_6
#define D3_GPIO	GPIOC
#define D3_PIN	GPIO_PIN_7
#define D4_GPIO	GPIOA
#define D4_PIN	GPIO_PIN_10

#define ALL_SET		10
#define ALL_RESET	11

// 구조체 정의
// struct seg_port seg_a 이런식으로 씀
//struct seg_port {
//	GPIO_TypeDef *GPIOx;
//	uint16_t GPIO_Pin;
//};
// 자료형 정의
// seg_port seg_a 이런식으로 씀
typedef struct {
	GPIO_TypeDef *GPIOx;
	uint16_t GPIO_Pin;
} seg_port;

static void fnd_all_off();
static void fnd_sel_digit(int digit);
static void fnd_disp_number(int num);
static void fnd_show_one_digit(int num, int idx);
static void fnd_show_number_old(int num);

// 외부 사용 금지: static 이 파일 내에서만 쓰겠다
static void fnd_all_off() {
	HAL_GPIO_WritePin(D1_GPIO, D1_PIN, GPIO_PIN_SET); // D1
	HAL_GPIO_WritePin(D2_GPIO, D2_PIN, GPIO_PIN_SET); // D2
	HAL_GPIO_WritePin(D3_GPIO, D3_PIN, GPIO_PIN_SET); // D3
	HAL_GPIO_WritePin(D4_GPIO, D4_PIN, GPIO_PIN_SET); // D4
}

static void fnd_sel_digit(int digit) {
	fnd_all_off();

	switch (digit) {
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
}

static void fnd_disp_number(int num) {

	// 구조체 배열
	seg_port seg_font[8] = { { GPIOA, GPIO_PIN_6 }, // A
			{ GPIOA, GPIO_PIN_9 }, // B
			{ GPIOB, GPIO_PIN_5 }, // C
			{ GPIOB, GPIO_PIN_10 }, // D
			{ GPIOA, GPIO_PIN_8 }, // E
			{ GPIOA, GPIO_PIN_7 }, // F
			{ GPIOB, GPIO_PIN_3 }, // G
			{ GPIOB, GPIO_PIN_4 } // DP
	};

	// 2차원 배열
	int seg_font_data[12][8] = { { 1, 1, 1, 1, 1, 1, 0, 0 }, // 0
			{ 0, 1, 1, 0, 0, 0, 0, 0 }, // 1
			{ 1, 1, 0, 1, 1, 0, 1, 0 }, // 2
			{ 1, 1, 1, 1, 0, 0, 1, 0 }, // 3
			{ 0, 1, 1, 0, 0, 1, 1, 0 }, // 4
			{ 1, 0, 1, 1, 0, 1, 1, 0 }, // 5
			{ 1, 0, 1, 1, 1, 1, 1, 0 }, // 6
			{ 1, 1, 1, 0, 0, 0, 0, 0 }, // 7
			{ 1, 1, 1, 1, 1, 1, 1, 0 }, // 8
			{ 1, 1, 1, 1, 0, 1, 1, 0 }, // 9
			{ 1, 1, 1, 1, 1, 1, 1, 1 }, // set all
			{ 0, 0, 0, 0, 0, 0, 0, 0 }  // reset all
	};

	for (int i = 0; i < 8; i++) {
		HAL_GPIO_WritePin(seg_font[i].GPIOx, seg_font[i].GPIO_Pin,
				seg_font_data[num][i]);
	}
}

static void fnd_show_one_digit(int num, int idx) {
	// display digit in D idx
	fnd_disp_number(num);
	fnd_sel_digit(idx);
	HAL_Delay(1);

	fnd_all_off();
}

void fnd_show_number(int num) {
	int temp;
	temp = num;

	for (int i = 4; i >= 1; i--) {
		fnd_show_one_digit(temp % 10, i);
		temp = temp / 10;
	}
}

static void fnd_show_number_old(int num) {
	static int state = 0;

	switch (state) {
	case 0:
		fnd_disp_number(num);
		fnd_sel_digit(1);
		break;
	case 1:
		fnd_disp_number(num);
		fnd_sel_digit(2);
		break;
	case 2:
		fnd_disp_number(num);
		fnd_sel_digit(3);
		break;
	case 3:
		fnd_disp_number(num);
		fnd_sel_digit(4);
		break;
	}

	HAL_Delay(1);
	fnd_all_off();

	state = (state + 1) % 4;
}
