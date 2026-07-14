import 'package:flutter/material.dart';
import 'dart:io'; 
import 'welcome_page.dart';
import 'dashboard_page.dart';

class OptionPage extends StatefulWidget {
  const OptionPage({super.key});

  @override
  State<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;

  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _titleAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    ));
    _titleController.forward();

    _cardController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _cardAnimation = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));
    _cardController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _navigate(BuildContext context, String userType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            userType == 'Patient' ? const WelcomePage() : DashboardPage(),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              TweenAnimationBuilder(
                duration: const Duration(seconds: 2),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(0, (1 - value) * 30),
                  child: Opacity(opacity: value, child: child),
                ),
                
              ),
              const SizedBox(height: 20),
              const Text(
                "Thank You..",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );

  
    Future.delayed(const Duration(seconds: 3), () {
      exit(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Deep Premium Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Ambient Glow Orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 150, spreadRadius: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.25), blurRadius: 150, spreadRadius: 100),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: isMobile
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _titleAnimation,
                          child: const AppTitle(),
                        ),
                        const SizedBox(height: 50),
                        ScaleTransition(
                          scale: _cardAnimation,
                          child: OptionCard(
                            icon: Icons.person_outline,
                            label: 'Patient',
                            onTap: () => _navigate(context, 'Patient'),
                          ),
                        ),
                        const SizedBox(height: 25),
                        ScaleTransition(
                          scale: _cardAnimation,
                          child: OptionCard(
                            icon: Icons.admin_panel_settings_outlined,
                            label: 'Admin',
                            onTap: () => _navigate(context, 'Admin'),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _titleAnimation,
                          child: const Expanded(child: AppTitle()),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: _cardAnimation,
                                child: OptionCard(
                                  icon: Icons.person_outline,
                                  label: 'Patient',
                                  onTap: () =>
                                      _navigate(context, 'Patient'),
                                ),
                              ),
                              const SizedBox(height: 25),
                              ScaleTransition(
                                scale: _cardAnimation,
                                child: OptionCard(
                                  icon: Icons.admin_panel_settings_outlined,
                                  label: 'Admin',
                                  onTap: () =>
                                      _navigate(context, 'Admin'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.redAccent,
              onPressed: _showExitDialog,
              child: const Icon(Icons.exit_to_app, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Appointment Booking',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.8,
        shadows: [
          Shadow(
            blurRadius: 12,
            color: Colors.black54,
            offset: Offset(3, 3),
          ),
        ],
      ),
    );
  }
}


class OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white.withValues(alpha: 0.95),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: const Color(0xFF2563EB).withValues(alpha: 0.2),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFEFF6FF), // Soft Blue
                child: Icon(
                  icon,
                  size: 30,
                  color: const Color(0xFF2563EB), // Primary Blue
                ),
              ),
              const SizedBox(width: 22),
              Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
