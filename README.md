# OpenTX Lua Telemetry Scripts
A collection of telemetry scripts i build for OpenTx 2.1.x

feel free to contact me if u have questions: rcbebo82@googlemail.com

Lipo.lua
This scripts shows up to 12S Lipo cells or if only one lipo sensor is attachted some optional stuff like RSSI, RPM and temperature.

If you use one lipo sensor cells are displayed on the left side, rpm on the right side. Check the variables mainrotorgear and tailrotorgear to fit it for your use. Temperature is only displayed in the middle if a tmp sensor is present. If you use a Taranis X9D plus you get the rssi on the right side of the display. 
I use this script now for my T-Rex 600 Nitro Pro which only has 2 lipo cells connected.

For 12 S you need two FLVS Sensors. Note that you must change the id of one sensor with a SBUS Servo channel changer. Define the names like you want in the telemetry screen and correct the variables liposensor1, liposensor2.

In the middle you see the voltage of all cells together and the receiver voltage below.
On the lowest middle position you see the lowest lipo voltage cell of each sensor
the right one is liposensor2 and the left one liposensor1.
