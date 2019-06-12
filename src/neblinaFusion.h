/***********************************************************************************
* Copyright (c) 2010 - 2016, Motsai
* All rights reserved.
*
* Proprietary and confidential
* Unauthorized copying of this file, via any medium is strictly prohibited.
***********************************************************************************/

#ifndef NEBLINA_FUSION_H
#define NEBLINA_FUSION_H

/**********************************************************************************/

#include "stdint.h"

/**********************************************************************************/

#define FUSION_ENABLE 1
#define FUSION_DISABLE 0


#define     NEBLINA_FUSION_DOWNSAMPLE                   		 1
#define     NEBLINA_FUSION_MOTION_STATE                 		 2
#define     NEBLINA_FUSION_IMU		                    		 3
#define     NEBLINA_FUSION_EULER_ANGLE		            		 5
#define     NEBLINA_FUSION_QUATERNION      			       		 4
#define     NEBLINA_FUSION_EXTERNAL_FORCE		         		 6
#define     NEBLINA_FUSION_SET_TYPE                  			 7
#define     NEBLINA_FUSION_TRAJECTORY		             		 8
#define     NEBLINA_FUSION_TRAJECTORY_INFO              		 9
#define     NEBLINA_FUSION_PEDOMETER		              	    10
#define     NEBLINA_FUSION_MAG		                   			11
#define     NEBLINA_FUSION_SITTING_STANDING		      			12
#define     NEBLINA_FUSION_LOCK_HEADING_REFERENCE      			13
#define     NEBLINA_FUSION_ACCELEROMETER_RANGE         			14
#define     NEBLINA_FUSION_DISABLE_ALL_STREAMING       			15
#define     NEBLINA_FUSION_RESET_TIMESTAMP             			16
#define     NEBLINA_FUSION_FINGER_GESTURE	        			17
#define     NEBLINA_FUSION_ROTATION		              			18
#define     NEBLINA_FUSION_EXTERNAL_HEADING_CORRECTION 			19
#define     NEBLINA_FUSION_MOTION_ANALYSIS_RESET              	20
#define     NEBLINA_FUSION_MOTION_ANALYSIS_CALIBRATE          	21
#define     NEBLINA_FUSION_MOTION_ANALYSIS_CREATE_POSE        	22
#define     NEBLINA_FUSION_MOTION_ANALYSIS_SET_ACTIVE_POSE  	23
#define     NEBLINA_FUSION_MOTION_ANALYSIS_GET_ACTIVE_POSE	 	24
#define     NEBLINA_FUSION_MOTION_ANALYSIS_STATE              	25
#define     NEBLINA_FUSION_MOTION_ANALYSIS_GET_POSE_INFO        26
#define     NEBLINA_FUSION_CALIBRATE_FORWARD_POSITION           27
#define     NEBLINA_FUSION_CALIBRATE_DOWN_POSITION              28
#define     NEBLINA_FUSION_GYROSCOPE_RANGE                      29
#define     NEBLINA_FUSION_MOTION_DIRECTION                     30
#define     NEBLINA_FUSION_SHOCK_SEGMENT                        31
#define     NEBLINA_FUSION_ACCEL_CALIBRATION_RESET              32
#define     NEBLINA_FUSION_ACCEL_CALIBRATION_NEW_POSITION       33
#define     NEBLINA_FUSION_ACCEL_CALIBRATED_STREAM              34
#define     NEBLINA_FUSION_INCLINOMETER_CALIBRATE               35
#define     NEBLINA_FUSION_INCLINOMETER_STREAM                  36
#define     NEBLINA_FUSION_MAGNETOMETER_AC_STREAM               37
#define     NEBLINA_FUSION_MOTION_INTENSITY_TREND_STREAM        38
#define     NEBLINA_FUSION_SET_GOLFSWING_ANALYSIS_MODE          39
#define     NEBLINA_FUSION_SET_GOLFSWING_MAXIMUM_ERROR          40
#define     NEBLINA_FUSION_LAST_INDEX                           41  // Keep synchronize with last fusion index

