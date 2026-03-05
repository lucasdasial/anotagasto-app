import 'package:anotagasto_app/app/routes.dart';
import 'package:anotagasto_app/core/models/user_model.dart';
import 'package:anotagasto_app/core/theme/app_colors.dart';
import 'package:anotagasto_app/core/utils/constants.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/core/widgets/error_banner.dart';
import 'package:anotagasto_app/features/profile/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // StatefulWidget needed for addListener/removeListener lifecycle.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().addListener(_onStateChange);
    });
  }

  @override
  void dispose() {
    context.read<ProfileViewModel>().removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (context.read<ProfileViewModel>().loggedOut) {
      Navigator.of(context).pushReplacementNamed(Routes.login.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<ProfileViewModel>().viewState;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hPadding = constraints.maxWidth >= 600
            ? Constants.paddingPage
            : Constants.paddingPage * 0.67;

        if (viewState is LoadingStateView) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewState is ErrorStateView) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: ErrorBanner(
                message: viewState.message,
                onRetry: () => context.read<ProfileViewModel>().loadUser(),
              ),
            ),
          );
        }

        if (viewState is SuccessStateView<UserModel>) {
          return _ProfileContent(
            user: viewState.data,
            hPadding: hPadding,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;
  final double hPadding;

  const _ProfileContent({required this.user, required this.hPadding});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPadding, 32, hPadding, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user.phone,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () => context.read<ProfileViewModel>().logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
