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

#include <assert.h>
#include <stdint.h>
//#include <stdio.h>
//#include <string.h>

#include "neblina_debug.h"
#include "neblina_eeprom.h"
#include "neblina_fusion.h"
#include "neblina_general.h"
#include "neblina_led.h"
#include "neblina_power.h"
#include "neblina_recorder.h"
#include "neblina_sensor.h"

/**********************************************************************************/

#define     NEBLINA_API_VERSION                  2

/**********************************************************************************/

#define     NEBLINA_BITMASK_SUBSYSTEM                        0x1F
#define     NEBLINA_BITMASK_PACKETTYPE                       0xE0

#define     NEBLINA_BITPOSITION_PACKETTYPE                      5

/**********************************************************************************/

#define     NEBLINA_NAME_LENGTH_MAX                             16
#define     NEBLINA_SESSION_NAME_LENGTH_MAX                     15

/**********************************************************************************/

/// UART uses hardware flow control (CTS/RTS)
#define     NEBLINA_UART_BAUDRATE                               1000000
#define     NEBLINA_UART_DATA_SIZE                              8
#define     NEBLINA_UART_STOP_BITS                              1

/**********************************************************************************/

#define     NEBLINA_PACKET_HEADER_ELEMENT_CTRL                  0x00
#define     NEBLINA_PACKET_HEADER_ELEMENT_LENGTH                0x01
#define     NEBLINA_PACKET_HEADER_ELEMENT_CRC                   0x02
#define     NEBLINA_PACKET_HEADER_ELEMENT_DATATYPE              0x03
#define     NEBLINA_PACKET_HEADER_LENGTH                        0x04

#define     NEBLINA_PACKET_TYPE_RESPONSE                        0x00
#define     NEBLINA_PACKET_TYPE_ACK                             0x01
#define     NEBLINA_PACKET_TYPE_COMMAND                         0x02
#define     NEBLINA_PACKET_TYPE_DATA                            0x03
#define     NEBLINA_PACKET_TYPE_ERROR                           0x04
#define     NEBLINA_PACKET_TYPE_RESERVE_2                       0x05
#define     NEBLINA_PACKET_TYPE_REQUEST_LOG                     0x06
#define     NEBLINA_PACKET_TYPE_RESERVE_3                       0x07

/**********************************************************************************/

#define     NEBLINA_SUBSYSTEM_GENERAL                           0x00
#define     NEBLINA_SUBSYSTEM_FUSION                            0x01
#define     NEBLINA_SUBSYSTEM_POWER                             0x02
#define     NEBLINA_SUBSYSTEM_GPIO                              0x03
#define     NEBLINA_SUBSYSTEM_LED                               0x04
#define     NEBLINA_SUBSYSTEM_ADC                               0x05
#define     NEBLINA_SUBSYSTEM_DAC                               0x06
#define     NEBLINA_SUBSYSTEM_I2C                               0x07
#define     NEBLINA_SUBSYSTEM_SPI                               0x08
#define     NEBLINA_SUBSYSTEM_DEBUG                             0x09
#define     NEBLINA_SUBSYSTEM_TEST                              0x0A
#define     NEBLINA_SUBSYSTEM_RECORDER                          0x0B
#define     NEBLINA_SUBSYSTEM_EEPROM                            0x0C
#define     NEBLINA_SUBSYSTEM_SENSOR                            0x0D

/**********************************************************************************/

#define     NEBLINA_SESSION_CLOSE                       0
#define     NEBLINA_SESSION_CREATE                      1
#define     NEBLINA_SESSION_OPEN                        2
#define     NEBLINA_SESSION_INVALID                     0xFF

#define     NEBLINA_SESSION_HEADER_LENGTH               496

/**********************************************************************************/

typedef enum {
    NEBLINA_RATE_EVENT = 0,
    NEBLINA_RATE_1 = 1,
    NEBLINA_RATE_50 = 50,
    NEBLINA_RATE_100 = 100,
    NEBLINA_RATE_200 = 200,
    NEBLINA_RATE_400 = 400,
    NEBLINA_RATE_800 = 800,
    NEBLINA_RATE_1600 = 1600
} NEBLINA_ATTRIBUTE_PACKED( NeblinaRate_t );

/**********************************************************************************/

#pragma pack( push, 1 )

/**********************************************************************************/

typedef struct NeblinaPacketHeader_t {
    uint8_t subSystem:5;    /// SubSystem
    uint8_t packetType:3;   /// Packet type
    uint8_t length;         /// Data length (in byte)
    uint8_t crc;            /// Packet CRC
    uint8_t command;        /// Command
} NeblinaPacketHeader_t;

/**********************************************************************************/

typedef struct NeblinaPacket_t {
    NeblinaPacketHeader_t header;
    uint8_t               data[1];        /// Data buffer follows. i.e Data array more than one item
} NeblinaPacket_t;

/**********************************************************************************/

typedef struct {
    uint32_t microseconds; /// high-resolution timestamp in microseconds
    uint32_t unixTime; /// Unix timestamp in seconds
} NeblinaTimestamp_t;

/**********************************************************************************/

#pragma pack( pop )

/**********************************************************************************/
