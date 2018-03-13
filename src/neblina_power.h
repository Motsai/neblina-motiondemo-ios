/***********************************************************************************
* Copyright (c) 2010 - 2018, Motsai
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
***********************************************************************************/

#pragma once

/**********************************************************************************/

#include <stdint.h>

#include "neblina_common.h"

/**********************************************************************************/

#define     NEBLINA_COMMAND_POWER_BATTERY                       0x00
#define     NEBLINA_COMMAND_POWER_TEMPERATURE                   0x01
#define     NEBLINA_COMMAND_POWER_CHARGE_CURRENT                0x02

/**********************************************************************************/

typedef enum {
    NEBLINA_POWER_STATUS_NO_BATTERY     = 0x00,
    NEBLINA_POWER_STATUS_CHARGE_TRICKLE = 0x01,
    NEBLINA_POWER_STATUS_CHARGE_CC      = 0x02,
    NEBLINA_POWER_STATUS_CHARGE_CV      = 0x03,
    NEBLINA_POWER_STATUS_EOC            = 0x04,
    NEBLINA_POWER_STATUS_FAULT_HOT      = 0x05,
    NEBLINA_POWER_STATUS_FAULT_COLD     = 0x06,
    NEBLINA_POWER_STATUS_UNKNOWN        = 0xFF
} NEBLINA_ATTRIBUTE_PACKED( NeblinaPowerStatus_t );

/**********************************************************************************/

#pragma pack(push, 1)

/**********************************************************************************/

typedef struct {
    uint16_t stateOfCharge;     /// in percentage (1000 = 100.0%)
} NeblinaPowerBattery_t;

typedef struct {
    uint16_t current;           /// in mA
} NeblinaPowerChargeCurrent_t;

/**********************************************************************************/

#pragma pack(pop)

/**********************************************************************************/