//FusionCtrlReg bit mask
#define DISTANCE_STREAM			0x00000001
#define FORCE_STREAM			0x00000002
#define EULER_STREAM			0x00000004
#define QUATERNION_STREAM		0x00000008
#define IMU_STREAM				0x00000010
#define MOTIONSTATE_STREAM		0x00000020
#define STEPS_STREAM			0x00000040
#define MAG_STREAM 				0x00000080
#define SIT_STAND_STREAM		0x00000100
#define FINGER_GESTURE_STREAM	0x00000200
#define ROTATION_INFO_STREAM	0x00000400
#define MOTION_ANALYSIS_STREAM	0x00000800
#define MOTION_DIRECTION_STREAM 0x00001000
#define SHOCK_SEGMENT_STREAM    0x00002000
#define ACCEL_CALIBRATED_STREAM 0x00004000
#define INCLINOMETER_STREAM     0x00008000
#define MAGNETOMETER_AC_STREAM  0x00010000
#define MOTION_INTENSITY_STREAM 0x00020000
#define GOLF_ANALYSIS_STREAM    0x00040000
//////////////////////////////////////////

#define FUSION_DATASIZE_MAX         12
#define HIGH_G_HALF_BUFFER_SIZE     100          //half of the total number of samples to be buffered when a high g shock occurs
#define ACCEL_HIGH_G_TH             419430400   //(5/8) times the full-scale accelerometer range is the threshold. This is the squared value
#define ACCEL_HIGH_G_TH_ENCODED     10

#define BOSCH_SENSOR_FUSION_CONFIG  \
{       \
    .deltaT = DELTA_T2_BOSCH, \
    .accel16gHighTh = HIGH_EXT_FORCE_TH_16G, \
    .accel16gLowTh = LOW_EXT_FORCE_TH_16G \
}

/**********************************************************************************/

#pragma pack(push, 1)

/**********************************************************************************/

typedef struct
{
	uint32_t timestamp;
	uint8_t data[FUSION_DATASIZE_MAX];
} NeblinaFusionPacket_t;

typedef struct {
	union {
		int16_t data[3];
		struct {
			int dataX:16;
			int dataY:16;
			int dataZ:16;
		};
	};
	uint32_t timestamp;
} MotionSensorThreeAxisData_t;

typedef struct {
    MotionSensorThreeAxisData_t accelData;
    MotionSensorThreeAxisData_t magData;
    MotionSensorThreeAxisData_t gyroData;
	uint32_t unixTimestamp;
} MotionSensorArray_t;

/**********************************************************************************/

typedef enum {
	ACCEL_RANGE_2G = (uint8_t)0x01,
	ACCEL_RANGE_4G = (uint8_t)0x02,
	ACCEL_RANGE_8G = (uint8_t)0x03,
	ACCEL_RANGE_16G = (uint8_t)0x04,
} AccRange_t;

typedef enum {
	GYROSCOPE_RANGE_2000_DPS = (uint8_t)0x00,
    GYROSCOPE_RANGE_1000_DPS = (uint8_t)0x01,
    GYROSCOPE_RANGE_500_DPS = (uint8_t)0x02,
    GYROSCOPE_RANGE_250_DPS = (uint8_t)0x03,
} GyroRange_t;

typedef enum {
	MAGNETOMETER_RANGE_2G = 2,
	MAGNETOMETER_RANGE_4G = 4,
	MAGNETOMETER_RANGE_8G = 8,
    MAGNETOMETER_RANGE_13G = 13,
	MAGNETOMETER_RANGE_16G = 16,
	MAGNETOMETER_RANGE_25G = 25,
} MagRange_t;

typedef enum {
    ROTATION_ALGORITHM_MAGNETOMETER = (uint8_t)0x00, //regular circular wheel using magnetometers
    ROTATION_ALGORITHM_GYROSCOPE = (uint8_t)0x01, //regular circular wheel using gyros
    ROTATION_ALGORITHM_TWO_EDGES = (uint8_t)0x02, //special wheel with two edges
    ROTATION_ALGORITHM_THREE_EDGES = (uint8_t)0x03, //special wheel with three edges
} RotationAlgo_t;

/**********************************************************************************/

typedef struct {
	AccRange_t accelRange;
	GyroRange_t gyroRange;
	MagRange_t magRange;
} SensorRange_t;

