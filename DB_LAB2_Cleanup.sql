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
    REFERENCES      Customer(Username)
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

.mode csv Ticket
.import SampleData_Ticket.csv Ticket

.mode csv Theater
.import SampleData_Theater.csv Theater

.mode csv Customer
.import SampleData_Customer.csv Customer

.mode csv Movie
.import SampleData_Movie.csv Movie



-- .mode csv Performance
-- .import SampleData_Performance.csv Performance

INSERT OR   REPLACE
INTO        Performance(StartTime, PerformanceDate, TheaterName, MovieTitle)
VALUES      ("10:00","2022-12-10","Artcraft Theater","Avatar: The Way of Water");

END TRANSACTION;
-- PRAGMA foreign_keys = ON;

-- NOTE: Replace the import commands above with real INSERT commands later
