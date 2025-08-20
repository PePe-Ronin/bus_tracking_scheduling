import 'package:flutter/material.dart';
import 'package:bus/services/notification_service.dart';

class NotificationList extends StatelessWidget {
  final String parentId;

  const NotificationList({
    super.key,
    required this.parentId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: NotificationService.getNotifications(parentId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRead = notification['read'] ?? false;

              return ListTile(
                leading: Icon(
                  _getIconForType(notification['type']),
                  color: isRead ? Colors.grey : Colors.blue,
                ),
                title: Text(
                  notification['title'] ?? 'Notification',
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notification['message'] ?? ''),
                trailing: Text(
                  _formatTimestamp(notification['timestamp']),
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  if (!isRead) {
                    NotificationService.markAsRead(
                      parentId,
                      notification['id'],
                    );
                  }
                },
              );
            },
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'arrival':
        return Icons.directions_bus;
      case 'boarding':
        return Icons.person_add;
      case 'dropoff':
        return Icons.exit_to_app;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
