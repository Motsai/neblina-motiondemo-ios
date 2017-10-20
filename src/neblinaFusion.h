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


#define QUAT quaternion_fxp_t
#define command_t uint8_t
#define Euler_fxp euler_fxp_t
#define MOTION_FEATURE Motion_Feature_t

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

#define     NEBLINA_FUSION_NB_STREAMING_COMMANDS                12

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

#if 0
//Accelerometer full scale modes
#define ACC_FS_MODE_2G			0x00
#define ACC_FS_MODE_4G			0x01
#define ACC_FS_MODE_8G			0x02
#define ACC_FS_MODE_16G			0x03

//Gyroscope full scale modes
#define GYRO_FS_MODE_500_DPS	0x00
#define GYRO_FS_MODE_1000_DPS	0x01
#define GYRO_FS_MODE_2000_DPS	0x02

//Magnetometer full scale modes
#define MAG_FS_MODE_4_GAUSS		0x00
#define MAG_FS_MODE_8_GAUSS 	0x01
#define MAG_FS_MODE_16_GAUSS 	0x02
#endif

#define TrajectoryDistance TrajectoryInfo

#define FUSION_DATASIZE_MAX         12
#define HIGH_G_HALF_BUFFER_SIZE     100          //half of the total number of samples to be buffered when a high g shock occurs
#define ACCEL_HIGH_G_TH             419430400   //(5/8) times the full-scale accelerometer range is the threshold. This is the squared value

/**********************************************************************************/

#pragma pack(push, 1)

/**********************************************************************************/

typedef struct NeblinaFusionPacket_t
{
	uint32_t timestamp;
	uint8_t data[FUSION_DATASIZE_MAX];
} NeblinaFusionPacket;

typedef struct {
	union {
		int16_t Data[3];
		struct {
			int DataX:16;
			int DataY:16;
			int DataZ:16;
		};
	};
	uint32_t TimeStamp;
} MOTSENSOR_DATA;

typedef struct {
	MOTSENSOR_DATA AccData;
	MOTSENSOR_DATA MagData;
	MOTSENSOR_DATA GyrData;
	uint32_t UnixTimestamp;
} MOTSENSOR_ARRAY;

/**********************************************************************************/

typedef enum {
	Two_G = (uint8_t)0x01,
	Four_G = (uint8_t)0x02,
	Eight_G = (uint8_t)0x03,
	Sixteen_G = (uint8_t)0x04,
}AccRange_t;

typedef enum {
	dps_2000 = (uint8_t)0x00,
    dps_1000 = (uint8_t)0x01,
    dps_500 = (uint8_t)0x02,
    dps_250 = (uint8_t)0x03,
}GyroRange_t;

typedef enum {
	Gauss_2 = 2,
	Gauss_4 = 4,
	Gauss_8 = 8,
    Gauss_13 = 13,
	Gauss_16 = 16,
	Gauss_25 = 25,
}MagRange_t;

typedef enum {
    magBased = (uint8_t)0x00, //regular circular wheel using magnetometers
    gyroBased = (uint8_t)0x01, //regular circular wheel using gyros
    twoEdgeWheel = (uint8_t)0x02, //special wheel with two edges
    threeEdgeWheel = (uint8_t)0x03, //special wheel with three edges
}rotationAlgo_t;

/**********************************************************************************/

typedef struct SensorRange_t{
	AccRange_t AccelRange;
	GyroRange_t GyroRange;
	MagRange_t MagRange;
}SensorRange_t;

/**********************************************************************************/

// Fixed-point Quaternion
typedef struct {
	int16_t q[4];
} quaternion_fxp_t;

// Timestamped fixed-point Quaternion
typedef struct {
    uint32_t timestamp;
    int16_t q[4];
} quaternion_fxp_ts_t;

// Floating-point Quaternion
typedef struct {
    float q[4];
} quaternion_fp_t;

// Timestamped floating-point Quaternion
typedef struct {
    uint32_t timestamp;
    float q[4];
} quaternion_fp_ts_t;

/**********************************************************************************/

// Fixed-point Euler angles
// i.e., round(angle*10)
typedef struct {
	int16_t yaw; //first rotation, around z-axis
	int16_t pitch; //second rotation, around y-axis
	int16_t roll; //third rotation, around x-axis
} euler_fxp_t;

// Timestamp fixed-point Euler angles
typedef struct {
    uint32_t timestamp;
    int16_t yaw; //first rotation, around z-axis
    int16_t pitch; //second rotation, around y-axis
    int16_t roll; //third rotation, around x-axis
} euler_fxp_ts_t;

