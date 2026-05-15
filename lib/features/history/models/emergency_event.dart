import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

@immutable
class EmergencyEvent {
  final int level;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String destination;
  final String origin;
  final int notifiedVehicles;
  final int activatedTrafficLights;
  final Duration avgVehicleReaction;
  final Duration avgTrafficLightWait;
  final Duration avgLatency;
  final Duration baselineWithoutSystem;

  const EmergencyEvent({
    required this.level,
    required this.startedAt,
    required this.finishedAt,
    required this.destination,
    required this.origin,
    required this.notifiedVehicles,
    required this.activatedTrafficLights,
    required this.avgVehicleReaction,
    required this.avgTrafficLightWait,
    required this.avgLatency,
    required this.baselineWithoutSystem,
  });

  Duration get totalDuration => finishedAt.difference(startedAt);

  Color get levelColor => AppColors.getEmergencyColor(level);

  String get startedLabel => _formatDateTime(startedAt);

  String get finishedLabel => _formatDateTime(finishedAt);

  String get totalDurationLabel => _formatDuration(totalDuration);

  String get avgVehicleReactionLabel => _formatDuration(avgVehicleReaction);

  String get avgTrafficLightWaitLabel => _formatDuration(avgTrafficLightWait);

  String get avgLatencyLabel {
    final seconds = avgLatency.inMilliseconds / 1000.0;
    return '${seconds.toStringAsFixed(1)}s';
  }

  String get baselineWithoutSystemLabel =>
      _formatDuration(baselineWithoutSystem);

  String get savingsLabel {
    final diff = baselineWithoutSystem - totalDuration;
    final sign = diff.isNegative ? '+' : '-';
    return '$sign${_formatDuration(diff.abs())}';
  }

  static String _formatDateTime(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} • $hh:$mi';
  }

  static String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
