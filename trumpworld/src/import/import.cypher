// CREATE SCHEMA CONSTRAINT
CREATE CONSTRAINT ON (p:Person) ASSERT p.name IS UNIQUE;
CREATE CONSTRAINT ON (o:Organization) ASSERT o.name IS UNIQUE;


// Create Organization-Organization relationships
WITH
'https://docs.google.com/spreadsheets/u/1/d/1Z5Vo5pbvxKJ5XpfALZXvCzW26Cl4we3OaN73K9Ae5Ss/export?format=csv&gid=634968401' AS url,
['LOAN','LOBBIED','SALE','SUPPLIER','SHAREHOLDER','LICENSES','AFFILIATED','TIES','NEGOTIATION','INVOLVED','PARTNER'] AS terms
LOAD CSV WITH HEADERS FROM url AS row
WITH apoc.text.regreplace(toUpper(row.Connection),'\\W+','_') AS type, row, terms
WITH coalesce(head(filter(term IN terms WHERE type CONTAINS term)), type) AS type, row
MERGE (o1:Organization {name:row.`Organization A`})
MERGE (o2:Organization {name:row.`Organization B`})
WITH o1,o2,type,row
CALL apoc.create.relationship(o1,type, {source:row.`Source(s)`, connection:row.Connection},o2) YIELD rel
RETURN type(rel), count(*)
ORDER BY count(*) desc;

// Set Bank label
MATCH (o:Organization)
WHERE o.name CONTAINS "BANK" SET o:Bank;

// Set Hotel label
MATCH (o:Organization)
WHERE o.name CONTAINS "HOTEL" SET o:Hotel;

// Set Trump label
MATCH (o:Organization)
WHERE any(term in ["TRUMP","DT","DJT"] WHERE o.name CONTAINS (term + " "))
SET o:Trump;

// CREATE Organization-Person relationships
WITH
'https://docs.google.com/spreadsheets/u/1/d/1Z5Vo5pbvxKJ5XpfALZXvCzW26Cl4we3OaN73K9Ae5Ss/export?format=csv&gid=1368567920' AS url,
['BOARD','DIRECTOR','INCOME','PRESIDENT','CHAIR','CEO','PARTNER','OWNER','INVESTOR','FOUNDER','STAFF','DEVELOPER','EXECUTIVE_COMITTEE','EXECUTIVE','FELLOW','BANKER','COUNSEL','ADVISOR','SHAREHOLDER','LIASON','SPEECH','CONNECTED','HIRED','CONSULTED','INVOLVED','APPOINTEE','MANAGER','TRUSTEE','AMBASSADOR','PUBLISHER','LAWYER'] AS terms
LOAD CSV WITH HEADERS FROM url AS row
WITH apoc.text.regreplace(toUpper(row.Connection),'\\W+','_') AS type, row, terms
WITH coalesce(head(filter(term IN terms WHERE type CONTAINS term)), 'INVOLVED_WITH') AS type, row
MERGE (o:Organization {name:row.Organization})
MERGE (p:Person {name:row.Person})
WITH o,p,type,row
CALL apoc.create.relationship(p,type, {source:row.`Source(s)`, connection:row.Connection},o) YIELD rel
RETURN type(rel), count(*)
ORDER BY count(*) desc;


// Create Person-Person relationships
WITH
'https://docs.google.com/spreadsheets/u/1/d/1Z5Vo5pbvxKJ5XpfALZXvCzW26Cl4we3OaN73K9Ae5Ss/export?format=csv&gid=905294723' AS url,
['WHITE_HOUSE','REPRESENTATIVE','FRIEND','DIRECTOR','ADVISOR','WORKED','MET','LUNCHED','NOMINEE','COUNSELOR','AIDED','CAMPAIGN','PARTNER','MARRIED','CLOSE','APPEARANCE','BOUGHT','SAT_IN','CONSULTED','CO_CHAIR','GAVE'] AS terms
LOAD CSV WITH HEADERS FROM url AS row
WITH apoc.text.regreplace(toUpper(row.Connection),'\\W+','_') AS type, row, terms
WITH coalesce(head(filter(term IN terms WHERE type CONTAINS term)), type) AS type, row
MERGE (p1:Person {name:row.`Person A`})
MERGE (p2:Person {name:row.`Person B`})
WITH p1,p2,type,row
CALL apoc.create.relationship(p2,type, {source:row.`Source(s)`, connection:row.Connection},p1) YIELD rel
RETURN type(rel), count(*)
ORDER BY count(*) desc;
