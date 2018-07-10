/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost > 0;


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(DISTINCT(name)) FROM Facilities WHERE membercost = 0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance;

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM Facilities
WHERE facid
IN ( 1, 5 ); 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, IF( monthlymaintenance >100,  'expensive',  'cheap' ) AS Label
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT * FROM Members JOIN (SELECT MAX(joindate) AS max_date FROM Members) AS latest ON Members.joindate = latest.max_date;


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT( non_guests.surname,  ' ', non_guests.firstname ) AS Name, tennis_court.name AS Tennis_Court_Name
FROM (

SELECT * 
FROM Members
WHERE surname !=  'GUEST'
) AS non_guests
JOIN Bookings ON non_guests.memid = Bookings.memid
JOIN (

SELECT * 
FROM Facilities
WHERE name LIKE  "Tennis Court %"
) AS tennis_court ON Bookings.facid = tennis_court.facid
ORDER BY Name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name AS Facility_Name, CONCAT( Members.firstname,  ' ', Members.surname ) AS Member_Name, 
CASE WHEN Members.memid =0
THEN Facilities.guestcost *2 * Bookings.slots
ELSE Facilities.membercost * Bookings.slots
END AS Cost
FROM Bookings
JOIN Facilities ON Bookings.facid = Facilities.facid
JOIN Members ON Bookings.memid = Members.memid
WHERE Bookings.starttime LIKE  '2012-09-14%'
HAVING Cost >30
ORDER BY Cost DESC; 

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT Facility_Name, Member_Name, 
CASE WHEN Member_Name LIKE  'GUEST%'
THEN Slot * guestcost *2
ELSE Slot * membercost
END AS Cost
FROM (

SELECT Facilities.name AS Facility_Name, CONCAT( Members.firstname,  ' ', Members.surname ) AS Member_Name, Facilities.membercost, Facilities.guestcost, selected_bookings.slots AS Slot
FROM (

SELECT * 
FROM Bookings
WHERE starttime LIKE  "2012-09-14%"
) AS selected_bookings
JOIN Members ON selected_bookings.memid = Members.memid
JOIN Facilities ON selected_bookings.facid = Facilities.facid
) AS joined
HAVING Cost >30
ORDER BY Cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

ELECT facid, name, (
SUM( Cost ) - monthlymaintenance *12 - initialoutlay
) AS Revenue
FROM (

SELECT Bookings.bookid, Bookings.facid, Facilities.monthlymaintenance, initialoutlay, name, Bookings.Starttime, 
CASE WHEN Bookings.memid =0
THEN Bookings.slots *2 * Facilities.guestcost
ELSE Bookings.slots * Facilities.membercost
END AS Cost
FROM Bookings
JOIN Facilities ON Bookings.facid = Facilities.facid
) AS joined
GROUP BY facid
HAVING Revenue <1000
ORDER BY Revenue;
