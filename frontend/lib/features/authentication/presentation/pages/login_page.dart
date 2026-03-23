import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../config/routes/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginEvent(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      ));
    }
  }

  void _forgotPassword() {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'Enter your email and we\'ll send a reset link.'),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'your@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              final email = ctrl.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter a valid email.')));
                return;
              }
              Navigator.pop(ctx);
              context
                  .read<AuthBloc>()
                  .add(ForgotPasswordEvent(email: email));
            },
            child: const Text('Send Reset Link',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushNamedAndRemoveUntil(
                context, RouteNames.home, (_) => false);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error));
          }
          if (state is PasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Password reset link sent! Check your email.'),
                backgroundColor: Colors.green));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              // ── Header ───────────────────────────────────────────
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: AppColors.topographicPattern,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.white,
                    child: Icon(Icons.eco,
                        size: 40, color: AppColors.primaryGreen),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SizedBox(height: 24),
                    Text(AppStrings.signIn,
                        style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 32),

                    // Email
                    CustomTextField(
                      labelText: AppStrings.email,
                      hintText: 'demo@email.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please enter your email';
                        if (!v.contains('@'))
                          return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    CustomTextField(
                      labelText: AppStrings.password,
                      hintText: 'Enter your password',
                      controller: _passCtrl,
                      obscureText: _obscure,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please enter your password';
                        if (v.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: Text(AppStrings.forgotPassword,
                            style: AppTextStyles.linkText),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => CustomButton(
                        text: AppStrings.login,
                        onPressed:
                            state is AuthLoading ? null : _login,
                        isLoading: state is AuthLoading,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR',
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13)),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 16),

                    // Google Sign In
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                        onPressed: () => context
                            .read<AuthBloc>()
                            .add(const GoogleSignInEvent()),
                        icon: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(4)),
                          child: const Center(
                            child: Text('G',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                          ),
                        ),
                        label: const Text('Continue with Google',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign up link
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(AppStrings.dontHaveAccount,
                          style: AppTextStyles.bodyText),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, RouteNames.signup),
                        child: Text(AppStrings.signUp,
                            style: AppTextStyles.linkText),
                      ),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
