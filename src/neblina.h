/*
 * neblina.h
 *
 *	Neblina
 *
 *  Created on: 2015-06-17
 *      Author: hoan
 */
#include <stdint.h>


#ifndef __NEBLINA_H__
#define __NEBLINA_H__

#pragma pack(push, 1)

typedef struct {
	uint8_t major;
	uint8_t minor;
	uint8_t build;
} FWVersion_t;

typedef struct {
	uint8_t API_Release;
	FWVersion_t KL26;
	FWVersion_t Nordic;
	uint64_t devid;
} Neblina_FWVersions_t;

//Firmware Versions: Define here
#define API_RELEASE_VERSION	0x01

//Freescale
#define NEBKL26_FWVERS_MAJOR	0
#define NEBKL26_FWVERS_MINOR	13
#define NEBKL26_FWVERS_BUILD	8

//Nordic
#define NEBNRF51_FWVERS_MAJOR	0
#define NEBNRF51_FWVERS_MINOR	13
#define NEBNRF51_FWVERS_BUILD	8

///////////////////////////////////


/*
 * Neblina communication interface definitions
 */
#define NEB_COMM_INTRF_BLE				0		// Neblina comm over BLE
#define NEB_COMM_INTRF_UART				1		// Neblina comm over UART

/*
 * Neblina Control Byte definitions
 *
 * 0-4 : Subsystem
 * 5-7 : Packet Type
 *
 */
#define NEB_CTRL_PKTYPE_MASK			0xE0		// Packet type mask
#define NEB_CTRL_SUBSYS_MASK			0x1F		// Subsystem mask

// Packet types
#define NEB_CTRL_PKTYPE_DATA				0		// Data/Response
#define NEB_CTRL_PKTYPE_ACK					1		// Ack
#define NEB_CTRL_PKTYPE_CMD					2		// Command
#define NEB_CTRL_PKTYPE_RESERVE1			3
#define NEB_CTRL_PKTYPE_ERR					4		// Error response
#define NEB_CTRL_PKTYPE_RESERVE2			5		//
#define NEB_CTRL_PKTYPE_RQSTLOG				6		// Request status/error log
#define NEB_CTRL_PKTYPE_RESERVE3			7

// Subsystem values
#define NEB_CTRL_SUBSYS_DEBUG				0		// Status & logging
#define NEB_CTRL_SUBSYS_MOTION_ENG			1		// Motion Engine
#define NEB_CTRL_SUBSYS_POWERMGMT			2		// Power management
#define NEB_CTRL_SUBSYS_GPIO				3		// GPIO control
#define NEB_CTRL_SUBSYS_LED					4		// LED control
#define NEB_CTRL_SUBSYS_ADC					5		// ADC control
#define NEB_CTRL_SUBSYS_DAC					6		// DAC control
#define NEB_CTRL_SUBSYS_I2C					7		// I2C control
#define NEB_CTRL_SUBSYS_SPI					8		// SPI control

// ***
// Power management subsystem command code
#define POWERMGMT_CMD_GET_BAT_LEVEL			0	// Get battery level
#define POWERMGMT_CMD_GET_TEMPERATURE		1	// Get temperature
#define POWERMGMT_CMD_SET_CHARGE_CURRENT	2	// Set battery charge current

// ***
// Debug subsystem command code
#define DEBUG_CMD_PRINTF							0	// The infamous printf thing.
#define DEBUG_CMD_SET_INTERFACE						1	// sets the protocol interface - this command is now obsolete
#define DEBUG_CMD_MOTENGINE_RECORDER_STATUS			2	// asks for the streaming status of the motion engine, as well as the flash recorder state
#define DEBUG_CMD_MOTION_ENG_UNIT_TEST_START_STOP	3	// starts/stops the motion engine unit-test mode
#define DEBUG_CMD_MOTION_ENG_UNIT_TEST_DATA			4	// data being transferred between the host and Neblina for motion engine's unit testing
#define DEBUG_CMD_GET_FW_VERSION					5
#define DEBUG_CMD_DUMP_DATA							6 	// dump and forward the data to the host (for printing on the screen, etc.)
#define DEBUG_CMD_STREAM_RSSI						7	// get the BLE signal strength in db
#define DEBUG_CMD_GET_DATAPORT						8	// Get streaming data interface port state.
#define DEBUG_CMD_SET_DATAPORT						9	// Enable/Disable streaming data interface port

//
// Data port control
#define DATAPORT_MAX								2	// Max number of data port

#define DATAPORT_BLE								0 	// streaming data port BLE
#define DATAPORT_UART								1	//

#define DATAPORT_OPEN								1	// Open streaming data port
#define DATAPORT_CLOSE								0	// Close streaming data port

typedef struct _Data_Port {
	uint8_t	PortIdx;		// Data port index	(DATAPORT_BLE = 0, DATAPORT_UART = 1, ...)
	uint8_t	PortCtrl;		// Data port control (DATAPORT_OPEN, DATAPORT_CLOSE)
} NEB_DATAPORT_CTRL;


// LED control command codes
#define LED_CMD_SET_VALUE							1	// Set LED value
#define LED_CMD_GET_VALUE							2	// Get LED value
#define LED_CMD_SET_CFG								3	// Set config
#define LED_CMD_GET_CFG								4	// Get config

#define LED_MAX_NB			8	// Max number of LED supported

typedef struct _LedCtrl_Data {
	uint8_t NbLed;						// Number of LED to control
	struct {
		uint8_t	No;						// LED number
		uint8_t	Value;					// data - value depending on command code
	} Led[LED_MAX_NB];
} NEB_LEDCTRL_DATA;

#define NEB_PKT_MAX_FUSION_DATASIZE 	12

typedef struct Fusion_DataPacket_t
{
	uint32_t TimeStamp;
	uint8_t data[NEB_PKT_MAX_FUSION_DATASIZE];
} Fusion_DataPacket_t;

typedef struct {
	uint8_t SubSys:5; 	// subsystem code
	uint8_t PkType:3; 	// packet type: command, response, error packet, acknowledge
	uint8_t Len;		// Data len = size in byte of following data
	uint8_t Crc;		// Crc on data
	uint8_t Cmd;
} NEB_PKTHDR;

// NOTE : Variable length data structure. Do not allocate this structure directly
//
typedef struct {
	NEB_PKTHDR	Header;
	uint8_t 	Data[1];	// Data buffer follows. i.e. Data array more than one item
} NEB_PKT;



#pragma pack(pop)


#endif // __NEBLINA_H__
