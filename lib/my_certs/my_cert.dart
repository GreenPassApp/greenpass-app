class MyCert {
  final String qrCode;

  MyCert({required this.qrCode});

  MyCert.fromJson(Map<String, dynamic> json)
    : this.qrCode = json['qr'];

  Map<String, dynamic> toJson() => {
    'qr': this.qrCode,
  };
}