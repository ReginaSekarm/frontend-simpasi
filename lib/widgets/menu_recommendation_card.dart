import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

import 'recipe_store.dart';

class MenuRecommendationCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String badge;
  final VoidCallback onTap;

  const MenuRecommendationCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.badge,
    required this.onTap,
  });

  static const Color _badgeYellow = Color(0xFFFFB636);
  static const Color _heartRed    = Color(0xFFDD2E44);
  static const Color _fireOrange  = Color(0xFFFF8F1F);
  static const Color _textBlack   = Color(0xFF000000);
  static const Color _textGrey    = Color(0xFF8F8F8F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 144,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _textBlack, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 13, 9, 0),
              child: SizedBox(
                width: 125,
                height: 123,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePath,
                        width: 125,
                        height: 123,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 125,
                          height: 123,
                          color: _textGrey,
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 7,
                      left: 6,
                      child: Container(
                        height: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _badgeYellow,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          badge,
                          style: google_fonts.GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            height: 12 / 10,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 10,
                      child: ValueListenableBuilder<Set<String>>(
                        valueListenable: RecipeStore.favorites,
                        builder: (_, favs, __) {
                          final liked = favs.contains(title);
                          return GestureDetector(
                            onTap: () => RecipeStore.toggle(title),
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              liked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: liked ? _heartRed : _textBlack,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 8, 9, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: _textBlack,
                      height: 12 / 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 12,
                        color: _fireOrange,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '320 kkal',
                        style: google_fonts.GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: _textBlack,
                          height: 12 / 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}