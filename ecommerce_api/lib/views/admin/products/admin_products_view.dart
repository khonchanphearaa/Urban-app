import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/admin/admin_product_controller.dart';
import '../../../models/product_model.dart';
import '../../../widgets/pagination_widget.dart';
import 'add_edit_product_view.dart';

class AdminProductsView extends StatefulWidget {
  const AdminProductsView({super.key});

  @override
  State<AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<AdminProductsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductController>().fetchProducts(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<AdminProductController>();
    final products = productController.products;
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
          'Manage Products',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: productController.isLoading && products.isEmpty ? const Center(child: CircularProgressIndicator()) : productController.error != null && products.isEmpty ? _buildErrorState(productController) : products.isEmpty ? _buildEmptyState() : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => productController.fetchProducts(
                      page: productController.currentPage,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(
                          context,
                          products[index],
                          productController,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomSafe + 88),
                  child: PaginationWidget(
                    currentPage: productController.currentPage,
                    totalPages: productController.totalPages,
                    total: productController.total,
                    limit: productController.limit,
                    minItemsToShow: 6,
                    isLoading: productController.isLoading,
                    onPageChanged: (page) {
                      productController.fetchProducts(page: page);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductView()),
          );
        },
        backgroundColor: const Color(0xFF4597E5),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
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
              Icons.inventory_2_outlined,
              size: 60,
              color: Color(0xFF4597E5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No products yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first product to get started',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AdminProductController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Failed to load products',
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
              onPressed: () => controller.fetchProducts(page: 1),
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

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    AdminProductController controller,
  ) {
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            
            /* Product Image */
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFEAF3FD),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF4597E5),
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? const Color(0xFF4597E5).withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: product.stock > 0
                                ? const Color(0xFF4597E5)
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditProductView(product: product),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteDialog(context, product, controller);
                } else if (value == 'stock') {
                  _showAddStockDialog(context, product, controller);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'stock',
                  child: Row(
                    children: [
                      Icon(Icons.add_box_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Add Stock'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProductModel product,
    AdminProductController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (product.id.isNotEmpty) {
                controller.deleteProduct(product.id);
              }
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog(
    BuildContext context,
    ProductModel product,
    AdminProductController controller,
  ) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Stock'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            hintText: 'Enter quantity to add',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (quantity > 0 && product.id.isNotEmpty) {
                controller.addStock(product.id, quantity);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