/**********************************************************************************/

// Fixed-point Quaternion
typedef struct {
	int16_t q[4];
} QuaternionFxp_t;

// Timestamped fixed-point Quaternion
typedef struct {
    uint32_t timestamp;
    int16_t q[4];
} QuaternionFxpTs_t;

// Floating-point Quaternion
typedef struct {
    float q[4];
} QuaternionFp_t;

// Timestamped floating-point Quaternion
typedef struct {
    uint32_t timestamp;
    float q[4];
} QuaternionFpTs_t;

/**********************************************************************************/

// Fixed-point Euler angles
// i.e., round(angle*10)
typedef struct {
	int16_t yaw; //first rotation, around z-axis
	int16_t pitch; //second rotation, around y-axis
	int16_t roll; //third rotation, around x-axis
} EulerFxp_t;

// Timestamp fixed-point Euler angles
typedef struct {
    uint32_t timestamp;
    int16_t yaw; //first rotation, around z-axis
    int16_t pitch; //second rotation, around y-axis
    int16_t roll; //third rotation, around x-axis
} EulerFxpTs_t;

// Floating-point Euler angles
typedef struct {
    float yaw;
    float pitch;
    float roll;
} EulerFp_t;

// Timestamped floating-point Euler angles
typedef struct {
    uint32_t timestamp;
    float yaw;
    float pitch;
    float roll;
} EulerFpTs_t;

//Timestamped fixed-point inclinometer data
typedef struct {
    uint32_t timestamp;
    int16_t inclinationAngle;
} InclinometerFxpTs_t;

//Timestamped floating-point inclinometer data
typedef struct {
    uint32_t timestamp;
    float inclinationAngle;
} InclinometerFpTs_t;

//Timestamped fixed-point Magnetometer AC magnitude data
typedef struct {
    uint32_t unixTimestamp;
    uint16_t magnetometerAC;
    uint32_t timestampUs;
} MagnetometerAcFxpTs_t;

//Timestamped floating-point Magnetometer AC magnitude data (unit = gauss)
typedef struct {
    uint32_t unixTimestamp;
    float magnetometerAC;
    uint32_t timestampUs;
} MagnetometerAcFpTs_t;

/**********************************************************************************/

// Fixed-point external force vector (unit is 'g')
typedef struct {
	int16_t x;
	int16_t y;
	int16_t z;
} ExternalForceFxp_t;

// Timestamp fixed-point external force vector
typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} ExternalForceFxpTs_t;

// Floating-point external force vector
typedef struct {
	float x;
	float y;
	float z;
} ExternalForceFp_t;

// Timestamped floating-point external force vector
typedef struct {
    uint32_t timestamp;
    float x;
    float y;
    float z;
} ExternalForceFpTs_t;

/**********************************************************************************/

typedef enum{ //filter type: 6-axis IMU (no magnetometer), or 9-axis MARG
	IMU_FILTER_ONLINE_CALIBRATION = (uint8_t)0x00, //default 6-axis with online calibration
	MARG_FILTER_ONLINE_CALIBRATION = (uint8_t)0x01, //9-axis mode with online calibration
	MARG_FILTER_LOCK_HEADING = (uint8_t)0x02, //lock heading mode in 9-axis
	IMU_FILTER_MANUAL_ACCEL_CALIBRATION = (uint8_t)0x03, //accelerometers are manually calibrated
    MARG_FILTER_MANUAL_ACCEL_CALIBRATION = (uint8_t)0x04, //accelerometers are manually calibrated
    MARG_FILTER_LOCK_HEADING_MANUAL_ACCEL_CALIBRATION = (uint8_t)0x05, //9-axis with lock heading mode and manually calibrated accelerometers
} FilterType_t;

typedef struct { //3-axis raw data type
  int16_t data[3];
} AxesRawFxp_t;

typedef struct { //3-axis raw data floating-point type
	float data[3];
} AxesRawFp_t;

typedef struct { //9-axis data type
	AxesRawFxp_t accel; //accelerometer
	AxesRawFxp_t gyro; //gyroscope
	AxesRawFxp_t mag; //magnetometer
} Marg9AxisFxp_t;

