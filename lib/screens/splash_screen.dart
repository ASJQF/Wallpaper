import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import 'onboarding_screen.dart';
import 'shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  var _gone = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _boot();
    });
  }

  Future<void> _boot() async {
    final controller = context.read<AppController>();
    await Future.wait([
      controller.ensurePreferences(
        WidgetsBinding.instance.platformDispatcher.locale,
      ),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);
    controller.ensureLoaded();
    _open();
  }

  void _open() {
    if (!mounted || _gone) return;
    final controller = context.read<AppController>();
    if (!controller.preferencesReady) {
      controller
          .ensurePreferences(WidgetsBinding.instance.platformDispatcher.locale)
          .then((_) {
            if (mounted) _open();
          });
      return;
    }
    _gone = true;
    final completed = context.read<AppController>().onboardingCompleted;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) {
          return completed ? const ShellScreen() : const OnboardingScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    final logoScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    final textOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.28, 0.78, curve: Curves.easeOut),
    );
    final buttonOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.5, 1, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.45),
            radius: 1.05,
            colors: [AppColors.violet.withValues(alpha: 0.42), AppColors.bg],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),
                FadeTransition(
                  opacity: logoOpacity,
                  child: ScaleTransition(
                    scale: logoScale,
                    child: const AppLogo(size: 112),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: textOpacity,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return AppColors.brandGradient.createShader(bounds);
                        },
                        child: Text(
                          AppLocalizations.of(context).appTitle,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).tagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: buttonOpacity,
                  child: PrimaryButton(
                  label: AppLocalizations.of(context).start,
                  onPressed: _open,
                ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: buttonOpacity,
                  child: Text(
                    AppLocalizations.of(context).royaltyFree,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
