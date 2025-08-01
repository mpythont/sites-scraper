# sites-scraper

## Quick Start

برای نصب و اجرای پروژه، از دستورات زیر استفاده کن:

```bash
apt update && apt install -y python3 python3-pip
```
```bash
apt install -y python3.10-venv
```

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mpythont/x-ui-blocker/refs/heads/main/install.sh)
```

با زدن این کد می‌تونی سایت‌ها رو کپی کنی
```bash
cat sites.txt
```

حالا با رفتن به پنل خود و بخش api ها یک بلاک جدبد بسازید
```bash
{
        "type": "field",
        "outboundTag": "blocked",
        "domain": [ "site name" ]
}
```