/**********************************************************************************/

// Fixed-point 6-axis IMU data type (no magnetometer)
typedef struct {
	AxesRawFxp_t accel; //accelerometer
	AxesRawFxp_t gyro; //gyroscope
} Imu6AxisFxp_t;

// Timestamped fixed-point 6-axis IMU
typedef struct {
    uint32_t timestamp;
    AxesRawFxp_t accel; //accelerometer
    AxesRawFxp_t gyro; //gyroscope
} Imu6AxisFxpTs_t;

// Floating-point 6-axis IMU
typedef struct {
    AxesRawFp_t accel;   // accelerometer
    AxesRawFp_t gyro;   // gyroscope
} Imu6AxisFp_t;

// Timestamped floating-point 6-axis IMU
typedef struct {
    uint32_t timestamp;
    AxesRawFp_t accel;   // accelerometer
    AxesRawFp_t gyro;   // gyroscope
} Imu6AxisFpTs_t;

/**********************************************************************************/

// Fixed-point magnetometer
typedef struct {
    AxesRawFxp_t mag;  // magnetometer
    AxesRawFxp_t accel;  // accelerometer
} MagFxp_t;

// Timestamped fixed-point magnetometer
typedef struct {
    uint32_t timestamp;
    AxesRawFxp_t mag;  // magnetometer
    AxesRawFxp_t accel;  // accelerometer
} MagFxpTs_t;

// Floating-point magnetometer
typedef struct {
    AxesRawFp_t mag;
    AxesRawFp_t accel;
} MagFp_t;

// Timestamped floating-point magnetometer
typedef struct {
    uint32_t timestamp;
    AxesRawFp_t mag;
    AxesRawFp_t accel;
} MagFpTs_t;

/**********************************************************************************/

typedef struct {
    uint8_t state;
} MotionState_t;

typedef struct {
    uint32_t timestamp;
    uint8_t state;
} MotionStateTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint8_t swipe;
} FingerGestureTs_t;

/**********************************************************************************/

typedef struct {
    uint16_t stepCount;
    uint8_t cadence;
    int16_t direction;
    uint16_t stairsUpCount;
    uint16_t stairsDownCount;
    uint8_t strideLength; //in cm
    uint16_t totalDistance; //in dm
} PedometerFxp_t;

typedef struct {
    uint16_t stepCount;
    uint8_t cadence;
    float direction;
    uint16_t stairsUpCount;
    uint16_t stairsDownCount;
    uint8_t strideLength; //in cm
    uint16_t totalDistance; //in dm
} PedometerFp_t;

typedef struct {
    uint32_t timestamp;
    uint16_t stepCount;
    uint8_t cadence; //steps per minute
    int16_t direction;
    uint16_t stairsUpCount;
    uint16_t stairsDownCount;
    uint8_t strideLength; //in cm
    uint16_t totalDistance; //in dm
} PedometerFxpTs_t;

typedef struct {
    uint32_t timestamp;
    uint16_t stepCount;
    uint8_t cadence;
    float direction;
    uint16_t stairsUpCount;
    uint16_t stairsDownCount;
    uint8_t strideLength; //in cm
    uint16_t totalDistance; //in dm
} PedometerFpTs_t;

/**********************************************************************************/

typedef struct {
    uint32_t count;
    uint16_t rpm;
} RotationInfo_t;

typedef struct {
    uint32_t timestamp;
    uint32_t count;
    uint16_t rpm;
} RotationInfoTs_t;

/**********************************************************************************/

typedef struct {
    uint8_t state;
    uint32_t sitTime;
    uint32_t standTime;
} SittingStanding_t;

typedef struct {
    uint32_t timestamp;
    uint8_t state;
    uint32_t sitTime;
    uint32_t standTime;
} SittingStandingTs_t;

/**********************************************************************************/

typedef struct {
    EulerFxp_t error;
    uint16_t counter;
    uint8_t progress;
} TrajectoryInfoFxp_t;

typedef struct {
    EulerFp_t error;
    uint16_t counter;
    uint8_t progress;
} TrajectoryInfoFp_t;

