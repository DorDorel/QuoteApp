import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:QuoteApp/data/models/bid.dart';

Widget bidsInfoTable(BuildContext context, Bid bid) {
  final theme = Theme.of(context);

  return SizedBox(
    width: double.infinity,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        columns: const [
          DataColumn(label: Text("Item")),
          DataColumn(label: Text("Quantity"), numeric: true),
          DataColumn(label: Text("Warranty")),
          DataColumn(label: Text("Price per unit"), numeric: true),
          DataColumn(label: Text("Final Price"), numeric: true),
        ],
        rows: _getTableRows(bid),
      ),
    ),
  );
}

List<DataRow> _getTableRows(Bid bid) {
  final oCcy = NumberFormat("#,##0.00", "en_US");

  return bid.selectedProducts.map((element) {
    return DataRow(cells: [
      DataCell(
        SizedBox(
          width: 150, // Set a fixed width for the item column
          child: Text(
            element.product.productName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
      DataCell(Text(element.quantity.toString())),
      DataCell(Text("${element.warrantyMonths} mo")),
      DataCell(Text(oCcy.format(element.product.price))),
      DataCell(Text(oCcy.format(element.product.price * element.quantity))),
    ]);
  }).toList();
}
