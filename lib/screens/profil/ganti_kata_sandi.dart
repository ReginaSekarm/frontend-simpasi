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

class GantiKataSandiScreen extends StatefulWidget {
  const GantiKataSandiScreen({super.key});

  @override
  State<GantiKataSandiScreen> createState() => _GantiKataSandiScreenState();
}

class _GantiKataSandiScreenState extends State<GantiKataSandiScreen> {
  // Warna dari Figma
  static const Color primaryOrange = Color(0xFFF1A038);
  static const Color textBlack     = Color(0xFF000000);
  static const Color textGrey      = Color(0xFF8F8F8F);
  static const Color inputBg       = Color(0x99FFFFFF); // white 60%

  final _oldPassC = TextEditingController();
  final _newPassC = TextEditingController();
  final _confirmPassC = TextEditingController();

  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _oldPassC.dispose();
    _newPassC.dispose();
    _confirmPassC.dispose();
    super.dispose();
  }

  void _simpan() {
    final oldP = _oldPassC.text.trim();
    final newP = _newPassC.text.trim();
    final conf = _confirmPassC.text.trim();

    // Validasi dasar
    if (oldP.isEmpty || newP.isEmpty || conf.isEmpty) {
      _snack('Semua kolom wajib diisi');
      return;
    }
    if (newP.length < 6) {
      _snack('Kata sandi baru minimal 6 karakter');
      return;
    }
    if (newP != conf) {
      _snack('Konfirmasi kata sandi tidak cocok');
      return;
    }

    // TODO: kirim ke backend
    _snack('Kata sandi berhasil diubah');
    Navigator.of(context).pop();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= HEADER =================
          Padding(
            padding: EdgeInsets.fromLTRB(15, topPad + 60, 15, 0),
            child: SizedBox(
              height: 32,
              child: Stack(
                children: [
                  // Back arrow
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
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
                      'Ganti Kata Sandi',
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
          ),

          // ================= CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 46),

                  // ---- Field: Kata Sandi Lama ----
                  _buildLabel('Kata Sandi Lama'),
                  const SizedBox(height: 4),
                  _buildPasswordField(
                    controller: _oldPassC,
                    hide: _hideOld,
                    onToggle: () => setState(() => _hideOld = !_hideOld),
                  ),

                  const SizedBox(height: 36),

                  // ---- Field: Kata Sandi Baru ----
                  _buildLabel('Kata Sandi Baru'),
                  const SizedBox(height: 5),
                  _buildPasswordField(
                    controller: _newPassC,
                    hide: _hideNew,
                    onToggle: () => setState(() => _hideNew = !_hideNew),
                  ),

                  const SizedBox(height: 36),

                  // ---- Field: Konfirmasi Kata Sandi Baru ----
                  _buildLabel('Konfirmasi Kata Sandi Baru'),
                  const SizedBox(height: 6),
                  _buildPasswordField(
                    controller: _confirmPassC,
                    hide: _hideConfirm,
                    onToggle: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                  ),

                  const SizedBox(height: 46),

                  // ---- Tombol Simpan ----
                  GestureDetector(
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
                        'Simpan Kata Sandi',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 24 / 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
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

  // ================= PASSWORD FIELD =================
  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool hide,
    required VoidCallback onToggle,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 14, right: 14),
      decoration: BoxDecoration(
        color: inputBg,
        border: Border.all(color: textBlack, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: hide,
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
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              hide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: textGrey,
            ),
          ),
        ],
      ),
    );
  }
}