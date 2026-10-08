import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

import '../../models/child_data.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/child_switch_group.dart';
import '../../widgets/data_menu_dropdown.dart';
import '../../widgets/hapus_data_dialog.dart';
import '../../widgets/menu_recommendation_card.dart';
import '../../widgets/tambah_data_anak_sheet.dart';
import '../ai/tanya_ai_screen.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/detail_resep_screen.dart';
import '../menu/menu_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import '../riwayat/riwayat_screen.dart';

class HomeIbuScreen extends StatefulWidget {
  const HomeIbuScreen({super.key});

  @override
  State<HomeIbuScreen> createState() => _HomeIbuScreenState();
}

class _HomeIbuScreenState extends State<HomeIbuScreen> {
  // Warna dari Figma
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgPeach    = Color(0xFFFCEBD5);
  static const Color bgTeal     = Color(0xFF8BDFDD);
  static const Color textBrown  = Color(0xFF785862);
  static const Color textGrey   = Color(0xFF8F8F8F);
  static const Color badgeGreen = Color(0xFF76C457);

  static const Color textBlack   = Color(0xFF000000);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color textBlack50 = Color(0x80000000);
  static const Color purpleAI    = Color(0xFF9564DD);

  // ================= DATA ANAK (DUMMY) =================
  final List<ChildData> _children = [
    ChildData(
      nama: 'Alaia',
      gender: 'P',
      umur: '18 Bulan',
      status: 'Normal',
      berat: '6,4',
      tinggi: '63,3',
      kepala: '40,9',
      lila: '14,75',
      alergi: '', // Boleh diisi, tapi tidak akan tampil di card
      tempat: 'Denpasar',
      tanggalLahir: '01/04/2025',
    ),
    ChildData(
      nama: 'Kentoz',
      gender: 'L',
      umur: '10 Bulan',
      status: 'Normal',
      berat: '6,4',
      tinggi: '63,3',
      kepala: '40,9',
      lila: '14,75',
      alergi: 'Telur', // Boleh diisi, tapi tidak akan tampil di card
      tempat: 'Denpasar',
      tanggalLahir: '01/04/2025',
    ),
  ];

  int _currentChildIndex = 0;
  bool _showDataMenu = false;

  bool get _hasChild => _children.isNotEmpty;

  ChildData get _currentChild => _children[_currentChildIndex];

  void _switchChild() {
    if (!_hasChild) return;
    setState(() {
      _currentChildIndex = (_currentChildIndex + 1) % _children.length;
    });
  }

  // ================= TAMBAH ANAK =================
  Future<void> _openTambahAnak() async {
    if (_children.length >= 2) {
      _snack('Maksimal 2 data anak');
      return;
    }

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const TambahDataAnakSheet(),
    );

