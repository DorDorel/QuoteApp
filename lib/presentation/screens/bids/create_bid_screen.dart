// ignore_for_file: library_private_types_in_public_api

import 'package:QuoteApp/presentation/screens/bids/product_selection_screen.dart';
import 'package:QuoteApp/presentation/widgets/next_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/const_widgets/app_bar_title_style.dart';
import '../../widgets/const_widgets/background_color.dart';

class CreateBidScreen extends StatefulWidget {
  static const routeName = '/create_new_bid';

  @override
  _CreateBidScreenState createState() => _CreateBidScreenState();
}

class _CreateBidScreenState extends State<CreateBidScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'New Quote',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInfoDialog(context);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Top wave design
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black87,
                  ],
                ),
              ),
            ),
          ),
          // Client form
          SafeArea(
            child: NewBidForm(),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.grey[800]),
            SizedBox(width: 10),
            Text(
              "Creating a Quote",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Enter your client's contact information to create a personalized quote. All fields are required to proceed.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            child: Text("GOT IT",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

// Custom wave clipper for top design
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 4), size.height - 40);
    var secondEndPoint = Offset(size.width, size.height - 10);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class NewBidForm extends StatefulWidget {
  @override
  _NewBidFormState createState() => _NewBidFormState();
}

class _NewBidFormState extends State<NewBidForm> {
  String name = '';
  String email = '';
  String phoneNumber = '';
  final _formKey = GlobalKey<FormState>();

  bool _saveForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return false;
    }
    _formKey.currentState!.save();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40), // Reduced from 70 to move the header up
            // Header with animation and design
            _buildHeader(),
            SizedBox(height: 30),
            _buildFormSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_add_rounded,
                size: 30,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Client Information",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Enter your client's details",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500, // Set a maximum width for larger screens
            ),
            width: MediaQuery.of(context).size.width > 600
                ? MediaQuery.of(context).size.width *
                    0.7 // Use 70% width on wider screens
                : MediaQuery.of(context).size.width *
                    0.95, // Use 95% width on smaller screens
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.symmetric(
                vertical: 16, horizontal: 4), // Added vertical margin
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildName(),
                  const SizedBox(height: 20),
                  buildEmail(),
                  const SizedBox(height: 20),
                  buildPhone(),
                  const SizedBox(height: 40),
                  buildNextButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildName() => _buildInputField(
        labelText: 'Client Name',
        hintText: 'Personal or Company name',
        prefixIcon: Icons.business_rounded,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a name';
          }
          return null;
        },
        onSaved: (value) => name = value!,
      );

  Widget buildEmail() => _buildInputField(
        labelText: 'Email Address',
        hintText: 'client@example.com',
        prefixIcon: Icons.email_rounded,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          const String pattern =
              r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
          final RegExp regExp = RegExp(pattern);

          if (value == null || value.isEmpty) {
            return 'Please enter an email';
          } else if (!regExp.hasMatch(value)) {
            return 'Please enter a valid email';
          } else {
            return null;
          }
        },
        onSaved: (value) => email = value!,
      );

  Widget buildPhone() => _buildInputField(
        labelText: 'Phone Number',
        hintText: '(123) 456-7890',
        prefixIcon: Icons.phone_rounded,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a phone number';
          }
          return null;
        },
        onSaved: (value) => phoneNumber = value!,
      );

  Widget _buildInputField({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        prefixIcon: Container(
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(12),
              right: Radius.circular(0),
            ),
          ),
          child: Icon(prefixIcon, color: Colors.black87, size: 22),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[800]),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget buildNextButton() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.grey[400],
        ),
        onPressed: () {
          if (_saveForm()) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ProductSelectionScreen(
                  name: name,
                  email: email,
                  phoneNumber: phoneNumber,
                ),
              ),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CONTINUE TO PRODUCTS',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded),
          ],
        ),
      );
}
