/*
 * rtc.h
 *
 *  Created on: 2026. 10. 21.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_RTC_RTC_H_
#define SRC_DRIVER_RTC_RTC_H_

#include "stm32f4xx_hal.h"

typedef struct {
	int8_t sec; // 1bit 0 + 3bit 십의자리 + 4bit 1의자리
	int8_t min; // 1bit 0 + 3bit 십의자리 + 4bit 1의자리
	int8_t hour; // 1bit 0 + 1bit (12/24 시간제) + 1bit (am/pm 혹은 20의 자리) + 1bit 십의자리 + 4bit 1의자리
} rtc_clock_t;

typedef struct {
	int8_t day; // 5bit 0 + 3bit 요일 (1-7) (1 = 일요일)
	int8_t date; // 2bit 0 + 2bit 10의자리 + 4bit 1의자리
	int8_t mon; // 1bit 세기 정보 (0: 19xx, 1:20xx) + 2bit 0 + 1bit 10의자리 + 4bit 1의자리
	int8_t year; // 4bit 10의자리 + 4bit 1의자리
	int8_t year_century; // 19 / 20
} rtc_date_t;

void Rtc_init();
void Rtc_setClockData(rtc_clock_t *clk);
void Rtc_setDateData(rtc_date_t *date);
rtc_clock_t* Rtc_getClockData();
rtc_date_t* Rtc_getDateData();

#endif /* SRC_DRIVER_RTC_RTC_H_ */
