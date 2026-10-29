import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

import '../../widgets/bottom_nav.dart';
import '../../widgets/recipe_store.dart';
import '../../widgets/komentar_sheet.dart';   
import '../koleksi/koleksi_screen.dart';

class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}

// ================= DATA DUMMY DETAIL =================
class RecipeDetailData {
  final List<String> bahan;
  final List<String> langkah;
  final String kalori;
  final String protein;
  final String karbohidrat;
  final String lemak;
  final String tips;

  const RecipeDetailData({
    required this.bahan,
    required this.langkah,
    required this.kalori,
    required this.protein,
    required this.karbohidrat,
    required this.lemak,
    required this.tips,
  });

  static RecipeDetailData fromTitle(String title) {
    if (title.toLowerCase().contains('pepaya')) {
      return const RecipeDetailData(
        bahan: [
          'Pepaya matang: 30–50 gram (pilih yang manis dan matang sempurna)',
        ],
        langkah: [
          'Kupas kulit pepaya dan buang bijinya hingga bersih.',
          'Potong kecil-kecil, lalu lumatkan menggunakan sendok/garpu atau saring menggunakan saringan kawat hingga bertekstur halus.',
          'Siap disajikan sebagai camilan/menu pendamping',
        ],
        kalori: '80',
        protein: '3,5',
        karbohidrat: '8',
        lemak: '3,5',
        tips: 'Buah pepaya lumat sebaiknya disajikan segar dan tidak disimpan terlalu lama karena dapat mengalami oksidasi (berubah warna/rasa) dan nutrisinya berkurang. Jika ada sisa pepaya utuh, simpan dalam wadah tertutup di kulkas maksimal 1–2 hari.',
      );
    }

    return const RecipeDetailData(
      bahan: [
        '130gr ubi ungu',
        '50 ml santan kelapa',
        '1 butir telur ayam',
        'Keju parut secukupnya',
      ],
      langkah: [
        'Potong ubi ungu',
        'Kukus selama 15 menit',
        'Haluskan ubi ungu',
        'Tambahkan santan dan telur, aduk rata',
        'Masukkan ke dalam food container',
        'Kukus kembali selama 10 menit',
        'Kue ubi keju siap disajikan',
      ],
      kalori: '58',
      protein: '2.2',
      karbohidrat: '4.8',
      lemak: '3.2',
      tips: 'Simpan sisa kue dalam wadah kedap udara di kulkas maksimal 2 hari. Perkenalkan keju secara bertahap di awal untuk memantau reaksi alergi pada bayi.',
    );
  }
}

// ================= DETAIL RESEP SCREEN =================
class DetailResepScreen extends StatefulWidget {
  final String title;
  final String imagePath;
  final String badge;
  final bool openComments; // 👈 1. TAMBAHKAN VARIABEL INI

  const DetailResepScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.badge,
    this.openComments = false, // 👈 2. BERI NILAI DEFAULT FALSE
  });

  @override
  State<DetailResepScreen> createState() => _DetailResepScreenState();
}

class _DetailResepScreenState extends State<DetailResepScreen> {
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color bgCream     = Color(0xFFFFF1B5);
  static const Color badgeText   = Color(0xFFDE801A);
  static const Color textBlack   = Color(0xFF000000);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color textBlack50 = Color(0x80000000);
  static const Color greyToggle  = Color(0x80AAA6A6);
  static const Color heartRed    = Color(0xFFDD2E44);
  static const Color lampOrange  = Color(0xFFF1A038);

  int _tab = 0; 
  late RecipeDetailData _data;

  @override
  void initState() {
    super.initState();
    _data = RecipeDetailData.fromTitle(widget.title);
    
    // 👇 3. TAMBAHKAN LOGIKA INI UNTUK OTOMATIS BUKA KOMENTAR
    if (widget.openComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openKomentarSheet();
      });
    }
  }

  void _openKomentarSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,             
      backgroundColor: Colors.transparent,  
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => KomentarSheet(recipeTitle: widget.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(               
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageHeader(context),
                  const SizedBox(height: 17),
                  _buildTitleRow(),
                  const SizedBox(height: 28),
                  _buildTabs(),
                  const SizedBox(height: 22),
                  _buildListContent(),
                  const SizedBox(height: 42),
                  _buildNutritionBox(),
                  const SizedBox(height: 140), 
                ],
              ),
            ),

            Positioned(
              bottom: 90,
              right: 15,
              child: GestureDetector(
                onTap: _openKomentarSheet,   
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 63,
                  height: 63,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: textBlack.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/chat-komentar.svg', 
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        textBlack,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            BottomNav(
              currentIndex: 1,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KoleksiScreen()),
                  );
                } else if (i == 1) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                } else if (i == 2) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28.4),
        bottomRight: Radius.circular(28.4),
      ),
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFFD9D9D9)),
              ),
            ),
            Positioned(
              top: topPad + 10,
              left: 5,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 22,
                    color: textBlack,
                  ),
                ),
              ),
            ),
            Positioned(
              top: topPad + 10,
              right: 18,
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: RecipeStore.favorites,
                builder: (_, favs, __) {
                  final liked = favs.contains(widget.title);
                  return GestureDetector(
                    onTap: () => RecipeStore.toggle(widget.title),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        size: 22,
                        color: liked ? heartRed : textBlack,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(31, 0, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textBlack,
                height: 29 / 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
            decoration: BoxDecoration(
              color: bgCream,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              widget.badge,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: badgeText,
                height: 17 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: 43,
      decoration: BoxDecoration(
        color: greyToggle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Bahan'),
          _buildTabItem(1, 'Langkah'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : textBlack,
              height: 18 / 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    final items = _tab == 0 ? _data.bahan : _data.langkah;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((t) => _buildBulletItem(t)).toList(),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const SizedBox(width: 30),
          Padding(
            padding: const EdgeInsets.only(top: 4), 
            child: SizedBox(
              width: 16,
              height: 16,
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primaryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textBlack,
                height: 20 / 15, 
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildNutritionBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      decoration: BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail nutrisi & tips',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 18 / 15,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildNutritionCard('Kalori', _data.kalori)),
              const SizedBox(width: 12),
              Expanded(child: _buildNutritionCard('Protein', _data.protein)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildNutritionCard('Karbohidrat', _data.karbohidrat)),
              const SizedBox(width: 12),
              Expanded(child: _buildNutritionCard('Lemak', _data.lemak)),
            ],
          ),
          const SizedBox(height: 27),
          Container(height: 3, color: textBlack50),
          const SizedBox(height: 13),
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 0, bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 24,
                  color: lampOrange,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips penyimpanan',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textBlack71,
                          height: 18 / 13,
                        ),
                      ),
                      Text(
                        _data.tips,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: textBlack,
                          height: 18 / 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: label == 'Karbohidrat' ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: textBlack71,
              height: 18 / (label == 'Karbohidrat' ? 10 : 12),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 18 / 24,
            ),
          ),
        ],
      ),
    );
  }
}