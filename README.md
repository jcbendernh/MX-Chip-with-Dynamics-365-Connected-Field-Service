# MX-Chip-with-Dynamics-365-Connected-Field-Service
This walks you through how to integrate an MX Chip with the OOB Dynamics 365 Connected Field Service Demo.

Recently we released a firmware update for the MX Chip that exposes all the telemetry on the chip and integrates it with IoT Central.  However, we can also use that firmware for the chip to interact with the traditional IoT Hub without IoT Central.  This makes it very easy to get the chip integrated with the Dynamics 365 Connected Field Service demonstration.  Thus, if you already have the Connected Field Service demonstration running within Azure IoT and Dynamics 365, you can use the following steps to integrate the MX Chip to interact with Dynamics 365 for both sending and receiving messages.  For more information on the MX Chip, click <a href="http://www.mxchip.com/az3166" target="_blank">here</a>.
 
1.	Go into Dynamics 365 and add your custom device.  To do so, within D365, go to <b>Internet of Things >> Registered Devices</b> and click <b>+NEW</b> to add a new device.  Give it a distinct name and Device ID.
NOTE:  The Device ID is what gets registered to the IoT Hub, so we will need to remember this for future steps.
2.	After the record has saved, click the <b>REGISTER</b> button on the toolbar.  Once the registration process has completed, your device should now show a Registration <b>Status = Registered</b>.
3.	Next, we need to capture our Device Connection string.  To do so, go into the <a href="https://portal.azure.com" target="_blank"> Azure portal</a> and under your Connected Field Service resource group, select your <b>IoT Hub</b> and once loaded, click on the <b>IoT Devices</b> blade and select your newly registered <b>Device ID</b>.
4.	This will open the <b>IoT Device</b> blade for this device.  Copy the <b>Connection string – primary key</b> to Notepad.  
NOTE:  This is what defines your custom Device Id to the MX Chip
5.	Download the <b>Dec 4, 2017 release</b> of the firmware which is the <b>AZ3166-IoT-Central-1.0.0.bin</b> file from GitHub at https://github.com/Microsoft/microsoft-iot-central-firmware/releases.<br>  <b> NOTE: </b>Do not download the latest release as it has an issue with receiving the Method Name commands.
6.	Follow the instructions in the <b>Prepare the DevKit device</b> section at https://docs.microsoft.com/en-us/microsoft-iot-central/howto-connect-devkit.  When you get to step 7 and you configure the device in the web page at http://192.168.0.1/start make sure to copy your <b>Connection string – primary key</b> from Notepad into the <b>Device connection string</b> field and select the Temperature checkbox at a minimum.  You can select the other telemetry as well, but it is not needed for this specific scenario.<br>&nbsp;<br>
<img src="https://jq25qg.dm2302.livefilestore.com/y4mG_faJylzWG9bcN4fiO_DNQ0-FXxda3W9K3l1lxmp2uOzJ-drp2zUo5HPXJpriI9Lv3JBSv9btZjJDYz4KfyoUn97E_oTjugqa8qkTsMDi-T3YPiJHzddg8IB-GG0p5BNpUyEmsZKCdKJ72Ijx-w77BSBVJYXA0G_ctKrg2J30TvBuHq3CwBWvCyKUCdFQvi1UTfN8RGq5ANOlWjfHaEXiw?width=660&height=387&cropmode=none" width="660" height="387" /><br>&nbsp;<br>
Click the <b>Configure Device</b> button and click the reset button on the MX Chip.<br>&nbsp;<br>
NOTE:  If you do not get the Device connection string field in the window above, try doing a hard reset on the MX CHIP by holding down both the A & B buttons for a few seconds.

7.	Now you should see telemetry coming from your custom named MX chip.  You can view this by downloading the <a href="https://github.com/Azure/azure-iot-sdk-csharp/tree/master/tools/DeviceExplorer" target="_blank">Azure Device Explorer Twin</a> and pasting the IoT Hub Connection Sting into the Configuration tab.  Once you have done so, go to the Data tab and select your device and click Monitor…<br>&nbsp;<br>
<img src="https://edjpig.dm2302.livefilestore.com/y4mb5rLs2IcvZlfIFDSXeZmQwC_sRXKhvOHxI2OOzFW8PXXebgTeBAIgRVX9Lyi7AYQxsPfqWJAj_5VUiFRQU-YjJMszMyPDf2CFfSN6lV7w_xJHGfqThQFSNQsoby2dIelOs2sOXHNGNZvvXF7QqG4UaqvYn_ttFVV8rPS8qxU8IMF7EIVcNWBw62-4-eD0nRERQoVnCbTzIbBE3uRqnoIWw?width=660&height=524&cropmode=none" width="660" height="524" /><br>&nbsp;<br>
NOTE:  The IoT Hub Connection string can be obtained by going into the <a href="https://portal.azure.com" target="_blank">Azure portal</a> and under your Connected Field Service resource group, select your IoT Hub and click on the <b>Shared access polices</b> blade.  Once it is loaded, click the <b>iothubowner</b> policy and copy the <b>Connection string-primary key</b>.<br>&nbsp;<br>

Since the MX Chip firmware for IoT Central device sends telemetry a little different than the web simulator or other devices, we will need to modify our queries for the Stream Analytics jobs.  If you enabled the Power BI integration during the Connected Field Service setup, you will have 2 Stream Analytics jobs in your Connected Field Service resource group.  The following steps show how to configure these jobs so that both the MX Chip and the web simulators can send data simultaneously via the IoT Hub and ultimately into Dynamics.

