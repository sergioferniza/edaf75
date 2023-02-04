# EDAF75 Lab 2:
## Note:
I think it is best if we add data from a .csv 
file instead of using lots of 
```sql
INSERT OR REPLACE
INTO   TABLE(param1, param2, param3)
VALUES ('asdf', 'asdf', 'asdf'),
...
```
in our DB setup .sql scripts. <br> <br>
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