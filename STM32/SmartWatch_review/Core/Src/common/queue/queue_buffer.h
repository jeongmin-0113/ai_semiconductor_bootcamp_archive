/*
 * queue_buffer.h
 *
 *  Created on: 2026. 10. 30.
 *      Author: kccistc
 */

#ifndef SRC_COMMON_QUEUE_QUEUE_BUFFER_H_
#define SRC_COMMON_QUEUE_QUEUE_BUFFER_H_

#include <stdbool.h>
#include <string.h>
#include <stdint.h>

typedef struct {
	uint8_t *buf;			// 저장 공간 배열의 주소
	uint16_t element_size;  // 버퍼에 저장할 데이터 사이즈
	uint16_t capacity;		// 버퍼 크기
	volatile uint16_t head;		// 다음 데이터 push할 인덱스
	volatile uint16_t tail;		// 다음 데이터 pop할 인덱스
	volatile bool isFull;	// 버퍼 차있으면 true
	volatile bool isEmpty;	// 버퍼 비어있으면 true
} queue_buf_t;

void queue_buf_init(queue_buf_t *q, void *storage, uint16_t elem_size,
		uint16_t capacity);
bool queue_push(queue_buf_t *q, void *element);
bool queue_pop(queue_buf_t *q, void *element);
bool queue_isFull(queue_buf_t *q);
bool queue_isEmpty(queue_buf_t *q);

#endif /* SRC_COMMON_QUEUE_QUEUE_BUFFER_H_ */
