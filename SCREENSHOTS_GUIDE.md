# Generating Screenshots for Your README

Screenshots make a GitHub project instantly more credible — they let a visitor "see" the result without cloning and running anything. Here's how to get 2–3 clean ones in under 15 minutes.

## Recommended screenshots (pick 2–3, not more)

1. **Schema/ERD diagram** — shows your database design at a glance
2. **A query result** — e.g., revenue by store, or the data quality report
3. **(Optional) A chart** — if you build any visualization from the EDA questions

---

## Option A — Schema diagram (pgAdmin, easiest)

1. Open **pgAdmin** → connect to your `soko_fresh_mart` database.
2. Right-click the database name → **Generate ERD** (in pgAdmin 4, this is under the database's context menu, or Tools menu depending on version).
3. pgAdmin will lay out all 5 tables with their relationships automatically.
4. Use the **Export** button in the ERD toolbar to save as PNG, or take a clean screenshot (Windows: `Win + Shift + S`).
5. Save as `docs/screenshots/01_schema_erd.png`.

## Option B — Query result screenshot (psql or pgAdmin)

1. Run one of your more visually interesting queries — the revenue-by-store or data-quality-report query works well since it's business-relevant.
2. If using **pgAdmin's Query Tool**: run the query, let the results grid populate, then use `Win + Shift + S` to snip just the results panel (avoid capturing your whole desktop).
3. If using **psql** in Git Bash: enlarge your terminal font first (`Ctrl` + `+`) so the screenshot is legible, run the query, then snip the terminal window.
4. Save as `docs/screenshots/02_revenue_by_store.png`.

## Option C — A chart from your EDA work

If you built any chart while answering the EDA questions (e.g., in Excel, Google Sheets, or Python/pandas using the query outputs):

1. Export or screenshot the chart directly.
2. Save as `docs/screenshots/03_data_quality_report.png` (or rename to match what the chart actually shows).

---

## Tips for clean screenshots

- **Crop tightly** — no browser chrome, no desktop background, no unrelated taskbar icons.
- **Use a light theme** for pgAdmin/psql if possible — screenshots read better on GitHub's default white background. (Not required — dark theme screenshots work fine too, just be consistent.)
- **Keep file sizes reasonable** — PNG is fine; avoid anything over ~1MB per image.
- **Name files numerically** (`01_`, `02_`, `03_`) so they stay in a sensible order in the folder.

---

## Adding them to your repo

```bash
mkdir -p docs/screenshots
# move your saved PNG files into docs/screenshots/
git add docs/screenshots/
git commit -m "Add project screenshots"
git push
```

Then update the `README.md` preview section to actually embed them instead of just listing filenames:

```markdown
## 📸 Preview

![Schema ERD](docs/screenshots/01_schema_erd.png)
![Revenue by Store](docs/screenshots/02_revenue_by_store.png)
```

That's it — GitHub will render these inline automatically once pushed.
