import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 80.0,
    this.showText = false, // Default to false - no text in logo
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Professional Logo Container with Car Image
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.95),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background gradient
                Container(
                  width: size * 0.95,
                  height: size * 0.95,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.05),
                        AppTheme.primaryColor.withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
                
                // Car Logo Image - Using the uploaded logo
                Image.asset(
                  'assets/images/car_logo.png', // Update this path with your actual logo file
                  width: size * 0.65,
                  height: size * 0.65,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image not found
                    return Icon(
                      Icons.directions_car_rounded,
                      size: size * 0.45,
                      color: AppTheme.primaryColor,
                    );
                  },
                ),
                
                // Decorative ring
                Container(
                  width: size * 0.9,
                  height: size * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'SmartCAR',
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1.8,
              shadows: [
                Shadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Premium Rentals',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor.withOpacity(0.8),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}

// Alternative version with different logo options
class AppLogoVariant extends StatelessWidget {
  final double size;
  final bool showText;
  final String logoAsset; // Allow different logo assets

  const AppLogoVariant({
    super.key,
    required this.logoAsset,
    this.size = 80.0,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Professional Logo Container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Car Logo Image
                Image.asset(
                  logoAsset,
                  width: size * 0.7,
                  height: size * 0.7,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.directions_car_rounded,
                      size: size * 0.45,
                      color: AppTheme.primaryColor,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'SmartCAR',
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Premium Rentals',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor.withOpacity(0.8),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}

// For future use with actual logo image
class AppLogoImage extends StatelessWidget {
  final double size;
  final String logoPath;
  final bool showText;

  const AppLogoImage({
    super.key,
    required this.logoPath,
    this.size = 80.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Professional Logo Container with Image
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.95),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Your actual logo image goes here
                Image.asset(
                  logoPath,
                  width: size * 0.8,
                  height: size * 0.8,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.directions_car_rounded,
                      size: size * 0.45,
                      color: AppTheme.primaryColor,
                    );
                  },
                ),
                
                // Decorative overlay if needed
                Container(
                  width: size * 0.9,
                  height: size * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'SmartCAR',
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1.8,
              shadows: [
                Shadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Premium Rentals',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor.withOpacity(0.8),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}
