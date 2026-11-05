import 'package:flutter/material.dart';

/// A robust image loader for the Bhoomi app:
/// 1. Attempts to load local asset [imagePath].
/// 2. If image is unavailable or network fails, falls back to high-resolution agricultural CDN photo.
/// 3. If offline, falls back to an elegant agricultural themed container.
///
/// Guaranteed NEVER to throw or show Flutter's red X ErrorWidget on any platform (Web, Android, iOS).
class SafeLocalImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? fallback;
  final String? networkFallbackUrl;

  const SafeLocalImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.fallback,
    this.networkFallbackUrl,
  }) : super(key: key);

  static const Map<String, String> _defaultNetworkFallbacks = {
    'assets/images/mustard_crop.jpg':
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&auto=format&fit=crop',
    'assets/images/wheat_crop.jpg':
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800&auto=format&fit=crop',
    'assets/images/farmer_field.jpg':
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop',
    'assets/images/farmer_hero.jpg':
        'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=800&auto=format&fit=crop',
    'assets/images/optimized_farmland.jpg':
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&auto=format&fit=crop',
    'assets/images/tractor_rental.jpg':
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop',
    'assets/images/farmland_sale.jpg':
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&auto=format&fit=crop',
  };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) {
        // Fallback: High-resolution agricultural CDN photo matching the crop
        final netUrl = networkFallbackUrl ?? _defaultNetworkFallbacks[imagePath];
        if (netUrl != null) {
          return Image.network(
            netUrl,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) {
              return fallback ?? _buildPlaceholder();
            },
          );
        }

        // Final Fallback: Clean eco placeholder card
        return fallback ?? _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE2EFDF), Color(0xFFD3E7CE)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.agriculture_rounded,
        color: Color(0xFF1E4D2B),
        size: 28,
      ),
    );
  }
}
