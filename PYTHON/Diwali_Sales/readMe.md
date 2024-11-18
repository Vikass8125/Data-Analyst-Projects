# Diwali Sales Analysis

## Description:
This project explores customer purchasing behavior during Diwali sales, analyzing key patterns across demographics, product categories, and geographical locations. It aims to provide insights into factors driving sales performance.

## Tool:
Python (pandas, matplotlib, seaborn)

## Project Type:
Data Cleaning, Data Analysis, Data Visualization

## Data Set Link:
*Unavailable*

## Project File Link:
*Not Provided*

---

## Summary

- **Goal**  
  To analyze Diwali sales data to identify customer trends, purchasing patterns, and top-performing regions/products for better decision-making in sales strategies.

- **Process**  
  1. Cleaned and preprocessed the dataset by removing irrelevant columns and handling missing values.  
  2. Explored the dataset using statistical summaries and visualizations to identify trends.  
  3. Generated insights using bar charts, grouped summaries, and trend analyses.

- **Insights**  
  - **Gender:** Most buyers are females, and their purchasing power is higher compared to males.  
  - **Age Group:** Customers aged 26-35 years make the most purchases, predominantly females.  
  - **Geography:** Uttar Pradesh, Maharashtra, and Karnataka lead in both the number of orders and revenue.  
  - **Marital Status:** Married individuals, especially women, contribute significantly to sales.  
  - **Occupation:** IT, Healthcare, and Aviation professionals are the top contributors.  
  - **Product Categories:** Food, Clothing, and Electronics dominate the product categories.  

---

## Key Visualizations

### Gender Distribution  
**Placeholder:** Add a bar chart showing the distribution of buyers by gender and their purchasing amounts.

### Age Group Analysis  
**Placeholder:** Add a bar chart showing total purchases and revenue by age group.

### Top States by Orders and Revenue  
**Placeholder:** Add two bar charts: one showing the number of orders by state and another showing revenue by state.

### Marital Status and Gender Contribution  
**Placeholder:** Add a grouped bar chart comparing marital status and gender against total revenue.

### Occupation Insights  
**Placeholder:** Add a bar chart showing the total revenue contribution by different occupations.

### Product Categories and Top Products  
**Placeholder:** Add two visuals: one showing the top product categories by revenue and another showing the top 10 most sold products.

---

## Conclusion:
Married women aged 26-35 from Uttar Pradesh, Maharashtra, and Karnataka, working in IT, Healthcare, and Aviation, are more likely to purchase products in Food, Clothing, and Electronics categories during Diwali.

---

## Python Code Snippet

```python
# Importing required libraries
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Load the dataset
df = pd.read_csv('Diwali Sales Data.csv', encoding='unicode_escape')

# Data Cleaning
df.drop(['Status', 'unnamed1'], axis=1, inplace=True)
df.dropna(inplace=True)
df['Amount'] = df['Amount'].astype('int')

# Gender Analysis
sns.countplot(x='Gender', data=df)
plt.title('Gender Distribution of Buyers')
plt.show()

sales_gen = df.groupby('Gender')['Amount'].sum().reset_index()
sns.barplot(x='Gender', y='Amount', data=sales_gen)
plt.title('Total Amount by Gender')
plt.show()

# Age Group Analysis
sns.countplot(x='Age Group', hue='Gender', data=df)
plt.title('Age Group Distribution by Gender')
plt.show()

sales_age = df.groupby('Age Group')['Amount'].sum().reset_index()
sns.barplot(x='Age Group', y='Amount', data=sales_age)
plt.title('Total Amount by Age Group')
plt.show()

# State Analysis
sales_state = df.groupby('State')['Orders'].sum().reset_index().sort_values(by='Orders', ascending=False).head(10)
sns.barplot(x='State', y='Orders', data=sales_state)
plt.title('Top 10 States by Number of Orders')
plt.show()

sales_state_amount = df.groupby('State')['Amount'].sum().reset_index().sort_values(by='Amount', ascending=False).head(10)
sns.barplot(x='State', y='Amount', data=sales_state_amount)
plt.title('Top 10 States by Revenue')
plt.show()

# Occupation Analysis
sns.countplot(x='Occupation', data=df)
plt.title('Occupation Distribution')
plt.show()

sales_occupation = df.groupby('Occupation')['Amount'].sum().reset_index().sort_values(by='Amount', ascending=False)
sns.barplot(x='Occupation', y='Amount', data=sales_occupation)
plt.title('Total Amount by Occupation')
plt.show()

# Product Category Analysis
sns.countplot(x='Product_Category', data=df)
plt.title('Product Category Distribution')
plt.show()

sales_product = df.groupby('Product_Category')['Amount'].sum().reset_index().sort_values(by='Amount', ascending=False)
sns.barplot(x='Product_Category', y='Amount', data=sales_product)
plt.title('Top Product Categories by Revenue')
plt.show()

