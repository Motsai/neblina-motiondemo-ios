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

#if defined(NEBLINA_DLL)
#define NEBLINA_EXTERN NEBLINA_EXPORT
#else
#define NEBLINA_EXTERN NEBLINA_IMPORT
#endif

/**********************************************************************************/

#if defined(__GNUC__)
#define NEBLINA_ATTRIBUTE_PACKED(X) __attribute__((packed)) X
#else
#define NEBLINA_ATTRIBUTE_PACKED(X) X
#endif

/**********************************************************************************/

#define     NEBLINA_BITMASK_SUBSYSTEM                        0x1F
#define     NEBLINA_BITMASK_PACKETTYPE                       0xE0

#define     NEBLINA_BITPOSITION_PACKETTYPE                      5

/**********************************************************************************/

#define     NEBLINA_NAME_LENGTH_MAX                             16

/**********************************************************************************/

/// UART uses hardware flow control (CTS/RTS)
#define     NEBLINA_UART_BAUDRATE                               1000000
#define     NEBLINA_UART_DATA_SIZE                              8
#define     NEBLINA_UART_STOP_BITS                              1

/**********************************************************************************/

#define     NEBLINA_COMMAND_DEBUG_PRINTF                        0
#define     NEBLINA_COMMAND_DEBUG_DUMP_DATA                     1

/**********************************************************************************/

#define     NEBLINA_COMMAND_EEPROM_READ                         1
#define     NEBLINA_COMMAND_EEPROM_WRITE                        2

/**********************************************************************************/

#define     NEBLINA_COMMAND_FUSION_RATE                         0
#define     NEBLINA_COMMAND_FUSION_DOWNSAMPLE                   1
#define     NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM          2
#define     NEBLINA_COMMAND_FUSION_QUATERNION_STREAM            4
#define     NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM           5
#define     NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM        6
#define     NEBLINA_COMMAND_FUSION_FUSION_TYPE                  7
#define     NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD            8
#define     NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM       9
#define     NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM            10
#define     NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM     12
#define     NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE      13
#define     NEBLINA_COMMAND_FUSION_FINGER_GESTURE_STREAM       17
#define     NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM        18
#define     NEBLINA_COMMAND_FUSION_EXTERNAL_HEADING_CORRECTION 19
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_RESET              20
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_CALIBRATE          21
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_CREATE_POSE        22
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_SET_ACTIVE_POSE    23
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_GET_ACTIVE_POSE    24
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_STREAM             25
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_POSE_INFO          26
#define     NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION  27
#define     NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION     28
#define     NEBLINA_COMMAND_FUSION_MOTION_DIRECTION_STREAM     30
#define     NEBLINA_COMMAND_FUSION_COUNT                       31       // Keep last

/**********************************************************************************/

#define     NEBLINA_COMMAND_GENERAL_AUTHENTICATION              0
#define     NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS               1
#define     NEBLINA_COMMAND_GENERAL_FUSION_STATUS               2
#define     NEBLINA_COMMAND_GENERAL_RECORDER_STATUS             3
#define     NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION            5
#define     NEBLINA_COMMAND_GENERAL_RSSI                        7
#define     NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS            8
#define     NEBLINA_COMMAND_GENERAL_INTERFACE_STATE             9
#define     NEBLINA_COMMAND_GENERAL_POWER_STATUS                10
#define     NEBLINA_COMMAND_GENERAL_SENSOR_STATUS               11
#define     NEBLINA_COMMAND_GENERAL_DISABLE_STREAMING           12
#define     NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP             13
#define     NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE             14
#define     NEBLINA_COMMAND_GENERAL_DEVICE_NAME_GET             15
#define     NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET             16

/**********************************************************************************/

#define     NEBLINA_COMMAND_LED_STATE                           1
#define     NEBLINA_COMMAND_LED_STATUS                          2

/**********************************************************************************/

#define     NEBLINA_COMMAND_POWER_BATTERY                       0
#define     NEBLINA_COMMAND_POWER_TEMPERATURE                   1
#define     NEBLINA_COMMAND_POWER_CHARGE_CURRENT                2

/**********************************************************************************/

#define     NEBLINA_COMMAND_SENSOR_SET_DOWNSAMPLE                       0
#define     NEBLINA_COMMAND_SENSOR_SET_RANGE                            1
#define     NEBLINA_COMMAND_SENSOR_SET_RATE                             2
#define     NEBLINA_COMMAND_SENSOR_GET_DOWNSAMPLE                       3
#define     NEBLINA_COMMAND_SENSOR_GET_RANGE                            4
#define     NEBLINA_COMMAND_SENSOR_GET_RATE                             5
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM                10
#define     NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM                    11
#define     NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM                     12
#define     NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM                 13
#define     NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM                     14
#define     NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM                  15
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM      16
#define     NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM   17
#define     NEBLINA_COMMAND_SENSOR_COUNT                               18          // Keep last and incremented

/**********************************************************************************/

