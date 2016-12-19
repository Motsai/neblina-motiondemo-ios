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

#define TOTAL_SAMPLES_PER_STEP	100

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
#define     NEBLINA_FUSION_LAST_INDEX                           30  // Keep synchronize with last fusion index

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

#define FUSION_DATASIZE_MAX 12

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
	Two_Gauss = (uint8_t)0x01,
	Four_Gauss = (uint8_t)0x02,
	Eight_Gauss = (uint8_t)0x03,
	Sixteen_Gauss = (uint8_t)0x04,
}MagRange_t;

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
	IMU_Filter = (uint8_t)0x00,
	MARG_Filter = (uint8_t)0x01,
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
    uint16_t direction;
    uint32_t toe_off_timestamp;
} pedometer_fxp_t;

typedef struct {
    uint16_t step_count;
    uint8_t cadence;
    float direction;
    uint32_t toe_off_timestamp;
} pedometer_fp_t;

typedef struct {
    uint32_t timestamp;
    uint16_t step_count;
    uint8_t cadence;
    uint16_t direction;
    uint32_t toe_off_timestamp;
} pedometer_fxp_ts_t;

typedef struct {
    uint32_t timestamp;
    uint16_t step_count;
    uint8_t cadence;
    float direction;
    uint32_t toe_off_timestamp;
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

typedef struct steps_t { //steps and pedometer data types
	uint8_t step_detect; //detection of a step gives 1. It also returns 1, if no step has been detected for 5 seconds
	uint16_t step_cnt; //number of steps taken so far.
	uint8_t spm; //cadence: number of steps per minute
	uint32_t toe_off_timestamp;
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

typedef enum{
	none = (uint8_t)0x00,
	flatWalk = (uint8_t)0x01,
	stairsUp = (uint8_t)0x02,
	stairsDown = (uint8_t)0x03,
}activity_t;


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
	steps_t steps;
	int16_t direction;
	sit_stand_t sit_stand;
	uint8_t swipe; //finger swipe pattern: swipe left (0), or swipe right (1), swipe up (2), swipe down (3), flip left (4), flip right (5), double tap (6)
	wheels_t rotation_info; //rpm speed, rotation count
	pose_t pose_info;
	activity_t activity;
}Motion_Feature_t;

typedef struct rawDataArray_t{
	int16_t gx[TOTAL_SAMPLES_PER_STEP];
	int16_t gy[TOTAL_SAMPLES_PER_STEP];
	int16_t gz[TOTAL_SAMPLES_PER_STEP];
	int16_t ax[TOTAL_SAMPLES_PER_STEP];
	int16_t ay[TOTAL_SAMPLES_PER_STEP];
	int16_t az[TOTAL_SAMPLES_PER_STEP];
}rawDataArray_t;

typedef struct rawDataIndx_t{
	uint16_t array[2][2]; //two arrays with two phases each
}rawDataIndx_t;

typedef struct rawDataMemory_t{
	rawDataArray_t array[2][2]; //two arrays, where each array has two phases
}rawDataMemory_t;

typedef struct
{
	uint16_t downsample;
} FusionDownsample;

typedef struct
{
    int16_t yaw;
    uint16_t error;
} FusionHeadingCorrection;

typedef struct
{
    uint16_t id;
    quaternion_fxp_t quaternion;
} MotionAnalysisPose;

#pragma pack(pop)



#endif // NEBLINA_FUSION_H
