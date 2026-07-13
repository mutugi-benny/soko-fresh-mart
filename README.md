# 🛒 Soko Fresh Mart — PostgreSQL Data Management & EDA Project

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-blue.svg)](https://www.postgresql.org/)
[![Use this template](https://img.shields.io/badge/Use%20this-Template-brightgreen)](../../generate)

A complete, realistic **data cleaning + exploratory data analysis (EDA)** project built entirely in PostgreSQL. Designed to simulate a real business problem: a 12-branch supermarket chain with messy transactional data that needs to be validated before leadership can trust any metric built on top of it.

**Use this repo as-is to practice SQL, or fork it as a template for your own dataset/business case.**

---

## 📸 Preview

> Add 2–3 screenshots here once you've run the project locally — see [`docs/SCREENSHOTS_GUIDE.md`](docs/SCREENSHOTS_GUIDE.md) for exactly how to generate clean, presentable ones from pgAdmin or psql.

```
docs/screenshots/
├── 01_schema_erd.png
└── 02_data_quality_report.png
```

---

## 🧩 What's Inside

| Folder | Contents |
|---|---|
| `data/` | 5 CSVs (~25,200 rows) — realistic, intentionally messy retail data |
| `sql/` | `01_schema.sql` (DDL) and `02_load_data.sql` (data loading via `\copy`) |
| `docs/` | Full project brief, 32 guided questions, self-grading rubric, screenshot guide |

**Tables:** `stores` · `products` · `customers` · `orders` · `order_items` — normalized to 3NF, with realistic relationships and deliberately seeded data quality issues (duplicates, missing values, referential integrity gaps, outliers).

---

## 🚀 Quick Start

```bash
git clone https://github.com/mutugi-benny/soko-fresh-mart.git
cd soko-fresh-mart

createdb soko_fresh_mart
psql -U postgres -d soko_fresh_mart -f sql/01_schema.sql
cd sql
psql -U postgres -d soko_fresh_mart -f 02_load_data.sql
```

Then open [`docs/PROJECT_BRIEF.md`](docs/PROJECT_BRIEF.md) and start working through the 32 questions.

Full troubleshooting (PATH setup, common `\copy` errors, Windows/Git Bash specifics) is in [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md).

---

## 🎯 Why This Project Exists

Most beginner SQL portfolio projects hand you clean data and ask you to write a few `SELECT` statements. This one doesn't. It's built around a real business problem — **inconsistent branch performance, unclear loyalty-program impact, and untrustworthy underlying data** — and every question maps to what a working data engineer or analyst actually does before a single dashboard goes live:

- ✅ Joins, aggregation, and window functions (ranking, running totals, LAG/LEAD)
- ✅ Data cleaning (NULL handling, string standardization, type casting)
- ✅ Data validation (referential integrity, duplicate detection, outlier detection)
- ✅ Exploratory analysis (distributions, correlations, chart-ready query design)

---

## 🔁 Using This as a Template

Want to adapt this for your own business idea, dataset, or teaching material? Here's how:

1. Click **"Use this template"** at the top of this repo (or fork it).
2. Swap out the CSVs in `data/` for your own dataset — keep the same column structure, or update `sql/01_schema.sql` to match your new schema.
3. Rewrite `docs/PROJECT_BRIEF.md` with your own business scenario and question set — the structure (business context → data dictionary → guided questions → self-grading rubric) works for almost any domain.
4. Re-run the Quick Start steps above to confirm your new version loads cleanly.

This structure works equally well for: e-commerce platforms, fintech/mobile money analytics, HR/employee databases, logistics and delivery tracking, or any relational business dataset.

---

## 🛠️ Tech Stack

- **PostgreSQL 18** (works on 14+, no version-specific features used)
- Plain SQL only — no ORMs, no external dependencies
- Data generated synthetically with realistic messiness (see `docs/PROJECT_BRIEF.md` for the full list of seeded data quality issues)

---

## 📄 License

MIT — free to use, modify, and redistribute. See [`LICENSE`](LICENSE) for details.

---

## 👤 Author

**Benny Mutugi**
BSc Computer Science, JKUAT
[GitHub](https://github.com/mutugi-benny) · Open to data engineering & analytics opportunities

If this helped you practice SQL or kickstarted your own project, a ⭐ on the repo is appreciated!
