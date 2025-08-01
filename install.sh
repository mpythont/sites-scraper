#!/bin/bash
set -e


GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"


if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}❌ لطفاً این اسکریپت را با دسترسی root اجرا کنید یا از sudo استفاده کنید:${RESET}"
  echo -e "${YELLOW}مثال:${RESET} sudo bash $0"
  exit 1
fi

echo -e "${CYAN}${BOLD}🚀 شروع نصب TopPornSites Scraper...${RESET}"
sleep 1


if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}🔄 نصب Python3...${RESET}"
    apt update && apt install -y python3 python3-pip
    echo -e "${GREEN}✅ Python3 نصب شد.${RESET}"
else
    echo -e "${GREEN}✅ Python3 قبلاً نصب شده.${RESET}"
fi


if ! command -v google-chrome &> /dev/null; then
    echo -e "${YELLOW}🔄 نصب Google Chrome...${RESET}"
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -y ./google-chrome-stable_current_amd64.deb || apt --fix-broken install -y
    rm -f google-chrome-stable_current_amd64.deb
    echo -e "${GREEN}✅ Google Chrome نصب شد.${RESET}"
else
    echo -e "${GREEN}✅ Google Chrome قبلاً نصب شده.${RESET}"
fi


echo -e "${YELLOW}🔄 نصب wget، unzip و curl...${RESET}"
apt install -y wget unzip curl >/dev/null 2>&1


CHROME_VERSION=$(google-chrome --version | grep -oP '[0-9]+' | head -1)
DRIVER_VERSION=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_$CHROME_VERSION")
echo -e "${YELLOW}🔄 دانلود ChromeDriver نسخه ${DRIVER_VERSION} (هماهنگ با Chrome نسخه ${CHROME_VERSION})...${RESET}"

wget -q "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip" -O /tmp/chromedriver.zip
unzip -o /tmp/chromedriver.zip -d /usr/local/bin/ >/dev/null
chmod +x /usr/local/bin/chromedriver-linux64/chromedriver
ln -sf /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver

echo -e "${GREEN}✅ ChromeDriver هماهنگ نصب شد.${RESET}"


echo -e "${YELLOW}🔄 نصب کتابخانه‌های Python (selenium, webdriver-manager, tqdm)...${RESET}"
pip3 install --upgrade pip >/dev/null
pip3 install selenium webdriver-manager tqdm >/dev/null
echo -e "${GREEN}✅ کتابخانه‌های Python نصب شدند.${RESET}"


TMP_FILE="/tmp/scraper.py"
RAW_URL="https://raw.githubusercontent.com/mpythont/toppornsites-scraper/main/scraper.py"

echo -e "${YELLOW}🔄 دانلود اسکریپت از GitHub...${RESET}"
wget -qO $TMP_FILE $RAW_URL && echo -e "${GREEN}✅ اسکریپت دانلود شد.${RESET}" || { echo -e "${RED}❌ دانلود اسکریپت با خطا مواجه شد.${RESET}"; exit 1; }


echo -e "${CYAN}${BOLD}🚀 اجرای اسکریپت...${RESET}"
python3 $TMP_FILE "$@" && echo -e "${GREEN}✅ اسکریپت با موفقیت اجرا شد.${RESET}" || echo -e "${RED}❌ اجرای اسکریپت خطا داد.${RESET}"
