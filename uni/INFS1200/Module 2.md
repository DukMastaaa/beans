# Module 2: Relational Model

## Relations

| ID   | Name | Salary | Department |
| ---- | ---- | ------ | ---------- |
| 1    | h    | 22     | h dept     |
| 2    | g    | 11     | g dept     |

Domain: set of atomic values (indivisible). Like the "data type" of an attribute. e.g. domain of ID is integers, domain of department is variable length string

Number of attributes in relation is called its *degree*.

Cannot determine anything between two attributes based on their domains or name.

A $n$-*tuple* is an ordered list of $n$ values, where each value is an element of the corresponding domain of the attribute, or `null`.

A *relation schema* includes relation name and list of attributes $R(A_1, A_2, A_3, ..., A_n)$. For example, a relation schema of degree 4 is `Student(name, age, id, address)`.

Relation schema written Relation [<u>key</u>, attribute, attribute].

A *relation instance* of the relation schema `R`, denoted by `r(R)`, is a set of n-tuples where each tuple contains the values of attributes of `R`.

Tuples are ordered, but the order doesn't matter as long as the link between attribute and value is maintained.

## Constraints

A *superkey* is a subset of attributes of a relation schema such that all values of those attributes are unique for all tuplles in the schema.

A *key* is a minimal superkey, i.e. every subset of the key is no longer a superkey (smallest set of attributes which uniquely identify a tuple). A schema may have more than 1 key - all of them are called *candidate keys* and we select one as the *primary key*, whose name is underlined.

We can use *foreign keys* to relate two different schema:

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20200817160328700.png" alt="image-20200817160328700" style="zoom:50%;" />

If we have a set of attributes $FK$ in R1 and primary attributes $PK$ of R2, $FK$ is a foreign key referencing $PK$ of R2 if:

1. $FK$ and $PK$ have the same domain
2. For any tuple $t_1$ in R1, either $FK$'s value is `null` or $\exists$ a tuple $t_2$ in R2 such that $t_1[FK] = t_2[PK]$.

We write `Schema1.foreign references Schema2.primary` as an example.
A relation can also reference itself, e.g. `Schema1.foreign references Schema1.primary`.

**Domain constraint**: every attribute in a relation must belong to some domain

**Uniqueness constraint**: all tuples in a relation must be distinct

**Key constraint**: keys always must remain unique

**Entity Integrity constraint**: no primary key can be `null`. For composite primary keys, no part can be `null`.

**Referential Integrity constraint**: a foreign key cannot reference another tuple that does not exist from another schema based on its primary key

*Insertion* can violate all of the above constraints.
*Deletion* can violate referential integrity constraint. Options:

- Reject the deletion
- Cascade the deletion, i.e. delete everything which will be affected by the deletion
- Modify the referencing attribute values and delete

*Modification* to non-key values requires domain check.
Modifying a primary key is similar to deleting and inserting.
Modifying a foreign key requires DBMS to ensure the new value references an existing tuple

**Semantic Integrity constraint**: constraints which cannot be directly expressed in schemas (e.g. salary of employee is less than salary of manager). Can be violated during insertion, deletion or modification

*Transactions* allow changes to be made to the database to be made which violate DB integrity constraints as long as at the end of the transaction, the DB is in a valid state which satisfies all constraints. Intermediate states can be rolled back to the initial consistent state, or can be committed to form a new consistent state.

## ER -> Relational Mapping

```flow
user=>start: User's persepctive
dbreq=>operation: Database Requirements
concd=>operation: Conceptual Design
concs=>operation: Conceptual Schema (ER)
logd=>operation: Logical Design
logs=>operation: Logical Schema (Relational)
ints=>operation: Internal Schema

user->dbreq(right)->concd->concs(right)->logd->logs(right)->ints
```

Mapping steps:

1. Strong Entities
2. Weak entities
3. Binary 1:1 relationships
4. Binary 1:N relationships
5. Binary M:N relationships
6. Multivalued attributes
7. N-ary relationships
8. Super/subclasses (in EER)

### 1. Strong Entities

For all strong entity types $E$, create a relation $R$ that includes all attributes of $E$. 

