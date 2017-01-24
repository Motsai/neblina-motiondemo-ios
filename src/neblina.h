/***********************************************************************************
* Copyright (c) 2010 - 2016, Motsai
* All rights reserved.

* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
***********************************************************************************/

#ifndef __NEBLINA_H___
#define __NEBLINA_H___

/**********************************************************************************/

#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

/**********************************************************************************/

#define     NEBLINA_API_VERSION                  2
#define     NEBLINA_FIRMWARE_VERSION_MAJOR       2
#define     NEBLINA_FIRMWARE_VERSION_MINOR       0
#define     NEBLINA_FIRMWARE_VERSION_BUILD       0

//#define     NEBLINA_HARDWARE_V2A
#define     NEBLINA_HARDWARE_V2B

/**********************************************************************************/

#if defined(NDEBUG)
#define     NEBLINA_ASSERT(cond, msg)
#else
#define     NEBLINA_ASSERT(cond, msg)      assert(cond && msg)
#endif

/**********************************************************************************/

#if defined(_WIN32) || defined(_WIN64)
#define NEBLINA_WINDOW
#elif defined(__APPLE__) || defined(__MACH__)
#define NEBLINA_APPLE
#elif defined(unix) || defined(__unix) || defined(__unix__)
#define NEBLINA_LINUX
#else
#define NEBLINA_EMBEDDED
#endif

/**********************************************************************************/

#if defined(NEBLINA_WINDOW)
#define NEBLINA_EXPORT __declspec(dllexport)
#define NEBLINA_IMPORT __declspec(dllimport)
#else
#define NEBLINA_EXPORT
#define NEBLINA_IMPORT
#endif

#ifdef NEBLINA_CFG_DLL
#define NEBLINA_EXTERN NEBLINA_EXPORT
#else
#define NEBLINA_EXTERN NEBLINA_IMPORT
#endif

/**********************************************************************************/

#define     NEBLINA_BITMASK_SUBSYSTEM                        0x1F
#define     NEBLINA_BITMASK_PACKETTYPE                       0xE0

#define     NEBLINA_BITPOSITION_PACKETTYPE                      5

/**********************************************************************************/

#define     NEBLINA_UART_BAUDRATE                               1000000

/**********************************************************************************/

#define     NEBLINA_COMMAND_DEBUG_PRINTF                        0
#define     NEBLINA_COMMAND_DEBUG_DUMP_DATA                     1

/**********************************************************************************/

#define     NEBLINA_COMMAND_EEPROM_READ                         1
#define     NEBLINA_COMMAND_EEPROM_WRITE                        2

/**********************************************************************************/

#define     NEBLINA_COMMAND_FUSION_SAMPLING_RATE                0
#define     NEBLINA_COMMAND_FUSION_DOWNSAMPLE                   1
#define     NEBLINA_COMMAND_FUSION_MOTION_STATE                 2
#define     NEBLINA_COMMAND_FUSION_IMU_STATE                    3
#define     NEBLINA_COMMAND_FUSION_QUATERNION_STATE             4
#define     NEBLINA_COMMAND_FUSION_EULER_ANGLE_STATE            5
#define     NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STATE         6
#define     NEBLINA_COMMAND_FUSION_FUSION_TYPE                  7
#define     NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD            8
#define     NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STATE        9
#define     NEBLINA_COMMAND_FUSION_PEDOMETER_STATE             10
#define     NEBLINA_COMMAND_FUSION_MAG_STATE                   11
#define     NEBLINA_COMMAND_FUSION_SITTING_STANDING_STATE      12
#define     NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE      13
#define     NEBLINA_COMMAND_FUSION_ACCELEROMETER_RANGE         14
#define     NEBLINA_COMMAND_FUSION_FINGER_GESTURE_STATE        17
#define     NEBLINA_COMMAND_FUSION_ROTATION_STATE              18
#define     NEBLINA_COMMAND_FUSION_EXTERNAL_HEADING_CORRECTION 19
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_RESET              20
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_CALIBRATE          21
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_CREATE_POSE        22
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_SET_ACTIVE_POSE    23
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_GET_ACTIVE_POSE    24
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_STATE              25
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_POSE_INFO          26
#define     NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION  27
#define     NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION     28
#define     NEBLINA_COMMAND_FUSION_GYROSCOPE_RANGE             29
#define     NEBLINA_COMMAND_FUSION_COUNT                       30       // Keep last

/**********************************************************************************/

