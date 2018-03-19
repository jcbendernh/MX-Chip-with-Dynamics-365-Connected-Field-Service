# MX-Chip-with-Dynamics-365-Connected-Field-Service
This walks you through how to integrated an MX Chip with the OOB Dynamics 365 Connected Field Service Demo.

Recently we released a firmware update for the MX Chip that exposes all the telemetry on the chip and integrates it with IoT Central.  However, we can also use that firmware for the chip to interact with the traditional IoT Hub without IoT Central.  This makes it very easy to get the chip integrated with the Dynamics 365 Connected Field Service demonstration.  Thus, if you already have the Connected Field Service demonstration running within Azure IoT and Dynamics 365, you can use the following steps to integrate the MX Chip to interact with Dynamics 365 for both sending and receiving messages.  For more information on the MX Chip, click here.
 
1.	Go into Dynamics 365 and add your custom device.  To do so, within D365, go to <b>Internet of Things >> Registered Devices</b> and click <b>+NEW</b> to add a new device.  Give it a distinct name and Device ID.
NOTE:  The Device ID is what gets registered to the IoT Hub, so we will need to remember this for future steps.
2.	After the record has saved, click the <b>REGISTER</b> button on the toolbar.  Once the registration process has completed, your device should now show a Registration <b>Status = Registered</b>.
3.	Next, we need to capture our Device Connection string.  To do so, go into the Azure portal and under your Connected Field Service resource group, select your <b>IoT Hub</b> and once loaded, click on the <b>IoT Devices</b> blade and select your newly registered <b>Device ID</b>.
4.	This will open the <b>IoT Device</b> blade for this device.  Copy the <b>Connection string – primary key</b> to Notepad.  
NOTE:  This is what defines your custom Device Id to the MX Chip
5.	Download the latest <b>AZ3166-IoT-Central-1.0.0.bin</b> from GitHub at https://github.com/Microsoft/microsoft-iot-central-firmware/releases
6.	Follow the instructions in the <b>Prepare the DevKit device</b> section at https://docs.microsoft.com/en-u/s/microsoft-iot-central/howto-connect-devkit.  When you get to step 7 and you configure the device in the web page at http://192.168.0.1/start make sure to copy your <b>Connection string – primary key</b> from Notepad into the <b>Device connection string</b> field and select the Temperature checkbox at a minimum.  You can select the other telemetry as well, but it is not needed for this specific scenario. 

 
Click the <b>Configure Device</b> button and click the reset button on the MX Chip.

NOTE:  If you do not get the Device connection string field in the window above, try doing a hard reset on the MX CHIP by holding down both the A & B buttons for a few seconds.

7.	Now you should see telemetry coming from your custom named MX chip.  You can view this by downloading the Azure Device Explorer Twin and pasting the IoT Hub Connection Sting into the Configuration tab.  Once you have done so, go to the Data tab and select your device and click Monitor…
 

NOTE:  The IoT Hub Connection string can be obtained by going into the Azure portal and under your Connected Field Service resource group, select your IoT Hub and click on the <b>Shared access polices</b> blade.  Once it is loaded, click the <b>iothubowner</b> policy and copy the <b>Connection string-primary key</b>.

Since the MX Chip firmware for IoT Central device sends telemetry a little different than the web simulator or other devices, we will need to modify our queries for the Stream Analytics jobs.  If you enabled the Power BI integration during the Connected Field Service setup, you will have 2 Stream Analytics jobs in your Connected Field Service resource group.  The following steps show how to configure these jobs so that both the MX Chip and the web simulators can send data simultaneously via the IoT Hub and ultimately into Dynamics.

8.	First, we will modify the Stream Analytics job with the <b>Output to the Alerts Queue</b>.  This can be identified by choosing our Connected Field Service Resource Group within the Azure portal and sort the listing by Type.  Open the first Stream Analytics job in your listing and verify that the <b>output</b> states <b>AlertsQueue</b>.  If it is not this job, close and open the other job.

9.	Next, we need to stop the Stream Analytics job in order to modify the query.  From the overview blade of the Stream Analytics job, click the Stop button at the top.  Typically, it takes about 30-90 seconds for the Stream Analytics job to stop. 
10.	Once stopped, click on the <b>Query</b> blade to open the Query window.  Highlight all text in the window and delete.  Copy the contents from the <b>IoTStream to AlertsQueue with Custom MX Chip Name SQL</b> script into the Query Editor window and click Save.
11.	Once the query has saved, go back to the <b>Overview</b> blade and click <b>Start</b>.
12.	Put your finger on the temp sensor of the MX Chip to manipulate the temperature so it is hotter than the threshold.  You should now start to see IoT Alerts showing up in Dynamics 365.
13.	If you activated the Power BI integration, we need to also manipulate the Stream Analytics job with the <b>output to PowerBISQL</b>.  This can be identified by choosing our Connected Field Service Resource Group within the Azure portal and sort the listing by Type.  Open the other Stream Analytics job in your listing and verify that the output states <b>PowerBISQL</b>…

 

14.	Just as before, we need to stop the Stream Analytics job in order to modify the query.  From the overview blade of the Stream Analytics job, click the <b>Stop</b> button at the top.  
15.	Once stopped, click on the <b>Query</b> blade to open the Query window.  Highlight all text in the window and delete.  Copy the contents from the <b>IoTStream to PowerBISQL with Custom MX Chip Name</b> SQL script into the Query Editor window and click <b>Save</b>.
16.	Once the query has saved, go back to the <b>Overview</b> blade and click <b>Start</b>.
17.	You should now see the data in the Azure SQL database and the Power BI Report Template for Connected Field Service that uses that database as a source.

Now that we have configured data to flow from the device to Dynamics 365.  Let’s look how we can send a signal back to the device from Dynamics 365.  With the MX Chip IoT Central Firmware, there are a few out of the box methods that we can call on the device.  For this example I am highlighting the following….

<b>Have a Message Display on the device</b>

18.	Bring up your IoT Device record in Dynamics 365 by going to <b>Internet of Things >> Registered Devices</b> and open your <b>IoT Device</b>.  In the toolbar, click the <b>CREATE COMMAND</b> button on the toolbar.  In the New IoT Device Command window, fill in a name and then copy the following into the MESSAGE TO SEND FIELD…

{"methodName": "message","payload": {"text": "Message Received from Operator"}}

and click the <b>SEND & CLOSE</b> button on the toolbar.   Your message should show on the screen of the MX Chip shortly. It can take upwards of a minute to take effect.

<b>Show Rainbow Lights on the Device</b>

19.	Bring up your IoT Device record in Dynamics 365 by going to <b>Internet of Things >> Registered Devices</b> and open your <b>IoT Device</b>.  In the toolbar, click the <b>CREATE COMMAND</b> button on the toolbar.  In the New IoT Device Command window, fill in a name and then copy the following into the MESSAGE TO SEND FIELD…

{"methodName": "rainbow","payload": {"cycles": "5"}}  

and click the <b>SEND & CLOSE</b> button on the toolbar.   The LED light on the left of the MX Chip should cycle through rainbow lights shortly. It can take upwards of a minute to take effect.

