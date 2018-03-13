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

#define     NEBLINA_COMMAND_RECORDER_ERASE_ALL                  0x01
#define     NEBLINA_COMMAND_RECORDER_RECORD                     0x02
#define     NEBLINA_COMMAND_RECORDER_PLAYBACK                   0x03
#define     NEBLINA_COMMAND_RECORDER_SESSION_COUNT              0x04
#define     NEBLINA_COMMAND_RECORDER_SESSION_GENERAL_INFO       0x05
#define     NEBLINA_COMMAND_RECORDER_SESSION_READ               0x06
#define     NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD           0x07
#define     NEBLINA_COMMAND_RECORDER_SESSION_SENSOR_INFO        0x08
#define     NEBLINA_COMMAND_RECORDER_SESSION_FUSION_INFO        0x09
#define     NEBLINA_COMMAND_RECORDER_SESSION_NAME               0x0A

/**********************************************************************************/

#pragma pack(push, 1)

/**********************************************************************************/

typedef enum {
    NEBLINA_RECORDER_SESSION_INFO_GENERAL       = 0x00,
    NEBLINA_RECORDER_SESSION_INFO_NAME          = 0x01,
    NEBLINA_RECORDER_SESSION_INFO_SENSORS       = 0x02,
    NEBLINA_RECORDER_SESSION_INFO_FUSION        = 0x03
} NEBLINA_ATTRIBUTE_PACKED( NeblinaRecorderSessionInfo_t );

typedef enum {
    NEBLINA_RECORDER_STATUS_IDLE     = 0x0,
    NEBLINA_RECORDER_STATUS_READ     = 0x01,
    NEBLINA_RECORDER_STATUS_RECORD   = 0x02,
    NEBLINA_RECORDER_STATUS_ERASE    = 0x03,
    NEBLINA_RECORDER_STATUS_DOWNLOAD = 0x04,
    NEBLINA_RECORDER_STATUS_UNKNOWN  = 0xFF
} NEBLINA_ATTRIBUTE_PACKED( NeblinaRecorderStatus_t );

/**********************************************************************************/

typedef struct {
    uint8_t state;
    uint16_t sessionId;
    uint16_t length;
    uint32_t offset;
} NeblinaSessionDownload_t;

typedef struct {
    uint32_t offset;
    uint8_t data[NEBLINA_PACKET_LENGTH_MAX - sizeof( uint32_t )];
} NeblinaSessionDownloadData_t;

/**********************************************************************************/

typedef struct {
    uint8_t state; //ON/OFF to Start/Stop a recording session
    uint8_t name[15]; //session name
} NeblinaSessionRecordCommand_t;

typedef struct {
    uint8_t length; //length of the packet, i.e., "data" array size + 1 byte for "state"
    uint8_t state; //ON/OFF for the start/stop of a recording session
    uint8_t data[15]; //description of a to-be-recorded session, when the state is ON
} NeblinaSessionRecordNameLength_t;

/**********************************************************************************/

typedef struct {
    uint32_t length;
    uint32_t timestamp; /// Unix Time in seconds
} NeblinaSessionGeneralInfo_t;

typedef struct {
    uint8_t accelerometer_range; //enum "NeblinaAccelerometerRange_t"
    uint8_t gyroscope_range; //enum "NeblinaGyroscopeRange_t"
    uint8_t magnetometer_range; //"MagRange_t"
    uint8_t accelerometer_cutoff_divider; //represents accelerometer bandwidth, see enum "CutoffFreq_t" for details
    uint8_t gyroscope_cutoff_divider; //represents gyroscope bandwidth, see enum "CutoffFreq_t" for details
} NeblinaSessionSensorInfo_t;

typedef struct {
    uint8_t fusionType; //see the enum "NeblinaFusionType_t" for details
    uint8_t shockThreshold; //see the enum "NeblinaFusionShockThreshold_t" for details
    uint8_t rotationAlgorithm; //see the enum "NeblinaFusionRotationAlgorithm_t" for details
} NeblinaSessionFusionInfo_t;

/**********************************************************************************/

typedef struct {
    uint8_t state;
    uint16_t sessionId;
} NeblinaSessionStatus_t;

/**********************************************************************************/

typedef struct {
    uint16_t sessionId;
    uint16_t length;
    uint32_t offset;
} NeblinaSessionReadCommand_t;

/**********************************************************************************/

typedef struct {
    uint8_t data[NEBLINA_PACKET_LENGTH_MAX];
} NeblinaSessionReadData_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_RECORDER_ERASE_QUICK = 0x00,
    NEBLINA_RECORDER_ERASE_MASS = 0x01
} NEBLINA_ATTRIBUTE_PACKED( NeblinaRecorderErase_t );

/**********************************************************************************/

#pragma pack(pop)

/**********************************************************************************/
