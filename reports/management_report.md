# Management Report: Retail Sales and Profitability, 2014-2017

Data: Superstore sample dataset (9,993 order lines, 5,009 orders, 793 customers, 1,894 products).
All figures come from the PostgreSQL analysis in `sql/`, cross-checked in Python, Excel and Power BI.

## Executive summary

Revenue was 2,296,919 and profit 286,409 (12.5% margin) over four years. Revenue grew
in 2016 (+29.5%) and 2017 (+20.4%). Profit is being lost mainly through **deep discounting
(over 20%)** and a few loss-making products, concentrated in Furniture and the Central region.
Growth now comes almost entirely from existing customers.

## Key findings and recommendations

### 1. Deep discounts destroy profit
- In every category, lines discounted 20% or less are profitable and lines above 20% lose money
  (Furniture -54,466; Office Supplies -47,140; Technology -33,758).
- **Recommendation:** introduce a discount approval rule above 20%, starting with Furniture.
- Caveat: this is a strong association. Product mix may also contribute.

### 2. Furniture earns almost no profit
- Furniture revenue is 741,718 but profit only 18,463 (2.5% margin vs 17.0% and 17.4%).
- Tables lose 17,725 and Bookcases 3,473.
- Furniture lines at 20% discount or less made 72,929 profit; deep-discount lines turn it into 18,463.
- **Recommendation:** review pricing and discount limits for Tables and Bookcases.

### 3. Central region is the weakest
- Central margin is 7.9% (West 14.9%). Its average discount is 0.240 and 27.7% of its lines
  are discounted over 20%; those lines lose 52,392, more than Central's total profit of 39,706.
- **Recommendation:** apply the discount rule in Central first and track margin quarterly.
- Caveat: regional product mix has not been tested.

### 4. A few products drive large losses
- Worst: Cubify CubeX 3D Printer Double Head (-8,880), Lexmark MX611dhe (-4,590).
- Machines earn only 3,385 on 189,239 revenue.
- **Recommendation:** review pricing and discounts on the loss-making Machines and Tables products.

### 5. Top customers by revenue are not always profitable
- The top customer by revenue (Sean Miller, 25,043) lost 1,981. One Cisco TelePresence line
  (22,638 at 50% discount) caused it.
- **Recommendation:** rank accounts by profit as well as revenue, and require approval for
  large heavily discounted orders.

### 6. Win back at-risk customers
- At Risk: 80 customers, about 8.7 orders each, about 195 days inactive, 56,375 profit.
- Champions and Loyal (332 customers) generate about 53% of revenue.
- **Recommendation:** targeted win-back outreach to At Risk customers using non-discount offers.
  Lost customers (175, 374 days inactive) suit low-cost automated contact only.

### 7. New customer acquisition has nearly stopped
- New customers per year: 595, 136, 51, 11. In 2017, 682 of 693 active customers were returning.
- **Recommendation:** review acquisition channels. Cause is unknown and may reflect how the
  sample dataset was built.

### 8. Seasonality
- Revenue is weakest in January and February and peaks in November (Nov 2017: 118,448).
- **Recommendation:** plan staffing and stock for the November peak and promotions for early year.

## Risks
- Margin depends on discount discipline; deep discounts always lost money in this data.
- Growth relies on existing customers, so churn would hit revenue directly.

## Limitations
- Cost is derived (sales minus profit), not source data.
- Inventory, suppliers and lead times are simulated (seed 42); inventory results show the method only.
- One near-duplicate row (Row ID 3407) was removed on the assumption it was double-entered.
- RFM segment rules are my own definitions, and NTILE splits tied values arbitrarily.
- 98.5% of customers ordered more than once, so a simple repeat rate does not separate customers.
- 347 products had no sale in 2017; this is a review list, not proof of failure.
- Findings show association, not proven cause.