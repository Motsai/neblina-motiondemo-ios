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

#define     NEBLINA_COMMAND_FUSION_RATE                                         0x00
#define     NEBLINA_COMMAND_FUSION_DOWNSAMPLE                                   0x01
#define     NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM                          0x02
#define     NEBLINA_COMMAND_FUSION_QUATERNION_STREAM                            0x04
#define     NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM                           0x05
#define     NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM                        0x06
#define     NEBLINA_COMMAND_FUSION_FUSION_TYPE                                  0x07
#define     NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD                            0x08
#define     NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM                       0x09
#define     NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM                             0x0A
#define     NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM                      0x0C
#define     NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE                       0x0D    /// Deprecated
#define     NEBLINA_COMMAND_FUSION_FINGER_GESTURE_STREAM                        0x11
#define     NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM                         0x12
#define     NEBLINA_COMMAND_FUSION_EXTERNAL_HEADING_CORRECTION                  0x13
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_RESET                               0x14    /// Experimental
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_CALIBRATE                           0x15    /// Experimental
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_CREATE_POSE                         0x16    /// Experimental
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_SET_ACTIVE_POSE                     0x17    /// Experimental
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_GET_ACTIVE_POSE                     0x18    /// Experimental
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_STREAM                              0x19    /// Experimental
#define     NEBLINA_COMMAND_FUSION_ANALYSIS_POSE_INFO                           0x1A    /// Experimental
#define     NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION                   0x1B
#define     NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION                      0x1C
#define     NEBLINA_COMMAND_FUSION_MOTION_DIRECTION_STREAM                      0x1E
#define     NEBLINA_COMMAND_FUSION_SHOCK_SEGMENT_STREAM                         0x1F
#define     NEBLINA_COMMAND_FUSION_ACCELEROMETER_CALIBRATION_RESET              0x20
#define     NEBLINA_COMMAND_FUSION_ACCELEROMETER_CALIBRATION_SET_NEW_POSITION   0x21
#define     NEBLINA_COMMAND_FUSION_CALIBRATED_ACCELEROMETER_STREAM              0x22
#define     NEBLINA_COMMAND_FUSION_INCLINOMETER_CALIBRATE                       0x23
#define     NEBLINA_COMMAND_FUSION_INCLINOMETER_STREAM                          0x24
#define     NEBLINA_COMMAND_FUSION_MAGNETOMETER_AC_STREAM                       0x25
#define     NEBLINA_COMMAND_FUSION_MOTION_INTENSITY_TREND_STREAM                0x26
#define     NEBLINA_COMMAND_FUSION_SET_GOLFSWING_ANALYSIS_MODE                  0x27
#define     NEBLINA_COMMAND_FUSION_SET_GOLFSWING_MAXIMUM_ERROR                  0x28
#define     NEBLINA_COMMAND_FUSION_CLUSTERING_INFO_STREAM                       0x29
#define     NEBLINA_COMMAND_FUSION_COUNT                                        (NEBLINA_COMMAND_FUSION_CLUSTERING_INFO_STREAM + 1)      /// Keep last

/**********************************************************************************/

typedef uint16_t NeblinaFusionDownsample_t;
typedef uint32_t NeblinaFusionStatus_t;

/**********************************************************************************/

typedef enum {
    NEBLINA_FUSION_STREAM_CALIBRATED_ACCEL       = 0x00,
    NEBLINA_FUSION_STREAM_EULER                  = 0x01,
    NEBLINA_FUSION_STREAM_EXTERNAL_FORCE         = 0x02,
    NEBLINA_FUSION_STREAM_FINGER_GESTURE         = 0x03,
    NEBLINA_FUSION_STREAM_INCLINOMETER           = 0x04,
    NEBLINA_FUSION_STREAM_MAGNETOMETER_AC        = 0x05,
    NEBLINA_FUSION_STREAM_MOTION_ANALYSIS        = 0x06,
    NEBLINA_FUSION_STREAM_MOTION_DIRECTION       = 0x07,
    NEBLINA_FUSION_STREAM_MOTION_INTENSITY_TREND = 0x08,
    NEBLINA_FUSION_STREAM_MOTION_STATE           = 0x09,
    NEBLINA_FUSION_STREAM_PEDOMETER              = 0x0A,
    NEBLINA_FUSION_STREAM_QUATERNION             = 0x0B,
    NEBLINA_FUSION_STREAM_ROTATION_INFO          = 0x0C,
    NEBLINA_FUSION_STREAM_SHOCK_SEGMENT          = 0x0D,
    NEBLINA_FUSION_STREAM_SITTING_STANDING       = 0x0E,
    NEBLINA_FUSION_STREAM_TRAJECTORY_INFO        = 0x10,
    NEBLINA_FUSION_STREAM_COUNT            /// Keep last
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionStream_t );

