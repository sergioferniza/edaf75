-- DB_Lab2_Cleanup.sql
-- Written by Jacob Krucinski on 04/02/23
--
-- Cleanup of original database setup file
--
-- TODO:
-- Consider switching variables to snake case (as seen in lectures)
-- Consider changing table names to plural (as seen in lecture notes)

DROP TABLE IF EXISTS Theater;
CREATE TABLE Theater
(
    TheaterName     VARCHAR(50),
    Capacity        INT,

    CONSTRAINT      PK_Theater_TheaterName PRIMARY KEY(TheaterName),
    CONSTRAINT      UQ_Theater_ThraterName UNIQUE(TheaterName)
);

DROP TABLE IF EXISTS Performance;
CREATE TABLE Performance
(
    StartTime       VARCHAR(50),
    TheaterName     VARCHAR(50) NOT NULL,
    MovieTitle      VARCHAR(50) NOT NULL,
    TicketId        VARCHAR(50) NOT NULL,

    CONSTRAINT      PK_Performance_StartTime             PRIMARY KEY(StartTime),
    CONSTRAINT      UQ_Performance_StartTime             UNIQUE(StartTime),
    CONSTRAINT      FK_Performance_Theater_TheaterName   FOREIGN KEY(TheaterName)
    REFERENCES      Theater(TheaterName),
    CONSTRAINT      FK_Performance_Movie_MovieTitle      FOREIGN KEY(MovieTitle)
    REFERENCES      Movie(MovieTitle),
    CONSTRAINT      FK_Performance_Ticket_TicketId       FOREIGN KEY(TicketId)
    REFERENCES      Ticket(TicketId)
);

DROP TABLE IF EXISTS Movie;
CREATE TABLE Movie
(
    MovieTitle      VARCHAR(50),
    ProductionYear  INT,
    IMDBKey         VARCHAR(50),
    RunningTime     INT,

    CONSTRAINT      PK_Movie_MovieTitle PRIMARY KEY(MovieTitle),
    CONSTRAINT      UQ_Movie_MovieTilte UNIQUE(MovieTitle)
);

DROP TABLE IF EXISTS Ticket;
CREATE TABLE Ticket
(
    TicketId        UUID PRIMARY KEY,
    Username        VARCHAR(50) NOT NULL,

    CONSTRAINT      FK_Ticket_Costumer_Username FOREIGN KEY(Username)
    REFERENCES      Costumer(Username)
);

DROP TABLE IF EXISTS Customer;
CREATE TABLE Customer
(
    Username        VARCHAR(50),
    CustomerName    VARCHAR(50),
    UserPassword    VARCHAR(50),

    CONSTRAINT      PK_Costumer_Username PRIMARY KEY(Username),
    CONSTRAINT      UQ_Costumer_Username UNIQUE(Username)
);

-- Now insert data from CSV using SQLite3 commands
.mode csv Customer
.import SampleData_Customer.csv Customer