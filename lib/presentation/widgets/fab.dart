import 'package:QuoteApp/logic/product_bid_logic.dart';
import 'package:QuoteApp/presentation/screens/bids/create_bid_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Fab extends StatelessWidget {
  const Fab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.4),
            spreadRadius: 4,
            blurRadius: 14,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 0,
        onPressed: () {
          removeBidDraft(context);
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.scale,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 400),
              alignment: Alignment.bottomCenter,
              child: CreateBidScreen(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
