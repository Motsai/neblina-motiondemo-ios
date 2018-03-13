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
#include "neblina_led.h"

/**********************************************************************************/

#define     NEBLINA_COMMAND_GENERAL_AUTHENTICATION              0x00
#define     NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS               0x01
#define     NEBLINA_COMMAND_GENERAL_FUSION_STATUS               0x02
#define     NEBLINA_COMMAND_GENERAL_RECORDER_STATUS             0x03
#define     NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION            0x05
#define     NEBLINA_COMMAND_GENERAL_DEVICE_SHUTDOWN             0x06
#define     NEBLINA_COMMAND_GENERAL_RSSI                        0x07
#define     NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS            0x08
#define     NEBLINA_COMMAND_GENERAL_INTERFACE_STATE             0x09
#define     NEBLINA_COMMAND_GENERAL_POWER_STATUS                0x0A
#define     NEBLINA_COMMAND_GENERAL_SENSOR_STATUS               0x0B
#define     NEBLINA_COMMAND_GENERAL_DISABLE_STREAMING           0x0C
#define     NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP             0x0D
#define     NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE             0x0E
#define     NEBLINA_COMMAND_GENERAL_DEVICE_NAME_GET             0x0F
#define     NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET             0x10
#define     NEBLINA_COMMAND_GENERAL_SET_UNIX_TIMESTAMP          0x11
#define     NEBLINA_COMMAND_GENERAL_GET_UNIX_TIMESTAMP          0x12
// Reserved command 0x13, 0x14, 0x15 and 0x16 for configurator
#define     NEBLINA_COMMAND_GENERAL_DEVICE_RESET                0x17

/**********************************************************************************/

#define     NEBLINA_INTERFACE_CLOSE                     0   /// Close streaming for interface
#define     NEBLINA_INTERFACE_OPEN                      1   /// Open streaming for interface

/**********************************************************************************/

typedef uint8_t NeblinaInterfaceStatus_t;

/**********************************************************************************/

#pragma pack(push, 1)

/**********************************************************************************/

typedef struct {
    uint8_t api;                    /// Application Program Interface
    uint8_t firmware_major;         /// Firmware major version (X.0.0)
    uint8_t firmware_minor;         /// Firmware minor version (0.Y.0)
    uint8_t firmware_patch;         /// Firmware patch version (0.0.Z)
    uint8_t firmware_build[3];      /// Firmware build version (
    uint64_t device_uuid;             /// Device UUID
} NeblinaFirmwareVersion_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_INTERFACE_BLE  = 0x00,
    NEBLINA_INTERFACE_UART = 0x01,
    NEBLINA_INTERFACE_COUNT     /// Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaInterface_t );

/*typedef enum {
    NEBLINA_INTERFACE_STATE_CLOSE = 0x00,
    NEBLINA_INTERFACE_STATE_OPEN  = 0x01
} NEBLINA_ATTRIBUTE_PACKED( NeblinaInterfaceState_t );*/

typedef enum {
    NEBLINA_INTERFACE_STATUS_BLE  = ( 1 << NEBLINA_INTERFACE_BLE ),
    NEBLINA_INTERFACE_STATUS_UART = ( 1 << NEBLINA_INTERFACE_UART )
} NEBLINA_ATTRIBUTE_PACKED( NeblinaInterfaceStatusMask_t );

typedef struct {
    uint8_t interface;  /// Communication interface
    uint8_t state;          /// Interface state (OPEN/CLOSE)
} NeblinaInterfaceState_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_RESET_TIMESTAMP_LIVE  = 0x00,
    NEBLINA_RESET_TIMESTAMP_DELAY = 0x01,
    NEBLINA_RESET_TIMESTAMP_COUNT           /// Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaResetTimestamp_t );

/**********************************************************************************/

typedef struct {
    uint32_t fusion;      /// Flag bits indicating fusion data streaming states
    uint16_t sensor;      /// Flag bits indicating sensor data streaming states
    uint8_t  power;       /// Flag bits indicating power states
    uint8_t  recorder;    /// Flag bits indicating recorder states
    uint8_t  interface;
    uint8_t  led[NEBLINA_LED_COUNT];  /// LED levels
    uint32_t  hardware;
} NeblinaSystemStatus_t;


/**********************************************************************************/

#pragma pack(pop)

/**********************************************************************************/
