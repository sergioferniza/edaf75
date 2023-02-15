-- DB_Lab2_Cleanup_v2.sql
-- Written by Jacob Krucinski on 07/02/23
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
    PerformanceId   INT,
    StartTime       TIME,
    PerformanceDate DATE,
    TheaterName     VARCHAR(50) NOT NULL,
    IMDBKey         CHAR(9),

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
AFTER INSERT ON Ticket
WHEN (SELECT COUNT() FROM Ticket WHERE PerformanceId = NEW.PerformanceId) > (SELECT Capacity FROM Theater WHERE TheaterName = (SELECT TheaterName FROM Performance WHERE PerformanceId = NEW.PerformanceId))
BEGIN
    SELECT RAISE(ROLLBaCK, 'I am sorry we have run out of tickets');
END;



-- Now insert test data from CSV using SQLite3 commands
BEGIN TRANSACTION;

.mode csv Customer
.import SampleData_Customer.csv Customer

.mode csv Theater
.import SampleData_Theater.csv Theater

.mode csv Movie
.import SampleData_Movie.csv Movie

-- .mode csv Performance
-- .import SampleData_Performance.csv Performance
INSERT OR   REPLACE
INTO        Performance(PerformanceId, StartTime, PerformanceDate, TheaterName, IMDBKey)
VALUES      (1,"10:00","2023-01-15","Artcraft Theater","tt1630029"),
            (2,"13:15","2023-01-01","Artcraft Theater","tt0109830"),
            (3,"17:00","2023-01-23","Artcraft Theater","tt0109830"),
            (4,"21:20","2023-01-11","Booth Theater","tt0102926"),
            (5,"19:10","2022-10-06","Capitol Theater","tt0468569"),
            (6,"22:45","2022-10-06","Capitol Theater","tt0468569"),
            (7,"19:35","2022-12-16","Cliff Theater","tt0468569"),
            (8,"14:00","2022-12-17","Los Angeles Theater","tt0088847"),
            (9,"18:30","2022-12-18","Los Angeles Theater","tt0088847"),
            (10,"18:15","2022-12-19","Paramount Theater","tt0092099"),
            (11,"21:20","2022-12-19","Paramount Theater","tt0092099"),
            (12,"18:15","2022-12-19","Tower Theater","tt0092099"),
            (13,"23:00","2023-02-01","Vista Theater","tt0092099"),
            (14,"09:20","2023-02-04","Garneau Theater","tt0876563"),
            (15,"19:25","2023-02-04","Royal Cinema","tt0876563"),
            (16,"12:30","2049-01-01[","Atlantic","tt1856101"),
            (17,"21:00","2022-11-06","Astoria","tt0088247"),
            (18,"22:20","2022-11-06","Maximteatern","tt0088247"),
            (19,"13:30","2022-08-04","Draken","tt4912910");

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
