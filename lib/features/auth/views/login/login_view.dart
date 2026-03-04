import 'package:anotagasto_app/app/routes.dart';
import 'package:anotagasto_app/core/utils/phone_formatter.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/core/widgets/app_snack_bar.dart';
import 'package:anotagasto_app/features/auth/views/login/login_view_model.dart';
import 'package:anotagasto_app/features/auth/views/login/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginViewModel>().addListener(_onStateChange);
    });
  }

  @override
  void dispose() {
    context.read<LoginViewModel>().removeListener(_onStateChange);
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onStateChange() {
    final state = context.read<LoginViewModel>().viewState;

    if (state is SuccessStateView) {
      Navigator.of(context).pushReplacementNamed(Routes.expenseList.name);
    }

    if (state is ErrorStateView) {
      AppSnackBar.error(context, state.message);
      context.read<LoginViewModel>().resetViewState();
    }
  }

  void _submit(String phone, String pass) {
    if (!_formKey.currentState!.validate()) return;
    final digits = PhoneMaskFormatter.unmasked(phone);
    context.read<LoginViewModel>().onSubmit(digits, pass);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<LoginViewModel, bool>(
      (vm) => vm.viewState is LoadingStateView,
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              PhoneMaskFormatter(),
            ],
            decoration: const InputDecoration(
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
            validator: (v) =>
                v == null || v.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () => _submit(_phoneCtrl.text, _passCtrl.text),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Entrar'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Não tem conta? '),
              TextButton(
                onPressed: () => AppSnackBar.info(context, 'Em breve'),
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
