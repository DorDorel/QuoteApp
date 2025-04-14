import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:QuoteApp/logs/console_logger.dart';

import '../data/models/bid.dart';
import '../data/models/product.dart';
import '../data/providers/new_bids_provider.dart';

bool addProductToCurrentBid(
  BuildContext context,
  Product product,
  int quantity,
  num pricePerUnit,
  int discount,
  int warrantyMonths,
  String remark,
) {
  final logger = Logger();
  final newBidsProvider = Provider.of<NewBidsProvider>(context, listen: false);
  try {
    final SelectedProducts currentProduct = SelectedProducts(
        product: product,
        quantity: quantity,
        discount: discount,
        warrantyMonths: warrantyMonths,
        finalPricePerUnit: pricePerUnit,
        remark: remark);
    newBidsProvider.addProductToList(currentProduct);
    logger.info("Product ${product.productName} added to current bid",
        tag: "ProductBidLogic");
    return true;
  } catch (exp) {
    logger.error("Failed to add product to bid",
        tag: "ProductBidLogic", exception: exp);
    return false;
  }
}

bool removeProductFromCurrentBid(BuildContext context, String productId) {
  final logger = Logger();
  final newBidsProvider = Provider.of<NewBidsProvider>(context, listen: false);
  try {
    newBidsProvider.removeProductFromBid(productId);
    logger.info("Product $productId removed from bid", tag: "ProductBidLogic");
    return true;
  } catch (exp) {
    logger.error("Failed to remove product from bid",
        tag: "ProductBidLogic", exception: exp);
    return false;
  }
}

void removeBidDraft(BuildContext context) {
  final logger = Logger();
  final newBidsProvider = Provider.of<NewBidsProvider>(context, listen: false);
  newBidsProvider.clearAllCurrentBid();
  logger.info("Bid draft removed", tag: "ProductBidLogic");
}

SelectedProducts? findCurrentProductDataInProductsBidList(String productId) {
  final List<SelectedProducts> productBidList =
      NewBidsProvider().getCurrentBidProduct;
  try {
    final SelectedProducts currentProduct =
        productBidList.firstWhere((p) => p.product.productId == productId);
    return currentProduct;
  } catch (exp) {
    return null;
  }
}

bool findCurrentProductDataInProductsBidListBoll(
    BuildContext context, String productId) {
  final newBidsProvider = Provider.of<NewBidsProvider>(context, listen: false);
  final List<SelectedProducts> productBidList =
      newBidsProvider.getCurrentBidProduct;
  try {
    productBidList.firstWhere((p) => p.product.productId == productId);

    return true;
  } catch (exp) {
    return false;
  }
}

bool updateCurrentProductDataInBidList({
  required BuildContext context,
  required String productId,
  required Product product,
  required int quantity,
  required num pricePerUnit,
  required int discount,
  required int warrantyMonths,
  required String remark,
}) {
  final logger = Logger();
  try {
    final newBidsProvider = Provider.of<NewBidsProvider>(
      context,
      listen: false,
    );
    newBidsProvider.removeProductFromBid(
      productId,
    );
    addProductToCurrentBid(
      context,
      product,
      quantity,
      pricePerUnit,
      discount,
      warrantyMonths,
      remark,
    );
    logger.info("Product ${product.productName} updated in bid",
        tag: "ProductBidLogic");
    return true;
  } catch (exp) {
    logger.error(
      "Failed to update product in bid",
      tag: "ProductBidLogic",
      exception: exp,
    );
    return false;
  }
}

double setDiscount(num originalPrice, num discountPercentage) {
  final priceAfterDiscount =
      originalPrice - ((originalPrice / 100) * discountPercentage);

  return priceAfterDiscount;
}

num calculateDiscount(num originalPrice, num newPrice) {
  final num discountPrice = originalPrice - newPrice;
  final num discountValue = (discountPrice / originalPrice) * 100;

  return discountValue;
}

double calculateTotalBidSum(BuildContext context) {
  final logger = Logger();
  final newBidsProvider = Provider.of<NewBidsProvider>(
    context,
    listen: false,
  );

  double totalSum = 0;
  try {
    for (final element in newBidsProvider.getCurrentBidProduct) {
      int singleProductUnit = element.quantity;
      num priceForAllProductUnits =
          singleProductUnit * element.finalPricePerUnit;
      totalSum += priceForAllProductUnits;
      logger.info(
          "Adding product: ${element.product.productName}, quantity: ${element.quantity}, price per unit: ${element.finalPricePerUnit}, subtotal: $priceForAllProductUnits",
          tag: "ProductBidLogic");
    }
    logger.info("Total calculated bid sum: $totalSum", tag: "ProductBidLogic");
  } catch (e) {
    logger.error("Error calculating bid sum",
        tag: "ProductBidLogic", exception: e);
  }
  return totalSum;
}
