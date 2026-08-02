# Employee API v1

Base path:

```text
/api/v1
```

Content type:

```text
application/json
```

## Employee resource

Responses use camelCase property names. Create and update requests use snake_case property names.

```json
{
  "id": "0190f4d8-6ff0-7b30-a6ad-fecdd7cf6001",
  "organizationId": null,
  "branchId": null,
  "departmentId": null,
  "teamId": null,
  "employeeCode": "EMP-0001",
  "firstName": "Phakphum",
  "lastName": "Wiriyaphap",
  "nickname": null,
  "position": "Radiologic Technologist",
  "email": "phakphum@example.com",
  "phone": null,
  "isActive": true,
  "createdAt": "2026-08-01T03:30:00.000000Z",
  "updatedAt": "2026-08-01T03:30:00.000000Z"
}
```

## Endpoints

| Method | Path | Success |
| --- | --- | --- |
| GET | `/api/v1/employees` | `200 OK` |
| POST | `/api/v1/employees` | `201 Created` |
| GET | `/api/v1/employees/{employee}` | `200 OK` |
| PUT/PATCH | `/api/v1/employees/{employee}` | `200 OK` |
| DELETE | `/api/v1/employees/{employee}` | `204 No Content` |

`{employee}` is the employee UUID.

## List employees

```http
GET /api/v1/employees?page=1
```

Employees are ordered by `employee_code`. The endpoint uses Laravel pagination with 50 records per page.

A successful response contains `data`, `links`, and `meta`.

## Create employee

```http
POST /api/v1/employees
Content-Type: application/json
```

Required properties:

| Property | Validation |
| --- | --- |
| `employee_code` | required string, maximum 50 characters, unique |
| `first_name` | required string, maximum 100 characters |
| `last_name` | required string, maximum 100 characters |

Optional properties:

| Property | Validation |
| --- | --- |
| `organization_id` | nullable UUID |
| `branch_id` | nullable UUID |
| `department_id` | nullable UUID |
| `team_id` | nullable UUID |
| `nickname` | nullable string, maximum 100 characters |
| `position` | nullable string, maximum 150 characters |
| `email` | nullable email, maximum 255 characters, unique |
| `phone` | nullable string, maximum 30 characters |
| `is_active` | boolean |

Example:

```json
{
  "employee_code": "EMP-0001",
  "first_name": "Phakphum",
  "last_name": "Wiriyaphap",
  "position": "Radiologic Technologist",
  "email": "phakphum@example.com",
  "is_active": true
}
```

Invalid data returns `422 Unprocessable Content`.

## Update employee

```http
PATCH /api/v1/employees/{employee}
Content-Type: application/json
```

All fields are optional. Supplied fields must satisfy the same type, length, and uniqueness rules as create.

## Delete employee

Deleting an employee performs a soft delete and returns `204 No Content`.

## Errors

A missing employee returns `404 Not Found`.

Validation errors use Laravel's JSON error shape:

```json
{
  "message": "The employee code field is required. (and 2 more errors)",
  "errors": {
    "employee_code": [
      "The employee code field is required."
    ],
    "first_name": [
      "The first name field is required."
    ],
    "last_name": [
      "The last name field is required."
    ]
  }
}
```

## Security status

The current v1 Employee endpoints do not yet require authentication or authorization.