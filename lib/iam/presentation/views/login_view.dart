import 'package:flutter/material.dart';
import 'package:tfmoviles2/iam/domain/repositories/auth_repository.dart';
import 'package:tfmoviles2/service_locator.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';
import 'package:tfmoviles2/shared/presentation/components/custom_text_field.dart';
import 'package:tfmoviles2/iam/presentation/views/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final authRepository = getIt<AuthRepository>();
    final user = await authRepository.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login exitoso')),
        );
        // Navegar a la pantalla principal aquí
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en el login')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C313C).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 70,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        Positioned(
                          bottom: 15,
                          child: Container(
                            height: 2,
                            width: 60,
                            color: Colors.orangeAccent.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'SpacePulse',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 60),
                CustomTextField(
                  label: 'Correo',
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Contraseña',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF243447),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  '¿No tienes cuenta?',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterView()),
                    );
                  },
                  child: const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
