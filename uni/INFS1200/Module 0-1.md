---
3/08/20
---

# Summary

Databases contain data which are statistics used for analysis/reference.
A DMBS creates, manages, manipulates and maintains databases.

We use the three-schema architecture:

1. External deals with users accessing the database through DBMS/applications.
2. Conceptual deals with UoD and how the database is laid out.
3. Internal deals with the data storage in the database itself.

```flow
ext=>operation: External
con=>operation: Conceptual
int=>operation: Internal

ext(right)->con(right)->int
```

For entities in ER diagrams:

| Type                  | Description                                                  | Appearance                                              |
| --------------------- | ------------------------------------------------------------ | ------------------------------------------------------- |
| Entity                | Object                                                       | Rectangle, capitals                                     |
| (Simple) Attribute    | Property of an entity                                        | Hollow oval                                             |
| Key                   | Attribute that is unique for every entity in entity set      | Attribute with underlined name                          |
| Composite Attribute   | Attribute composed of several simple attributes              | Attribute with line connecting to simple attributes     |
| Derived Attribute     | Attribute whose value can be derived from other *stored attributes* | Hollow oval with dashed outline                         |
| Multi-value Attribute | Attribute which can contain zero or more values              | Double outline hollow oval                              |
| Entity set            | Set of all entities of an entity type in the database        | Can be mapped to a table; not represented on ER diagram |
| Value set             | Set of values which can be assigned to an attribute          | Not represented on ER diagram                           |
| `null`                | Used when attribute has no value                             | Not represented on ER diagram                           |

For relationships in ER diagrams:

# Module 0: Introduction

## Course Admin

h.khosravi@uq.edu.au
archie.chapman@uq.edu.au

Access videos through Chrome, not Firefox for some reason

Face masks in practicals are *required*, use sanitising wipes

## Databases

Data is just facts and statistics collected for analysis/reference.
When data is used meaningfully to make decisions, it is *information*.

An *information system* has inputs, processes and outputs. Databases hold the data and technology makes everything run.

A database collects organised data which represents some aspect of the world called "universe of discourse" (UoD).
It has meaning (contains *information*) and has a specific purpose with applications.

A *D*ata*b*ase *M*anagement *S*ystem (DBMS) is a software system which does the following to databases:

* defines them
* constructs them (storing it)
* manipulates them (querying, updating)
* maintains them (ensuring efficiency, safety, correctness)

Applications are programs which manipulate the database (via the DBMS).
Users are just people who use the database either through DBMS or through applications.

## Database Design

### Conceptual

1. Identify UoD. We won't be modelling everything
2. Convert UoD to a data model which can be used with a database.

### Minimise Redundancy

| ID   | Name  | Level     |
| ---- | ----- | --------- |
| 1    | Paris | Developer |
| 2    | Anna  | Manager   |
| 3    | Ben   | Manager   |

and..

| ID   | Name  | Salary |
| ---- | ----- | ------ |
| 1    | Paris | $30000 |
| 2    | Anna  | $50000 |
| 3    | Ben   | $50000 |

Information is duplicated and there is redundancy. This is bad.

## DBMS

### Data Integrity Maintenance

The DBMS enforces integrity constraints on data based on its meaning.

For example, employees should have a *unique* id (maybe represented by 4-digit `int`), should work in one department, and their salary should be less than their supervisor's.

### Concurrency Control

DBMS handles concurrent access to data - lots of users can be using the database at the same time.

### Backup, Recovery

DMBS can recover a system to its previous state when a system failure occurs.

## 3-Schema Architecture

1. External level
   - provides access to users
2. Conceptual level
   - describes structure of a database
3. Internal level
   - describes physical storage structure of database.

Want each of these schema to be independent from each other - *data independence*

1. Logical data independence: change *conceptual* without changing *external*.
2. Physical data independence: modify *internal* without changing *conceptual*.

```flow
ext=>operation: External
con=>operation: Conceptual
int=>operation: Internal

ext(right)->con(right)->int
```

# Module 1: Conceptual Data Modelling

A model is never perfect. There will be:

- phenomena not captured in the model
- common phenomena
- phenomena which isn't always true in the real world

## Entity-Relationship (ER) Model

Graphical modelling technique which represents relationships and entities within UoD.

### Entities

An *entity* is an object with physical or conceptual existence.
Each entity has *attributes* which are the properties which describe it.
The same entity will have different attributes/prominence in different UoDs.

In the ER model, the entity type is a rectangular box. Attribute names are ovals attached to the entity type.

A *key* is a uniqueness constraint for an entity type with its name underlined within the oval. They are distinct for every individual entity in the entity set.
Keys must hold for *every* possible extension of the entity type, and multiple keys are allowed.

*Composite attributes* can be sub-divided into smaller *simple attributes* with apparent meaning.
For example, name can be divided into first, middle and last names.
A key can be a composite attribute, so the combination of attribute values will be distinct for each entity.

Simple attributes can be either *single-* or multi-valued. Multi-valued attribtues contain 0 or more values and its oval has double outlines.

In some cases, attribute values can be *derived* from other *stored* attributes. *Derived attributes* are represented by a dotted outline oval.

*Value sets* represent the set of values that may be assigned to an attribute (i.e. attribute value format). These are not displayed on the ER diagram.

An entity may not have a value for an attribute, so we can use the `null` value to indicate this.

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20200803115134484.png" alt="image-20200803115134484" style="zoom: 50%;" />

The collection of all entities of an entity type in the db at any point in time is called an *entity set*.
An entity set can be mapped to a table.

### Relationships

*Relationships* are an association with 2 or more entities. They are represented with a diamond connected to the appropriate entity types (rectangles).
They can have *descriptive attributes* as well as *key attributes*, represented as the same shapes as on the entities (oval, underline).

The *degree* of a relationship is the amount of entities involved. $n$ entities forms an N-ary relationship.

Entities have *roles* in a relationship, written next to the line connecting it to the relationship.
These roles can be recursive - the entities can participate more than once in the same relationship type.

All relationships of a relationship type in the db at a point in time are called a *relationship set*. You can represent them using a diagram or table.

## Relationship Constraints

### Cardinality Ratio

A cardinality ratio specifies how many entities can participate in a relationship.

1. One-to-one (1:1): both entities can only participate in 1 relationship type
2. One-to-many or many-to-one (1:N or N:1): one entity can participate in many relationship instances
3. Many-to-many (M:N): both entities can participate in many relationship instances

For example, an employee works for a department only, but a department contains many employees, so relationship is one-to-many (dept:employee).

This is indicated by writing 1, M or N next to the relationship diamond for each participating entity.

### Participation Types and Existence Dependency

If an entity is *existentially dependent* on another entity, it cannot exist without an associated instance of the related entity.

1. Total participation (existential dependency). Indicated by double line to diamond.
2. Partial participation: not all A is B. Indicated by single line to diamond.

For example, employees can have a license, or they may not have a license. Relationship between employee and license is partial participation - single line. But, you cannot have a license without an associated employee. So, license is *existentially dependent* on employee, and relationship between them is total participation - double line.


