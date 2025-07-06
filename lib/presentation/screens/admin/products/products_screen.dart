import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:QuoteApp/data/providers/products_provider.dart';
import 'package:QuoteApp/presentation/screens/admin/add_new_product_screen.dart';
import 'package:QuoteApp/presentation/screens/admin/products/single_product_list.dart';

class ProductsScreen extends StatefulWidget {
  static const routeName = '/products_screen';

  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Manage Products',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        elevation: 2,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productsData, child) {
          if (productsData.products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black87),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: productsData.products.length,
            itemBuilder: (_, index) => SingleProductList(
              product: productsData.products[index],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const AddNewProductScreen(
                isEdit: false,
              ),
            ),
          );
        },
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Product',
      ),
    );
  }
}