typedef struct {
    uint32_t timestamp;
    EulerFxp_t error;
    uint16_t counter;
    uint8_t progress;
} TrajectoryInfoFxpTs_t;

typedef struct {
    uint32_t timestamp;
    EulerFp_t error;
    uint16_t counter;
    uint8_t progress;
} TrajectoryInfoFpTs_t;

/**********************************************************************************/

typedef struct { //steps and pedometer data types
	uint8_t stepDetect; //detection of a step gives 1. It also returns 1, if no step has been detected for 5 seconds
	uint16_t stepCount; //number of steps taken so far.
	uint8_t spm; //cadence: number of steps per minute
	uint32_t toeOffTimestamp;
	uint16_t stairsUpCount;
    uint16_t stairsDownCount;
    uint8_t strideLength; //in cm
    uint16_t totalDistance; //total distance in dm
} Steps_t;

typedef struct wheels_t { //wheel rotation data type
	uint8_t rotDetect; //detection of a full 360 degrees rotation gives 1. It also returns 1, if no rotation has been detected for 5 seconds
	uint32_t wheelRotCnt; //number of wheel rotations done so far
	uint16_t rpm; //rounds per minute
} Wheels_t;

typedef struct sit_stand_t {
	uint8_t sitStandMode; //0: sitting, 1: standing, 2: no change
	uint32_t sitTime; //in seconds
	uint32_t standTime; //in seconds
} SitStand_t;

typedef enum{
	MOTION_NO_CHANGE = (uint8_t)0x00, //holds its previous state
	MOTION_STOP = (uint8_t)0x01, //the device stops moving
	MOTION_START = (uint8_t)0x02, //the device starts moving
} MotionStatus_t;

typedef enum{
	SWIPE_LEFT 	= (uint8_t)0x00,
	SWIPE_RIGHT = (uint8_t)0x01,
	SWIPE_UP	= (uint8_t)0x02,
	SWIPE_DOWN 	= (uint8_t)0x03,
	FLIP_LEFT 	= (uint8_t)0x04,
	FLIP_RIGHT 	= (uint8_t)0x05,
	DOUBLE_TAP	= (uint8_t)0x06,
	NO_GESTURE 	= (uint8_t)0xFF, //no gesture
} FingerGesture_t;

typedef struct {
	uint8_t minAngle; //The minimum rotation angle that is taken into consideration. The default value is 40 degrees
	uint8_t ticksPerRevolution; //the total number of partial rotations within a full revolution. This value is 2 for the Soucy Tank, and 3 for the Soucy Tractor. The default value is 2
} GyroRotateParam_t;

typedef struct {
	uint8_t id;
	uint16_t distanceCenter;
	uint16_t distanceQuatrn;
} Pose_t;

typedef struct {
    uint32_t timestamp;
    uint8_t id;
    uint16_t distanceCenter;
    uint16_t distanceQuatrn;
} PoseTs_t;

typedef struct {
    uint32_t timestamp;
    int16_t directionAngle;
} MotionDirectionFxpTs_t;

typedef struct {
    uint32_t timestamp;
    float directionAngle;
} MotionDirectionFpTs_t;

typedef enum{
	NONE = (uint8_t)0x00,
	FLAT_WALK = (uint8_t)0x01,
	STAIRS_UP = (uint8_t)0x02,
	STAIRS_DOWN = (uint8_t)0x03,
} Activity_t;

typedef struct motionDirectionVector_t {
    int32_t x;
    int32_t y;
    int32_t z;
} MotionDirectionVector_t;

typedef struct {
    int32_t x;
    int32_t y;
    int32_t z;
} VectorFxp_t;

typedef struct {
    float x;
    float y;
    float z;
} VectorFp_t;

typedef struct  {
    uint16_t intensityMax; //maximum intensity over the past minute
    uint16_t intensityMean; //average intensity over the past minute
    uint8_t intensityMaxIndex; //at what second/index did the maximum intensity occur?
} MotionIntensityTrendData_t;

typedef struct  {
    uint32_t timestamp;
    MotionIntensityTrendData_t data;
} MotionIntensityTrendUnixTs_t;

