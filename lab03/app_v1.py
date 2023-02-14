# app_v1.py
# EDAF75 Lab 3
# Written by Jacob, Sergio, and Tom
#
# This Python scripts starts a REST server that connects with
# the theater database from Lab 2s

# Import packages
from bottle import get, post, run, request, response
import sqlite3
from tabulate import tabulate
from urllib.parse import unquote

# Print SQLite3 version
ver = sqlite3.sqlite_version_info
print("Using SQLite Version {}.{}.{}".format(ver[0], ver[1], ver[2]))

# Configure connection information
PORT    = 7007
HOST    = "localhost"
db      = sqlite3.connect("theaters.sqlite")

####### Main REST server functions ########
@get('/ping')
def get_ping_pong():
    """
    Return string 'pong' when <host>:<port>/ping is requested
    """
    # Set 200 - OK status
    request.status = 200

    # Return pong string
    return "pong"

@post('/reset')
def reset_db():
    """
    Reset the database (remove all entries)
    TODO: Jacob

    Should we do this using transactions??
    """
    pass

@post('/users')
def add_customer():
    """
    Add a user to the Customer table (if they don't already exist)

    Raise errors if this happens
    """
    customer_data = request.json
    pass

@post('/movies')
def add_movie():
    """
    Add a movie to the Movie table

    Raise errors if this happens
    """
    movie_data = request.json
    pass

@get('/movies')
def get_movies():
    """
    Get all movies from the Movie table
    Make sure to edit query based on query strings (e.g. ?name=asdf)

    Returned in JSON format
    """
    pass

@get('/movies/<imdb_key>')
def get_specific_movie(imdb_key):
    """
    Get a specific movie from the Movie table based on the IMDB key
    """
    pass

@post('/performances')
def add_performance():
    """
    Add a performance to the Performance table

    Raise errors if this happens
    """
    performance_data = request.json
    pass

@get('/performances')
def get_performances():
    """
    Get all performances from the Performance table
    """
    pass

@post('/tickets')
def add_ticket():
    """
    Add a ticket to the Ticket table
    """
    pass

@get('/users/<username>/tickets')
def get_users_ticket():
    """
    Get all ticket information for a specific user
    """
    pass


##### Start running REST server #####
run(host=HOST, port=PORT)
