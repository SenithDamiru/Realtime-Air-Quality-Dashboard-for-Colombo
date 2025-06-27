CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) CHECK (Role IN ('Admin', 'Public')) NOT NULL,
    Status NVARCHAR(10) CHECK (Status IN ('Active', 'Inactive')) NOT NULL DEFAULT 'Active'
);

CREATE TABLE Sensors (
    SensorID INT IDENTITY(1,1) PRIMARY KEY,
    LocationName NVARCHAR(100) NOT NULL,
    Latitude DECIMAL(9,6) NOT NULL,
    Longitude DECIMAL(9,6) NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Active', 'Inactive')) NOT NULL DEFAULT 'Active',
    LastReading DECIMAL(5,2) NULL
);

CREATE TABLE AirQualityData (
    AQIDataID INT IDENTITY(1,1) PRIMARY KEY,
    SensorID INT NOT NULL,
    AQI INT NOT NULL CHECK (AQI BETWEEN 0 AND 500),
    PM25 DECIMAL(5,2) NOT NULL,
    PM10 DECIMAL(5,2) NOT NULL,
    Timestamp DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SensorID) REFERENCES Sensors(SensorID) ON DELETE CASCADE
);

CREATE TABLE Alerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    AQIThreshold INT NOT NULL CHECK (AQIThreshold BETWEEN 0 AND 500),
    AlertMessage NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

EXEC sp_fkeys 'AirQualityData';

INSERT INTO Users (Name, Email, PasswordHash, Role, Status)
VALUES 
('John Doe', 'johndoe@example.com', 'hashed_password_123', 'Admin', 'Active'),
('Jane Smith', 'janesmith@example.com', 'hashed_password_456', 'Public', 'Inactive');

INSERT INTO Sensors (LocationName, Latitude, Longitude, Status, LastReading)
VALUES 
('Colombo - Fort', 6.9355, 79.8489, 'Active', 42.75),
('Kandy - City Center', 7.2906, 80.6336, 'Inactive', NULL);


INSERT INTO AirQualityData (SensorID, AQI, PM25, PM10, Timestamp)
VALUES 
(1, 75, 35.50, 45.20, GETDATE()),  -- Data from SensorID 1 (Colombo - Fort)
(2, 120, 55.80, 68.40, GETDATE()); -- Data from SensorID 2 (Kandy - City Center)

INSERT INTO Alerts (AQIThreshold, AlertMessage) 
VALUES 
(150, 'Unhealthy air quality detected!'),
(200, 'Very unhealthy! Avoid outdoor activities.');


ALTER TABLE Users
WITH CHECK ADD CONSTRAINT CHK_Role CHECK (Role IN ('Environmental Officer', 'Data Analyst', 'Maintenance Staff', 'Admin', 'Public'));

UPDATE Users
SET Role = 'Admin'  -- Replace this with the desired role
WHERE UserID = 3;


ALTER TABLE Users
ALTER COLUMN Role NVARCHAR(50) NOT NULL;



DROP TABLE Alerts;

CREATE TABLE Alerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    AlertType NVARCHAR(50) NOT NULL CHECK (AlertType IN ('High PM2.5', 'High PM10', 'System Malfunction', 'Sensor Offline')),
    AQIThreshold DECIMAL(5,2) NULL,
    Priority NVARCHAR(10) NOT NULL CHECK (Priority IN ('Low', 'Medium', 'High', 'Critical')),
    NotificationMethods NVARCHAR(50) NOT NULL,
    AlertMessage NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

ALTER TABLE Alerts
ADD SensorID INT NULL,
    FOREIGN KEY (SensorID) REFERENCES Sensors(SensorID) ON DELETE CASCADE;


INSERT INTO Alerts (AlertType, AQIThreshold, Priority, NotificationMethods, AlertMessage, SensorID)
VALUES 
('High PM2.5', 100.00, 'High', 'Email,SMS', 'PM2.5 levels exceeded safe limits.', 1);

INSERT INTO Alerts (AlertType, AQIThreshold, Priority, NotificationMethods, AlertMessage, SensorID)
VALUES 
('Sensor Offline', NULL, 'Critical', 'Email', 'Sensor has been offline for more than 30 minutes.', 2);


-- Ensure LastReading column allows NULL initially
ALTER TABLE Sensors 
ALTER COLUMN LastReading DECIMAL(5,2) NULL;

-- Create a trigger to update the LastReading field in Sensors
CREATE TRIGGER trg_UpdateLastReading
ON AirQualityData
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update LastReading in Sensors table with the latest AQI from AirQualityData
    UPDATE Sensors
    SET LastReading = i.AQI
    FROM Sensors s
    INNER JOIN inserted i ON s.SensorID = i.SensorID;
END;


SELECT CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Alerts' AND COLUMN_NAME = 'SensorID';


ALTER TABLE Alerts
DROP CONSTRAINT FK__Alerts__SensorID__4F7CD00D;
ALTER TABLE Alerts
DROP COLUMN SensorID;


ALTER TABLE [AirQualityDB].[dbo].[Alerts]
ADD [Status] VARCHAR(10) DEFAULT 'Active';


UPDATE Alerts
SET Status = 'Active'
WHERE AlertID IN (1, 2, 3);


DROP TABLE IF EXISTS Sensor;





ALTER TABLE Sensors
ADD 
    SensorName NVARCHAR(255) NULL,
    ActivatedAt DATETIME NULL,
    DeactivatedAt DATETIME NULL;


	UPDATE Sensors
SET Status = 'Inactive'
WHERE Status IS NULL;


UPDATE Sensors
SET 
    SensorName = 'Default Sensor ' + CAST(SensorID AS NVARCHAR),
    ActivatedAt = '2024-03-01 10:00:00'
WHERE ActivatedAt IS NULL;


INSERT INTO Sensors (SensorName, LocationName, Latitude, Longitude, Status, LastReading, ActivatedAt, DeactivatedAt)
VALUES
    ('Maharagama Sensor', 'Maharagama', 6.8483, 79.9285, 'Active', NULL, '2024-03-30 08:00:00', NULL),
    ('NSBM Sensor', 'NSBM Green University, Pitipana', 6.8215, 80.0417, 'Active', NULL, '2024-03-30 08:30:00', NULL),
    ('Athurugiriya Sensor', 'Athurugiriya', 6.8798, 79.9721, 'Active', NULL, '2024-03-30 09:00:00', NULL);



	INSERT INTO AirQualityData (SensorID, AQI, PM25, PM10, Timestamp)
VALUES 
(3, 75, 30.5, 60.2, GETDATE()),
(4, 62, 22.8, 45.9, GETDATE()),
(5, 88, 40.3, 75.1, GETDATE()),
(6, 95, 48.9, 82.4, GETDATE());
