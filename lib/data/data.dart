import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:note_app_sample/data/get_all_notes_response/get_all_notes_response.dart';
import 'package:note_app_sample/data/note_model/note_model.dart';
import 'package:note_app_sample/data/url.dart';

abstract class ApiCalls {
  Future<NoteModel?> createNote(NoteModel value);
  Future<List<NoteModel?>> getAllNotes();
  Future<NoteModel?> updateNote(NoteModel value);
  Future<void> deleteNote(String id);
}

class NoteDB extends ApiCalls {
// singleton

  NoteDB._internal();

  // Static instance of the singleton
  static final instance = NoteDB._internal();

// end singleton
  final dio = Dio();
  final url = Url();

  ValueNotifier<List<NoteModel>> noteListNotifier = ValueNotifier([]);

  NoteDB() {
    dio.options = BaseOptions(
      baseUrl: url.baseUrl,
      responseType: ResponseType.plain,
    );
  }

  @override
  Future<NoteModel?> createNote(NoteModel value) async {
    try {
      final result = await dio.post(
        url.addNote,
        data: value.toJson(),
      );
      final resultAsJson = jsonDecode(result.data);
      return NoteModel.fromJson(resultAsJson as Map<String, dynamic>);
    } on DioError catch (e) {
      print(e);
      return null;
    } catch (e) {}
    return null;
  }

  @override
  Future<void> deleteNote(String id) async {
    final _result =
        await dio.delete(url.baseUrl + url.deleteNote.replaceFirst('{id}', id));
    if (_result.data == null) {
      return;
    }

    final index = noteListNotifier.value.indexWhere((note) => note.id == id);
    if (index == -1) {
      return;
    }
    noteListNotifier.value.removeAt(index);
    noteListNotifier.notifyListeners();
  }

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final result = await dio.get(url.baseUrl + url.getAllNote);

      if (result.data != null) {
        // Use the response data directly
        final getNoteResponse = GetAllNotesResponse.fromJson(result.data);

        noteListNotifier.value.clear();

        final nonNullNotes = getNoteResponse.data
            .where((note) => note != null)
            .map((note) => note as NoteModel)
            .toList();

        noteListNotifier.value.addAll(nonNullNotes.reversed);
        noteListNotifier.notifyListeners(); // Notify listeners
        return nonNullNotes;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<NoteModel?> updateNote(NoteModel value) async {
    NoteDB();
    final result = await dio.put(
      url.baseUrl + url.updateNote,
      data: value.toJson(),
    );
    if (result.data == null) {
      return null;
    }

    //find index

    final index =
        noteListNotifier.value.indexWhere((note) => note.id == value.id);
    if (index == -1) {
      return null;
    }

    noteListNotifier.value.removeAt(index);

    noteListNotifier.value.insert(index, value);
    noteListNotifier.notifyListeners();
    return value;
  }

  NoteModel? getNoteById(String id) {
    try {
      return noteListNotifier.value.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }
}