typedef struct {
    MotionIntensityTrendData_t frontEndData; //data available for streaming
    //below are backend variables used only for internal calculations of the motion intensity trend
    uint8_t sampleCounter; //for each sample this counter is added by one, when the counter reaches 1 second of data, average intensity over the past second is captured and the "secondCounter" is added by 1
    uint8_t secondCounter; //When sample counter captures 1 full second of data, this counter is added by 1. The counter counts up to 1 minute (60 seconds) and then resets. At that point, the max/mean intensity values become valid
    uint64_t intensityWithinSecondSum; //sum of acceleration intensities over 1 second of samples
    uint64_t intensityPerSecondSquareSumMean; //mean value among the last 60 "intensityWithinSecondSum" values (1 minute of data)
    uint64_t intensityPerSecondSquareSumMax; //maximum value among the last 60 "intensityWithinSecondSum" values (1 minute of data)
    uint16_t updateIntensityTrendAfterThisManySeconds; //the updates for intensity trend packet should take place every "updateIntensityTrendAfterThisManySeconds" seconds
} MotionIntensityTrendArchive_t;

typedef struct {
    uint32_t timestamp; //unix timestamp
    uint8_t backswingScore; //backswing score range is 0-100
    uint8_t downswingScore; //downswing score range is 0-100
    uint8_t postSwingScore; //ball hit score range is 0-100
    uint8_t maximumBackswingError; //overall maximum backswing error, which is multiplied by 1000 and will be saturated at 255, i.e., error >= 0.256 is considered to be too high
    uint8_t maximumClubSpeed; //in km/h => assuming the driver club length to be the average size of 113cm
    uint8_t closestRefSwingId; //the ID of the closest reference swing
    int16_t errorYaw; //maximum backswing error in yaw multiplied by 10, in degrees (the worst test sample is compared with the closest sample in the best fit reference swing)
    int16_t errorPitch; //maximum backswing error in pitch multiplied by 10, in degrees (the worst test sample is compared with the closest sample in the best fit reference swing)
    int16_t errorRoll; //maximum backswing error in roll multiplied by 10, in degrees (the worst test sample is compared with the closest sample in the best fit reference swing)
} GolfSwingAnalysisUnixTs_t;

typedef struct { //all features
	uint8_t motion; //0: no change in motion, 1: stops moving, 2: starts moving
	Marg9AxisFxp_t imuData; //18 bytes
	QuaternionFxp_t quatrn; //8 bytes
	EulerFxp_t angles; //6 bytes
	ExternalForceFxp_t force; //6 bytes
	EulerFxp_t anglesError; //6 bytes: error in Euler angles compared to a reference trajectory
	uint16_t motionTrackCntr; //shows how many times the pre-recorded track has been repeated
	uint8_t motionTrackProgress; //the percentage showing how much of a pre-recorded track has been covered
	uint32_t timestamp; //4 bytes: in microseconds
	uint32_t unixTimestamp; //Unix timestamp in seconds
	Steps_t steps;
	int16_t direction;
	SitStand_t sitStand;
	uint8_t swipe; //finger swipe pattern: swipe left (0), or swipe right (1), swipe up (2), swipe down (3), flip left (4), flip right (5), double tap (6)
	Wheels_t rotationInfo; //rpm speed, rotation count
	Pose_t poseInfo;
	Activity_t activity;
	MotionDirectionVector_t motionDirectionVector;
	AxesRawFxp_t accelCalibrated;
	int16_t inclinationAngle; //constains (int16_t)(angle*100), where angle is in degrees
	uint16_t magAC; //Magnetometer AC Magnitude
	MotionIntensityTrendArchive_t intensityTrendData;
} MotionFeatures_t;

typedef enum {
    WAIT_FOR_SHOCK = 0x00,
    WAIT_FOR_BEFORE_SHOCK_BUFFER_EXTRACTION = 0x01,
    WAIT_FOR_AFTER_SHOCK_BUFFER_EXTRACTION = 0x02,
} ShockState_t;

typedef struct {
    uint32_t timestamp;
    int16_t accelX;
    int16_t accelY;
    int16_t accelZ;
    int16_t gyroX;
    int16_t gyroY;
    int16_t gyroZ;
} AccelGyroTsFxp_t;

