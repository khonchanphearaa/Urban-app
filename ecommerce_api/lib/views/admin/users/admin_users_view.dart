import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/admin/admin_user_controller.dart';
import '../../../models/admin_user_model.dart';
import '../../../widgets/pagination_widget.dart';
import 'package:intl/intl.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUserController>().fetchUsers(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<AdminUserController>();
    final users = userController.users;
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
          'Manage Users',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () =>
                userController.fetchUsers(page: userController.currentPage),
          ),
        ],
      ),
      body: userController.isLoading && users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : userController.error != null && users.isEmpty
          ? _buildErrorState(userController)
          : users.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Stats card
                if (users.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildStatsCard(userController),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => userController.fetchUsers(
                      page: userController.currentPage,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(
                          context,
                          users[index],
                          userController,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomSafe + 24),
                  child: PaginationWidget(
                    currentPage: userController.currentPage,
                    totalPages: userController.totalPages,
                    total: userController.total,
                    limit: userController.limit,
                    minItemsToShow: 6,
                    isLoading: userController.isLoading,
                    onPageChanged: (page) {
                      userController.fetchUsers(page: page);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard(AdminUserController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4597E5), Color(0xFF1E64B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Users',
            controller.total.toString(),
            Icons.people,
          ),
          _buildStatItem(
            'Admins',
            controller.totalAdmins.toString(),
            Icons.admin_panel_settings,
          ),
          _buildStatItem(
            'Active',
            controller.totalActiveUsers.toString(),
            Icons.verified,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
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
              Icons.people_outline,
              size: 60,
              color: Color(0xFF4597E5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No users found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Users will appear here once they register',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AdminUserController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Failed to load users',
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
              onPressed: () => controller.fetchUsers(page: 1),
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

  Widget _buildUserCard(
    BuildContext context,
    AdminUserModel user,
    AdminUserController controller,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final accountColor = user.isActive ? Colors.green : Colors.red;
    final roleColor = user.isAdmin
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF4597E5);

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
          _showUserDetails(context, user, controller);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User header
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: roleColor, width: 1),
                    ),
                    child: user.profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              user.profileImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildAvatarPlaceholder(user, roleColor),
                            ),
                          )
                        : _buildAvatarPlaceholder(user, roleColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: roleColor, width: 1),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: roleColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // User details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        user.isActive
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                        size: 16,
                        color: accountColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accountColor,
                        ),
                      ),
                    ],
                  ),
                  if (user.createdAt != null)
                    Text(
                      'Joined ${dateFormat.format(user.createdAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showRoleChangeDialog(context, user, controller);
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Role'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4597E5),
                        side: const BorderSide(color: Color(0xFF4597E5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showStatusChangeDialog(context, user, controller);
                      },
                      icon: Icon(
                        user.isActive ? Icons.lock_outline : Icons.lock_open,
                        size: 16,
                      ),
                      label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(AdminUserModel user, Color color) {
    return Center(
      child: Text(
        user.name.isNotEmpty
            ? user.name[0].toUpperCase()
            : user.email[0].toUpperCase(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showUserDetails(
    BuildContext context,
    AdminUserModel user,
    AdminUserController controller,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
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
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User Details',
                        style: TextStyle(
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
                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildDetailSection('Account Information', [
                        _buildDetailRow('Name', user.displayName),
                        _buildDetailRow('Email', user.email),
                        if (user.phone != null && user.phone!.isNotEmpty)
                          _buildDetailRow('Phone', user.phone!),
                        _buildDetailRow(
                          'Role',
                          user.role.toUpperCase(),
                          valueColor: user.isAdmin
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFF4597E5),
                        ),
                        _buildDetailRow(
                          'Status',
                          user.isActive ? 'Active' : 'Inactive',
                          valueColor: user.isActive ? Colors.green : Colors.red,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('Account Timeline', [
                        if (user.createdAt != null)
                          _buildDetailRow(
                            'Joined',
                            dateFormat.format(user.createdAt!),
                          ),
                        if (user.updatedAt != null)
                          _buildDetailRow(
                            'Last Updated',
                            dateFormat.format(user.updatedAt!),
                          ),
                      ]),
                      const SizedBox(height: 20),
                      // Delete user section
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(context, user, controller);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
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

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
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
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeDialog(
    BuildContext context,
    AdminUserModel user,
    AdminUserController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current role: ${user.role.toUpperCase()}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            const Text('Select new role:'),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('User'),
              value: 'user',
              groupValue: user.role,
              onChanged: (value) async {
                Navigator.pop(context);
                final success = await controller.updateUserRole(
                  userId: user.id,
                  role: 'user',
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User role updated to user'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Admin'),
              value: 'admin',
              groupValue: user.role,
              onChanged: (value) async {
                Navigator.pop(context);
                final success = await controller.updateUserRole(
                  userId: user.id,
                  role: 'admin',
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User role updated to admin'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog(
    BuildContext context,
    AdminUserModel user,
    AdminUserController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
        content: Text(
          user.isActive
              ? 'Are you sure you want to deactivate this user? They will not be able to login.'
              : 'Are you sure you want to activate this user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.toggleUserStatus(
                userId: user.id,
                isActive: !user.isActive,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      user.isActive ? 'User deactivated' : 'User activated',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(user.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AdminUserModel user,
    AdminUserController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to permanently delete ${user.displayName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteUser(userId: user.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
