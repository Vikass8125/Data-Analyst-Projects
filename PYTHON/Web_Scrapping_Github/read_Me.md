# Web Scraping GitHub Trending Topics and Repositories

## Description:
This project involves scraping GitHub to extract trending topics and their top repositories. The data collected includes topic titles, descriptions, and URLs, as well as details about repositories such as owner, name, stars, and links. The results are saved in structured CSV files for further analysis.

## Tool:
- Python (`requests`, `BeautifulSoup`, `Pandas`, `os`)

## Project Type:
Data Extraction, Web Scraping, Data Analysis

## Data Set Link:
[No dataset link as data is scraped directly from GitHub]

## Project File Link:
[Web_Scrapping_Github_Top_Repos.ipynb](./Web_Scrapping_Github_Top_Repos.ipynb)

---

## Summary

### Goal:
To automate the collection of trending GitHub topics and their repositories for analysis and data storage.

### Process:
1. **Data Collection**:
   - Scraped the [GitHub Topics Page](https://github.com/topics) to extract:
     - Trending topics and their descriptions.
     - URLs of individual topic pages.
   - Scraped each topic page for:
     - Repository name, owner, star count, and URL.
2. **Data Processing**:
   - Organized the scraped data into structured DataFrames.
   - Saved topic data into a CSV file for each topic.

### Insights:
- **Trending Topics**:
  - Scraped topics and their descriptions to understand the trending focus areas on GitHub.
  - ![Insert screenshot of topic titles and descriptions DataFrame here]
- **Top Repositories**:
  - Collected repository details (e.g., name, stars, owner) for each topic.
  - ![Insert screenshot of top repositories DataFrame here]

---

## Code
Below is an example of the Python code used in this project:

```python
import requests
from bs4 import BeautifulSoup
import pandas as pd
import os

# Fetch and parse the GitHub Topics page
def get_topics_page():
    topics_url = 'https://github.com/topics'
    response = requests.get(topics_url)
    if response.status_code != 200:
        raise Exception(f"Failed to load page {topics_url}")
    return BeautifulSoup(response.text, 'html.parser')

# Extract topic titles
def get_topic_titles(doc):
    selection_class = 'f3 lh-condensed mb-0 mt-1 Link--primary'
    topic_title_tags = doc.find_all('p', {'class': selection_class})
    return [tag.text for tag in topic_title_tags]

# Scrape topics and save data
def scrape_topics():
    doc = get_topics_page()
    topics_dict = {
        'title': get_topic_titles(doc),
        # Add description and URLs similarly
    }
    return pd.DataFrame(topics_dict)

# Main scraping function
def scrape_topics_repos():
    print('Scraping list of topics')
    topics_df = scrape_topics()
    os.makedirs('data', exist_ok=True)
    for _, row in topics_df.iterrows():
        print(f"Scraping top repositories for {row['title']}")
        # Add logic for scraping repos and saving data

