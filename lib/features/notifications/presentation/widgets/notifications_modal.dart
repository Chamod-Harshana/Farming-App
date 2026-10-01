import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/language_controller.dart';

class NotificationItem {
  final String id;
  final String titleSi;
  final String titleEn;
  final String bodySi;
  final String bodyEn;
  final String timeAgoSi;
  final String timeAgoEn;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.titleSi,
    required this.titleEn,
    required this.bodySi,
    required this.bodyEn,
    required this.timeAgoSi,
    required this.timeAgoEn,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

class NotificationsModal extends StatefulWidget {
  const NotificationsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsModal(),
    );
  }

  @override
  State<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends State<NotificationsModal> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      titleSi: 'කාලගුණ අනතුරු ඇඟවීම',
      titleEn: 'Weather Alert',
      bodySi: 'හෙට පස්වරුවේ තද වැසි අපේක්ෂා කෙරේ. ජලාපවහන මාර්ග පිරිසිදු කරගන්න.',
      bodyEn: 'Heavy rain expected tomorrow afternoon. Ensure proper drainage.',
      timeAgoSi: 'පැය 1කට පෙර',
      timeAgoEn: '1 hour ago',
      icon: Icons.thunderstorm_rounded,
      iconColor: Colors.blue,
    ),
    NotificationItem(
      id: '2',
      titleSi: 'පොහොර යෙදීමේ මතක් කිරීම',
      titleEn: 'Fertilizer Reminder',
      bodySi: 'ඔබගේ වී වගාව සඳහා දෙවන කාබනික පොහොර යෙදීමට කාලයයි.',
      bodyEn: 'Time for the second organic fertilizer application on your rice crop.',
      timeAgoSi: 'පැය 3කට පෙර',
      timeAgoEn: '3 hours ago',
      icon: Icons.eco_rounded,
      iconColor: AppColors.primary,
    ),
    NotificationItem(
      id: '3',
      titleSi: 'පළිබෝධ පාලන උපදෙස්',
      titleEn: 'Pest Control Tip',
      bodySi: 'ගොයම් කෘමීන් පාලනය සඳහා ස්වාභාවික කොහොඹ සාරය භාවිතයට ගොවි උපදෙස්.',
      bodyEn: 'Natural neem extract advice for controlling paddy insects.',
      timeAgoSi: 'ඊයේ',
      timeAgoEn: 'Yesterday',
      icon: Icons.bug_report_rounded,
      iconColor: Colors.orange,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      titleSi: 'වෙළඳපොළ මිල ගණන්',
      titleEn: 'Market Price Update',
      bodySi: 'අද දිනයේ එළවළු සඳහා ලැබුණු නවතම තොග මිල ගණන් පරීක්ෂා කරන්න.',
      bodyEn: 'Check the latest wholesale vegetable market prices for today.',
      timeAgoSi: 'දින 2කට පෙර',
      timeAgoEn: '2 days ago',
      icon: Icons.storefront_rounded,
      iconColor: Colors.purple,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isSinhala = LanguageController.instance.isSinhala;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle indicator
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LanguageController.instance.getText('notifications'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isSinhala ? 'නවතම දැනුම්දීම් සහ පණිවිඩ' : 'Latest alerts and messages',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),

          // Notifications List
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isSinhala ? 'දැනට දැනුම්දීම් කිසිවක් නැත' : 'No notifications available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: item.isRead ? Colors.white : AppColors.lightLavender.withAlpha(100),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.isRead ? Colors.grey.shade200 : AppColors.primary.withAlpha(50),
                            width: item.isRead ? 1 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: item.iconColor.withAlpha(30),
                                radius: 24,
                                child: Icon(item.icon, color: item.iconColor, size: 24),
                              ),
                              if (!item.isRead)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  isSinhala ? item.titleSi : item.titleEn,
                                  style: TextStyle(
                                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                isSinhala ? item.timeAgoSi : item.timeAgoEn,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              isSinhala ? item.bodySi : item.bodyEn,
                              style: TextStyle(
                                fontSize: 13,
                                color: item.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              item.isRead = true;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
