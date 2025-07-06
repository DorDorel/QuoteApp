import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:QuoteApp/data/models/product.dart';
import 'package:QuoteApp/data/providers/products_provider.dart';
import 'package:QuoteApp/presentation/screens/admin/add_new_product_screen.dart';
import 'package:QuoteApp/services/storage_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SingleProductList extends StatelessWidget {
  final Product product;

  const SingleProductList({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(2)} ₪',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AddNewProductScreen(
                      isEdit: true,
                      product: product,
                    ),
                  ),
                );
              },
              tooltip: 'Edit Product',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              onPressed: () => _showDeleteDialog(context),
              tooltip: 'Delete Product',
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Delete Product',
      desc: 'Are you sure you want to delete this product? This action cannot be undone.',
      btnOkText: 'Delete',
      btnOkColor: Colors.red.shade400,
      btnCancelText: 'Cancel',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final productsData = Provider.of<ProductProvider>(context, listen: false);
        await StorageService().deleteProductImage(productImageURL: product.imageUrl);
        await productsData.deleteProduct(product.productId);
      },
      width: 400,
    ).show();
  }
}