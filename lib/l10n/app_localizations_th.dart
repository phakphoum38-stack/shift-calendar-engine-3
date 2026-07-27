// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Shift Calendar Engine';

  @override
  String get dashboard => 'ภาพรวม';

  @override
  String get roster => 'ตารางเวร';

  @override
  String get employees => 'บุคลากร';

  @override
  String get exchange => 'แลกเวร';

  @override
  String get reports => 'รายงาน';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get today => 'วันนี้';

  @override
  String get tomorrow => 'พรุ่งนี้';

  @override
  String get nextShift => 'เวรถัดไป';

  @override
  String get monthlyAssignments => 'จำนวนเวรเดือนนี้';

  @override
  String get estimatedIncome => 'รายได้โดยประมาณ';

  @override
  String get pendingRequests => 'คำขอที่รอดำเนินการ';

  @override
  String get calendarStatus => 'สถานะปฏิทิน';

  @override
  String get notConnected => 'ยังไม่เชื่อมต่อ';

  @override
  String get noSchedule => 'ยังไม่มีข้อมูลตารางเวร';

  @override
  String get noScheduleDescription => 'นำเข้าหรือสร้างตารางเวรเพื่อเริ่มใช้งาน';

  @override
  String get createRoster => 'สร้างตารางเวร';

  @override
  String get importRoster => 'นำเข้าตารางเวร';

  @override
  String get previousMonth => 'เดือนก่อนหน้า';

  @override
  String get nextMonth => 'เดือนถัดไป';

  @override
  String get monthOverview => 'ภาพรวมรายเดือน';

  @override
  String get employeeDirectory => 'รายชื่อบุคลากร';

  @override
  String get employeeDirectoryDescription => 'จัดการบุคลากรที่ใช้ในตารางเวร';

  @override
  String get noEmployees => 'ยังไม่มีบุคลากร';

  @override
  String get exchangeRequests => 'คำขอแลกเวร';

  @override
  String get exchangeDescription =>
      'คำขอ การอนุมัติ และประวัติจะอ้างอิงตารางเวรหลัก';

  @override
  String get noRequests => 'ยังไม่มีคำขอแลกเวร';

  @override
  String get reportCenter => 'ศูนย์รายงาน';

  @override
  String get reportDescription => 'รายงานตารางเวรสำหรับพิมพ์และส่งออก';

  @override
  String get noReports => 'ยังไม่มีข้อมูลรายงาน';

  @override
  String get workspaceSettings => 'การตั้งค่า Workspace';

  @override
  String get language => 'ภาษา';

  @override
  String get followSystem => 'ตามระบบ';

  @override
  String get english => 'อังกฤษ';

  @override
  String get thai => 'ไทย';

  @override
  String get theme => 'ธีม';

  @override
  String get systemTheme => 'ตามระบบ';

  @override
  String get lightTheme => 'สว่าง';

  @override
  String get darkTheme => 'มืด';

  @override
  String get demoMode => 'โหมดสาธิต';

  @override
  String get demoModeDescription =>
      'ใช้ข้อมูลตัวอย่างที่แน่นอนโดยไม่เชื่อมต่อบัญชีภายนอก';

  @override
  String get phaseStatus => 'รากฐาน SCE 3.0';

  @override
  String get phaseStatusDescription =>
      'เปิดใช้ตารางเวรหลัก การประกอบ dependency แบบชัดเจน navigation responsive ระบบภาษา และการทดสอบแล้ว';
}
