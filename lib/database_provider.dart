import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart';

class DatabaseProvider extends ChangeNotifier {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the contacts table
        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT
          )
        ''');
      },
    );
  }
// Get all contacts from the database
  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }
//add contact 
  Future<void> addContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap());
    notifyListeners();
  }
//update contact
  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
    notifyListeners();
  }
//delete contact
  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }
//delete all contacts

  Future<void> deleteAllContacts() async {
    final db = await database;
    await db.delete('contacts');
    notifyListeners();
  }

    // Retrieve a contact by ID
  Future<Contact?> getContact(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.query('contacts', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Contact.fromMap(result.first);
    }
    return null;
  }



}
