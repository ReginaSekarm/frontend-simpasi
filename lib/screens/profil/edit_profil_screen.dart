import 'package:flutter/material.dart';

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

class EditProfilScreen extends StatefulWidget {
  final String namaLengkap;
  final String? email;
  final String? noHp;

  const EditProfilScreen({
    super.key,
    required this.namaLengkap,
    this.email,
    this.noHp,
  });

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  // Warna dari Figma
  static const Color primaryOrange = Color(0xFFF1A038);
  static const Color textBlack     = Color(0xFF000000);
  static const Color textGrey      = Color(0xFF8F8F8F);
  static const Color inputBg       = Color(0x99FFFFFF); // white 60%

  late TextEditingController _namaC;
  late TextEditingController _emailC;
  late TextEditingController _hpC;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.namaLengkap);
    _emailC = TextEditingController(text: widget.email ?? '');
    _hpC = TextEditingController(text: widget.noHp ?? '');
  }

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _hpC.dispose();
    super.dispose();
  }

  void _simpan() {
    final nama = _namaC.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap wajib diisi')),
      );
      return;
    }

    // TODO: kirim perubahan ke backend

    // Balikkan nama ke ProfilScreen
    Navigator.of(context).pop(nama);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            SizedBox(
              height: 60,
              child: Stack(
                children: [
                  // Back arrow
                  Positioned(
                    top: 8,
                    left: 15,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.chevron_left,
                          size: 32,
                          color: textBlack,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Center(
                    child: Text(
                      'Edit Profil',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textBlack,
                        height: 29 / 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // ---- Avatar ----
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/avatar_profile.jpg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 65,
                              color: Color(0xFF808080),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ---- Nama ----
                    Center(
                      child: Text(
                        _namaC.text.isEmpty ? 'Aisyah' : _namaC.text,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textBlack,
                          height: 29 / 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // ---- Field: Nama Lengkap ----
                    _buildLabel('Nama Lengkap'),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _namaC),

                    const SizedBox(height: 25),

                    // ---- Field: Alamat Email ----
                    _buildLabel('Alamat Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 25),

                    // ---- Field: No. HP ----
                    _buildLabel('No. HP'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _hpC,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),

            // ================= TOMBOL SIMPAN =================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: GestureDetector(
                onTap: _simpan,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 24 / 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LABEL =================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textBlack,
          height: 19 / 16,
        ),
      ),
    );
  }

  // ================= TEXTFIELD =================
  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: inputBg,
        border: Border.all(color: textBlack, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textBlack,
            height: 19 / 16,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}