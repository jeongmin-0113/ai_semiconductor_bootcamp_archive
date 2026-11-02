/*
 * queue_buffer.c
 *
 *  Created on: 2026. 10. 30.
 *      Author: kccistc
 */
#include "queue_buffer.h"

void queue_buf_init(queue_buf_t *q, void *storage, uint16_t elem_size,
		uint16_t capacity) {
	q->head = 0;
	q->tail = 0;
	q->isFull = false;
	q->isEmpty = true;

	q->buf = (uint8_t*) storage;
	q->element_size = elem_size;
	q->capacity = capacity;
}

uint8_t* slot(queue_buf_t *q, uint16_t n) {
	return (uint8_t*) (q->buf + n * q->element_size);
}

uint16_t next(queue_buf_t *q, uint16_t idx) {
	return (uint16_t) ((idx + 1) % q->capacity);
}

bool queue_push(queue_buf_t *q, void *element) {
	if (q->isFull)
		return false;
	if (q->isEmpty)
		q->isEmpty = false;

	// buf가 8bit짜리라서 data 4byte짜리 가져오려면 주소 4씩 증가시켜야함
	// q->buf + q->head * q->element_size = *element;
	memcpy(slot(q, q->head), element, q->element_size);
//	q->head = (q->head + 1) % q->capacity;
	q->head = next(q, q->head);

	if (q->head == q->tail)
		q->isFull = true;
	return true;
}

bool queue_pop(queue_buf_t *q, void *element) {
	if (q->isEmpty)
		return false;
	if (q->isFull)
		q->isFull = false;

//	*element = q->buf + q->tail * q->element_size;
	memcpy(element, slot(q, q->tail), q->element_size);
//	q->tail = (q->tail + 1) % q->capacity;
	q->tail = next(q, q->tail);

	if (q->head == q->tail)
		q->isEmpty = true;
	return true;
}

bool queue_isFull(queue_buf_t *q) {
	return q->isFull;
}

bool queue_isEmpty(queue_buf_t *q) {
	return q->isEmpty;
}
