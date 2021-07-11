/**
 * We made our own implementation here because
 * toolchain-provided implementation contains
 * some instructions that has a strict rule to use.
 *
 * Since we don't set up MMU, it is possible
 * to trigger data abort by those instruction.
 * (like DC ZVA, etc.)
 */

#include <stdint.h>
#include <string.h>

char* strncpy(char* dst, const char* src, size_t num) {
  size_t i = 0;
  while (i < num - 1 && src[i] != '\0') {
    dst[i] = src[i];
    i++;
  }

  dst[i] = '\0';
  return dst;
}

void bzero(void* dst, size_t len) {
  memset(dst, 0, len);
}

void* memset(void* dst, int ch, size_t len) {
  uint8_t* d = dst;
  while (len-- > 0) {
    *d++ = ch;
  }
  return dst;
}

void* memcpy(void* dst, const void* src, size_t len) {
  uint8_t* d = dst;
  const uint8_t* s = src;
  while (len-- > 0) {
    *d++ = *s++;
  }
  return dst;
}

void* memmove(void* dst, const void* src, size_t len) {
  uint8_t* d = dst + len;
  const uint8_t* s = src + len;
  while (len-- > 0) {
    *--d = *--s;
  }
  return dst;
}
