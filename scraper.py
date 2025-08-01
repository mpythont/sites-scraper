import threading
import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from urllib.parse import urljoin
from tqdm import tqdm
import re
import os

# 🟢 اطمینان از ایجاد پوشه پروفایل موقت
os.makedirs("/tmp/chrome-profile", exist_ok=True)

# 🎯 تنظیمات مرورگر برای سرور
options = Options()
options.add_argument("--headless=new")
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--disable-gpu")
options.add_argument("--user-data-dir=/tmp/chrome-profile")
options.add_argument("user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36")

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

base_url = "https://toppornsites.net/"
links = []
pattern = r"https?://([^/?#]+)"

# ⬅️ ۱. باز کردن صفحه اصلی و جمع‌آوری href ها
driver.get(base_url)
time.sleep(5)

all_hrefs = []
divs = driver.find_elements(By.XPATH, "//div[@class='block-list']")
for div in divs:
    for li in div.find_elements(By.TAG_NAME, 'li'):
        try:
            tag_a = li.find_element(By.TAG_NAME, 'a').get_attribute('href')
            if tag_a:
                all_hrefs.append(tag_a)
        except:
            pass

all_hrefs = [urljoin(base_url, h) if not h.startswith("http") else h for h in all_hrefs]

# 🟢 شمارنده‌ها
ok_count = 0
error_count = 0
progress_count = 0
total = len(all_hrefs)

# 🔄 تابع آپدیت نرم نوار پیشرفت
def smooth_progress_bar(pbar):
    global progress_count
    while progress_count < total:
        if progress_count < ok_count + error_count:
            progress_count += 1
            pbar.update(1)
        time.sleep(0.05)
    while progress_count < total:
        progress_count += 1
        pbar.update(1)
    pbar.close()

pbar = tqdm(total=total, desc=f"🔗 Processing | OK:0 | ERR:0", colour="cyan", unit="link", ncols=120)
threading.Thread(target=smooth_progress_bar, args=(pbar,), daemon=True).start()

# ⬅️ ۲. پردازش لینک‌ها
for full_url in all_hrefs:
    try:
        if full_url.startswith("https://toppornsites.net/"):
            driver.get(full_url)
            time.sleep(5)
            final_url = driver.current_url
        else:
            final_url = full_url

        for d in re.findall(pattern, final_url):
            if d.startswith("www."):
                d = d[4:]
            links.append(d)

        ok_count += 1
    except:
        error_count += 1

    pbar.set_description(f"🔗 Processing | OK:{ok_count} | ERR:{error_count}")

driver.quit()

# ⬅️ ۳. افزودن دامنه‌های سفارشی
extra_sites = [
    "de.pornhub.org",
    "ge.xhamster.desi",
    "porn4days.blue",
    "xhamster.desi",
    "xhaccess.com"
]
links.extend(extra_sites)

# ⬅️ ۴. حذف تکراری‌ها و ذخیره در فایل
unique_links = sorted(set(links))
with open("sites.txt", "w", encoding="utf-8") as f:
    for link in unique_links:
        f.write(f"\"{link}\",\n")

print(f"\n✅ {len(unique_links)} لینک نهایی در فایل sites.txt ذخیره شد. (موفق: {ok_count} | خطا: {error_count})")
