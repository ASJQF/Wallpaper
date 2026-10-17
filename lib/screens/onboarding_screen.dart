import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_glass.dart';
import '../widgets/primary_button.dart';
import 'shell_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.replay = false});

  final bool replay;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  var _index = 0;

  List<_IntroPage> _pages(AppLocalizations l10n) {
    return [
      _IntroPage(
        icon: Icons.auto_awesome_rounded,
        title: l10n.onboard1Title,
        body: l10n.onboard1Body,
      ),
      _IntroPage(
        icon: Icons.bookmark_rounded,
        title: l10n.onboard2Title,
        body: l10n.onboard2Body,
      ),
      _IntroPage(
        icon: Icons.download_rounded,
        title: l10n.onboard3Title,
        body: l10n.onboard3Body,
      ),
    ];
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _finish() {
    final controller = context.read<AppController>();
    controller.completeOnboarding();
    if (widget.replay) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ShellScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _next(int count) {
    if (_index == count - 1) {
      _finish();
      return;
    }
    _page.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _pages(l10n);
    final last = _index == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(l10n.skip),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: pages.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) =>
                      _PageBody(page: pages[index]),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? AppColors.violet
                            : Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: last ? l10n.start : l10n.next,
                onPressed: () => _next(pages.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPage {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.page});

  final _IntroPage page;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandGradient,
                ),
              ),
              AuraGlass(
                width: 156,
                height: 156,
                borderRadius: 32,
                child: Icon(page.icon, size: 64, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          page.body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).hintColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
