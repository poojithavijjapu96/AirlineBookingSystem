USE IrisAirlinesFlightBookingSystem_db;

# create table to log flight delays
CREATE TABLE Flight_Delay (
    FlightDelayID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    FlightID INT NOT NULL,
    FlightCode CHAR(6),
    OldDateTime TIMESTAMP,
    NewDateTime TIMESTAMP,
    FlightType BOOLEAN,
    FlightScheduleType VARCHAR(10),
    UpdateDate DATE
);

# create trigger to log Flight delays - departures and arrivals
# trigger started when update made to either departure time, arrival time, or both in Flight table
DELIMITER $$
	CREATE TRIGGER Flight_DateTime_Update
	AFTER UPDATE ON Flight
	FOR EACH ROW BEGIN
		IF (Old.FlightDepartureDateTime <> New.FlightDepartureDateTime)  THEN 
		 INSERT INTO Flight_Delay(FlightID,FlightCode, OldDateTime, NewDateTime,FlightType, FlightScheduleType, UpdateDate) 
			VALUES (OLD.FlightID, Old.FlightCode, Old.FlightDepartureDateTime, New.FlightDepartureDateTime, Old.FlightType, 'Departure',SYSDATE()); END IF;
		IF (Old.FlightArrivalDateTime <> New.FlightArrivalDateTime) THEN
		INSERT INTO Flight_Delay(FlightID,FlightCode, OldDateTime, NewDateTime, FlightType, FlightScheduleType, UpdateDate)
		 VALUES (Old.FlightID, Old.FlightCode, Old.FlightArrivalDateTime, New.FlightArrivalDateTime, Old.FlightType, 'Arrival',SYSDATE()); END IF;
	END $$
DELIMITER ;

# update Flight datetime values
UPDATE Flight 
SET 
    FlightDepartureDateTime = '2022-01-18 13:17:21',
    FlightArrivalDateTime = '2022-01-19 23:10:54'
WHERE
    FlightID = 6;

UPDATE Flight 
SET 
    FlightDepartureDateTime = '2022-01-27 20:22:49',
    FlightArrivalDateTime = '2022-01-28 01:12:49'
WHERE
    FlightID = 8;

UPDATE Flight 
SET 
    FlightDepartureDateTime = '2022-01-28 19:56:54'
WHERE
    FlightID = 9;

UPDATE Flight 
SET 
    FlightDepartureDateTime = '2022-02-17 07:50:34'
WHERE
    FlightID = 13;

UPDATE Flight 
SET 
    FlightArrivalDateTime = '2022-07-29 07:30:18'
WHERE
    FlightID = 20;

# Show average difference in datetime values
SELECT 
    AVG(DifferenceDateTimeMin)
FROM
    (SELECT 
        ABS(TIMESTAMPDIFF(MINUTE, OldDateTime, NewDateTime)) AS DifferenceDateTimeMin
    FROM
        Flight_Delay
    WHERE
        FlightType = 1
            AND YEAR(OldDateTime) = '2022') AS InternationalDelayTime;
 
# show count of delayed flights by flight schedule type (departure/arrival) 
SELECT 
    FlightScheduleType, COUNT(FlightDelayID)
FROM
    Flight_Delay
WHERE
    YEAR(OldDateTime) = '2022'
GROUP BY FlightScheduleType;

# show count of delayed flights by airport name
SELECT 
    AirportName, COUNT(FlightDelayID)
FROM
    Flight_Delay
        INNER JOIN
    Flight_Schedule ON Flight_Delay.FlightID = Flight_Schedule.FlightID
        INNER JOIN
    Airport ON Flight_Schedule.AirportID = Airport.AirportID
WHERE
    YEAR(OldDateTime) = '2022'
GROUP BY AirportName
ORDER BY COUNT(FlightDelayID) DESC;


#Creating a FlightSchedule view using a self join in order to get a Departure Airport ID and an Arrival Airport ID
CREATE VIEW FlightScheduleView AS
    (SELECT 
        FS1.FlightID,
        FS1.AirportID AS DepartureAirportID,
        FS2.AirportID AS ArrivalAirportID
    FROM
        Flight_Schedule FS1,
        Flight_Schedule FS2
    WHERE
        FS1.FlightID = FS2.FlightID
            AND FS1.AirportID != FS2.AirportID
            AND FS1.FlightScheduleType = 0
            AND FS2.FlightScheduleType = 1);

#Using FlightSchedule View and adding Depature and Arrival Airport Cities and DateTime fields
CREATE VIEW FlightSchedulewithAirportCity AS
    (SELECT 
        F.FlightID,
        FlightDepartureDateTime,
        DepartureAirportID,
        A1.AirportCity AS DepartureAirportCity,
        FlightArrivalDateTime,
        ArrivalAirportID,
        A2.AirportCity AS ArrivalAirportCity
    FROM
        FlightScheduleView F
            JOIN
        Airport A1 ON F.DepartureAirportID = A1.AirportID
            JOIN
        Airport A2 ON F.ArrivalAirportID = A2.AirportID
            JOIN
        Flight ON F.FlightID = Flight.FlightID);

#Using FlightSchedulewithAirportCity view for question 2 and 3


