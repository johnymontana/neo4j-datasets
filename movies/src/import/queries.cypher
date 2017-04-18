// Find movies similar to Matrix movies
MATCH (m:Movie) WHERE m.title CONTAINS "Matrix"
MATCH (m)-[:IN_GENRE]->(g:Genre)<-[:IN_GENRE]-(rec:Movie)
RETURN rec, count(*) AS num ORDER BY num DESC LIMIT 10;

// Content recommendation by overlapping genres
MATCH (u:User {name: "Misty Williams"})
MATCH (u)-[r:RATED]->(m:Movie)
MATCH (m)-[:IN_GENRE]->(g:Genre)<-[:IN_GENRE]-(rec:Movie)
RETURN rec.title, COUNT(*) AS score ORDER BY score DESC LIMIT 10;

// Show all ratings by Misty Williams
MATCH (u:User {name: "Misty Williams"})
MATCH (u)-[r:RATED]->(m:Movie)
RETURN *;

// Show all ratings by Misty Williams
MATCH (u:User {name: "Misty Williams"})
MATCH (u)-[r:RATED]->(m:Movie)
RETURN avg(r.rating) AS average;

// What are the movies that Misty liked more than average?
MATCH (u:User {name: "Misty Williams"})
MATCH (u)-[r:RATED]->(m:Movie)
WITH u, avg(r.rating) AS average
MATCH (u)-[r:RATED]->(m:Movie)
WHERE r.rating > average
RETURN *;

// Most similar users using Cosine similarity
MATCH (p1:User {name: "Misty Williams"})-[x:RATED]->(m:Movie)<-[y:RATED]-(p2:User)
WITH SUM(x.rating * y.rating) AS xyDotProduct,
SQRT(REDUCE(xDot = 0.0, a IN COLLECT(x.rating) | xDot + a^2)) AS xLength,
SQRT(REDUCE(yDot = 0.0, b IN COLLECT(y.rating) | yDot + b^2)) AS yLength,
p1, p2
RETURN p1, p2, xyDotProduct / (xLength * yLength) AS sim ORDER BY sim DESC;