#define     NEBLINA_COMMAND_RECORDER_ERASE_ALL                  1
#define     NEBLINA_COMMAND_RECORDER_RECORD                     2
#define     NEBLINA_COMMAND_RECORDER_PLAYBACK                   3
#define     NEBLINA_COMMAND_RECORDER_SESSION_COUNT              4
#define     NEBLINA_COMMAND_RECORDER_SESSION_INFO               5
#define     NEBLINA_COMMAND_RECORDER_SESSION_READ               6
#define     NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD           7
#define     NEBLINA_COMMAND_RECORDER_SESSION_OPEN               8
#define     NEBLINA_COMMAND_RECORDER_SESSION_CLOSE              9


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
#define     NEBLINA_PACKET_TYPE_DATA                            3
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

#define     NEBLINA_EEPROM_READ                         0
#define     NEBLINA_EEPROM_WRITE                        1

#define     NEBLINA_INTERFACE_CLOSE                     0   // Close streaming for interface
#define     NEBLINA_INTERFACE_OPEN                      1   // Open streaming for interface

#define     NEBLINA_SESSION_CLOSE                       0
#define     NEBLINA_SESSION_CREATE                      1
#define     NEBLINA_SESSION_OPEN                        2
#define     NEBLINA_SESSION_INVALID                     0xFF

/**********************************************************************************/

#pragma pack( push, 1 )

/**********************************************************************************/

typedef struct {
    uint8_t major;          // Major version (X.0.0)
    uint8_t minor;          // Minor version (0.Y.0)
    uint8_t build;          // Build version (0.0.Z)
} Version_t;

typedef struct {
	uint8_t apiVersion;     // API
    Version_t coreVersion;  // core fusion firmware version
	Version_t bleVersion;	// BLE comm firmware version
    uint64_t devid;			// Neblina UID
} NeblinaFirmwareVersion_t;

/**********************************************************************************/

typedef struct NeblinaPacketHeader_t {
    uint8_t subSystem:5;    // SubSystem
    uint8_t packetType:3;   // Packet type
    uint8_t length;         // Data length (in byte)
    uint8_t crc;            // Packet CRC
    uint8_t command;        // Command
} NeblinaPacketHeader_t;

/**********************************************************************************/

typedef struct NeblinaPacket_t {
    NeblinaPacketHeader_t header;
    uint8_t               data[1];        // Data buffer follows. i.e Data array more than one item
} NeblinaPacket_t;

/**********************************************************************************/

typedef struct {
    uint16_t current;
} NeblinaPowerChargeCurrent_t;

/**********************************************************************************/

typedef uint16_t NeblinaEEPROMRead_t;

typedef struct {
    uint16_t type;
    uint16_t pageId;
    uint8_t  content[8];
} NeblinaEEPROMData_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_RESET_TIMESTAMP_LIVE  = 0x00,
    NEBLINA_RESET_TIMESTAMP_DELAY = 0x01,
    NEBLINA_RESET_TIMESTAMP_COUNT           // Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaResetTimestamp_t );

/**********************************************************************************/

