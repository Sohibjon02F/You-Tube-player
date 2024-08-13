import 'package:hive/hive.dart';

class DbService {
  Box? todoBox;

  Future<void> openBox() async {
    if (!Hive.isBoxOpen("todo")) {
      todoBox = await Hive.openBox("todo");
    } else {
      todoBox = Hive.box("todo");
    }
  }

  Future<void> writeToDB(String userData) async {
    await openBox();
    await todoBox?.add(userData);
  }

  Future<List<dynamic>> getTodos() async {
    await openBox();
    return todoBox?.values.toList() ?? [];
  }

  Future<void> deleteItems(int index) async {
    await openBox();
    if (todoBox != null && index >= 0 && index < todoBox!.length) {
      await todoBox?.deleteAt(index);
    } else {
      print("Index chegaradan tashqarida yoki box ochilmagan");
    }
  }

  Future<void> updateItem(int index, String newUserData) async {
    await openBox();
    if (todoBox != null && index >= 0 && index < todoBox!.length) {
      await todoBox?.putAt(index, newUserData);
    } else {
      print("Index chegaradan tashqarida yoki box ochilmagan");
    }
  }
}
