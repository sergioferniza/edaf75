CREATE TABLE Theater
(
TheaterName VARCHAR(50) NOT NULL,
Capacity int NOT NULL,

CONSTRAINT PK_Theater_TheaterName PRIMARY KEY(TheaterName),
CONSTRAINT UQ_Theater_ThraterName UNIQUE(TheaterName)
)

CREATE TABLE Performance
(
StartTime VARCHAR(50) NOT NULL,
TheaterName VARCHAR(50) NOT NULL,
MovieTitle VARCHAR(50) NOT NULL,
TicketId VARCHAR(50) NOT NULL,

CONSTRAINT PK_Performance_StartTime PRIMARY KEY(StartTime),
CONSTRAINT UQ_Performance_StartTime UNIQUE(StartTime),
CONSTRAINT FK_Performance_Theater_TheaterName FOREIGN KEY(TheaterName)
REFERENCES Theater(TheaterName),
CONSTRAINT FK_Performance_Movie_MovieTitle FOREIGN KEY(MovieTitle)
REFERENCES Movie(MovieTitle),
CONSTRAINT FK_Performance_Ticket_TicketId FOREIGN KEY(TicketId)
REFERENCES Ticket(TicketId)
)

CREATE TABLE Movie
(
MovieTitle VARCHAR(50) NOT NULL,
ProductionYear int NOT NULL,
IMDBKey VARCHAR(50) NOT NULL,
RunningTime int NOT NULL,

CONSTRAINT PK_Movie_MovieTitle PRIMARY KEY(MovieTitle),
CONSTRAINT UQ_Movie_MovieTilte UNIQUE(MovieTitle)
)

CREATE TABLE Ticket
(
TicketId uuid PRIMARY KEY NOT NULL,
Username VARCHAR(50) NOT NULL,

CONSTRAINT FK_Ticket_Costumer_Username FOREIGN KEY(Username)
REFERENCES Costumer(Username)
)

CREATE TABLE Costumer
(
Username VARCHAR(50) NOT NULL,
CostumerName VARCHAR(50) NOT NULL,
UserPassword VARCHAR(50) NOT NULL,

CONSTRAINT PK_Costumer_Username PRIMARY KEY(Username),
CONSTRAINT UQ_Costumer_Username UNIQUE(Username)
)