typedef enum {
    NEBLINA_FUSION_STATUS_CALIBRATED_ACCEL       = ( 1 << NEBLINA_FUSION_STREAM_CALIBRATED_ACCEL ),
    NEBLINA_FUSION_STATUS_EULER                  = ( 1 << NEBLINA_FUSION_STREAM_EULER ),
    NEBLINA_FUSION_STATUS_EXTERNAL_FORCE         = ( 1 << NEBLINA_FUSION_STREAM_EXTERNAL_FORCE ),
    NEBLINA_FUSION_STATUS_FINGER_GESTURE         = ( 1 << NEBLINA_FUSION_STREAM_FINGER_GESTURE ),
    NEBLINA_FUSION_STATUS_INCLINOMETER           = ( 1 << NEBLINA_FUSION_STREAM_INCLINOMETER ),
    NEBLINA_FUSION_STATUS_MAGNETOMETER_AC        = ( 1 << NEBLINA_FUSION_STREAM_MAGNETOMETER_AC ),
    NEBLINA_FUSION_STATUS_MOTION_ANALYSIS        = ( 1 << NEBLINA_FUSION_STREAM_MOTION_ANALYSIS ),
    NEBLINA_FUSION_STATUS_MOTION_DIRECTION       = ( 1 << NEBLINA_FUSION_STREAM_MOTION_DIRECTION ),
    NEBLINA_FUSION_STATUS_MOTION_INTENSITY_TREND = ( 1 << NEBLINA_FUSION_STREAM_MOTION_INTENSITY_TREND ),
    NEBLINA_FUSION_STATUS_MOTION_STATE           = ( 1 << NEBLINA_FUSION_STREAM_MOTION_STATE ),
    NEBLINA_FUSION_STATUS_PEDOMETER              = ( 1 << NEBLINA_FUSION_STREAM_PEDOMETER ),
    NEBLINA_FUSION_STATUS_QUATERNION             = ( 1 << NEBLINA_FUSION_STREAM_QUATERNION ),
    NEBLINA_FUSION_STATUS_ROTATION_INFO          = ( 1 << NEBLINA_FUSION_STREAM_ROTATION_INFO ),
    NEBLINA_FUSION_STATUS_SHOCK_SEGMENT          = ( 1 << NEBLINA_FUSION_STREAM_SHOCK_SEGMENT ),
    NEBLINA_FUSION_STATUS_SITTING_STANDING       = ( 1 << NEBLINA_FUSION_STREAM_SITTING_STANDING ),
    NEBLINA_FUSION_STATUS_TRAJECTORY_INFO        = ( 1 << NEBLINA_FUSION_STREAM_TRAJECTORY_INFO ),
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionStatusMask_t );

typedef enum {
    NEBLINA_FUSION_TYPE_6AXIS_ONLINE_CALIBRATION                = 0x00, /// default 6-axis mode using accelerometers and gyroscopes with online calibration procedures
    NEBLINA_FUSION_TYPE_9AXIS_ONLINE_CALIBRATION                = 0x01, /// 9-axis mode using accelerometers, gyroscopes and magnetometers featuring online calibration routines
    NEBLINA_FUSION_TYPE_9AXIS_LOCK_HEADING                      = 0x02, /// 9-axis mode utilizing a lock heading mechanism based on the magnetic field signature
    NEBLINA_FUSION_TYPE_6AXIS_MANUAL_CALIBRATION                = 0x03, /// 6-axis mode with calibrated accelerometers. Manual 6-position calibration for accelerometers should be conducted beforehand
    NEBLINA_FUSION_TYPE_9AXIS_MANUAL_CALIBRATION                = 0x04, /// 9-axis mode with calibrated accelerometers. Manual 6-position calibration for accelerometers should be conducted beforehand
    NEBLINA_FUSION_TYPE_9AXIS_LOCK_HEADING_MANUAL_CALIBRATION   = 0x05, /// 9-axis mode with an automatic lock heading mechanism and manually calibrated accelerometers, which must be conducted beforehand.
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionType_t );

