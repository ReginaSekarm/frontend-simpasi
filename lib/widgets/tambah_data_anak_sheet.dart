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
  final InitialChildData? initialData;

  const TambahDataAnakSheet({super.key, this.initialData});

  @override
  State<TambahDataAnakSheet> createState() => _TambahDataAnakSheetState();
}

class _TambahDataAnakSheetState extends State<TambahDataAnakSheet> {
  static const Color primaryRed   = Color(0xFFD45060);
  static const Color textBlack    = Color(0xFF000000);
  static const Color textGrey     = Color(0xFF8F8F8F); 
  static const Color inputBorder  = Color(0xFFE0E0E0); 
  static const Color errorRed     = Color(0xFFFF0020);
  
  static const Color dividerGrey  = Color(0xFFD9D9D9);
  
  // Warna sesuai CSS Figma
  static const Color colorMale    = Color(0xFF8BB7D4); // Biru Muda
  static const Color colorFemale  = Color(0xFFE38D93); // Pink Muda
  static const Color bgDefault    = Color(0xB3D9D9D9); // #D9D9D9 dengan Opacity 0.7
  
  static const Color normalBg     = Color(0x33006199);
  static const Color normalText   = Color(0x80006199);

  static const double _radius  = 13.84; // Sesuai Figma
  static const double _fieldH  = 48.0; 

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

  bool _namaError = false;
  bool _tempatError = false;
  bool _tglError = false;

  bool _isDragging = false;
  double _sheetFraction = 0.88; 

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
      if (d.tanggalLahir.isNotEmpty) _hitungUmurString(d.tanggalLahir);
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

  void _hitungUmur(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    int totalMonths = (years * 12) + months;

    setState(() {
      if (years > 0) {
        _calculatedUmur = months > 0 ? '$years Tahun $months Bulan' : '$years Tahun';
      } else {
        _calculatedUmur = '$totalMonths Bulan';
      }
    });
  }

