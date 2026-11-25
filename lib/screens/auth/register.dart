import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'otp_verification_screen.dart';
import 'login.dart'; // Pastikan import ini sesuai dengan nama file Anda

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Warna dari Figma
  static const Color primary = Color(0xFFD45060);
  static const Color accent = Color(0xFFF1A038);
  static const Color grey = Color(0xFF8F8F8F);
  static const Color successGreen = Color(0xFF2E7D32);

  // Ganti ke http://10.0.2.2:5000/api jika menjalankan di Android Emulator
  static const String _baseUrl = 'http://localhost:5000/api';

  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _hpC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;
  bool _agree = false;
  bool _isSubmitting = false;

  // STATE UNTUK ERROR NO HP & EMAIL
  String? _hpError;
  String? _emailError;

  // Status validasi real-time kata sandi
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigit = false;

  @override
  void initState() {
    super.initState();
    _passC.addListener(_validatePasswordRealtime);
  }

  void _validatePasswordRealtime() {
    final text = _passC.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
      _hasDigit = RegExp(r'\d').hasMatch(text);
    });
  }

  @override
  void dispose() {
    _passC.removeListener(_validatePasswordRealtime);
    _namaC.dispose();
    _emailC.dispose();
    _hpC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  // ---------- Helper style ----------
  TextStyle _label() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      );

  // DECORATION DIPERBARUI UNTUK MENERIMA ERROR TEXT
  InputDecoration _decoration(String hint, {Widget? suffix, String? errorText}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: grey, width: 1),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: grey),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: primary, width: 1.2),
      ),
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      suffixIcon: suffix,
      errorText: errorText,
      errorStyle: GoogleFonts.inter(fontSize: 10, color: Colors.red),
    );
  }

  // FIELD DIPERBARUI AGAR MENDUKUNG ERROR TEXT & ONCHANGED
  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? type,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(label, style: _label()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: type,
          style: GoogleFonts.inter(fontSize: 14),
          onChanged: onChanged,
          decoration: _decoration(hint, errorText: errorText),
        ),
      ],
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(label, style: _label()),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: _decoration(
              '........',
              suffix: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onToggle,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: grey,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Popup Modal Syarat & Ketentuan ----------
  void _showTermsAndPrivacyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4D4D4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Syarat & Ketentuan Pengguna',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.black54, size: 22),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20, thickness: 1, color: Color(0xFFF0F0F0)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Syarat & Ketentuan ini berlaku bagi Anda sebagai orang tua/wali yang menggunakan aplikasi SIMPASI untuk memantau data tumbuh kembang anak Anda. Dengan membuat akun dan menggunakan SIMPASI, Anda dianggap telah membaca, memahami, dan menyetujui ketentuan berikut.',
                        style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: Colors.black87),
                      ),
                      const SizedBox(height: 14),
                      _modalSectionTitle('1. Tentang Layanan'),
                      _modalSectionBody('SIMPASI adalah aplikasi yang membantu memantau data tumbuh kembang balita, termasuk hasil pemeriksaan antropometri (berat badan, tinggi badan, lingkar kepala, lingkar lengan) dan status gizi yang diinput oleh kader posyandu berdasarkan hasil pemeriksaan langsung terhadap anak Anda.'),
                      _modalSectionTitle('2. Bukan Diagnosis Medis'),
                      _modalSectionBody('Status ("Normal" / "Berisiko" / "Stunting") dan rekomendasi menu adalah hasil pencatatan kader, bukan diagnosis dokter. Kalau ada hal yang mengkhawatirkan, konsultasikan ke puskesmas atau fasilitas kesehatan terdekat.'),
                      _modalSectionTitle('3. Akun Anda'),
                      _modalSectionBody('Jaga kerahasiaan email dan password Anda. Segera hubungi kader/admin bila menduga akun diakses tanpa izin.'),
                      _modalSectionTitle('4. Hak Anda'),
                      _modalSectionBody('Anda berhak melihat riwayat pemeriksaan anak secara transparan dan mengajukan koreksi ke kader bila ada data yang dirasa tidak sesuai.'),
                      _modalSectionTitle('5. Larangan'),
                      _modalSectionBody('Dilarang mengakses data anak lain di luar anak/wali Anda, menyebarkan data kesehatan anak lain tanpa izin, atau mengganggu sistem aplikasi.'),
                      _modalSectionTitle('6. Batasan Tanggung Jawab'),
                      _modalSectionBody('SIMPASI adalah alat bantu pemantauan, bukan pengganti layanan kesehatan resmi. Kami tidak bertanggung jawab atas keputusan yang diambil tanpa konsultasi tenaga kesehatan.'),
                      _modalSectionTitle('7. Perubahan Ketentuan'),
                      _modalSectionBody('Ketentuan ini bisa diperbarui sewaktu-waktu; versi terbaru selalu tersedia di aplikasi.'),
                      const SizedBox(height: 24),
                      Text(
                        'Kebijakan Privasi',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kebijakan ini menjelaskan data apa yang kami kumpulkan dan bagaimana kami menjaganya, karena data kesehatan anak bersifat sensitif.',
                        style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: Colors.black87),
                      ),
                      const SizedBox(height: 14),
                      _modalSectionTitle('1. Data yang Dikumpulkan'),
                      _modalSectionBody('Data akun Anda seperti nama, email, no. HP, password terenkripsi dan data anak seperti nama, tanggal lahir, hasil ukuran fisik, status gizi, catatan kader yang diinput saat pemeriksaan.'),
                      _modalSectionTitle('2. Penggunaan Data'),
                      _modalSectionBody('Untuk menampilkan riwayat tumbuh kembang anak, membantu kader/puskesmas memantau gizi, memberi rekomendasi menu MPASI, dan pelaporan program stunting secara agregat (tanpa identitas).'),
                      _modalSectionTitle('3. Pembagian Data'),
                      _modalSectionBody('Dibagikan ke kader posyandu wilayah Anda dan puskesmas/dinas kesehatan setempat (untuk pelaporan). Kami tidak menjual data ke pihak ketiga.'),
                      _modalSectionTitle('4. Data Anak sebagai Data Sensitif'),
                      _modalSectionBody('Akses dibatasi hanya untuk orang tua/wali terdaftar dan kader yang menangani anak tersebut (role-based access).'),
                      _modalSectionTitle('5. Keamanan Data'),
                      _modalSectionBody('Data disimpan terenkripsi dengan akses terbatas. Setiap perubahan data pemeriksaan tercatat (siapa & kapan mengubah) sebagai jejak audit.'),
                      _modalSectionTitle('6. Hak Anda'),
                      _modalSectionBody('Akses untuk melihat seluruh data anak Anda. Koreksi ajukan perbaikan lewat kader. Ajukan penghapusan akun (data historis bisa tetap tersimpan teragregasi/anonim untuk pelaporan kesehatan sesuai ketentuan berlaku).'),
                      _modalSectionTitle('7. Penyimpanan & Perubahan Kebijakan'),
                      _modalSectionBody('Data disimpan selama akun aktif. Kebijakan ini bisa diperbarui, dan perubahan signifikan akan diinformasikan lewat aplikasi.'),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modalSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
    );
  }

  Widget _modalSectionBody(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12.5,
        height: 1.45,
        color: Colors.black87,
      ),
    );
  }

  // ---------- Popup Kustom Error (Sesuai Figma) ----------
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return _AutoDismissErrorDialog(
          title: title,
          message: message,
        );
      },
    );
  }

  // ---------- Aksi Tombol & Integrasi API Register ----------
  Future<void> _onRegister() async {
    if (_isSubmitting) return;

    setState(() {
      _hpError = null;
      _emailError = null;
    });

    final fullName = _namaC.text.trim();
    final email = _emailC.text.trim();
    final phone = _hpC.text.trim();
    final password = _passC.text;
    final confirmPassword = _confirmC.text;

    // 1. Cek kolom kosong
    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog(
        'Semua Kolom Wajib Diisi',
        'Silakan lengkapi nama, email, no. HP, dan kata sandi Anda terlebih dahulu sebelum mendaftar.',
      );
      return;
    }

    // 2. Cek Panjang No. HP (MINIMAL 11 & MAKSIMAL 13 DIGIT)
    final int hpLength = phone.length;
    if (hpLength < 11 || hpLength > 13) {
      setState(() {
        _hpError = 'No. HP harus 11 - 13 digit';
      });
      return;
    }

    // 3. Cek format email
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() {
        _emailError = 'Format email tidak valid';
      });
      return;
    }

    // 4. Cek kriteria kata sandi
    if (!_hasMinLength || !_hasUppercase || !_hasDigit) {
      _showErrorDialog(
        'Kata Sandi Belum Memenuhi Ketentuan',
        'Kata sandi minimal 8 karakter, harus mengandung 1 huruf besar dan 1 angka.',
      );
      return;
    }

    // 5. Cek konfirmasi kata sandi
    if (password != confirmPassword) {
      _showErrorDialog(
        'Konfirmasi Kata Sandi Salah',
        'Kata sandi dan konfirmasi kata sandi tidak sama. Silakan periksa kembali.',
      );
      return;
    }

    // 6. Cek persetujuan S&K
    if (!_agree) {
      _showErrorDialog(
        'Persetujuan Dibutuhkan',
        'Anda harus menyetujui Syarat & Ketentuan serta Kebijakan Privasi terlebih dahulu.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': fullName,
              'email': email,
              'phone': phone,
              'password': password,
              'confirmPassword': confirmPassword,
              'agreeToTerms': _agree,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      Map<String, dynamic> body = {};
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      }

      final message = (body['message'] as String?) ??
          (response.statusCode == 201
              ? 'Registrasi berhasil! Kode OTP telah dikirim ke email Anda.'
              : 'Gagal mendaftar. Silakan coba lagi.');

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
        return;
      }

      if (response.statusCode == 409 && body['needsVerification'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
        return;
      }

      if (response.statusCode == 409) {
        setState(() => _emailError = message);
      }

      _showErrorDialog('Registrasi Gagal', message);
    } on TimeoutException {
      if (!mounted) return;
      _showErrorDialog(
        'Koneksi Terputus',
        'Permintaan ke server memakan waktu terlalu lama. Periksa koneksi Anda lalu coba lagi.',
      );
    } catch (_) {
      if (!mounted) return;
      _showErrorDialog(
        'Gagal Terhubung ke Server',
        'Tidak dapat menghubungi server. Pastikan backend berjalan dan alamat server sudah benar.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background merah melengkung
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 322,
              decoration: const BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),

          // Konten Form
          SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Maskot
                          Image.asset(
                            'assets/images/start-melet-buka.png',
                            height: 76,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.child_care,
                              size: 76,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            'Buat Akun',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Daftar sekarang untuk mulai perjalanan Anda',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Card form
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.fromLTRB(21, 20, 21, 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: grey, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _field(
                                  label: 'Nama Lengkap',
                                  hint: 'nama lengkap',
                                  controller: _namaC,
                                ),
                                const SizedBox(height: 20),

                                _field(
                                  label: 'Alamat Email',
                                  hint: 'nama@gmail.com',
                                  controller: _emailC,
                                  type: TextInputType.emailAddress,
                                  errorText: _emailError,
                                  onChanged: (val) {
                                    if (_emailError != null &&
                                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                            .hasMatch(val.trim())) {
                                      setState(() => _emailError = null);
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),

                                _field(
                                  label: 'No.HP',
                                  hint: '08xxxxxxxxxx',
                                  controller: _hpC,
                                  type: TextInputType.phone,
                                  errorText: _hpError,
                                  onChanged: (val) {
                                    final int length = val.trim().length;
                                    if (_hpError != null &&
                                        length >= 11 &&
                                        length <= 13) {
                                      setState(() => _hpError = null);
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _passwordField(
                                        label: 'Kata Sandi',
                                        controller: _passC,
                                        obscure: _hidePass,
                                        onToggle: () =>
                                            setState(() => _hidePass = !_hidePass),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _passwordField(
                                        label: 'Konfirmasi',
                                        controller: _confirmC,
                                        obscure: _hideConfirm,
                                        onToggle: () => setState(
                                            () => _hideConfirm = !_hideConfirm),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    '*Kata sandi min 8 karakter, 1 huruf besar dan 1 angka',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: (_hasMinLength &&
                                              _hasUppercase &&
                                              _hasDigit)
                                          ? successGreen
                                          : grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: Checkbox(
                                        value: _agree,
                                        onChanged: _isSubmitting
                                            ? null
                                            : (v) => setState(
                                                () => _agree = v ?? false),
                                        activeColor: primary,
                                        checkColor: Colors.white,
                                        fillColor: WidgetStateProperty.resolveWith(
                                          (states) => states
                                                  .contains(WidgetState.selected)
                                              ? primary
                                              : const Color(0xFFF7F8F0),
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF797777),
                                          width: 1.7,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: Colors.black,
                                          ),
                                          children: [
                                            const TextSpan(
                                                text: 'Saya menyetujui '),
                                            TextSpan(
                                              text: 'Syarat & Ketentuan',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: primary,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () =>
                                                    _showTermsAndPrivacyModal(
                                                        context),
                                            ),
                                            const TextSpan(text: ' serta '),
                                            TextSpan(
                                              text: 'Kebijakan Privasi',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: primary,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () =>
                                                    _showTermsAndPrivacyModal(
                                                        context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // Tombol Daftar
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : _onRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      disabledBackgroundColor:
                                          accent.withValues(alpha: 0.65),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Daftar Sekarang',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 20),

                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Masuk di sini',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= WIDGET POPUP AUTO-DISMISS =================
class _AutoDismissErrorDialog extends StatefulWidget {
  final String title;
  final String message;

  const _AutoDismissErrorDialog({
    required this.title,
    required this.message,
  });

  @override
  State<_AutoDismissErrorDialog> createState() => _AutoDismissErrorDialogState();
}

class _AutoDismissErrorDialogState extends State<_AutoDismissErrorDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: 335,
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF0000),
              size: 60,
            ),
            const SizedBox(height: 17),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 24 / 20,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8F8F8F),
                height: 17 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}