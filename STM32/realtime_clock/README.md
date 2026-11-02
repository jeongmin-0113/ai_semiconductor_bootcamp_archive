# realtime_clock — DS3231 RTC 모듈로 실제 시계 만들기

> 📅 2026-10-21 · 보드: NUCLEO-F411RE

[clock_I2C_LCD](../clock_I2C_LCD)의 I2C LCD 시계에 **DS3231 RTC(Real Time Clock) 모듈**을 같은 I2C 버스에 붙여서, 전원이 꺼져도 시간이 유지되는 실제 시계를 만듦.
처음으로 데이터시트만 보고 I2C 디바이스 드라이버(`driver/rtc`)를 직접 작성함.

## 파일 구조

```
Core/Src/
├── main.c
├── ap/
│   ├── ap_main.c
│   ├── StopWatch/  TimeClock/  Display/
└── driver/
    ├── button/  led/  fnd/  lcd/
    └── rtc/               # DS3231 드라이버
```

## 사용 핀 / 설정

| 항목 | 설정 |
|---|---|
| I2C1 (PB8 SCL / PB9 SDA) | LCD (0x27) + DS3231 (0x68) 같은 버스에 연결 |
| TIM3 | PSC 100, ARR 1000 → 1ms (FND 출력) |
| TIM4 | PSC 1000, ARR 1000 → 10ms (시간 카운트) |
| 버튼 / LED / FND | [upcounter_stopwatch](../upcounter_stopwatch)와 동일 |

---

## 실습: realtime 모듈 붙여서 실제 시계 만들기

> 1. DS3231 Driver를 만드시오
> 2. 시계 모드일 때 LCD
>    | 1번째 줄 | 시 : 분 : 초 |
>    |---|---|
>    | 2번째 줄 | 년 . 월 . 일 . 요일 |
> 3. StopWatch 모드일 때 LCD
>    | 1번째 줄 | 시 : 분 : 초 (시계) |
>    |---|---|
>    | 2번째 줄 | 시 : 분 : 초 : ms (StopWatch) |

### ds3231 datasheet

- [DS3231 datasheet (Analog Devices)](https://www.analog.com/media/en/technical-documentation/data-sheets/ds3231.pdf)

**Timekeeping registers** (데이터시트 Figure 1 중 시간·날짜 부분)

| 주소 | bit 7 | bit 6 | bit 5 | bit 4 | bit 3~0 | 기능 | 범위 |
|---|---|---|---|---|---|---|---|
| 00h | 0 | 10 Seconds | | | Seconds | 초 | 00–59 |
| 01h | 0 | 10 Minutes | | | Minutes | 분 | 00–59 |
| 02h | 0 | 12/24 | AM/PM · 20 Hour | 10 Hour | Hour | 시 | 1–12 + AM/PM / 00–23 |
| 03h | 0 | 0 | 0 | 0 | 0 + Day | 요일 | 1–7 |
| 04h | 0 | 0 | 10 Date | | Date | 일 | 01–31 |
| 05h | Century | 0 | 0 | 10 Month | Month | 월 / 세기 | 01–12 + Century |
| 06h | 10 Year | | | | Year | 년 | 00–99 |
| 0Fh | **OSF** | 0 | 0 | 0 | EN32kHz, BSY, A2F, A1F | Control/Status | — |

- 값은 **BCD 코드**로 저장되어있다 → 예) 10초면 0x10
  - 상위 4bit = 10의 자리, 하위 4bit = 1의 자리
- 03h~06h는 달력 (요일, 날짜, 월/세기, 년)
- OSF (Oscillator Stop Flag): 전원이 완전히 끊겨 시간이 멈췄으면 1 → 이때만 시간을 다시 세팅

### data write 하는 방법

| S | 1101000 | W(0) | A | Word Address (n) | A | DATA (n) | A | DATA (n+1) | A | … | P |
|---|---|---|---|---|---|---|---|---|---|---|---|
| start | slave 주소 0x68 | write | ack | 레지스터 주소 | ack | 예) 초 | ack | 예) 분 | ack | | stop |

1. start 신호
2. SLA + W
3. Register 주소
4. Reg 주소 위치의 Data 값
5. (Reg 주소 + 1)의 Data 값 …
6. stop 신호

- DS3231 (only I2C) 주소: 1101000 → 0x68
- word address: 접근할 데이터의 레지스터 주소
  - 이걸 보내주면 해당하는 function - 데이터를 받을 수 있다
  - function에 있는 데이터들은 예) 10초면 0x10 → BCD 코드로 저장되어있다
  - data를 또 보내면 다음 주소에 위치한 데이터에 접근 (초 → 분 → 시 그 뒤까지 계속 보내면 계속 접근 가능함)
- 마지막엔 stop (I2C 프로토콜에 맞춰서)

#### data read하는 방법

| S | 0x68 + W | A | Word Address (n) | A | **Sr** | 0x68 + R | A | DATA (n) | A | DATA (n+1) | A | … | DATA (n+X) | **NACK** | P |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

예) 달력 읽기 (0x03 요일, 0x04 날짜, 0x05 월, 0x06 년도)

1. start → 2. 0x68 + W → 3. Reg 주소 요일(0x03) → 4. repeated start → 5. 0x68 + R
6. Read(요일) → 7. Read(날짜) → 8. Read(월) → 9. Read(년도) → 10. NACK (더이상 Data 전송하지 마!) → 11. stop

- read라서 r/w == 1
- master가 slave한테 address + r/w 전송하면 slave는 해당하는 ack 보낸 후 data 전송함
- data 수신받는대로 slave한테 ack 보내면 됨
- 근데 어디를 읽음?
  - 먼저 레지스터 주소를 write하고
  - 다음에 read하겠다고 말하면 됨!
- Sr: repeated start → start 신호를 또 보낸다!
- start 다음엔 무조건 주소야 → 그러니까 write 하고 바로 read하고 싶으면 start와 함께 다시 address와 read를 보내면 된다!
- 이렇게 보내면 word address → 해당하는 레지스터 주소부터 read한다!
- A바: NACK → 더이상 data 전송하지 말라고 slave한테 전송
- 받을거 다 받았으면 nack 보내고 stop하면 됨
- ack와 nack (9번째 clock에서)
  - ack: SCL이 high인 동안 SDA를 **low**로 유지
  - nack: SCL이 high인 동안 SDA가 **high** 유지

### ds3231 driver

전체 코드: [`Core/Src/driver/rtc/rtc.c`](Core/Src/driver/rtc/rtc.c)

```c
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
```

- `HAL_I2C_Mem_Write` / `HAL_I2C_Mem_Read`: 레지스터 주소 전송 + data 전송/수신(repeated start)을 한 번에 해주는 HAL 함수

### i2c 정리

- i2c는 한 bus를 통해 다양한 기능 접근 → 느리다
- 충돌 방지 - 순차적으로 통신해야함 → 느리다
- 빠르지 않은 기능들에 대해 쓴다
- 저렴하기 때문에 많이 쓴다
- 동영상 출력같은건 못함

> 드라이버 구조를 다시 정리한 버전은 [realtime_clock_review](../realtime_clock_review)
