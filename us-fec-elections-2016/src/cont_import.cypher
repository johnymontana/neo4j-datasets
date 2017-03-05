CREATE CONSTRAINT ON (c:FECCommittee) ASSERT c.committee_id IS UNIQUE;
CREATE CONSTRAINT ON (c:Organization) ASSERT c.name IS UNIQUE;

LOAD CSV WITH HEADERS FROM "file:///cm.txt" AS row FIELDTERMINATOR "|"

MERGE (c:FECCommittee {committee_id: row.CMTE_ID})
SET c.name = row.CMTE_NM,
    c.designation = row.CMTE_DSGN,
    c.committee_type = row.CMTE_TP,
    c.committee_party = row.CMTE_PTY_AFFILIATION,
    c.category = row.ORG_TP

FOREACH (_ IN CASE WHEN row.CONNECTED_ORG_NM IS NOT NULL THEN [1] ELSE [] END |
    MERGE (o:Organization {name: row.CONNECTED_ORG_NM})
    MERGE (c)-[:CONNECTED_ORG]->(o)
);

MATCH (n:Organization) WHERE n.name = "NONE"
DETACH DELETE n;

CREATE CONSTRAINT ON (c:Candidate) ASSERT c.fecID IS UNIQUE;

// Add candidates
LOAD CSV WITH HEADERS FROM "file:///cn.txt" AS row FIELDTERMINATOR "|"

MERGE (c:Candidate {fecID: row.CAND_ID})
ON CREATE SET c.name = row.CAND_NAME,
              c.office = row.CAND_OFFICE,
              c.party = row.CAND_PTY_AFFILIATION,
              c.state = row.CAND_ST,
              c.district = toInteger(row.CAND_OFFICE_DISTRICT),
              c.election_year = toInteger(row.CAND_ELECTION_YR),
              c.incumbent = row.CAND_ICI;

// Link candidates to committees
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///ccl.txt" AS row FIELDTERMINATOR "|"

MATCH (c:FECCommittee) WHERE c.committee_id = row.CMTE_ID
MATCH (l:Candidate {fecID: row.CAND_ID})
MERGE (c)-[r:FUNDS {fec_year: row.FEC_ELECTION_YR, cand_year: row.CAND_ELECTION_YR}]->(l);


CREATE CONSTRAINT ON (c:Contribution) ASSERT c.sub_id IS UNIQUE;

// Create contributions
USING PERIODIC COMMIT 50000
LOAD CSV WITH HEADERS FROM "file:///itcont_20160928_20161027.txt" AS row FIELDTERMINATOR "|"
CREATE (con:Contribution)
    SET con.sub_id = row.SUB_ID,
        con.amount = toFloat(row.TRANSACTION_AMT),
        con.date = row.TRANSACTION_DT
WITH row,con
MATCH (c:FECCommittee) WHERE c.committee_id = row.CMTE_ID
CREATE (con)-[:MADE_TO]->(c);

// The contributor
CREATE CONSTRAINT ON (c:Contributor) ASSERT c.namezip IS UNIQUE;

USING PERIODIC COMMIT 50000
LOAD CSV WITH HEADERS FROM "file:///itcont_20160928_20161027.txt" AS row FIELDTERMINATOR "|"
WITH row WHERE row.NAME IS NOT NULL AND row.ZIP_CODE IS NOT NULL // only include rows where we have a contributor name and zip code
MERGE (c:Contributor {namezip: row.NAME + row.ZIP_CODE})
ON CREATE SET c.name = row.NAME,
              c.zip_code = row.ZIP_CODE;

USING PERIODIC COMMIT 50000
LOAD CSV WITH HEADERS FROM "file:///itcont_20160928_20161027.txt" AS row FIELDTERMINATOR "|"
MATCH (con:Contributor) WHERE con.namezip = row.NAME + row.ZIP_CODE
MATCH (c:Contribution) WHERE c.sub_id = row.SUB_ID
CREATE (con)-[:MADE_CONTRIBUTION]->(c);

CREATE CONSTRAINT ON (e:Employer) ASSERT e.name IS UNIQUE;
CREATE CONSTRAINT ON (o:Occupation) ASSERT o.name IS UNIQUE;

USING PERIODIC COMMIT 50000
LOAD CSV WITH HEADERS FROM "file:///itcont_20160928_20161027.txt" AS row FIELDTERMINATOR "|"
WITH row WHERE row.OCCUPATION IS NOT NULL AND row.EMPLOYER IS NOT NULL // filter on rows that have an Employer and Occupation value
MERGE (o:Occupation {name: row.OCCUPATION})
MERGE (e:Employer {name: row.EMPLOYER});


CREATE CONSTRAINT ON (s:State) ASSERT s.code IS UNIQUE;

EXPLAIN USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///itcont_20160928_20161027.txt" AS row FIELDTERMINATOR "|"
MATCH (con:Contributor) WHERE con.namezip = row.NAME + row.ZIP_CODE

MATCH (e:Employer) WHERE e.name = row.EMPLOYER
MATCH (o:Occupation) WHERE o.name = row.OCCUPATION

MERGE (con)-[:WORKS_FOR]->(e)
MERGE (con)-[:HAS_OCCUPATION]->(o)

FOREACH (_ IN CASE WHEN row.STATE IS NOT NULL THEN [1] ELSE [] END |
    MERGE (s:State {code: row.STATE})
    MERGE (con)-[:LIVES_IN]->(s)
);
