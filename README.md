# geoLink 128 v1.01
Written by Glenn Holmer (a.k.a "Shadow", a.k.a "Cenbe").

GEOS 128 support added by Alex Burger

https://csdb.dk/release/?id=91469

August 18th, 2019


## Overview

geoLink128 is a networked GEOS application for the Commodore 128 written by ShadowM (originally for the C64 with C128 support added by Alex Burger) which includes an IRC client and uses the IP65 network stack.  A technical presentation on geoLink called 'geoLink Internals' was given at the C=4 Expo on 2010-05-29 (1) and a presentation on 'Networking in Geos' was given at the 2009 World of Commodore (2).  The program works with GEOS 128 in 80 column mode.  See Manual.html for instructions on using geoLink and Readme2.html for other useful information including the version history, downloading disk images and compiling using geoProgrammer.  It requires a 64NIC+, 1541 Ultimate, RR-Net, MMC Replay, or FB-Net network card (it does not work with 'WiFi' modems).

	(1) ftp://8bitfiles.net/archives/geos-archive/GEOS-LINK/geoLinkInternals.pdf
	(2) ftp://8bitfiles.net/archives/geos-archive/GEOS-LINK

The original geoProgrammer source files were converted to ASCII and then tweaked by Alex Burger to compile with CC65.


## Installing

If this is your first time trying geoLink128, it is recommended that you download the 40 column c64 .d64 image from CSDB or 8bitfiles.net which contains a bootable GEOS 64 2.0 disk along with the geoLink program.  Read both Readme2.html and Manual.html before attempting to run geoLink.

If using the Vice c64 emulator, you can configure the network card using by clicking Settings / Cartridge I/O Settings / Ethernet Cart Settings.  Enable cartridge and set to RR-Net at $DE00.  Then Settings / Ethernet Settings and select your PC network card to attach to.

To manually install from this repository, inside the bin folder is a cc65 compiled version (geolink.cvt) in GEOS CONVERT format which can be copied directly to a .d64, d71 or .d81 image file using DirMaster or another Commodore disk imaging program.  When using DirMaster, the file will be automatically converted to GEOS format but with other utilities you may have to manually convert to GEOS format using CONVERT 2.5.

geoLink reports network errors by hex code which can be found in IP65's ip65.h.  The error codes are:

	IP65_ERROR_PORT_IN_USE                   0x80
	IP65_ERROR_TIMEOUT_ON_RECEIVE            0x81
	IP65_ERROR_TRANSMIT_FAILED               0x82
	IP65_ERROR_TRANSMISSION_REJECTED_BY_PEER 0x83
	IP65_ERROR_INPUT_TOO_LARGE               0x84
	IP65_ERROR_DEVICE_FAILURE                0x85
	IP65_ERROR_ABORTED_BY_USER               0x86
	IP65_ERROR_LISTENER_NOT_AVAILABLE        0x87
	IP65_ERROR_CONNECTION_RESET_BY_PEER      0x89
	IP65_ERROR_CONNECTION_CLOSED             0x8A
	IP65_ERROR_MALFORMED_URL                 0xA0
	IP65_ERROR_DNS_LOOKUP_FAILED             0xA1


## Compiling geoLink

Compiling requires the cc65 6502 compiler which is available from https://cc65.github.io/cc65/.

geoLink uses the IP65 TCP/IP stack for 6502 based computers from https://github.com/cc65/ip65.  Included in this repository are the compiled library files along with IP65-GEOS.prg which contains the compiled stack for GEOS.  Compiling IP65 from scratch is detailed below but is not required.

The following libraries are required from the GOES 2.0 source code at https://github.com/mist64/geos/tree/master/inc

	geosmac.inc
	geossym.inc
	jumptab.inc

The following libraries are required from the cc65 project, which can be found at https://github.com/cc65/cc65/tree/master/libsrc/geos-cbm

	geossym2.inc

Note:  cc65 will create a Vice symbol file (geoLink.lbl) with all lables (eg: io := $d000), but it does not include constants (eg: two = 2).  To make debugging easier, modify geossym.inc, geossym2.inc and jumptab.inc by changing all '=' to ':=' so that they are all added to the symbol file.

