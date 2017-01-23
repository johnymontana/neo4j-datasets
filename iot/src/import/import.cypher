WITH ["cam.csv", "sqwebcam.csv"] AS files
UNWIND files AS file
LOAD CSV WITH HEADERS FROM "file:///" + file  AS row
CREATE (d:Device)
SET d:Camera
SET d.banner = row.Banner,
    d.operating_system = row.`Operating System`,
    d.timestamp = row.Timestamp
MERGE (ip:IP {address: row.IP})
MERGE (p:Port {portip: row.Port + "-" + row.IP})
SET p.port = row.Port
MERGE (d)-[:LISTENING_ON]->(p)
MERGE (p)-[:ON]->(ip)

FOREACH (_ IN CASE WHEN row.Organization IS NOT NULL THEN [1] ELSE [] END |
    MERGE (org:Organization {name: row.Organization})
    MERGE (org)-[:OWNS]->(ip)
)

FOREACH (_ IN CASE WHEN row.City IS NOT NULL AND row.Country IS NOT NULL THEN [1] ELSE [] END |
    MERGE (city:City {id: row.City + "-" + row.Country})
    SET city.name = row.City
    MERGE (country:Country {name: row.Country})
    MERGE (ip)-[:IN_CITY]->(city)
    MERGE (city)-[:IN_COUNTRY]->(country)
)

FOREACH (_ IN CASE WHEN row.Country IS NOT NULL AND row.City IS NULL THEN [1] ELSE [] END |
    MERGE (country:Country {name: row.Country})
    MERGE (ip)-[:IN_COUNTRY]->(country)
)
