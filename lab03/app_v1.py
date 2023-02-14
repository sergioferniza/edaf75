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
    # Set 200 - OK status
    request.status = 200

    # Return pong string
    return "pong"

# Start running REST server
run(host=HOST, port=PORT)
