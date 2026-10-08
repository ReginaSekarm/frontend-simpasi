class ChildData {
  String nama;
  String gender;
  String umur;
  String status;
  String berat;
  String tinggi;
  String kepala;
  String lila;
  String alergi;
  String tempat;       // Tambahan baru
  String tanggalLahir;

  ChildData({
    required this.nama,
    required this.gender,
    required this.umur,
    required this.status,
    required this.berat,
    required this.tinggi,
    required this.kepala,
    required this.lila,
    this.alergi = '',
    this.tempat = '',
    this.tanggalLahir = '',
  });
}