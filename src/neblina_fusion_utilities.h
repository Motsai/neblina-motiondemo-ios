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

#include <math.h>

#include "neblina.h"

/**********************************************************************************/

#ifdef __cplusplus

class NeblinaFusionUtilities
{
public:
    static inline float convertAccelerationMagnitude( NeblinaAccelerometerRange_t pRange, const uint32_t& prMagnitudeFxp );

    static inline NeblinaFusionEulerFp_t convertEuler( const NeblinaFusionEulerFxp_t& prEulerFxp );
    static inline NeblinaFusionEulerFpTs_t convertEuler( const NeblinaFusionEulerFxpTs_t& prEulerFxp );

    static inline NeblinaFusionExternalForceFpTs_t convertExternalForce( NeblinaAccelerometerRange_t pRange, const NeblinaFusionExternalForceFxpTs_t& prFxp );

    static inline NeblinaFusionMagnetometerAcFpTs_t convertMagnetometerAc( const NeblinaFusionMagnetometerAcFxpTs_t& prMagFxp );

    static inline NeblinaFusionPedometerFpTs_t convertPedometer( const NeblinaFusionPedometerFxpTs_t& prFxp );

    static inline NeblinaFusionQuaternionFpTs_t convertQuaternion( const NeblinaFusionQuaternionFxpTs_t& prQuatFxp );
    static inline NeblinaFusionEulerFpTs_t convertQuaternionToEuler( const NeblinaFusionQuaternionFxpTs_t& prQuatFxp );

    static inline NeblinaFusionInclinometerFpTs_t convertInclinometer( const NeblinaFusionInclinometerFxpTs_t& prFxp );

    static inline NeblinaFusionMotionDirectionFpTs_t convertMotionDirection( const NeblinaFusionMotionDirectionFxpTs_t& prMotionDirectionFxp );

    static inline NeblinaFusionTrajectoryInfoFpTs_t convertTrajectoryInfo( const NeblinaFusionTrajectoryInfoFxpTs_t& prFxp );
};

/**********************************************************************************/

