WITH AlertData AS 
(
-- Web Simulator Devices
SELECT
     Stream.DeviceID,
     'Temperature' AS ReadingType,
     Stream.Temperature AS Reading,
     Stream.EventToken AS EventToken,
     Ref.Temperature AS Threshold,
     Ref.TemperatureRuleOutput AS RuleOutput,
     Stream.EventEnqueuedUtcTime AS [time]
FROM IoTStream Stream
JOIN DeviceRulesBlob Ref ON Ref.DeviceType = 'Thermostat'
WHERE
     Stream.EventToken IS NOT NULL AND Stream.Temperature > Ref.Temperature 

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
     (Stream.temp IS NOT NULL) AND ((Stream.temp*1.8)+32) > Ref.Temperature
)

-- Insert data into the "Alerts" Service Bus Queue 
SELECT data.DeviceId,
    data.ReadingType,
    data.Reading,
    data.EventToken,
    data.Threshold,
    data.RuleOutput,
    data.Time
INTO AlertsQueue
FROM AlertData data
WHERE LAG(data.DeviceID) OVER (PARTITION BY data.DeviceId, data.Reading, data.ReadingType LIMIT DURATION(minute, 1)) IS NULL