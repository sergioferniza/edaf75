-- DB_Lab3.sql
-- Written by Jacob Krucinski on 16/02/23
--
-- Attempt 2 for cleaning up database with new structure
--
-- TODO:
-- ** Rename to lab2.sql later
-- Consider switching variables to snake case (as seen in lectures)
-- Consider changing table names to plural (as seen in lecture notes)
--
-- ** NOTE: Constraints below will fail if there is no data in the other tables (referencing a NULL)

-- Init
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS Theater;
DROP TABLE IF EXISTS Performance;
DROP TABLE IF EXISTS Movie;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Customer;

PRAGMA foreign_keys = ON;

-- Create tables
CREATE TABLE Theater
(
    TheaterName     VARCHAR(50) NOT NULL,
    Capacity        INT,

    CONSTRAINT      PK_Theater_TheaterName      PRIMARY KEY(TheaterName)
);

CREATE TABLE Performance
(
    PerformanceHash TEXT DEFAULT (lower(hex(randomblob(16)))),
    PerformanceId   INT,
    StartTime       TIME,
    PerformanceDate DATE,
    TheaterName     VARCHAR(50) NOT NULL,
    IMDBKey         CHAR(9),
    RemainingSeats  INT,

    CONSTRAINT      PK_DateTimeName                     PRIMARY KEY(PerformanceId)

    CONSTRAINT      FK_Performance_Theater_TheaterName  FOREIGN KEY(TheaterName)
    REFERENCES      Theater(TheaterName)

    CONSTRAINT      FK_Performance_Movie_IMDBKey        FOREIGN KEY(IMDBKey)
    REFERENCES      Movie(IMDBKey)
);

CREATE TABLE Movie
(
    IMDBKey         CHAR(9) NOT NULL,
    MovieTitle      VARCHAR(50) NOT NULL,
    ProductionYear  INT,
    RunningTime     INT,

    CONSTRAINT      PK_Movie_MovieTitle                 PRIMARY KEY(IMDBKey)
);

CREATE TABLE Ticket
(
    TicketId        TEXT DEFAULT (lower(hex(randomblob(16)))),
    PerformanceId   INT,
    Username        VARCHAR(50) NOT NULL,

    CONSTRAINT      PK_TicketId                 PRIMARY KEY(TicketId)

    CONSTRAINT      FK_Performance              FOREIGN KEY(PerformanceId)
    REFERENCES      Performance(PerformanceId)

    CONSTRAINT      FK_Ticket_Costumer_Username FOREIGN KEY(Username)
    REFERENCES      Customer(Username)
);

CREATE TABLE Customer
(
    Username        VARCHAR(50) NOT NULL,
    CustomerName    VARCHAR(50) NOT NULL,
    UserPassword    VARCHAR(50) NOT NULL,

    CONSTRAINT      PK_Costumer_Username        PRIMARY KEY(Username)
);


-- ** Order of insertion: MIGHT NOT MATTER IF FOREIGN KEYS DISABLED
-- 1. Customer
-- 2. Theater
-- 3. Movie
-- 4. Performance
-- 5. Ticket

-- CONSTRAINT ON THE NUMBER OF TICKET INSTANCES BASED ON CAPACITY
DROP TRIGGER IF EXISTS Capacity_Reached;
CREATE TRIGGER Capacity_Reached
BEFORE INSERT ON Ticket
WHEN (SELECT RemainingSeats FROM Performance WHERE PerformanceId = NEW.PerformanceId) <= 0
BEGIN
    SELECT RAISE(ROLLBACK, 'I am sorry we have run out of tickets');
END;

-- TRIGGER FOR DECREMENTING REMAINING SEATS FOR A PERFORMANCE
DROP TRIGGER IF EXISTS Decrement_Remaining_Seats;
CREATE TRIGGER Decrement_Remaining_Seats
AFTER INSERT ON Ticket
BEGIN
    UPDATE Performance
    SET    RemainingSeats = RemainingSeats - 1
    WHERE  PerformanceId = NEW.PerformanceId; 
END;

-- Now insert test data from CSV using SQLite3 commands
BEGIN TRANSACTION;

.mode csv Customer
.import SampleData_Customer.csv Customer

.mode csv Theater
.import SampleData_Theater.csv Theater

.mode csv Movie
.import SampleData_Movie.csv Movie

-- NOTE: RemainingSeats is currently hard-coded, see commented out code for a solution (has a bug though)
INSERT OR REPLACE
INTO        Performance(PerformanceId, StartTime, PerformanceDate, TheaterName, IMDBKey, RemainingSeats)
VALUES      (1,"10:00","2023-01-15","Artcraft Theater","tt1630029", 450),
            (2,"13:15","2023-01-01","Artcraft Theater","tt0109830", 450),
            (3,"17:00","2023-01-23","Artcraft Theater","tt0109830", 450),
            (4,"21:20","2023-01-11","Booth Theater","tt0102926", 750),
            (5,"19:10","2022-10-06","Capitol Theater","tt0468569", 900),
            (6,"22:45","2022-10-06","Capitol Theater","tt0468569", 900),
            (7,"19:35","2022-12-16","Cliff Theater","tt0468569", 40),
            (8,"14:00","2022-12-17","Los Angeles Theater","tt0088847", 1000),
            (9,"18:30","2022-12-18","Los Angeles Theater","tt0088847", 1000),
            (10,"18:15","2022-12-19","Paramount Theater","tt0092099", 12),
            (11,"21:20","2022-12-19","Paramount Theater","tt0092099", 12),
            (12,"18:15","2022-12-19","Tower Theater","tt0092099", 1),
            (13,"23:00","2023-02-01","Vista Theater","tt0092099", 72),
            (14,"09:20","2023-02-04","Garneau Theater","tt0876563", 450),
            (15,"19:25","2023-02-04","Royal Cinema","tt0876563", 750),
            (16,"12:30","2049-01-01","Atlantic","tt1856101", 900),
            (17,"21:00","2022-11-06","Astoria","tt0088247", 204),
            (18,"22:20","2022-11-06","Maximteatern","tt0088247", 208),
            (19,"13:30","2022-08-04","Draken","tt4912910", 10);

-- Also initialize remaining seats
-- UPDATE  Performance
-- SET     RemainingSeats = Theater.Capacity
-- WHERE   
--     SELECT      Capacity
--     FROM        Performance
--     LEFT JOIN   Theater
--     USING       (TheaterName);

-- Now fill in performance IDs
INSERT OR   REPLACE
INTO        Ticket(Username, PerformanceId)
VALUES      ("test123",1),
            ("test123",2),
            ("test123",3),
            ("jacob1576",3),
            ("jacob1576",3),
            ("alice2002",4),
            ("jacob1576",5),
            ("brian22",19),
            ("test123",12),
            ("test123",13),
            ("jacob1576",14),
            ("jacob1576",17),
            ("alice2002",15),
            ("jacob1576",16),
            ("brian22",18);

-- REWRITE TO ADD MANUALLY (so that default ticket UUIDs are used)

END TRANSACTION;

--PRAGMA foreign_keys = ON;

-- NOTE: Replace the import commands above with real INSERT commands later