// Floating-point Euler angles
typedef struct {
    float yaw;
    float pitch;
    float roll;
} euler_fp_t;

// Timestamped floating-point Euler angles
typedef struct {
    uint32_t timestamp;
    float yaw;
    float pitch;
    float roll;
} euler_fp_ts_t;

//Timestamped fixed-point inclinometer data
typedef struct {
    uint32_t timestamp;
    int16_t inclinationAngle;
} inclinometer_fxp_ts_t;

//Timestamped floating-point inclinometer data
typedef struct {
    uint32_t timestamp;
    float inclinationAngle;
} inclinometer_fp_ts_t;

//Timestamped fixed-point Magnetometer AC magnitude data
typedef struct {
    uint32_t unix_timestamp;
    uint16_t magnetometerAC;
    uint32_t timestamp_us;
}magnetometer_ac_fxp_ts_t;

//Timestamped floating-point Magnetometer AC magnitude data (unit = gauss)
typedef struct {
    uint32_t unix_timestamp;
    float magnetometerAC;
    uint32_t timestamp_us;
}magnetometer_ac_fp_ts_t;

/**********************************************************************************/

// Fixed-point external force vector (unit is 'g')
typedef struct {
	int16_t x;
	int16_t y;
	int16_t z;
} external_force_fxp_t;

// Timestamp fixed-point external force vector
typedef struct {
    uint32_t timestamp;
    int16_t x;
    int16_t y;
    int16_t z;
} external_force_fxp_ts_t;

// Floating-point external force vector
typedef struct {
	float x;
	float y;
	float z;
} external_force_fp_t;

// Timestamped floating-point external force vector
typedef struct {
    uint32_t timestamp;
    float x;
    float y;
    float z;
} external_force_fp_ts_t;

/**********************************************************************************/

typedef enum{ //filter type: 6-axis IMU (no magnetometer), or 9-axis MARG
	IMU_Filter = (uint8_t)0x00, //default 6-axis with online calibration
	MARG_Filter = (uint8_t)0x01, //9-axis mode with online calibration
	MARG_Filter_Lock_Heading = (uint8_t)0x02, //lock heading mode in 9-axis
	IMU_Filter_Manual_Calibration = (uint8_t)0x03, //accelerometers are manually calibrated
    MARG_Filter_Manual_Calibration = (uint8_t)0x04, //accelerometers are manually calibrated
    MARG_Filter_Lock_Heading_Manual_Calibration = (uint8_t)0x05, //9-axis with lock heading mode and manually calibrated accelerometers
}Filter_Type;

typedef struct { //3-axis raw data type
  int16_t Data[3];
} AxesRaw_fxp_t;

typedef struct AxesRaw_fp_t{ //3-axis raw data floating-point type
	float Data[3];
} AxesRaw_fp_t;

typedef struct MARG_9Axis_fxp_t{ //9-axis data type
	AxesRaw_fxp_t Acc; //accelerometer
	AxesRaw_fxp_t Gyr; //gyroscope
	AxesRaw_fxp_t Mag; //magnetometer
} MARG_9Axis_fxp_t;

typedef struct SensorData_fxp_t{
	uint32_t TimeStamp;
	MARG_9Axis_fxp_t MARG;
	uint32_t humidity;
	uint32_t pressure;
	int32_t temperature;
}SensorData_fxp_t;

/**********************************************************************************/

// Fixed-point 6-axis IMU data type (no magnetometer)
typedef struct {
	AxesRaw_fxp_t Acc; //accelerometer
	AxesRaw_fxp_t Gyr; //gyroscope
} imu_6axis_fxp_t;

// Timestamped fixed-point 6-axis IMU
typedef struct {
    uint32_t timestamp;
    AxesRaw_fxp_t acc; //accelerometer
    AxesRaw_fxp_t gyr; //gyroscope
} imu_6axis_fxp_ts_t;

// Floating-point 6-axis IMU
typedef struct {
    AxesRaw_fp_t Acc;   // accelerometer
    AxesRaw_fp_t Gyr;   // gyroscope
} imu_6axis_fp_t;

// Timestamped floating-point 6-axis IMU
typedef struct {
    uint32_t timestamp;
    AxesRaw_fp_t acc;   // accelerometer
    AxesRaw_fp_t gyr;   // gyroscope
} imu_6axis_fp_ts_t;

/**********************************************************************************/

// Fixed-point magnetometer
typedef struct {
    AxesRaw_fxp_t Mag;  // magnetometer
    AxesRaw_fxp_t Acc;  // accelerometer
} mag_fxp_t;

