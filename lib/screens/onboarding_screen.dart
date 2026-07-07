import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/expense_provider.dart';
import 'nav_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  // Onboarding pages data
  static const List<_OnboardPage> _pages = [
    _OnboardPage(
      icon: Icons.receipt_long_rounded,
      title: 'Track Every\nExpense',
      subtitle: 'Log your spending instantly — categorize, tag and\nmonitor where your money goes.',
      iconColor: Color(0xFFE36F47),
      glowColor: Color(0xFFE36F47),
      accentGradient: [Color(0xFF3D1D50), Color(0xFF1B0B24)],
    ),
    _OnboardPage(
      icon: Icons.bar_chart_rounded,
      title: 'Understand\nYour Habits',
      subtitle: 'Visualize monthly spending patterns with\nbeautiful charts and category breakdowns.',
      iconColor: Color(0xFFD3B0E8),
      glowColor: Color(0xFFD3B0E8),
      accentGradient: [Color(0xFF2A1637), Color(0xFF1B0B24)],
    ),
    _OnboardPage(
      icon: Icons.person_rounded,
      title: null, // Profile input page
      subtitle: null,
      iconColor: Color(0xFFE36F47),
      glowColor: Color(0xFFE36F47),
      accentGradient: [Color(0xFF3D1D50), Color(0xFF1B0B24)],
    ),
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0.18, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeInOutCubic),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onPageChanged(int idx) {
    setState(() => _currentPage = idx);
    _contentController.forward(from: 0);
  }

  void _onContinue() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      if (_formKey.currentState!.validate()) {
        HapticFeedback.mediumImpact();
        Provider.of<ExpenseProvider>(context, listen: false)
            .saveProfile(_nameController.text.trim());
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const NavShell(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1B0B24),
      body: Stack(
        children: [
          // ── Full-screen gradient background ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _pages[_currentPage].accentGradient,
              ),
            ),
          ),

          // ── Decorative top arc ──
          Positioned(
            top: -size.width * 0.4,
            left: -size.width * 0.2,
            right: -size.width * 0.2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: size.width * 1.4,
              height: size.width * 1.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _pages[_currentPage].glowColor.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Page content ──
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                      child: _currentPage < _pages.length - 1
                          ? GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  _pages.length - 1,
                                  duration:
                                      const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                );
                              },
                              child: Text(
                                'Skip',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white38,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : const SizedBox(height: 24),
                    ),
                  ),

                  // ── PageView ──
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (ctx, i) {
                        if (i == _pages.length - 1) {
                          return _buildProfilePage();
                        }
                        return _buildFeaturePage(_pages[i]);
                      },
                    ),
                  ),

                  // ── Page indicators ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE36F47)
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Continue / Launch button ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                    child: GestureDetector(
                      onTap: _onContinue,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE36F47),
                              Color(0xFFC85A36),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFE36F47).withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1
                                    ? "Let's Go"
                                    : 'Continue',
                                style: GoogleFonts.dmSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Feature page (page 1 & 2) ───────────────────────────────────────────

  Widget _buildFeaturePage(_OnboardPage page) {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Big rounded icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      page.iconColor.withOpacity(0.25),
                      page.iconColor.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: page.iconColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: page.glowColor.withOpacity(0.2),
                      blurRadius: 24,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 44,
                  color: page.iconColor,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                page.title!,
                style: GoogleFonts.dmSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 18),

              // Subtitle
              Text(
                page.subtitle!,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Profile input page (last page) ──────────────────────────────────────

  Widget _buildProfilePage() {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE36F47).withOpacity(0.25),
                      const Color(0xFFE36F47).withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: const Color(0xFFE36F47).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE36F47).withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  size: 44,
                  color: Color(0xFFE36F47),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "What's your\nname?",
                style: GoogleFonts.dmSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Personalise your Trackly experience.',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              // Name text field — styled to match dark theme
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: const Color(0xFFE36F47),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle: GoogleFonts.dmSans(
                    color: Colors.white24,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFFE36F47),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.07),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE36F47),
                      width: 1.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Colors.redAccent, width: 1.0),
                  ),
                  errorStyle: GoogleFonts.dmSans(
                    color: Colors.redAccent.shade100,
                    fontSize: 12,
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter your name'
                    : null,
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data model for onboarding pages ──────────────────────────────────────

class _OnboardPage {
  final IconData icon;
  final String? title;
  final String? subtitle;
  final Color iconColor;
  final Color glowColor;
  final List<Color> accentGradient;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.glowColor,
    required this.accentGradient,
  });
}