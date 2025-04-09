import 'package:QuoteApp/data/models/bid.dart';
import 'package:QuoteApp/data/models/product.dart';
import 'package:QuoteApp/logic/product_bid_logic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListTile extends StatefulWidget {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final String description;

  ProductListTile({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  Product _currentProductInProductObject() {
    return Product(
        productId: productId,
        productName: productName,
        price: price,
        imageUrl: imageUrl,
        description: description);
  }

  @override
  _ProductListTileState createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0.00", "en_US");
    final bool isSelected =
        findCurrentProductDataInProductsBidListBoll(context, widget.productId);
    final SelectedProducts? productSelectedData =
        findCurrentProductDataInProductsBidList(widget.productId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.grey.shade400, width: 1.5)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ProductDetailsSheet(
                    widget: widget,
                    isSelected: isSelected,
                  ),
                );
              },
              splashColor: Colors.grey.withOpacity(0.1),
              highlightColor: Colors.grey.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Product image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.grey.shade400,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 16),

                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.productName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${oCcy.format(widget.price)} ₪",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          if (isSelected && productSelectedData != null)
                            _buildSelectedInfo(productSelectedData, oCcy),
                        ],
                      ),
                    ),

                    // Action button
                    _buildActionButton(isSelected),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedInfo(
      SelectedProducts productSelectedData, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "Qty: ${productSelectedData.quantity} × ${formatter.format(productSelectedData.finalPricePerUnit)} ₪",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        if (productSelectedData.remark.isNotEmpty &&
            productSelectedData.remark != 'Empty')
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 2.0),
            child: Row(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    productSelectedData.remark,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isSelected) {
              removeProductFromCurrentBid(
                context,
                widget.productId,
              );
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ProductDetailsSheet(
                  widget: widget,
                  isSelected: isSelected,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Icon(
              isSelected ? Icons.remove : Icons.add,
              color: isSelected ? Colors.red.shade600 : Colors.black,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsSheet extends StatefulWidget {
  final ProductListTile widget;
  final bool isSelected;

  const ProductDetailsSheet({
    Key? key,
    required this.widget,
    required this.isSelected,
  }) : super(key: key);

  @override
  _ProductDetailsSheetState createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<ProductDetailsSheet> {
  late final productSelectedData = widget.isSelected
      ? findCurrentProductDataInProductsBidList(widget.widget.productId)
      : null;

  late int quantity = widget.isSelected ? productSelectedData!.quantity : 1;
  late int discount = widget.isSelected ? productSelectedData!.discount : 0;
  late int warrantyMonths =
      widget.isSelected ? productSelectedData!.warrantyMonths : 12;
  late num price = widget.isSelected
      ? productSelectedData!.finalPricePerUnit
      : widget.widget.price;
  late String remark = widget.isSelected ? productSelectedData!.remark : '';

  bool customPriceEnabled = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0.00", "en_US");

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(oCcy),

          // Product details form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.widget.description.isNotEmpty)
                      _buildDescriptionCard(),
                    SizedBox(height: 20),
                    _buildSectionTitle("Configure Options"),
                    SizedBox(height: 12),
                    _buildQuantityField(),
                    SizedBox(height: 16),
                    _buildDiscountField(),
                    SizedBox(height: 16),
                    _buildCustomPriceField(),
                    SizedBox(height: 16),
                    _buildWarrantyField(),
                    SizedBox(height: 20),
                    _buildSectionTitle("Add Notes"),
                    SizedBox(height: 8),
                    _buildNotesField(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Bottom action buttons
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(NumberFormat formatter) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Container(
                width: 100,
                height: 100,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.widget.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.widget.productName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Base Price: ${formatter.format(widget.widget.price)} ₪",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Drag handle indicator
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.black, size: 18),
              SizedBox(width: 8),
              Text(
                "Product Description",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            widget.widget.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityField() {
    return _buildOptionCard(
      title: "Quantity",
      subtitle: "Tap to change quantity",
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionCircleButton(
            icon: Icons.remove,
            onPressed: () {
              if (quantity > 1) {
                setState(() {
                  quantity--;
                });
              }
            },
          ),
          Container(
            width: 36,
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$quantity",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildActionCircleButton(
            icon: Icons.add,
            onPressed: () {
              setState(() {
                quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountField() {
    return _buildOptionCard(
      title: "Discount",
      subtitle: "Tap to set discount percentage",
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionCircleButton(
            icon: Icons.remove,
            onPressed: () {
              if (discount > 0) {
                setState(() {
                  discount--;
                  if (!customPriceEnabled) {
                    price = setDiscount(widget.widget.price, discount);
                  }
                });
              }
            },
          ),
          Container(
            width: 36,
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$discount%",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildActionCircleButton(
            icon: Icons.add,
            onPressed: () {
              setState(() {
                discount++;
                if (!customPriceEnabled) {
                  price = setDiscount(widget.widget.price, discount);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPriceField() {
    final oCcy = NumberFormat("#,##0.00", "en_US");

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: customPriceEnabled ? Colors.black : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: customPriceEnabled,
                onChanged: (value) {
                  setState(() {
                    customPriceEnabled = value!;
                    if (!customPriceEnabled) {
                      // Reset price to discounted base price
                      price = setDiscount(widget.widget.price, discount);
                    }
                  });
                },
                activeColor: Colors.black87,
              ),
              SizedBox(width: 4),
              Text(
                "Custom Price",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              Text(
                "₪",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 80,
                child: TextFormField(
                  enabled: customPriceEnabled,
                  initialValue: oCcy.format(price),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  onChanged: (value) {
                    // Remove formatting characters and parse
                    String cleanValue =
                        value.replaceAll(RegExp(r'[^0-9.]'), '');
                    if (cleanValue.isNotEmpty) {
                      setState(() {
                        price = double.parse(cleanValue);
                        // Update discount based on custom price if needed
                        if (customPriceEnabled) {
                          discount =
                              calculateDiscount(widget.widget.price, price)
                                  .toInt();
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          if (customPriceEnabled)
            Padding(
              padding: const EdgeInsets.only(left: 42.0, top: 4.0),
              child: Text(
                "Enter a custom price for this product",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWarrantyField() {
    return _buildOptionCard(
      title: "Warranty (Months)",
      subtitle: "Tap to change warranty period",
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionCircleButton(
            icon: Icons.remove,
            onPressed: () {
              if (warrantyMonths > 0) {
                setState(() {
                  warrantyMonths--;
                });
              }
            },
          ),
          Container(
            width: 36,
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$warrantyMonths",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildActionCircleButton(
            icon: Icons.add,
            onPressed: () {
              setState(() {
                warrantyMonths++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: remark,
        maxLines: 3,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          hintText: "Add notes for this product...",
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
          contentPadding: EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.note_alt_outlined,
              color: Colors.black87,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        onChanged: (value) {
          remark = value;
        },
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildActionCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          customBorder: CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "CANCEL",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),

          // Add/Update button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.isSelected ? "UPDATE" : "ADD TO QUOTE",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProduct() {
    if (widget.isSelected) {
      // Update existing product
      updateCurrentProductDataInBidList(
        context: context,
        productId: widget.widget.productId,
        product: widget.widget._currentProductInProductObject(),
        quantity: quantity,
        pricePerUnit: price,
        discount: discount,
        warrantyMonths: warrantyMonths,
        remark: remark,
      );
    } else {
      // Add new product
      addProductToCurrentBid(
        context,
        widget.widget._currentProductInProductObject(),
        quantity,
        price,
        discount,
        warrantyMonths,
        remark,
      );
    }
    Navigator.pop(context);
  }
}
