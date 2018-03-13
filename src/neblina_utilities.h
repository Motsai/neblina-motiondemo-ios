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

#ifndef NEBLINA_UTILITIES_H
#define NEBLINA_UTILITIES_H

/**********************************************************************************/

#include "neblina.h"
#include "neblina_fusion_utilities.h"

#include <map>
#include <string>
#include <sstream>
#include <vector>

/**********************************************************************************/

#ifdef __cplusplus

namespace neblina
{

/**********************************************************************************/

class NEBLINA_EXTERN NeblinaUtilities
{
public:
    // Typedef
    typedef std::map< std::string, double > NeblinaPacketMap;
    typedef std::vector< NeblinaPacketMap > NeblinaPacketVector;
    typedef std::map< std::string, NeblinaPacketVector > NeblinaCommandMap;
    typedef std::map< std::string, NeblinaCommandMap > NeblinaSessionDownloadMap;

    // Global
    static uint8_t crc8( const uint8_t* ppBuf, uint8_t pSize );
    static std::string getCommandName( uint8_t pSubSystem, uint8_t pCommand );
    static std::string getPacketName( uint8_t pSubSystem, uint8_t pCommand );
    static std::string getPacketName( uint8_t pPacketType, uint8_t pSubSystem, uint8_t pCommand );
    static const uint8_t* getPacketPayload( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static uint8_t getPacketType( uint8_t pControlByte );
    static uint8_t getSubSystem( uint8_t pControlByte );
    static std::string getSubSystemName( uint8_t pSubSystem );
    static bool isPacketSizeValid( uint32_t pPayloadSize, uint32_t pPacketSize, bool pCRC );
    static bool isPacketCommandValid( uint8_t pCommandToValidate, const uint8_t* ppPacket, uint32_t pSize, bool pCRC );

    // Sensors
    static inline NeblinaAccelerometerFpTs_t convertAccelerometer( NeblinaAccelerometerRange_t pRange, const NeblinaAccelerometerFxpTs_t& prFxp );
    static inline NeblinaAccelerometerGyroscopeFpTs_t convertAccelerometerGyroscope( NeblinaAccelerometerRange_t pAccelRange, NeblinaGyroscopeRange_t pGyroRange, const NeblinaAccelerometerGyroscopeFxpTs_t& prFxp );
    static inline NeblinaAccelerometerMagnetometerFpTs_t convertAccelerometerMagnetometer( NeblinaAccelerometerRange_t pAccelRange, const NeblinaAccelerometerMagnetometerFxpTs_t& prFxp );
    static inline NeblinaGyroscopeFpTs_t convertGyroscope( NeblinaGyroscopeRange_t pRange, const NeblinaGyroscopeFxpTs_t& prFxp );
    static inline NeblinaMagnetometerFpTs_t convertMagnetometer( const NeblinaMagnetometerFxpTs_t& prFxp );
    static inline NeblinaHumidityFpTs_t convertHumidity( const NeblinaHumidityFxpTs_t& prFxp );
    static inline NeblinaPressureFpTs_t convertPressure( const NeblinaPressureFxpTs_t& prFxp );
    static inline NeblinaTemperatureFpTs_t convertTemperature( const NeblinaTemperatureFxpTs_t& prFxp );

    // LED
    static uint8_t getLEDIntensity( NeblinaLED_t pLEDIndex, const NeblinaLEDStatus_t& prStatus );

    // Session download utilities
    static void getSessionDownloadMap( const std::vector< uint8_t >& prDownloadData, NeblinaSessionDownloadMap& prOutput );
    static NeblinaAccelerometerFpTs_t getFusionCalibratedAccelerometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionEulerFpTs_t getFusionEulerAngle( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionExternalForceFpTs_t getFusionExternalForce( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionFingerGestureTs_t getFusionFingerGesture( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionInclinometerFpTs_t getFusionInclinometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionMagnetometerAcFpTs_t getFusionMagnetometerAC( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionMotionAnalysisPoseTs_t getFusionMotionAnalysis( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionMotionDirectionFpTs_t getFusionMotionDirection( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionMotionIntensityTrendUnixTs_t getFusionMotionIntensity( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionMotionStateTs_t getFusionMotionState( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionPedometerFpTs_t getFusionPedometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionQuaternionFpTs_t getFusionQuaternion( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionRotationInfoTs_t getFusionRotationInfo( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionSittingStandingTs_t getFusionSittingStanding( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaAccelerometerGyroscopeFpTs_t getFusionShockSegment( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaFusionTrajectoryInfoFpTs_t getFusionTrajectoryInfo( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaAccelerometerFpTs_t getSensorAccelerometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaAccelerometerGyroscopeFpTs_t getSensorAccelerometerGyroscope( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaAccelerometerMagnetometerFpTs_t getSensorAccelerometerMagnetometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaGyroscopeFpTs_t getSensorGyroscope( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaMagnetometerFpTs_t getSensorMagnetometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaHumidityFpTs_t getSensorHumidity( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaPressureFpTs_t getSensorPressure( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );
    static NeblinaTemperatureFpTs_t getSensorTemperature( const uint8_t* ppPacket, uint32_t pSize, bool pCRC );

    // Fusion Stream utilities
    static bool isCalibratedAccelerometerStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isEulerStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isExternalForceStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isFingerGestureStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isInclinometerStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isMagnetometerACStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isMotionAnalysisStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isMotionDirectionStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isMotionIntensityTrendStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isMotionStateStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isPedometerStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isQuaternionStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isRotationInfoStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isShockSegmentStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isSittingStandingStreaming( const NeblinaFusionStatus_t& prStatus );
    static bool isTrajectoryInfoStreaming( const NeblinaFusionStatus_t& prStatus );

    // Sensor Stream utilities
    static bool isAccelerometerStreaming( const NeblinaSensorStatus_t& prStatus );
    static bool isGyroscopeStreaming( const NeblinaSensorStatus_t& prStatus );
    static bool isMagnetometerStreaming( const NeblinaSensorStatus_t& prStatus );
    static bool isAccelerometerGyroscopeStreaming( const NeblinaSensorStatus_t& prStatus );
    static bool isAccelerometerMagnetometerStreaming( const NeblinaSensorStatus_t& prStatus );
    static bool isHumidityStreaming( const NeblinaSensorStatus_t& prStatus );
    static bool isPressureStreaming( const NeblinaSensorStatus_t& prStatus );
    static bool isTemperatureStreaming( const NeblinaSensorStatus_t& prStatus );

    // Interface utilities
    static bool isInterfaceBLEOpen( const NeblinaInterfaceStatus_t& prStatus );
    static bool isInterfaceUARTOpen( const NeblinaInterfaceStatus_t& prStatus );  

private:    
    static std::string getDebugCommandName( uint8_t pCommand );
    static std::string getEEPROMCommandName( uint8_t pCommand );
    static std::string getFusionCommandName( uint8_t pCommand );
    static std::string getGeneralCommandName( uint8_t pCommand );
    static std::string getLEDCommandName( uint8_t pCommand );
    static std::string getPowerCommandName( uint8_t pCommand );
    static std::string getSensorCommandName( uint8_t pCommand );
    static std::string getRecoderCommandName( uint8_t pCommand );
    static std::string getPacketTypeName( uint8_t pPacketType );    

    static void splitPacket( const std::vector< uint8_t >& prInput, std::vector< std::vector< uint8_t > >& prSplit, bool pCRC );
};

/**********************************************************************************/

NeblinaAccelerometerFpTs_t NeblinaUtilities::convertAccelerometer( NeblinaAccelerometerRange_t pRange, const NeblinaAccelerometerFxpTs_t& prFxp )
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

    NeblinaAccelerometerFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.x = ( lMultiplier * ((float)prFxp.x)) / 32768.0f;
    lFp.y = ( lMultiplier * ((float)prFxp.y)) / 32768.0f;
    lFp.z = ( lMultiplier * ((float)prFxp.z)) / 32768.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaAccelerometerGyroscopeFpTs_t NeblinaUtilities::convertAccelerometerGyroscope( NeblinaAccelerometerRange_t pAccelRange,
                                                                                     NeblinaGyroscopeRange_t pGyroRange,
                                                                                     const NeblinaAccelerometerGyroscopeFxpTs_t& prFxp )
{
    NeblinaAccelerometerFxpTs_t lAccelFxp = { prFxp.timestamp, prFxp.accelX, prFxp.accelY, prFxp.accelZ };
    NeblinaAccelerometerFpTs_t lAccelFp = convertAccelerometer( pAccelRange, lAccelFxp );

    NeblinaGyroscopeFxpTs_t lGyroFxp = { prFxp.timestamp, prFxp.gyroX, prFxp.gyroY, prFxp.gyroZ };
    NeblinaGyroscopeFpTs_t lGyroFp = convertGyroscope( pGyroRange, lGyroFxp );

    NeblinaAccelerometerGyroscopeFpTs_t lFp = { lAccelFp.timestamp, lAccelFp.x, lAccelFp.y, lAccelFp.z, lGyroFp.x, lGyroFp.y, lGyroFp.z };
    return lFp;
}

/**********************************************************************************/

NeblinaAccelerometerMagnetometerFpTs_t NeblinaUtilities::convertAccelerometerMagnetometer( NeblinaAccelerometerRange_t pAccelRange,
                                                                                           const NeblinaAccelerometerMagnetometerFxpTs_t& prFxp )
{
    NeblinaAccelerometerFxpTs_t lAccelFxp = { prFxp.timestamp, prFxp.accelX, prFxp.accelY, prFxp.accelZ };
    NeblinaAccelerometerFpTs_t lAccelFp = convertAccelerometer( pAccelRange, lAccelFxp );

    NeblinaMagnetometerFxpTs_t lMagFxp = { prFxp.timestamp, prFxp.magX, prFxp.magY, prFxp.magZ };
    NeblinaMagnetometerFpTs_t lMagFp = convertMagnetometer( lMagFxp );

    NeblinaAccelerometerMagnetometerFpTs_t lFp = { lAccelFp.timestamp, lAccelFp.x, lAccelFp.y, lAccelFp.z, lMagFp.x, lMagFp.y, lMagFp.z };
    return lFp;
}

/**********************************************************************************/

NeblinaGyroscopeFpTs_t NeblinaUtilities::convertGyroscope( NeblinaGyroscopeRange_t pRange, const NeblinaGyroscopeFxpTs_t& prFxp )
{    
    uint16_t lMultiplier = 2000;

    switch ( pRange ) {
    case NEBLINA_GYROSCOPE_RANGE_500:
        lMultiplier = 500;
        break;
    case NEBLINA_GYROSCOPE_RANGE_2000:
        lMultiplier = 2000;
        break;
    default:
        NEBLINA_ASSERT( false, "Missing gyroscope range" );
        break;
    }

    NeblinaGyroscopeFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.x = ( lMultiplier * ((float)prFxp.x)) / 32768.0f;
    lFp.y = ( lMultiplier * ((float)prFxp.y)) / 32768.0f;
    lFp.z = ( lMultiplier * ((float)prFxp.z)) / 32768.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaMagnetometerFpTs_t NeblinaUtilities::convertMagnetometer( const NeblinaMagnetometerFxpTs_t& prFxp )
{    
    uint8_t lMultiplier = 13;

    NeblinaMagnetometerFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.x = ( lMultiplier * ((float)prFxp.x)) / 32768.0f;
    lFp.y = ( lMultiplier * ((float)prFxp.y)) / 32768.0f;
    lFp.z = ( lMultiplier * ((float)prFxp.z)) / 32768.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaHumidityFpTs_t NeblinaUtilities::convertHumidity( const NeblinaHumidityFxpTs_t& prFxp )
{
    NeblinaHumidityFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.value = prFxp.value / 100.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaPressureFpTs_t NeblinaUtilities::convertPressure( const NeblinaPressureFxpTs_t& prFxp )
{
    NeblinaPressureFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.value = prFxp.value / 100.0f;
    return lFp;
}

/**********************************************************************************/

NeblinaTemperatureFpTs_t NeblinaUtilities::convertTemperature( const NeblinaTemperatureFxpTs_t& prFxp )
{
    NeblinaTemperatureFpTs_t lFp;
    lFp.timestamp = prFxp.timestamp;
    lFp.value = prFxp.value / 100.0f;
    return lFp;
}

/**********************************************************************************/

inline uint8_t NeblinaUtilities::crc8( const uint8_t* ppBuf, uint8_t pSize )
{
    uint8_t i, e, f, crc;

    crc = 0;
    for ( i = 0; i < pSize; i++ )
    {
        e = crc ^ ppBuf[i];
        f = e ^ ( e >> 4 ) ^ ( e >> 7 );
        crc = ( f << 1 ) ^ ( f << 4 );
    }
    return crc;
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getPacketName( uint8_t pSubSystem, uint8_t pCommand )
{
    std::string lPacketName = "";
    lPacketName += getCommandName( pSubSystem, pCommand );
    lPacketName += " ";
    lPacketName += getSubSystemName( pSubSystem );
    return lPacketName;
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getPacketName( uint8_t pPacketType, uint8_t pSubSystem, uint8_t pCommand )
{
    std::string lPacketName = "";
    lPacketName += getCommandName( pSubSystem, pCommand );
    lPacketName += " ";
    lPacketName += getSubSystemName( pSubSystem );
    lPacketName += " ";
    lPacketName += getPacketTypeName( pPacketType );
    return lPacketName;
}

/**********************************************************************************/

inline const uint8_t* NeblinaUtilities::getPacketPayload( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    if ( pCRC ) {
        if ( pSize < NEBLINA_PACKET_HEADER_LENGTH ) return nullptr;
        return &ppPacket[NEBLINA_PACKET_HEADER_LENGTH];
    }
    else {
        if ( pSize < NEBLINA_PACKET_HEADER_LENGTH - 1 ) return nullptr;
        return &ppPacket[NEBLINA_PACKET_HEADER_LENGTH - 1];
    }
}

/**********************************************************************************/

inline uint8_t NeblinaUtilities::getPacketType( uint8_t pControlByte )
{
    return ( pControlByte & NEBLINA_BITMASK_PACKETTYPE ) >> NEBLINA_BITPOSITION_PACKETTYPE;
}

/**********************************************************************************/

inline uint8_t NeblinaUtilities::getSubSystem( uint8_t pControlByte )
{
    return ( pControlByte & NEBLINA_BITMASK_SUBSYSTEM );
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getCommandName( uint8_t pSubSystem, uint8_t pCommand )
{
    switch ( pSubSystem )
    {
    case NEBLINA_SUBSYSTEM_GENERAL:
        return getGeneralCommandName( pCommand );
    case NEBLINA_SUBSYSTEM_FUSION:
        return getFusionCommandName( pCommand );
    case NEBLINA_SUBSYSTEM_POWER:
        return getPowerCommandName( pCommand );
    case NEBLINA_SUBSYSTEM_LED:
        return getLEDCommandName( pCommand );
    case NEBLINA_SUBSYSTEM_DEBUG:
        return getDebugCommandName( pCommand );
    case NEBLINA_SUBSYSTEM_EEPROM:
        return getEEPROMCommandName( pCommand );
    case NEBLINA_SUBSYSTEM_SENSOR:
        return getSensorCommandName( pCommand );
    case NEBLINA_SUBSYSTEM_RECORDER:
        return getRecoderCommandName( pCommand );
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getDebugCommandName( uint8_t pCommand )
{
    switch ( pCommand )
    {
    case NEBLINA_COMMAND_DEBUG_PRINTF:
        return "printf";
    case NEBLINA_COMMAND_DEBUG_DUMP_DATA:
        return "DumpData";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getEEPROMCommandName( uint8_t pCommand )
{
    switch( pCommand )
    {
    case NEBLINA_COMMAND_EEPROM_READ:
        return "Read";
    case NEBLINA_COMMAND_EEPROM_WRITE:
        return "Write";
    default:
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getFusionCommandName( uint8_t pCommand )
{
    switch ( pCommand )
    {
    case NEBLINA_COMMAND_FUSION_RATE:
        return "Rate";
    case NEBLINA_COMMAND_FUSION_DOWNSAMPLE:
        return "Downsample";
    case NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM:
        return "MotionStream";
    case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
        return "QuaternionStream";
    case NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM:
        return "EulerStream";
    case NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM:
        return "ExternalForceStream";
    case NEBLINA_COMMAND_FUSION_FUSION_TYPE:
        return "FusionType";
    case NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD:
        return "TrajectoryRecord";
    case NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM:
        return "TrajectoryInfoStream";
    case NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM:
        return "PedometerStream";
    case NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM:
        return "SittingStandingStream";
    case NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE:
        return "LockHeadingReference";
    case NEBLINA_COMMAND_FUSION_FINGER_GESTURE_STREAM:
        return "FingerGestureStream";
    case NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM:
        return "RotationInfoStream";
    case NEBLINA_COMMAND_FUSION_EXTERNAL_HEADING_CORRECTION:
        return "ExternalHeadingCorrection";
    case NEBLINA_COMMAND_FUSION_ANALYSIS_RESET:
        return "MotionAnalysisReset";
    case NEBLINA_COMMAND_FUSION_ANALYSIS_CALIBRATE:
        return "MotionAnalysisCalibrate";
    case NEBLINA_COMMAND_FUSION_ANALYSIS_CREATE_POSE:
        return "MotionAnalysisCreatePose";
    case NEBLINA_COMMAND_FUSION_ANALYSIS_GET_ACTIVE_POSE:
        return "MotionAnalysisGetActivePose";
    case NEBLINA_COMMAND_FUSION_ANALYSIS_SET_ACTIVE_POSE:
        return "MotionAnalysisSetActivePose";
    case NEBLINA_COMMAND_FUSION_ANALYSIS_STREAM:
        return "MotionAnalysisStream";
    case NEBLINA_COMMAND_FUSION_ANALYSIS_POSE_INFO:
        return "MotionAnalysisPoseInfo";
    case NEBLINA_COMMAND_FUSION_MOTION_DIRECTION_STREAM:
        return "MotionDirectionStream";
    case NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION:
        return "CalibrateDownward";
    case NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION:
        return "CalibrateForward";
    case NEBLINA_COMMAND_FUSION_SHOCK_SEGMENT_STREAM:
        return "ShockSegmentStream";
    case NEBLINA_COMMAND_FUSION_ACCELEROMETER_CALIBRATION_RESET:
        return "AccelerometerCalibrationReset";
    case NEBLINA_COMMAND_FUSION_ACCELEROMETER_CALIBRATION_SET_NEW_POSITION:
        return "AccelerometerCalibrationSetNewPosition";
    case NEBLINA_COMMAND_FUSION_CALIBRATED_ACCELEROMETER_STREAM:
        return "AccelerometerCalibrationStream";
    case NEBLINA_COMMAND_FUSION_INCLINOMETER_CALIBRATE:
        return "InclinometerCalibrate";
    case NEBLINA_COMMAND_FUSION_INCLINOMETER_STREAM:
        return "InclinometerStream";
    case NEBLINA_COMMAND_FUSION_MAGNETOMETER_AC_STREAM:
        return "MagnetometerACStream";
    case NEBLINA_COMMAND_FUSION_MOTION_INTENSITY_TREND_STREAM:
        return "MotionIntensityTrendStream";
    case NEBLINA_COMMAND_FUSION_SET_GOLFSWING_ANALYSIS_MODE:
        return "GolfSwingAnalysisMode";
    case NEBLINA_COMMAND_FUSION_SET_GOLFSWING_MAXIMUM_ERROR:
        return "GolfSwingMaximumError";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getGeneralCommandName( uint8_t pCommand )
{
    switch ( pCommand )
    {
    case NEBLINA_COMMAND_GENERAL_AUTHENTICATION:
        return "Authentication";
    case NEBLINA_COMMAND_GENERAL_DEVICE_NAME_GET:
        return "DeviceNameGet";
    case NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET:
        return "DeviceNameSet";
    case NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION:
        return "Firmware";
    case NEBLINA_COMMAND_GENERAL_INTERFACE_STATE:
        return "InterfaceState";
    case NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS:
        return "InterfaceStatus";
    case NEBLINA_COMMAND_GENERAL_FUSION_STATUS:
        return "FusionStatus";
    case NEBLINA_COMMAND_GENERAL_POWER_STATUS:
        return "PowerStatus";
    case NEBLINA_COMMAND_GENERAL_RECORDER_STATUS:
        return "RecorderStatus";
    case NEBLINA_COMMAND_GENERAL_RSSI:
        return "RSSI";
    case NEBLINA_COMMAND_GENERAL_SENSOR_STATUS:
        return "SensorStatus";
    case NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP:
        return "ResetTimestamp";
    case NEBLINA_COMMAND_GENERAL_DISABLE_STREAMING:
        return "DisableStreaming";
    case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
        return "SystemStatus";
    case NEBLINA_COMMAND_GENERAL_GET_UNIX_TIMESTAMP:
        return "GetUnixTimestamp";
    case NEBLINA_COMMAND_GENERAL_SET_UNIX_TIMESTAMP:
        return "SetUnixTimestamp";
    case NEBLINA_COMMAND_GENERAL_DEVICE_RESET:
        return "DeviceReset";
    case NEBLINA_COMMAND_GENERAL_DEVICE_SHUTDOWN:
        return "DeviceShutdown";
//    case NEBLINA_COMMAND_GENERAL_SET_MODE:
//        return "SetMode";
//    case NEBLINA_COMMAND_GENERAL_GET_MODE:
//        return "GetMode";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getLEDCommandName( uint8_t pCommand )
{
    switch ( pCommand )
    {
    case NEBLINA_COMMAND_LED_STATE:
        return "LEDState";
    case NEBLINA_COMMAND_LED_STATUS:
        return "LEDStatus";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getPowerCommandName( uint8_t pCommand )
{
    switch ( pCommand )
    {
    case NEBLINA_COMMAND_POWER_BATTERY:
        return "Battery";
    case NEBLINA_COMMAND_POWER_TEMPERATURE:
        return "Temperature";
    case NEBLINA_COMMAND_POWER_CHARGE_CURRENT:
        return "ChargeCurrent";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getSensorCommandName( uint8_t pCommand )
{
    switch ( pCommand )
    {
    case NEBLINA_COMMAND_SENSOR_GET_DOWNSAMPLE:
        return "GetDownsample";
    case NEBLINA_COMMAND_SENSOR_GET_RANGE:
        return "GetRange";
    case NEBLINA_COMMAND_SENSOR_GET_RATE:
        return "GetRate";
    case NEBLINA_COMMAND_SENSOR_SET_DOWNSAMPLE:
        return "SetDownsample";
    case NEBLINA_COMMAND_SENSOR_SET_RANGE:
        return "SetRange";
    case NEBLINA_COMMAND_SENSOR_SET_RATE:
        return "SetRate";
    case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM:
        return "AccelerometerStream";
    case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM:
        return "AccelerometerGyroscopeStream";
    case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM:
        return "AccelerometerMagnetometerStream";
    case NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM:
        return "HumidityStream";
    case NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM:
        return "PressureStream";
    case NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM:
        return "TemperatureStream";
    case NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM:
        return "GyroscopeStream";
    case NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM:
        return "MagnetometerStream";
    case NEBLINA_COMMAND_SENSOR_SET_BANDWIDTH:
        return "SetBandwidth";
    case NEBLINA_COMMAND_SENSOR_GET_BANDWIDTH:
        return "GetBandwidth";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getRecoderCommandName( uint8_t pCommand )
{
    switch ( pCommand )
    {
    case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
        return "EraseAll";
    case NEBLINA_COMMAND_RECORDER_PLAYBACK:
        return "Playback";
    case NEBLINA_COMMAND_RECORDER_RECORD:
        return "Record";
    case NEBLINA_COMMAND_RECORDER_SESSION_COUNT:
        return "SessionCount";
    case NEBLINA_COMMAND_RECORDER_SESSION_GENERAL_INFO:
        return "SessionGeneralInfo";
    case NEBLINA_COMMAND_RECORDER_SESSION_READ:
        return "SessionRead";
    case NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD:
        return "SessionDownload";
    case NEBLINA_COMMAND_RECORDER_SESSION_SENSOR_INFO:
        return "SessionSensorInfo";
    case NEBLINA_COMMAND_RECORDER_SESSION_FUSION_INFO:
        return "SessionFusionInfo";
    case NEBLINA_COMMAND_RECORDER_SESSION_NAME:
        return "SessionName";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getPacketTypeName( uint8_t pPacketType )
{
    switch ( pPacketType )
    {
    case NEBLINA_PACKET_TYPE_RESPONSE:
        return "Response";
    case NEBLINA_PACKET_TYPE_ACK:
        return "Ack";
    case NEBLINA_PACKET_TYPE_COMMAND:
        return "Command";
    case NEBLINA_PACKET_TYPE_ERROR:
        return "Error";
    case NEBLINA_PACKET_TYPE_DATA:
        return "Data";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline std::string NeblinaUtilities::getSubSystemName( uint8_t pSubSystem )
{
    switch ( pSubSystem )
    {
    case NEBLINA_SUBSYSTEM_DEBUG:
        return "Debug";
    case NEBLINA_SUBSYSTEM_EEPROM:
        return "EEPROM";
    case NEBLINA_SUBSYSTEM_FUSION:
        return "Fusion";
    case NEBLINA_SUBSYSTEM_GENERAL:
        return "General";
    case NEBLINA_SUBSYSTEM_LED:
        return "LED";
    case NEBLINA_SUBSYSTEM_POWER:
        return "Power";
    case NEBLINA_SUBSYSTEM_SENSOR:
        return "Sensor";
    case NEBLINA_SUBSYSTEM_RECORDER:
        return "Recorder";
    case NEBLINA_SUBSYSTEM_TEST:
        return "Test";
    default:
        assert( false );
        return "Undefined";
    }
}

/**********************************************************************************/

inline bool NeblinaUtilities::isCalibratedAccelerometerStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_CALIBRATED_ACCEL );
}

/**********************************************************************************/

inline bool NeblinaUtilities::isEulerStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_EULER );
}

/**********************************************************************************/

inline bool NeblinaUtilities::isExternalForceStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_EXTERNAL_FORCE ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isFingerGestureStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_FINGER_GESTURE ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isInclinometerStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_INCLINOMETER );
}

/**********************************************************************************/

inline bool NeblinaUtilities::isMagnetometerACStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_MAGNETOMETER_AC );
}

/**********************************************************************************/

inline bool NeblinaUtilities::isMotionAnalysisStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_MOTION_ANALYSIS ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isMotionDirectionStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_MOTION_DIRECTION );
}

/**********************************************************************************/

inline bool NeblinaUtilities::isMotionIntensityTrendStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_MOTION_INTENSITY_TREND );
}

/**********************************************************************************/

inline bool NeblinaUtilities::isMotionStateStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_MOTION_STATE ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isPedometerStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_PEDOMETER ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isQuaternionStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_QUATERNION ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isRotationInfoStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_ROTATION_INFO ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isShockSegmentStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_SHOCK_SEGMENT );
}

/**********************************************************************************/

inline bool NeblinaUtilities::isSittingStandingStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_SITTING_STANDING ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isTrajectoryInfoStreaming( const NeblinaFusionStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_FUSION_STATUS_TRAJECTORY_INFO ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isInterfaceBLEOpen( const NeblinaInterfaceStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_INTERFACE_STATUS_BLE ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isInterfaceUARTOpen( const NeblinaInterfaceStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_INTERFACE_STATUS_UART ) != 0;
}

/**********************************************************************************/

inline uint8_t NeblinaUtilities::getLEDIntensity( NeblinaLED_t pLEDIndex, const NeblinaLEDStatus_t& prStatus )
{
    return prStatus.status[pLEDIndex];
}

/**********************************************************************************/

inline bool NeblinaUtilities::isAccelerometerStreaming( const NeblinaSensorStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_SENSOR_STATUS_ACCELEROMETER );
}

/**********************************************************************************/

inline bool NeblinaUtilities::isGyroscopeStreaming( const NeblinaSensorStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_SENSOR_STATUS_GYROSCOPE ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isMagnetometerStreaming( const NeblinaSensorStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_SENSOR_STATUS_MAGNETOMETER ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isAccelerometerGyroscopeStreaming( const NeblinaSensorStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_SENSOR_STATUS_ACCELEROMETER_GYROSCOPE ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isAccelerometerMagnetometerStreaming( const NeblinaSensorStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_SENSOR_STATUS_ACCELEROMETER_MAGNETOMETER ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isHumidityStreaming( const NeblinaSensorStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_SENSOR_STATUS_HUMIDITY ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isPressureStreaming( const NeblinaSensorStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_SENSOR_STATUS_PRESSURE ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isTemperatureStreaming( const NeblinaSensorStatus_t& prStatus )
{
    return ( prStatus & NEBLINA_SENSOR_STATUS_TEMPERATURE ) != 0;
}

/**********************************************************************************/

inline bool NeblinaUtilities::isPacketSizeValid( uint32_t pPayloadSize, uint32_t pPacketSize, bool pCRC )
{
    if ( pCRC ) {
        return ( pPacketSize == pPayloadSize + NEBLINA_PACKET_HEADER_LENGTH );
    }
    else {
        return ( pPacketSize == pPayloadSize + NEBLINA_PACKET_HEADER_LENGTH - 1 );
    }
}

/**********************************************************************************/

inline bool NeblinaUtilities::isPacketCommandValid( uint8_t pCommandToValidate, const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    if ( pCRC ) {
        if ( pSize <= NEBLINA_PACKET_HEADER_ELEMENT_DATATYPE ) return false;
        return ( ppPacket[NEBLINA_PACKET_HEADER_ELEMENT_DATATYPE] == pCommandToValidate );
    }
    else {
        if ( pSize <= NEBLINA_PACKET_HEADER_ELEMENT_DATATYPE - 1 ) return false;
        return ( ppPacket[NEBLINA_PACKET_HEADER_ELEMENT_DATATYPE - 1] == pCommandToValidate );
    }
}

/**********************************************************************************/

inline void NeblinaUtilities::splitPacket( const std::vector< uint8_t >& prInput, std::vector< std::vector< uint8_t > >& prOutput, bool pCRC )
{
    prOutput.clear();

    for ( unsigned int i = 0; i < prInput.size(); ) {
        std::vector< uint8_t > lPacket;

        // Header (without CRC) is 3 bytes + payload length (byte 2)
        uint32_t lMax = i + 3 + prInput[i+1];
        if ( pCRC ) lMax++;

        for ( ; i < lMax; i++ ) {
            lPacket.push_back( prInput[i] );
        }

        prOutput.push_back( lPacket );
    }
}

/**********************************************************************************/

inline void NeblinaUtilities::getSessionDownloadMap( const std::vector< uint8_t >& prDownloadData, NeblinaSessionDownloadMap& prOutput )
{
    prOutput.clear();   

    // Remove session header
    std::vector< uint8_t > lDownloadDataWithoutHeader( prDownloadData.begin() + NEBLINA_SESSION_HEADER_LENGTH, prDownloadData.end() );

    std::vector< std::vector< uint8_t > > lPacketSplit;
    splitPacket( lDownloadDataWithoutHeader, lPacketSplit, false );

    for ( unsigned int lPacketIndex = 0; lPacketIndex < lPacketSplit.size(); lPacketIndex++ ) {
        const std::vector< uint8_t >& lrPacket = lPacketSplit[lPacketIndex];
        uint32_t lPacketSize = static_cast< uint32_t >( lrPacket.size() );

        uint8_t lSubSystem = NeblinaUtilities::getSubSystem( lrPacket[NEBLINA_PACKET_HEADER_ELEMENT_CTRL] );
        uint8_t lCommand = lrPacket[NEBLINA_PACKET_HEADER_ELEMENT_DATATYPE - 1];        // No CRC, -1

        std::string lCommandName = NeblinaUtilities::getCommandName( lSubSystem, lCommand ).c_str();
        std::string lSubSystemName = NeblinaUtilities::getSubSystemName( lSubSystem ).c_str();

        std::map< std::string, double > lPacketElement;
        if ( lSubSystem == NEBLINA_SUBSYSTEM_FUSION ) {
            if ( lCommand == NEBLINA_COMMAND_FUSION_CALIBRATED_ACCELEROMETER_STREAM ) {
                NeblinaAccelerometerFpTs_t lData = getFusionCalibratedAccelerometer( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["x"] = lData.x;
                lPacketElement["y"] = lData.y;
                lPacketElement["z"] = lData.z;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM ) {
                NeblinaFusionEulerFpTs_t lData = getFusionEulerAngle( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["yaw"] = lData.yaw;
                lPacketElement["pitch"] = lData.pitch;
                lPacketElement["roll"] = lData.roll;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM ) {
                NeblinaFusionExternalForceFpTs_t lData = getFusionExternalForce( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["x"] = lData.x;
                lPacketElement["y"] = lData.y;
                lPacketElement["z"] = lData.z;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_FINGER_GESTURE_STREAM ) {
                NeblinaFusionFingerGestureTs_t lData = getFusionFingerGesture( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["swipe"] = lData.swipe;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_INCLINOMETER_STREAM ) {
                NeblinaFusionInclinometerFpTs_t lData = getFusionInclinometer( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["angle"] = lData.inclinationAngle;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_MAGNETOMETER_AC_STREAM ) {
                NeblinaFusionMagnetometerAcFpTs_t lData = getFusionMagnetometerAC( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestampUs;
                lPacketElement["timestamp_unix"] = lData.timestampUnix;
                lPacketElement["ac"] = lData.magnetometerAC;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_ANALYSIS_STREAM ) {
                NeblinaFusionMotionAnalysisPoseTs_t lData = getFusionMotionAnalysis( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["id"] = lData.id;
                lPacketElement["distance_center"] = lData.distanceCenter;
                lPacketElement["distance_quaternion"] = lData.distanceQuatrn;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_MOTION_DIRECTION_STREAM ) {
                NeblinaFusionMotionDirectionFpTs_t lData = getFusionMotionDirection( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["angle"] = lData.directionAngle;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_MOTION_INTENSITY_TREND_STREAM ) {
                NeblinaFusionMotionIntensityTrendUnixTs_t lData = getFusionMotionIntensity( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["max"] = lData.data.intensityMax;
                lPacketElement["max_timestamp_offset"] = lData.data.intensityMaxIndex;
                lPacketElement["mean"] = lData.data.intensityMean;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM ) {
                NeblinaFusionMotionStateTs_t lData = getFusionMotionState( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["state"] = lData.state;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM ) {
                NeblinaFusionPedometerFpTs_t lData = getFusionPedometer( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["cadence"] = lData.cadence;
                lPacketElement["direction"] = lData.direction;
                lPacketElement["stairs_down_count"] = lData.stairsDownCount;
                lPacketElement["stairs_up_count"] = lData.stairsUpCount;
                lPacketElement["step_count"] = lData.stepCount;
                lPacketElement["stride_length"] = lData.strideLength;
                lPacketElement["total_distance"] = lData.totalDistance;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_QUATERNION_STREAM ) {
                NeblinaFusionQuaternionFpTs_t lData = getFusionQuaternion( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["w"] = lData.w;
                lPacketElement["x"] = lData.x;
                lPacketElement["y"] = lData.y;
                lPacketElement["z"] = lData.z;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM ) {
                NeblinaFusionRotationInfoTs_t lData = getFusionRotationInfo( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["count"] = lData.count;
                lPacketElement["rpm"] = lData.rpm;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM ) {
                NeblinaFusionSittingStandingTs_t lData = getFusionSittingStanding( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["state"] = lData.state;
                lPacketElement["sit_time"] = lData.sitTime;
                lPacketElement["stand_time"] = lData.standTime;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_SHOCK_SEGMENT_STREAM ) {
                NeblinaAccelerometerGyroscopeFpTs_t lData = getFusionShockSegment( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["accel_x"] = lData.accelX;
                lPacketElement["accel_y"] = lData.accelY;
                lPacketElement["accel_z"] = lData.accelZ;
                lPacketElement["gyro_x"] = lData.gyroX;
                lPacketElement["gyro_y"] = lData.gyroY;
                lPacketElement["gyro_z"] = lData.gyroZ;
            }
            else if ( lCommand == NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM ) {
                NeblinaFusionTrajectoryInfoFpTs_t lData = getFusionTrajectoryInfo( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["counter"] = lData.counter;
                lPacketElement["progress"] = lData.progress;
                lPacketElement["error_yaw"] = lData.error.yaw;
                lPacketElement["error_pitch"] = lData.error.pitch;
                lPacketElement["error_roll"] = lData.error.roll;
            }
            else {
                assert( false );
            }
        }
        else if ( lSubSystem == NEBLINA_SUBSYSTEM_SENSOR ) {
            if ( lCommand == NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM ) {
                NeblinaAccelerometerFpTs_t lData = getSensorAccelerometer( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["x"] = lData.x;
                lPacketElement["y"] = lData.y;
                lPacketElement["z"] = lData.z;
            }
            else if ( lCommand == NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM ) {
                NeblinaAccelerometerGyroscopeFpTs_t lData = getSensorAccelerometerGyroscope( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["accel_x"] = lData.accelX;
                lPacketElement["accel_y"] = lData.accelY;
                lPacketElement["accel_z"] = lData.accelZ;
                lPacketElement["gyro_x"] = lData.gyroX;
                lPacketElement["gyro_y"] = lData.gyroY;
                lPacketElement["gyro_z"] = lData.gyroZ;
            }
            else if ( lCommand == NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM ) {
                NeblinaAccelerometerMagnetometerFpTs_t lData = getSensorAccelerometerMagnetometer( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["accel_x"] = lData.accelX;
                lPacketElement["accel_y"] = lData.accelY;
                lPacketElement["accel_z"] = lData.accelZ;
                lPacketElement["mag_x"] = lData.magX;
                lPacketElement["mag_y"] = lData.magY;
                lPacketElement["mag_z"] = lData.magZ;
            }
            else if ( lCommand == NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM ) {
                NeblinaGyroscopeFpTs_t lData = getSensorGyroscope( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["x"] = lData.x;
                lPacketElement["y"] = lData.y;
                lPacketElement["z"] = lData.z;
            }
            else if ( lCommand == NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM ) {
                NeblinaMagnetometerFpTs_t lData = getSensorMagnetometer( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["x"] = lData.x;
                lPacketElement["y"] = lData.y;
                lPacketElement["z"] = lData.z;
            }
            else if ( lCommand == NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM ) {
                NeblinaHumidityFpTs_t lData = getSensorHumidity( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["humidity"] = lData.value;
            }
            else if ( lCommand == NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM ) {
                NeblinaPressureFpTs_t lData = getSensorPressure( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["pressure"] = lData.value;
            }
            else if ( lCommand == NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM ) {
                NeblinaTemperatureFpTs_t lData = getSensorTemperature( &lrPacket[0], lPacketSize, false );
                lPacketElement["timestamp"] = lData.timestamp;
                lPacketElement["temperature"] = lData.value;
            }
            else {

            }
        }

        prOutput[lSubSystemName][lCommandName].push_back( lPacketElement );
    }
}

/**********************************************************************************/

inline NeblinaFusionEulerFpTs_t NeblinaUtilities::getFusionEulerAngle( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionEulerFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionEulerFxpTs_t* lpFxp = (NeblinaFusionEulerFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaFusionEulerFpTs_t lFp = NeblinaFusionUtilities::convertEuler( *lpFxp );
    return lFp;
}

/**********************************************************************************/

inline NeblinaAccelerometerFpTs_t NeblinaUtilities::getFusionCalibratedAccelerometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaAccelerometerFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_CALIBRATED_ACCELEROMETER_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaAccelerometerFxpTs_t* lpFxp = (NeblinaAccelerometerFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaAccelerometerFpTs_t lFp = NeblinaUtilities::convertAccelerometer( NEBLINA_ACCELEROMETER_RANGE_2G, *lpFxp );     // TODO: Unhardcode accelerometer range
    return lFp;
}

/**********************************************************************************/

inline NeblinaFusionExternalForceFpTs_t NeblinaUtilities::getFusionExternalForce( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionExternalForceFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionExternalForceFxpTs_t* lpFxp = (NeblinaFusionExternalForceFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaFusionExternalForceFpTs_t lFp = NeblinaFusionUtilities::convertExternalForce( NEBLINA_ACCELEROMETER_RANGE_2G, *lpFxp );      // TODO: Unhardcode accelerometer range
    return lFp;
}

/**********************************************************************************/

inline NeblinaFusionFingerGestureTs_t NeblinaUtilities::getFusionFingerGesture( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionFingerGestureTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_INCLINOMETER_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionFingerGestureTs_t* lpData = (NeblinaFusionFingerGestureTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return *lpData;
}

/**********************************************************************************/

inline NeblinaFusionInclinometerFpTs_t NeblinaUtilities::getFusionInclinometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionInclinometerFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_INCLINOMETER_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionInclinometerFxpTs_t* lpFxp = (NeblinaFusionInclinometerFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaFusionInclinometerFpTs_t lFp = NeblinaFusionUtilities::convertInclinometer( *lpFxp );
    return lFp;
}

/**********************************************************************************/

inline NeblinaFusionMotionAnalysisPoseTs_t NeblinaUtilities::getFusionMotionAnalysis( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionMotionAnalysisPoseTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_ANALYSIS_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionMotionAnalysisPoseTs_t* lpData = (NeblinaFusionMotionAnalysisPoseTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return *lpData;
}

/**********************************************************************************/

inline NeblinaFusionMagnetometerAcFpTs_t NeblinaUtilities::getFusionMagnetometerAC( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionMagnetometerAcFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_MAGNETOMETER_AC_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionMagnetometerAcFxpTs_t* lpFxp = (NeblinaFusionMagnetometerAcFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaFusionMagnetometerAcFpTs_t lFp = NeblinaFusionUtilities::convertMagnetometerAc( *lpFxp );
    return lFp;
}

/**********************************************************************************/

inline NeblinaFusionMotionDirectionFpTs_t NeblinaUtilities::getFusionMotionDirection( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionMotionDirectionFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_MOTION_DIRECTION_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionMotionDirectionFxpTs_t* lpFxp = (NeblinaFusionMotionDirectionFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaFusionMotionDirectionFpTs_t lFp = NeblinaFusionUtilities::convertMotionDirection( *lpFxp );
    return lFp;
}

/**********************************************************************************/

inline NeblinaFusionMotionIntensityTrendUnixTs_t NeblinaUtilities::getFusionMotionIntensity( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionMotionIntensityTrendUnixTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_MOTION_INTENSITY_TREND_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionMotionIntensityTrendUnixTs_t* lpData = (NeblinaFusionMotionIntensityTrendUnixTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return *lpData;
}

/**********************************************************************************/

inline NeblinaFusionMotionStateTs_t NeblinaUtilities::getFusionMotionState( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionMotionStateTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionMotionStateTs_t* lpData = (NeblinaFusionMotionStateTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return *lpData;
}

/**********************************************************************************/

inline NeblinaFusionPedometerFpTs_t NeblinaUtilities::getFusionPedometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionPedometerFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionPedometerFxpTs_t* lpFxp = (NeblinaFusionPedometerFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaFusionPedometerFpTs_t lFp = NeblinaFusionUtilities::convertPedometer( *lpFxp );
    return lFp;
}

/**********************************************************************************/

inline NeblinaFusionQuaternionFpTs_t NeblinaUtilities::getFusionQuaternion( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionQuaternionFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_QUATERNION_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionQuaternionFxpTs_t* lpFxp = (NeblinaFusionQuaternionFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaFusionQuaternionFpTs_t lFp = NeblinaFusionUtilities::convertQuaternion( *lpFxp );
    return lFp;
}

/**********************************************************************************/

inline NeblinaFusionRotationInfoTs_t NeblinaUtilities::getFusionRotationInfo( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionRotationInfoTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionRotationInfoTs_t* lpData = (NeblinaFusionRotationInfoTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return *lpData;
}

/**********************************************************************************/

inline NeblinaFusionSittingStandingTs_t NeblinaUtilities::getFusionSittingStanding( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionSittingStandingTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionSittingStandingTs_t* lpData = (NeblinaFusionSittingStandingTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return *lpData;
}

/**********************************************************************************/

inline NeblinaAccelerometerGyroscopeFpTs_t NeblinaUtilities::getFusionShockSegment( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaAccelerometerGyroscopeFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_SHOCK_SEGMENT_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaAccelerometerGyroscopeFxpTs_t* lpFxp = (NeblinaAccelerometerGyroscopeFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaAccelerometerGyroscopeFpTs_t lFp = NeblinaUtilities::convertAccelerometerGyroscope( NEBLINA_ACCELEROMETER_RANGE_2G, NEBLINA_GYROSCOPE_RANGE_2000, *lpFxp );
    return lFp;
}

/**********************************************************************************/

inline NeblinaFusionTrajectoryInfoFpTs_t NeblinaUtilities::getFusionTrajectoryInfo( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaFusionTrajectoryInfoFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaFusionTrajectoryInfoFxpTs_t* lpFxp = (NeblinaFusionTrajectoryInfoFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    NeblinaFusionTrajectoryInfoFpTs_t lFp = NeblinaFusionUtilities::convertTrajectoryInfo( *lpFxp );
    return lFp;
}

/**********************************************************************************/

inline NeblinaAccelerometerFpTs_t NeblinaUtilities::getSensorAccelerometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaAccelerometerFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaAccelerometerFxpTs_t* lpFxp = (NeblinaAccelerometerFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return NeblinaUtilities::convertAccelerometer( NEBLINA_ACCELEROMETER_RANGE_2G, *lpFxp );
}

/**********************************************************************************/

inline NeblinaAccelerometerGyroscopeFpTs_t NeblinaUtilities::getSensorAccelerometerGyroscope( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaAccelerometerGyroscopeFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaAccelerometerGyroscopeFxpTs_t* lpFxp = (NeblinaAccelerometerGyroscopeFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return NeblinaUtilities::convertAccelerometerGyroscope( NEBLINA_ACCELEROMETER_RANGE_2G, NEBLINA_GYROSCOPE_RANGE_2000, *lpFxp ); // TODO: Unhardcode
}

/**********************************************************************************/

inline NeblinaAccelerometerMagnetometerFpTs_t NeblinaUtilities::getSensorAccelerometerMagnetometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaAccelerometerMagnetometerFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaAccelerometerMagnetometerFxpTs_t* lpFxp = (NeblinaAccelerometerMagnetometerFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return NeblinaUtilities::convertAccelerometerMagnetometer( NEBLINA_ACCELEROMETER_RANGE_2G, *lpFxp );
}

/**********************************************************************************/

inline NeblinaGyroscopeFpTs_t NeblinaUtilities::getSensorGyroscope( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaGyroscopeFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaGyroscopeFxpTs_t* lpFxp = (NeblinaGyroscopeFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return NeblinaUtilities::convertGyroscope( NEBLINA_GYROSCOPE_RANGE_2000, *lpFxp );
}

/**********************************************************************************/

inline NeblinaMagnetometerFpTs_t NeblinaUtilities::getSensorMagnetometer( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaMagnetometerFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaMagnetometerFxpTs_t* lpFxp = (NeblinaMagnetometerFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return NeblinaUtilities::convertMagnetometer( *lpFxp );
}

/**********************************************************************************/

inline NeblinaHumidityFpTs_t NeblinaUtilities::getSensorHumidity( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaHumidityFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaHumidityFxpTs_t* lpFxp = (NeblinaHumidityFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return NeblinaUtilities::convertHumidity( *lpFxp );
}

/**********************************************************************************/

inline NeblinaPressureFpTs_t NeblinaUtilities::getSensorPressure( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaPressureFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaPressureFxpTs_t* lpFxp = (NeblinaPressureFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return NeblinaUtilities::convertPressure( *lpFxp );
}

/**********************************************************************************/

inline NeblinaTemperatureFpTs_t NeblinaUtilities::getSensorTemperature( const uint8_t* ppPacket, uint32_t pSize, bool pCRC )
{
    assert( isPacketSizeValid( sizeof( NeblinaTemperatureFxpTs_t ), pSize, pCRC ) );
    assert( isPacketCommandValid( NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM, ppPacket, pSize, pCRC ) );

    NeblinaTemperatureFxpTs_t* lpFxp = (NeblinaTemperatureFxpTs_t*)getPacketPayload( ppPacket, pSize, pCRC );
    return NeblinaUtilities::convertTemperature( *lpFxp );
}

/**********************************************************************************/


/**********************************************************************************/

} // neblina namespace

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

#endif // __NEBLINA_UTILITIES_H__