8.	First, we will modify the Stream Analytics job with the <b>Output to the Alerts Queue</b>.  This can be identified by choosing our Connected Field Service Resource Group within the Azure portal and sort the listing by Type.  Open the first Stream Analytics job in your listing and verify that the <b>output</b> states <b>AlertsQueue</b>.  If it is not this job, close and open the other job. <br>&nbsp;<br>
<img src="https://fe2rxq.dm2302.livefilestore.com/y4mgArnk1PjCTNyEPiWaWeH4W_WE5tBS8EVgfQvK1kqIrDs5m6s92Gc8foBydiK6cdWz2W7JcXVwaTtEPLgcbr56NeC57K5i_puvqtykJ-Nets4rNk-2JO1vav0OoJVPNQ5w3KCHB-EdxIbxdysd0RGiAaZR820if2gYOYIVZre-BSgSE6T4YNApXRtIqwjUuboA7PnIQ_1powMtL_5VvNg2g?width=256&height=203&cropmode=none" width="256" height="203" /><br>

9.	Next, we need to stop the Stream Analytics job in order to modify the query.  From the overview blade of the Stream Analytics job, click the <b>Stop</b> button at the top.  Typically, it takes about 30-90 seconds for the Stream Analytics job to stop. 
10.	Once stopped, click on the <b>Query</b> blade to open the Query window.  Highlight all text in the window and delete.  Copy the contents from the <b>IoTStream to AlertsQueue with Custom MX Chip Name SQL</b> script in this repository into the Query Editor window and click Save.
11.	Once the query has saved, go back to the <b>Overview</b> blade and click <b>Start</b>.
12.	Put your finger on the temp sensor of the MX Chip to manipulate the temperature so it is hotter than the threshold.  You should now start to see IoT Alerts showing up in Dynamics 365.
13.	If you activated the Power BI integration, we need to also manipulate the Stream Analytics job with the <b>output to PowerBISQL</b>.  This can be identified by choosing our Connected Field Service Resource Group within the Azure portal and sort the listing by Type.  Open the other Stream Analytics job in your listing and verify that the output states <b>PowerBISQL</b>…<br>&nbsp;<br>
<img src="https://r8e4aa.dm2302.livefilestore.com/y4mGERWQxyG6eUQw6ERfqSo54LjXDBBqkwWWCPQXBQ16NgJmS_oy54XYjQjnwIXDNSTyhjMjxX0v-oBMXGDdov-todkCvYvTiA1Tl6oRwQLcBNgv8kNM_bvHEp8krdbmy5D9wLBb9whpPvceCKuxuHcGI31BYCM04OETD3FK-7GmNAwXStw8pUH0WAcmAAGYvctgO2PGUb3UmkE2JFHECq7sg?width=256&height=207&cropmode=none" width="256" height="207" /><br>

14.	Just as before, we need to stop the Stream Analytics job in order to modify the query.  From the overview blade of the Stream Analytics job, click the <b>Stop</b> button at the top.  
15.	Once stopped, click on the <b>Query</b> blade to open the Query window.  Highlight all text in the window and delete.  Copy the contents from the <b>IoTStream to PowerBISQL with Custom MX Chip Name</b> SQL script in this repository into the Query Editor window and click <b>Save</b>.
16.	Once the query has saved, go back to the <b>Overview</b> blade and click <b>Start</b>.
17.	You should now see the data in the Azure SQL database and the <a href="https://www.microsoft.com/en-us/download/details.aspx?id=54298" target="_blank">Power BI Report Template for Connected Field Service</a> that uses that database as a source.

Now that we have configured data to flow from the device to Dynamics 365.  Let’s look how we can send a signal back to the device from Dynamics 365.  With the MX Chip IoT Central Firmware, there are two out-of-the-box methods that we can call on the device…

<b>Have a Message Display on the device</b><br>
<b>NOTE:</b>  This only works with the <b>Dec 4, 2017 release</b> of the firmware which is the <b>AZ3166-IoT-Central-1.0.0.bin</b> file.  Later firmware releases use different Method Names and are not compatible with these commands.

18.	Bring up your IoT Device record in Dynamics 365 by going to <b>Internet of Things >> Registered Devices</b> and open your <b>IoT Device</b>.  In the toolbar, click the <b>CREATE COMMAND</b> button on the toolbar.  In the New IoT Device Command window, fill in a name and then copy the following into the MESSAGE TO SEND FIELD…<br>&nbsp;<br>
{"methodName": "message","payload": {"text": "Message Received from Operator"}}<br>&nbsp;<br>
and click the <b>SEND & CLOSE</b> button on the toolbar.   Your message should show on the screen of the MX Chip shortly. It can take upwards of a minute to take effect.

<b>Show Rainbow Lights on the Device</b>

19.	Bring up your IoT Device record in Dynamics 365 by going to <b>Internet of Things >> Registered Devices</b> and open your <b>IoT Device</b>.  In the toolbar, click the <b>CREATE COMMAND</b> button on the toolbar.  In the New IoT Device Command window, fill in a name and then copy the following into the MESSAGE TO SEND FIELD…<br>&nbsp;<br>
{"methodName": "rainbow","payload": {"cycles": "5"}}<br>&nbsp;<br>
and click the <b>SEND & CLOSE</b> button on the toolbar.   The LED light on the left of the MX Chip should cycle through rainbow lights shortly. It can take upwards of a minute to take effect.
