-- DB_Lab3_Updated_PerfId.sql
-- Written by Jacob Krucinski on 16/02/23
--
-- Use HASHED PerformanceId for primary key of Performance table
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
    PerformanceId   TEXT DEFAULT (lower(hex(randomblob(16)))),
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
    PerformanceId   TEXT DEFAULT (lower(hex(randomblob(16)))),
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
