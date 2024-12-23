import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart'; // The Contact model class

/// A ChangeNotifier class to manage the database and provide CRUD operations.
/// This class uses SQLite for data persistence and notifies listeners when changes occur.
class DatabaseProvider extends ChangeNotifier {
  Database? _database; // Holds a reference to the SQLite database

  /// Getter to lazily initialize and return the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// Initialize the SQLite database.
  /// This function creates the database file and a `contacts` table if it doesn't exist.
  Future<Database> initDatabase() async {
    // Get the path to the database directory
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db'); // Set the database name

    // Open the database and create the contacts table if it doesn't exist
    return await openDatabase(
      path,
      version: 1, // Database version for migrations in future updates
      onCreate: (db, version) async {
        // SQL command to create the contacts table
        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT, -- Auto-incremented ID
            name TEXT, -- Name of the contact
            phone TEXT -- Phone number of the contact
          )
        ''');
      },
    );
  }

  /// Retrieve all contacts from the database.
  Future<List<Contact>> getAllContacts() async {
    final db = await database; // Ensure the database is initialized
    final List<Map<String, dynamic>> maps = await db.query('contacts'); // Query all rows from the `contacts` table

    // Convert the list of maps to a list of Contact objects
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]); // Convert each map to a Contact object
    });
  }

  /// Add a new contact to the database.
  Future<void> addContact(Contact contact) async {
    final db = await database; // Ensure the database is initialized
    await db.insert('contacts', contact.toMap()); // Insert the contact into the `contacts` table
    notifyListeners(); // Notify listeners of the change
  }

  /// Update an existing contact in the database.
  Future<void> updateContact(Contact contact) async {
    final db = await database; // Ensure the database is initialized
    await db.update(
      'contacts', // Table name
      contact.toMap(), // New values for the contact
      where: 'id = ?', // Condition to match the contact by ID
      whereArgs: [contact.id], // Arguments for the condition
    );
    notifyListeners(); // Notify listeners of the change
  }

  /// Delete a contact from the database by ID.
  Future<void> deleteContact(int id) async {
    final db = await database; // Ensure the database is initialized
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]); // Delete the row with the given ID
    notifyListeners(); // Notify listeners of the change
  }

  /// Delete all contacts from the database.
  Future<void> deleteAllContacts() async {
    final db = await database; // Ensure the database is initialized
    await db.delete('contacts'); // Delete all rows from the `contacts` table
    notifyListeners(); // Notify listeners of the change
  }

  /// Retrieve a specific contact by ID.
  Future<Contact?> getContact(int id) async {
    final db = await database; // Ensure the database is initialized
    // Query the `contacts` table for a row with the given ID
    List<Map<String, dynamic>> result =
        await db.query('contacts', where: 'id = ?', whereArgs: [id]);

    // If a contact is found, return it as a Contact object
    if (result.isNotEmpty) {
      return Contact.fromMap(result.first);
    }
    return null; // Return null if no contact is found
  }
}
