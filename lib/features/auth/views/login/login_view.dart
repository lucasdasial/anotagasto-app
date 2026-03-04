import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/phone_formatter.dart';
import 'package:anotagasto_app/features/auth/views/login/login_view_model.dart';
import 'package:anotagasto_app/features/auth/views/login/widgets/password_field.dart';
import 'package:anotagasto_app/features/auth/views/login_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginViewModel>().viewState;
    final vm = context.read<LoginViewModel>();

    void submit(String phone, String pass) {
      if (!_formKey.currentState!.validate()) return;
      final digits = PhoneMaskFormatter.unmasked(phone);
      vm.onSubmit(digits, pass);
    }

    if (state is SuccessStateLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }

    if (state is ErrorStateLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ),
        );
        vm.resetViewState();
      });
    }

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
            onPressed: state is LoadingStateLogin
                ? null
                : () => submit(_phoneCtrl.text, _passCtrl.text),
            child: state is LoadingStateLogin
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
                onPressed: () => Navigator.of(context).pushNamed('/register'),
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
