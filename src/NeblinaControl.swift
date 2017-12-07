//
//  NeblinaControl.swift
//
//
//  Created by Hoan Hoang on 2017-04-06.
//  Copyright © 2017 Motsai. All rights reserved.
//

import Foundation
import CoreBluetooth

extension Neblina {
	//
	// MARK : **** API
	//

	// ********************************
	// * Neblina Command API
	// ********************************
	//
	// ***
	// *** Subsystem General
	// ***
	func getSystemStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS, paramLen: 0, paramData: [0])
	}

	func getFusionStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_FUSION_STATUS, paramLen: 0, paramData: [0])
	}
	
	func getRecorderStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_RECORDER_STATUS, paramLen: 0, paramData: [0])
	}
	
	func getFirmwareVersion() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION, paramLen: 0, paramData: [0])
	}
	
	func getDataPortState() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS, paramLen: 0, paramData: [0])
	}
	
	func setDataPort(_ PortIdx : Int, Ctrl : UInt8) {
		var param = [UInt8](repeating: 0, count: 2)

		param[0] = UInt8(PortIdx)
		param[1] = Ctrl		// 1 - Open, 0 - Close
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, paramLen: 2, paramData: param)
	}
	
	func getPowerStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_POWER_STATUS, paramLen: 0, paramData: [0])
	}

	func getSensorStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_SENSOR_STATUS, paramLen: 0, paramData: [0])
	}
	
	func disableStreaming() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_DISABLE_STREAMING, paramLen: 0, paramData: [0])
	}

	func resetTimeStamp( Delayed : Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Delayed == true {
			param[0] = 1
		}
		else {
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP, paramLen: 1, paramData: param)
	}
	
	func firmwareUpdate() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE, paramLen: 0, paramData: [0])
	}
	
	func getDeviceName() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_DEVICE_NAME_GET, paramLen: 0, paramData: [0])
	}
	
	func setDeviceName(name : String) {
		let param = [UInt8](name.utf8)
		print("setDeviceName \(name) \(param))")
		var len = param.count
		if len > Int(NEBLINA_NAME_LENGTH_MAX) {
			len = Int(NEBLINA_NAME_LENGTH_MAX)
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET, paramLen: len, paramData: param)
	}
	
	func shutdown() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_DEVICE_SHUTDOWN, paramLen: 0, paramData: [0])
	}
	
	func getUnixTime(uTime : UInt32) {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_GET_UNIX_TIMESTAMP, paramLen: 0, paramData: [0])
	}

	func setUnixTime(uTime : UInt32) {
		var param = [UInt8](repeating: 0, count: 4)

		param[0] = UInt8(uTime & 0xFF)
		param[1] = UInt8((uTime >> 8) & 0xFF)
		param[1] = UInt8((uTime >> 16) & 0xFF)
		param[3] = UInt8((uTime >> 24) & 0xFF)

		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_SET_UNIX_TIMESTAMP, paramLen: param.count, paramData: param)
	}

	// ***
	// *** EEPROM
	// ***
	func eepromRead(_ pageNo : UInt16) {
		var param = [UInt8](repeating: 0, count: 2)

		param[0] = UInt8(pageNo & 0xff)
		param[1] = UInt8((pageNo >> 8) & 0xff)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_EEPROM, cmd: NEBLINA_COMMAND_EEPROM_READ, paramLen: param.count, paramData: param)
	}
	
	func eepromWrite(_ pageNo : UInt16, data : UnsafePointer<UInt8>) {
		var param = [UInt8](repeating: 0, count: 10)
		
		param[0] = UInt8(pageNo & 0xff)
		param[1] = UInt8((pageNo >> 8) & 0xff)
		for i in 0..<8 {
			param[i + 2] = data[i]
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_EEPROM, cmd: NEBLINA_COMMAND_EEPROM_WRITE, paramLen: param.count, paramData: param)
	}
	
	// *** LED subsystem commands
	func getLed() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_LED, cmd: NEBLINA_COMMAND_LED_STATUS, paramLen: 0, paramData: [0])
	}
	
	func setLed(_ LedNo : UInt8, Value:UInt8) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = LedNo
		param[1] = Value
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_LED, cmd: NEBLINA_COMMAND_LED_STATE, paramLen: param.count, paramData: param)
	}
	
	// *** Power management sybsystem commands
	func getTemperature() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_POWER, cmd: NEBLINA_COMMAND_POWER_TEMPERATURE, paramLen: 0, paramData: [0])
	}
	
	func setBatteryChargeCurrent(_ Current: UInt16) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = UInt8(Current & 0xFF)
		param[1] = UInt8((Current >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_POWER, cmd: NEBLINA_COMMAND_POWER_CHARGE_CURRENT, paramLen: param.count, paramData: param)
	}

	// ***
	// *** Fusion subsystem commands
	// ***
	func setFusionRate(_ Rate: NeblinaRate_t) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = UInt8(Rate.rawValue & 0xFF)
		param[1] = UInt8((Rate.rawValue >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_RATE, paramLen: param.count, paramData: param)
	}

	func setFusionDownSample(_ Rate: UInt16) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = UInt8(Rate & 0xFF)
		param[1] = UInt8((Rate >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_DOWNSAMPLE, paramLen: param.count, paramData: param)
	}
	
	func streamMotionState(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamQuaternion(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamEulerAngle(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamExternalForce(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM, paramLen: param.count, paramData: param)
	}

	func setFusionType(_ Mode:UInt8) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = Mode
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_FUSION_TYPE, paramLen: param.count, paramData: param)
	}
	
	func recordTrajectory(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD, paramLen: param.count, paramData: param)
	}
	
	func streamTrajectoryInfo(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamPedometer(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM, paramLen: param.count, paramData: param)
	}

	func streamSittingStanding(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM, paramLen: param.count, paramData: param)
	}
	
	func lockHeadingReference() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE, paramLen: 0, paramData: [0])
	}
	
	func streamFingerGesture(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_FINGER_GESTURE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamRotationInfo(_ Enable:Bool, Type : UInt8) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[1] = Type
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM, paramLen: param.count, paramData: param)
	}
	
	func externalHeadingCorrection(yaw : Int16, error : UInt16 ) {
		var param = [UInt8](repeating: 0, count: 4)
		
		param[0] = UInt8(yaw & 0xFF)
		param[1] = UInt8((yaw >> 8) & 0xFF)
		param[2] = UInt8(error & 0xFF)
		param[3] = UInt8((error >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_EXTERNAL_HEADING_CORRECTION, paramLen: param.count, paramData: param)
	}
	
	func resetAnalysis() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_RESET, paramLen: 0, paramData: [0])
	}

	func calibrateAnalysis() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_CALIBRATE, paramLen: 0, paramData: [0])
	}
	
	func createPoseAnalysis(id : UInt8, qtf : [Int16]) {
		var param = [UInt8](repeating: 0, count: 2 + 8)
		
		param[0] = UInt8(id & 0xFF)
		
		for i in 0..<4 {
			param[1 + (i << 1)] = UInt8(qtf[i] & 0xFF)
			param[2 + (i << 1)] = UInt8((qtf[i] >> 8) & 0xFF)
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_CREATE_POSE, paramLen: param.count, paramData: param)
	}
	
	func setActivePoseAnalysis(id : UInt8) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = id
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_SET_ACTIVE_POSE, paramLen: param.count, paramData: param)
	}

	func getActivePoseAnalysis() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_GET_ACTIVE_POSE, paramLen: 0, paramData: [0])
	}

	func streamAnalysis(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_STREAM, paramLen: param.count, paramData: param)
	}
	
	func getPoseAnalysisInfo(_ id: UInt8) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = id
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_POSE_INFO, paramLen: param.count, paramData: param)
	}

	func calibrateForwardPosition() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION, paramLen: 0, paramData: [0])
	}
	
	func calibrateDownPosition() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION, paramLen: 0, paramData: [0])
	}
	
	func streamMotionDirection(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_MOTION_DIRECTION_STREAM, paramLen: param.count, paramData: param)
	}

	func streamShockSegment(_ Enable:Bool, threshold : UInt8 ) {
		var param = [UInt8](repeating: 0, count: 2)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		param[1] = threshold
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_SHOCK_SEGMENT_STREAM, paramLen: param.count, paramData: param)
	}
	
	func setGolfSwingAnalysisMode(_ mode : UInt8) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = mode
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_SET_GOLFSWING_ANALYSIS_MODE, paramLen: param.count, paramData: param)
	}
	
	func setGolfSwingMaxError(_ count : UInt8) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = count
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_SET_GOLFSWING_MAXIMUM_ERROR, paramLen: param.count, paramData: param)
	}
	
	// ***
	// *** Storage subsystem commands
	// ***
	func getSessionCount() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_COUNT, paramLen: 0, paramData: [0])
	}
	
	func getSessionInfo(_ sessionId : UInt16, idx : UInt8) {
		var param = [UInt8](repeating: 0, count: 3)
		
		param[0] = UInt8(sessionId & 0xFF)
		param[1] = UInt8((sessionId >> 8) & 0xFF)
		param[2] = idx;
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_GENERAL_INFO, paramLen: param.count, paramData: param)
	}

	func getSessionName(_ sessionId : UInt16) {
		var param = [UInt8](repeating: 0, count: 3)
		
		param[0] = UInt8(sessionId & 0xFF)
		param[1] = UInt8((sessionId >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_NAME, paramLen: param.count, paramData: param)
	}
	
	func eraseStorage(_ quickErase:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if quickErase == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_ERASE_ALL, paramLen: param.count, paramData: param)

	}
	
	func sessionPlayback(_ Enable:Bool, sessionId : UInt16) {
		var param = [UInt8](repeating: 0, count: 3)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		param[1] = UInt8(sessionId & 0xff)
		param[2] = UInt8((sessionId >> 8) & 0xff)

		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_PLAYBACK, paramLen: param.count, paramData: param)
	}
	
	func sessionRecord(_ Enable:Bool, info : String) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		print("\(info)")
		param += info.utf8
		print("\(param)")
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_RECORD, paramLen: min(param.count, 16), paramData: param)
	}
	
	func sessionRead(_ SessionId:UInt16, Len:UInt16, Offset:UInt32) {
		var param = [UInt8](repeating: 0, count: 8)

		// Command parameter
		param[0] = UInt8(SessionId & 0xFF)
		param[1] = UInt8((SessionId >> 8) & 0xFF)
		param[2] = UInt8(Len & 0xFF)
		param[3] = UInt8((Len >> 8) & 0xFF)
		param[4] = UInt8(Offset & 0xFF)
		param[5] = UInt8((Offset >> 8) & 0xFF)
		param[6] = UInt8((Offset >> 16) & 0xFF)
		param[7] = UInt8((Offset >> 24) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_READ, paramLen: param.count, paramData: param)
	}
	
	func sessionDownload(_ Start : Bool, SessionId:UInt16, Len:UInt16, Offset:UInt32) {
		var param = [UInt8](repeating: 0, count: 9)

		// Command parameter
		if Start == true {
			param[0] = 1
		}
		else {
			param[0] = 0
		}
		param[1] = UInt8(SessionId & 0xFF)
		param[2] = UInt8((SessionId >> 8) & 0xFF)
		param[3] = UInt8(Len & 0xFF)
		param[4] = UInt8((Len >> 8) & 0xFF)
		param[5] = UInt8(Offset & 0xFF)
		param[6] = UInt8((Offset >> 8) & 0xFF)
		param[7] = UInt8((Offset >> 16) & 0xFF)
		param[8] = UInt8((Offset >> 24) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD, paramLen: param.count, paramData: param)
	}
	
	// ***
	// *** Sensor subsystem commands
	// ***
	func sensorSetDownsample(stream : UInt16, factor : UInt16) {
		var param = [UInt8](repeating: 0, count: 4)
		
		param[0] = UInt8(stream & 0xFF)
		param[1] = UInt8(stream >> 8)
		param[2] = UInt8(factor & 0xFF)
		param[3] = UInt8(factor >> 8)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_SET_DOWNSAMPLE, paramLen: param.count, paramData: param)
	}
	
	func sensorSetRange(type : UInt16, range: UInt16) {
		var param = [UInt8](repeating: 0, count: 4)
		
		param[0] = UInt8(type & 0xFF)
		param[1] = UInt8(type >> 8)
		param[2] = UInt8(range & 0xFF)
		param[3] = UInt8(range >> 8)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_SET_RANGE, paramLen: param.count, paramData: param)
	}
	
	func sensorSetRate(type : UInt16, rate: UInt16) {
		var param = [UInt8](repeating: 0, count: 4)
		
		param[0] = UInt8(type & 0xFF)
		param[1] = UInt8(type >> 8)
		param[2] = UInt8(rate & 0xFF)
		param[3] = UInt8(rate >> 8)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_SET_RATE, paramLen: param.count, paramData: param)
	}
	
	func sensorGetDownsample(stream : NeblinaSensorStream_t) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = stream.rawValue
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_GET_DOWNSAMPLE, paramLen: param.count, paramData: param)
	}

	func sensorGetRange(type : NeblinaSensorType_t) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = type.rawValue
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_GET_RANGE, paramLen: param.count, paramData: param)
	}

	func sensorGetRate(type : NeblinaSensorType_t) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = type.rawValue
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_GET_RATE, paramLen: param.count, paramData: param)
	}

	func sensorStreamAccelData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamGyroData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamHumidityData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamMagData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamPressureData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamTemperatureData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamAccelGyroData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM, paramLen: param.count, paramData: param)
	}

	func sensorStreamAccelMagData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM, paramLen: param.count, paramData: param)
	}
}
