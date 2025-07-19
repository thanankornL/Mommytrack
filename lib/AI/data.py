import requests
from bs4 import BeautifulSoup
import time
import pandas as pd
BASE_URL = "https://moph.go.th/"
NEWS_CATEGORY_URL = "https://moph.go.th/link_department"  # หมวดข่าวสุขภาพ

def get_news_links(page_url):
    res = requests.get(page_url)
    soup = BeautifulSoup(res.text, 'html.parser')
    articles = soup.find_all('div', class_='col-md-4 col-sm-6 col-12 mb-4')

    links = []
    for article in articles:
        a_tag = article.find('a', href=True)
        if a_tag:
            links.append(BASE_URL + a_tag['href'])
    return links

def get_news_content(news_url):
    res = requests.get(news_url)
    soup = BeautifulSoup(res.text, 'html.parser')
    title = soup.find('h2', class_='mt-0').text.strip() if soup.find('h2', class_='mt-0') else "No Title"
    content_div = soup.find('div', class_='desc')
    content = content_div.get_text(separator='\n').strip() if content_div else "No Content"
    return title, content

def main():
    all_news = []

    # สมมติดึงแค่ 3 หน้า (ถ้าจะดึงเพิ่ม ให้เพิ่ม loop หรือปรับ URL)
    for page_num in range(1, 4):
        print(f"กำลังดึงหน้าที่ {page_num}")
        url = NEWS_CATEGORY_URL
        if page_num > 1:
            url += f'?page={page_num}'
        
        links = get_news_links(url)
        print(f"เจอลิงก์ข่าว {len(links)} ข่าว")

        for link in links:
            print("กำลังดึงข่าว:", link)
            title, content = get_news_content(link)
            all_news.append({'title': title, 'content': content})
            time.sleep(1)  # เว้นระยะเพื่อไม่ให้เว็บโหลดหนักเกินไป
    
    # บันทึกลงไฟล์ CSV
    import csv
    with open('moph_news.csv', 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['title', 'content'])
        writer.writeheader()
        for news in all_news:
            writer.writerow(news)

    print("บันทึกข้อมูลเสร็จเรียบร้อย")

if __name__ == '__main__':
    main()



df = pd.read_csv('moph_news.csv')
print(df.head())
print(df.shape)