# The Iris Airline collects about 20% taxes along with the trip fares. 
# The accountant wants to verify if this true.
# Solution : Calculate sum of trip costs, add 20% takes and verify if the difference between it and Payment amount is less than 3%

#Creating View with approximate calculations
CREATE VIEW Amount AS
    SELECT 
        Ticket.TicketID,
        SUM(TripCost) AS TicketCost,
        ROUND((SUM(TripCost) + 0.2 * SUM(TripCost)), 2) AS TicketCostwithApproxTax
    FROM
        Trip,
        Ticket
    WHERE
        Trip.TicketID = Ticket.TicketID
    GROUP BY TicketID;
    
#Calculating and displaying the Verification Status
SELECT 
    T.TicketID,
    T.PaymentID,
    TicketCostwithApproxTax,
    PaymentAmount,
    CASE
        WHEN ((ABS(PaymentAmount - TicketCostwithApproxTax)) / PaymentAmount) < 0.05 THEN 'accepted'
        ELSE 'not accepted'
    END AS VerifyStatus
FROM
    Amount A,
    Payment P,
    Ticket T
WHERE
    A.TicketID = T.TicketID
        AND P.PaymentID = T.PaymentID;

#Iris Airlines has been informed that a passenger who travelled from San Francisco to LA on March 1st 2022 with a possibly deadly infection.  
#The airline wants list of all the passengers and crew who travelled from SFO to LA on this date.
#Details regarding their flight and contact are expected. 
SELECT 
    P.PassengerID,
    PassengerNameFirst,
    PassengerNameMiddleInitial,
    PassengerNameLast,
    PassengerAddressStreetline1,
    PassengerAddressStreetline2,
    PassengerAddressCity,
    PassengerAddressState,
    PassengerAddressCountry,
    PassengerAddressZipcode,
    PassengerPhone,
    PassengerEmail
FROM
    Passenger P,
    Ticket,
    Trip
WHERE
    Trip.TicketID = Ticket.TicketID
        AND Ticket.PassengerID = P.PassengerID
        AND FlightID = (SELECT 
            FlightID
        FROM
            FlightSchedulewithAirportCity
        WHERE
            DepartureAirportCity = 'San Francisco'
                AND ArrivalAirportCity = 'Los Angeles'
                AND DATE(FlightDepartureDateTime) = '2022-01-03');


# Longest and shortest Flights

#Extracting offset from the timedate field
CREATE VIEW CalculatingTime AS
    (SELECT 
        FlightID,
        FlightDepartureDateTime,
        FlightDepartureTimeZone,
        FlightArrivalDateTime,
        FlightArrivalTimeZone,
        SUBSTRING(FlightDepartureTimeZone, 4, 2) + ':00' AS OffsettimeDeparture,
        SUBSTRING(FlightArrivalTimeZone, 4, 2) + ':00' AS OffsettimeArrival
    FROM
        Flight);

#Calculating time difference including time zone difference
CREATE VIEW FlightDurations AS
    (SELECT 
        FlightID,
        ABS(TIMESTAMPDIFF(MINUTE,
                    CONVERT_TZ(FlightDepartureDateTime,
                            '+00:00',
                            OffsettimeDeparture),
                    CONVERT_TZ(FlightArrivalDateTime,
                            '+00:00',
                            OffsettimeDeparture))) AS Duration
    FROM
        CalculatingTime);

#Details of shortest flight
SELECT 
    Duration,
    FD.FlightID,
    DepartureAirportCity,
    ArrivalAirportCity
FROM
    FlightDurations FD,
    FlightSchedulewithAirportCity FSA
WHERE
    FD.FlightID = FSA.FlightID
        AND Duration = (SELECT 
            MIN(Duration)
        FROM
            FlightDurations);

# details of longest flight
SELECT 
    Duration,
    FD.FlightID,
    DepartureAirportCity,
    ArrivalAirportCity
FROM
    FlightDurations FD,
    FlightSchedulewithAirportCity FSA
WHERE
    FD.FlightID = FSA.FlightID
        AND Duration = (SELECT 
            MIN(Duration)
        FROM
            FlightDurations);



#Iris Airline wants to identify its most frequent route so that it can dedicate more airplanes for that route.
SELECT 
    FlightCode,
    DepartureAirportCity,
    ArrivalAirportCity,
    COUNT(FlightCode)
FROM
    Flight,
    FlightSchedulewithAirportCity
WHERE
    Flight.FlightID = FlightSchedulewithAirportCity.FlightID
GROUP BY FlightCode
ORDER BY COUNT(FlightCode) DESC;

# The airline wants to give loyalty points and wants a list of passengers who travelled for more than 40 hours (2400 minutes) in 2022
SELECT 
    Passenger.PassengerID,
    PassengerNameFirst AS FirstName,
    PassengerNameLast AS LastName,
    PassengerPhone AS Phone,
    PassengerEmail AS Email,
    FlightDepartureDateTime,
    SUM(TripDuration)
FROM
    Passenger,
    Trip,
    Ticket,
    Flight
WHERE
    Passenger.PassengerID = Ticket.PassengerID
        AND Ticket.TicketID = Trip.TicketID
        AND Flight.FlightID = Trip.FlightiD
GROUP BY PassengerID
HAVING SUM(TripDuration) > 2400;
