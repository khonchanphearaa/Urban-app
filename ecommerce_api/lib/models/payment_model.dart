class PaymentResponse {
  final String? orderId;
  final String? paymentId;
  final String? md5;
  final String? qrData;
  final String? qrImageUrl;
  final String? qrImageBase64;
  final double? amount;

  PaymentResponse({
    this.orderId,
    this.paymentId,
    this.md5,
    this.qrData,
    this.qrImageUrl,
    this.qrImageBase64,
    this.amount,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map = json;
    if (json['data'] is Map<String, dynamic>) {
      map = json['data'] as Map<String, dynamic>;
    }

    dynamic getValue(String key) {
      if (map.containsKey(key)) return map[key];
      if (json.containsKey(key)) return json[key];
      return null;
    }

    String? findString(List<String> keys) {
      for (final key in keys) {
        final value = getValue(key);
        if (value != null) return value.toString();
      }
      return null;
    }

    final orderId = (getValue('orderId') ?? getValue('_id') ?? getValue('id'))
        ?.toString();
    final paymentId = getValue('paymentId')?.toString();
    final md5 = getValue('md5')?.toString();

    final qrStringValue = getValue('qr_string')?.toString();
    final qrValue = findString([
      'qrData',
      'qrCode',
      'khqr',
      'khqrData',
      'qrString',
      'qr',
      'qrImage',
      'qrImageUrl',
      'imageUrl',
      'image',
    ]);

    final rawAmount = getValue('amount');
    final amount = rawAmount is num ? rawAmount.toDouble() : double.tryParse(rawAmount?.toString() ?? '');

    String? qrData;
    String? qrImageUrl;
    String? qrImageBase64;

    if (qrStringValue != null && qrStringValue.isNotEmpty) {
      qrData = qrStringValue;
    } else if (qrValue != null) {
      if (qrValue.startsWith('http://') || qrValue.startsWith('https://')) {
        qrImageUrl = qrValue;
      } else if (qrValue.startsWith('data:image')) {
        qrImageBase64 = qrValue;
      } else if (qrValue.startsWith('000201')) {
        /* EMVCo/KHQR payload (numeric prefix) */
        qrData = qrValue;
      } else {
        qrData = qrValue;
      }
    }

    return PaymentResponse(
      orderId: orderId,
      paymentId: paymentId,
      md5: md5,
      qrData: qrData,
      qrImageUrl: qrImageUrl,
      qrImageBase64: qrImageBase64,
      amount: amount,
    );
  }
}
