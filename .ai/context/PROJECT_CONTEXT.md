# AI Project Context

Project: Shift Calendar Engine 3.0

ระบบ Flutter ข้ามแพลตฟอร์มสำหรับบริหารตารางเวร โดย Roster เป็น Source of Truth รองรับบุคลากร การแลกเวร กฎและความขัดแย้ง เงินเวร รายงาน A4 Google Sheets และ Google Calendar

เอกสารหลัก:
- `docs/Shift_Calendar_Engine_3.0_UI_and_System_Spec_Complete_TH.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`

ข้อห้ามสำคัญ:
- ห้ามลบ Calendar Workflow เดิม
- ห้าม duplicate implementation
- ห้ามใส่ business logic ใน Widget
- ห้ามส่งข้อมูลของบุคคลอื่นไป Google Calendar
- ห้ามใช้ demo data เป็น production data