float NeblinaFusionUtilities::convertAccelerationMagnitude( NeblinaAccelerometerRange_t pRange, const uint32_t& prMagnitudeFxp )
{
    uint8_t lMultiplier = 2;

    switch ( pRange ) {
    case NEBLINA_ACCELEROMETER_RANGE_2G:
        lMultiplier = 2;
        break;
    case NEBLINA_ACCELEROMETER_RANGE_4G:
        lMultiplier = 4;
        break;
    case NEBLINA_ACCELEROMETER_RANGE_8G:
        lMultiplier = 8;
        break;
    case NEBLINA_ACCELEROMETER_RANGE_16G:
        lMultiplier = 16;
        break;
    default:
        NEBLINA_ASSERT( false, "Missing accelerometer range ?" );
        break;
    }

    float lFp = ( lMultiplier * ((float)prMagnitudeFxp)) / 32768.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionEulerFp_t NeblinaFusionUtilities::convertEuler( const NeblinaFusionEulerFxp_t& prFxp )
{
    NeblinaFusionEulerFp_t lFp;
    lFp.pitch = ((float)prFxp.pitch) / 10.0f;
    lFp.roll = ((float)prFxp.roll) / 10.0f;
    lFp.yaw = ((float)prFxp.yaw) / 10.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionEulerFpTs_t NeblinaFusionUtilities::convertEuler( const NeblinaFusionEulerFxpTs_t& prFxp )
{
    NeblinaFusionEulerFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.pitch = ((float)prFxp.pitch) / 10.0f;
    lFp.roll = ((float)prFxp.roll) / 10.0f;
    lFp.yaw = ((float)prFxp.yaw) / 10.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionExternalForceFpTs_t NeblinaFusionUtilities::convertExternalForce( NeblinaAccelerometerRange_t pRange, const NeblinaFusionExternalForceFxpTs_t& prFxp )
{
    NeblinaFusionExternalForceFpTs_t lFp;
    uint8_t lMultiplier = 2;

    switch ( pRange ) {
    case NEBLINA_ACCELEROMETER_RANGE_2G:
        lMultiplier = 2;
        break;
    case NEBLINA_ACCELEROMETER_RANGE_4G:
        lMultiplier = 4;
        break;
    case NEBLINA_ACCELEROMETER_RANGE_8G:
        lMultiplier = 8;
        break;
    case NEBLINA_ACCELEROMETER_RANGE_16G:
        lMultiplier = 16;
        break;
    default:
        NEBLINA_ASSERT( false, "Missing accelerometer range ?" );
        break;
    }

    lFp.timestamp = prFxp.timestamp;
    lFp.x = ( lMultiplier * ((float)prFxp.x)) / 32768.0f;
    lFp.y = ( lMultiplier * ((float)prFxp.y)) / 32768.0f;
    lFp.z = ( lMultiplier * ((float)prFxp.z)) / 32768.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionMagnetometerAcFpTs_t NeblinaFusionUtilities::convertMagnetometerAc( const NeblinaFusionMagnetometerAcFxpTs_t& prFxp )
{
    NeblinaFusionMagnetometerAcFpTs_t lFp;
    lFp.timestampUs = prFxp.timestampUs;
    lFp.timestampUnix = prFxp.timestampUnix;
    lFp.magnetometerAC = ( 13.0f * ((float)prFxp.magnetometerAC)) / 32768.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionPedometerFpTs_t NeblinaFusionUtilities::convertPedometer( const NeblinaFusionPedometerFxpTs_t& prFxp )
{
    NeblinaFusionPedometerFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.cadence = prFxp.cadence;
    lFp.direction = prFxp.direction / 10.0f;
    lFp.stepCount = prFxp.stepCount;
    lFp.timestamp = prFxp.timestamp;
    lFp.stairsUpCount = prFxp.stairsUpCount;
    lFp.stairsDownCount = prFxp.stairsDownCount;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionQuaternionFpTs_t NeblinaFusionUtilities::convertQuaternion( const NeblinaFusionQuaternionFxpTs_t& prFxp )
{
    NeblinaFusionQuaternionFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.w = ((float)prFxp.w) / 32768.0f;
    lFp.x = ((float)prFxp.x) / 32768.0f;
    lFp.y = ((float)prFxp.y) / 32768.0f;
    lFp.z = ((float)prFxp.z) / 32768.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionEulerFpTs_t NeblinaFusionUtilities::convertQuaternionToEuler( const NeblinaFusionQuaternionFxpTs_t& prFxp )
{
    float a = ((float)prFxp.w) / 32768.0f;
    float b = ((float)prFxp.x) / 32768.0f;
    float c = ((float)prFxp.y) / 32768.0f;
    float d = ((float)prFxp.z) / 32768.0f;

    NeblinaFusionEulerFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.roll = 57.29578f*((float)(atan2(2*(a*b+c*d),1-2*(b*b+c*c)))); //57.29578 = 180/pi
    lFp.pitch = 57.29578f*((float)(asin(2*(a*c-b*d))));
    lFp.yaw = 57.29578f*((float)(atan2(2*(a*d+b*c),1-2*(d*d+c*c))));
    return lFp;
}

/**********************************************************************************/

NeblinaFusionInclinometerFpTs_t NeblinaFusionUtilities::convertInclinometer( const NeblinaFusionInclinometerFxpTs_t& prFxp )
{
    NeblinaFusionInclinometerFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.inclinationAngle = prFxp.inclinationAngle / 100.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionMotionDirectionFpTs_t NeblinaFusionUtilities::convertMotionDirection( const NeblinaFusionMotionDirectionFxpTs_t& prFxp )
{
    NeblinaFusionMotionDirectionFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.directionAngle = ((float)prFxp.directionAngle) / 10.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaFusionTrajectoryInfoFpTs_t NeblinaFusionUtilities::convertTrajectoryInfo( const NeblinaFusionTrajectoryInfoFxpTs_t& prFxp )
{
    NeblinaFusionTrajectoryInfoFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.counter = prFxp.counter;
    lFp.error = convertEuler( prFxp.error );
    lFp.progress = prFxp.progress;
    return lFp;
}

/**********************************************************************************/

#endif // __cplusplus

/**********************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

// C function prototype
#ifdef __cplusplus
}
#endif

/**********************************************************************************/

/**********************************************************************************/
