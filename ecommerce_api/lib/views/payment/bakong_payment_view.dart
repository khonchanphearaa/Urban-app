import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../controllers/payment_controller.dart';
import '../../widgets/base_modal.dart';

class BakongPaymentView extends StatefulWidget {
  final String orderId;
  final double amount;
  final String orderLabel;

  const BakongPaymentView({
    super.key,
    required this.orderId,
    required this.amount,
    required this.orderLabel,
  });

  @override
  State<BakongPaymentView> createState() => _BakongPaymentViewState();
}

class _BakongPaymentViewState extends State<BakongPaymentView> {
  static const int _expirySeconds =
      2 * 60; // backend expires QR after 2 minutes
  late int _remainingSeconds;
  Timer? _timer;
  Timer? _statusTimer;
  bool _isPaid = false;
  bool _isShowingPaidModal = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _expirySeconds;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<PaymentController>();
      controller.requestBakongQr(context, orderId: widget.orderId);
      _startTimer();
      _startStatusPolling();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _statusTimer?.cancel(); // Stop polling when QR expires
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) return;

      final controller = context.read<PaymentController>();
      final md5 = controller.payment?.md5;
      if (md5 == null || md5.isEmpty) return;

      final status = await controller.checkStatus(
        context,
        orderId: widget.orderId,
      );

      if (!mounted) return;

      final normalized = (status ?? '').toUpperCase();

      if (normalized == 'PAID') {
        /* Payment confirmed — stop all timers */
        timer.cancel();
        _statusTimer?.cancel();
        _timer?.cancel();
        if (!mounted) return;
        setState(() => _isPaid = true);

        if (!_isShowingPaidModal) {
          _isShowingPaidModal = true;
          await BaseModal.alert(
            context,
            title: 'Payment Successful',
            message: 'Your payment has been confirmed and your order is being processed.',
            buttonText: 'Continue',
            buttonColor: const Color(0xFF1A7F5A),
          );
          if (!mounted) return;
          Navigator.of(context).pop(true);
        }
      } else if (normalized == 'CANCELLED' ||
          normalized == 'EXPIRED' ||
          normalized == 'FAILED') {
        
        /* QR expired or payment failed — stop polling */
        timer.cancel();
        _timer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment $normalized'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }

  String _formatRemaining() {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text( 'Pay with KHQR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), ),
      ),
      body: Stack(
        children: [
          _buildGradientHeader(),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                _buildHeroCard(payment),
                const SizedBox(height: 18),
                _buildQrCard(payment),
                const SizedBox(height: 18),
                _buildStepsCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      height: 190,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0055FF), Color(0xFF80AAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildHeroCard(PaymentController payment) {
    final apiAmount = payment.payment?.amount;
    final displayAmount = apiAmount ?? widget.amount;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [ BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0055FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan to Pay',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.orderLabel,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text( 'Order ID: ${widget.orderId}', style: const TextStyle(color: Colors.black54, fontSize: 11), ),
              ],
            ),
          ),
          Text( '\$${displayAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
        ],
      ),
    );
  }

  Widget _buildQrCard(PaymentController payment) {
    final response = payment.payment;

    Widget content;
    if (payment.isLoading) {
      content = const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (response == null) {
      content = const SizedBox(
        height: 220,
        child: Center(
          child: Text('No QR data yet.', style: TextStyle(color: Colors.red)),
        ),
      );
    } else if (response.qrImageUrl != null) {
      content = Image.network(
        response.qrImageUrl!,
        height: 220,
        fit: BoxFit.contain,
      );
    } else if (response.qrImageBase64 != null) {
      final base64 = response.qrImageBase64!;
      final bytes = base64.startsWith('data:image') ? base64Decode(base64.split('base64,').last) : base64Decode(base64);
      content = Image.memory(bytes, height: 220, fit: BoxFit.contain);
    } else if (response.qrData != null) {
      content = QrImageView(
        data: response.qrData!,
        size: 220,
        backgroundColor: Colors.white,
      );
    } else {
      content = const SizedBox(
        height: 220,
        child: Center(child: Text('QR not available')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isPaid) ...[
            const Icon(Icons.check_circle, color: Color(0xFF1A7F5A), size: 54),
            const SizedBox(height: 8),
            const Text(
              '✓ Payment Confirmed',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A7F5A),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (response?.md5 != null && response!.md5!.isNotEmpty) ...[
            
            /* Show active checking indicator when MD5 exists */
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF0055FF).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0055FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Checking payment status...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0055FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          content,
          const SizedBox(height: 12),
          const Text( 'Scan with Bakong or your bank app', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17), ),
          const SizedBox(height: 6),
          Text( 'This QR will expire after a short time. Please complete payment soon.', style: TextStyle(color: Colors.grey[600], fontSize: 12), textAlign: TextAlign.center, ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, size: 16, color: Color(0xFF0055FF)),
                const SizedBox(width: 6),
                Text('Expires in ${_formatRemaining()}', style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0055FF),
                  ),
                ),
                if (payment.status != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: payment.status == 'PAID' ? const Color(0xFF1A7F5A) : const Color(0xFFE0B15A), borderRadius: BorderRadius.circular(8), ),
                    child: Text(
                      payment.status!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: payment.isLoading ? null : () async {
                    final controller = context.read<PaymentController>();
                    await controller.retryBakongQr(
                      context,
                      orderId: widget.orderId,
                    );
                    if (!mounted) return;
                    setState(() => _remainingSeconds = _expirySeconds);
                    _startTimer();
                    _startStatusPolling();
                  },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh QR'),
          ),
          if (_isPaid) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7F5A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Back to Orders',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          if (response?.qrData != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: response!.qrData!));
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('KHQR copied')));
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy KHQR String'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text( 'Payment Steps', style: TextStyle(fontWeight: FontWeight.bold), ),
          const SizedBox(height: 8),
          _stepRow('1', 'Open your banking app and select Scan QR.'),
          _stepRow('2', 'Scan the QR code and verify the amount.'),
          _stepRow('3', 'Confirm payment. We will update your order status.'),
        ],
      ),
    );
  }

  Widget _stepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF0055FF),
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
