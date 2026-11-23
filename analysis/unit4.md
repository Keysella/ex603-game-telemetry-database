# Unit 4 Analysis

## Task 4.1: Measure the platform

**Who would act on the per-match breakdown?**
- Some kind of manager or analyst for server stability or matches - someone who can check concrete match_ids.

**What the aggregate hides?**
- The average of 18.14 hides the scatter from 0.00 to 70.86. Zeros are giving abandoned rows and bring down the average.
- 200 events are made from 30 players, and matches consist of different number of events, so, the average of a small match can be moved a lot by a single player, meaning that reliability across all the matches is not the same.

**What to look at next?**
- Maybe check the timeout rate per match to see if there are outliers.

## Task 4.2: Build the breakdown leadership asked for

### Part A: Two numbers in one pass

1) How many events did each match have?
2) How many of these events were network timeouts?

### Part B: Subtotals and a grand total

**Which rows are which?**
- Rows with regions are subtotals, and row ALL is the total for the platform.

**Who needs subtotals?**
- Regional directors or managers who need to compare performance across regions.

**What the grand total supports?**
- Total norm of 6.0% which can be compared to all the regions, and helps identify if the issue is regional or the whole platform is affected.

### Part C: A two-step pipeline

- What is the normal timeout rate for high-volume matches, and which matches are above that rate?

## Reflection

Conditional aggregation allows to get several results in one pass through the data, which makes it efficient. 4.2 part A shows one query calculating total event number and network timeouts for each match at the same time. Alternatively, we could use two separate queries: 1) calculate total number of events per match without filters, 2) calculate total number of network timeouts per match with WHERE disconnect_reason = 'Network timeout'. Each query has to go through the table, so data will be read twice, making the second approach less efficient. On our data with 200 rows the difference is not significant, but at a million rows it can be very slow, and every extra metric that we can come up with (abandoned or contested rows) will make the second approach even slower, while using CASE inside SUM statement still reads this table only once.

Additionally, there is a consistency problem: on a live platform there are always new matches being created, so new rows can be added between the two queries. As a result, numerator and denominator will come from a different data, leading to the wrong rate, while with conditional aggregation both numbers come from the same rows.
