import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ================= MODEL UNTUK INITIAL DATA =================
class InitialChildData {
  final String nama;
  final String gender; // 'L' / 'P'
  final String tempat;
  final String tanggalLahir;
  final String bb;
  final String tb;
  final String kepala;
  final String lila;
  final String kondisi; // 'Normal' / 'Berisiko' / 'Stunting'

  const InitialChildData({
    required this.nama,
    required this.gender,
    required this.tempat,
    required this.tanggalLahir,
    required this.bb,
    required this.tb,
    required this.kepala,
    required this.lila,
    required this.kondisi,
  });
}

class TambahDataAnakSheet extends StatefulWidget {
  /// Kalau null → mode TAMBAH
  /// Kalau ada → mode UBAH (pre-fill dari data existing)
  final InitialChildData? initialData;

  const TambahDataAnakSheet({super.key, this.initialData});

  @override
  State<TambahDataAnakSheet> createState() => _TambahDataAnakSheetState();
}

class _TambahDataAnakSheetState extends State<TambahDataAnakSheet> {
  static const Color primaryRed   = Color(0xFFD45060);
  static const Color textBlack    = Color(0xFF000000);
  static const Color textBlack25  = Color(0x40000000);
  static const Color textBlack50  = Color(0x80000000);
  static const Color textGrey80   = Color(0xCC000000);
  static const Color inputBg      = Color(0x80D9D9D9); 
  static const Color genderBg     = Color(0x59D9D9D9);
  static const Color dividerGrey  = Color(0xFFD9D9D9);
  static const Color errorRed     = Color(0xFFFF0020);
  static const Color maleBg       = Color(0xB369A8D0);
  static const Color femaleBg     = Color(0xB3E76B73);
  static const Color normalBg     = Color(0x33006199);
  static const Color normalText   = Color(0x80006199);

  static const double _radius  = 13.8366;
  static const double _fieldH  = 37.2;

  final _namaC    = TextEditingController();
  final _tempatC  = TextEditingController();
  final _tglC     = TextEditingController();
  final _bbC      = TextEditingController();
  final _tbC      = TextEditingController();
  final _kepalaC  = TextEditingController();
  final _lilaC    = TextEditingController();

