import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_badge.dart';

class EventsHistoryScreen extends StatefulWidget {
  const EventsHistoryScreen({super.key});

  @override
  State<EventsHistoryScreen> createState() => _EventsHistoryScreenState();
}

class _EventsHistoryScreenState extends State<EventsHistoryScreen> {
  static const String _baseMetrics = 'http://10.0.2.2:3004';
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Nivel 1', 'Nivel 2', 'Nivel 3'];
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.get(
        Uri.parse('$_baseMetrics/events'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _events = List<Map<String, dynamic>>.from(data['events'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() { _error = 'Error ${res.statusCode}'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _visibleEvents {
    if (_selectedFilter == 'Todos') return _events;
    final level = int.tryParse(_selectedFilter.split(' ').last) ?? 0;
    return _events.where((e) => e['severity_level'] == level).toList();
  }

  String _formatDuration(dynamic seconds) {
    if (seconds == null) return '--:--';
    final s = int.tryParse(seconds.toString()) ?? 0;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return ''; }
  }

  Color _levelColor(int level) {
    switch (level) {
      case 1: return AppColors.emergency1;
      case 2: return AppColors.emergency2;
      case 3: return AppColors.emergency3;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Historial • Dynavia', style: AppTypography.titleMedium),
        actions: [
          IconButton(
            onPressed: _loadEvents,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                filter,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 60, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Sin conexión al servidor', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadEvents, child: const Text('Reintentar')),
        ],
      ),
    );
    if (_visibleEvents.isEmpty) return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Sin eventos registrados', style: AppTypography.titleMedium),
        ],
      ),
    );
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _visibleEvents.length,
        itemBuilder: (context, index) => _buildEventCard(_visibleEvents[index]),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final level = event['severity_level'] ?? 1;
    final color = _levelColor(level);
    final duration = _formatDuration(event['total_duration_seconds']);
    final date = _formatDate(event['activated_at']);
    final status = event['status'] ?? 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(level: level, text: 'Nivel $level'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'completed'
                        ? AppColors.emergency3.withOpacity(0.1)
                        : AppColors.emergency2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'completed' ? 'Completado' : 'Activo',
                    style: AppTypography.labelSmall.copyWith(
                      color: status == 'completed' ? AppColors.emergency3 : AppColors.emergency2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(date, style: AppTypography.labelSmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.local_hospital_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ID: ${event['id'] ?? ''}',
                    style: AppTypography.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChip(Icons.timer_outlined, duration),
                _buildChip(Icons.directions_car_outlined,
                    '${event['vehicles_notified'] ?? 0} vehículos'),
                _buildChip(Icons.traffic_outlined,
                    '${event['semaphores_activated'] ?? 0} semáf.'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(text, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}