#define     NEBLINA_COMMAND_GENERAL_AUTHENTICATION              0
#define     NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS               1
#define     NEBLINA_COMMAND_GENERAL_FUSION_STATUS               2
#define     NEBLINA_COMMAND_GENERAL_RECORDER_STATUS             3
#define     NEBLINA_COMMAND_GENERAL_FIRMWARE                    5
#define     NEBLINA_COMMAND_GENERAL_RSSI                        7
#define     NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS            8
#define     NEBLINA_COMMAND_GENERAL_INTERFACE_STATE             9
#define     NEBLINA_COMMAND_GENERAL_POWER_STATUS                10
#define     NEBLINA_COMMAND_GENERAL_SENSOR_STATUS               11
#define     NEBLINA_COMMAND_GENERAL_DISABLE_STREAMING           12
#define     NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP             13
#define     NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE             14

/**********************************************************************************/

#define     NEBLINA_COMMAND_LED_STATE                           1
#define     NEBLINA_COMMAND_LED_STATUS                          2

/**********************************************************************************/

#define     NEBLINA_COMMAND_POWER_BATTERY                       0
#define     NEBLINA_COMMAND_POWER_TEMPERATURE                   1
#define     NEBLINA_COMMAND_POWER_CHARGE_CURRENT                2

/**********************************************************************************/

#define     NEBLINA_COMMAND_SENSOR_DOWNSAMPLE                   0
#define     NEBLINA_COMMAND_SENSOR_RANGE                        1
#define     NEBLINA_COMMAND_SENSOR_RATE                         2
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER                10
#define     NEBLINA_COMMAND_SENSOR_GYROSCOPE                    11
#define     NEBLINA_COMMAND_SENSOR_HUMIDITY                     12
#define     NEBLINA_COMMAND_SENSOR_MAGNETOMETER                 13
#define     NEBLINA_COMMAND_SENSOR_PRESSURE                     14
#define     NEBLINA_COMMAND_SENSOR_TEMPERATURE                  15
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE      16
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER   17
#define     NEBLINA_COMMAND_SENSOR_COUNT                        18          // Keep last and incremented

/**********************************************************************************/

#define     NEBLINA_COMMAND_RECORDER_ERASE_ALL                  1
#define     NEBLINA_COMMAND_RECORDER_RECORD                     2
#define     NEBLINA_COMMAND_RECORDER_PLAYBACK                   3
#define     NEBLINA_COMMAND_RECORDER_SESSION_COUNT              4
#define     NEBLINA_COMMAND_RECORDER_SESSION_INFO               5
#define     NEBLINA_COMMAND_RECORDER_SESSION_READ               6

/**********************************************************************************/

#define     NEBLINA_COMMAND_TEST_MOTION_STATE                   0
#define     NEBLINA_COMMAND_TEST_MOTION_DATA                    1

/**********************************************************************************/

#define     NEBLINA_PACKET_HEADER_ELEMENT_CTRL                  0
#define     NEBLINA_PACKET_HEADER_ELEMENT_LENGTH                1
#define     NEBLINA_PACKET_HEADER_ELEMENT_CRC                   2
#define     NEBLINA_PACKET_HEADER_ELEMENT_DATATYPE              3
#define     NEBLINA_PACKET_HEADER_LENGTH                        4

#define     NEBLINA_PACKET_LENGTH_MAX                          40

#define     NEBLINA_PACKET_TYPE_RESPONSE                        0
#define     NEBLINA_PACKET_TYPE_ACK                             1
#define     NEBLINA_PACKET_TYPE_COMMAND                         2
#define     NEBLINA_PACKET_TYPE_RESERVE_1                       3
#define     NEBLINA_PACKET_TYPE_ERROR                           4
#define     NEBLINA_PACKET_TYPE_RESERVE_2                       5
#define     NEBLINA_PACKET_TYPE_REQUEST_LOG                     6
#define     NEBLINA_PACKET_TYPE_RESERVE_3                       7

/**********************************************************************************/

#define     NEBLINA_SUBSYSTEM_GENERAL                           0
#define     NEBLINA_SUBSYSTEM_FUSION                            1
#define     NEBLINA_SUBSYSTEM_POWER                             2
#define     NEBLINA_SUBSYSTEM_GPIO                              3
#define     NEBLINA_SUBSYSTEM_LED                               4
#define     NEBLINA_SUBSYSTEM_ADC                               5
#define     NEBLINA_SUBSYSTEM_DAC                               6
#define     NEBLINA_SUBSYSTEM_I2C                               7
#define     NEBLINA_SUBSYSTEM_SPI                               8
#define     NEBLINA_SUBSYSTEM_DEBUG                             9
#define     NEBLINA_SUBSYSTEM_TEST                             10
#define     NEBLINA_SUBSYSTEM_RECORDER                         11
#define     NEBLINA_SUBSYSTEM_EEPROM                           12
#define     NEBLINA_SUBSYSTEM_SENSOR                           13

/**********************************************************************************/

