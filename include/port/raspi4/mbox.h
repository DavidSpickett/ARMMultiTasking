#ifndef PORT_RASPI4_MBOX_H
#define PORT_RASPI4_MBOX_H

#include <stdint.h>

#define MBOX_REQUEST 0

/* channels */
#define MBOX_CH_POWER 0
#define MBOX_CH_FB    1
#define MBOX_CH_VUART 2
#define MBOX_CH_VCHIQ 3
#define MBOX_CH_LEDS  4
#define MBOX_CH_BTNS  5
#define MBOX_CH_TOUCH 6
#define MBOX_CH_COUNT 7
#define MBOX_CH_PROP  8

/* tags */
#define MBOX_TAG_SETPOWER   0x28001
#define MBOX_TAG_SETCLKRATE 0x38002
#define MBOX_TAG_LAST       0

int mbox_call(unsigned char ch, const uint32_t* mbox);

#endif /* PORT_RASPI4_MBOX_H */
