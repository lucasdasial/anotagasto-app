import 'package:anotagasto_app/app/routes.dart';
import 'package:anotagasto_app/core/utils/phone_formatter.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/core/widgets/app_snack_bar.dart';
import 'package:anotagasto_app/features/auth/views/login/widgets/password_field.dart';
import 'package:anotagasto_app/features/auth/views/register/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// StatefulWidget needed for TextEditingController disposal and addListener lifecycle.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegisterViewModel>().addListener(_onStateChange);
    });
  }

  @override
  void dispose() {
    context.read<RegisterViewModel>().removeListener(_onStateChange);
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _onStateChange() {
    final state = context.read<RegisterViewModel>().viewState;

    if (state is SuccessStateView) {
      Navigator.of(context).pushReplacementNamed(Routes.expenseList.name);
    }

    if (state is ErrorStateView) {
      AppSnackBar.error(context, state.message);
      context.read<RegisterViewModel>().resetViewState();
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final phone = PhoneMaskFormatter.unmasked(_phoneCtrl.text);
    context
        .read<RegisterViewModel>()
        .onSubmit(_nameCtrl.text.trim(), phone, _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<RegisterViewModel, bool>(
      (vm) => vm.viewState is LoadingStateView,
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameCtrl,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.person_outline),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              PhoneMaskFormatter(),
            ],
            decoration: const InputDecoration(
              fillColor: Colors.white,
              labelText: 'Telefone',
              hintText: '(11) 99999-9999',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              final digits = PhoneMaskFormatter.unmasked(v ?? '');
              if (digits.isEmpty) return 'Campo obrigatório';
              if (digits.length < 11) return 'Telefone inválido';
              return null;
            },
          ),
          const SizedBox(height: 14),
          PasswordField(
            controller: _passCtrl,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Campo obrigatório';
              if (v.length < 6) return 'Mínimo de 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 14),
          PasswordField(
            controller: _confirmPassCtrl,
            label: 'Confirmar senha',
            validator: (v) {
              if (v == null || v.isEmpty) return 'Campo obrigatório';
              if (v != _passCtrl.text) return 'As senhas não coincidem';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Criar conta'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Já tem conta? '),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
