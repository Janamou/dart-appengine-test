import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gcloud/db.dart';
import 'package:appengine/appengine.dart';
import 'package:notes/model.dart';

Key get notes => context.services.db.emptyKey.append(Notes, id: 1);

Future sendJSONResponse(HttpRequest request, json) {
  request.response
      ..headers.contentType = ContentType.JSON
      ..headers.set("Cache-Control", "no-cache")
      ..add(UTF8.encode(JSON.encode(json)));

  return request.response.close();
}

Future readJSONRequest(HttpRequest request) =>
    request.transform(UTF8.decoder).transform(JSON.decoder).single;

Future<List<Note>> queryItems() {
  var query = context.services.db.query(
      Note, ancestorKey: notes)..order("date");
  return query.run().toList();
}

handleItems(HttpRequest request) {
  if (request.method == 'GET') {   
    return queryItems().then((List<Note> items) {
      var result = items.map((item) => item.toJson()).toList();
      var json = {'notes': result};
      return sendJSONResponse(request, json);
    });
  } else if (request.method == 'POST') {
    return readJSONRequest(request).then((json) {
      var item = Note.fromJson(json)..parentKey = notes;
      return context.services.db.commit(inserts: [item]).then((_) {
          json = {'message': 'success'};
          return sendJSONResponse(request, json);
        });
    });
  } else if (request.method == 'DELETE') {
    return queryItems().then((items) {
      var deletes = items.map((item) => item.key).toList();
      return context.services.db.commit(deletes: deletes).then((_) {
        Map json = {'message': 'success'};
        return sendJSONResponse(request, json);
      });
    });
  }
}
  
void requestHandler(HttpRequest request) {
  if (request.uri.path == '/notes') {
    handleItems(request);
  } else if (request.uri.path == '/') {
    request.response.redirect(Uri.parse('/index.html'));
  } else {
    context.assets.serve();
  }
}

void main() {
  runAppEngine(requestHandler);
}
