import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';

class AboutMeView extends StatelessWidget {
  const AboutMeView({super.key});

  static const String _githubUrl = 'https://github.com/khonchanphearaa';
  static const String _emailAddress = 'khonchanphearaa@gmail.com';
  static const String _telegramUrl = 'https://t.me/khonchanphearaa';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final hasAvatar = (user?.avatar ?? '').trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("About Me", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /* Hero Section */
            const SizedBox(height: 10),
            _buildHeroAvatar(user, hasAvatar),
            
            const SizedBox(height: 24),
            Text(
              user?.name ?? 'Developer Name',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
            ),
            const Text(
              'FLUTTER DEVELOPER',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blueAccent, letterSpacing: 2),
            ),

            const SizedBox(height: 20),

            /* Connect Section (Minimalist Icons - No Background) */
            const Text(
              'Connect with me',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  context,
                  icon: Icons.terminal_rounded,
                  color: const Color(0xFF24292E),
                  url: _githubUrl,
                ),
                const SizedBox(width: 30),
                _buildSocialIcon(
                  context,
                  icon: Icons.alternate_email_rounded,
                  color: const Color(0xFFEA4335),
                  url: _emailAddress,
                  isEmail: true,
                ),
                const SizedBox(width: 30),
                _buildSocialIcon(
                  context,
                  icon: Icons.send_rounded,
                  color: const Color(0xFF0088CC),
                  url: _telegramUrl,
                ),
              ],
            ),

            const SizedBox(height: 20),

            /* Information Section */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('About Me'),
                  const SizedBox(height: 12),
                  const Text(
                    'HELLO! am currently y4 student at Royal University of Phnom Penh (RUPP), majoring in Computer Science.'
                    'My goal is to create apps that feel as good as they look. with a REST api Urban Store',
                    style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Expertise'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildSkillChip('Flutter'),
                      _buildSkillChip('Node.js'),
                      _buildSkillChip('Typescript'),
                      _buildSkillChip('GitHub'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Develop by: @khonchanphearaa',
                    style: TextStyle(fontSize: 13, color: Colors.black45, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAvatar(dynamic user, bool hasAvatar) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.1), width: 8),
            ),
          ),
          CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFFF0F0F0),
            backgroundImage: hasAvatar ? NetworkImage(user!.avatar!) : null,
            child: !hasAvatar 
              ? Text(user?.name?[0].toUpperCase() ?? 'U', 
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.blueAccent))
              : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, {required IconData icon, required Color color, required String url, bool isEmail = false}) {
    return Tooltip(
      message: 'Click to ${isEmail ? 'email' : 'visit'}',
      child: InkWell(
        onTap: () => _openLink(context, isEmail ? Uri(scheme: 'mailto', path: url) : Uri.parse(url)),
        onLongPress: () => _copyToClipboard(context, url),
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            size: 36,
            color: color,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.2), thickness: 1)),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  
  Future<void> _openLink(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch link')));
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      HapticFeedback.mediumImpact(); // Adds a nice vibration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied: $value'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.blue,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}