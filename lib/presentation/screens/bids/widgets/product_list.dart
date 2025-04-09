import 'package:QuoteApp/data/providers/products_provider.dart';
import 'package:QuoteApp/presentation/screens/bids/widgets/product_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class ProductList extends StatefulWidget {
  static const routeName = '/products_screen';

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {
    // Data init
    final productsData = Provider.of<ProductProvider>(context);
    productsData.fetchData();

    return productsData.products.isEmpty
        ? _buildLoadingState()
        : _buildProductsList(productsData);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: 120,
            height: 120,
          ),
          SizedBox(height: 16),
          Text(
            "Loading products...",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductProvider productsData) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        padding:
            EdgeInsets.only(bottom: 100), // Extra padding at bottom for FAB
        itemCount: productsData.products.length,
        itemBuilder: (_, index) {
          final product = productsData.products[index];

          return ProductListTile(
            productId: product.productId,
            productName: product.productName,
            price: product.price,
            imageUrl: product.imageUrl,
            description: product.description,
          );
        },
      ),
    );
  }
}
