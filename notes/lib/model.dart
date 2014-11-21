library notes.model;

import 'package:gcloud/db.dart';

@Kind()
class Notes extends Model {}

@Kind()
class Note extends Model {
  @StringProperty()
  String text;
  
  @IntProperty()
  int date;
  
  Note();
  
  Note.withData(this.text, this.date);

  Map toJson() => {'text': text, 'date': date};

  static Note fromJson(Map jsonMap) {
    return new Note.withData(jsonMap['text'], jsonMap['date']);
  }
}