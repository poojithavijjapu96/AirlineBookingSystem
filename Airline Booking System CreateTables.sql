# create schema
CREATE SCHEMA IrisAirlinesFlightBookingSystem_db;

USE IrisAirlinesFlightBookingSystem_db;

CREATE TABLE Airport (
    AirportID INT NOT NULL,
    AirportName VARCHAR(50),
    AirportCity VARCHAR(50),
    AirportState VARCHAR(50),
    AirportCountry VARCHAR(50),
    AirportType VARCHAR(20),
    AirportCode CHAR(3) UNIQUE NOT NULL,
    CONSTRAINT PRIMARY KEY (AirportID)
);

CREATE TABLE Crew (
    CrewID INT NOT NULL,
    CrewNameFirst VARCHAR(50) NOT NULL,
    CrewNameMiddleInitial VARCHAR(50),
    CrewNameLast VARCHAR(50) NOT NULL,
    CrewPhone CHAR(12) NOT NULL,
    CrewEmail VARCHAR(50) NOT NULL,
    CrewAddressStreetLine1 VARCHAR(50) NOT NULL,
    CrewAddressStreetLine2 VARCHAR(50),
    CrewAddressCity VARCHAR(50) NOT NULL,
    CrewAddressState VARCHAR(50) NOT NULL,
    CrewAddressZipCode VARCHAR(50) NOT NULL,
    CrewAddressCountry VARCHAR(50) NOT NULL,
    CrewDateHired DATE NOT NULL,
    CrewDateOfBirth DATE NOT NULL,
    CrewJobType VARCHAR(50) NOT NULL CHECK (CrewJobType IN ('Pilot' , 'Steward')),
    CONSTRAINT Crew_PK PRIMARY KEY (CrewID)
);

CREATE TABLE Crew_Language (
    CrewID INT NOT NULL,
    CrewLanguage VARCHAR(50) NOT NULL,
    CONSTRAINT CrewLanguage_Pk PRIMARY KEY (CrewID , CrewLanguage),
    CONSTRAINT Crewlanguage_FK FOREIGN KEY (CrewID)
        REFERENCES Crew (CrewID)
);
   
CREATE TABLE Airplane (
    AirplaneID INT NOT NULL,
    AirplaneModel VARCHAR(10) NOT NULL,
    AirplaneManufacturedBy VARCHAR(50) NOT NULL,
    AirplanePassengerCapacity INT,
    AirplaneSeatConfiguration VARCHAR(12),
    AirplaneYearManufactured YEAR,
    AirplaneStatus VARCHAR(10) NOT NULL CHECK (AirplaneStatus IN ('Active' , 'Inactive', 'Discarded')),
    CONSTRAINT Airplane_PK PRIMARY KEY (AirplaneID)
);

CREATE TABLE Airplane_Class (
    AirplaneID INT NOT NULL,
    AirplaneClass VARCHAR(15) NOT NULL CHECK (AirplaneClass IN ('Economy' , 'Premium Economy', 'Business', 'First')),
    CONSTRAINT AirplaneClass_PK PRIMARY KEY (AirplaneID , AirplaneClass),
    CONSTRAINT AirplaneClass_FK FOREIGN KEY (AirplaneID)
        REFERENCES Airplane (AirplaneID)
);
    
CREATE TABLE Flight (
    FlightID INT NOT NULL,
    FlightCode CHAR(6),
    FlightDepartureDateTime TIMESTAMP,
    FlightDepartureTimeZone CHAR(6),
    FlightArrivalDateTime TIMESTAMP,
    FlightArrivalTimeZone CHAR(6),
    FlightStatus VARCHAR(9) CHECK (FlightStatus IN ('Scheduled' , 'Canceled', 'Completed')),
    FlightType BOOLEAN,
    AirplaneID INT NOT NULL,
    CONSTRAINT Flight_PK PRIMARY KEY (FlightID),
    CONSTRAINT AirplaneID_FK FOREIGN KEY (AirplaneID)
        REFERENCES Airplane (AirplaneID)
);
    
