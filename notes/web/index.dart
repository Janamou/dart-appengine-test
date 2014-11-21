import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:notes/model.dart';

InputElement noteInput;
UListElement notesWrapper;
ButtonElement notesDeleteAll;
List<Note> notes;

void main() {
  noteInput = querySelector("#note_add_input");
  noteInput.onChange.listen(createNote); 
  
  notesWrapper = querySelector("#notes_wrapper");
  
  notesDeleteAll = querySelector("#notes_delete_all");
  notesDeleteAll.onClick.listen(deleteAll); 
  
  notes = new List<Note>();
  
  createGet('/notes').then((result) {
    result.forEach((json) => notes.add(Note.fromJson(json)));
    addNotes();
  });
}

void createNote(Event event) {
  String noteText = noteInput.value;
  if (noteText.isNotEmpty) {
    addNote(noteText);
  }
}

void addNote(String noteText) {
  Note note = new Note.withData(noteText, new DateTime.now().millisecondsSinceEpoch);
  createPost('/notes', note.toJson()).then((result) {
    notes.add(note);
    addNoteElement(noteText);
    noteInput.value = "";
  });
}

void addNoteElement(String noteText) {
  LIElement note = new LIElement();
  note.text = noteText; 
  //addDeleteNoteButton(note);
  notesWrapper.append(note);
}

void addDeleteNoteButton(LIElement note) {
  ButtonElement deleteButton = new ButtonElement();
  deleteButton
    ..text = "Delete"
    ..classes.add("btn btn-danger btn-sm")
    ..onClick.listen(deleteNote);
  note.append(deleteButton);
}

void deleteNote(Event event) {
  LIElement actualNote = ((event.target as ButtonElement).parent as LIElement);  
  int actualIndex = notesWrapper.children.indexOf(actualNote);
  notes.removeAt(actualIndex);  
  actualNote.remove();    
}

void deleteAll(Event event) {
  createDeleteAll('/notes').then((result) {
    notes.clear();
    notesWrapper.children.clear();
  });  
}

void addNotes() {
  for (Note note in notes) {
    addNoteElement(note.text);
  }
}

Future createGet(String path) {
  return HttpRequest.getString(path).then((response) {
    var json = JSON.decode(response);
    return json['notes'];
  });
}

Future createPost(String path, json) {
  return HttpRequest.request(path, method: 'POST', sendData: JSON.encode(json))
  .then((HttpRequest request) {
    return JSON.decode(request.response);
  });
}

Future createDeleteAll(String path) {
  return HttpRequest.request(path, method: 'DELETE')
  .then((HttpRequest request) {
    return JSON.decode(request.response);
  });
}