    if (result != null) {
      setState(() {
        _children.add(ChildData(
          nama: result['nama'] ?? 'Anak Baru',
          gender: result['gender'] ?? 'L',
          umur: result['umur'] ?? '0 Bulan',
          status: result['status'] ?? 'Normal',
          berat: result['berat'] ?? '-',
          tinggi: result['tinggi'] ?? '-',
          kepala: result['kepala'] ?? '-',
          lila: result['lila'] ?? '-',
          alergi: result['alergi'] ?? '',
          tempat: result['tempat'] ?? '-',
          tanggalLahir: result['tanggalLahir'] ?? '-',
        ));
        _currentChildIndex = _children.length - 1;
      });
    }
  }

  // ================= UBAH DATA ANAK =================
  Future<void> _openUbahAnak() async {
    setState(() => _showDataMenu = false);

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => TambahDataAnakSheet(
        initialData: InitialChildData(
          nama: _currentChild.nama,
          gender: _currentChild.gender,
          tempat: _currentChild.tempat,
          tanggalLahir: _currentChild.tanggalLahir,
          bb: _currentChild.berat,
          tb: _currentChild.tinggi,
          kepala: _currentChild.kepala,
          lila: _currentChild.lila,
          kondisi: _currentChild.status,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _children[_currentChildIndex] = ChildData(
          nama: result['nama'] ?? _currentChild.nama,
          gender: result['gender'] ?? _currentChild.gender,
          umur: _currentChild.umur, 
          status: result['status'] ?? _currentChild.status,
          berat: result['berat'] ?? _currentChild.berat,
          tinggi: result['tinggi'] ?? _currentChild.tinggi,
          kepala: result['kepala'] ?? _currentChild.kepala,
          lila: result['lila'] ?? _currentChild.lila,
          alergi: _currentChild.alergi, // Tetap simpan alergi lama
          tempat: result['tempat'] ?? _currentChild.tempat,
          tanggalLahir: result['tanggalLahir'] ?? _currentChild.tanggalLahir,
        );
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ================= HAPUS ANAK =================
  Future<void> _hapusAnak() async {
    setState(() => _showDataMenu = false);

    final confirmed = await HapusDataDialog.show(context);
    if (!confirmed) return;

    setState(() {
      _children.removeAt(_currentChildIndex);
      _currentChildIndex = 0;
    });
  }

  // ================= BUKA AI =================
  Future<void> _openAi() async {
    if (!_hasChild) {
      _snack('Tambahkan data anak dulu ya');
      return;
    }

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => TanyaAiScreen(
          child: AiChildInfo(
            nama: _currentChild.nama,
            umur: _currentChild.umur,
            gender: _currentChild.gender,
            alergi: _currentChild.alergi, // Kirim alergi yang tersimpan ke AI
          ),
        ),
      ),
    );
    
    // Tetap update data alergi di background agar AI ingat untuk sesi berikutnya
    if (result != null && mounted) {
      setState(() => _currentChild.alergi = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ================= KONTEN SCROLL =================
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context),
                  _buildMenuSection(),
                  const SizedBox(height: 34),
                  _buildStuntingBanner(),
                  const SizedBox(height: 140),
                ],
              ),
            ),

            // ================= AI FAB =================
            Positioned(
              bottom: 90,
              right: 15,
              child: GestureDetector(
                onTap: _openAi,
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
                  child: const Icon(
                    Icons.auto_awesome,
                    color: purpleAI,
                    size: 40,
                  ),
                ),
              ),
            ),

            // ================= BOTTOM NAV =================
            BottomNav(
              currentIndex: 2,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const KoleksiScreen()));
                } else if (i == 1) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MenuScreen()));
                } else if (i == 3) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const RiwayatScreen()));
                } else if (i == 4) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProfilScreen()));
                }
              },
            ),

            // ================= TAP-AWAY =================
            if (_showDataMenu)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showDataMenu = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),

            // ================= DROPDOWN UBAH / HAPUS =================
            if (_showDataMenu && _hasChild)
              Positioned(
                top: topPad + 96,
                left: 186,
                child: DataMenuDropdown(
                  onEdit: _openUbahAnak,
                  onDelete: _hapusAnak,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER + KARTU ANAK =================
  Widget _buildHeaderSection(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: topPad + 286,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background merah
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topPad + 170,
              decoration: const BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),

          // Avatar + nama
          Positioned(
            top: topPad + 20,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textBlack,
                        height: 29 / 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    'Aisyah',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 29 / 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Switch group
          if (_hasChild)
            Positioned(
              top: topPad + 24,
              right: 61,
              child: ChildSwitchGroup(
                childGender: _currentChild.gender,
                showAddButton: _children.length < 2,
                onSwitch: _switchChild,
                onAdd: _openTambahAnak,
              ),
            ),

          // Bell
          Positioned(
            top: topPad + 28,
            right: 27,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NotifikasiScreen()));
              },
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),

          // Kartu data anak ATAU empty state
          Positioned(
            top: topPad + 116,
            left: 26,
            right: 26,
            child: _hasChild
                ? Container(
                    height: 170,
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                    decoration: BoxDecoration(
                      color: bgPeach,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _buildChildDataContent(),
                  )
                : _buildEmptyStateCard(),
          ),

          // Maskot overlap
          if (_hasChild)
            Positioned(
              top: topPad + 100,
              left: 8,
              child: SizedBox(
                width: 96,
                height: 74,
                child: Image.asset(
                  _currentChild.gender == 'P'
                      ? 'assets/images/kepala_b.cewe.png'
                      : 'assets/images/kepala_b.cowo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.child_care,
                    size: 72,
                    color: primaryRed,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= EMPTY STATE CARD =================
  Widget _buildEmptyStateCard() {
    return GestureDetector(
      onTap: _openTambahAnak,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: bgPeach,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              size: 60,
              color: primaryRed,
            ),
            const SizedBox(height: 14),
            Text(
              'Tambah Data Anak',
              style: google_fonts.GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textBlack.withValues(alpha: 0.7),
                height: 22 / 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= KARTU DATA ANAK =================
  Widget _buildChildDataContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 69),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _currentChild.nama,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textBrown,
                  height: 24 / 20,
                ),
              ),
              const SizedBox(width: 15),
              Container(
                width: 60,
                height: 17,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _currentChild.status,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeGreen,
                    height: 12 / 10,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    setState(() => _showDataMenu = !_showDataMenu),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.settings,
                    color: textBlack71,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 69),
          child: Row(
            children: [
              Text(
                _currentChild.gender,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textBlack71,
                  height: 13 / 11,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: textGrey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _currentChild.umur,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textBlack71,
                  height: 13 / 11,
                ),
              ),
              // 👇 BAGIAN BADGE ALERGI SUDAH DIHAPUS DARI SINI
            ],
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Berat', _currentChild.berat, 'kg'),
              _buildStatItem('Tinggi', _currentChild.tinggi, 'cm'),
              _buildStatItem('Kepala', _currentChild.kepala, 'cm'),
              _buildStatItem('LiLA', _currentChild.lila, 'cm'),
            ],
          ),
        ),
      ],
    );
  }

  // ================= KOTAK STATISTIK =================
  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: google_fonts.GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textBlack71,
            height: 12 / 10,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textBlack,
                  height: 24 / 20,
                ),
              ),
              Text(
                unit,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: textGrey,
                  height: 11 / 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= REKOMENDASI MENU =================
  Widget _buildMenuSection() {
    const menus = [
      {
        'title': 'Bubur Hati Ayam',
        'imagePath': 'assets/images/bubur-hati-ayam.png',
        'badge': '9 - 11 Bulan',
      },
      {
        'title': 'Kue ubi keju',
        'imagePath': 'assets/images/kue-ubi-keju.png',
        'badge': '9 - 11 Bulan',
      },
      {
        'title': 'Jagung Kukus',
        'imagePath': 'assets/images/jagung-kukus.png',
        'badge': '9 - 11 Bulan',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 44),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi Menu',
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  color: textBlack,
                  height: 19 / 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MenuScreen()));
                },
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Lihat Semua',
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: textBlack,
                    height: 13 / 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 21),
        SizedBox(
          height: 186,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            children: [
              for (int i = 0; i < menus.length; i++) ...[
                if (i > 0) const SizedBox(width: 9),
                MenuRecommendationCard(
                  title: menus[i]['title']!,
                  imagePath: menus[i]['imagePath']!,
                  badge: menus[i]['badge']!,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DetailResepScreen(
                        title: menus[i]['title']!,
                        imagePath: menus[i]['imagePath']!,
                        badge: menus[i]['badge']!,
                      ),
                    ));
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ================= BANNER STUNTING =================
  Widget _buildStuntingBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 37),
      height: 190,
      decoration: BoxDecoration(
        color: bgTeal,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
                    Positioned(
            right: 3,
            top: 0,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/penggaris.png',
                width: 143,
                height: 143,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 25, 25, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    'Riwayat pemeriksaan stunting',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textBlack,
                      height: 19 / 16,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: 157,
                  child: Text(
                    'Update dan Check History',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textBlack50,
                      height: 16 / 13,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const RiwayatScreen()));
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 171,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cek Detail',
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textBlack50,
                        height: 18 / 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}