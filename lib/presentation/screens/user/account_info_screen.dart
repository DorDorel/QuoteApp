import 'package:QuoteApp/data/providers/user_info_provider.dart';
import 'package:QuoteApp/presentation/screens/user/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AccountInfoScreen extends StatelessWidget {
  static const routeName = '/user_profile';

  const AccountInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: firebaseUser != null
          ? const ProfileBody()
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserInfoProvider>(context);
    final userData = userDataProvider.userData;

    if (userData == null) {
      return const Center(
        child: Text(
          'No user data available.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Stack(
      children: [
        // Background header
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                // Profile Header
                Text(
                  "My Profile",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 36.0,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage("assets/images/user.png"),
                ),
                const SizedBox(height: 16),

                // User Email
                Text(
                  userData.email,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'UID: ${userData.uid}',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                // User Info Card
                _buildInfoCard(context, userData),

                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic userData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.business_outlined,
              label: 'Tenant ID',
              value: userData.tenantId,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.report_problem_outlined,
              label: 'Report a Problem',
              isAction: true,
              onTap: () {
                // TODO: Implement report functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    String? value,
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (value != null)
              Text(
                value,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            if (isAction)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<UserInfoProvider>().cleanUserMemory(context, true);
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
      },
      icon: const Icon(Icons.logout_outlined),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red.shade400,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        textStyle: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}