import 'dart:ui';

import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/constants.dart';
import 'package:anotagasto_app/core/widgets/app_snack_bar.dart';
import 'package:anotagasto_app/core/widgets/category_chip.dart';
import 'package:anotagasto_app/features/expenses/expenses_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> showAddExpenseSheet(BuildContext context) {
  final vm = context.read<ExpensesViewModel>();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.transparent,
    pageBuilder: (_, _, _) => _AddExpenseSheetPage(viewModel: vm),
    transitionBuilder: (_, anim, _, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class _AddExpenseSheetPage extends StatefulWidget {
  final ExpensesViewModel viewModel;

  const _AddExpenseSheetPage({required this.viewModel});

  @override
  State<_AddExpenseSheetPage> createState() => _AddExpenseSheetPageState();
}

class _AddExpenseSheetPageState extends State<_AddExpenseSheetPage> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.uncategorized;
  bool _loading = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  int get _valueCents {
    final digits = _valueCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.viewModel.addExpense(
        value: _valueCents,
        description: _descCtrl.text.trim(),
        category: _category,
      );
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          e.response?.data['error'] ?? 'Erro ao adicionar despesa.',
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(
          context,
          'Ocorreu um erro inesperado. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: const SizedBox.expand(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      Constants.paddingPage,
                      20,
                      Constants.paddingPage,
                      Constants.paddingPage,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDim,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Nova despesa',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _valueCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_CurrencyInputFormatter()],
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              prefixText: 'R\$  ',
                              hintText: '0,00',
                            ),
                            validator: (_) =>
                                _valueCents <= 0 ? 'Informe um valor' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Descrição',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Informe a descrição'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 36,
                            child: ScrollConfiguration(
                              behavior:
                                  ScrollConfiguration.of(context).copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                },
                              ),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: ExpenseCategory.values.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (_, index) {
                                  final cat = ExpenseCategory.values[index];
                                  return CategoryChip(
                                    category: cat,
                                    selected: _category == cat,
                                    onTap: () =>
                                        setState(() => _category = cat),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Adicionar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final cents = int.tryParse(digits) ?? 0;
    final formatted = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