- Include simple attributes of composite attributes
- Don't include derived attributes
- Choose *one* key attribute of $E$ as a primary key for $R$.

If a composite attribute is a key of $E$, then add each simple attribute separately.

Consider foreign keys, weak entities and multi-valued attributes later.

### 2. Weak Entities

For each weak entity type $W$ with owner entity type $E$, create a relation $R$ which includes all simple attributes of $W$.

- Include the primary key attribute of $E$ as the foreign key attributes of $R$
- The primary key of $R$ is the combination of $E$'s primary key and $W$'s partial key (if it exists)

If $W$ has multiple owner entities, include the primary keys of all owner relations.

Written so far:

```
Relations:
Employee [_ssn_, fName, lName]
Department [_dNumber_, dName]
Dependent [_ssn_, _depname_, sex, dob, relationship]

Foreign Keys:
Dependent.ssn references Employee.ssn
```

### 3. Binary 1:1 Relationships

For each binary 1:1 relationship $R$ with participating relations $S$ and $T$, choose one relation (preferably one with total participation). Assume we choose $T$. Include $S$' primary key as a foreign key of $T$. Also, include all simple attributes (decomposing composite attributes) of $R$ as attributes of $T$.

Choose the relationship with total participation because uh

### 4. Binary 1:N Relationships

Similar to binary 1:1 relationship mapping, but choose $T$ as the relation on the N-side of the relationship (side marked with N).

Note that for 1:N recursive relationships, a foreign key is added to an entity which references its own primary key. 

### 5. Binary M:N Relationships

For each binary M:N relationship $R$, create a new relation $R$ to represent it.

- Include the primary keys of the participating relations as foreign keys of $R$
- This combination of foreign keys will form the primary key of $R$
- $R$ can have its own attributes which contribute to the primary key
- Include simple attributes of $R$ into the relation

Sparse relationship mapping is when you create a new relation for every relationship regardless of cardinality. Some people like it because you reduce the amount of foreign keys inside the participating relations but i think it's bad because why create a new one if you don't have to lmao

==why is he bread==

==how????!!==

### 6. Multivalued Attributes

For each multivalued attribute $A$ belonging to relation $E$, create a new relation $R$ which includes:

* An attribute corresponding to $A$ (or its components if $A$ is composite)
* A foreign key referencing the primary key of $E$

The primary key of $R$ is a combination of these attributes.

### 7. N-ary Relationships

uhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh

1. M-N-P relationship or whatever
   - create a new relation whose primary keys are foreign keys referencing participating relations' primary keys
2. M-N-P-1 relationship or whatever (at least one relation has cardinality `1`)
   - create new relation like M-N-P but don't make the foreign key referencing relation with cardinality `1` unique
3. M-1-1 relationship (only 1 relation has cardinality `M`; rest is `1`)
   - add foreign keys referencing other relations to the relation with cardinality `M`
4. 1-1-1 relationship
   - let 

### 8. Superclasses/Subclasses

4 options to model subclass/superclass depending on details of relationship (o/d, total/partial)

1. Multiple Relations, both super/subclasses
   - Create relations for both superclass and all subclasses. 
   - Primary key of subclasses references primary key of superclass.
   - This works for both o/d, total/partial.

2. Multiple Relations, only subclasses

   - Create relations for all subclasses. Merge attributes of superclass into attrs of subclasses. 
   - Primary key of superclass is the primary key of subclass.
   - This works for only **disjoint total** subclasses.
   - Does not work for overlapping (redundancy) and partial

3. Single relation, 1 type attribute

   - Create one relation for all subclasses and superclass. 
   - Attributes are union of all attrs in super/subclasses plus another `type` attribute which indicates which subclass the tuple belongs to. `type` is `null` in tuples that don't belong to a subclass.
   - This works for **disjoint** subclasses, total/partial.
   - Does not work for overlapping and introduces a lot of `null`s

4. Single relation, multiple type attributes

   - Create one relation for all subclasses and superclass.
   - Attributes are union of all attrs in super/subclasses plus $m$ extra boolean attrs corresponding to whether a tuple is an instance of each subclass.
   - This works for **overlapping** subclasses, total/partial.
   - Introduces a lot of `null`s, not recommended if there are many subclass attrs.

   

