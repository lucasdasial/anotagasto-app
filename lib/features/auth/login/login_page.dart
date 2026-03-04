import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePass = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      // key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            // controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              hintText: 'Ex: 11999999999',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            // controller: _passCtrl,
            // obscureText: _obscurePass,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => obscurePass = !obscurePass),
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) =>
                v == null || v.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(child: const Text('Entrar'), onPressed: () {}),
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
