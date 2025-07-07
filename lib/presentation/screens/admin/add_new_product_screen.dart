import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:QuoteApp/data/models/product.dart';
import 'package:QuoteApp/data/providers/products_provider.dart';
import 'package:QuoteApp/services/storage_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddNewProductScreen extends StatefulWidget {
  static const routeName = '/add_new_product_screen';
  final bool isEdit;
  final Product? product;

  const AddNewProductScreen({Key? key, required this.isEdit, this.product}) : super(key: key);

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late Product _editedProduct;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _editedProduct = widget.product ?? Product(productId: '', productName: '', price: 0, imageUrl: '', description: '');
    _nameController = TextEditingController(text: _editedProduct.productName);
    _priceController = TextEditingController(text: _editedProduct.price.toString());
    _descriptionController = TextEditingController(text: _editedProduct.description);
    _imageUrl = _editedProduct.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final productsData = Provider.of<ProductProvider>(context, listen: false);
      try {
        if (widget.isEdit) {
          await productsData.editProduct(_editedProduct.productId, _editedProduct);
        } else {
          await productsData.addNewProduct(_editedProduct);
        }
        Navigator.of(context).pop();
      } catch (error) {
        _showErrorDialog('An error occurred!', 'Could not save product.');
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      String? imageUrl = await StorageService().uploadProductImage(_editedProduct.productId);
      if (imageUrl != null) { // ignore: unnecessary_null_comparison
        setState(() {
          _imageUrl = imageUrl;
          _editedProduct = _editedProduct.copyWith(imageUrl: imageUrl);
        });
      } else {
        _showErrorDialog('Image Upload Failed', 'Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred!', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: Colors.black87,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Product' : 'Add Product',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveForm,
            tooltip: 'Save Product',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Product Name',
                  validator: (value) => value!.isEmpty ? 'Please provide a name.' : null,
                  onSaved: (value) => _editedProduct = _editedProduct.copyWith(productName: value),
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _priceController,
                  label: 'Price',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a price.';
                    if (double.tryParse(value) == null) return 'Please enter a valid number.';
                    if (double.parse(value) <= 0) return 'Please enter a number greater than zero.';
                    return null;
                  },
                  onSaved: (value) => _editedProduct = _editedProduct.copyWith(price: double.parse(value!)),
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please provide a description.';
                    if (value.length < 10) return 'Should be at least 10 characters long.';
                    return null;
                  },
                  onSaved: (value) => _editedProduct = _editedProduct.copyWith(description: value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: _imageUrl?.isNotEmpty ?? false
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_imageUrl!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Product Image',
                    style: GoogleFonts.openSans(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}