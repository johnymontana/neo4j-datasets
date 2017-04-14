"use strict";

import {
    GraphQLID,
    GraphQLList,
    GraphQLObjectType,
    GraphQLSchema,
    GraphQLInt,
    GraphQLString,
    GraphQLBoolean,
    GraphQLFloat
} from 'graphql';

let neo4j = require('neo4j-driver').v1;
let driver = neo4j.driver("bolt://localhost");


// resolvers


function getReviewsForBusiness(business) {
    let session = driver.session();
    let params = {businessId: business.business_id};
    let query = `MATCH (b:Business {business_id: {businessId}})
                 MATCH (b)<-[:REVIEWS]-(r:Review)
                 RETURN r;
                `;
}

function getCategoriesForBusiness(business) {
    let session = driver.session();
    let params = {businessId: business.business_id};
    let query = `MATCH (b:Business {business_id: {businessId}})
                 MATCH (b)-[:IN_CATEGORY]->(c:Category)
                 RETURN c;
                 `;

    return session.run(query, params)
        .then(function(result) {
            let cs = [];

            result.records.forEach(function(record) {
                cs.push({"id": record.get("c").identity.toInt(), "name": record.get("c").properties['name']});

            });

            return cs;
        })
}

function getReviewById(reviewId) {

    let session = driver.session();
    let params = {reviewId: reviewId};

    let query = `

                `;

    return {"review_id": reviewId};
}

function getCategoryById(categoryId) {
    return {"name": categoryId};
}

function getBusinessById(businessId) {
    let session = driver.session();
    let params = {businessId: businessId};
    let query = `MATCH (b:Business) WHERE b.business_id = {businessId}
                 MATCH (c:Category)<-[:IN_CATEGORY]-(b)<-[:REVIEWS]-(r:Review)
                 RETURN b as business, COLLECT(DISTINCT r.review_id) AS reviews, COLLECT(DISTINCT c.name) AS categories
                `;

    console.log(params);

    return session.run(query, params)
        .then(function(result) {
            let b = {};

            result.records.forEach(function(record) {
                console.dir(record);
                let business = record.get("business");
                b['id']           = business.identity;
                b['address']      = business.properties['address'];
                b['city']         = business.properties['city'];
                b['is_open']      = business.properties['is_open'];
                b['name']         = business.properties['name'];
                b['review_count'] = business.properties['review_count'].toInt();
                b['lon']          = business.properties['lon'];
                b['lat']          = business.properties['lat'];
                b['neighborhood'] = business.properties['neighborhood'];
                b['stars']        = business.properties['stars'];
                b['state']        = business.properties['state'];
                b['postal_code']  = business.properties['postal_code'];
                b['business_id']  = business.properties['business_id'];

                //relationships
                b['reviews']      = record.get('reviews');
                b['categories']   = record.get('categories');
            });

            console.log(b);
            return b;

        })
}

// Types

// Business
// {id, address, city, is_open, name, review_count, lon, lat, neighborhood, stars, state, postal_code, business_id}
// (:Business)-[:IN_CATEGORY]->(:Category), (:Review)-[:REVIEWS]->(:Business)
const BusinessType = new GraphQLObjectType({
    name: 'Business',
    description: '...',

    fields: () => ({
        id: {type: GraphQLInt},
        address: {type: GraphQLString},
        city: {type: GraphQLString},
        is_open: {type: GraphQLBoolean},
        name: {type: GraphQLString},
        review_count: {type: GraphQLInt},
        lon: {type: GraphQLFloat},
        lat: {type: GraphQLFloat},
        neighborhood: {type: GraphQLString},
        stars: {type: GraphQLFloat},
        state: {type: GraphQLString},
        postal_code: {type: GraphQLString},
        business_id: {type: GraphQLString},

        // Relationships
        reviews: {
            type: new GraphQLList(ReviewType),
            resolve: (business) => getReviewsForBusiness(business) //business.reviews.map(getReviewById)
        },
        categories: {
            type: new GraphQLList(CategoryType),
            resolve: (business) => getCategoriesForBusiness(business) //business.categories.map(getCategoryById)
        }
    })
});

const ReviewType = new GraphQLObjectType({
    name: 'Review',
    description: '...',

    fields: () => ({
        review_id: {type: GraphQLString}
    })
});

const CategoryType = new GraphQLObjectType({
    name: 'Category',
    description: '...',
    fields: () => ({
        name: {type: GraphQLString}
    })
});

// User
// {compliment_writer, compliment_more, compliment_funny, average_stars, cool, review_count:106compliment_plain:6type:usercompliment_note:0fans:0compliment_profile:0compliment_hot:2yelping_since:2013-03-17user_id:WKbdS0LlutPPBOcb8l4aGgcompliment_photos:0name:Marycompliment_cool:1compliment_list:0compliment_cute:0useful:135funny:21}
// [FRIENDS, WROTE]

// Review

// Category(?)



// Queries

const QueryType = new GraphQLObjectType({
    name: 'Query',
    description: '...',

    fields: () => ({
        business: {
            type: BusinessType,
            args: {
                id: {type: GraphQLString}
            },
            resolve: (root, args) => getBusinessById(args.id)
        }
    })
});

// BusinessQuery

// UserQuery

// ReviewQuery

// CategoryQuery(?)
// Get all businesses within a query



export default new GraphQLSchema({
    query: QueryType
})