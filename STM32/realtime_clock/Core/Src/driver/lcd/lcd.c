/*
 * lcd.c
 *
 *  Created on: 2026. 10. 21.
 *      Author: kccistc
 */
#include "lcd.h"

#define	LCD_RS	0
#define LCD_RW	1
#define LCD_E	2
#define LCD_BL	3
#define LCD_ADR 0x27

extern I2C_HandleTypeDef hi2c1;

uint8_t lcdData = 0; // core data

void Lcd_sendData(uint8_t data) {
	HAL_I2C_Master_Transmit(&hi2c1, LCD_ADR << 1, &data, 1, 100);
}

// rs pin(bit[0]) low = cmd mode
void Lcd_cmdMode(void) {
	lcdData &= ~(1 << LCD_RS);
}

// rs pin(bit[0]) high = data mode
void Lcd_dataMode(void) {
	lcdData |= (1 << LCD_RS);
}

// r/w pin(bit[1]) low = write to device
void Lcd_writeMode(void) {
	lcdData &= ~(1 << LCD_RW);
}

// r/w pin(bit[1]) high = read from device
void Lcd_readMode(void) {
	lcdData |= (1 << LCD_RW);
}

// enable pin(bit[2]) high = ready to read data
void Lcd_enHigh(void) {
	lcdData |= (1 << LCD_E);
	Lcd_sendData(lcdData);
//	HAL_Delay(1);
}

// enable pin(bit[2]) low (하강엣지에) = read data
void Lcd_enLow(void) {
	lcdData &= ~(1 << LCD_E);
	Lcd_sendData(lcdData);
//	HAL_Delay(1);
}

// bl pin(bit[2]) high = backlight on
void Lcd_backlightOn(void) {
	lcdData |= (1 << LCD_BL);
	Lcd_sendData(lcdData);
}

// bl pin(bit[2]) low == backlight off
void Lcd_backlightOff(void) {
	lcdData &= ~(1 << LCD_BL);
	Lcd_sendData(lcdData);
}

void Lcd_writeNibble(uint8_t data) {
	Lcd_enHigh();
	// lcd 데이터의 하위 4bit (3:0, rs, rw, e, bl) + 상위 4bit(7:4)는 데이터
	lcdData = (lcdData & 0x0f) | (data & 0xf0);
	Lcd_sendData(lcdData);
	Lcd_enLow();
}

void Lcd_writeByte(uint8_t data) {
	// 상위 4bit 보내기
	Lcd_writeNibble(data);
	// 하위 4bit를 상위 4bit에 위치하게 만들기
	data <<= 4;
	// 하위 4bit 보내기
	Lcd_writeNibble(data);
}

void Lcd_writeCmdData(uint8_t data) {
	// 1. RS pin HIGH(data) / LOW(command)
	Lcd_cmdMode(); // rs pin low
	// 2. R/W pin HIGH(read) / LOW(write)
	Lcd_writeMode();
	// 3. send data (enable + data bit)
	Lcd_writeByte(data); // 4bit * 2회 send
}

void Lcd_writeCharData(uint8_t data) {
	// 1. RS pin HIGH(data) / LOW(command)
	Lcd_dataMode(); // rs pin low
	// 2. R/W pin HIGH(read) / LOW(write)
	Lcd_writeMode();
	// 3. send data (enable + data bit)
	Lcd_writeByte(data); // 4bit * 2회 send
}

void Lcd_init(void) {
	HAL_Delay(40);
	Lcd_cmdMode();
	Lcd_writeMode();
	Lcd_writeNibble(0x30);
	HAL_Delay(5);
	Lcd_writeNibble(0x30);
	HAL_Delay(1);
	Lcd_writeNibble(0x30);

	Lcd_writeNibble(0x20);
	Lcd_writeByte(0x28); // function set 4bit
	Lcd_writeByte(0x08); // display off
	Lcd_writeByte(0x01); // display clear
	Lcd_writeByte(0x06); // entry mode set
	// 초기화 끝

	Lcd_writeByte(0x0C); // display on
	Lcd_backlightOn(); // backlight on
}

void Lcd_writeString(char *str) {
	for (int i=0; str[i]; i++) {
		Lcd_writeCharData(str[i]);
	}
}

void Lcd_gotoXY(uint8_t row, uint8_t col) {
	col %= 16;
	row %= 2;

	uint8_t lcdRegAddr = (0x40 * row) + col;
	uint8_t cmd = 0x80 + lcdRegAddr;
	Lcd_writeCmdData(cmd);
}

void Lcd_writeStringXY(uint8_t row, uint8_t col, char* str) {
	Lcd_gotoXY(row, col);
	Lcd_writeString(str);
}
