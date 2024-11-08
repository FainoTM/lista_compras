
// widgets/item_list_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/view_model.dart';
import '../model/itemModel.dart';

class ItemListWidget extends StatelessWidget {
  final Function(Item) onEdit;
  final Function(Item) onDelete;

  ItemListWidget({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemViewModel>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          itemCount: viewModel.items.length,
          itemBuilder: (context, index) {
            final item = viewModel.items[index];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                title: Text(item.name),
                leading: Text('Quantidade ${item.quantity.toString()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => onEdit(item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => onDelete(item),
                    ),
                    Checkbox(
                      value: item.bought,
                      onChanged: (value) {
                        viewModel.toggleBoughtStatus(item);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}