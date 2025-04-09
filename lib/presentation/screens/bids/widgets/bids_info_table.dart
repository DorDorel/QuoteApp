import 'package:QuoteApp/data/models/bid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

Widget bidsInfoTable(BuildContext context, Bid bid) {
  final tableWidth = MediaQuery.of(context).size.width - 40;

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columnSpacing: 16,
      headingTextStyle: GoogleFonts.openSans(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      dataTextStyle: GoogleFonts.openSans(
        color: Colors.black,
      ),
      columns: [
        DataColumn(
          label: Container(
            width: tableWidth * 0.3,
            child: Text(
              "Item",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataColumn(
          label: Text("Quantity"),
        ),
        DataColumn(
          label: Text("Warranty"),
        ),
        DataColumn(
          label: Text("Price per unit"),
        ),
        DataColumn(
          label: Text("Final Price"),
        )
      ],
      rows: _getTableRows(bid, tableWidth),
    ),
  );
}

List<DataRow> _getTableRows(Bid bid, double tableWidth) {
  final oCcy = NumberFormat("#,##0.00", "en_US");

  List<DataRow> products = [];
  for (final element in bid.selectedProducts) {
    final DataRow dataRow = DataRow(cells: [
      DataCell(
        Container(
          width: tableWidth * 0.3,
          child: Text(
            element.product.productName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
      DataCell(
        Text(
          element.quantity.toString(),
        ),
      ),
      DataCell(
        Text(
          "${element.warrantyMonths} mo",
        ),
      ),
      DataCell(
        Text(
          oCcy.format(element.product.price),
        ),
      ),
      DataCell(
        Text(
          oCcy.format(
            (element.product.price * element.quantity),
          ),
        ),
      )
    ]);
    products.add(dataRow);
  }

  return products;
}
