# Shift Calendar Engine 3.0 — Data Model

## Core entities

### Workspace
- id
- name
- locale
- timezone
- hospitalProfileId
- settings

### Employee
- id
- workspaceId
- displayName
- role
- department
- contact
- calendarIdentity
- personalAllowanceOverrides
- active

### ShiftTemplate
- id
- workspaceId
- code
- name
- startTime
- endTime
- crossesMidnight
- color
- defaultAllowance
- rules

### Shift
- id
- scheduleId
- templateId (optional for Free Style)
- date
- startDateTime
- endDateTime
- department
- location
- assigneeIds
- status
- approvalStatus
- syncStatus
- notes
- overrideAllowance

### Schedule
- id
- workspaceId
- period
- shifts
- revision
- updatedAt

### ExchangeRequest
- id
- shiftId
- requesterId
- targetEmployeeId
- status
- approvalHistory

### AuditLog
- id
- workspaceId
- actorId
- action
- entityType
- entityId
- before
- after
- timestamp

### SyncRun
- id
- userId
- period
- plannedChanges
- resultCounts
- errors
- startedAt
- finishedAt

## Constraints
- Schedule เป็น canonical aggregate และ source of truth
- Shift แบบ Free Style ไม่จำเป็นต้องมี templateId
- เวรข้ามวันต้องเก็บ start/end แบบ datetime ไม่ใช่เฉพาะเวลา
- การแก้ไขสำคัญต้องเพิ่ม AuditLog
- ข้อมูล integration secrets ต้องเข้ารหัส
- Backup ต้องเก็บ version และ restore history
