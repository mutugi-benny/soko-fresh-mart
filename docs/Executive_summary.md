Executive Summary: Soko Fresh Mart Data & Strategy Audit

Date: [2026-07-13] | Prepared By: [Munene Benny Mutugi]
Reporting Period: Jan 2023 – June 2026

Greetings Leadership Team. We have concluded a rigorous, end-to-end analysis of Soko Fresh Mart’s historical data. This audit evaluated over 30 distinct performance metrics—ranging from Month-over-Month (MoM) revenue trends and cumulative daily sales to regional payment preferences and product pricing outliers.

Below is our strategic assessment of our store efficiency, loyalty program performance, and the urgent data infrastructure issues we must resolve immediately.

1. Store Efficiency: Which Stores Need Immediate Attention?

Historically, we assumed that expanding store size (store_size_sqm) guaranteed proportional revenue growth. However, our correlation analysis (Pearson's r = [0.4389]) reveals that floor space does not strictly dictate success.

The High Performers: Our bar charts and MoM lag analyses show that Store [Soko Fresh Mart - Eldoret Town] generates [37151.83] in average monthly revenue, vastly outperforming larger locations. This is largely driven by our top-grossing category, [Baby & Kids], and their localized best-selling product: [Baby Formula 400g].

The Underperformers: Store [Soko Fresh Mart - Kisumu] has seen a MoM revenue decline of [98.08]% and is failing to move our top 10 best-selling items.

Action: Regional managers must audit the layouts of our underperforming large stores. Success is being driven by optimized product mix and regional payment adaptations (e.g., heavily utilizing [M-Pesa] in [Nairobi]), not just square footage.

2. Customer Value: Does Loyalty Actually Drive Spend?

Yes, but our revenue relies heavily on a small group of big spenders. Our statistical distribution checks (Mean: [4366.18] vs. Median: [3674]) prove our order values are highly right-skewed.

Loyalty Program Impact: Box-plot distributions confirm that our loyalty tiers do not directly correlate with spend. Customers in the [Bronze Tier] tier have a median spend that is [2.40]% higher than gold-tiered customers who dominate our "High Spend" buckets.

Churn Risk: We mapped the lifespan (first to last order) of our top customers (5+ orders). Our Recency Model shows that [73.91]% of our previously high-value customers have not ordered in over 90 days, placing them in the "At Risk" or "Churning" buckets.

Action: Marketing must deploy targeted retention campaigns to the [233] customers currently in the 90-180 day risk segment before they fall into the "Lost" bucket. We must also engage the [251] registered customers who have historically placed zero orders.

3. Critical Data Quality Roadblocks (Must Fix Immediately)

Before we can roll these tracking dashboards out company-wide, we must plug severe data leaks that are actively inflating our revenue reporting. Our automated data-cleaning queries caught the following systemic anomalies:

Revenue Attribution Errors: We found [15] orders tied to store_ids that do not exist, representing [79174.25] in orphaned revenue. Furthermore, [49] orders were logged before their respective stores officially opened.

Inventory & Pricing Corruption: We identified [25] exact duplicate line items (double-counting revenue), [160] rows with zero or negative quantities, and [1] extreme unit-price outlier(s) that failed our Interquartile Range (IQR) checks.

Customer Duplication & Missing Contacts: Due to unstandardized text entry (e.g., failing to trim/capitalize cities like "Nairobi"), we detected [79] duplicate customer profiles. Even worse, [0.22]% of our profiles are missing both emails and phone numbers, forcing our COALESCE fallback to report 'Not on file', which cripples our ability to contact at-risk customers.

Next Steps: Engineering must implement strict database constraints to enforce valid dates, block negative quantities, and prevent orphaned foreign keys. Operations must standardize checkout data entry immediately.