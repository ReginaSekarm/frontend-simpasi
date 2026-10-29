import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_text.dart';
import '../screens/menu/detail_resep_screen.dart';
import '../utils/responsive.dart';
import 'recipe_store.dart';

class MenuRecommendationCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String badge;

  /// Kalau kosong, kartu langsung membuka halaman detail resep.
  final VoidCallback? onTap;

  final bool hasBorder;
  final bool isNew;
  final Color borderColor;

  const MenuRecommendationCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.badge,
    this.onTap,
    this.hasBorder = true,
    this.isNew = false,
    this.borderColor = _textBlack,
  });

  static const Color _badgeYellow = Color(0xFFFFB636);
  static const Color _heartRed    = Color(0xFFDD2E44);
  static const Color _textBlack   = Color(0xFF000000);
  static const Color _textGrey    = Color(0xFF8F8F8F);
  static const Color _primaryRed  = Color(0xFFD45060);
  static const Color _gradTop     = Color(0xFFE76D73);
  static const Color _gradBottom  = Color(0xFFFF8F1F);

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetailResepScreen(
        title: title,
        imagePath: imagePath,
        badge: badge,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);
    return isNew ? _withNewStyle(context, card) : card;
  }

  // ================= KARTU =================
  Widget _buildCard(BuildContext context) {
    // Material + InkWell: ada efek riak saat kartu ditekan
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.w(10)),
        side: (hasBorder && !isNew)
            ? BorderSide(color: borderColor, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap ?? () => _openDetail(context),
        child: SizedBox(
          width: context.w(144),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.w(9), context.w(13), context.w(9), 0),
                child: SizedBox(
                  width: context.w(125),
                  height: context.w(123),
                  child: Stack(children: [
                    _image(context),
                    Positioned(
                      top: context.w(7),
                      left: context.w(6),
                      child: _badge(context),
                    ),
                    Positioned(
                      top: context.w(2),
                      right: context.w(6),
                      child: _heartButton(context),
                    ),
                  ]),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.w(13), context.w(8), context.w(9), context.w(6)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.txt(10, h: 12 / 10),
                    ),
                    SizedBox(height: context.w(8)),
                    _kalori(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _image(BuildContext context) => ClipRRect(
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
            child: const Icon(Icons.fastfood, color: Colors.white),
          ),
        ),
      );

  // Badge usia: dibatasi lebarnya, teks mengecil kalau sempit
  Widget _badge(BuildContext context) => Container(
        height: context.w(16),
        constraints: BoxConstraints(maxWidth: context.w(82)),
        padding: EdgeInsets.symmetric(horizontal: context.w(8)),
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
            style: context.txt(10, c: Colors.white, h: 12 / 10),
          ),
        ),
      );

  Widget _heartButton(BuildContext context) =>
      ValueListenableBuilder<Set<String>>(
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
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? _heartRed : _textBlack,
                size: context.w(20),
              ),
            ),
          );
        },
      );

  
  Widget _kalori(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            'assets/images/fire.svg',
            width: context.w(12),
            height: context.w(12),
            fit: BoxFit.contain,
          ),
          SizedBox(width: context.w(2)),
          Flexible(
            child: Text(
              '320 kkal',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.txt(10, h: 12 / 10),
            ),
          ),
        ],
      );

  // ================= MENU BARU: BORDER GRADASI + LABEL =================
  Widget _withNewStyle(BuildContext context, Widget card) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(1.5)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_gradTop, _gradBottom],
              ),
              borderRadius: BorderRadius.circular(context.w(11.5)),
            ),
            child: card,
          ),
          Positioned(
            top: context.w(-12),
            left: context.w(22),
            child: Container(
              height: context.w(25),
              padding: EdgeInsets.symmetric(horizontal: context.w(8)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.w(8)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star, size: context.w(10), color: _primaryRed),
                SizedBox(width: context.w(4)),
                Text(
                  'Menu Baru',
                  style: context.txt(12.22, w: 700, c: _primaryRed, h: 15 / 12.22),
                ),
              ]),
            ),
          ),
        ],
      );
}