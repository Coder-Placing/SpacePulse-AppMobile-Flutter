import 'package:flutter/material.dart';
import '../../../spaces/presentation/views/spaces_view.dart';
import '../../../home/presentation/views/home_view.dart';
// import '../../../alerts/presentation/views/alerts_view.dart'; // To be created

// 1. IMPORTAMOS NUESTRA VISTA DEFINITIVA DE IOT
import '../../../iot/presentation/views/iot_view.dart';

import '../../../profile/presentation/views/profile_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0; // Default to Home

  final List<Widget> _pages = [
    const HomeView(),
    const SpacesView(),
    const Center(child: Text('Alertas')), // Placeholder for Alertas

    // 2. COLOCAMOS EL IOTVIEW AQUÍ (En la posición de índice 3)
    const IotView(),

    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // To show more than 3 items properly
        backgroundColor: const Color(0xFF1E1E1E), // Mantiene tu tema oscuro en el menú
        selectedItemColor: Colors.blueAccent, // Color del ícono cuando está seleccionado
        unselectedItemColor: Colors.grey, // Color de los íconos inactivos
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard),
            label: 'Espacios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.router),
            label: 'IoT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mi Perfil',
          ),
        ],
      ),
    );
  }
}