// Timestamped fixed-point magnetometer
typedef struct {
    uint32_t timestamp;
    AxesRaw_fxp_t mag;  // magnetometer
    AxesRaw_fxp_t acc;  // accelerometer
} mag_fxp_ts_t;

// Floating-point magnetometer
typedef struct {
    AxesRaw_fp_t Mag;
    AxesRaw_fp_t Acc;
} mag_fp_t;

// Timestamped floating-point magnetometer
typedef struct {
    uint32_t timestamp;
    AxesRaw_fp_t mag;
    AxesRaw_fp_t acc;
} mag_fp_ts_t;

/**********************************************************************************/

typedef struct {
    uint8_t state;
} motion_state_t;

typedef struct {
    uint32_t timestamp;
    uint8_t state;
} motion_state_ts_t;

/**********************************************************************************/

typedef struct {
    uint32_t timestamp;
    uint8_t swipe;
} finger_gesture_ts_t;

/**********************************************************************************/

typedef struct {
    uint16_t step_count;
    uint8_t cadence;
    int16_t direction;
    uint16_t stairs_up_count;
    uint16_t stairs_down_count;
    uint8_t stride_length; //in cm
    uint16_t total_distance; //in dm
} pedometer_fxp_t;

typedef struct {
    uint16_t step_count;
    uint8_t cadence;
    float direction;
    uint16_t stairs_up_count;
    uint16_t stairs_down_count;
    uint8_t stride_length; //in cm
    uint16_t total_distance; //in dm
} pedometer_fp_t;

typedef struct {
    uint32_t timestamp;
    uint16_t step_count;
    uint8_t cadence; //steps per minute
    int16_t direction;
    uint16_t stairs_up_count;
    uint16_t stairs_down_count;
    uint8_t stride_length; //in cm
    uint16_t total_distance; //in dm
} pedometer_fxp_ts_t;

typedef struct {
    uint32_t timestamp;
    uint16_t step_count;
    uint8_t cadence;
    float direction;
    uint16_t stairs_up_count;
    uint16_t stairs_down_count;
    uint8_t stride_length; //in cm
    uint16_t total_distance; //in dm
} pedometer_fp_ts_t;

/**********************************************************************************/

typedef struct {
    uint32_t count;
    uint16_t rpm;
} rotation_info_t;

typedef struct {
    uint32_t timestamp;
    uint32_t count;
    uint16_t rpm;
} rotation_info_ts_t;

/**********************************************************************************/

typedef struct {
    uint8_t state;
    uint32_t sit_time;
    uint32_t stand_time;
} sitting_standing_t;

typedef struct {
    uint32_t timestamp;
    uint8_t state;
    uint32_t sit_time;
    uint32_t stand_time;
} sitting_standing_ts_t;

/**********************************************************************************/

typedef struct {
    euler_fxp_t error;
    uint16_t counter;
    uint8_t progress;
} trajectory_info_fxp_t;

typedef struct {
    euler_fp_t error;
    uint16_t counter;
    uint8_t progress;
} trajectory_info_fp_t;

typedef struct {
    uint32_t timestamp;
    euler_fxp_t error;
    uint16_t counter;
    uint8_t progress;
} trajectory_info_fxp_ts_t;

typedef struct {
    uint32_t timestamp;
    euler_fp_t error;
    uint16_t counter;
    uint8_t progress;
} trajectory_info_fp_ts_t;

/**********************************************************************************/

#if 0
typedef struct Quaternion_t //quaternion
{
	int16_t q[4]; //fixed-point quaternion
}Quaternion_t;
#endif

typedef struct { //steps and pedometer data types
	uint8_t step_detect; //detection of a step gives 1. It also returns 1, if no step has been detected for 5 seconds
	uint16_t step_cnt; //number of steps taken so far.
	uint8_t spm; //cadence: number of steps per minute
	uint32_t toe_off_timestamp;
	uint16_t stairs_up_count;
    uint16_t stairs_down_count;
    uint8_t stride_length; //in cm
    uint16_t total_distance; //total distance in dm
}steps_t;

typedef struct wheels_t { //wheel rotation data type
	uint8_t rot_detect; //detection of a full 360 degrees rotation gives 1. It also returns 1, if no rotation has been detected for 5 seconds
	uint32_t wheel_rot_cnt; //number of wheel rotations done so far
	uint16_t rpm; //rounds per minute
}wheels_t;

typedef struct sit_stand_t {
	uint8_t sit_stand_mode; //0: sitting, 1: standing, 2: no change
	uint32_t sit_time; //in seconds
	uint32_t stand_time; //in seconds
}sit_stand_t;

