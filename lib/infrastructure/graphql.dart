import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

dynamic fetchGraphql(String query) async {

  // graphql client
  GraphQLClient getGqlClient() {
    final Link link = HttpLink(
      dotenv.get('GRAPHQL_SERVER_URL'),
    );
    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  // get response
  try {
    final GraphQLClient client = getGqlClient();
    final QueryOptions options = QueryOptions(document: gql(query));
    final QueryResult response = await client.query(options);
    return response;
  } catch(e) {
    return null;
  }

}

WebSocketChannel? connectGqlSubscription(String query, String connId) {
  try {
    // websocket graphql client
    final String url = dotenv.get('WEBSOCKET_SERVER_URL');
    final channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        headers: {
          'Sec-WebSocket-Protocol': 'graphql-ws',
        }
    );

    // init graphql connection
    final String initMessage = """
      {
        "id": "$connId",
        "type": "connection_init"
      }
    """;
    channel.sink.add(initMessage);

    // set subscription query
    String startMessage = """
      {
        "id": "$connId",
        "type": "start",
        "payload": {
          "variables": {},
          "extensions": {},
          "operationName": null,
          "query": "${query.replaceAll('\n', '')}"
        }
      }
    """;
    channel.sink.add(startMessage);
    return channel;

  } catch (e) {
    return null;
  }
}
