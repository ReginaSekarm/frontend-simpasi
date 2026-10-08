
class OnboardingModel {
  final String image;
  final String title;
  final String desc;

  const OnboardingModel({
    required this.image,
    required this.title,
    required this.desc,
  });
}

final List<OnboardingModel> onboardingData = [
  const OnboardingModel(
    image: 'assets/images/onboarding1.png',
    title: 'Selamat Datang',
    desc: 'Aplikasi pendamping tumbuh kembang anak Indonesia.',
  ),
  const OnboardingModel(
    image: 'assets/images/onboarding2.png',
    title: 'Fitur Posyandu',
    desc: 'Pantau jadwal dan catatan kesehatan balita dari mana saja.',
  ),
  const OnboardingModel(
    image: 'assets/images/onboarding3.png',
    title: 'Profil Tumbuh Kembang',
    desc: 'Simpan profil lengkap si Kecil dan lihat grafik perkembangannya dibandingkan standar tumbuh kembang balita Indonesia.',
  ),
  const OnboardingModel(
    image: 'assets/images/onboarding4.png',
    title: 'Forum Diskusi',
    desc: 'Terhubung dengan sesama orang tua dan kader Posyandu se-Indonesia untuk berbagi cerita, bertanya, dan saling mendukung mencegah stunting.',
  ),
];