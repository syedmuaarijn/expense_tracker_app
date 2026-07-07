import 'package:flutter/material.dart';

class CategoryIconInfo {
  final String emoji;
  final List<Color> gradientColors;

  const CategoryIconInfo({required this.emoji, required this.gradientColors});
}

class CategoryIconHelper {
  static CategoryIconInfo getIconInfo(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('food') || lowerName.contains('drink') || lowerName.contains('eat') || lowerName.contains('restaurant')) {
      return const CategoryIconInfo(
        emoji: '🍔',
        gradientColors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
      );
    } else if (lowerName.contains('transport') || lowerName.contains('uber') || lowerName.contains('car') || lowerName.contains('taxi') || lowerName.contains('ride')) {
      return const CategoryIconInfo(
        emoji: '🚗',
        gradientColors: [Color(0xFFFAD961), Color(0xFFF76B1C)],
      );
    } else if (lowerName.contains('bill') || lowerName.contains('elect') || lowerName.contains('water') || lowerName.contains('power') || lowerName.contains('utility') || lowerName.contains('phone')) {
      return const CategoryIconInfo(
        emoji: '⚡',
        gradientColors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      );
    } else if (lowerName.contains('shop') || lowerName.contains('clothe') || lowerName.contains('shoe') || lowerName.contains('nike') || lowerName.contains('apple')) {
      return const CategoryIconInfo(
        emoji: '👕',
        gradientColors: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
      );
    } else if (lowerName.contains('entertainment') || lowerName.contains('movie') || lowerName.contains('wants') || lowerName.contains('game')) {
      return const CategoryIconInfo(
        emoji: '🍿',
        gradientColors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
      );
    } else if (lowerName.contains('need')) {
      return const CategoryIconInfo(
        emoji: '🛡️',
        gradientColors: [Color(0xFFFF0844), Color(0xFFFFB199)],
      );
    } else if (lowerName.contains('health') || lowerName.contains('doctor') || lowerName.contains('medicine')) {
      return const CategoryIconInfo(
        emoji: '🏥',
        gradientColors: [Color(0xFFFAD961), Color(0xFFF76B1C)],
      );
    } else if (lowerName.contains('education') || lowerName.contains('book') || lowerName.contains('school')) {
      return const CategoryIconInfo(
        emoji: '📚',
        gradientColors: [Color(0xFF30CFD0), Color(0xFF330867)],
      );
    }
    
    // Default
    return const CategoryIconInfo(
      emoji: '🏷️',
      gradientColors: [Color(0xFFE2D1F9), Color(0xFFC7B1F6)],
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
            color: info.gradientColors[0].withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        info.emoji,
        style: TextStyle(
          fontSize: size * 0.5,
        ),
      ),
    );
  }
}
