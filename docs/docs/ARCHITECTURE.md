# Shift Calendar Engine 3.0 — Architecture

## เป้าหมาย

Shift Calendar Engine (SCE) 3.0 เป็นแอป Flutter แบบข้ามแพลตฟอร์มสำหรับ Web, Android, iOS, Windows, macOS และ Linux เพื่อบริหารตารางเวร บุคลากร การแลกเวร เงินเวร รายงาน การพิมพ์ A4 และการซิงก์เวรของผู้ใช้กับ Google Calendar

## หลักการสำคัญ

- Roster หรือ “ตารางเวร” เป็น Source of Truth
- แยก Domain, Application, Infrastructure และ Presentation ให้ชัดเจน
- Business logic ห้ามอยู่ใน Widget
- การเก็บข้อมูลต้องผ่าน Repository Interface
- การเปลี่ยนแปลงจำนวนมากต้องมี Preview และ Confirmation
- ข้อมูลสำคัญต้องมี Audit Log
- Google Calendar ต้องรับเฉพาะเวรของผู้ใช้ ไม่ส่งข้อมูลบุคคลอื่น
- ระบบต้องกำหนดชื่อเวร เวลา สี อัตราเงิน กฎ วันหยุด และปฏิทินได้จาก Settings

## Layers

### Domain
ประกอบด้วย Entity, Value Object, Aggregate, Rule และ Domain Service เช่น Schedule, Shift, Employee, ShiftTemplate, ExchangeRequest และ AllowanceRule

### Application
ประกอบด้วย Use Case และ Workflow เช่น CreateShift, PreviewRosterChanges, ApproveExchange, CalculatePayroll, ImportSheet และ SyncCalendar

### Infrastructure
ประกอบด้วย Local persistence, Google Sheets, Google Calendar, PDF/print, file import/export, notification และ backup adapters

### Presentation
ประกอบด้วย responsive Flutter UI สำหรับ Dashboard, Roster, Employees, Shift Exchange, Reports และ Settings

## Feature structure

```text
lib/
├── app/
├── core/
│   ├── config/
│   ├── errors/
│   ├── localization/
│   ├── navigation/
│   ├── permissions/
│   ├── storage/
│   ├── theme/
│   └── utils/
├── features/
│   ├── dashboard/
│   ├── roster/
│   │   ├── builder/
│   │   ├── viewer/
│   │   ├── editor/
│   │   ├── printing/
│   │   └── import_export/
│   ├── employees/
│   ├── shift_exchange/
│   ├── payroll/
│   ├── allowance_rules/
│   ├── reports/
│   ├── profiles/
│   ├── shift_templates/
│   ├── rules/
│   ├── policies/
│   ├── conflicts/
│   ├── sheets/
│   ├── calendar_sync/
│   ├── workflow/
│   ├── notifications/
│   ├── history/
│   ├── backup/
│   └── settings/
├── models/
├── services/
└── main.dart
```

## Data flow

```text
UI → Use Case → Repository Interface → Adapter/Persistence
                      ↓
              Rule/Conflict/Policy Engine
                      ↓
                Preview + Audit Log
```

## Quality gates

ทุก Phase ต้องผ่าน:

```bash
dart format .
flutter analyze
flutter test
```

ห้ามปิด lint เพื่อซ่อนปัญหา และต้องเพิ่ม test สำหรับ logic สำคัญ