  String _gender  = ''; 
  String _kondisi = ''; 
  String _calculatedUmur = '0 Bulan';

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    final d = widget.initialData;
    if (d != null) {
      _namaC.text   = d.nama;
      _tempatC.text = d.tempat;
      _tglC.text    = d.tanggalLahir;
      _bbC.text     = d.bb;
      _tbC.text     = d.tb;
      _kepalaC.text = d.kepala;
      _lilaC.text   = d.lila;
      _gender       = d.gender;
      _kondisi      = d.kondisi;
      
      if (d.tanggalLahir.isNotEmpty) {
        _hitungUmurString(d.tanggalLahir);
      }
    }
  }

  @override
  void dispose() {
    _namaC.dispose();
    _tempatC.dispose();
    _tglC.dispose();
    _bbC.dispose();
    _tbC.dispose();
    _kepalaC.dispose();
    _lilaC.dispose();
    super.dispose();
  }

  // ================= FUNGSI HITUNG UMUR OTOMATIS =================
  void _hitungUmur(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    int totalMonths = (years * 12) + months;

    setState(() {
      if (years > 0) {
        if (months > 0) {
          _calculatedUmur = '$years Tahun $months Bulan';
        } else {
          _calculatedUmur = '$years Tahun';
        }
      } else {
        _calculatedUmur = '$totalMonths Bulan';
      }
    });
  }

  void _hitungUmurString(String tglStr) {
    try {
      final parts = tglStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        _hitungUmur(DateTime(year, month, day));
      }
    } catch (_) {
      _calculatedUmur = '0 Bulan';
    }
  }

  void _simpan() {
    if (_namaC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap wajib diisi')),
      );
      return;
    }

    Navigator.of(context).pop({
      'nama':   _namaC.text,
      'gender': _gender.isEmpty ? 'L' : _gender,
      'umur':   _calculatedUmur,
      'berat':  _bbC.text.isEmpty ? '-' : _bbC.text,
      'tinggi': _tbC.text.isEmpty ? '-' : _tbC.text,
      'kepala': _kepalaC.text.isEmpty ? '-' : _kepalaC.text,
      'lila':   _lilaC.text.isEmpty ? '-' : _lilaC.text,
      'status': _kondisi.isEmpty ? 'Normal' : _kondisi,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(21, 8, 21, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 👈 Memastikan kolom tidak memaksa penuh
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= DRAG HANDLE =================
                  Center(
                    child: Container(
                      width: 74.5,
                      height: 4.64,
                      margin: const EdgeInsets.only(top: 26, bottom: 24),
                      decoration: BoxDecoration(
                        color: dividerGrey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),

                  // ================= TITLE (dinamis) =================
                  Center(
                    child: Text(
                      _isEditMode ? 'Ubah Data Anak' : 'Tambah Data Anak',
                      style: GoogleFonts.inter(
                        fontSize: 18.57,
                        fontWeight: FontWeight.w700,
                        color: textBlack,
                        height: 22 / 18.57,
                      ),
                    ),
                  ),
                  const SizedBox(height: 31),

                  // ================= NAMA LENGKAP =================
                  _buildLabel('Nama Lengkap'),
                  const SizedBox(height: 4),
                  _buildTextField(controller: _namaC),
                  const SizedBox(height: 27),

                  // ================= JENIS KELAMIN =================
                  _buildLabel('Jenis Kelamin'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderButton(
                          label: 'Laki-laki',
                          iconPath: 'assets/images/male.svg', 
                          value: 'L',
                        ),
                      ),
                      Expanded(
                        child: _buildGenderButton(
                          label: 'Perempuan',
                          iconPath: 'assets/images/female.svg', 
                          value: 'P',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ================= TEMPAT & TANGGAL LAHIR =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tempat'),
                            const SizedBox(height: 4),
                            _buildTextField(controller: _tempatC),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tanggal Lahir', indent: 1.5),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller: _tglC,
                              hint: 'dd/mm/yyyy',
                              suffixIcon: Icons.calendar_month,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2024),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _tglC.text =
                                        '${picked.day.toString().padLeft(2, '0')}/'
                                        '${picked.month.toString().padLeft(2, '0')}/'
                                        '${picked.year}';
                                  });
                                  _hitungUmur(picked);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ================= BB & TB =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Berat (kg)'),
                            const SizedBox(height: 4),
                            _buildTextField(
                                controller: _bbC,
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tinggi (cm)', indent: 1.5),
                            const SizedBox(height: 4),
                            _buildTextField(
                                controller: _tbC,
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ================= KEPALA & LiLA =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Kepala (cm)'),
                            const SizedBox(height: 4),
                            _buildTextField(
                                controller: _kepalaC,
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('LiLA (cm)', indent: 3.5),
                            const SizedBox(height: 4),
                            _buildTextField(
                                controller: _lilaC,
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ================= INFO BOX LILA (SESUAI FIGMA) =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF3F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Cara mengukur lingkar lengan atas: lingkarkan pita di tengah lengan kiri atas antara bahu dan siku. Belum punya angkanya? Kosongkan dulu, kader bisa mengisinya.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A7772),
                        height: 15 / 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ================= KONDISI BALITA =================
                  _buildLabel(
                    'Kondisi Balita (opsional)',
                    color: textBlack,
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(child: _buildKondisiButton('Normal')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKondisiButton('Berisiko')),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Expanded(child: _buildKondisiButton('Stunting')),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 29),

                  // ================= BATAL & SIMPAN DATA =================
                  Center(
                    child: SizedBox(
                      width: 332,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 150,
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  side: const BorderSide(
                                      color: errorRed, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Batal',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: errorRed,
                                    height: 19 / 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 158,
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _simpan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryRed,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Simpan Data',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 19 / 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= LABEL =================
  Widget _buildLabel(String text, {double indent = 5.6, Color color = textGrey80}) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14.86,
          fontWeight: FontWeight.w600,
          color: color,
          height: 18 / 14.86,
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================
  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Container(
      height: _fieldH,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: onTap != null,
              onTap: onTap,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textBlack,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textBlack25,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixIcon != null)
            Icon(suffixIcon, size: 20, color: textBlack50),
        ],
      ),
    );
  }

  // ================= GENDER BUTTON =================
  Widget _buildGenderButton({
    required String label,
    required String iconPath,
    required String value,
  }) {
    final active = _gender == value;
    final isLeft = value == 'L';

    final Color bg = active
        ? (value == 'P' ? femaleBg : maleBg)
        : genderBg;
    final Color fg = active ? Colors.white : textBlack25;

    const r = Radius.circular(_radius);

    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? r : Radius.zero,
            right: isLeft ? Radius.zero : r,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: isLeft ? 0 : 9,
              right: 0, 
              top: 9,
              height: 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: fg,
                          height: 17 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= KONDISI BUTTON =================
  Widget _buildKondisiButton(String kondisi) {
    final active = _kondisi == kondisi;

    Color bgColor;
    Color textColor;
    Color dotColor;

    if (!active) {
      bgColor = inputBg;
      textColor = textBlack;
      dotColor = Colors.black;
    } else {
      switch (kondisi) {
        case 'Normal':
          bgColor = normalBg;
          textColor = normalText;
          dotColor = normalText;
          break;
        case 'Berisiko':
          bgColor = const Color(0x80FFD444);
          textColor = const Color(0xFFE38621);
          dotColor = const Color(0xFFE38621);
          break;
        default: // Stunting
          bgColor = const Color(0x80FCEBD5);
          textColor = const Color(0xFFDD2E44);
          dotColor = const Color(0xFFDD2E44);
          break;
      }
    }

    return GestureDetector(
      onTap: () => setState(() => _kondisi = kondisi),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _fieldH,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 17.5,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 6.5,
                  height: 6.5,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Text(
              kondisi,
              style: GoogleFonts.inter(
                fontSize: 14.86,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 18 / 14.86,
              ),
            ),
          ],
        ),
      ),
    );
  }
}