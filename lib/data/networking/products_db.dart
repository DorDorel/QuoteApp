import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable, kDebugMode;
import 'package:QuoteApp/logs/console_logger.dart';

import '../../auth/tenant_repository.dart';
import '../models/product.dart';
import 'constants/products_firestore_constants.dart';

/*
    tenantRef: Reference to specific company(tenant) collection of current user
 */
@immutable
class ProductsDb {
  static final logger = Logger();

  static Future<String> addNewProduct(Product product) async {
    final DocumentReference<Object?>? tenantRef =
        await TenantRepositoryImpl().getTenantReference();
    try {
      if (kDebugMode) {
        log("*DEBUG LOG* : Database Query - addNewProduct from ProductsDb reading");
      }

      final CollectionReference<Map<String, dynamic>> productList =
          tenantRef!.collection(
        ProductFirestoreConstants.productsCollectionString,
      );
      final newProductDbObject = await productList.add(
        product.toMap(),
      );
      newProductDbObject.set(
        {
          ProductFirestoreConstants.productDocumentIdString:
              newProductDbObject.id,
        },
        SetOptions(merge: true),
      );
      return newProductDbObject.id;
    } catch (exp) {
      logger.error("Failed to add new product",
          tag: "ProductsDB", exception: exp);
      return exp.toString();
    }
  }

  static Future<List<Product>?> getAllProducts() async {
    final DocumentReference<Object?>? tenantRef =
        await TenantRepositoryImpl().getTenantReference();
    List<Product> productList = [];
    try {
      if (kDebugMode) {
        log("🐛 *DEBUG LOG* : Database Query - getAllProducts from ProductsDb reading");
      }

      QuerySnapshot<Map<String, dynamic>> productsCollection = await tenantRef!
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .get();
      for (final product in productsCollection.docs) {
        productList.add(
          Product.fromMap(product.data()),
        );
      }
    } catch (exp) {
      logger.error("Failed to get all products",
          tag: "ProductsDB", exception: exp);
      return null;
    }
    return productList;
  }

  static Future<Product?> findProductByProductId(String productId) async {
    final DocumentReference<Object?>? tenantRef =
        await TenantRepositoryImpl().getTenantReference();
    try {
      if (kDebugMode) {
        log("🐛 *DEBUG LOG* : Database Query - findProductByProductId from ProductsDb reading");
      }

      QuerySnapshot<Map<String, dynamic>> currentProduct = await tenantRef!
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .where(
            ProductFirestoreConstants.productIdString,
            isEqualTo: productId,
          )
          .get();
      return Product.fromMap(currentProduct.docs.first.data());
    } catch (exp) {
      logger.error("Failed to find product by ID: $productId",
          tag: "ProductsDB", exception: exp);
      return null;
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>?> _findFirestoreDocumentId(
      String productId) async {
    final DocumentReference<Object?>? tenantRef =
        await TenantRepositoryImpl().getTenantReference();
    try {
      if (kDebugMode) {
        log("*🐛 DEBUG LOG* : Database Query - findFirestoreDocumentId from ProductsDb reading");
      }

      QuerySnapshot<Map<String, dynamic>> currentProduct = await tenantRef!
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .where(
            ProductFirestoreConstants.productIdString,
            isEqualTo: productId,
          )
          .get();
      return currentProduct;
    } catch (exp) {
      logger.error(
          "Failed to find Firestore document ID for product: $productId",
          tag: "ProductsDB",
          exception: exp);
      return null;
    }
  }

  static Future<void> removeProduct(String productId) async {
    final DocumentReference<Object?>? tenantRef =
        await TenantRepositoryImpl().getTenantReference();
    try {
      if (kDebugMode) {
        log("*🐛 DEBUG LOG* : Database Query - removeProduct from ProductsDb reading");
      }

      QuerySnapshot<Map<String, dynamic>>? currentProduct =
          await _findFirestoreDocumentId(
        productId,
      );
      final String documentId = currentProduct!.docs.first
          .data()[ProductFirestoreConstants.productDocumentIdString];

      try {
        await tenantRef!
            .collection(
              ProductFirestoreConstants.productsCollectionString,
            )
            .doc(
              documentId,
            )
            .delete();
      } catch (exp) {
        logger.error("Failed to delete product document",
            tag: "ProductsDB", exception: exp);
      }
    } catch (exp) {
      logger.error("Failed to remove product: $productId",
          tag: "ProductsDB", exception: exp);
    }
  }

  static Future<void> editProduct(String productId, Product product) async {
    final DocumentReference<Object?>? tenantRef =
        await TenantRepositoryImpl().getTenantReference();
    try {
      QuerySnapshot<Map<String, dynamic>>? currentProduct =
          await _findFirestoreDocumentId(productId);
      final String documentId = currentProduct!.docs.first
          .data()[ProductFirestoreConstants.productDocumentIdString];

      await tenantRef!
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .doc(
            documentId,
          )
          .update(
            product.toMap(),
          );
    } catch (exp) {
      logger.error("Failed to edit product: $productId",
          tag: "ProductsDB", exception: exp);
    }
  }
}