CREATE TABLE Flight_Schedule (
    FlightID INT NOT NULL,
    AirportID INT NOT NULL,
    FlightScheduleType BOOLEAN NOT NULL,
    CONSTRAINT FlightSchedule_PK PRIMARY KEY (FlightID , AirportID),
    CONSTRAINT FlightID_FK FOREIGN KEY (FlightID)
        REFERENCES Flight (FlightID),
    CONSTRAINT AirportID_FK FOREIGN KEY (AirportID)
        REFERENCES Airport (AirportID)
);
    
CREATE TABLE Crew_Schedule (
    CrewID INT NOT NULL,
    FlightID INT NOT NULL,
    CONSTRAINT CrewSchedule_Pk PRIMARY KEY (CrewID , FlightID),
    CONSTRAINT CrewID_FK FOREIGN KEY (CrewID)
        REFERENCES Crew (CrewID),
    CONSTRAINT CrewFlightID_FK FOREIGN KEY (FlightID)
        REFERENCES Flight (FlightID)
);

CREATE TABLE Passenger (
    PassengerID INT NOT NULL,
    PassengerNameFirst VARCHAR(25),
    PassengerNameMiddleInitial VARCHAR(25),
    PassengerNameLast VARCHAR(25),
    PassengerDOB DATE,
    PassengerGender VARCHAR(6),
    PassengerAddressStreetline1 VARCHAR(50),
    PassengerAddressStreetline2 VARCHAR(50),
    PassengerAddressCity VARCHAR(50),
    PassengerAddressState VARCHAR(50),
    PassengerAddressCountry VARCHAR(50),
    PassengerAddressZipcode VARCHAR(50),
    PassengerPhone VARCHAR(13),
    PassengerEmail VARCHAR(50),
    PassengerMembership VARCHAR(10),
    CONSTRAINT PRIMARY KEY (PassengerID)
);

CREATE TABLE Payment (
    PaymentID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentAmount DECIMAL(6 , 2 ) NOT NULL,
    PaymentMethod VARCHAR(10) NOT NULL CHECK (PaymentMethod IN ('CreditCard' , 'Paypal', 'ApplePay', 'Klarna', 'Affirm')),
    PaymentCreditCardCompany VARCHAR(50),
    PaymentCreditCardFirstName VARCHAR(50),
    PaymentCreditCardLastName VARCHAR(50),
    PaymentCreditCardNumber CHAR(20),
    PaymentCreditCardSecCode CHAR(3),
    PaymentCreditCardExpirationDate CHAR(5),
    PaymentCreditcardZipCode VARCHAR(10),
    CONSTRAINT Payment_PK PRIMARY KEY (PaymentID)
);
  
CREATE TABLE Ticket (
    TicketID VARCHAR(6) NOT NULL PRIMARY KEY,
    PassengerID INT NOT NULL,
    PaymentID INT NOT NULL,
    TicketDepartureAirport VARCHAR(10) NOT NULL,
    TicketArrivalAirport VARCHAR(10) NOT NULL,
    TicketLayoverTime INT,
    TicketType VARCHAR(10) NOT NULL,
    CONSTRAINT PassengerID_fk FOREIGN KEY (PassengerID)
        REFERENCES Passenger (PassengerID),
    CONSTRAINT PaymentID_fk FOREIGN KEY (PaymentID)
        REFERENCES Payment (PaymentID)
);
  
CREATE TABLE Trip (
    TripID VARCHAR(6) NOT NULL PRIMARY KEY,
    TicketID VARCHAR(6) NOT NULL,
    FlightID INT NOT NULL,
    TripSeatID VARCHAR(4) NOT NULL,
    TripClass VARCHAR(15) NOT NULL,
    TripCost DECIMAL(6 , 2 ),
    TripDuration INT,
    TripPurpose VARCHAR(50),
    CONSTRAINT TicketID_fk FOREIGN KEY (TicketID)
        REFERENCES Ticket (TicketID),
    CONSTRAINT TripFlightID_fk FOREIGN KEY (FlightID)
        REFERENCES Flight (FlightID)
);  


