import 'package:flutter/material.dart';
import 'package:health/health.dart';

class SleepDataTest extends StatefulWidget {
  @override
  _SleepDataTestState createState() => _SleepDataTestState();
}

class _SleepDataTestState extends State<SleepDataTest> {
  final Health health = Health();

  Future<void> testSleepData3Days() async {
    print('========== ทดสอบดึงข้อมูลการนอน 3 วันย้อนหลัง ==========');

    // 1. ตรวจสอบว่ามี Health Connect หรือไม่
    print('\n1. ตรวจสอบ Health Connect...');
    bool available = await health.isDataTypeAvailable(
      HealthDataType.SLEEP_SESSION,
    );
    print('   Health Connect Available: $available');

    if (!available) {
      print('   ❌ ไม่พบ Health Connect กรุณาติดตั้ง');
      return;
    }

    // 2. ขอสิทธิ์
    print('\n2. ขอสิทธิ์เข้าถึงข้อมูล...');
    final types = [HealthDataType.SLEEP_SESSION];

    bool? hasPermissions = await health.hasPermissions(
      types,
      permissions: [HealthDataAccess.READ],
    );

    if (hasPermissions != true) {
      hasPermissions = await health.requestAuthorization(
        types,
        permissions: [HealthDataAccess.READ],
      );
    }

    if (hasPermissions != true) {
      print('   ❌ ไม่ได้รับสิทธิ์');
      return;
    }

    print('   ✅ ได้รับสิทธิ์แล้ว');

    // 3. ดึงข้อมูล 3 วันย้อนหลัง แยกวัน
    print('\n3. ดึงข้อมูลการนอน 3 วันย้อนหลัง:');
    print('=' * 70);

    final now = DateTime.now();

    for (int day = 1; day <= 3; day++) {
      final targetDate = now.subtract(Duration(days: day));

      // กำหนดช่วงเวลา: จาก 18:00 ของวันนั้น ถึง 14:00 ของวันถัดไป
      final startTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        18,
        0,
      );
      final endTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day + 1,
        14,
        0,
      );

      print(
        '\n📅 วันที่: ${targetDate.day}/${targetDate.month}/${targetDate.year}',
      );
      print(
        '   ช่วงเวลาค้นหา: ${_formatDateTime(startTime)} ถึง ${_formatDateTime(endTime)}',
      );
      print('   ' + '-' * 60);

      try {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_SESSION],
          startTime: startTime,
          endTime: endTime,
        );

        if (healthData.isEmpty) {
          print('   ⚠️ ไม่มีข้อมูลการนอนในวันนี้');
          continue;
        }

        print('   พบข้อมูล ${healthData.length} session:');

        // แสดงทุก session
        for (int i = 0; i < healthData.length; i++) {
          var point = healthData[i];
          final duration = point.dateTo.difference(point.dateFrom);

          print('      Session ${i + 1}: ${point.sourceName}');
          print(
            '         เวลา: ${_formatTime(point.dateFrom)} - ${_formatTime(point.dateTo)}',
          );
          print(
            '         ระยะเวลา: ${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
          );
        }

        // เลือก session ที่ยาวที่สุด
        HealthDataPoint? longestSession;
        Duration longestDuration = Duration.zero;

        for (var point in healthData) {
          final duration = point.dateTo.difference(point.dateFrom);
          if (duration > longestDuration) {
            longestDuration = duration;
            longestSession = point;
          }
        }

        if (longestSession != null) {
          print('\n   ✅ เลือก Session ที่ยาวที่สุด:');
          print('      🛏️ เข้านอน: ${_formatTime(longestSession.dateFrom)}');
          print('      ⏰ ตื่นนอน: ${_formatTime(longestSession.dateTo)}');
          print(
            '      💤 นอนทั้งหมด: ${longestDuration.inHours} ชม ${longestDuration.inMinutes.remainder(60)} นาที',
          );
          print('      📱 แหล่งที่มา: ${longestSession.sourceName}');
        }
      } catch (e) {
        print('   ❌ เกิดข้อผิดพลาด: $e');
      }
    }

    print('\n' + '=' * 70);
    print('========== เสร็จสิ้น ==========\n');
  }

  // ฟังก์ชันช่วยแสดงวันที่และเวลา
  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ฟังก์ชันช่วยแสดงเฉพาะเวลา
  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ทดสอบดึงข้อมูลการนอน 3 วัน'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nightlight_round, size: 100, color: Colors.indigo),
            SizedBox(height: 20),
            Text(
              'ดึงข้อมูลการนอน\n3 วันย้อนหลัง',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: testSleepData3Days,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.indigo,
              ),
              child: Text(
                'ทดสอบ 3 วันย้อนหลัง\n(ดูผลที่ Console)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '💡 จะแสดงข้อมูลแยกตามวัน\nพร้อมเลือก session ที่ยาวที่สุดของแต่ละวัน',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
