import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification/app.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';
import 'package:path_provider/path_provider.dart';

import '../featues_export.dart';

class NotificationService {
  static final _winNotifyPlugin =
      WindowsNotification(applicationId: "flutter_notification");
  static Future<void> initializeNotification() async {
    // Add in main method.
    await localNotifier.setup(
      appName: 'flutter_notification',
      // The parameter shortcutPolicy only works on Windows
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    log('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    log('onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const SecondScreen(),
        ),
      );
    }
  }

  static Future<void> jsonDataNotification(Map<String, Object> jsonData) async {
    if (Platform.isWindows) {
      // Refactor JSON data to match Windows toast format
      final String title = jsonData['title'] as String;
      final String body = jsonData['body'] as String;
      final String launch = jsonData['launch'] as String;

      final String template = '''
      <toast activationType="background" launch="$launch">
        <visual>
          <binding template="ToastGeneric">
            <text>$title</text>
            <text>$body</text>
          </binding>
        </visual>
      </toast>
    ''';
      NotificationMessage message =
          NotificationMessage.fromCustomTemplate("test1", group: "jj");
      // Send notification using windows_notification package
      _winNotifyPlugin.showNotificationCustomTemplate(message, template);
    } else {
      // Send notification using awesome_notifications package
      await AwesomeNotifications().createNotificationFromJsonData(jsonData);
    }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));
    log("showNotification Triggered");
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      //!Local Notifier
      // LocalNotification notification = LocalNotification(
      //   title: title,
      //   body: body,

      // );

      // notification.onShow = () {
      //   log('onShow ${notification.identifier}');
      // };
      // notification.onClose = (closeReason) {
      //   // Only supported on windows, other platforms closeReason is always unknown.
      //   switch (closeReason) {
      //     case LocalNotificationCloseReason.userCanceled:
      //       // do something
      //       break;
      //     case LocalNotificationCloseReason.timedOut:
      //       // do something
      //       break;
      //     default:
      //   }
      //   log('onClose  - $closeReason');
      // };
      // notification.onClick = () {
      //   log('onClick ${notification.identifier}');
      // };
      // notification.onClickAction = (actionIndex) {
      //   log('onClickAction ${notification.identifier} - $actionIndex');
      // };
      // notification.show();
      //!Windows Notification
      // Refactor JSON data to match Windows toast format
// Get the directory where the app's icon is stored
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();

      // Check if the icon file exists in the directory
      final File iconFile = File('${documentsDirectory.path}app_icon.png');
      final String template = '''
<?xml version="1.0" encoding="utf-8"?>
        <toast launch='conversationId=9813' activationType="background">
    <visual>
        <binding template='ToastGeneric'>
            <text>$title</text>
            <text>$body</text>
            <image src='${iconFile.path}'/>
        </binding>
    </visual>
    <actions>
        <action content='Archive'  arguments='action:archive'/>
    </actions>
</toast>
      ''';
      NotificationMessage message =
          NotificationMessage.fromCustomTemplate("test1", group: "jj");
      // Send notification using windows_notification package
      _winNotifyPlugin.showNotificationCustomTemplate(message, template);
      return;
    }
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
              interval: interval,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }
}
