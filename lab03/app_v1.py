# app_v1.py
# EDAF75 Lab 3
# Written by Jacob, Sergio, and Tom
#
# This Python scripts starts a REST server that connects with
# the theater database from Lab 2s

# Import packages
from bottle import get, post, run, request, response
from json import dumps
import sqlite3
from tabulate import tabulate
from urllib.parse import unquote
from hashlib import sha256

# Print SQLite3 version
ver = sqlite3.sqlite_version_info
print("Using SQLite Version {}.{}.{}".format(ver[0], ver[1], ver[2]))

# Configure connection information
PORT    = 7007
HOST    = "127.0.0.1"
db      = sqlite3.connect("theaters_v2.sqlite")
db.execute("PRAGMA foreign_keys = 1")
print("Foreign Keys Enabled!\n")

####### Main REST server functions ########
@get('/ping')
def get_ping_pong():
    """
    Return string 'pong' when <host>:<port>/ping is requested
    """
    # Set 200 - OK status
    request.status = 200

    # Return pong string
    return "pong\n"

@post('/reset')
def reset_db():
    """
    Reset the database (remove all entries)
    TODO: Jacob

    Should we do this using transactions??
    """

    # Delete all entries in table (BUT not the table itself), all in one transaction
    c = db.cursor()
    db.execute("PRAGMA foreign_keys = 0")
    c.execute("DELETE FROM Theater")
    c.execute("DELETE FROM Performance")
    c.execute("DELETE FROM Movie")
    c.execute("DELETE FROM Ticket")
    c.execute("DELETE FROM Customer")
    db.commit()
    db.execute("PRAGMA foreign_keys = 1")

    # Populate the Theater table with dummy data, in another transaction
    #c = db.cursor()
    c.execute("""INSERT
                 INTO        Theater(TheaterName, Capacity)
                 VALUES      ("Kino",10),
                             ("Regal",16),
                             ("Skandia",100)
                 RETURNING   TheaterName;
              """)

    # Check if insertions ran correctly
    found = c.fetchall()            # MAKE SURE TO USE FETCHALL, otherwise you will get a 500 error
    #print(found)
    if not found:
        response.status = 400
        return "Theater insertion during reset failed!\n"
    else:
        db.commit()
        response.status = 200
        return "Theater database has been successfully reset!\n"

@post('/users')
def add_customer():
    """
    Add a user to the Customer table (if they don't already exist)
    TODO: Tom
    God is Good

    Raise errors if this happens
    """
    customer_data = request.json
    password_hashed = hash(customer_data['pwd'])
    try:
        c = db.cursor()
        c.execute(
            """
            INSERT
            INTO       Customer(Username, CustomerName, UserPassword)
            VALUES     (?, ?, ?)
            RETURNING Username
            """,
            [customer_data['username'], customer_data['fullName'], password_hashed]
        )

        username = c.fetchone()[0]
        if not username:
            response.status = 400
            return "Error\n"
        else:
            db.commit()
            response.status = 200
            return f"/users/{username}\n"
    except sqlite3.IntegrityError:
        response.status = 400
        return ""

@post('/movies')
def add_movie():
    """
    Add a movie to the Movie table
    TODO: Tom

    Raise errors if this happens
    """
    movie_data = request.json
    try:
        c = db.cursor()
        c.execute(
            """
            INSERT
            INTO       Movie(IMDBKey, MovieTitle, ProductionYear, RunningTime)
            VALUES     (?, ?, ?, ?)
            RETURNING IMDBKey
            """,
            [movie_data['imdbKey'], movie_data['title'], movie_data['year'], 40]
        )

        imdbKey = c.fetchone()[0]
        if not imdbKey:
            response.status = 400
            return "Error\n"
        else:
            db.commit()
            response.status = 201
            return f"/movies/{imdbKey}\n"
    except sqlite3.IntegrityError:
        response.status = 400
        return ""

@get('/movies')
def get_movies():
    """
    Get all movies from the Movie table
    Make sure to edit query based on query strings (e.g. ?name=asdf)
    TODO: Tom

    Returned in JSON format
    """
    movie_data = request.json
    query = """
        SELECT   MovieTitle, ProductionYear, IMDBKey
        FROM     Movie
        WHERE    1 = 1
        """
    params = []
    if request.query.title:
        query += " AND MovieTitle = ?"
        params.append(unquote(request.query.title))
    if request.query.year:
        query += " AND ProductionYear - ?"
        params.append(unquote(request.query.year))
    c = db.cursor()
    c.execute(query, params)
    result = c.fetchall()
    movies_list = [
        {
            "imdbKey": IMDBKey,
            "title": MovieTitle,
            "year": Prod,
        }
        for MovieTitle, Prod, IMDBKey in result
    ]

    response.status = 200
    return dumps({"data": movies_list}, indent=4)

