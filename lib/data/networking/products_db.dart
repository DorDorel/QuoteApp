import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable, kDebugMode;
import 'package:logger/logger.dart';

import '../../auth/tenant_repository.dart';
import '../models/product.dart';
import 'constants/products_firestore_constants.dart';
import 'database_exception.dart';

@immutable
class ProductsDb {
  static final Logger _logger = Logger();

  static Future<String> addNewProduct(Product product) async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();
    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference");
    }

    try {
      if (kDebugMode) {
        _logger.d("Database Query - addNewProduct from ProductsDb reading");
      }

      final productList = tenantRef.collection(
        ProductFirestoreConstants.productsCollectionString,
      );
      final newProductDbObject = await productList.add(
        product.toMap(),
      );
      await newProductDbObject.set(
        {
          ProductFirestoreConstants.productDocumentIdString:
              newProductDbObject.id,
        },
        SetOptions(merge: true),
      );
      return newProductDbObject.id;
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to add new product",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Failed to add new product",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<List<Product>> getAllProducts() async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();
    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference");
    }

    try {
      if (kDebugMode) {
        _logger.d("Database Query - getAllProducts from ProductsDb reading");
      }

      final productsCollection = await tenantRef
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .get();

      return productsCollection.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to get all products",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Failed to get all products",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<Product?> findProductByProductId(String productId) async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();
    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference");
    }

    try {
      if (kDebugMode) {
        _logger.d(
            "Database Query - findProductByProductId from ProductsDb reading");
      }

      final currentProduct = await tenantRef
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .where(
            ProductFirestoreConstants.productIdString,
            isEqualTo: productId,
          )
          .get();

      if (currentProduct.docs.isEmpty) {
        return null;
      }

      return Product.fromMap(currentProduct.docs.first.data());
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to find product by ID: $productId",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Failed to find product by ID: $productId",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<String> _findFirestoreDocumentId(String productId) async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();
    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference");
    }

    try {
      if (kDebugMode) {
        _logger.d(
            "Database Query - findFirestoreDocumentId from ProductsDb reading");
      }

      final currentProduct = await tenantRef
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .where(
            ProductFirestoreConstants.productIdString,
            isEqualTo: productId,
          )
          .get();

      if (currentProduct.docs.isEmpty) {
        throw DatabaseException(
            "Product with ID '$productId' not found in Firestore");
      }

      return currentProduct.docs.first
          .data()[ProductFirestoreConstants.productDocumentIdString];
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to find Firestore document ID for product: $productId",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Failed to find Firestore document ID for product: $productId",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> removeProduct(String productId) async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();
    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference");
    }

    try {
      if (kDebugMode) {
        _logger.d("Database Query - removeProduct from ProductsDb reading");
      }

      final documentId = await _findFirestoreDocumentId(productId);

      await tenantRef
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .doc(documentId)
          .delete();
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to remove product: $productId",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Failed to remove product: $productId",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> editProduct(String productId, Product product) async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();
    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference");
    }

    try {
      final documentId = await _findFirestoreDocumentId(productId);

      await tenantRef
          .collection(
            ProductFirestoreConstants.productsCollectionString,
          )
          .doc(documentId)
          .update(
            product.toMap(),
          );
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to edit product: $productId",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Failed to edit product: $productId",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