#define     NEBLINA_INTERFACE_BLE                       0   // Bluetooth LE interface
#define     NEBLINA_INTERFACE_UART                      1   // UART interface
#define     NEBLINA_INTERFACE_COUNT                     2   // Max number of interface

#define     NEBLINA_INTERFACE_CLOSE                     0   // Close streaming for interface
#define     NEBLINA_INTERFACE_OPEN                      1   // Open streaming for interface

#define     NEBLINA_RECORDER_IDLE                       0   // Recorder is in idle state
#define     NEBLINA_RECORDER_PLAYING                    1   // Recorder is playing back a previous record
#define     NEBLINA_RECORDER_RECORDING                  2   // Recorder is recording a session
#define     NEBLINA_RECORDER_ERASE                      3   // Recorder is currently being erased.

#define     NEBLINA_SESSION_CLOSE                       0
#define     NEBLINA_SESSION_CREATE                      1
#define     NEBLINA_SESSION_OPEN                        2
#define     NEBLINA_SESSION_INVALID                     0xFF

#define     NEBLINA_LED_MAX_COUNT                       4

/**********************************************************************************/

#pragma pack( push, 1 )

/**********************************************************************************/

typedef struct {
    uint8_t major;          // Major version (X.0.0)
    uint8_t minor;          // Minor version (0.Y.0)
    uint8_t build;          // Build version (0.0.Z)
} Version_t;

/**********************************************************************************/

typedef struct {
	uint8_t apiVersion;     // API
    Version_t coreVersion;  // core fusion firmware version
	Version_t bleVersion;	// BLE comm firmware version
    uint64_t devid;			// Neblina UID
} NeblinaFirmwareVersion_t;

/**********************************************************************************/

typedef struct NeblinaPacketHeader_t
{
    uint8_t subSystem:5;    // SubSystem
    uint8_t packetType:3;   // Packet type
    uint8_t length;         // Data length (in byte)
    uint8_t crc;            // Packet CRC
    uint8_t command;        // Command
} NeblinaPacketHeader_t;

/**********************************************************************************/

typedef struct NeblinaPacket_t
{
    NeblinaPacketHeader_t header;
    uint8_t               data[1];        // Data buffer follows. i.e Data array more than one item
} NeblinaPacket_t;

/**********************************************************************************/

typedef struct
{
    uint16_t current;
} ChargeCurrentData_t;

/**********************************************************************************/

typedef struct
{
    uint16_t pageId;
    uint8_t  content[8];
} EEPROMData_t;

/**********************************************************************************/

typedef struct
{
    uint8_t interface;  // Communication interface
    uint8_t state;          // Interface state (OPEN/CLOSE)
} NeblinaInterfaceState_t;

/**********************************************************************************/

typedef struct
{
    uint8_t state[NEBLINA_INTERFACE_COUNT];    // Interface status (OPEN/CLOSE)
} NeblinaInterfaceStatus_t;

/**********************************************************************************/

typedef struct
{
    uint8_t index;
    uint8_t state;
} NeblinaLEDState_t;

/**********************************************************************************/

typedef struct
{
    uint8_t state[NEBLINA_LED_MAX_COUNT];
} NeblinaLEDStatus_t;

/**********************************************************************************/

typedef struct
{
    uint8_t distance:1;
    uint8_t force:1;
    uint8_t euler:1;
    uint8_t quaternion:1;
    uint8_t imu:1;
    uint8_t motion:1;
    uint8_t pedometer:1;
    uint8_t mag:1;
    uint8_t sittingStanding:1;
    uint8_t fingerGesture:1;
    uint8_t rotation:1;
} NeblinaFusionStatus_t;

/**********************************************************************************/

typedef struct
{
    uint32_t status;
} NeblinaSensorStatus_t;

/**********************************************************************************/

typedef struct
{
    uint8_t status;
} NeblinaPowerStatus_t;

/**********************************************************************************/

typedef struct
{
    uint8_t state;
} NeblinaRecorderStatus_t;

/**********************************************************************************/

// Neblina System status
// mostly used to update UI with current system state
typedef struct
{
    uint32_t FusionStatus;      // Flag bits indicating fusion data streaming states
    uint16_t SensorStatus;      // Flag bits indicating sensor data streaming states
    uint8_t  PowerStatus;       // Flag bits indicating power states
    uint8_t  RecorderStatus;    // Flag bits indicating recorder states
    uint8_t  LEDStatus[NEBLINA_LED_MAX_COUNT];  // LED levels
} NeblinaSystemStatus_t;

/**********************************************************************************/

typedef struct
{
    uint32_t timestamp;
    uint8_t rssi;
} RSSIData_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint32_t value;         // in %RH (format .2f)
} NeblinaHumidityFxp_t;

