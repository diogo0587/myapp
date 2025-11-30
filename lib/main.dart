
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: const MyApp(),
    ),
  );
}

class NotificationModel {
  final String title;
  final String body;
  final String appName;
  final int timestamp;

  NotificationModel({
    required this.title,
    required this.body,
    required this.appName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'appName': appName,
      'timestamp': timestamp,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      appName: map['appName'] ?? '',
      timestamp: map['timestamp'] is int
          ? map['timestamp'] as int
          : int.tryParse(map['timestamp']?.toString() ?? '') ?? 0,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  String _searchQuery = '';

  List<NotificationModel> get notifications {
    if (_searchQuery.isEmpty) {
      return _notifications;
    }
    return _notifications
        .where((n) =>
            n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            n.body.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            n.appName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  NotificationProvider() {
    loadNotifications();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    saveNotifications();
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    saveNotifications();
    notifyListeners();
  }

  void removeNotificationAt(int index) {
    final notificationToRemove = notifications[index];
    _notifications.remove(notificationToRemove);
    saveNotifications();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsList = _notifications.map((n) => json.encode(n.toMap())).toList();
    await prefs.setStringList('notifications', notificationsList);
  }

  void loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsList = prefs.getStringList('notifications');
    if (notificationsList != null) {
      _notifications = notificationsList.map((n) => NotificationModel.fromMap(json.decode(n))).toList();
      notifyListeners();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Saver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationListScreen(),
    );
  }
}

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  static const _notificationChannel = EventChannel('com.example.myapp/notifications');

  @override
  void initState() {
    super.initState();
    _notificationChannel.receiveBroadcastStream().listen((dynamic event) {
      final notification = NotificationModel.fromMap(Map<String, dynamic>.from(event));
      Provider.of<NotificationProvider>(context, listen: false).addNotification(notification);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all notifications',
            onPressed: () {
              if (provider.notifications.isEmpty) return;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear all'),
                    content: const Text('Delete all saved notifications?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          Provider.of<NotificationProvider>(context, listen: false)
                              .clearAll();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                provider.setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications saved yet. Grant notification access in settings.'),
            );
          }
          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text(notification.appName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailScreen(notification: notification),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Notification'),
                          content: const Text('Are you sure you want to delete this notification?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () {
                                provider.removeNotificationAt(index);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ts = _formatTimestamp(notification.timestamp);
    return Scaffold(
      appBar: AppBar(
        title: Text(notification.appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ts.isNotEmpty)
              Text(
                ts,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8.0),
            Text(
              notification.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            Text(notification.body),
          ],
        ),
      ),
    );
  }
}
