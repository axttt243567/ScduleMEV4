# Scheduling Logic Documentation

**Last Updated:** 2026-01-27
**Module:** `features/schedules`

This document details the business logic, data models, and UI behaviors behind the Schedule Management system in ScduleMEv4.

---

## 1. Data Model: `ScheduleItem`
The core model is defined in `lib/features/schedules/models/schedule_model.dart`. It represents any time-bound or task-bound entry in the user's life.

### Core Properties
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique identifier (UUID or similar). |
| `title` | `String` | Display name of the schedule. |
| `type` | `ScheduleType` | Enum: `classSession`, `event`, `workshop`, `personal`. Determines color coding and icon logic. |
| `notes` | `String?` | Optional rich text notes. |

### Tagging & Hierarchy (New Feature)
We support a 2-level hierarchy for categorization.
1.  **Group Tag (`groupTag`)**: A "Main Category" that groups related items (e.g., `#Health`, `#University`). This is displayed prominently on the UI.
2.  **Sub-Tags (`tags`)**: Specific descriptors (e.g., `#Yoga`, `#Lecture`).

**Logic:**
- Tags are stored as a `List<String>`.
- **Auto-Prefixing:** To enforce hierarchy in search and filtering, when a sub-tag is added while a Group is selected, it is automatically prefixed.
    - *Example:* If Group is `#Health` and user adds `Yoga`, the stored tag becomes `#Health_Yoga`.

---

## 2. Recurrence Types (`ScheduleRepeatType`)
The system supports three distinct modes of scheduling, handled by the `repeatType` enum.

### A. One-Time (`ScheduleRepeatType.oneTime`)
*Use Case:* One-off events (e.g., "Hackathon", "Dentist Appointment").
*   **Required Fields:**
    *   `specificStart`: `DateTime` (Date & Time)
    *   `specificEnd`: `DateTime` (Date & Time)
*   **Validation:** Start must be before End.

### B. Fixed Days (`ScheduleRepeatType.fixedDays`)
*Use Case:* Rigid routines (e.g., "Math Class: Mon, Wed at 10 AM").
*   **Required Fields:**
    *   `weekDays`: `List<int>` (1=Monday, 7=Sunday).
    *   `startTime`: `TimeOfDay`.
    *   `duration`: `Duration`.
*   **Logic:** The system considers this active on any date where `date.weekday` is present in `weekDays`.

### C. Flexible (`ScheduleRepeatType.flexible`)
*Use Case:* Habit goals (e.g., "Gym 3x a week").
*   **Required Fields:**
    *   `targetOccurrences`: `int` (e.g., 3).
    *   `period`: `Duration` (Default: 7 days).
*   **Logic:** These do not appear on specific time slots in a calendar day view unless explicitly "logged" (future feature). They appear in "To-Do" lists until the quota is met.

---

## 3. UI logic (`SchedulesPage`)

### Overview Tab
- **Visualization:** Timeline vs Goals.
- **Filtering:**
    - **Search Bar:** Filters by `title` or `tags`.
    - **Chips:** Quick toggles for `Recurring`, `Flexible`, `Events`.

### Calendar Tab
- **Custom Implementation:** logic manually calculates active days.
- **Marker Logic:**
    - Iterates through `_allSchedules`.
    - If `oneTime`: Checks `isSameDay`.
    - If `fixedDays`: Checks if `day.weekday` is in `weekDays`.
    - If `flexible`: Currently typically ignored in *strict* calendar grids as they aren't date-specific, but can be shown as "All Day" tasks.

### Creation Logic (Bottom Sheet)
*   **Dynamic Form:** The UI adapts based on `repeatType` selection.
    *   *One-Time* -> Shows Date Picker & Time Range.
    *   *Fixed* -> Shows Weekday Selector (Mon-Sun) & Start Time + Duration.
    *   *Flexible* -> Shows "+ / -" counter for occurrences.
*   **Tag Input:**
    *   User types tag -> logic checks for `#` -> logic prepends `groupTag` if present.

---
## 4. Junior Dev Notes / Common Pitfalls
1.  **TimeOfDay Imports:** Watch out for `TimeOfDay` coming from `material.dart`. Do not mix with other time libraries.
2.  **Date Comparison:** Always use `DateUtils.isSameDay(a, b)` instead of `a == b`, because `DateTime` includes microseconds.
3.  **Hierarchy Naming:** When processing tags for analytics, remember to split by `_` if you need the raw sub-tag name.
