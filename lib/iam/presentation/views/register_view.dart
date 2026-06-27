import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';
import 'package:tfmoviles2/shared/presentation/components/custom_text_field.dart';
import 'package:tfmoviles2/iam/presentation/views/widgets/profile_image_picker.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  XFile? _profileImage;

  void _onImageSelected(XFile? image) {
    setState(() {
      _profileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C313C),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 60,
                          color: Colors.white,
                        ),
                        Positioned(
                          bottom: 12,
                          child: Container(
                            height: 2,
                            width: 50,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SpacePulse',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Profile Image Picker Component
                ProfileImagePicker(onImageSelected: _onImageSelected),
                
                const SizedBox(height: 24),
                const CustomTextField(label: 'Nombre completo', isLight: true),
                const SizedBox(height: 16),
                const CustomTextField(label: 'Correo electrónico', isLight: true),
                const SizedBox(height: 16),
                const CustomTextField(label: 'Teléfono', isLight: true),
                const SizedBox(height: 16),
                const CustomTextField(label: 'Contraseña', isPassword: true, isLight: true),
                const SizedBox(height: 16),
                const CustomTextField(label: 'Confirmar contraseña', isPassword: true, isLight: true),
                const SizedBox(height: 32),
                // Registrarme Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logic for registration
                      if (_profileImage != null) {
                        debugPrint('Registering with image: \${_profileImage!.name}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Registrarme',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Ya tengo una cuenta',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
}
