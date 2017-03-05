CREATE CONSTRAINT ON (c:Candidate) ASSERT c.fec_id IS UNIQUE;
CREATE CONSTRAINT ON (s:State) ASSERT s.code IS UNIQUE;
CREATE CONSTRAINT ON (d:District) ASSERT d.number IS UNIQUE;
CREATE CONSTRAINT ON (o:Office) ASSERT o.id IS UNIQUE;
CREATE CONSTRAINT ON (e:Expense) ASSERT e.id IS UNIQUE;

LOAD CSV WITH HEADERS FROM "file:///candidates-2016.csv" AS row
WITH row WHERE row.branch IS NOT NULL
MERGE (c:Candidate {fec_id: row.fec_candidate_id})
ON CREATE set c.name       = row.name,
              c.clean_name = row.clean_name,
              c.crp_id     = row.crp_id

MERGE (p:Party {name: row.party})
MERGE (c)-[:MEMBER_OF]->(p)

MERGE (o:Office {id: row.office_state + "-" + row.branch + "-" + row.district})
  ON CREATE SET o.state    = row.office_state,
                o.district = row.district,
                o.branch   = row.branch
MERGE (c)-[:FOR]->(o);

LOAD CSV WITH HEADERS FROM "file:///independent-expenditure.csv" AS row

MERGE (e:Transaction {id: row.tra_id})
ON CREATE SET t.amt = toFloat(replace(replace(row.exp_amo, "$", ""), ",", ""))

MERGE (v:Vendor {name:})

