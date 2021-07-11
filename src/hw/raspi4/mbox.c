#include "port/raspi4/mbox.h"
#include "common/assert.h"
#include "port/raspi4/mmio.h"

#include <stdint.h>

#define VIDEOCORE_MBOX (MMIO_BASE + 0x0000B880)
#define MBOX_READ      ((volatile unsigned int*)(VIDEOCORE_MBOX + 0x0))
#define MBOX_POLL      ((volatile unsigned int*)(VIDEOCORE_MBOX + 0x10))
#define MBOX_SENDER    ((volatile unsigned int*)(VIDEOCORE_MBOX + 0x14))
#define MBOX_STATUS    ((volatile unsigned int*)(VIDEOCORE_MBOX + 0x18))
#define MBOX_CONFIG    ((volatile unsigned int*)(VIDEOCORE_MBOX + 0x1C))
#define MBOX_WRITE     ((volatile unsigned int*)(VIDEOCORE_MBOX + 0x20))
#define MBOX_RESPONSE  0x80000000
#define MBOX_FULL      0x80000000
#define MBOX_EMPTY     0x40000000

int mbox_call(unsigned char ch, const uint32_t* mbox) {
  uint32_t r = (uint64_t)mbox | (ch & 0xF);

  /* wait until we can write to the mailbox */
  do {
    asm volatile("nop");
  } while (*MBOX_STATUS & MBOX_FULL);

  /* write the address of our message to the mailbox with channel identifier */
  *MBOX_WRITE = r;

  /* now wait for the response */
  while (1) {
    /* is there a response? */
    do {
      asm volatile("nop");
    } while (*MBOX_STATUS & MBOX_EMPTY);

    /* is it a response to our message? */
    if (r == *MBOX_READ) {
      /* is it a valid successful response? */
      return mbox[1] == MBOX_RESPONSE;
    }
  }
  return 0;
}
