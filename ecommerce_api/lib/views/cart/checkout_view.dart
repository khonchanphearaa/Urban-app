import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../payment/bakong_payment_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  String _paymentMethod = 'BAKONG_KHQR';

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  int _parseDiscount() {
    return int.tryParse(_discountController.text.trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final order = context.watch<OrderController>();
    final items = cart.items;

    final subtotal = items.fold<double>(
      0.0,
      (prev, it) => prev + (it.price * it.quantity),
    );
    final discountPercent = _parseDiscount().clamp(0, 90);
    final discountAmount = subtotal * (discountPercent / 100.0);
    final shipping = items.isEmpty ? 0.0 : 10.0;
    final total = (subtotal - discountAmount) + shipping;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Delivery Details'),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration(
                      'Delivery Address',
                      Icons.location_on_outlined,
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Please enter delivery address'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      'Phone Number',
                      Icons.phone_outlined,
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Please enter phone number'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 10),
            _buildPaymentSelector(),
            const SizedBox(height: 22),
            _buildSectionTitle('Discount'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Discount Percent',
                Icons.local_offer_outlined,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 10),
            _buildSummaryCard(subtotal, discountAmount, shipping, total),
            const SizedBox(height: 24),
            _buildPlaceOrderButton(order.isLoading, total),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(bool isLoading, double total) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : () async {
                if (!_formKey.currentState!.validate()) return;

                final request = OrderRequest(
                  deliveryAddress: _addressController.text.trim(),
                  phoneNumber: _phoneController.text.trim(),
                  paymentMethod: _paymentMethod,
                  discountPercent: _parseDiscount().clamp(0, 90),
                );

                final orderController = context.read<OrderController>();
                final cartController = context.read<CartController>();
                final items = cartController.items;
                final orderLabel = items.isEmpty ? 'Order' : (items.length == 1) ? items.first.name : '${items.first.name} + ${items.length - 1} more';

                final orderId = await orderController.placeOrder(
                  context,
                  request: request,
                );

                if (!mounted) return;
                if (orderId == null) return;

                cartController.clearCart();

                if (_paymentMethod == 'BAKONG_KHQR') {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BakongPaymentView(
                        orderId: orderId,
                        amount: total,
                        orderLabel: orderLabel,
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
        child: isLoading ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Process Order',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildSummaryCard(
    double subtotal,
    double discountAmount,
    double shipping,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', subtotal),
          _summaryRow('Discount', -discountAmount),
          _summaryRow('Shipping', shipping),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _summaryRow('Total', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildPaymentSelector() {
    const methods = ['BAKONG_KHQR', 'CASH_ON_DELIVERY', 'CARD'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _paymentMethod,
          items: methods .map(
                (m) => DropdownMenuItem<String>(
                  value: m,
                  child: Text(m.replaceAll('_', ' ')),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _paymentMethod = value);
          },
        ),
      ),
    );
  }
}
