#!/bin/bash
set -e

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}❌ لطفاً این اسکریپت را با دسترسی root اجرا کنید:${RESET}"
  echo -e "${YELLOW}مثال:${RESET} sudo bash $0"
  exit 1
fi

echo -e "${CYAN}${BOLD}🚀 شروع نصب TopPornSites Scraper...${RESET}"
sleep 1


apt update && apt install -y python3 python3-pip wget unzip curl


if ! command -v google-chrome &> /dev/null; then
    echo -e "${YELLOW}🔄 نصب Google Chrome...${RESET}"
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -y ./google-chrome-stable_current_amd64.deb || apt --fix-broken install -y
    rm -f google-chrome-stable_current_amd64.deb
    echo -e "${GREEN}✅ Chrome نصب شد.${RESET}"
fi


CHROME_VERSION=$(google-chrome --version | grep -oP '[0-9]+' | head -1)
DRIVER_VERSION=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_$CHROME_VERSION")
wget -q "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip" -O /tmp/chromedriver.zip
unzip -o /tmp/chromedriver.zip -d /usr/local/bin/ >/dev/null
chmod +x /usr/local/bin/chromedriver-linux64/chromedriver
ln -sf /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver


pip3 install --upgrade pip
pip3 install selenium webdriver-manager tqdm requests


RAW_URL="https://raw.githubusercontent.com/mpythont/toppornsites-scraper/main/scraper.py"
wget -qO /tmp/scraper.py $RAW_URL


mkdir -p /tmp/chrome-profile
python3 /tmp/scraper.py
