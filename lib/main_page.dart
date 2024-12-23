import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contact.dart';
import 'database_provider.dart';
import 'add_edit_page.dart';

/// The main page of the application, displaying a list of contacts.
/// Allows users to view, add, edit, or delete contacts.
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    // Access the DatabaseProvider using the Provider package
    final dbProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'), // Title for the app bar
      ),
      body: FutureBuilder<List<Contact>>(
        future: dbProvider.getAllContacts(), // Fetch all contacts from the database
        builder: (context, snapshot) {
          // Handle different states of the Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if the Future fails
            return const Center(child: Text('Error loading contacts.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if no contacts are found
            return const Center(child: Text('No contacts found.'));
          }

          // If data is successfully retrieved, display the list of contacts
          final contacts = snapshot.data!;
          return ListView.builder(
            itemCount: contacts.length, // Number of contacts
            itemBuilder: (context, index) {
              final contact = contacts[index]; // Get each contact from the list
              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact.name[0]), // Display the first letter of the contact's name
                ),
                title: Text(contact.name), // Display the contact's name
                subtitle: Text(contact.phone), // Display the contact's phone number
                trailing: IconButton(
                  icon: const Icon(Icons.delete), // Delete button
                  onPressed: () async {
                    // Delete the contact and refresh the UI
                    await dbProvider.deleteContact(contact.id!);
                  },
                ),
                onTap: () {
                  // Show a dialog with contact details when tapped
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Contact Info'), // Title of the dialog
                      content: Text(
                        'Name: ${contact.name}\nPhone Number: ${contact.phone}', // Display name and phone number
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), // Close the dialog
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                onLongPress: () async {
                  // Open the Add/Edit page to edit the contact when long-pressed
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditPage(contact: contact),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add), // Floating action button to add a contact
        onPressed: () async {
          // Navigate to the Add/Edit page to add a new contact
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditPage()),
          );
        },
      ),
    );
  }
}
