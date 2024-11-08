// models/item.dart
class Item {
  int? id;
  String name;
  int quantity;
  bool bought;

  Item({this.id, required this.name, required this.quantity, this.bought = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'bought': bought ? 1 : 0,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      bought: map['bought'] == 1,
    );
  }
}
