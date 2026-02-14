import 'package:flutter/material.dart';
import 'package:health/health.dart';

class SciFitPremiumUI extends StatefulWidget {
  const SciFitPremiumUI({super.key});

  @override
  State<SciFitPremiumUI> createState() => _SciFitPremiumUIState();
}

class _SciFitPremiumUIState extends State<SciFitPremiumUI> {
  final Health _health = Health();
  bool _isSyncing = false;
  int _steps = 0;
  String _status = "Ready to Sync";
  List<HealthDataPoint> _dataHistory = [];

  @override
  void initState() {
    super.initState();
    _health.configure();
  }

  // --- Logic: สะอาดและปลอดภัย ---
  Future<void> _syncData() async {
    setState(() => _isSyncing = true);
    try {
      final types = [HealthDataType.STEPS, HealthDataType.HEART_RATE];
      if (await _health.requestAuthorization(types)) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);

        List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: types,
        );

        // หาค่า Max Steps (แก้ปัญหา Source ซ้ำ)
        int maxSteps = 0;
        final stepPoints = data.where((e) => e.type == HealthDataType.STEPS);
        if (stepPoints.isNotEmpty) {
          maxSteps = stepPoints
              .map((e) => (e.value as NumericHealthValue).numericValue.toInt())
              .reduce((a, b) => a > b ? a : b);
        }

        setState(() {
          _steps = maxSteps;
          _dataHistory = _health.removeDuplicates(data).reversed.toList();
          _status =
              "Updated at ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
        });
      }
    } catch (e) {
      setState(() => _status = "Sync Failed");
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildMainCard()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ),
          ),
          _buildActivityList(),
        ],
      ),
    );
  }

  // AppBar แบบ Modern
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF8F9FD),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        title: const Text(
          "My Health",
          style: TextStyle(
            color: Color(0xFF1D1D1F),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _isSyncing ? null : _syncData,
          icon: Icon(
            _isSyncing ? Icons.hourglass_empty : Icons.refresh,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  // การ์ดสรุปก้าวเดิน (Hero Card)
  Widget _buildMainCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.directions_walk, color: Colors.white, size: 30),
              Text(
                _status,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Steps Today",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            "$_steps",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _steps / 10000,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Goal: 10,000 steps",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // รายการกิจกรรมล่าสุด
  Widget _buildActivityList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = _dataHistory[index];
          final isStep = item.type == HealthDataType.STEPS;
          final value = (item.value as NumericHealthValue).numericValue.toInt();

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isStep ? Colors.orange : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isStep ? Icons.directions_run : Icons.favorite,
                  color: isStep ? Colors.orange : Colors.red,
                ),
              ),
              title: Text(
                "$value ${item.unitString}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                item.sourceName.split('.').last,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                "${item.dateFrom.hour}:${item.dateFrom.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }, childCount: _dataHistory.length),
      ),
    );
  }
}
