import 'package:flutter/material.dart';
import '../../app/routes/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../utils/language_controller.dart';

/// Navigation Drawer with options: Home, My Crops, Articles & Guides, Chat, About Us, Contact Us, Language Switcher
class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageController.instance,
      builder: (context, lang, child) {
        return Drawer(
          backgroundColor: AppColors.background,
          child: Column(
            children: [
              // Drawer Header with App branding
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.darkPill,
                ),
                accountName: Text(
                  LanguageController.instance.getText('app_title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                accountEmail: Text(
                  LanguageController.instance.isSinhala
                      ? 'ඔබගේ කෘෂිකාර්මික සහයකයා'
                      : 'Your Smart Farming Assistant',
                  style: TextStyle(color: Colors.white.withAlpha(200)),
                ),
                currentAccountPicture: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Navigation Options List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_rounded, color: AppColors.darkPill),
                      title: Text(
                        LanguageController.instance.getText('home'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, RouteNames.home);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.grass_rounded, color: AppColors.primary),
                      title: Text(
                        LanguageController.instance.getText('my_crops'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.menu_book_rounded, color: Colors.purple),
                      title: Text(
                        LanguageController.instance.getText('articles'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.forum_rounded, color: Colors.indigo),
                      title: Text(
                        LanguageController.instance.getText('chat'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                      title: Text(
                        LanguageController.instance.getText('about'),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.contact_support_outlined, color: AppColors.textSecondary),
                      title: Text(
                        LanguageController.instance.getText('contact'),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showContactDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Language Toggle Card
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.lightLavender.withAlpha(128),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language, color: AppColors.darkPill),
                        const SizedBox(width: 8),
                        Text(
                          LanguageController.instance.isSinhala ? 'භාෂාව (Language)' : 'Language (භාෂාව)',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Switch(
                      value: LanguageController.instance.isSinhala,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        LanguageController.instance.toggleLanguage();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: LanguageController.instance.getText('app_title'),
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 40),
      children: [
        Text(
          LanguageController.instance.isSinhala
              ? 'ගොවීන්ගේ වගා කටයුතු සහ තොරතුරු සූක්ෂමව පාලනය කිරීමට සෑදූ ඇප් එකකි.'
              : 'A smart assistant designed for farmers to manage crops and farming information efficiently.',
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LanguageController.instance.getText('contact')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('📧 Email: support@farmingapp.com'),
            SizedBox(height: 8),
            Text('📞 Phone: +94 77 123 4567'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
