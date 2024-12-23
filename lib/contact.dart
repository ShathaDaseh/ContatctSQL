class Contact {
  int? id;
  String name;
  String phone;

Contact({this.id, required this.name, required this.phone});

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'phone': phone,
  };
}
factory Contact.fromMap(Map<String, dynamic> map) {
  return Contact(
    id: map['id'] as int,
    name: map['name']as String,
    phone: map['phone']as String,
  );
}
@override
String toString() {
  return 'Contact{id: $id, name: $name, phone: $phone}';
}
}