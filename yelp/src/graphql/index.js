import express from 'express';
import graphQLHTTP from 'express-graphql';

import schema from './schema';

const app = express();

app.use(graphQLHTTP({
    schema,
    graphiql: true
}));

app.listen(5000);