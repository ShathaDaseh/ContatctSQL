import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contact.dart';
import 'database_provider.dart';

class AddEditPage extends StatefulWidget {
  final Contact? contact;

  AddEditPage({this.contact});

  @override
  _AddEditPageState createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Create a new Contact object
                    final newContact = Contact(
                      id: widget.contact?.id, // Use null for adding a new contact
                      name: _nameController.text,
                      phone: _phoneController.text,
                    );

                    // Add or update contact
                    if (widget.contact == null) {
                      // Adding a new contact
                      await dbProvider.addContact(newContact);
                    } else {
                      // Updating an existing contact
                      await dbProvider.updateContact(newContact);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
