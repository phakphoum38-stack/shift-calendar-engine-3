# User Guide

This guide describes capabilities currently implemented in Shift Calendar
Engine 3.0. Planned features are listed separately in the roadmap.

## Navigation

Phones use bottom navigation. Wider tablet, web, and desktop layouts use a
navigation rail. The six destinations are Dashboard, Roster, Employees,
Exchange, Reports, and Settings.

## Choose language and appearance

Open **Settings**:

1. Select Follow system, English, or Thai.
2. Select System, Light, or Dark theme.
3. Changes apply immediately and persist on the current device.

## Try Demo mode

Enable **Demo mode** in Settings to load deterministic sample data without an
external account. Disable it to return to the locally persisted canonical
schedule.

## Manage employees

Open **Employees** to:

1. Search the employee directory.
2. Add an employee and department details.
3. Edit an employee.
4. Deactivate an employee without deleting historical assignment identity.

Employee codes must be unique.

## Configure shift templates

Open **Settings**, then **Shift templates**. Templates define the reusable
shift code, name, start/end time, working hours, rate, and active status.
Morning, evening, and night defaults are seeded only when no saved templates
exist. Shift codes must be unique.

## Build a roster manually

Open **Roster**, then the manual roster editor:

1. Select a date.
2. Select an active employee.
3. Select an active shift template.
4. Optionally enter location and remark.
5. Preview the change.
6. Confirm the assignment.
7. Use Save to persist the canonical schedule.

Deleting an assignment also requires preview and confirmation. The editor
updates the canonical `Schedule` first; it does not maintain a second roster
model.

## View a monthly roster

The Roster screen displays one month at a time. Use the previous and next
controls to navigate. Days show their canonical assignments and preserve
multiple employees or shifts on the same date.

## Create an A4 schedule report

Open **Reports**:

1. Select a month.
2. Optionally filter one department.
3. Select **Preview report**.
4. Review the A4 landscape PDF.
5. Select **Print** or **Share PDF**.

The report includes:

- chronological calendar dates
- deterministic employee ordering by department, name, and ID
- textual shift codes and a legend
- multiple shift codes when one employee has multiple assignments in a day
- weekends and holidays that remain visible without relying only on color
- employee and assignment totals
- shift totals, notes, page numbers, and blank signature areas

The generated filename follows `shift_schedule_YYYY_MM.pdf`. Employee,
department, location, and shift values are user data and are not translated.

## Data safety

- The canonical schedule is the scheduling source of truth.
- Explicit saves use staged local storage so a failed write does not replace
  the last valid payload.
- Do not place real credentials or confidential roster exports in the source
  repository.
- Backup/restore, exchange approval, payroll, import, and calendar sync are
  future phases in this clean repository and should not be treated as active.
