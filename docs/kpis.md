# Commercial KPIs

Eight indicators for the commercial board. Each one comes with the decision it changes. Values are calculated on `fact_sales`, from 2011-05-31 to 2014-06-30.

## 1. Gross and net revenue

- **Definition:** gross = `sum(unitprice * orderqty)`; net = gross minus discounts.
- **Value:** US$ 110.37 million gross and US$ 109.85 million net. Gross by year: 2011 (May to December) 12.65 million; 2012 33.71 million; 2013 43.92 million; 2014 (January to June) 20.09 million.
- **Decision it changes:** the size of sales targets and of the commercial budget. Gross is the audited reference; net shows what actually came in after discounts.

## 2. Average ticket

- **Definition:** net revenue divided by the distinct orders of the period.
- **Value:** about US$ 3,491 per order overall. By channel: US$ 1,061 online and US$ 21,148 in salesperson orders. By year: US$ 7,867 (2011), US$ 8,563 (2012), US$ 3,076 (2013) and US$ 1,705 (2014).
- **Decision it changes:** where to invest sales effort. The drop in ticket in 2013 and 2014 comes from the strong arrival of small online orders, and shows that growth in orders is not growth in revenue per order.

## 3. Orders and items per order

- **Definition:** distinct orders; items per order = units divided by orders.
- **Value:** 31,465 orders and 274,914 units, or 8.7 items per order. Online: 2.2 items per order. Salesperson: 56.4 items per order.
- **Decision it changes:** the cross-sell strategy online (few items per order) and the stock replenishment plan for stores (large orders).

## 4. Average discount rate

- **Definition:** discount divided by gross sales.
- **Value:** about 0.48% overall (US$ 0.53 million). By category: Clothing 1.0%, Bikes and Accessories 0.5%, Components close to 0%. By year: 0% (2011), 0.6% (2012), 0.7% (2013) and 0.2% (2014).
- **Decision it changes:** the promotion policy. The discount is low in every category, so cutting it brings little; the gain is in price, mix and volume.

## 5. Revenue by channel

- **Definition:** gross sales by `is_online_order`.
- **Value:** salesperson (stores) 73.4% of gross (US$ 81.0 million) and online 26.6% (US$ 29.4 million). The channel matches the customer type: every online order is from a person and every salesperson order is from a store.
- **Decision it changes:** the allocation of the sales team across store accounts and the investment in the online channel.

## 6. Concentration in the top 10 customers

- **Definition:** share of the top 10 customers in gross sales.
- **Value:** top 10 = 7.2%; top 100 = 42.3% (0.5% of the 19,119 buyers). The largest customer is under 1%.
- **Decision it changes:** the key account relationship plan. There is no dependency on a single customer, but 100 customers sustain about 42% of the revenue.

## 7. Revenue by territory (country) and monthly and yearly growth

- **Definition:** gross sales by ship-to country; month over month (MoM) and year over year (YoY) growth on comparable periods.
- **Value:** United States 57.4% (US$ 63.3 million), Canada 14.9%, Australia 9.7%, United Kingdom 7.0%, France 6.6% and Germany 4.5%. From January to May, 2014 grew about 47% over 2013, comparing the same months (June 2014 is incomplete and left out).
- **Decision it changes:** the investment priority by country and the validation of growth targets. Always compare the same range of months, because of the partial years.

## 8. Mix by category

- **Definition:** share of each product category in gross sales.
- **Value:** Bikes 86.2%, Components 10.7%, Clothing 1.9% and Accessories 1.2%. Accessories appear in about 19,500 orders, the highest number, but are worth only 1.2% of the revenue.
- **Decision it changes:** the portfolio focus. Revenue depends on bikes; accessories work as an order add-on and not as a revenue driver, which changes how the success of each category is measured.
