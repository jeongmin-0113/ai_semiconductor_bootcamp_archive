# STM32

NUCLEO-F411RE (STM32F411RET6) · STM32CubeIDE · HAL

| 날짜 | 프로젝트 | 내용 |
|---|---|---|
| 10/12 | [LedBlink](LedBlink) | CubeMX/CubeIDE 세팅, 클럭 설정, GPIO로 LED 점멸·버튼 입력 |
| 10/13 | [Ledblink_review](Ledblink_review) | 버튼 3개 + LED를 FSM 구조로 리팩토링 |
| 10/13 | [FND](FND) | 4자리 7-segment 다이나믹 구동, 9999 카운터 |
| 10/13~15 | [C_Lang](C_Lang) | 임베디드 C 문법 (컴파일 과정, 엔디안, 포인터, 배열, 구조체, 전처리) |
| 10/14 | [FND_review](FND_review) | 구조체·배열로 FND 코드 정리, 드라이버 분리, SW 스택 구조 |
| 10/14 | [Stopwatch](Stopwatch) | 논블로킹 버튼 디바운서 + FSM 스톱워치 |
| 10/15 | [baremetal_gpio](baremetal_gpio) | HAL 없이 레지스터 직접 제어 (RCC, MODER, ODR, BSRR) |
| 10/16 | [LED_Button](LED_Button) | LED / Button 드라이버 작성 |
| 10/16 | [upcounter_stopwatch](upcounter_stopwatch) | 타이머 인터럽트(TIM2/TIM3) 스톱워치 + 시계 |
| 10/19 | [stopwatch_watch_review](stopwatch_watch_review) | 인터럽트 동작 원리 (벡터 테이블, ISR, 콜백), TIM4 |
| 10/20 | [stopwatch_timeclock_I2C_LCD](stopwatch_timeclock_I2C_LCD) | 코어 / 디스플레이 모듈 분리 (결합도 낮추기) |
| 10/20~21 | [clock_I2C_LCD](clock_I2C_LCD) | I2C 프로토콜, I2C LCD 드라이버 |
| 10/21 | [realtime_clock](realtime_clock) | DS3231 RTC 드라이버 작성, write / read (repeated start) |
| 10/22 | [realtime_clock_review](realtime_clock_review) | DS3231 드라이버 리뷰 (중심 데이터 → 접근 함수), 로직 분석기 |
| 10/23 | [stepmotor](stepmotor) | 스텝모터 + ULN2003, 1-2상 여자, auto-reload preload |
| 10/23~26 | [proj_analog_clock_stopwatch](https://github.com/jeongmin-0113/proj_analog_clock_stopwatch) (별도 레포) | 프로젝트: 스텝모터 아날로그 시계 + 디지털 시계 / 스톱워치 |
| 10/27 | [dht11](dht11) | DHT11 1-wire 프로토콜 직접 구현, UART printf |
| 10/28 | [dht11_temp_humid](dht11_temp_humid) | DHT11 드라이버 리뷰, BSP / service 구조, pull 방식 |
| 10/28 | [dht11_sr04](dht11_sr04) | HC-SR04 초음파 센서 (EXTI + 타이머 카운터) |
| 10/29 | [dht11_sr04_review](dht11_sr04_review) | 초음파 드라이버 리뷰, Timer PWM (ARR / CCR) |
| 10/29~30 | [buzzer](buzzer) | PWM 부저 음계, Queue (링 버퍼) |
| 10/30 | [digital_clock_all_in_one](digital_clock_all_in_one) | DHT11 + SR04 + 부저 + Queue 디지털 시계 통합 |
| 11/02 | [SmartWatch_review](SmartWatch_review) | 스마트 워치 구조 리뷰 (작업 중) |
| 11/03 | [ADC](ADC) | 조도센서 · 조이스틱 ADC, polling → interrupt → continuous → DMA |
| 11/04~05 | [uart_protocol](uart_protocol) | UART 바이너리 프레임 (START/LEN/CMD/CHK), 1byte FSM 파서, 함수 포인터 콜백 |
| 11/10 | [RTOS_test](RTOS_test) | FreeRTOS task · 스케줄링, task로 나눈 FND 카운터, ITM printf |
| 11/11 | [DC_Motor_Controller](DC_Motor_Controller) | L298N DC 모터 PWM 속도 / 방향 제어, 버튼 FSM |

## 빌드

저장소에는 직접 작성한 코드와 설정 파일만 올림 (`Core/`, `.ioc`, `.project`, `.cproject`, 링커 스크립트).
HAL / CMSIS 라이브러리(`Drivers/`)는 `.ioc`로 다시 생성할 수 있어서 제외함.

1. STM32CubeIDE → `File > Import > Existing Projects into Workspace` → 프로젝트 폴더 선택
2. `.ioc` 파일 열기 → `Project > Generate Code` (`Drivers/` 생성)
3. Build

(`C_Lang`은 CMake/`STM32CubeIDE/` 하위 구조라 해당 폴더를 import)