@get('/movies/<imdb_key>')
def get_specific_movie(imdb_key):

    ### RETURN A SPECIFIC MOVIE BASED ON A GIVEN IMDB KEY ###
    c = db.cursor()
    c.execute("""

    SELECT IMDBKey, MovieTitle, ProductionYear
    FROM MOVIE
    WHERE IMDBKEY = ?

    """, (imdb_key,))


    ### OBTAIN RESULTS AND PUT THEM IN A DICTIONARY ###
    result = c.fetchone()
    if result:
        movie_dict = [
            {

            "imdbKey": result[0],
            "MovieTitle": result[1],
            "ProductionYear": result[2]

            }
        ]
    else:
        movie_dict = []
    request.status = 200

    ### RETURN OUR DESIRED RESULT ###
    return dumps({"data": movie_dict}, indent = 4)

@post('/performances')
def add_performance():

    ### ADD TO THE DB A NEW PERFORMANCE ENTRY WITH ALL NECESSARY DATA ###
    performance = request.json
    try:
        c = db.cursor()
        c.execute(
            """

            INSERT INTO Performance(StartTime, PerformanceDate, TheaterName, IMDBKey)
            VALUES      (?, ?, ?, ?)
            RETURNING   PerformanceId

            """, (
                performance["time"],
                performance["date"],
                performance["theater"],
                performance["imdbKey"]
            )
        )

        # Also initialize remaining seats to theater capacity
        phash = c.fetchone()[0]
        if (not phash):
            response.status = 400
            return "Error\n"
        
        c2 = db.cursor()
        c2.execute("""
                   UPDATE Performance
                   SET    RemainingSeats = (SELECT Capacity FROM Theater WHERE TheaterName=?)
                   WHERE  PerformanceId=?
                   """,
                   [performance["theater"], phash])

        db.commit()
        request.status = 201
        return f"/performances/{phash}\n"
    except sqlite3.IntegrityError:
        response.status = 400
        return "No such movie or theater\n"


@get('/performances')
def get_performances():

    ### RETURN THE PERFORMANCE TABLE ###
    c = db.cursor()
    c.execute("""
              SELECT      PerformanceID, PerformanceDate, StartTime, MovieTitle, ProductionYear, TheaterName, RemainingSeats
              FROM        Performance
              LEFT JOIN   Movie
              USING       (IMDBKey)
              """
              )

    ### GETS THE RESULT AND MAKES IT A DICT LIST ###
    result = c.fetchall()
    performance_list = [
        {
            "performanceId": pid,
            "date": date,
            "startTime": time,
            "title": title,
            "year": year,
            "theater": theater, 
            "remainingSeats": rem_seats
        }
        for pid, date, time, title, year, theater, rem_seats in result
    ]

    request.status = 200
    return dumps({"data": performance_list}, indent=4)

@post('/tickets')
def add_ticket():
    """
    Add a ticket to the Ticket table

    TODO: Jacob
    """
    # Get ticket JSON from request
    ticket = request.json

    # Check username and password
    # Extract these fields from JSON
    username = ticket['username']
    password_hashed = hash(ticket['pwd'])
    # Perform a query to get the correct password
    c = db.cursor()
    c.execute("""
              SELECT UserPassword
              FROM Customer
              WHERE username=?
              """,
              [username])
    true_password_hashed = c.fetchone()[0]
    # Check if password is correct
    if (password_hashed != true_password_hashed):
        response.status = 401
        return "Wrong user credentials\n"

    # Now try to add ticket
    try:
        c = db.cursor()
        c.execute(
            """
            INSERT
            INTO       Ticket(Username, PerformanceId)
            VALUES     (?, ?)
            RETURNING  TicketId
            """,
            [ticket['username'], ticket['performanceId']]
        )

        ticket_id = c.fetchone()[0]
        if not ticket_id:
            response.status = 400
            return "Error\n"
        else:
            db.commit()
            response.status = 201
            return f"/tickets/{ticket_id}\n"
    except sqlite3.IntegrityError:
        response.status = 400
        return "No tickets left\n"

@get('/users/<username>/tickets')
def get_users_ticket(username):
    """
    Get all ticket information for a specific user

    TODO: Jacob
    """
    # Get ticket JSON from request

    # Define query and execute
    c = db.cursor()
    c.execute(
        """
        SELECT      PerformanceDate, StartTime, TheaterName, MovieTitle, ProductionYear, count() as nbrOfTickets
        FROM        Ticket
        LEFT JOIN   Customer
        USING       (username)
        LEFT JOIN   Performance
        USING       (PerformanceId)
        LEFT JOIN   Movie
        USING       (IMDBKey)
        WHERE       username=?
        GROUP BY    PerformanceId
        """,
        [username]
    )

    # Add fields to query
    results = [{"date": date,
               "startTime": startTime,
               "theater": theater,
               "title": title,
               "year": year,
               "nbrOfTickets": nbrOfTickets}
               for date, startTime, theater, title, year, nbrOfTickets in c
              ]

    # Set status
    response.status = 200

    # Return query results using dumps() for pretty printing
    return dumps({"data": results}, indent=4)

def hash(msg):
    return sha256(msg.encode('utf-8')).hexdigest()

##### Start running REST server #####
run(host=HOST, port=PORT)
