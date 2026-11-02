#include <stdint.h>
#include <stdbool.h>

#define RCC_BASE	0x40023800UL // unsigned long
#define GPIOA_BASE 	0x40020000UL // unsigned long
#define GPIOB_BASE 	0x40020400UL
#define GPIOC_BASE	0x40020800UL
#define GPIOD_BASE 	0x40020C00UL

#define	REG(addr)	(*(volatile uint32_t *)(addr))

#define RCC_AHB1ENR		REG(RCC_BASE + 0x30)

//#define GPIOA_MODER		REG(GPIOA_BASE + 0x00)
//#define GPIOA_OTYPER	REG(GPIOA_BASE + 0x04)
//#define GPIOA_OSPEEDR	REG(GPIOA_BASE + 0x08)
//#define GPIOA_PUPDR		REG(GPIOA_BASE + 0x0c)
//#define GPIOA_ODR		REG(GPIOA_BASE + 0x14)

//#define GPIOC_MODER		REG(GPIOC_BASE + 0x00)
//#define GPIOC_PUPDR		REG(GPIOC_BASE + 0x0c)
//#define GPIOC_IDR		REG(GPIOC_BASE + 0x10)

typedef struct {
	volatile uint32_t MODER; 	// offset 0x00
	volatile uint32_t OTYPER; 	// offset 0x04
	volatile uint32_t OSPEEDR; 	// offset 0x08
	volatile uint32_t PUPDR; 	// offset 0x0c
	volatile uint32_t IDR; 		// offset 0x10
	volatile uint32_t ODR; 		// offset 0x14
	volatile uint32_t BSRR; 	// offset 0x18
	volatile uint32_t LCKR; 	// offset 0x1c
	volatile uint32_t AFRL; 	// offset 0x20
	volatile uint32_t AFRH; 	// offset 0x24
} gpio_regs_t;

#define GPIOA ((gpio_regs_t *)GPIOA_BASE)
#define GPIOB ((gpio_regs_t *)GPIOB_BASE)
#define GPIOC ((gpio_regs_t *)GPIOC_BASE)
#define GPIOD ((gpio_regs_t *)GPIOD_BASE)

void delay(uint32_t n) {
	while (n--)
		;
}

typedef enum {
	GPIO_MODE_IN = 0, GPIO_MODE_OUT, GPIO_MODE_AF, GPIO_MODE_ANALOG
} gpio_mode_t;
typedef enum {
	GPIO_PULL_NONE, GPIO_PULL_UP, GPIO_PULL_DOWN
} gpio_pull_t;

void gpio_set_mode(gpio_regs_t *port, uint16_t pin, gpio_mode_t mode) {
	uint32_t v = port->MODER;

	// 00으로 먼저 해당 bit를 초기화해두고
	v &= ~(3 << (pin * 2));

	// mode에 맞게 bit 변경
	v |= ((uint32_t)mode << (pin * 2));
	port->MODER = v;
}

void gpio_set_pull(gpio_regs_t *port, uint16_t pin, gpio_pull_t pull) {
	uint32_t v = port->PUPDR;

	// 00으로 먼저 해당 bit를 초기화해두고
	v &= ~(3 << (pin * 2));

	// pull에 맞게 bit 변경
	v |= ((uint32_t)pull << (pin * 2));
	port->PUPDR = v;
}

void gpio_write(gpio_regs_t *port, uint16_t pin, bool level) {
	// BSRR = bit set/reset register
	// level이 참이면 BSRR의 pin번째 bit를 set (pin = 0이면 0번째 set)
	// level이 거짓이면 BSRR의 pin+16번째 bit를 set (pin = 0이면 16번째 set)
	port->BSRR = level ? (1 << pin) : (1 << (pin + 16));
}

bool gpio_read(const gpio_regs_t *port, uint16_t pin) {
	// idr 읽어와서 pin번째 bit가 0번째 bit가 되도록 shift
	// 0번째 bit와 1 (1bit)를 and 연산해 출력 -> 1 bit만 출력되도록
	return (port->IDR >> pin) & 1;
}

void gpio_toggle(gpio_regs_t *port, uint16_t pin) {
	// 어느 bit만 사용할건지 선택
	uint32_t mask = 1 << pin;
	uint32_t odr = port->ODR;
	// odr의 pin번째 bit만 가져와 16번 shift (brr 위치)
	// odr의 pin번째 bit에 not 취하기 (bsr 위치)
	// 둘을 합침
	// reset은 현재 상태, set은 현재 상태의 not -> toggle 된다
	// 현재상태 0 -> reset 0, set 1 -> set 된다
	// 현재상태 1 -> reset 1, set 0 -> reset 된다
	port->BSRR = ((odr & mask) << 16) | (~odr & mask);
}

int main(void) {

	// rcc base address: 0x4002_3800
	// clock enable register offset: 0x30
	// *((volatile uint32_t*) (0x40023800 + 0x30)) |= (1 << 0);	// set
	RCC_AHB1ENR |= (1 << 0); // gpioa에 clock enable
	RCC_AHB1ENR |= (1 << 2); // gpioc에 clock enable

	// pa5 = green led

	// MODE register (MODER): output 으로 설정 (01, gpo 모드)
	// moder offset: 0x00

	// gpioa base address: 0x4002_0000
	// mode register: 0x4002_0000 + 0x00
	// moder 중에 PA5 담당하는 moder5의 위치: 11:10 비트
	// gpioa의 moder[11:10] = 2b01로 만들기
//	GPIOA->MODER &= ~(1 << 11);	// reset
//	GPIOA->MODER |= (1 << 10);	// set
//
//	// output type register (OTYPER): push pull로 설정 (0)
//	// otyper offset: 0x04
//
//	// gpioa base address: 0x4002_0000
//	// otyper register: 0x4002_0000 + 0x04
//	GPIOA->OTYPER &= ~(1 << 5);	// reset
//
//	// OSPEEDR: medium speed로 설정 (01)
//	GPIOA->OSPEEDR &= ~(1 << 11);	// reset
//	GPIOA->OSPEEDR |= (1 << 10); 	// set
//
//	// PUPDR: pull up (01)
//	GPIOA->PUPDR &= ~(1 << 11);	// reset
//	GPIOA->PUPDR |= (1 << 10);	// set
//
//	// pc13 = 버튼 b1
//
//	// gpioc moder: 00 (input)
//	GPIOC->MODER &= ~(1 << 27);
//	GPIOC->MODER &= ~(1 << 26);
//
//	// gpioc pupdr: pull up (01)
//	GPIOC->PUPDR &= ~(1 << 27);
//	GPIOC->PUPDR |= (1 << 26);

	gpio_set_mode(GPIOA, 5, GPIO_MODE_OUT);
	gpio_set_mode(GPIOC, 13, GPIO_MODE_IN);
	gpio_set_pull(GPIOC, 13, GPIO_PULL_UP);
	while (1) {
		if (gpio_read(GPIOC, 13) == 0) {
			gpio_write(GPIOA, 5, 1); // odr[5] set
		} else {
			gpio_write(GPIOA, 5, 0); // odr[5] reset
		}
	}

	return 0;
}
