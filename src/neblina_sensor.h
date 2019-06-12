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

#define     NEBLINA_COMMAND_SENSOR_SET_DOWNSAMPLE                      0x00
#define     NEBLINA_COMMAND_SENSOR_SET_RANGE                           0x01
#define     NEBLINA_COMMAND_SENSOR_SET_RATE                            0x02
#define     NEBLINA_COMMAND_SENSOR_GET_DOWNSAMPLE                      0x03
#define     NEBLINA_COMMAND_SENSOR_GET_RANGE                           0x04
#define     NEBLINA_COMMAND_SENSOR_GET_RATE                            0x05
#define     NEBLINA_COMMAND_SENSOR_SET_BANDWIDTH                       0x06     /// currently only applicable to accel & gyro sensors
#define     NEBLINA_COMMAND_SENSOR_GET_BANDWIDTH                       0x07     /// currently only valid for accel & gyro sensors
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM                0x0A
#define     NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM                    0x0B
#define     NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM                     0x0C
#define     NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM                 0x0D
#define     NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM                     0x0E
#define     NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM                  0x0F
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM      0x10
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM   0x11
#define     NEBLINA_COMMAND_SENSOR_COUNT                               0x12     /// Keep last and incremented

/**********************************************************************************/

typedef uint16_t NeblinaSensorStatus_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_SENSOR_STREAM_ACCELEROMETER              = 0x00,
    NEBLINA_SENSOR_STREAM_ACCELEROMETER_GYROSCOPE    = 0x01,
    NEBLINA_SENSOR_STREAM_ACCELEROMETER_MAGNETOMETER = 0x02,
    NEBLINA_SENSOR_STREAM_GYROSCOPE                  = 0x03,
    NEBLINA_SENSOR_STREAM_HUMIDITY                   = 0x04,
    NEBLINA_SENSOR_STREAM_MAGNETOMETER               = 0x05,
    NEBLINA_SENSOR_STREAM_PRESSURE                   = 0x06,
    NEBLINA_SENSOR_STREAM_TEMPERATURE                = 0x07,
    NEBLINA_SENSOR_STREAM_COUNT                      /// Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaSensorStream_t );

typedef enum {
    NEBLINA_SENSOR_STATUS_ACCELEROMETER              = ( 1 << NEBLINA_SENSOR_STREAM_ACCELEROMETER ),
    NEBLINA_SENSOR_STATUS_ACCELEROMETER_GYROSCOPE    = ( 1 << NEBLINA_SENSOR_STREAM_ACCELEROMETER_GYROSCOPE ),
    NEBLINA_SENSOR_STATUS_ACCELEROMETER_MAGNETOMETER = ( 1 << NEBLINA_SENSOR_STREAM_ACCELEROMETER_MAGNETOMETER ),
    NEBLINA_SENSOR_STATUS_GYROSCOPE                  = ( 1 << NEBLINA_SENSOR_STREAM_GYROSCOPE ),
    NEBLINA_SENSOR_STATUS_HUMIDITY                   = ( 1 << NEBLINA_SENSOR_STREAM_HUMIDITY ),
    NEBLINA_SENSOR_STATUS_MAGNETOMETER               = ( 1 << NEBLINA_SENSOR_STREAM_MAGNETOMETER ),
    NEBLINA_SENSOR_STATUS_PRESSURE                   = ( 1 << NEBLINA_SENSOR_STREAM_PRESSURE ),
    NEBLINA_SENSOR_STATUS_TEMPERATURE                = ( 1 << NEBLINA_SENSOR_STREAM_TEMPERATURE ),
} NEBLINA_ATTRIBUTE_PACKED( NeblinaSensorStatusMask_t );

typedef enum {
    NEBLINA_SENSOR_ACCELEROMETER    = 0x00,
    NEBLINA_SENSOR_GYROSCOPE        = 0x01,
    NEBLINA_SENSOR_MAGNETOMETER     = 0x02,
    NEBLINA_SENSOR_HUMIDITY         = 0x03,
    NEBLINA_SENSOR_PRESSURE         = 0x04,
    NEBLINA_SENSOR_TEMPERATURE      = 0x05,
    NEBLINA_SENSOR_COUNT                    /// Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaSensorType_t );

typedef enum {
    NEBLINA_ACCELEROMETER_RANGE_2G = 0x00,
    NEBLINA_ACCELEROMETER_RANGE_4G = 0x01,
    NEBLINA_ACCELEROMETER_RANGE_8G = 0x02,
    NEBLINA_ACCELEROMETER_RANGE_16G = 0x03
} NEBLINA_ATTRIBUTE_PACKED( NeblinaAccelerometerRange_t );

typedef enum {
    NEBLINA_GYROSCOPE_RANGE_2000 = 0x00,
    //NEBLINA_GYROSCOPE_RANGE_1000 = 0x01,
    NEBLINA_GYROSCOPE_RANGE_500  = 0x02,
    //NEBLINA_GYROSCOPE_RANGE_250  = 0x03
} NEBLINA_ATTRIBUTE_PACKED( NeblinaGyroscopeRange_t );

/**********************************************************************************/

#pragma pack(push, 1)

/**********************************************************************************/

typedef struct {
    uint16_t stream;
    uint16_t factor;
} NeblinaSensorDownsample_t;

typedef struct {
    uint16_t type;
    uint16_t range;
} NeblinaSensorRange_t;

typedef struct {
    uint16_t type;
    uint16_t rate;
} NeblinaSensorRate_t;

typedef struct {
    uint16_t type;
    uint16_t cutoffDivider;
} NeblinaSensorBandwidth_t;

/**********************************************************************************/

typedef struct {
    uint16_t downsample;
    uint16_t range;
    uint16_t rate;
} NeblinaSensorStreamMotionInfo_t;

typedef struct {
    uint16_t downsample;
    uint16_t rangeAccelerometer;
    uint16_t rangeGyroscope;
    uint16_t rate;
} NeblinaSensorStreamAccelerometerGyroscopeInfo_t;

typedef struct {
    uint16_t downsample;
    uint16_t rate;
} NeblinaSensorStreamEnvironmentInfo_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    float x;
    float y;
    float z;
} NeblinaAccelerometerFpTs_t;

typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaAccelerometerFxpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t accelX;
    int16_t accelY;
    int16_t accelZ;
    int16_t gyroX;
    int16_t gyroY;
    int16_t gyroZ;
} NeblinaAccelerometerGyroscopeFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float accelX;
    float accelY;
    float accelZ;
    float gyroX;
    float gyroY;
    float gyroZ;
} NeblinaAccelerometerGyroscopeFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t accelX;
    int16_t accelY;
    int16_t accelZ;
    int16_t magX;
    int16_t magY;
    int16_t magZ;
} NeblinaAccelerometerMagnetometerFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float accelX;
    float accelY;
    float accelZ;
    float magX;
    float magY;
    float magZ;
} NeblinaAccelerometerMagnetometerFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    float x;
    float y;
    float z;
} NeblinaGyroscopeFpTs_t;

typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaGyroscopeFxpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    float x;
    float y;
    float z;
} NeblinaMagnetometerFpTs_t;

typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaMagnetometerFxpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint32_t value;         /// in %RH (format .2f)
} NeblinaHumidityFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float value;
} NeblinaHumidityFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint32_t value;         /// in kPa (format .2f)
} NeblinaPressureFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float value;
} NeblinaPressureFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int32_t value;          /// in Celsius (format .2f)
} NeblinaTemperatureFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float value;
} NeblinaTemperatureFpTs_t;

/**********************************************************************************/

#pragma pack(pop)

/**********************************************************************************/