Note:  When using the generated debugger file, labels and code for loaded modules is not visible due to a limitiation in how cc65 creates the debug file.  If you find a solution to this, please let me know.

The button bitmap data is contained inside the main source files (geoLinkIRC.s, geoLinkPing etc).  If the .png/.pcx source images are changed, they need to be recompiled using sp65 and then manually added to source files.  If needed, use Gimp to convert from .png to .pcx.

	sp65 -v -r button-unck.pcx -c geos-bitmap -w button-unck.s,format=asm
	sp65 -v -r button-ck.pcx -c geos-bitmap -w button-ck.s,format=asm
	sp65 -v -r button-ok.pcx -c geos-bitmap -w button-ok.s,format=asm
	sp65 -v -r button-cncl.pcx -c geos-bitmap -w button-cncl.s,format=asm
	sp65 -v -r button-okDis.pcx -c geos-bitmap -w button-okDis.s,format=asm
	sp65 -v -r button-cnclDis.pcx -c geos-bitmap -w button-cnclDis.s,format=asm

	sp65 -v -r button-send.pcx -c geos-bitmap -w button-send.s,format=asm
	sp65 -v -r button-str.pcx -c geos-bitmap -w button-str.s,format=asm
	sp65 -v -r button-stp.pcx -c geos-bitmap -w button-stp.s,format=asm
	sp65 -v -r button-exit.pcx -c geos-bitmap -w button-exit.s,format=asm
	
The program icon is contained in icon-program.bin.  If the .png/.pcx source image is changed, it needs to be recompiled using sp65.

	sp65 -v -r icon-program.pcx -c geos-icon -w icon-program.bin,format=bin

Included with the source is a Unix Makefile and a Windows make.cmd batch file.  To build with either environment, type make and you should end up with:

	geoLink.cvt
	geoLinkEmbed.cvt
	dbgfile.cvt

Copy the following files to a .d64, d71 or .d81 image file using DirMaster or another Commodore disk imaging program.  When using DirMaster, the .cvt files will be automatically converted to GEOS format but with other utilities you may have to manually convert to GEOS format using CONVERT 2.5.

	vip128-mono.cvt		(located in bin folder)
	IP65-GEOS.prg		(located in bin folder)
	geoLinkEmbed.cvt
	geoLink.cvt
	dbgfile.cvt			(only needed for debugging with geoDebugger)

Note:  Run perl convert.pl to update the dbgfile.cvt.

Launch GEOS and run geoLinkEmbed. This will embed the TCP/IP stack (ip65-geos) into VLIR record 9 of the geoLink executable and the monospaced font (VIP128-mono) into record 8.  You should now have a working copy of geoLink.

To use geoDebugger, rename the debug file uIecSwitchX.dbg to geoLink128.dbg.

Following is the memory layout of the various modules for geoLink 1.01.  If addtional code is added to any of the modules, be sure to check the generated geoLink.map file to make sure there are no memory overlaps.  To change the start address for the overlay modules, change the __OVERLAYADDR__ value in geos-cbm.cfg and the modLoad label in geoLinkVal.s.  Note:  The start addresses for Overlay 8 (font) and 9 (IP65) in geos-cbm.cfg are not actually used.

The VIP font is loaded at the end of the geoLinkIRC code (vipFont label).  vipFont in the generated geoLink.lbl will give you the actual start addresses of the font.  fontEnd in geoDebugger after connecting to an IRC server should give you the actual end address (see note above about geoDebugger issues).

IP65 is loaded at the address IP65 specified in geoLink.inc and can only be relocated by recompiling IP65.

	Module                      Start   End
	=========================================
	geoLinkRes + geoLinkVal     0400    001012 
	Overlay1 - geoLinkSetup     001020  001AA8
	Overlay2 - geoLinkPing      001020  001596
	Overlay3 - geoLinkLogin     001020  00168D
	Overlay4 - geoLinkIRC       001020  002CD6
	Overlay8 - Font             002CF4  ???? *
	Overlay9 - IP65             3300    4FE6
	
* The font data is ???? bytes and is loaded at the end of geoLinkIRC when the IRC module is launched.


## Compiling IP65

Coming soon...



