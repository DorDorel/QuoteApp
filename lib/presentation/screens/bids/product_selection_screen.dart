import 'package:QuoteApp/data/models/bid.dart';
import 'package:QuoteApp/data/networking/shared_db.dart';
import 'package:QuoteApp/data/providers/bids_provider.dart';
import 'package:QuoteApp/data/providers/new_bids_provider.dart';
import 'package:QuoteApp/logic/create_bid_logic.dart';
import 'package:QuoteApp/logic/product_bid_logic.dart';
import 'package:QuoteApp/presentation/screens/bids/widgets/product_list.dart';
import 'package:QuoteApp/presentation/screens/home/main_dashboard.dart';
import 'package:QuoteApp/presentation/screens/root/root.dart';
import 'package:QuoteApp/presentation/widgets/const_widgets/background_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class ProductSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phoneNumber;

  ProductSelectionScreen({
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentBidData = Provider.of<NewBidsProvider>(context);
    final bidsData = Provider.of<BidsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(currentBidData),
      body: Column(
        children: [
          // Client info summary
          _buildClientSummary(),

          // Search field
          if (_isSearching) _buildSearchField(),

          // Products list
          Expanded(
            child: ProductList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(currentBidData, bidsData),
      floatingActionButton: currentBidData.getCurrentBidProduct.isNotEmpty
          ? _buildQuoteSummaryFAB(currentBidData)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(NewBidsProvider currentBidData) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Text(
        'Select Products',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search,
              color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
        if (currentBidData.getCurrentBidProduct.isNotEmpty)
          IconButton(
            icon: Icon(Icons.delete_outlined, color: Colors.white),
            onPressed: () {
              _showClearCartDialog(currentBidData);
            },
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
          style: GoogleFonts.poppins(),
          onChanged: (value) {
            // Implement search functionality
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildClientSummary() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  widget.email,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSummaryFAB(NewBidsProvider currentBidData) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.black87,
      elevation: 4,
      icon: Icon(Icons.shopping_cart),
      label: Text(
        '${currentBidData.getCurrentBidProduct.length} items',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {
        _showCartSummary(currentBidData);
      },
    );
  }

  Widget _buildBottomBar(
      NewBidsProvider currentBidData, BidsProvider bidsData) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: currentBidData.getCurrentBidProduct.isNotEmpty
            ? () async {
                if (_isSubmitting) return;

                setState(() {
                  _isSubmitting = true;
                });

                await _showLoadingDialog();
                await _createBid();

                // eraseAllUserBid because we want to re-reading from BidsDb
                bidsData.eraseAllUserBid();
              }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CREATE QUOTE',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.check_circle_outline),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(NewBidsProvider currentBidData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Clear Selection",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to remove all products from this quote?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            child: Text(
              "CANCEL",
              style: GoogleFonts.poppins(color: Colors.grey[800]),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text(
              "CLEAR ALL",
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              currentBidData.clearAllCurrentBid();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showCartSummary(NewBidsProvider currentBidData) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.black),
                SizedBox(width: 12),
                Text(
                  "Quote Summary",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "${currentBidData.getCurrentBidProduct.length} products selected",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Total: ${calculateTotalBidSum(context).toStringAsFixed(2)} ₪",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  "CONTINUE SHOPPING",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLoadingDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/loading.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text(
              "Creating your quote...",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBid() async {
    final firebaseUser = Provider.of<User?>(context, listen: false);
    final newBidsData = Provider.of<NewBidsProvider>(context, listen: false);
    int currentBidNumber = await SharedDb.getCurrentBidId();

    final Bid bid = Bid(
      openFlag: true,
      bidId: currentBidNumber.toString(),
      createdBy: firebaseUser!.uid.toString(),
      date: DateTime.now(),
      clientName: widget.name,
      clientMail: widget.email,
      clientPhone: widget.phoneNumber,
      finalPrice: calculateTotalBidSum(context),
      selectedProducts: newBidsData.getCurrentBidProduct,
    );

    final bool bidFlow = await CreateBid(
      phoneNumber: widget.phoneNumber,
      currentBid: bid,
      creator: firebaseUser.uid.toString(),
    ).startNewBidFlow();

    // Close loading dialog
    Navigator.of(context).pop();

    // Navigate to root screen
    Navigator.pushNamed(
      context,
      RootScreen.routeName,
    );

    setState(() {
      _isSubmitting = false;
    });
  }
}