typedef struct {
    uint32_t timestamp;
    float value;
} NeblinaHumidityFp_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint32_t value;         // in kPa (format .2f)
} NeblinaPressureFxp_t;

typedef struct {
    uint32_t timestamp;
    float value;
} NeblinaPressureFp_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int32_t value;          // in Celsius (format .2f)
} NeblinaTemperatureFxp_t;

typedef struct {
    uint32_t timestamp;
    float value;
} NeblinaTemperatureFp_t;

/**********************************************************************************/

typedef struct
{
    uint32_t length;
    uint16_t sessionId;
} NeblinaSessionInfo_t;

/**********************************************************************************/

typedef struct
{
    uint8_t state;
    uint16_t sessionId;
} NeblinaSessionStatus_t;

/**********************************************************************************/

typedef struct
{
    uint16_t sessionId;
    uint16_t length;
    uint32_t offset;
} NeblinaSessionReadCommand_t;

/**********************************************************************************/

typedef struct
{
    uint8_t data[NEBLINA_PACKET_LENGTH_MAX];
} NeblinaSessionReadData_t;

/**********************************************************************************/

typedef struct
{
    uint16_t temperature;
} TemperatureData_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_RATE_1 = 1,
    NEBLINA_RATE_50 = 50,
    NEBLINA_RATE_100 = 100,
    NEBLINA_RATE_200 = 200,
    NEBLINA_RATE_400 = 400,
    NEBLINA_RATE_800 = 800,
    NEBLINA_RATE_1600 = 1600
} NeblinaRate_t;

typedef enum {
    NEBLINA_SENSOR_STREAM_ACCELEROMETER              = 0x00,
    NEBLINA_SENSOR_STREAM_ACCELEROMETER_GYROSCOPE    = 0x01,
    NEBLINA_SENSOR_STREAM_ACCELEROMETER_MAGNETOMETER = 0x02,
    NEBLINA_SENSOR_STREAM_GYROSCOPE                  = 0x03,
    NEBLINA_SENSOR_STREAM_HUMIDITY                   = 0x04,
    NEBLINA_SENSOR_STREAM_MAGNETOMETER               = 0x05,
    NEBLINA_SENSOR_STREAM_PRESSURE                   = 0x06,
    NEBLINA_SENSOR_STREAM_TEMPERATURE                = 0x07,
    NEBLINA_SENSOR_STREAM_COUNT                     // Keep last
} NeblinaSensorStream_t;

typedef enum {
    NEBLINA_SENSOR_ACCELEROMETER    = 0x00,
    NEBLINA_SENSOR_GYROSCOPE        = 0x01,
    NEBLINA_SENSOR_MAGNETOMETER     = 0x02,
    NEBLINA_SENSOR_HUMIDITY         = 0x03,
    NEBLINA_SENSOR_PRESSURE         = 0x04,
    NEBLINA_SENSOR_TEMPERATURE      = 0x05,
    NEBLINA_SENSOR_COUNT                    // Keep last
} NeblinaSensorType_t;

typedef struct {
    uint16_t  stream;
    uint16_t downsample;
} NeblinaSensorDownsample_t;

typedef struct {
    uint16_t type;
    uint16_t range;
} NeblinaSensorRange_t;

typedef struct {
    uint16_t type;
    uint16_t rate;
} NeblinaSensorRate_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaAccelerometerFxp_t;

typedef enum {
    NEBLINA_ACCELEROMETER_RANGE_2G = 0x00,
    NEBLINA_ACCELEROMETER_RANGE_4G = 0x01,
    NEBLINA_ACCELEROMETER_RANGE_8G = 0x02,
    NEBLINA_ACCELEROMETER_RANGE_16G = 0x03
} NeblinaAccelerometerRange_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t accelX;
    int16_t accelY;
    int16_t accelZ;
    int16_t gyroX;
    int16_t gyroY;
    int16_t gyroZ;
} NeblinaAccelerometerGyroscopeFxp_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t accelX;
    int16_t accelY;
    int16_t accelZ;
    int16_t magX;
    int16_t magY;
    int16_t magZ;
} NeblinaAccelerometerMagnetometerFxp_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaGyroscopeFxp_t;

typedef enum {
    NEBLINA_GYROSCOPE_RANGE_2000 = 0x00,
    //NEBLINA_GYROSCOPE_RANGE_1000 = 0x01,
    NEBLINA_GYROSCOPE_RANGE_500  = 0x02,
    //NEBLINA_GYROSCOPE_RANGE_250  = 0x03
} NeblinaGyroscopeRange_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaMagnetometerFxp_t;

/**********************************************************************************/

#pragma pack( pop )

/**********************************************************************************/

#endif // __NEBLINA_H___
