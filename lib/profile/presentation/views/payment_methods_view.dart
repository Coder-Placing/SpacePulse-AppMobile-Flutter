import 'package:flutter/material.dart';
import 'package:tfmoviles2/iam/domain/models/payment_method.dart';
import 'package:tfmoviles2/iam/domain/repositories/auth_repository.dart';
import 'package:tfmoviles2/service_locator.dart';
import 'package:tfmoviles2/shared/domain/services/storage_service.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';

class PaymentMethodsView extends StatefulWidget {
  const PaymentMethodsView({super.key});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  List<PaymentMethod> _methods = [];
  bool _isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userData = await getIt<StorageService>().getUserData();
    _userId = userData['id'] ?? '';
    
    if (_userId.isNotEmpty) {
      final user = await getIt<AuthRepository>().getUserById(_userId);
      if (user != null) {
        setState(() {
          _methods = user.paymentMethods;
        });
      }
    }
    setState(() => _isLoading = false);
  }

  void _showAddPaymentMethodModal() {
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    String selectedType = 'VISA';

    final paymentTypes = [
      {'display': 'Visa', 'value': 'VISA'},
      {'display': 'MasterCard', 'value': 'MC'},
      {'display': 'Dinners', 'value': 'DINNERS'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Añadir Tarjeta',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      labelText: 'Tipo de tarjeta',
                      labelStyle: const TextStyle(color: AppColors.secondaryText),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5)),
                      ),
                    ),
                    items: paymentTypes.map((type) => DropdownMenuItem(
                      value: type['value'],
                      child: Text(type['display']!),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setStateModal(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: numberController,
                    style: const TextStyle(color: AppColors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Número de tarjeta',
                      labelStyle: const TextStyle(color: AppColors.secondaryText),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: expiryController,
                          style: const TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            hintStyle: const TextStyle(color: AppColors.secondaryText),
                            labelText: 'Expiración',
                            labelStyle: const TextStyle(color: AppColors.secondaryText),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: cvvController,
                          style: const TextStyle(color: AppColors.white),
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            labelStyle: const TextStyle(color: AppColors.secondaryText),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final success = await getIt<AuthRepository>().addPaymentMethod(_userId, {
                          'type': selectedType,
                          'number': numberController.text.trim(),
                          'expiry': expiryController.text.trim(),
                          'cvv': cvvController.text.trim(),
                        });

                        if (success) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            _loadData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tarjeta añadida con éxito')),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al añadir tarjeta')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Guardar Tarjeta',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Métodos de Pago', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.white))
          : _methods.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes tarjetas registradas',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _methods.length,
                  itemBuilder: (context, index) {
                    final method = _methods[index];
                    return Card(
                      color: AppColors.cardBackground,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(
                          method.type.toUpperCase() == 'VISA'
                              ? Icons.credit_card
                              : Icons.payment,
                          color: AppColors.primaryButton,
                          size: 32,
                        ),
                        title: Text(
                          '${method.type} **** ${method.lastFourDigits}',
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Expira: ${method.expiry}',
                          style: const TextStyle(color: AppColors.secondaryText),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentMethodModal,
        backgroundColor: AppColors.primaryButton,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
