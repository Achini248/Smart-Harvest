import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Forgot-password: call Firebase directly from the dialog so the result
  /// is shown inline — no state-race with AuthBloc's stream subscription.
  Future<void> _forgotPassword() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());

    // Track whether the email was sent successfully so we can show a
    // snackbar on the *page* only after the dialog has fully closed.
    bool resetSent = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Keep sending state inside the dialog's own closure so it never
        // touches the outer page's context after an async gap.
        bool sending = false;
        return StatefulBuilder(
          builder: (ctx, setDlg) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.lock_reset_outlined,
                    color: AppColors.primaryGreen, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('Reset Password',
                  style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ]),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text(
                'Enter your registered email address and we\'ll send you a link to reset your password.',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'your@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.primaryGreen, width: 2)),
                ),
              ),
            ]),
            actions: [
              TextButton(
                  onPressed: sending ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: sending
                    ? null
                    : () async {
                        final email = ctrl.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          // Use ctx (dialog context) — never the outer context
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please enter a valid email.')));
                          }
                          return;
                        }
                        setDlg(() => sending = true);
                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);
                          resetSent = true;
                          if (ctx.mounted) Navigator.pop(ctx);
                        } on FirebaseAuthException catch (e) {
                          setDlg(() => sending = false);
                          String msg;
                          switch (e.code) {
                            case 'user-not-found':
                              msg =
                                  'No account found with this email address.';
                              break;
                            case 'invalid-email':
                              msg = 'Please enter a valid email address.';
                              break;
                            case 'too-many-requests':
                              msg =
                                  'Too many attempts. Please wait and try again.';
                              break;
                            default:
                              msg =
                                  'Failed to send reset email. Please try again.';
                          }
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Text(msg),
                                backgroundColor: AppColors.error));
                          }
                        } catch (_) {
                          setDlg(() => sending = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Failed to send reset email. Check your connection.'),
                                  backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                child: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Send Reset Link',
                        style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );

    ctrl.dispose();

    // Dialog is fully closed — safe to use the page context now
    if (resetSent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: const [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Reset link sent! Check your inbox (and spam folder).')),
          ]),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
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
                    Text(AppStrings.signIn, style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Container(
                        width: 60, height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 32),
                    CustomTextField(
                      labelText: AppStrings.email,
                      hintText: 'demo@email.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      labelText: AppStrings.password,
                      hintText: 'Enter your password',
                      controller: _passCtrl,
                      obscureText: _obscure,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: Text(AppStrings.forgotPassword,
                            style: AppTextStyles.linkText),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => CustomButton(
                        text: AppStrings.login,
                        onPressed: state is AuthLoading ? null : _login,
                        isLoading: state is AuthLoading,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13)),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context
                            .read<AuthBloc>()
                            .add(const GoogleSignInEvent()),
                        icon: Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4)),
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
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(AppStrings.dontHaveAccount,
                          style: AppTextStyles.bodyText),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, RouteNames.signup),
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
