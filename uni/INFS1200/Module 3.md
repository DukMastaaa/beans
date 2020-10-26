# Module 3: SQL

SQL is a declarative language - you tell it what to do, not how to do. 3 types of statements:

1. Data Definition Language (DDL) - defines db schema
2. Data Manipulation Language (DML) - manipulates data
3. Data Control Language (DCL) - semantic integrity, storage, security, transaction etc

Syntax notation:

`KEYWORD <argument> [optional] {multiple} |choices|`

## DDL

`CREATE TABLE`, `DROP TABLE` and `ALTER TABLE`.

### CREATE TABLE

Creates new relation. Specify relation name, attributes, domains and constraints. Key, entity, ref integrity constraints specified after attributes.

Can specify domain manually or create one with `CREATE DOMAIN`.

Syntax: 

```SQL
CREATE TABLE <tablename> 
 (<colname> <domain> [<attrconstr>]
  {, <colname> <domain> [<attrconstr>]}
  [<tableconstr> {, <tableconstr>}])
```

e.g. Schema `Movie [_movieID, title, year]` is:

```SQL
CREATE TABLE Movie
	(movieID INTEGER, title CHAR(20), year INTEGER,
     PRIMARY KEY (movieID))
```

Relationships: Schema

```
StarsIn [_movieID, _starID, role]
StarsIn.starID -> MovieStar.starID
StarsIn.movieID -> Movie.movieID
```

now:

```SQL
CREATE TABLE StarsIn
	(movieID INTEGER, starID INTEGER, role CHAR(20),
     PRIMARY KEY (movieID, starID),
     FOREIGN KEY (starID) REFERENCES MovieStar(starID),
     FOREIGN KEY (movieID) REFERENCES Movie(movieID))
```

can use `NOT NULL`. Also can explicitly specify constraint: `CONSTRAINT empPK PRIMARY KEY (ssn)`

There is also `UNIQUE` constraint. All `PRIMARY KEY`s automatically have it, but you can only specify one primary key.

Can use `CHECK` for semantic constraints: `CHECK (salary >= 10000 AND salary < 150000)`. These constraints are evaluated during insertion/modification.

For referential integrity, can have `ON DELETE SET NULL | SET DEFAULT | CASCADE` and `ON UPDATE ..`
Self-explanatory.

Other constraints that can't be expressed using `CHECK` or semantic integrity are expressed with `ASSERTION`s.

### ALTER TABLE

Syntax:

```sql
ALTER TABLE <tablename>
	ADD <colname> <domain> [<attrconstr>]
		{, <colname> <domain> [<attrconstr>]}
	| DROP <colname> [CASCADE]
	| ALTER <colname> <coloptions>
	| ADD CONSTRAINT <constrname> <constroptions>
	| DROP CONSTRAINT <constrname> [CASCADE]
```

To alter constraint, drop and add.

e.g. `ALTER TABLE Employee ADD job VARCHAR(12)`. Values will be initially `NULL` so cannot specify `NOT NULL`.
e.g. `ALTER TABLE Employee DROP address`
e.g. `ALTER TABLE Employee DROP CONSTRAINT empPK CASCADE`

### DROP TABLE

Drops all constraints in the table including referencing constraints from other tables.
Deletes all tuples and table definition in system.

`DROP TABLE <tablename> [CASCADE]`

## DML

`SELECT`, `INSERT`, `UPDATE`, `DELETE`.

### INSERT

Adds tuples to an existing relation. For single tuple insert, either: 

1. values are listed in same order as attributes, or
2. specify names of attributes in order which you are inserting values into.

```sql
INSERT INTO <tablename>
	[(<colname>, {, <colname>})]
	(VALUES (<value>, {, <value>}
     | <selectstatement>)
);
```

i.e. include column names after tablename, put values after `VALUES`.

### DELETE

Can delete multiple tuples from one table. Deletion may cascade to other tables depending on referential integrity constraints set with `CREATE/ALTER TABLE`.

```sql
DELETE FROM <tablename>
	[WHERE <condition>];
```

condition like so: `DELETE FROM Employee WHERE dNum = 5;`

### UPDATE

Modifies one or more tuples in one table. This may cascade to other tables because of referential integrity constraints.

```sql
UPDATE <tablename>
	SET <colname> = <value>
	{, <colname> = <value>}
	[WHERE <condition>];
```

e.g. `UPDATE Employee SET salary = salary * 1.1 WHERE name = 

## SELECT

Basic syntax:

```sql
SELECT [DISTINCT] (<attrlist> | *)
FROM <tablelist>
[WHERE <condition>];
```

By default duplicates are included so limit with `DISTINCT`.

`*` is wildcard; includes all columns in table.

e.g. `SELECT DISTINCT Year FROM Movie;`

Can include arithmetic expressions: 
`SELECT name, salary, 1.17 * salary AS 'includingSuper' FROM Employee WHERE dnum = 4`

Condition can be any boolean comparison. Equality is `=` (even for strings).

### Complex WHERE

`LIKE` is used for string matching: `%` is 0 or more chars, `_` is one char. e.g. `WHERE title LIKE '%abc_%'`. Can also be used for int matching by specifying string pattern.

`IN` is like python `string in list` e.g. `WHERE lastName IN ('a', 'b', 'c')`

use `IS` for `NULL` i.e. `WHERE attr IS NULL`

SQL has date and time functions eg. `GETDATE()`, `YEAR()` etc. ]

`BETWEEN` is for numeric values and is <= not <, eg. `WHERE attr BETWEEN 10 AND 30`. Will also work for alphabetical sorting, but alpha sorting will be a <= x < b.

### Sorting

```sql
SELECT [DISTINCT] <targetlist>
FROM <tablelist>
[WHERE [<joincondition> AND] <searchcondition>]
[ORDER BY <col>[ASC|DESC] {, <col>[ASC|DESC]}];
```

`col` can either be a column name, or column position in `targetlist`.
Can sort by multiple columns.

















