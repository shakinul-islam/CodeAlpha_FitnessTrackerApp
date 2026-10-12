
import 'package:flutter/material.dart';

import '../core/notification_service.dart';
import '../core/theme.dart';

class NotificationSettingsScreen
    extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
  });

  @override
  State<NotificationSettingsScreen>
      createState() =>
          _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<
        NotificationSettingsScreen> {
  bool _loading = true;

  bool _waterReminder = false;

  bool _changing = false;

  @override
  void initState() {
    super.initState();

    _load();
  }

  // ============================================================
  // LOAD CURRENT STATUS
  // ============================================================

  Future<void> _load() async {
    final enabled =
        await NotificationService
            .instance
            .isWaterReminderEnabled();

    final scheduled =
        await NotificationService
            .instance
            .isWaterReminderScheduled();

    if (!mounted) {
      return;
    }

    setState(() {
      // Show ON only when both:
      // 1. User enabled it
      // 2. Android has the pending schedule
      _waterReminder =
          enabled && scheduled;

      _loading = false;
    });
  }

  // ============================================================
  // CHANGE WATER REMINDER
  // ============================================================

  Future<void> _setReminder(
    bool value,
  ) async {
    if (_changing) {
      return;
    }

    setState(() {
      _changing = true;
    });

    final success =
        await NotificationService
            .instance
            .setWaterReminderEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    if (!success && value) {
      setState(() {
        _waterReminder = false;
        _changing = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Required notification or alarm permission is not enabled. '
            'Please allow it and turn the reminder on again.',
          ),
        ),
      );

      return;
    }

    if (value) {
      final scheduled =
          await NotificationService
              .instance
              .isWaterReminderScheduled();

      if (!mounted) {
        return;
      }

      setState(() {
        _waterReminder =
            scheduled;

        _changing =
            false;
      });

      if (scheduled) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Water reminder enabled.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'The reminder could not be scheduled. '
              'Please check Android alarm and battery settings.',
            ),
          ),
        );
      }

      return;
    }

    setState(() {
      _waterReminder =
          false;

      _changing =
          false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Water reminder disabled.',
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
      ),

      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            colors: [
              AppTheme.bgColor,
              Color(
                0xFF071827,
              ),
            ],

            begin:
                Alignment.topCenter,

            end:
                Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          top: false,

          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        AppTheme.accentColor,
                  ),
                )
              : ListView(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(
                        18,
                      ),

                      decoration:
                          AppTheme.premiumCard(
                        borderColor:
                            AppTheme
                                .accentColor
                                .withOpacity(
                          .15,
                        ),
                      ),

                      child:
                          SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,

                        value:
                            _waterReminder,

                        onChanged:
                            _changing
                                ? null
                                : _setReminder,

                        activeThumbColor:
                            AppTheme
                                .accentColor,

                        secondary:
                            Container(
                          height:
                              48,

                          width:
                              48,

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .blueAccent
                                .withOpacity(
                              .13,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),

                          child:
                              const Icon(
                            Icons
                                .water_drop_rounded,

                            color:
                                Colors
                                    .blueAccent,
                          ),
                        ),

                        title:
                            const Text(
                          'Water Reminder',

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                        subtitle:
                            const Padding(
                          padding:
                              EdgeInsets.only(
                            top:
                                4,
                          ),

                          child:
                              Text(
                            'Receive hydration reminders throughout the day.',

                            style:
                                TextStyle(
                              color: AppTheme
                                  .textSecondary,

                              fontSize:
                                  12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_changing) ...[
                      const SizedBox(
                        height:
                            20,
                      ),

                      const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              AppTheme
                                  .accentColor,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}