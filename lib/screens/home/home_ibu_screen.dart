import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/child_data.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/child_store.dart';
import '../../widgets/child_switch_group.dart';
import '../../widgets/data_menu_dropdown.dart';
import '../../widgets/hapus_data_dialog.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/menu_recommendation_card.dart';
import '../../widgets/notification_icon.dart'; // 👈 TAMBAHKAN IMPORT INI
import '../../widgets/tambah_data_anak_sheet.dart';
import '../ai/tanya_ai_screen.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/detail_resep_screen.dart';
import '../menu/menu_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import '../riwayat/riwayat_screen.dart';

class HomeIbuScreen extends StatefulWidget {
  final bool showLoginSuccess;

  const HomeIbuScreen({super.key, this.showLoginSuccess = false});

  @override
  State<HomeIbuScreen> createState() => _HomeIbuScreenState();
}

class _HomeIbuScreenState extends State<HomeIbuScreen> {
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgPeach    = Color(0xFFFCEBD5);
  static const Color bgTeal     = Color(0xFF8BDFDD);
  static const Color textBrown  = Color(0xFF785862);
  static const Color textGrey   = Color(0xFF8F8F8F);
  static const Color badgeGreen = Color(0xFF76C457);

  static const Color textBlack   = Color(0xFF000000);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color textBlack50 = Color(0x80000000);

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
      alergi: '',
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
      alergi: 'Telur',
      tempat: 'Denpasar',
      tanggalLahir: '01/04/2025',
    ),
  ];

  int _currentChildIndex = 0;
  bool _showDataMenu = false;

  bool get _hasChild => _children.isNotEmpty;
  ChildData get _currentChild => _children[_currentChildIndex];

  void _syncCurrentChild() {
    if (_hasChild) {
      ChildStore.setCurrent(_currentChild.nama);
    } else {
      ChildStore.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _syncCurrentChild();

    if (widget.showLoginSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showLoginSuccessSnackBar();
      });
    }
  }

  void _switchChild() {
    if (!_hasChild) return;
    setState(() {
      _currentChildIndex = (_currentChildIndex + 1) % _children.length;
    });
    _syncCurrentChild();
  }

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
      _syncCurrentChild();
    }
  }

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
          alergi: _currentChild.alergi,
          tempat: result['tempat'] ?? _currentChild.tempat,
          tanggalLahir: result['tanggalLahir'] ?? _currentChild.tanggalLahir,
        );
      });
      _syncCurrentChild();
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _showLoginSuccessSnackBar() {
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
              width: context.w(275),
              height: context.w(44),
              decoration: BoxDecoration(
                color: const Color(0xFF77B255),
                borderRadius: BorderRadius.circular(context.w(17)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: context.w(26),
                  ),
                  SizedBox(width: context.w(10)),
                  Text(
                    'Login Berhasil',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: context.sp(17),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 21 / 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Future<void> _hapusAnak() async {
    setState(() => _showDataMenu = false);

    final confirmed = await HapusDataDialog.show(context);
    if (!confirmed) return;

    setState(() {
      _children.removeAt(_currentChildIndex);
      _currentChildIndex = 0;
    });
    _syncCurrentChild();
  }

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
            alergi: _currentChild.alergi,
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _currentChild.alergi = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context),
                  _buildMenuSection(),
                  SizedBox(height: context.w(34)),
                  _buildStuntingBanner(),
                  SizedBox(height: context.w(140) + bottomPad),
                ],
              ),
            ),

            Positioned(
              bottom: context.w(90) + bottomPad,
              right: context.w(15),
              child: GestureDetector(
                onTap: _openAi,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: context.w(63),
                  height: context.w(63),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: textBlack.withValues(alpha: 0.25),
                        blurRadius: context.w(4),
                        offset: Offset(0, context.w(4)),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.w(12)),
                    child: Image.asset(
                      'assets/images/AI.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

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

            if (_showDataMenu)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showDataMenu = false),
                  behavior: HitTestBehavior.opaque,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                ),
              ),

            if (_showDataMenu && _hasChild)
              Positioned(
                top: topPad + context.w(96),
                left: context.w(186),
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

  Widget _buildHeaderSection(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: topPad + context.w(286),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topPad + context.w(170),
              decoration: BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.w(50)),
                  bottomRight: Radius.circular(context.w(50)),
                ),
              ),
            ),
          ),

          Positioned(
            top: topPad + context.w(20),
            left: context.w(16),
            right: _hasChild ? context.w(130) : context.w(70),
            child: SizedBox(
              height: context.w(50),
              child: Row(
                children: [
                  const InitialAvatar(initial: 'A'),
                  SizedBox(width: context.w(18)),
                  Expanded(
                    child: Text(
                      'Aisyah',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: context.sp(24),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 29 / 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_hasChild)
            Positioned(
              top: topPad + context.w(24),
              right: context.w(61),
              child: ChildSwitchGroup(
                childGender: _currentChild.gender,
                showAddButton: _children.length < 2,
                onSwitch: _switchChild,
                onAdd: _openTambahAnak,
              ),
            ),

          Positioned(
            top: topPad + context.w(28),
            right: context.w(27),
            child: NotificationIconButton(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NotifikasiScreen()));
              },
            ),
          ),
          // 👆 SAMPAI SINI

          Positioned(
            top: topPad + context.w(116),
            left: context.w(26),
            right: context.w(26),
            child: _hasChild
                ? Container(
                    height: context.w(170),
                    padding: EdgeInsets.fromLTRB(
                      context.w(14),
                      context.w(18),
                      context.w(14),
                      context.w(14),
                    ),
                    decoration: BoxDecoration(
                      color: bgPeach,
                      borderRadius: BorderRadius.circular(context.w(30)),
                    ),
                    child: _buildChildDataContent(),
                  )
                : _buildEmptyStateCard(),
          ),

          if (_hasChild)
            Positioned(
              top: topPad + context.w(100),
              left: context.w(8),
              child: SizedBox(
                width: context.w(96),
                height: context.w(74),
                child: SvgPicture.asset(
                  _currentChild.gender == 'P'
                      ? 'assets/images/kepala_b.cewe.svg'
                      : 'assets/images/kepala_b.cowo.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Material(
      color: bgPeach,
      borderRadius: BorderRadius.circular(context.w(30)),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.w(30)),
        onTap: _openTambahAnak,
        child: SizedBox(
          height: context.w(170),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/icon-plus.svg',
                width: context.w(60),
                height: context.w(60),
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  primaryRed,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: context.w(14)),
              Text(
                'Tambah Data Anak',
                style: google_fonts.GoogleFonts.inter(
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.w700,
                  color: textBlack.withValues(alpha: 0.7),
                  height: 22 / 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildDataContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: context.w(69)),
          child: SizedBox(
            height: context.w(26), 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _currentChild.nama,
                            maxLines: 1,
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: context.sp(20),
                              fontWeight: FontWeight.w700,
                              color: textBrown,
                              height: 24 / 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.w(8)),
                      Container(
                        height: context.w(17),
                        padding: EdgeInsets.symmetric(horizontal: context.w(8)),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(context.w(5)),
                        ),
                        child: Text(
                          _currentChild.status,
                          maxLines: 1,
                          style: google_fonts.GoogleFonts.inter(
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w600,
                            color: badgeGreen,
                            height: 12 / 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() => _showDataMenu = !_showDataMenu),
                  child: SizedBox(
                    width: context.w(26),
                    height: context.w(26),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/settings.svg',
                        width: context.w(25),
                        height: context.w(25),
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          textBlack71,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: context.w(69)),
          child: Row(
            children: [
              Text(
                _currentChild.gender,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w700,
                  color: textBlack71,
                  height: 13 / 11,
                ),
              ),
              SizedBox(width: context.w(4)),
              Container(
                width: context.w(4),
                height: context.w(4),
                decoration: const BoxDecoration(
                  color: textGrey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.w(4)),
              Flexible(
                child: Text(
                  _currentChild.umur,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.w700,
                    color: textBlack71,
                    height: 13 / 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(17)),
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

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          style: google_fonts.GoogleFonts.inter(
            fontSize: context.sp(10),
            fontWeight: FontWeight.w500,
            color: textBlack71,
            height: 12 / 10,
          ),
        ),
        SizedBox(height: context.w(8)),
        Container(
          width: context.w(60),
          height: context.w(60),
          padding: EdgeInsets.symmetric(horizontal: context.w(4)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.w(5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.w700,
                    color: textBlack,
                    height: 24 / 20,
                  ),
                ),
              ),
              Text(
                unit,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: context.sp(9),
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

  Widget _buildMenuSection() {
    const menus = [
      {
        'title': 'Bubur Hati Ayam',
        'imagePath': 'assets/images/bubur-hati-ayam.png',
        'badge': '9 - 11 Bulan',
      },
      {
        'title': 'Kue Ubi Keju',
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
        SizedBox(height: context.w(44)),
        Padding(
          padding: EdgeInsets.only(
            left: context.w(30),
            right: context.w(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Rekomendasi Menu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    color: textBlack,
                    height: 19 / 16,
                  ),
                ),
              ),
              SizedBox(width: context.w(8)),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MenuScreen()));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(4),
                    vertical: context.w(4),
                  ),
                  child: Text(
                    'Jelajahi Menu',
                    maxLines: 1,
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w400,
                      color: textBlack,
                      height: 13 / 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.w(21)),
        SizedBox(
          height: context.w(192),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: context.w(30)),
            children: [
              for (int i = 0; i < menus.length; i++) ...[
                if (i > 0) SizedBox(width: context.w(9)),
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

  Widget _buildStuntingBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: context.w(37)),
      constraints: BoxConstraints(minHeight: context.w(190)),
      decoration: BoxDecoration(
        color: bgTeal,
        borderRadius: BorderRadius.circular(context.w(30)),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: context.w(3),
            top: 0,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/penggaris.png',
                width: context.w(143),
                height: context.w(143),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.w(25),
              context.w(25),
              context.w(25),
              context.w(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: context.w(200),
                  child: Text(
                    'Riwayat pemeriksaan stunting',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w700,
                      color: textBlack,
                      height: 19 / 16,
                    ),
                  ),
                ),
                SizedBox(height: context.w(9)),
                SizedBox(
                  width: context.w(157),
                  child: Text(
                    'Update dan Check History',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w500,
                      color: textBlack50,
                      height: 16 / 13,
                    ),
                  ),
                ),
                SizedBox(height: context.w(14)),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.w(20)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(context.w(20)),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              const RiwayatScreen(initialTab: 1)));
                    },
                    child: Container(
                      width: context.w(171),
                      height: context.w(35),
                      alignment: Alignment.center,
                      child: Text(
                        'Cek Detail',
                        style: google_fonts.GoogleFonts.inter(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w700,
                          color: textBlack50,
                          height: 18 / 15,
                        ),
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