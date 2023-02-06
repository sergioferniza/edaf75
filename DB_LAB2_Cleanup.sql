-- DB_Lab2_Cleanup.sql
-- Written by Jacob Krucinski on 04/02/23
--
-- Cleanup of original database setup file
--
-- TODO:
-- ** Rename to lab2.sql later
-- Consider switching variables to snake case (as seen in lectures)
-- Consider changing table names to plural (as seen in lecture notes)

-- Init
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS Theater;
DROP TABLE IF EXISTS Performance;
DROP TABLE IF EXISTS Movie;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Customer;

--PRAGMA foreign_keys = ON;

-- Create tables
CREATE TABLE Theater
(
    TheaterName     VARCHAR(50),
    Capacity        INT,

    CONSTRAINT      PK_Theater_TheaterName      PRIMARY KEY(TheaterName)
);

CREATE TABLE Performance
(
    StartTime       TIME,
    PerformanceDate DATE,
    TheaterName     VARCHAR(50) NOT NULL,
    MovieTitle      VARCHAR(50) NOT NULL,

    CONSTRAINT      PK_DateTimeName             PRIMARY KEY(StartTime, PerformanceDate, TheaterName)
    -- ** NOTE: Constraints below will fail if there is no data in the other tables (referencing a NULL)

    -- CONSTRAINT      FK_Performance_Theater_TheaterName   FOREIGN KEY(TheaterName)
    -- REFERENCES      Theater(TheaterName)
    CONSTRAINT      FK_Performance_Movie_MovieTitle      FOREIGN KEY(MovieTitle)
    REFERENCES      Movie(MovieTitle)
    -- CONSTRAINT      FK_Performance_Ticket_TicketId       FOREIGN KEY(TicketId)
    -- REFERENCES      Ticket(TicketId)
);

CREATE TABLE Movie
(
    MovieTitle      VARCHAR(50),
    ProductionYear  INT,
    IMDBKey         CHAR(9),
    RunningTime     INT,

    CONSTRAINT      PK_Movie_MovieTitle         PRIMARY KEY(MovieTitle)
);

CREATE TABLE Ticket
(
    TicketId        TEXT DEFAULT (lower(hex(randomblob(16)))),
    Username        VARCHAR(50) NOT NULL,
    StartTime       TIME,
    PerformanceDate DATE,
    TheaterName     VARCHAR(50) NOT NULL,

    CONSTRAINT      FK_Ticket_Costumer_Username FOREIGN KEY(Username)
    REFERENCES      Costumer(Username)
    -- Need to define foreign keys in tuples IF defined as tuples for primary key in another table
    CONSTRAINT      FK_Performance              FOREIGN KEY(StartTime, PerformanceDate, TheaterName)
    REFERENCES      Performance(StartTime, PerformanceDate, TheaterName)
);

CREATE TABLE Customer
(
    Username        VARCHAR(50),
    CustomerName    VARCHAR(50),
    UserPassword    VARCHAR(50),

    CONSTRAINT      PK_Costumer_Username        PRIMARY KEY(Username)
);


-- ** Order of insertion: MIGHT NOT MATTER IF FOREIGN KEYS DISABLED
-- 1. Customer
-- 2. Theater
-- 3. Movie
-- 4. Performance
-- 5. Ticket


-- Now insert test data from CSV using SQLite3 commands
BEGIN TRANSACTION;

.mode csv Customer
.import SampleData_Customer.csv Customer

.mode csv Movie
.import SampleData_Movie.csv Movie

-- .mode csv Performance
-- .import SampleData_Performance.csv Performance

INSERT OR   REPLACE
INTO        Performance(StartTime, PerformanceDate, TheaterName, MovieTitle)
VALUES      ("10:00","2023-01-15","Artcraft Theater","Avatar: The Way of Water"),
            ("13:15","2023-01-01","Artcraft Theater","Forrest Gump"),
            ("17:00","2023-01-23","Artcraft Theater","Forrest Gump"),
            ("21:20","2023-01-11","Booth Theater","Silence of the Lambs"),
            ("19:10","2022-10-06","Capitol Theater","The Dark Night"),
            ("22:45","2022-10-06","Capitol Theater","The Dark Night"),
            ("19:35","2022-12-16","Cliff Theater","The Dark Night"),
            ("14:00","2022-12-17","Los Angeles Theater","The Breakfast Club"),
            ("18:30","2022-12-18","Los Angeles Theater","The Breakfast Club"),
            ("18:15","2022-12-19","Paramount Theater","Top Gun"),
            ("21:20","2022-12-19","Paramount Theater","Top Gun"),
            ("18:15","2022-12-19","Tower Theater","Top Gun"),
            ("23:00","2023-02-01","Vista Theater","Top Gun"),
            ("09:20","2023-02-04","Garneau Theater","Ponyo"),
            ("19:25","2023-02-04","Royal Cinema","Ponyo"),
            ("12:30","2049-01-01","Atlantic","Blade Runner 2049"),
            ("21:00","2022-11-06","Astoria","The Terminator"),
            ("22:20","2022-11-06","Maximteatern","The Terminator"),
            ("13:30","2022-08-04","Draken","Mission Impossible - Fallout");


END TRANSACTION;
-- PRAGMA foreign_keys = ON;

-- NOTE: Replace the import commands above with real INSERT commands later