  void _hitungUmurString(String tglStr) {
    try {
      final parts = tglStr.split('/');
      if (parts.length == 3) {
        _hitungUmur(DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])));
      }
    } catch (_) {
      _calculatedUmur = '0 Bulan';
    }
  }

  void _simpan() {
    setState(() {
      _namaError = _namaC.text.isEmpty;
      _tempatError = _tempatC.text.isEmpty;
      _tglError = _tglC.text.isEmpty;
    });

    if (_namaError || _tempatError || _tglError) {
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
      'tanggalLahir': _tglC.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GestureDetector(
        onVerticalDragStart: (details) {
          setState(() => _isDragging = true);
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _sheetFraction -= details.delta.dy / screenHeight;
            if (_sheetFraction > 1.0) _sheetFraction = 1.0;
            if (_sheetFraction < 0.4) _sheetFraction = 0.4;
          });
        },
        onVerticalDragEnd: (details) {
          setState(() {
            _isDragging = false;
            if (_sheetFraction > 0.92) {
              _sheetFraction = 1.0; 
            } else if (_sheetFraction < 0.75) {
              Navigator.of(context).pop(); 
            } else {
              _sheetFraction = 0.88; 
            }
          });
        },
        child: AnimatedContainer(
          duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(
            maxHeight: screenHeight * _sheetFraction, 
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                  child: Center(
                    child: Container(
                      width: 60, 
                      height: 5,
                      decoration: BoxDecoration(
                        color: dividerGrey, 
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(21, 0, 21, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              _isEditMode ? 'Ubah Data Anak' : 'Tambah Data Anak',
                              style: GoogleFonts.inter(fontSize: 18.57, fontWeight: FontWeight.w700, color: textBlack),
                            ),
                          ),
                          const SizedBox(height: 26),

                          _buildLabel('Nama Lengkap'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _namaC,
                            hint: 'Masukkan nama anak',
                            isError: _namaError,
                            errorText: 'Nama wajib diisi',
                            onChanged: (val) {
                              if (val.isNotEmpty && _namaError) setState(() => _namaError = false);
                            },
                          ),
                          const SizedBox(height: 20),

                          // JENIS KELAMIN
                          _buildLabel('Jenis Kelamin'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildGenderButton(label: 'Laki-laki', iconPath: 'assets/images/male.svg', value: 'L', isLeft: true)),
                              Expanded(child: _buildGenderButton(label: 'Perempuan', iconPath: 'assets/images/female.svg', value: 'P', isLeft: false)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Tempat'),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _tempatC,
                                      hint: 'Contoh: Denpasar',
                                      isError: _tempatError,
                                      errorText: 'Tempat wajib diisi',
                                      onChanged: (val) {
                                        if (val.isNotEmpty && _tempatError) setState(() => _tempatError = false);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Tanggal Lahir', indent: 1.5),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _tglC,
                                      hint: 'dd/mm/yyyy',
                                      suffixIcon: Icons.calendar_month, 
                                      isError: _tglError,
                                      errorText: 'Tanggal wajib diisi',
                                      onChanged: (val) {
                                        if (val.isNotEmpty && _tglError) setState(() => _tglError = false);
                                      },
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime(2024),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _tglC.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                            _tglError = false;
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

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildLabel('Berat'),
                                        Text(' (opsional)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textGrey)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _bbC,
                                      keyboardType: TextInputType.number,
                                      hint: 'Contoh: 7.5',
                                      unit: 'kg', 
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildLabel('Tinggi', indent: 1.5),
                                        Text(' (opsional)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textGrey)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _tbC,
                                      keyboardType: TextInputType.number,
                                      hint: 'Contoh: 65',
                                      unit: 'cm', 
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildLabel('Kepala'),
                                        Text(' (opsional)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textGrey)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _kepalaC,
                                      keyboardType: TextInputType.number,
                                      hint: 'Contoh: 40',
                                      unit: 'cm', 
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildLabel('LiLA', indent: 1.5),
                                        Text(' (opsional)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textGrey)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _lilaC,
                                      keyboardType: TextInputType.number,
                                      hint: 'Contoh: 14',
                                      unit: 'cm', 
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                            decoration: BoxDecoration(color: const Color(0xFFDDF3F1), borderRadius: BorderRadius.circular(10)),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Cara mengukur lingkar lengan atas: ',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1A7772)),
                                  ),
                                  TextSpan(
                                    text: 'lingkarkan pita di tengah lengan kiri atas antara bahu dan siku. Belum punya angkanya? Kosongkan dulu, kader bisa mengisinya.',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF1A7772)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              _buildLabel('Kondisi Balita'),
                              Text(' (opsional)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textGrey)),
                            ],
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
                                          side: const BorderSide(color: errorRed, width: 1),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: Text('Batal', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: errorRed)),
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
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: Text('Simpan Data', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {double indent = 5.6, Color color = textBlack}) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14.86, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    IconData? suffixIcon, 
    String? unit, 
    VoidCallback? onTap,
    bool isError = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: _fieldH,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: isError ? errorRed : inputBorder,
              width: isError ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (!isError) 
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: onTap != null,
                  onTap: onTap,
                  onChanged: onChanged,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textBlack),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textGrey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_radius),
                      borderSide: const BorderSide(color: primaryRed, width: 1.5), 
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    isDense: true,
                  ),
                ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Text(
                    unit,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textGrey),
                  ),
                ),
              if (suffixIcon != null)
                GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14, left: 8),
                    child: Icon(suffixIcon, size: 20, color: isError ? errorRed : textGrey),
                  ),
                ),
            ],
          ),
        ),
        if (isError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              errorText,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400, color: errorRed),
            ),
          ),
      ],
    );
  }

  // ================= GENDER BUTTON (SESUAI GAMBAR) =================
  Widget _buildGenderButton({
    required String label, 
    required String iconPath, 
    required String value,
    required bool isLeft,
  }) {
    final active = _gender == value;
    
    // Warna dasar
    final Color baseColor = value == 'L' ? colorMale : colorFemale;

    // LOGIKA STATE (BELUM & SUDAH DIKLIK) 
    final Color bg = active ? baseColor : bgDefault;
    final Color borderColor = active ? Colors.transparent : baseColor;
    final Color contentColor = active ? Colors.white : baseColor;

    // Radius menyatu
    const r = Radius.circular(_radius);
    final borderRadius = BorderRadius.horizontal(
      left: isLeft ? r : Radius.zero,
      right: isLeft ? Radius.zero : r,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _gender = value),
        borderRadius: borderRadius,
        splashColor: baseColor.withValues(alpha: 0.2),
        highlightColor: baseColor.withValues(alpha: 0.1),
        child: Container(
          height: 39, // Sesuai tinggi Figma
          decoration: BoxDecoration(
            color: bg,
            borderRadius: borderRadius, 
            // Border 2px sesuai Figma
            border: Border.all(
              color: borderColor, 
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath, 
                width: 24, 
                height: 24, 
                colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Text(
                label, 
                style: GoogleFonts.inter(
                  fontSize: 15, // Sesuai ukuran font Figma
                  fontWeight: FontWeight.w500, // Sesuai Figma
                  color: contentColor
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= KONDISI BUTTON (BORDER KEMBALI SESUAI GAMBAR) =================
  Widget _buildKondisiButton(String kondisi) {
    final active = _kondisi == kondisi;
    
    Color bgColor = const Color(0x80D9D9D9); 
    Color textColor = textBlack;
    Color borderColor = Colors.transparent;

    if (active) {
      switch (kondisi) {
        case 'Normal':
          bgColor = normalBg; textColor = normalText; 
          borderColor = normalText; // 👈 Border dikembalikan
          break;
        case 'Berisiko':
          bgColor = const Color(0x80FFD444); textColor = const Color(0xFFE38621); 
          borderColor = textColor; // 👈 Border dikembalikan
          break;
        default: // Stunting
          bgColor = const Color(0x80FFC2B4); textColor = const Color(0xFFDD2E44); 
          borderColor = textColor; // 👈 Border dikembalikan
          break;
      }
    }

    return GestureDetector(
      onTap: () => setState(() => _kondisi = kondisi),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 37.19, 
        decoration: BoxDecoration(
          color: bgColor, 
          borderRadius: BorderRadius.circular(13.84), 
          border: Border.all(
            color: Colors.transparent, 
            width: 0,
          ),
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
                    color: textColor, 
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}