# Contributing to Shift Calendar Engine 3.0

## ก่อนเริ่มแก้ไข
1. ตรวจ repository ทั้งหมดและอ่านเอกสารใน `docs/`
2. ห้ามลบหรือแทนที่ Calendar Workflow เดิมโดยไม่ตรวจผลกระทบ
3. ห้ามสร้าง implementation ซ้ำกับของเดิม
4. ใช้ Roster เป็น Source of Truth

## กฎโครงสร้าง
- แยก Domain, Application, Infrastructure และ Presentation
- Business logic ห้ามอยู่ใน Flutter Widget
- ใช้ Repository Interface สำหรับ persistence และ external services
- UI ต้อง responsive บน Mobile, Tablet, Web และ Desktop
- รองรับ Demo Mode โดยไม่ใช้ข้อมูลตัวอย่างเป็น production data

## ก่อน Commit

```bash
dart format .
flutter analyze
flutter test
```

## Commit convention

```text
feat: เพิ่มความสามารถใหม่
fix: แก้ข้อผิดพลาด
docs: ปรับเอกสาร
refactor: ปรับโครงสร้างโดยไม่เปลี่ยนพฤติกรรม
test: เพิ่มหรือแก้การทดสอบ
chore: งานบำรุงรักษา
```

## Pull request checklist
- อธิบายปัญหาและผลลัพธ์ที่ต้องการ
- ระบุไฟล์หรือ feature ที่ได้รับผลกระทบ
- แนบผล format/analyze/test
- ระบุ migration หรือ compatibility impact
- เพิ่ม screenshot เมื่อแก้ UI
- เพิ่ม test เมื่อแก้ business logic
