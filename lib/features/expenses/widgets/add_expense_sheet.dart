import 'dart:ui';

import 'package:anotagasto_app/core/models/expense_category.dart';
import 'package:anotagasto_app/core/models/expense_model.dart';
import 'package:anotagasto_app/core/utils/date_formatter.dart';
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
  return _showSheet(context, vm, null);
}

Future<void> showEditExpenseSheet(BuildContext context, ExpenseModel expense) {
  final vm = context.read<ExpensesViewModel>();
  return _showSheet(context, vm, expense);
}

Future<void> _showSheet(
  BuildContext context,
  ExpensesViewModel vm,
  ExpenseModel? initialExpense,
) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.transparent,
    pageBuilder: (_, _, _) =>
        _AddExpenseSheetPage(viewModel: vm, initialExpense: initialExpense),
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
  final ExpenseModel? initialExpense;

  const _AddExpenseSheetPage({
    required this.viewModel,
    this.initialExpense,
  });

  @override
  State<_AddExpenseSheetPage> createState() => _AddExpenseSheetPageState();
}

class _AddExpenseSheetPageState extends State<_AddExpenseSheetPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descCtrl;
  late final TextEditingController _valueCtrl;
  late ExpenseCategory _category;
  late DateTime _selectedDate;
  bool _loading = false;

  bool get _isEditing => widget.initialExpense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    _descCtrl = TextEditingController(text: expense?.description ?? '');
    _category = expense?.category ?? ExpenseCategory.uncategorized;
    _selectedDate = expense?.date ?? DateTime.now();
    _valueCtrl = TextEditingController(
      text: expense != null ? _formatCents(expense.value) : '',
    );
  }

  String _formatCents(int cents) {
    return (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
  }

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
      if (_isEditing) {
        await widget.viewModel.editExpense(
          id: widget.initialExpense!.id,
          value: _valueCents,
          description: _descCtrl.text.trim(),
          category: _category,
          date: _selectedDate,
        );
      } else {
        await widget.viewModel.addExpense(
          value: _valueCents,
          description: _descCtrl.text.trim(),
          category: _category,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          e.response?.data['error'] ??
              (_isEditing
                  ? 'Erro ao editar despesa.'
                  : 'Erro ao adicionar despesa.'),
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: const SizedBox.expand(),
        ),
        Align(
          alignment: isDesktop ? Alignment.center : Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 520 : 600,
                ),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.only(
                    bottom: isDesktop ? 0 : bottomInset,
                    left: isDesktop ? 16 : 0,
                    right: isDesktop ? 16 : 0,
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      Constants.paddingPage,
                      isDesktop ? 20 : 20,
                      Constants.paddingPage,
                      Constants.paddingPage,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: isDesktop
                          ? BorderRadius.circular(16)
                          : const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isDesktop)
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDim,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                _isEditing ? 'Editar despesa' : 'Novo Gasto',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (isDesktop)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: AppColors.onSurfaceVariant,
                                  onPressed: () => Navigator.of(context).pop(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _valueCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_CurrencyInputFormatter()],
                            textAlign: TextAlign.end,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
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
                              hintText: 'No que você gastou?',
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Informe a descrição'
                                    : null,
                          ),
                          if (_isEditing) ...[
                            const SizedBox(height: 12),
                            _DatePickerRow(
                              date: _selectedDate,
                              onChanged: (d) =>
                                  setState(() => _selectedDate = d),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Categoria',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (isDesktop)
                            _CategoryGrid(
                              selected: _category,
                              onSelect: (cat) =>
                                  setState(() => _category = cat),
                            )
                          else
                            _CategoryScroll(
                              selected: _category,
                              onSelect: (cat) =>
                                  setState(() => _category = cat),
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
                                : Text(_isEditing ? 'Salvar' : 'Adicionar'),
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

// ---------------------------------------------------------------------------
// Category selectors
// ---------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onSelect;

  const _CategoryGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        physics: const ClampingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisExtent: 76,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: ExpenseCategory.values.length,
        itemBuilder: (_, index) {
          final cat = ExpenseCategory.values[index];
          final isSelected = selected == cat;
          return InkWell(
            onTap: () => onSelect(cat),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryScroll extends StatelessWidget {
  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onSelect;

  const _CategoryScroll({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ExpenseCategory.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final cat = ExpenseCategory.values[index];
            return CategoryChip(
              category: cat,
              selected: selected == cat,
              onTap: () => onSelect(cat),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date picker row
// ---------------------------------------------------------------------------

class _DatePickerRow extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerRow({required this.date, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              DateFormatter.formatDate(date),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.onSurfaceMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Currency input formatter
// ---------------------------------------------------------------------------

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
