import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ShiftMetricsScreen extends StatefulWidget {
  const ShiftMetricsScreen({super.key});

  @override
  State<ShiftMetricsScreen> createState() => _ShiftMetricsScreenState();
}

class _ShiftMetricsScreenState extends State<ShiftMetricsScreen>
    with SingleTickerProviderStateMixin {
  static const String _baseMetrics = 'http://192.168.56.101:3004';

  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isLoading = true;
  String? _error;

  // Datos reales de la BD
  int _totalEvents = 0;
  String _avgDuration = '--:--';
  String _savedTime = '--:--';
  double _savingPercent = 0;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _loadMetrics();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.get(
        Uri.parse('$_baseMetrics/metrics/shift'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _totalEvents = data['total_events'] ?? 0;
          _avgDuration = _formatSeconds(data['avg_duration_seconds']);
          _savedTime = _formatSeconds(data['avg_saved_seconds']);
          _savingPercent = (data['saving_percent'] ?? 0).toDouble();
          _events = List<Map<String, dynamic>>.from(data['events'] ?? []);
          _isLoading = false;
        });
        _controller.forward();
      } else {
        setState(() { _error = 'Error ${res.statusCode}'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  String _formatSeconds(dynamic raw) {
    if (raw == null) return '--:--';
    final s = int.tryParse(raw.toString()) ?? 0;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  // Construye los puntos reales del gráfico
  List<FlSpot> get _realSpots {
    return List.generate(_events.length, (i) {
      final secs = _events[i]['total_duration_seconds'];
      final mins = (int.tryParse(secs.toString()) ?? 0) / 60.0;
      return FlSpot(i.toDouble(), double.parse(mins.toStringAsFixed(1)));
    });
  }

  // Línea de referencia "sin sistema" — 30% más lento que cada punto real
  List<FlSpot> get _referenceSpots {
    return List.generate(_events.length, (i) {
      final secs = _events[i]['total_duration_seconds'];
      final mins = (int.tryParse(secs.toString()) ?? 0) / 60.0;
      return FlSpot(i.toDouble(), double.parse((mins * 1.30).toStringAsFixed(1)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Métricas del Turno', style: AppTypography.titleMedium),
        actions: [
          IconButton(
            onPressed: _loadMetrics,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadMetrics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShiftSummary(),
                        const SizedBox(height: 24),
                        _events.length >= 2
                            ? _buildChart()
                            : _buildNoChartMessage(),
                        const SizedBox(height: 24),
                        _buildStatsChips(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 60, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Sin conexión al servidor', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadMetrics, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildShiftSummary() {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(_animation),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Turno actual',
                            style: AppTypography.subtitleLarge
                                .copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Datos en tiempo real • BD',
                            style: AppTypography.bodySmall
                                .copyWith(color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('$_totalEvents', 'Eventos'),
                  Container(width: 1, height: 40,
                      color: Colors.white.withOpacity(0.3)),
                  _buildSummaryItem(_avgDuration, 'Promedio'),
                  Container(width: 1, height: 40,
                      color: Colors.white.withOpacity(0.3)),
                  _buildSummaryItem(_savedTime, 'Ahorro'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.titleLarge.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTypography.labelSmall
                .copyWith(color: Colors.white.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildChart() {
    final spots = _realSpots;
    final refSpots = _referenceSpots;
    final maxY = refSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tiempo de trayecto por evento',
              style: AppTypography.subtitleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem(AppColors.primary, 'Con Dynavia'),
              const SizedBox(width: 16),
              _buildLegendItem(AppColors.grey, 'Sin sistema'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.lightGrey, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}m',
                        style: AppTypography.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        'E${value.toInt() + 1}',
                        style: AppTypography.labelSmall,
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: refSpots,
                    isCurved: true,
                    color: AppColors.grey,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChartMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          'Se necesitan al menos 2 eventos completados para mostrar la gráfica',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12, height: 3,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }

  Widget _buildStatsChips() {
    final percentText = _savingPercent > 0
        ? '-${_savingPercent.toStringAsFixed(0)}% tiempo'
        : 'Sin datos de ahorro';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatChip(Icons.analytics_rounded, '$_totalEvents eventos hoy'),
        _buildStatChip(Icons.timer_outlined, 'Prom: $_avgDuration'),
        _buildStatChip(Icons.trending_down_rounded, percentText),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(text,
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
