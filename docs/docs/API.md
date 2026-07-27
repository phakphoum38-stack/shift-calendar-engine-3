# Shift Calendar Engine 3.0 — API Contracts

เอกสารนี้กำหนดขอบเขต API ภายในและ integration contracts ระดับแนวคิด โดยยังไม่บังคับรูปแบบ HTTP endpoint จนกว่าจะเลือก backend

## Repository interfaces

### ScheduleRepository
- loadSchedule(workspaceId, period)
- saveSchedule(schedule)
- previewChanges(changeSet)
- applyChanges(changeSet)
- watchSchedule(workspaceId)

### EmployeeRepository
- listEmployees(workspaceId)
- getEmployee(employeeId)
- saveEmployee(employee)
- archiveEmployee(employeeId)

### ShiftTemplateRepository
- listTemplates(workspaceId)
- saveTemplate(template)
- archiveTemplate(templateId)

### ExchangeRepository
- createRequest(request)
- approveRequest(requestId, approverId)
- rejectRequest(requestId, approverId, reason)
- listHistory(workspaceId)

### CalendarSyncRepository
- previewSync(userId, period)
- executeSync(syncPlan)
- retryFailed(syncRunId)
- readSyncHistory(userId)

### SheetsImportRepository
- listSources(accountId)
- previewImport(source, mapping)
- diffImport(preview)
- applyImport(importPlan)

## Contract rules
- ทุก operation ที่แก้ข้อมูลจำนวนมากต้องแยก preview และ apply
- Delete สำคัญต้องมี confirmation token หรือ explicit confirmation
- Integration ต้องส่งผลลัพธ์แบบเพิ่ม/แก้ไข/ลบ/ข้าม/ผิดพลาด
- Error ต้องมีรหัสที่แปลผลได้และไม่เปิดเผยข้อมูลลับ
- Calendar sync ต้อง filter เฉพาะเวรของผู้ใช้
