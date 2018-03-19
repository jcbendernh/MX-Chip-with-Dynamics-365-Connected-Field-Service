WITH TelemetryData AS 
(

-- Web Simulator Devices
SELECT
     Stream.DeviceId,
     'Temperature' AS ReadingType,
     Stream.Temperature AS Reading,
     Stream.EventToken AS EventToken,
     Ref.Temperature AS Threshold,
     Ref.TemperatureRuleOutput AS RuleOutput,
     Stream.EventEnqueuedUtcTime AS [time]
FROM IoTStream Stream
JOIN DeviceRulesBlob Ref ON Ref.DeviceType = 'Thermostat'
WHERE
     (Stream.EventToken IS NOT NULL )and (Stream.Temperature IS NOT NULL)

UNION

-- MX Chip with IoT Central Firmware Update
SELECT
     GetMetadataPropertyValue(Stream, 'IoTHub.ConnectionDeviceId') AS DeviceID,
     'Temperature' AS ReadingType,
	 ((Stream.temp*1.8)+32) as Reading,
	 GetMetadataPropertyValue(Stream, 'EventId') AS EventToken,
     Ref.Temperature AS Threshold,
     Ref.TemperatureRuleOutput AS RuleOutput,
     Stream.EventEnqueuedUtcTime AS [time]
FROM IoTStream Stream
JOIN DeviceRulesBlob Ref ON Ref.DeviceType = 'Thermostat'
WHERE
     Stream.temp IS NOT NULL

),

-- Aggregate Data
MaxInMinute AS
(
SELECT
    TopOne() OVER (ORDER BY Reading DESC) AS telemetryEvent
FROM
    TelemetryData 
WHERE 
	DeviceId IS NOT NULL
GROUP BY 
    DeviceId, TumblingWindow(minute, 1)
)

-- Insert into the Power BI SQL Dataset
SELECT telemetryEvent.DeviceId,
    telemetryEvent.ReadingType,
    telemetryEvent.Reading,
    telemetryEvent.EventToken,
    telemetryEvent.Threshold,
    telemetryEvent.RuleOutput,
    telemetryEvent.Time
INTO PowerBISQL
FROM MaxInMinute