import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

import '../utils/responsive.dart';
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
    final radius = BorderRadius.circular(context.w(10));

    // Material + InkWell: ada efek riak saat kartu ditekan
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: _textBlack, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: context.w(144),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(9),
                  context.w(13),
                  context.w(9),
                  0,
                ),
                child: SizedBox(
                  width: context.w(125),
                  height: context.w(123),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(context.w(10)),
                        child: Image.asset(
                          imagePath,
                          width: context.w(125),
                          height: context.w(123),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: context.w(125),
                            height: context.w(123),
                            color: _textGrey,
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Badge usia: dibatasi lebarnya, teks mengecil kalau sempit
                      Positioned(
                        top: context.w(7),
                        left: context.w(6),
                        child: Container(
                          height: context.w(16),
                          constraints: BoxConstraints(maxWidth: context.w(82)),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(8),
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _badgeYellow,
                            borderRadius: BorderRadius.circular(context.w(9)),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              badge,
                              maxLines: 1,
                              style: google_fonts.GoogleFonts.inter(
                                fontSize: context.sp(10),
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 12 / 10,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tombol favorit
                      Positioned(
                        top: context.w(2),
                        right: context.w(6),
                        child: ValueListenableBuilder<Set<String>>(
                          valueListenable: RecipeStore.favorites,
                          builder: (_, favs, _) {
                            final liked = favs.contains(title);
                            return GestureDetector(
                              onTap: () => RecipeStore.toggle(title),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                // area sentuh lebih besar dari ikonnya
                                padding: EdgeInsets.all(context.w(4)),
                                child: Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: liked ? _heartRed : _textBlack,
                                  size: context.w(20),
                                ),
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
                padding: EdgeInsets.fromLTRB(
                  context.w(13),
                  context.w(8),
                  context.w(9),
                  context.w(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: context.sp(10),
                        fontWeight: FontWeight.w400,
                        color: _textBlack,
                        height: 12 / 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.w(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: context.w(12),
                          color: _fireOrange,
                        ),
                        SizedBox(width: context.w(2)),
                        Flexible(
                          child: Text(
                            '320 kkal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: context.sp(10),
                              fontWeight: FontWeight.w400,
                              color: _textBlack,
                              height: 12 / 10,
                            ),
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
      ),
    );
  }
}