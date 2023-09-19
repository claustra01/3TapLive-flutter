import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

dynamic fetchGraphql(String query) async {

  // graphql client
  GraphQLClient getRickAndMortyApiClient() {
    final Link link = HttpLink(
      dotenv.get('APP_SERVER_URL'),
    );
    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  // get response
  try {
    final GraphQLClient client = getRickAndMortyApiClient();
    final QueryOptions options = QueryOptions(document: gql(query));
    final QueryResult response = await client.query(options);
    return response;
  } catch(e) {
    return null;
  }

}