typedef enum {
    NEBLINA_FUSION_ROTATION_ALGORITHM_MAG  = 0x00,
    NEBLINA_FUSION_ROTATION_ALGORITHM_GYRO = 0x01,
    NEBLINA_FUSION_ROTATION_ALGORITHM_TWO_EDGE_WHEEL = 0x02,
    NEBLINA_FUSION_ROTATION_ALGORITHM_THREE_EDGE_WHEEL = 0x03
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionRotationAlgorithm_t );

typedef enum {
    NEBLINA_FUSION_SWIPE_LEFT  = 0x00,
    NEBLINA_FUSION_SWIPE_RIGHT = 0x01,
    NEBLINA_FUSION_SWIPE_UP	   = 0x02,
    NEBLINA_FUSION_SWIPE_DOWN  = 0x03,
    NEBLINA_FUSION_FLIP_LEFT   = 0x04,
    NEBLINA_FUSION_FLIP_RIGHT  = 0x05,
    NEBLINA_FUSION_DOUBLE_TAP  = 0x06,
    NEBLINA_FUSION_NO_GESTURE  = 0xFF, //no gesture
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionFingerGesture_t );

typedef enum {
    NEBLINA_FUSION_SHOCK_THRESHOLD_4G_IN_16G_RANGE      = 0x04, //4g threshold, only works in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_5G_IN_16G_RANGE      = 0x05, //5g threshold, only works in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_6G_IN_16G_RANGE      = 0x06, //6g threshold, only works in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_7G_IN_16G_RANGE      = 0x07, //7g threshold, only works in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_8G_IN_16G_RANGE      = 0x08, //8g threshold, only works in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_56_PERCENT_FULLSCALE = 0x09, ///e.g., 9g in 16g range, or 4.48g in 8g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_62_PERCENT_FULLSCALE = 0x0A, ///e.g., 10g in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_69_PERCENT_FULLSCALE = 0x0B, ///e.g., 11g in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_75_PERCENT_FULLSCALE = 0x0C, ///e.g., 12g in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_81_PERCENT_FULLSCALE = 0x0D, ///e.g., 13g in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_87_PERCENT_FULLSCALE = 0x0E, ///e.g., 14g in 16g range
    NEBLINA_FUSION_SHOCK_THRESHOLD_94_PERCENT_FULLSCALE = 0x0F, ///e.g., 15g in 16g range
} NEBLINA_ATTRIBUTE_PACKED( NeblinaFusionShockThreshold_t );

/**********************************************************************************/

#pragma pack(push, 1)

/**********************************************************************************/

typedef struct {
    int16_t w;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaFusionQuaternionFxp_t;

typedef struct {
    uint32_t timestamp;
    int16_t w;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaFusionQuaternionFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float w;
    float x;
    float y;
    float z;
} NeblinaFusionQuaternionFpTs_t;

/**********************************************************************************/

typedef struct {
    int16_t yaw;
    int16_t pitch;
    int16_t roll;
} NeblinaFusionEulerFxp_t;

typedef struct {
    uint32_t timestamp;
    int16_t yaw;
    int16_t pitch;
    int16_t roll;
} NeblinaFusionEulerFxpTs_t;

typedef struct {
    float yaw;
    float pitch;
    float roll;
} NeblinaFusionEulerFp_t;

typedef struct {
    uint32_t timestamp;
    float yaw;
    float pitch;
    float roll;
} NeblinaFusionEulerFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t inclinationAngle;
} NeblinaFusionInclinometerFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float inclinationAngle;
} NeblinaFusionInclinometerFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestampUnix;
    uint16_t magnetometerAC;
    uint32_t timestampUs;
} NeblinaFusionMagnetometerAcFxpTs_t;

typedef struct {
    uint32_t timestampUnix;
    float magnetometerAC;
    uint32_t timestampUs;
} NeblinaFusionMagnetometerAcFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} NeblinaFusionExternalForceFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float x;
    float y;
    float z;
} NeblinaFusionExternalForceFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    NeblinaFusionEulerFxp_t error;
    uint16_t counter;
    uint8_t progress;
} NeblinaFusionTrajectoryInfoFxpTs_t;

