/*
 * rtc.c
 *
 *  Created on: 2026. 10. 21.
 *      Author: kccistc
 */
#include "rtc.h"

#define RTC_SEC		0x00
#define RTC_MIN		0x01
#define RTC_HOUR	0x02
#define RTC_DAY		0x03
#define RTC_DATE	0x04
#define	RTC_MON		0x05
#define RTC_YEAR	0x06
#define RTC_CNTL	0x0F

#define OSF_FLAG	7

#define RTC_ADR		0x68

extern I2C_HandleTypeDef hi2c1;

rtc_clock_t clockData;
rtc_clock_t clockData_decoded;
rtc_date_t dateData;
rtc_date_t dateDate_decoded;

// 10을 보내고 싶다면 0x10을 보내기 (BCD)
void Rtc_sendData(uint8_t adr, uint8_t *data, uint8_t size) {
	// 8bit 중 상위 7bit = device address / 1bit = r/w라서 << 1 해준것
//	HAL_I2C_Master_Transmit(&hi2c1, RTC_ADR << 1, &adr, 1, 100);
//	HAL_I2C_Master_Transmit(&hi2c1, RTC_ADR << 1, data, size, 100);
	HAL_I2C_Mem_Write(&hi2c1, RTC_ADR << 1, adr, 1, data, size, 100);
}

// 0x10을 받았다면 10으로 해석 (BCD)
void Rtc_receiveData(uint8_t adr, uint8_t *data, uint8_t size) {
//	HAL_I2C_Master_Transmit(&hi2c1, RTC_ADR << 1, &adr, 1, 100);
//	HAL_I2C_Master_Receive(&hi2c1, RTC_ADR << 1, data, size, 100); // 4byte
	HAL_I2C_Mem_Read(&hi2c1, RTC_ADR << 1, adr, 1, data, size, 100);
}

void Rtc_decodeDateData() {
	dateDate_decoded.day = dateData.day;
	dateDate_decoded.date = (dateData.date >> 4) * 10
			+ (dateData.date & (0b1111));
	dateDate_decoded.mon = (((dateData.mon & (1 << 4)) >> 4) * 10)
			+ (dateData.mon & (0b1111));
	dateDate_decoded.year_century = (dateData.mon >> 7) ? 21 : 20;
	dateDate_decoded.year = ((dateData.year >> 4) * 10)
			+ (dateData.year & (0b1111));
}

void Rtc_decodeClockData() {
	clockData_decoded.sec = (clockData.sec >> 4) * 10
			+ (clockData.sec & 0b1111);
	clockData_decoded.min = (clockData.min >> 4) * 10
			+ (clockData.min & 0b1111);
	clockData_decoded.hour =
			(clockData.hour >> 6) ?
					((clockData.hour & (1 << 5)) >> 5) * 12
							+ ((clockData.hour & (1 << 4)) >> 4) * 10
							+ (clockData.hour & 0b1111) :
					(clockData.hour >> 4) * 10 + (clockData.hour & 0b1111);
}

void Rtc_encodeClockData() {
	clockData.sec = ((clockData_decoded.sec / 10) << 4)
			| (clockData_decoded.sec % 10);
	clockData.min = ((clockData_decoded.min / 10) << 4)
			| (clockData_decoded.min % 10);
	clockData.hour = ((clockData_decoded.hour / 10) << 4)
			| (clockData_decoded.hour % 10); // bit6 = 0 → 24시간 모드
}

void Rtc_encodeDateData() {
	dateData.day = dateDate_decoded.day & 0b111;
	dateData.date = ((dateDate_decoded.date / 10) << 4)
			| (dateDate_decoded.date % 10);
	dateData.mon = ((dateDate_decoded.mon / 10) << 4)
			| (dateDate_decoded.mon % 10)
			| ((dateDate_decoded.year_century == 21) ? (1 << 7) : 0);
	dateData.year = ((dateDate_decoded.year / 10) << 4)
			| (dateDate_decoded.year % 10);
}

void Rtc_setClockData(rtc_clock_t *clk) {
	clockData_decoded.sec = clk->sec;
	clockData_decoded.min = clk->min;
	clockData_decoded.hour = clk->hour;
	Rtc_encodeClockData();

	uint8_t data[] = { clockData.sec, clockData.min, clockData.hour };
	Rtc_sendData(RTC_SEC, data, 3);
}

void Rtc_setDateData(rtc_date_t *date) {
	dateDate_decoded.day = date->day;
	dateDate_decoded.date = date->date;
	dateDate_decoded.mon = date->mon;
	dateDate_decoded.year = date->year;
	dateDate_decoded.year_century = date->year_century;
	Rtc_encodeDateData();

	uint8_t data[] =
			{ dateData.day, dateData.date, dateData.mon, dateData.year };
	Rtc_sendData(RTC_DAY, data, 4);
}

void Rtc_receiveClockData() {
	uint8_t data[3];
	Rtc_receiveData(RTC_SEC, data, 3);

	clockData.sec = data[0];
	clockData.min = data[1];
	clockData.hour = data[2];
	Rtc_decodeClockData();
}

void Rtc_receiveDateData() {
	uint8_t data[4];
	Rtc_receiveData(RTC_DAY, data, 4);

	dateData.day = data[0];
	dateData.date = data[1];
	dateData.mon = data[2];
	dateData.year = data[3];
	Rtc_decodeDateData();
}

rtc_clock_t* Rtc_getClockData() {
	Rtc_receiveClockData();
	return &clockData_decoded;
}

rtc_date_t* Rtc_getDateData() {
	Rtc_receiveDateData();
	return &dateDate_decoded;
}

void Rtc_init() {
	uint8_t data;
	Rtc_receiveData(RTC_CNTL, &data, 1);

	rtc_clock_t clk;
	rtc_date_t date;

	clk.sec = 0;
	clk.min = 0;
	clk.hour = 0;

	date.day = 4;
	date.date = 21;
	date.mon = 10;
	date.year = 26;
	date.year_century = 20;

	// 완전히 종료되어 시간이 리셋
	if (data & (1 << OSF_FLAG)) {
		Rtc_setClockData(&clk);
		Rtc_setDateData(&date);
		data |= (1 << OSF_FLAG);
		Rtc_sendData(RTC_CNTL, &data, 1);
	}

	Rtc_receiveClockData();
	Rtc_receiveDateData();
}
