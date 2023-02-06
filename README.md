# EDAF75 Lab 2:

## Work Log:
### Jacob:
2/5/23:
* Cleaned up initial DB scheme from Sergio 
* Added `lab2-nb.ipynb` file to repo
* Added CSV sample data files (used in DB setup)
* Created this `README.md` file
* Added the .drawio files with our UML diagrams
2/6/23:
* Continued updating DB schema and SQL script
### Sergio:
asdf
### Tom
asdf

## Note:
For testing, we can quickly add data from a .csv 
file instead of using lots of 
```sql
INSERT OR REPLACE
INTO   TABLE(param1, param2, param3)
VALUES ('asdf', 'asdf', 'asdf'),
...
```
in our DB setup .sql scripts 
**BUT the instructions do suggest some manual
statements like that.**
<br> <br>
To do this, I suggest creating the data in Excel,
then saving it as a CSV (comma delimited) file,
and removing the header (first row) in a text
editor.
Now, you can import the data using the following
SQL command with the `$$` variables filled in:
```sqlite3
.mode csv $TABLE_NAME$
.import $FILE_NAME$.csv $TABLE_NAME$
```
To recreate the .sqlite database file, run the following shell command
```
sqlite3 theaters.sqlite < $SQL_SCRIPT$.sql
```

**For submission, rename SQL file and DB file**: <br>
SQL file should be `lab2.sql` and 
DB file should be `movies.sqlite`

## E/R - UML Diagrams
I noticed we forgot to add one attribute to
our `Performance` table: `performance_time`
which is the `DATE` data type. I already
added this to my cleaned up SQL script.

## Foreign Key Referencing
1. When we add data to the `Ticket`, a random UUID is created for `TicketId`. How can we use the same UUIDs in the `Performance` table?