typedef struct {
    uint32_t timestamp;
    NeblinaFusionEulerFp_t error;
    uint16_t counter;
    uint8_t progress;
} NeblinaFusionTrajectoryInfoFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint8_t state;
    uint32_t sitTime;
    uint32_t standTime;
} NeblinaFusionSittingStandingTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint32_t count;
    uint16_t rpm;
} NeblinaFusionRotationInfoTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint16_t stepCount;
    uint8_t cadence; //steps per minute
    int16_t direction;
    uint16_t stairsUpCount;
    uint16_t stairsDownCount;
    uint8_t strideLength; //in cm
    uint16_t totalDistance; //in dm
} NeblinaFusionPedometerFxpTs_t;

typedef struct {
    uint32_t timestamp;
    uint16_t stepCount;
    uint8_t cadence;
    float direction;
    uint16_t stairsUpCount;
    uint16_t stairsDownCount;
    uint8_t strideLength; //in cm
    uint16_t totalDistance; //in dm
} NeblinaFusionPedometerFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint8_t swipe;
} NeblinaFusionFingerGestureTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    int16_t directionAngle;
} NeblinaFusionMotionDirectionFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float directionAngle;
} NeblinaFusionMotionDirectionFpTs_t;

/**********************************************************************************/

typedef struct  {
    uint16_t intensityMax; //maximum intensity over the past minute
    uint16_t intensityMean; //average intensity over the past minute
    uint8_t intensityMaxIndex; //at what second/index did the maximum intensity occur?
} NeblinaFusionMotionIntensityTrendData_t;

typedef struct  {
    uint32_t timestamp;
    NeblinaFusionMotionIntensityTrendData_t data;
} NeblinaFusionMotionIntensityTrendUnixTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint8_t state;
} NeblinaFusionMotionStateTs_t;

/**********************************************************************************/

typedef struct {
    int16_t yaw;
    uint16_t error;
} NeblinaFusionHeadingCorrection_t;

typedef struct {
    uint8_t id;
    NeblinaFusionQuaternionFxp_t quaternion;
} NeblinaFusionMotionAnalysisPose_t;

typedef struct {
    uint32_t timestamp;
    uint8_t id;
    uint16_t distanceCenter;
    uint16_t distanceQuatrn;
} NeblinaFusionMotionAnalysisPoseTs_t;

typedef struct {
    uint8_t state;
    uint16_t trendUpdateInSeconds; ///If set to X, it means that the motion intensity trend is updated every X seconds
} NeblinaFusionMotionIntensityTrendStreamInfo_t;

typedef struct {
    uint8_t state;
    uint8_t algorithm;
} NeblinaFusionRotationInfo_t;

typedef struct {
    uint8_t state;
    NeblinaFusionShockThreshold_t threshold;
} NeblinaFusionShockInfo_t;

typedef struct {
    uint16_t downsample;
    uint16_t rate;
} NeblinaFusionStreamInfo_t;

typedef struct
{
    uint32_t unixTimestamp; //Unix timestamp in seconds
    uint8_t activity;
    uint8_t cycleLocked; //just detected a new cycle
    uint8_t learningProgress; //the percentage of completion for the learning phase in order to lock to a new pattern
    uint8_t cycleProgress; //when the learning phase is complete (at 100), i.e., a periodic cycle is locked, this progress bar (0-100) will track the signal phase within the next cycle. The number will go from 0 to 100 per cycle execution. After reaching 100, the cycle is evaluated to verify whether it has been a consistent pattern or not
    uint16_t patternCount; //counts the number of repeating patterns
    uint16_t patternPeriod; //in ms
    uint32_t timestampUs; //timestamp in microseconds
} NeblinaFusionClusteringInfoTs_t;

typedef struct {
    uint8_t state; //0: streaming OFF, 1: streaming ON
    uint8_t mode; //0: cycle detection, 1: learning, 2: tracking/detecting
    uint8_t sensor; //clustering will use either 0: accelerometers, or 1: gyroscopes
    uint8_t downsample; //1, 2, 3, 4, etc.
    uint8_t snr; //default SNR scaling factor: 1, 2, 3, 4, etc.
} NeblinaFusionClusteringConfig_t;

/**********************************************************************************/

#pragma pack(pop)

/**********************************************************************************/
