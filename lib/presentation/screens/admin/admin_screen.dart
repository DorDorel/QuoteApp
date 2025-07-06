import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:QuoteApp/presentation/screens/admin/products/products_screen.dart';
import 'create_new_user.dart';

class AdminScreen extends StatelessWidget {
  static const routeName = '/admin_panel';

  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdminCard(
              context,
              icon: Icons.inventory_2_outlined,
              label: 'Manage Products',
              onTap: () => Navigator.pushNamed(context, ProductsScreen.routeName),
            ),
            _buildAdminCard(
              context,
              icon: Icons.person_add_alt_1_outlined,
              label: 'Create New User',
              onTap: () => Navigator.pushNamed(context, CreateNewUser.routeName),
            ),
            // Add more admin actions here as needed
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.black87),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}