typedef enum{
	No_Change = (uint8_t)0x00, //holds its previous state
	Stop_Motion = (uint8_t)0x01, //the device stops moving
	Start_Motion = (uint8_t)0x02, //the device starts moving
}motionstatus_t;

typedef enum{
	Swipe_Left 	= (uint8_t)0x00,
	Swipe_Right = (uint8_t)0x01,
	Swipe_Up	= (uint8_t)0x02,
	Swipe_Down 	= (uint8_t)0x03,
	Flip_Left 	= (uint8_t)0x04,
	Flip_Right 	= (uint8_t)0x05,
	Double_Tap	= (uint8_t)0x06,
	No_Gesture 	= (uint8_t)0xFF, //no gesture
}finger_gesture_t;

typedef struct gyro_rotate_param_t{
	uint8_t min_angle; //The minimum rotation angle that is taken into consideration. The default value is 40 degrees
	uint8_t ticks_per_revolution; //the total number of partial rotations within a full revolution. This value is 2 for the Soucy Tank, and 3 for the Soucy Tractor. The default value is 2
}gyro_rotate_param_t;

typedef struct pose_t{
	uint8_t id;
	uint16_t distance_center;
	uint16_t distance_quatrn;
}pose_t;

typedef struct pose_ts_t{
    uint32_t timestamp;
    uint8_t id;
    uint16_t distance_center;
    uint16_t distance_quatrn;
}pose_ts_t;

typedef struct motionDirection_fxp_ts_t{
    uint32_t timestamp;
    int16_t directionAngle;
}motionDirection_fxp_ts_t;

typedef struct motionDirection_fp_ts_t{
    uint32_t timestamp;
    float directionAngle;
}motionDirection_fp_ts_t;

typedef enum{
	none = (uint8_t)0x00,
	flatWalk = (uint8_t)0x01,
	stairsUp = (uint8_t)0x02,
	stairsDown = (uint8_t)0x03,
}activity_t;

typedef struct motionDirectionVector_t {
    int32_t x;
    int32_t y;
    int32_t z;
}motionDirectionVector_t;

typedef struct {
    int32_t x;
    int32_t y;
    int32_t z;
} Vector_fxp_t;

typedef struct {
    float x;
    float y;
    float z;
} Vector_fp_t;

typedef struct motion_intensity_trend_data_t {
    uint16_t intensityMax; //maximum intensity over the past minute
    uint16_t intensityMean; //average intensity over the past minute
    uint8_t intensityMaxIndex; //at what second/index did the maximum intensity occur?
} motion_intensity_trend_data_t;

typedef struct motion_intensity_trend_unix_ts_t {
    uint32_t timestamp;
    motion_intensity_trend_data_t data;
} motion_intensity_trend_unix_ts_t;

typedef struct Intensity_Trend_Archive_t {
    motion_intensity_trend_data_t FrontEndData; //data available for streaming
    //below are backend variables used only for internal calculations of the motion intensity trend
    uint8_t sampleCounter; //for each sample this counter is added by one, when the counter reaches 1 second of data, average intensity over the past second is captured and the "secondCounter" is added by 1
    uint8_t secondCounter; //When sample counter captures 1 full second of data, this counter is added by 1. The counter counts up to 1 minute (60 seconds) and then resets. At that point, the max/mean intensity values become valid
    uint64_t intensityWithinSecondSum; //sum of acceleration intensities over 1 second of samples
    uint64_t intensityPerSecondSquareSumMean; //mean value among the last 60 "intensityWithinSecondSum" values (1 minute of data)
    uint64_t intensityPerSecondSquareSumMax; //maximum value among the last 60 "intensityWithinSecondSum" values (1 minute of data)
    uint16_t updateIntensityTrendAfterThisManySeconds; //the updates for intensity trend packet should take place every "updateIntensityTrendAfterThisManySeconds" seconds
} Intensity_Trend_Archive_t;

typedef struct {
    uint32_t timestamp; //unix timestamp
    uint8_t backswingScore; //backswing score range is 0-100
    uint8_t downswingScore; //downswing score range is 0-100
    uint8_t ballHitScore; //ball hit score range is 0-100
    uint8_t maximumClubSpeed; //in km/h => assuming the driver club length to be the average size of 113cm
} golf_swing_analysis_unix_ts_t;

