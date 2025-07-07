import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:QuoteApp/auth/auth_repository.dart';
import 'package:QuoteApp/data/models/user.dart';
import 'package:QuoteApp/data/providers/tenant_provider.dart';
import 'package:QuoteApp/presentation/screens/user/login_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class CreateNewUser extends StatefulWidget {
  static const routeName = '/create_new_user';

  const CreateNewUser({Key? key}) : super(key: key);

  @override
  State<CreateNewUser> createState() => _CreateNewUserState();
}

class _CreateNewUserState extends State<CreateNewUser> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authInstance = AuthenticationRepositoryImpl();
        final user = CustomUser(
          tenantId: TenantProvider.tenantId,
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phoneNumber: _phoneController.text,
        );
        final newUser = await authInstance.createUser(user: user);
        if (newUser.isNotEmpty) {
          authInstance.signOut();
          Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
        }
      } catch (e) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Error',
          desc: e.toString(),
          btnOkOnPress: () {},
          btnOkColor: Colors.black87,
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Create New User',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _createUser,
            tooltip: 'Create User',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? 'Please enter a name.' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter an email.';
                    if (!value.contains('@')) return 'Please enter a valid email.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a password.';
                    if (value.length < 6) return 'Password must be at least 6 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Please enter a phone number.' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        labelStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}