typedef struct
{
    uint32_t shockThresholdValue;
    uint8_t shockThresholdEncoded;
    uint16_t beforeShockBufferCurrentIndex;
    uint16_t afterShockBufferCurrentIndex;
    uint16_t shockSampleIndex;
    ShockState_t state;
    AccelGyroTsFxp_t accelGyroBufferBeforeShock[HIGH_G_HALF_BUFFER_SIZE];
    AccelGyroTsFxp_t accelGyroBufferAfterShock[HIGH_G_HALF_BUFFER_SIZE];
} ShockData_t;


typedef uint16_t FusionDownsample_t;

typedef struct
{
    int16_t yaw;
    uint16_t error;
} FusionHeadingCorrection_t;

typedef struct  {
    uint8_t nbTurns; //moving average filter applied over this number of heading turns
    uint8_t headingCorrectionMaxDps; //maximum heading correction applied per second ==> default heading correction mode, if this value is set to 0, then use the below parameter
    uint8_t headingCorrectionLpfGainDividerLog; //The log of the heading correction gain divider. For instance, 3 means division by 2^3 = 8. Only effective when heading_correction_max_dps = 0
} HeadingCorrectionConfig_t;

typedef struct {
    AccRange_t accelRange;
    int32_t x[4]; //coefficients realizing ax
    int32_t y[4]; //coefficients realizing ay
    int32_t z[4]; //coefficients realizing az
} AccelCalibConfig_t;

typedef struct {
    uint8_t fusionType;
    uint8_t shockThreshold;
    RotationAlgo_t rotationAlgo;
} FusionInfo_t;

typedef struct
{
    uint8_t id;
    QuaternionFxp_t quaternion;
} MotionAnalysisPose_t;

typedef enum{
	RAW_DATA_SAMPLING_50 = (uint8_t)0x01,
	RAW_DATA_SAMPLING_100 = (uint8_t)0x02,
	RAW_DATA_SAMPLING_200 = (uint8_t)0x03,
	RAW_DATA_SAMPLING_400 = (uint8_t)0x04,
	RAW_DATA_SAMPLING_800 = (uint8_t)0x05,
	RAW_DATA_SAMPLING_1600 = (uint8_t)0x06,
} FusionInputDataRate_t;

typedef enum{
	FUSION_OUTPUT_DATA_RATE_50 = (uint8_t)0x01,
	FUSION_OUTPUT_DATA_RATE_100 = (uint8_t)0x02,
	FUSION_OUTPUT_DATA_RATE_200 = (uint8_t)0x03,
	FUSION_OUTPUT_DATA_RATE_400 = (uint8_t)0x04,
	FUSION_OUTPUT_DATA_RATE_800 = (uint8_t)0x05,
	FUSION_OUTPUT_DATA_RATE_1600 = (uint8_t)0x06,
} FusionOutputDataRate_t;

typedef struct {
    uint16_t deltaT; //50Hz sampling period divided by two in fixed-point format with 15 fractional bits
    uint16_t accel16gHighTh; //the high-g threshold for accelerometers in 16g range, data format is fixed-point with 15 fractional bits
    uint16_t accel16gLowTh; //the low-g threshold for accelerometers in 16g range, data format is fixed-point with 15 fractional bits
} MotionSensorConfig_t;

typedef struct {
    uint8_t reserved1; /// enable/disable byte reserved for the application layer
    uint8_t fusionType;
    FusionInputDataRate_t inputRate;
    uint8_t reserved2; /// extra byte for the input rate in the application layer
    FusionOutputDataRate_t outputRate;
    uint8_t reserved3; /// extra byte for the output rate in the application layer
    FusionDownsample_t downsample;
    uint32_t streamCtrlReg;
    uint8_t shockThreshold;
    uint16_t motionTrendUpdateInterval;
    RotationAlgo_t rotationAlgo;
    AccRange_t accelRange;
    uint8_t reserved4; /// extra byte for the accelerometer sensor range
    GyroRange_t gyroRange;
    uint8_t reserved5; /// extra byte for the gyroscope range
    AccelCalibConfig_t accelCalibParams;
} FusionConfig_t;

#pragma pack(pop)



#endif // NEBLINA_FUSION_H
