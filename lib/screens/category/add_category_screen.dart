import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? category; // Jika null, berarti mode Tambah. Jika ada, mode Edit.
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  IconData? _selectedIcon;
  Color? _selectedColor;

  final List<IconData> _icons = [
    Icons.shopping_cart, Icons.fastfood, Icons.local_gas_station, Icons.movie,
    Icons.receipt, Icons.home, Icons.phone_android, Icons.health_and_safety,
    Icons.school, Icons.flight, Icons.train, Icons.card_giftcard
  ];

  final List<Color> _colors = [
    Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple,
    Colors.teal, Colors.pink, Colors.amber, Colors.indigo, Colors.cyan
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon;
    _selectedColor = widget.category?.color;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedIcon == null || _selectedColor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih ikon dan warna')),
        );
        return;
      }

      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      if (widget.category == null) {
        // Mode Tambah
        provider.addCategory(_nameController.text, _selectedIcon!, _selectedColor!);
      } else {
        // Mode Edit
        provider.updateCategory(widget.category!.id, _nameController.text, _selectedIcon!, _selectedColor!);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Tambah Kategori' : 'Edit Kategori'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _icons.map((icon) => _buildIconChoice(icon)).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colors.map((color) => _buildColorChoice(color)).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconChoice(IconData icon) {
    final bool isSelected = _selectedIcon == icon;
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = icon),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
        ),
        child: Icon(icon, size: 30, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700),
      ),
    );
  }

  Widget _buildColorChoice(Color color) {
    final bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 3) : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}