typedef struct Motion_Feature_t{ //all features
	uint8_t motion; //0: no change in motion, 1: stops moving, 2: starts moving
	MARG_9Axis_fxp_t IMUData; //18 bytes
	quaternion_fxp_t quatrn; //8 bytes
	euler_fxp_t angles; //6 bytes
	external_force_fxp_t force; //6 bytes
	euler_fxp_t angles_err; //6 bytes: error in Euler angles compared to a reference trajectory
	uint16_t motiontrack_cntr; //shows how many times the pre-recorded track has been repeated
	uint8_t motiontrack_progress; //the percentage showing how much of a pre-recorded track has been covered
	uint32_t TimeStamp; //4 bytes: in microseconds
	uint32_t UnixTimestamp; //Unix timestamp in seconds
	steps_t steps;
	int16_t direction;
	sit_stand_t sit_stand;
	uint8_t swipe; //finger swipe pattern: swipe left (0), or swipe right (1), swipe up (2), swipe down (3), flip left (4), flip right (5), double tap (6)
	wheels_t rotation_info; //rpm speed, rotation count
	pose_t pose_info;
	activity_t activity;
	motionDirectionVector_t motionDirectionVector;
	AxesRaw_fxp_t AccelCalibrated;
	int16_t inclinationAngle; //constains (int16_t)(angle*100), where angle is in degrees
	uint16_t MagAC; //Magnetometer AC Magnitude
	Intensity_Trend_Archive_t intensityTrendData;
}Motion_Feature_t;

typedef enum {
    waitForShock = 0x00,
    waitForBeforeShockBufferExtraction = 0x01,
    waitForAfterShockBufferExtraction = 0x02,
}HighG_State_t;

typedef struct {
    uint32_t timestamp;
    int16_t accelX;
    int16_t accelY;
    int16_t accelZ;
    int16_t gyroX;
    int16_t gyroY;
    int16_t gyroZ;
} accel_gyro_ts_fxp_t;

typedef struct Shock_Data_t
{
    uint32_t shockThreshold;
    uint16_t beforeShockBufferCurrentIndex;
    uint16_t afterShockBufferCurrentIndex;
    uint16_t shockSampleIndex;
    HighG_State_t state;
    accel_gyro_ts_fxp_t accelGyroBufferBeforeShock[HIGH_G_HALF_BUFFER_SIZE];
    accel_gyro_ts_fxp_t accelGyroBufferAfterShock[HIGH_G_HALF_BUFFER_SIZE];
}Shock_Data_t;


typedef uint16_t FusionDownsample_t;

typedef struct
{
    int16_t yaw;
    uint16_t error;
} FusionHeadingCorrection;

typedef struct headingCorrectionConfig_t {
    uint8_t nb_turns; //moving average filter applied over this number of heading turns
    uint8_t heading_correction_max_dps; //maximum heading correction applied per second ==> default heading correction mode, if this value is set to 0, then use the below parameter
    uint8_t heading_correction_lpf_gain_divider_log; //The log of the heading correction gain divider. For instance, 3 means division by 2^3 = 8. Only effective when heading_correction_max_dps = 0
}headingCorrectionConfig_t;

typedef struct {
    AccRange_t AccRange;
    int32_t x[4]; //coefficients realizing ax
    int32_t y[4]; //coefficients realizing ay
    int32_t z[4]; //coefficients realizing az
} accelCalibConfig_t;

typedef struct
{
    uint8_t id;
    quaternion_fxp_t quaternion;
} MotionAnalysisPose;

typedef enum{
	RAW_DATA_SAMPLING_50 = (uint8_t)0x01,
	RAW_DATA_SAMPLING_100 = (uint8_t)0x02,
	RAW_DATA_SAMPLING_200 = (uint8_t)0x04,
	RAW_DATA_SAMPLING_400 = (uint8_t)0x08,
	RAW_DATA_SAMPLING_800 = (uint8_t)0x10,
	RAW_DATA_SAMPLING_1600 = (uint8_t)0x20,
}FusionInputDataRate_t;

typedef enum{
	FUSION_OUTPUT_DATA_RATE_50 = (uint8_t)0x01,
	FUSION_OUTPUT_DATA_RATE_100 = (uint8_t)0x02,
	FUSION_OUTPUT_DATA_RATE_200 = (uint8_t)0x04,
	FUSION_OUTPUT_DATA_RATE_400 = (uint8_t)0x08,
	FUSION_OUTPUT_DATA_RATE_800 = (uint8_t)0x10,
	FUSION_OUTPUT_DATA_RATE_1600 = (uint8_t)0x20,
}FusionOutputDataRate_t;

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
    rotationAlgo_t rotationAlgo;
    AccRange_t accelRange;
    uint8_t reserved4; /// extra byte for the accelerometer sensor range
    GyroRange_t gyroRange;
    uint8_t reserved5; /// extra byte for the gyroscope range
    accelCalibConfig_t accelCalibParams;
} FusionConfig_t;

#pragma pack(pop)



#endif // NEBLINA_FUSION_H
