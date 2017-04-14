# Use GraphQL to query Neo4j using the Yelp dataset

## Request

~~~
{
  business(id: "YCsLfBVdLFeN2Necw1HPSA") {
    name
    address
    city
    state
    postal_code
    lat
    lon
    categories {
      name
    }
  }
}
~~~


## Response
~~~
{
  "data": {
    "business": {
      "name": "Stussy",
      "address": "1000 Queen Street W",
      "city": "Toronto",
      "state": "ON",
      "postal_code": "M6J 1H1",
      "lat": 43.644258153,
      "lon": -79.4188293813,
      "categories": [
        {
          "name": "Shopping"
        },
        {
          "name": "Fashion"
        },
        {
          "name": "Men's Clothing"
        },
        {
          "name": "Shoe Stores"
        }
      ]
    }
  }
}
~~~
