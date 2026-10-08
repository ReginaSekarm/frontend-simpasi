import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color primaryRed = Color(0xFFD45060);
  static const Color textBlack  = Color(0xFF000000);
  static const Color textGrey80 = Color(0xCC000000);
  static const Color textGrey   = Color(0xFF8F8F8F);
  static const Color inputBg    = Color(0x80D9D9D9);
  static const Color dividerGrey= Color(0xFFD9D9D9);
  static const Color errorRed   = Color(0xFFFF0020);
  static const Color femaleBg   = Color(0xB3E76B73); // pink untuk perempuan aktif
  static const Color normalBg   = Color(0x33006199); // biru muda untuk Normal aktif
  static const Color normalText = Color(0x80006199);

  final _namaC     = TextEditingController();
  final _tempatC   = TextEditingController();
  final _tglC      = TextEditingController();
  final _bbC       = TextEditingController();
  final _tbC       = TextEditingController();
  final _kepalaC   = TextEditingController();
  final _lilaC     = TextEditingController();

  String _gender  = ''; // 'L' atau 'P'
  String _kondisi = ''; // 'Normal', 'Berisiko', 'Stunting'

  // 👇 Cek mode (tambah / ubah)
  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    // 👇 Kalau mode UBAH → pre-fill semua field dari data existing
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

  void _simpan() {
    if (_namaC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap wajib diisi')),
      );
      return;
    }

    // Balikkan data ke pemanggil
    Navigator.of(context).pop({
      'nama':   _namaC.text,
      'gender': _gender.isEmpty ? 'L' : _gender,
      'umur':   '0 Bulan',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= DRAG HANDLE =================
                  Center(
                    child: Container(
                      width: 74,
                      height: 5,
                      margin: const EdgeInsets.only(top: 26, bottom: 22),
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
                        fontSize: 18.5,
                        fontWeight: FontWeight.w700,
                        color: textBlack,
                        height: 22 / 18.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ================= NAMA LENGKAP =================
                  _buildLabel('Nama Lengkap'),
                  const SizedBox(height: 6),
                  _buildTextField(controller: _namaC),
                  const SizedBox(height: 26),

                  // ================= JENIS KELAMIN =================
                  _buildLabel('Jenis Kelamin'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderButton(
                          label: 'Laki-laki',
                          icon: Icons.male,
                          value: 'L',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildGenderButton(
                          label: 'Perempuan',
                          icon: Icons.female,
                          value: 'P',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // ================= TEMPAT & TANGGAL LAHIR =================
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tempat'),
                            const SizedBox(height: 6),
                            _buildTextField(controller: _tempatC),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tanggal Lahir'),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _tglC,
                              hint: 'dd/mm/yyyy',
                              suffixIcon: Icons.calendar_today_outlined,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2024),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  _tglC.text =
                                      '${picked.day.toString().padLeft(2, '0')}/'
                                      '${picked.month.toString().padLeft(2, '0')}/'
                                      '${picked.year}';
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // ================= BB & TB =================
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('BB (kg)'),
                            const SizedBox(height: 6),
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
                            _buildLabel('TB (cm)'),
                            const SizedBox(height: 6),
                            _buildTextField(
                                controller: _tbC,
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // ================= KEPALA & LiLA =================
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Kepala (cm)'),
                            const SizedBox(height: 6),
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
                            _buildLabel('LiLA (cm)'),
                            const SizedBox(height: 6),
                            _buildTextField(
                                controller: _lilaC,
                                keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // ================= KONDISI BALITA =================
                  _buildLabel('Kondisi Balita (opsional)'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _buildKondisiButton('Normal'),
                      _buildKondisiButton('Berisiko'),
                      _buildKondisiButton('Stunting'),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ================= SIMPAN DATA =================
                  Center(
                    child: SizedBox(
                      width: 186,
                      height: 48,
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
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 22 / 18.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ================= BATAL =================
                  Center(
                    child: SizedBox(
                      width: 186,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: errorRed, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.inter(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                            color: errorRed,
                            height: 22 / 18.5,
                          ),
                        ),
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
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14.85,
        fontWeight: FontWeight.w600,
        color: textGrey80,
        height: 18 / 14.85,
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
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(13.8),
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
                  fontWeight: FontWeight.w500,
                  color: textGrey.withValues(alpha: 0.7),
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
            Icon(suffixIcon, size: 18, color: textGrey80),
        ],
      ),
    );
  }

  // ================= GENDER BUTTON =================
  // Figma: Laki-laki = abu transparan, Perempuan aktif = pink (#E76B73 with alpha)
  Widget _buildGenderButton({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final active = _gender == value;

    // Warna background aktif berbeda: L = abu, P = pink (sesuai Figma)
    final activeBg = value == 'P'
        ? femaleBg
        : inputBg.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: active ? activeBg : inputBg.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(13.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? Colors.white : textGrey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : textGrey,
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

    // Warna background & text sesuai kondisi
    Color bgColor;
    Color textColor;
    Color dotColor;

    if (!active) {
      bgColor = inputBg.withValues(alpha: 0.7);
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
        width: 158,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(13.8),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                kondisi,
                style: GoogleFonts.inter(
                  fontSize: 14.85,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 18 / 14.85,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}