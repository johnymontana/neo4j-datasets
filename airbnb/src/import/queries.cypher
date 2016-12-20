// Interesting Cypher queries


// Amenities

// What are the most common amenities:
MATCH (h:Host)-[:HOSTS]->(l:Listing)-[:HAS]->(a:Amenity)
RETURN a.name, count(*) AS num ORDER BY num DESC LIMIT 10;



// Hosts

// What hosts live in the same neighborhood as their listings?



// Users

// Finding similar users




// Reviews

// Neighborhoods

// Most expensive neighborhoods
//  Look at mean, stddev
//  Price per room