typedef enum {
    NEBLINA_INTERFACE_BLE  = 0x00,
    NEBLINA_INTERFACE_UART = 0x01,
    NEBLINA_INTERFACE_COUNT     // Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaInterface_t );

typedef enum {
    NEBLINA_INTERFACE_STATUS_BLE  = ( 1 << NEBLINA_INTERFACE_BLE ),
    NEBLINA_INTERFACE_STATUS_UART = ( 1 << NEBLINA_INTERFACE_UART )
} NEBLINA_ATTRIBUTE_PACKED( NeblinaInterfaceStatusMask_t );

typedef struct {
    uint8_t interface;  // Communication interface
    uint8_t state;          // Interface state (OPEN/CLOSE)
} NeblinaInterfaceState_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_LED_BLUE  = 0x00,
    NEBLINA_LED_RED   = 0x01,
    NEBLINA_LED_GREEN = 0x02,
    NEBLINA_LED_COUNT       // Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaLED_t );

typedef struct {
    uint8_t index;
    uint8_t state;
} NeblinaLEDState_t;

typedef struct {
    uint8_t status[NEBLINA_LED_COUNT];
} NeblinaLEDStatus_t;

/**********************************************************************************/

typedef uint32_t NeblinaFusionStatus_t;
typedef uint8_t NeblinaInterfaceStatus_t;
typedef uint16_t NeblinaSensorStatus_t;

/**********************************************************************************/

typedef struct {
    uint32_t fusion;      // Flag bits indicating fusion data streaming states
    uint16_t sensor;      // Flag bits indicating sensor data streaming states
    uint8_t  power;       // Flag bits indicating power states
    uint8_t  recorder;    // Flag bits indicating recorder states
    uint8_t  interface;
    uint8_t  led[NEBLINA_LED_COUNT];  // LED levels
} NeblinaSystemStatus_t;

/**********************************************************************************/

typedef struct {
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

typedef struct {
    uint8_t state;
    uint16_t sessionId;
    uint16_t length;
    uint32_t offset;
} NeblinaSessionDownload_t;

/**********************************************************************************/

typedef struct {
    uint32_t offset;
    uint8_t data[NEBLINA_PACKET_LENGTH_MAX - sizeof( uint32_t )];
} NeblinaSessionDownloadData_t;

/**********************************************************************************/

typedef struct {
    uint32_t length;
    uint16_t sessionId;
} NeblinaSessionInfo_t;

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

typedef struct {
    uint16_t temperature;
} TemperatureData_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_FUSION_STREAM_EULER            = 0x00,
    NEBLINA_FUSION_STREAM_EXTERNAL_FORCE   = 0x01,
    NEBLINA_FUSION_STREAM_FINGER_GESTURE   = 0x02,
    NEBLINA_FUSION_STREAM_MOTION_ANALYSIS  = 0x03,
    NEBLINA_FUSION_STREAM_MOTION_STATE     = 0x04,
    NEBLINA_FUSION_STREAM_PEDOMETER        = 0x05,
    NEBLINA_FUSION_STREAM_QUATERNION       = 0x06,
    NEBLINA_FUSION_STREAM_ROTATION_INFO    = 0x07,
    NEBLINA_FUSION_STREAM_SITTING_STANDING = 0x08,
    NEBLINA_FUSION_STREAM_TRAJECTORY_INFO  = 0x09,
    NEBLINA_FUSION_STREAM_COUNT            // Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionStream_t );

typedef enum {
    NEBLINA_FUSION_STATUS_EULER            = ( 1 << NEBLINA_FUSION_STREAM_EULER ),
    NEBLINA_FUSION_STATUS_EXTERNAL_FORCE   = ( 1 << NEBLINA_FUSION_STREAM_EXTERNAL_FORCE ),
    NEBLINA_FUSION_STATUS_FINGER_GESTURE   = ( 1 << NEBLINA_FUSION_STREAM_FINGER_GESTURE ),
    NEBLINA_FUSION_STATUS_MOTION_ANALYSIS  = ( 1 << NEBLINA_FUSION_STREAM_MOTION_ANALYSIS ),
    NEBLINA_FUSION_STATUS_MOTION_STATE     = ( 1 << NEBLINA_FUSION_STREAM_MOTION_STATE ),
    NEBLINA_FUSION_STATUS_PEDOMETER        = ( 1 << NEBLINA_FUSION_STREAM_PEDOMETER ),
    NEBLINA_FUSION_STATUS_QUATERNION       = ( 1 << NEBLINA_FUSION_STREAM_QUATERNION ),
    NEBLINA_FUSION_STATUS_ROTATION_INFO    = ( 1 << NEBLINA_FUSION_STREAM_ROTATION_INFO ),
    NEBLINA_FUSION_STATUS_SITTING_STANDING = ( 1 << NEBLINA_FUSION_STREAM_SITTING_STANDING ),
    NEBLINA_FUSION_STATUS_TRAJECTORY_INFO  = ( 1 << NEBLINA_FUSION_STREAM_TRAJECTORY_INFO ),
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionStatusMask_t );

typedef enum {
    NEBLINA_FUSION_TYPE_6AXIS = 0x00,
    NEBLINA_FUSION_TYPE_9AXIS = 0x01
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionType_t );

typedef enum {
    NEBLINA_FUSION_ROTATION_ALGORITHM_MAG  = 0x00,
    NEBLINA_FUSION_ROTATION_ALGORITHM_GYRO = 0x01
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionRotationAlgorithm_t );

typedef uint16_t NeblinaFusionDownsample_t;

typedef struct {
    uint8_t state;
    uint8_t algorithm;
} NeblinaFusionRotationInfo_t;

typedef struct {
    uint16_t stream;
    uint16_t downsample;
    uint16_t rate;
} NeblinaFusionStreamInfo_t;

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

typedef enum {
    NEBLINA_SENSOR_STREAM_ACCELEROMETER              = 0x00,
    NEBLINA_SENSOR_STREAM_ACCELEROMETER_GYROSCOPE    = 0x01,
    NEBLINA_SENSOR_STREAM_ACCELEROMETER_MAGNETOMETER = 0x02,
    NEBLINA_SENSOR_STREAM_GYROSCOPE                  = 0x03,
    NEBLINA_SENSOR_STREAM_HUMIDITY                   = 0x04,
    NEBLINA_SENSOR_STREAM_MAGNETOMETER               = 0x05,
    NEBLINA_SENSOR_STREAM_PRESSURE                   = 0x06,
    NEBLINA_SENSOR_STREAM_TEMPERATURE                = 0x07,
    NEBLINA_SENSOR_STREAM_COUNT                      // Keep last
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
    NEBLINA_SENSOR_COUNT                    // Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaSensorType_t );

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
} NEBLINA_ATTRIBUTE_PACKED( NeblinaAccelerometerRange_t );

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
} NEBLINA_ATTRIBUTE_PACKED( NeblinaGyroscopeRange_t );

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
