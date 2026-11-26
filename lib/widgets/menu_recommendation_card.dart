import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_text.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../screens/menu/detail_resep_screen.dart';
import '../utils/responsive.dart';
import 'recipe_store.dart';
import 'child_store.dart'; // 👈 TAMBAHKAN IMPORT INI

class MenuRecommendationCard extends StatelessWidget {
  final int? recipeId;
  final String title;
  final String imagePath;
  final String badge;
  final String caloriesText;

  /// Kalau kosong, kartu langsung membuka halaman detail resep.
  final VoidCallback? onTap;

  final bool hasBorder;
  final bool isNew;
  final Color borderColor;

  const MenuRecommendationCard({
    super.key,
    this.recipeId,
    required this.title,
    required this.imagePath,
    required this.badge,
    this.caloriesText = '320 kkal',
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
        recipeId: recipeId, // 👈 Pastikan recipeId dikirim
        title: title,
        imagePath: imagePath,
        badge: badge,
      ),
    ));
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final currentFavs = Set<String>.from(RecipeStore.favorites.value);
    final currentlyLiked = currentFavs.contains(title);
    final nextLiked = !currentlyLiked;

    if (nextLiked) {
      currentFavs.add(title);
    } else {
      currentFavs.remove(title);
    }
    RecipeStore.favorites.value = currentFavs;

    if (recipeId == null) return;

    // AMBIL BABY ID DARI STORE
    final babyId = ChildStore.currentId.value;

    try {
      if (nextLiked) {
        await ApiClient.post(
          '/collection', 
          data: {
            'recipeId': recipeId,
            if (babyId != null) 'babyId': babyId,
          },
        );
      } else {
        final endpoint = babyId != null 
            ? '/collection/$recipeId?babyId=$babyId' 
            : '/collection/$recipeId';
        await ApiClient.delete(endpoint);
      }
    } on ApiException catch (e) {
      final reverted = Set<String>.from(RecipeStore.favorites.value);
      if (currentlyLiked) {
        reverted.add(title);
      } else {
        reverted.remove(title);
      }
      RecipeStore.favorites.value = reverted;

            if (context.mounted) {
        final bottomInset = MediaQuery.of(context).padding.bottom;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.zero,
              duration: const Duration(seconds: 2),
              margin: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottomInset),
              content: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF45060),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Text(
                    e.message.isNotEmpty
                        ? e.message
                        : 'Gagal memperbarui koleksi resep',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 17 / 14,
                    ),
                  ),
                ),
              ),
            ),
          );
      }
    }
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

  Widget _image(BuildContext context) {
    final cleanPath = imagePath.trim();
    final isNetwork =
        cleanPath.startsWith('http://') || cleanPath.startsWith('https://');

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.w(10)),
      child: isNetwork
          ? Image.network(
              cleanPath,
              width: context.w(125),
              height: context.w(123),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: context.w(125),
                height: context.w(123),
                color: _textGrey,
                child: const Icon(Icons.fastfood, color: Colors.white),
              ),
            )
          : Image.asset(
              cleanPath,
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
  }

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
            onTap: () => _toggleFavorite(context),
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
              caloriesText,
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