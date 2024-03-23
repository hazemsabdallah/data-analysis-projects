# Prosper Loan Data Exploration
### Hazem Samir Abdallah

## Dataset

The dataset consists of 113,937 rows and 81 columns. Each row is an individual 
loan record. The 81 variables include loan details such as loan amount, interest 
rate, loan status, borrower monthly income...etc. This dataset is provided through 
Udacity's classroom.

In order to get the data into shape for visual exploration and analysis, a few 
preliminary wrangling steps have been carried out. This includes replacing the 
numeric variables in the listing category column to their corresponding descriptions 
and changing the field's to category data type. Prosper rating variable has also 
been change to categorical ordinal data type. Listing date has been changes to 
datetime and another year column has been engineered from it. LoanOriginalAmount 
column has been used to engineer a LoanSize variable cutting loans into 3 sizes 
(i.e. small/medium/large). Furthermore, due to several loan statuses causing 
distraction during visualization, another loan status summary column has been 
derived to provide 5 possible summaries for the LoanStatus column.

## Summary of Findings

There is a strong correlation between loan status and Prosper rating. For instance,
combined ratings between 'D' to 'HR' are significantly more evident in bad debt and 
past due loan listings. As for other variables such as income and debt and debt to 
income ration, there were no key takeaways suggesting a signifacant correlation to 
loan status. Moreover, when viewing loan status for each individual listing category, 
bad debt loans seemed more apparent in 3 specific categories than in other. Those 
3 categories are student use, personal, and business loans.

Again, the most apparent correlation here is against Prosper rating. As the rating 
gets better (i.e. towards 'AA'), the interest rate, that is the cost of borrowing, 
gets lower. Also, the interest rates for homeowners seemed to generally have a lower 
average than non=owners. Furthermore, at first sight, it looks like loan amount and 
interest rate might have a negative relation. This latter trend though does not hold 
when adding Prosper rating to the equation. Such multivariate analysis between interest, 
amount and rating served to strengthen the correlation between Prosper rating and 
borrowing interest rate.

There is a clear correlation between loan amount and duration. As the Term of the loan 
increases, loan size tends to increase as well. Around 50% of the 3 year loans are above 
USD 5,000 and even more than 75% of the 5 year loans have an amount of at least USD 8,000. 
For 1 year loans however, around 75% of their dustribution are under the USD 5,000 mark. 
One more interesting interaction is between listing date and homeownership. The year 2009 
seemes to be a turning year for homeowners. Before 2009, non-homeowning borrowers had a 
higher count of loan listings. After 2009, however, homeowners have a higher count and the 
difference keeps slightly widening from one year to another in favor of homeowners. Finally, 
the average interet rates for homeowners is lower than non-owners. This difference, however, 
seem to be converging from one year to another.

## Key Insights for Presentation

In the beginning, the main purposes behind requesting Proper loans are visualized. 
Then, the main focus went into the interaction between Prosper rating and the main 
variables of interest which are loan status and interest rate. The addition of loan 
amount as a multivariate analysis is then depicted to strengthen the correlation 
between rating and interest rate. Lastly, the trend of loan listings per homeownership 
status is viewed as a trend analysis.

All visualizations have been adjusted to include descriptive titles, labels, and legends. 
The color palette used through the presentation is consistent. For the interest rate 
versus Prosper rating chart, continuing to use a violin plot as like in the exploration 
might not be the best idea for explanatory purposes. Using a box plot seemed distracting 
as well due to many outlier points. A bar plot is used here instead to depict the average 
interest rate for each rating. 
