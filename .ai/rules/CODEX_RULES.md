# Codex and AI Rules

1. ตรวจ repository ทั้งหมดก่อนแก้ไข
2. อ่าน specification, architecture และ roadmap ก่อนเริ่มงาน
3. รักษาความเข้ากันได้กับโครงสร้างเดิม
4. ใช้ Roster เป็น Source of Truth
5. แยก Domain, Application, Infrastructure และ Presentation
6. ใช้ Repository Interface และ dependency injection
7. ห้าม business logic อยู่ใน Widget
8. ทุก feature ต้องมี model และ application/service/use-case layer ที่เหมาะสม
9. ต้องมี preview ก่อน bulk changes และ confirmation ก่อน delete
10. เพิ่ม audit log สำหรับข้อมูลสำคัญ
11. เพิ่ม test สำหรับ logic สำคัญ
12. รัน `dart format .`, `flutter analyze`, `flutter test`
13. ห้ามปิด lint เพื่อซ่อนปัญหา
14. Google Calendar ต้องซิงก์เฉพาะเวรของผู้ใช้
15. สรุปไฟล์ที่แก้ เหตุผล และผล test ทุกครั้ง
