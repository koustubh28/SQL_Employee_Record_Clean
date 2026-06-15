# SQL Data Cleaning Project — Employee Records

A realistic end-to-end data cleaning exercise using a dirty HR dataset of ~1,160 rows.
---

## Project Files

| File | Purpose |
|------|---------|
| `employees_dirty.csv` | The raw, dirty dataset (load this first) |
Create the staging table and import the CSV |
| `02_exploration.sql` | Audit queries — understand the problems before fixing them |
---

## The Dataset — `employees` table

**1,160 rows** (including ~60 duplicate records) with these columns:

| Column | Expected Type | Expected Values |
|--------|--------------|-----------------|
| `employee_id` | INTEGER | Unique per employee |
| `first_name` | TEXT | Proper name |
| `last_name` | TEXT | Proper name |
| `department` | TEXT | Sales, Engineering, Marketing, HR, Finance |
| `gender` | TEXT | Male, Female |
| `age` | INTEGER | 18 – 80 |
| `hire_date` | TEXT / DATE | YYYY-MM-DD |
| `salary` | INTEGER | Positive number |
| `employment_status` | TEXT | Active, Inactive, On Leave |
| `email` | TEXT | valid format, lowercase |

---

## Dirty Data Issues

### 1. Duplicate Rows (~60 rows)
Some employee records were inserted twice with the same `employee_id`.

```
employee_id | first_name | ...
1359        | Lucas      | ...   ← appears twice
1359        | Lucas      | ...   ← exact duplicate
```

### 2. NULL / Missing Values
Multiple columns have NULL or empty-string values scattered throughout.

| Column | Approx. NULL count |
|--------|--------------------|
| salary | ~185 |
| hire_date | ~141 |
| age | ~139 |
| email | ~111 |
| first_name | ~42 |
| last_name | ~19 |

### 3. Inconsistent Categorical Values
Categorical columns have case variants, abbreviations, and typos:

**department**
```
Sales, sales, SALES, Saless, Sale
Engineering, engineering, Enginering, Eng
Marketing, marketing, Markting, Mktg
HR, hr, H.R., Human Resources
Finance, finance, Financee, Fin
```

**gender**
```
Male, male, MALE, M, m
Female, female, FEMALE, F, f
```

**employment_status**
```
Active, active, ACTIVE, Activ
Inactive, inactive, INACTIVE, In-active
On Leave, on leave, ON LEAVE, On_Leave, Leave
```

### 4. Wrong Data Types / Formats

**salary** — stored as TEXT with mixed formats:
```
86000          ← correct (as text)
$123,000       ← currency string
54000.0 USD    ← number + unit
-90000         ← negative value
```

**age** — stored as TEXT with bad values:
```
52             ← correct (as text)
54 years       ← number + unit
0              ← impossible
999            ← impossible
32.5           ← float instead of int
```

**hire_date** — multiple date formats:
```
2020-06-06     ← correct ISO format
06/20/2020     ← MM/DD/YYYY
20-06-2020     ← DD-MM-YYYY
6/20/2020      ← M/D/YYYY (no leading zeros)
```

**email** — malformed addresses:
```
lucas.taylor59@gmail.com    ← correct
lucas.taylor59gmail.com     ← missing @
   emma.white@yahoo.com     ← leading/trailing whitespace
EMMA.WHITE@YAHOO.COM        ← uppercase
```

---

## 5 SQL Skills Practiced

| # | Skill | Where Used |
|---|-------|-----------|
| 1 | `TRIM()` | Remove leading/trailing whitespace from every text column |
| 2 | `UPPER()` / `LOWER()` | Normalize case before comparisons; lowercase emails |
| 3 | `CASE WHEN` | Map dirty categoricals to canonical values; handle bad data |
| 4 | `CAST()` | Convert TEXT columns to INTEGER (salary, age, employee_id) |
| 5 | `ROW_NUMBER() OVER()` | Deduplicate: keep only the first row per `employee_id` |

---

## How to Run

### Step 1 — Explore the problems
Run `02_exploration.sql` query by query. Each query reveals a specific category of dirty data. 

### Step 2 — Clean the data
 We have created two tables:
- `employees_deduped` — duplicates removed
- `employees_clean` — fully cleaned, correctly typed

The verification queries at the bottom of the file confirm the data meets all quality rules.

---

## Expected Results After Cleaning

| Check | Before | After |
|-------|--------|-------|
| Total rows | ~1,160 | ~1,100 |
| Duplicate employee_ids | ~60 | 0 |
| Distinct `department` values | 25+ variants | 5 |
| Distinct `gender` values | 10+ variants | 2 |
| Distinct `employment_status` values | 13+ variants | 3 |
| Negative salaries | ~45 | 0 (set to NULL) |
| Non-ISO hire_dates | ~280 | 0 |
| Emails without `@` | ~100 | 0 (set to NULL) |
