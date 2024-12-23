import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contact.dart'; // The Contact model that defines contact properties
import 'database_provider.dart'; // Database provider for managing CRUD operations

/// A StatefulWidget for adding or editing a contact.
/// If a contact is passed, it allows editing. If no contact is passed, it enables adding a new contact.
class AddEditPage extends StatefulWidget {
  final Contact? contact; // The contact to edit, or null for adding a new contact.

  AddEditPage({this.contact});

  @override
  _AddEditPageState createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  // A form key to validate the form fields
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for name and phone fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form fields if an existing contact is being edited
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phone;
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up memory
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the DatabaseProvider to perform database operations
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // Display the title based on the action (Add or Edit)
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: _formKey, // Link the form key to the form widget
          child: Column(
            children: [
              // Text field for entering the contact name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  // Validate that the name is not empty
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              // Text field for entering the contact phone number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  // Validate that the phone number is not empty
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Spacing between fields and the button
              ElevatedButton(
                // Button to add or edit a contact
                onPressed: () async {
                  // Check if the form fields are valid
                  if (_formKey.currentState!.validate()) {
                    // Create a new Contact object with updated details
                    final newContact = Contact(
                      id: widget.contact?.id, // Use the same ID for editing; null for adding
                      name: _nameController.text, // Name entered by the user
                      phone: _phoneController.text, // Phone entered by the user
                    );

                    if (widget.contact == null) {
                      // If no contact is provided, this is a new contact
                      await dbProvider.addContact(newContact);
                    } else {
                      // If a contact is provided, update it in the database
                      await dbProvider.updateContact(newContact);
                    }

                    // Close the page and return to the previous screen
                    Navigator.pop(context);
                  }
                },
                // Change the button label based on the action (Add or Edit)
                child: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
