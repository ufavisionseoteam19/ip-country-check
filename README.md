# ip-country-check

ใส่เลข IP → บอก **ประเทศ / เมือง / ISP** แสดงตารางบนจอ + เซฟไฟล์ เรียงตามประเทศ ด้วย Bash

รับได้ทั้ง **ใส่ IP ตรงๆ** (ทีละตัว/หลายตัว) หรือ **อ่านจากไฟล์/CSV**

> ใช้ API ฟรี `ip-api.com` ไม่ต้องติดตั้งอะไร

---

## คุณสมบัติ

- ใส่ IP ตรงๆ ได้ทั้งตัวเดียวและหลายตัว
- อ่านจากไฟล์/CSV ได้ (ดึงเฉพาะ IP ที่ถูกต้อง ข้ามหัวตารางอัตโนมัติ)
- แสดง ประเทศ + รหัสประเทศ + เมือง + ISP
- **แสดงตารางเต็มบนจอ + เซฟไฟล์ `/root/ip-country-check.txt`** (เรียงตามประเทศ, ทับชื่อเดิม)
- แสดงสรุปจำนวน IP ต่อประเทศ
- รองรับ IPv4 / IPv6

---

## วิธีใช้

```bash
# ตรวจ IP เดียว / หลายตัว
./ip-country-check.sh 38.190.100.105 152.42.205.29

# อ่านจาก CSV
./ip-country-check.sh -f check-ip-list.csv

# เทผลจาก ip-count-check มาตรวจประเทศ
./ip-country-check.sh -f /root/ip_count_all.txt

# ดูผลย้อนหลัง
cat /root/ip-country-check.txt
```

### รันตรงจาก GitHub ไม่โหลดลง server

```bash
# ใส่ IP ตรงๆ
curl -fsSL https://raw.githubusercontent.com/ufavisionseoteam19/ip-country-check/main/ip-country-check.sh | bash -s -- 38.190.100.105 152.42.205.29

# อ่าน IP จาก CSV บน GitHub
curl -fsSL https://raw.githubusercontent.com/ufavisionseoteam19/ip-country-check/main/ip-country-check.sh | bash -s -- $(curl -fsSL https://raw.githubusercontent.com/ufavisionseoteam19/ip-country-check/main/check-ip-list.csv | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
```

---

## รูปแบบไฟล์ CSV (check-ip-list.csv)

```
ip
38.190.100.105
152.42.205.29
58.8.140.171
```

บรรทัดแรก `ip` = หัวตาราง / ถัดมาวาง IP บรรทัดละ 1 ตัว

---

## ตัวอย่างผลลัพธ์ (แสดงบนจอ = เนื้อหาใน /root/ip-country-check.txt)

```
ประเทศ             CC   IP                เมือง        ISP
Peru               PE   38.190.100.105    San Juan     Conex TV
Singapore          SG   152.42.205.29     Singapore    DigitalOcean, LLC
Singapore          SG   5.223.53.147      Singapore    Hetzner Online GmbH
Thailand           TH   58.8.140.171      Bangkok      True Internet
```

`cloud ISP` (DigitalOcean/Hetzner/AWS) = มัก bot | `ISP เน็ตบ้าน/มือถือ` (True/TOT/AIS) = มักคนจริง

---

## การตั้งค่า

| ตัวแปร | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|
| `OUT` | `/root/ip-country-check.txt` | ไฟล์ผล |
| `DELAY` | `1.4` | หน่วงเวลากัน rate limit |

---

## License

ใช้ภายในทีมได้อย่างอิสระ
