import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/admin/admin_order_controller.dart';
import '../../../models/order_model.dart';
import '../../../widgets/pagination_widget.dart';
import 'package:intl/intl.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderController>().fetchOrders(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderController = context.watch<AdminOrderController>();
    final orders = orderController.orders;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () =>
                orderController.fetchOrders(page: orderController.currentPage),
          ),
        ],
      ),
      body: orderController.isLoading && orders.isEmpty ? const Center(child: CircularProgressIndicator()) : orderController.error != null && orders.isEmpty ? _buildErrorState(orderController) : orders.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => orderController.fetchOrders(
                      page: orderController.currentPage,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(
                          context,
                          orders[index],
                          orderController,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomSafe + 24),
                  child: PaginationWidget(
                    currentPage: orderController.currentPage,
                    totalPages: orderController.totalPages,
                    total: orderController.total,
                    limit: orderController.limit,
                    minItemsToShow: 6,
                    isLoading: orderController.isLoading,
                    onPageChanged: (page) {
                      orderController.fetchOrders(page: page);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FD),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Color(0xFF4597E5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Orders will appear here once customers place them',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AdminOrderController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Failed to load orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchOrders(page: 1),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4597E5),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    AdminOrderController controller,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showOrderDetails(context, order, controller);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              /* Order header */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(order.id.length - 8)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.userName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              /* Order details */
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.shopping_bag_outlined,
                      '${order.items.length} items',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoItem(Icons.phone_outlined, order.phoneNumber),
              const SizedBox(height: 8),
              _buildInfoItem(
                Icons.location_on_outlined,
                order.deliveryAddress,
                maxLines: 2,
              ),
              if (order.createdAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoItem(
                  Icons.access_time,
                  dateFormat.format(order.createdAt!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  void _showOrderDetails(
    BuildContext context,
    OrderModel order,
    AdminOrderController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _OrderDetailsSheet(order: order, controller: controller),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final OrderModel order;
  final AdminOrderController controller;

  const _OrderDetailsSheet({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              
              /* Handle bar */
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              /* Title */
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(order.id.length - 8)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              /* Content */
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    
                    /* Customer info */
                    _buildSection('Customer Information', [
                      _buildDetailRow('Name', order.userName),
                      _buildDetailRow('Phone', order.phoneNumber),
                      _buildDetailRow('Address', order.deliveryAddress),
                    ]),
                    const SizedBox(height: 20),
                    
                    /* Order items */
                    _buildSection(
                      'Order Items (${order.items.length})',
                      order.items.map((item) => _buildOrderItem(item)).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    /* Payment info */
                    _buildSection('Payment Information', [
                      _buildDetailRow(
                        'Method',
                        order.paymentMethod.toUpperCase(),
                      ),
                      if (order.discountPercent > 0)
                        _buildDetailRow(
                          'Discount',
                          '${order.discountPercent}%',
                        ),
                      _buildDetailRow(
                        'Total Amount',
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    
                    /* Order dates */
                    _buildSection('Order Timeline', [
                      if (order.createdAt != null)
                        _buildDetailRow(
                          'Created',
                          dateFormat.format(order.createdAt!),
                        ),
                      if (order.updatedAt != null)
                        _buildDetailRow(
                          'Updated',
                          dateFormat.format(order.updatedAt!),
                        ),
                    ]),
                    const SizedBox(height: 20),
                    
                    /* Status update section */
                    _buildStatusUpdateSection(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'x${item.quantity} • \$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Update Order Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusChip(context, 'pending', Colors.orange),
            _buildStatusChip(context, 'processing', Colors.blue),
            _buildStatusChip(context, 'shipped', Colors.purple),
            _buildStatusChip(context, 'delivered', Colors.green),
            _buildStatusChip(context, 'cancelled', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status, Color color) {
    final isCurrentStatus = order.status.toLowerCase() == status;
    return GestureDetector(
      onTap: isCurrentStatus
          ? null
          : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Update Order Status'),
                  content: Text(
                    'Change order status to "${status.toUpperCase()}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                final success = await controller.updateOrderStatus(
                  orderId: order.id,
                  status: status,
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order status updated to $status'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentStatus ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: isCurrentStatus ? 2 : 1),
        ),
        child: Text(
          status[0].toUpperCase() + status.substring(1),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isCurrentStatus ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
