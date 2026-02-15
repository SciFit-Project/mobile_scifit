import 'package:flutter/material.dart';
import 'package:mobile_scifit/services/step_services.dart';

class GoalCard extends StatefulWidget {
  const GoalCard({super.key});

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  final StepServices _stepServices = StepServices();
  List<DailyStepData> _dailySteps = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSteps();
  }

  Future<void> _fetchSteps() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final steps = await _stepServices.getStep();
      setState(() {
        _dailySteps = steps;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching steps: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Card - Modern Gradient Design
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[400]!, Colors.purple[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_walk,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Steps',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Last 7 Days Activity',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchSteps,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.deepPurple[400],
                            ),
                          )
                        : Icon(Icons.refresh_rounded, size: 22),
                    label: Text(
                      _isLoading ? 'Syncing...' : 'Refresh Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple[600],
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),

        // Daily Step Cards
        if (_isLoading)
          Container(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: Colors.deepPurple[400],
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading your activity...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else if (_dailySteps.isEmpty)
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 12),
                Text(
                  'No data available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap Refresh Data to sync your steps',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else
          ..._dailySteps.map((data) => DailyStepCard(data: data)).toList(),
      ],
    );
  }
}

class DailyStepCard extends StatelessWidget {
  final DailyStepData data;
  final int goalSteps = 10000;

  const DailyStepCard({super.key, required this.data});

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (data.totalSteps / goalSteps).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    final isGoalReached = progress >= 1.0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header with Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(data.date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _getRelativeDay(data.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getProgressGradient(progress),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getProgressColor(progress).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isGoalReached)
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      if (isGoalReached) SizedBox(width: 4),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Total Steps with Icon
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_walk,
                    color: Colors.deepPurple[600],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatNumber(data.totalSteps),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'of ${_formatNumber(goalSteps)} steps',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Progress Bar - Modern Design
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getProgressGradient(progress),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _getProgressColor(progress).withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Source Breakdown - Enhanced Design
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSourceInfo(
                      icon: Icons.phone_android_rounded,
                      label: 'Health Connect',
                      steps: data.healthConnectSteps,
                      color: Colors.blue[600]!,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.grey[300],
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildSourceInfo(
                      icon: Icons.watch_rounded,
                      label: 'Wearable',
                      steps: data.wearableSteps,
                      color: Colors.green[600]!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceInfo({
    required IconData icon,
    required String label,
    required int steps,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          _formatNumber(steps),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green[600]!;
    if (progress >= 0.7) return Colors.orange[600]!;
    return Colors.red[400]!;
  }

  List<Color> _getProgressGradient(double progress) {
    if (progress >= 1.0) {
      return [Colors.green[400]!, Colors.green[600]!];
    }
    if (progress >= 0.7) {
      return [Colors.orange[400]!, Colors.orange[600]!];
    }
    return [Colors.red[300]!, Colors.red[500]!];
  }

  String _getRelativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDay).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '$difference days ago';
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}