import 'package:appkilosremitidos/core/constants/app_routes.dart';
import 'package:appkilosremitidos/core/constants/app_strings.dart';
import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:appkilosremitidos/core/utils/input_validators.dart';
import 'package:appkilosremitidos/widgets/custom_button.dart';
import 'package:appkilosremitidos/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final AuthProvider authProvider;

  const LoginForm({super.key, required this.authProvider});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await widget.authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        _showSuccessFeedback();
      } else {
        _showErrorFeedback(
          widget.authProvider.errorMessage ?? AppStrings.invalidCredentials,
        );
      }
    } catch (e) {
      _showErrorFeedback('Error de conexión');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessFeedback() {
    // Animación de éxito
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final overlaySize = overlay.size;

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: overlaySize.height * 0.15,
        left: overlaySize.width * 0.1,
        width: overlaySize.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSuccessFeedback(
            onComplete: () {
              overlayEntry?.remove();
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void _showErrorFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        elevation: 10,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de usuario con animación
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: CustomTextField(
              key: const ValueKey('username_field'),
              label: AppStrings.username,
              controller: _usernameController,
              validator: InputValidators.validateUsername,
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          // Campo de contraseña con animación
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: CustomTextField(
              key: const ValueKey('password_field'),
              label: AppStrings.password,
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: InputValidators.validatePassword,
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Botón de login con efecto de carga
          CustomButton(
            text: AppStrings.login,
            onPressed: _isSubmitting ? null : _submitForm,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}

// Widget para feedback visual de éxito
class AnimatedSuccessFeedback extends StatefulWidget {
  final VoidCallback onComplete;

  const AnimatedSuccessFeedback({super.key, required this.onComplete});

  @override
  State<AnimatedSuccessFeedback> createState() =>
      _AnimatedSuccessFeedbackState();
}

class _AnimatedSuccessFeedbackState extends State<AnimatedSuccessFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(20),
              color: Colors.green[600],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppStrings.loginSuccess,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
