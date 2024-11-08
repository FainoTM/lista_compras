// home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../model/itemModel.dart';
import '../viewmodel/view_model.dart';
import '../widgets/item_list_widget.dart';
import 'package:rive/rive.dart' as rv;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showFullScreenAnimation = false;
  late rv.RiveAnimationController _fullScreenController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().loadItems();
    });
    _fullScreenController = rv.SimpleAnimation('Timeline 1');
  }

  void _showFullScreenLoadingAnimation() {
    setState(() {
      _showFullScreenAnimation = true;
    });
  }

  void _hideFullScreenLoadingAnimation() {
    setState(() {
      _showFullScreenAnimation = false;
    });
  }

  void _openAddItemOverlay(BuildContext context, {Item? item}) {
    final isEditing = item != null;
    if (isEditing) {
      context.read<ItemViewModel>().textEditingController.text = item!.name;
      context.read<ItemViewModel>().quantEditingController.text = item.quantity.toString();
    } else {
      context.read<ItemViewModel>().textEditingController.clear();
      context.read<ItemViewModel>().quantEditingController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: context.read<ItemViewModel>().textEditingController,
                decoration: InputDecoration(
                  labelText: 'Nome do item',
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: context.read<ItemViewModel>().quantEditingController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    context.read<ItemViewModel>().updateItem(item!);
                  } else {
                    context.read<ItemViewModel>().addItem();
                  }
                  Navigator.of(context).pop();
                },
                child: Text(isEditing ? 'Editar Item' : 'Adicionar Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Compras', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Colors.white,),
            onPressed: () {
              _showFullScreenLoadingAnimation();

              Future.delayed(Duration(seconds: 7), () {
                _hideFullScreenLoadingAnimation();
                context.read<ItemViewModel>().generatePDF();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ItemListWidget(
                  onEdit: (item) => _openAddItemOverlay(context, item: item),
                  onDelete: (item) => context.read<ItemViewModel>().deleteItem(item),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _openAddItemOverlay(context),
                  child: Text('Adicionar Produto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.blueAccent)),
                ),
              ),
            ],
          ),
          if (_showFullScreenAnimation)
            Positioned.fill(
              child: rv.RiveAnimation.asset(
                'assets/animations/pdfpicture_recognition.riv',
                controllers: [_fullScreenController],
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
