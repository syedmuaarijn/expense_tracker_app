import 'package:flutter/material.dart';

class CategoryIconInfo {
  final IconData icon;
  final List<Color> gradientColors;

  const CategoryIconInfo({
    required this.icon,
    required this.gradientColors,
  });
}

class CategoryIconHelper {
  static CategoryIconInfo getIconInfo(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('food') ||
        lower.contains('drink') ||
        lower.contains('eat') ||
        lower.contains('restaurant') ||
        lower.contains('cafe') ||
        lower.contains('coffee') ||
        lower.contains('lunch') ||
        lower.contains('dinner')) {
      return const CategoryIconInfo(
        icon: Icons.restaurant_rounded,
        gradientColors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      );
    }

    if (lower.contains('transport') ||
        lower.contains('uber') ||
        lower.contains('car') ||
        lower.contains('taxi') ||
        lower.contains('ride') ||
        lower.contains('bus') ||
        lower.contains('fuel') ||
        lower.contains('petrol') ||
        lower.contains('gas') ||
        lower.contains('train') ||
        lower.contains('metro')) {
      return const CategoryIconInfo(
        icon: Icons.directions_car_rounded,
        gradientColors: [Color(0xFFFAD961), Color(0xFFF76B1C)],
      );
    }

    if (lower.contains('bill') ||
        lower.contains('elect') ||
        lower.contains('water') ||
        lower.contains('power') ||
        lower.contains('utility') ||
        lower.contains('internet') ||
        lower.contains('phone') ||
        lower.contains('mobile') ||
        lower.contains('broadband')) {
      return const CategoryIconInfo(
        icon: Icons.bolt_rounded,
        gradientColors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      );
    }

    if (lower.contains('shop') ||
        lower.contains('cloth') ||
        lower.contains('shoe') ||
        lower.contains('fashion') ||
        lower.contains('market') ||
        lower.contains('grocery') ||
        lower.contains('groceries') ||
        lower.contains('supermarket')) {
      return const CategoryIconInfo(
        icon: Icons.shopping_bag_rounded,
        gradientColors: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
      );
    }

    if (lower.contains('entertainment') ||
        lower.contains('movie') ||
        lower.contains('cinema') ||
        lower.contains('game') ||
        lower.contains('netflix') ||
        lower.contains('spotify') ||
        lower.contains('stream') ||
        lower.contains('music')) {
      return const CategoryIconInfo(
        icon: Icons.movie_rounded,
        gradientColors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
      );
    }

    if (lower.contains('health') ||
        lower.contains('doctor') ||
        lower.contains('medicine') ||
        lower.contains('pharmacy') ||
        lower.contains('hospital') ||
        lower.contains('medical')) {
      return const CategoryIconInfo(
        icon: Icons.local_hospital_rounded,
        gradientColors: [Color(0xFFFF0844), Color(0xFFFFB199)],
      );
    }

    if (lower.contains('education') ||
        lower.contains('book') ||
        lower.contains('school') ||
        lower.contains('course') ||
        lower.contains('tuition') ||
        lower.contains('college') ||
        lower.contains('university')) {
      return const CategoryIconInfo(
        icon: Icons.school_rounded,
        gradientColors: [Color(0xFF30CFD0), Color(0xFF330867)],
      );
    }

    if (lower.contains('home') ||
        lower.contains('rent') ||
        lower.contains('house') ||
        lower.contains('mortgage') ||
        lower.contains('maintenance')) {
      return const CategoryIconInfo(
        icon: Icons.home_rounded,
        gradientColors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
      );
    }

    if (lower.contains('travel') ||
        lower.contains('hotel') ||
        lower.contains('flight') ||
        lower.contains('trip') ||
        lower.contains('vacation')) {
      return const CategoryIconInfo(
        icon: Icons.flight_rounded,
        gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      );
    }

    if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('sport') ||
        lower.contains('workout')) {
      return const CategoryIconInfo(
        icon: Icons.fitness_center_rounded,
        gradientColors: [Color(0xFFFF9A9E), Color(0xFFFF6A88)],
      );
    }

    if (lower.contains('gift') ||
        lower.contains('donation') ||
        lower.contains('charity')) {
      return const CategoryIconInfo(
        icon: Icons.card_giftcard_rounded,
        gradientColors: [Color(0xFFF093FB), Color(0xFFF5576C)],
      );
    }

    if (lower.contains('salary') ||
        lower.contains('income') ||
        lower.contains('paycheck')) {
      return const CategoryIconInfo(
        icon: Icons.account_balance_wallet_rounded,
        gradientColors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
      );
    }

    if (lower.contains('need') || lower.contains('essential')) {
      return const CategoryIconInfo(
        icon: Icons.shield_rounded,
        gradientColors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      );
    }

    if (lower.contains('want') || lower.contains('luxury')) {
      return const CategoryIconInfo(
        icon: Icons.star_rounded,
        gradientColors: [Color(0xFFFCB045), Color(0xFFFC6076)],
      );
    }

    if (lower.contains('saving') || lower.contains('invest')) {
      return const CategoryIconInfo(
        icon: Icons.savings_rounded,
        gradientColors: [Color(0xFF11998E), Color(0xFF38EF7D)],
      );
    }

    // Default fallback
    return const CategoryIconInfo(
      icon: Icons.attach_money_rounded,
      gradientColors: [Color(0xFFE2D1F9), Color(0xFF9B59B6)],
    );
  }
}

class CategoryIconWidget extends StatelessWidget {
  final String categoryName;
  final double size;

  const CategoryIconWidget({
    super.key,
    required this.categoryName,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final info = CategoryIconHelper.getIconInfo(categoryName);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: info.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: info.gradientColors[0].withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        info.icon,
        color: Colors.white,
        size: size * 0.48,
      ),
    );
  }
}
