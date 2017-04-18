CREATE CONSTRAINT ON (m:Movie) ASSERT m.movieId IS UNIQUE;
CREATE CONSTRAINT ON (g:Genre) ASSERT g.name IS UNIQUE;
CREATE CONSTRAINT ON (u:User) ASSERT u.userId IS UNIQUE;
CREATE CONSTRAINT ON (a:Actor) ASSERT a.name IS UNIQUE;
//CREATE CONSTRAINT ON (w:Writer) ASSERT w.name IS UNIQUE;
CREATE CONSTRAINT ON (d:Director) ASSERT d.name IS UNIQUE;

CREATE INDEX ON :Movie(imdbId);
CREATE INDEX ON :User(name);

// Load movies
LOAD CSV WITH HEADERS FROM "file:///movies.csv" AS row
MERGE (m:Movie {movieId: row.movieId})
ON CREATE SET m.title = row.title
WITH *
UNWIND split(row.genres, "|") AS genre
MERGE (g:Genre {name: genre})
MERGE (m)-[:IN_GENRE]->(g);

// Load users / ratings
USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///ratings.csv" AS row
MERGE (u:User {userId: row.userId})
WITH *
MATCH (m:Movie {movieId: row.movieId})
CREATE (u)-[r:RATED]->(m)
SET r.rating = toFloat(row.rating),
    r.timestamp = toInt(row.timestamp);

// Add user names
LOAD CSV WITH HEADERS FROM "file:///names.csv" AS row
MATCH (u:User {userId: row.userid})
SET u.name = row.name;

// Set alternative ids
LOAD CSV WITH HEADERS FROM "file:///links.csv" AS row
MATCH (m:Movie {movieId: row.movieId})
SET m.imdbId = row.imdbId,
    m.tmdbId = row.tmdbId;


// Supplement with OMDB data
USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///omdbFull_.txt" AS row FIELDTERMINATOR "\t"
MATCH (m:Movie) WHERE m.imdbId = substring(row.imdbID,2)
SET m.year = toInt(row.Year),
    m.country = row.Country,
    m.language = row.Language,
    m.plot = row.Plot,
    m.imdbRating = toFloat(row.imdbRating),
    m.imdbVotes = toInt(row.imdbVotes),
    m.released = row.Released,
    m.runtime = toInt(replace(row.Runtime, " min", "")),
    m.poster = row.Poster
FOREACH (actor IN split(row.Cast, ",") |
    MERGE (a:Actor {name: actor})
    MERGE (m)<-[:ACTED_IN]-(a)
)
FOREACH (director IN split(row.Director, ",") |
    MERGE (d:Director {name: director})
    MERGE (m)<-[:DIRECTED]-(d)
);
