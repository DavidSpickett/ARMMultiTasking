#ifndef PORT_RASPI4_GPIO_H
#define PORT_RASPI4_GPIO_H

#include "port/raspi4/mmio.h"

#define GPFSEL0 ((volatile unsigned int*)(MMIO_BASE + 0x00200000))
#define GPFSEL1 ((volatile unsigned int*)(MMIO_BASE + 0x00200004))
#define GPFSEL2 ((volatile unsigned int*)(MMIO_BASE + 0x00200008))
#define GPFSEL3 ((volatile unsigned int*)(MMIO_BASE + 0x0020000C))
#define GPFSEL4 ((volatile unsigned int*)(MMIO_BASE + 0x00200010))
#define GPFSEL5 ((volatile unsigned int*)(MMIO_BASE + 0x00200014))
#define GPSET0  ((volatile unsigned int*)(MMIO_BASE + 0x0020001C))
#define GPSET1  ((volatile unsigned int*)(MMIO_BASE + 0x00200020))
#define GPCLR0  ((volatile unsigned int*)(MMIO_BASE + 0x00200028))
#define GPLEV0  ((volatile unsigned int*)(MMIO_BASE + 0x00200034))
#define GPLEV1  ((volatile unsigned int*)(MMIO_BASE + 0x00200038))
#define GPEDS0  ((volatile unsigned int*)(MMIO_BASE + 0x00200040))
#define GPEDS1  ((volatile unsigned int*)(MMIO_BASE + 0x00200044))
#define GPHEN0  ((volatile unsigned int*)(MMIO_BASE + 0x00200064))
#define GPHEN1  ((volatile unsigned int*)(MMIO_BASE + 0x00200068))

#endif /* PORT_RASPI4_GPIO_H */
