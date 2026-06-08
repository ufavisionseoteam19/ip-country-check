#!/bin/bash
# ============================================================
# ip-country-check.sh  (v3)
# ใส่เลข IP -> บอกประเทศ + ISP + เมือง
# แสดงตารางบนจอ + เซฟไฟล์ (เรียงตามประเทศ, ทับชื่อเดิม)
# รองรับ: ใส่ IP ตรงๆ (ทีละตัว/หลายตัว) หรืออ่านจากไฟล์/CSV
# ใช้ API ฟรี ip-api.com (ไม่ต้องติดตั้งอะไร)
# ============================================================

# ---------- ตั้งค่า ----------
API="http://ip-api.com/line"
FIELDS="status,country,countryCode,city,isp,query"
DELAY=1.4
OUTDIR="/root"
OUT="$OUTDIR/ip-country-check.txt"         # ไฟล์ผล (ทับชื่อเดิมทุกครั้ง)
TAB=$(printf '\t')
# --------------------------------

usage() {
  echo "วิธีใช้:"
  echo "  ใส่ IP ตรงๆ      : $0 8.8.8.8"
  echo "  หลาย IP          : $0 8.8.8.8 1.1.1.1 38.190.100.105"
  echo "  อ่านจากไฟล์      : $0 -f /root/ip_count_all.txt"
  echo ""
  echo "ผลจะเซฟที่: $OUT (เรียงตามประเทศ, ทับชื่อเดิม)"
  exit 1
}

# ---------- รวบรวมรายการ IP ----------
IPS=()
if [ "$1" = "-f" ]; then
  [ -z "$2" ] && usage
  [ ! -f "$2" ] && { echo "ไม่พบไฟล์: $2"; exit 1; }
  mapfile -t IPS < <(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9a-fA-F]{0,4}:){2,}[0-9a-fA-F]{0,4}' "$2" | sort -u)
elif [ -n "$1" ]; then
  IPS=("$@")
else
  usage
fi

TOTAL=${#IPS[@]}
[ "$TOTAL" -eq 0 ] && { echo "ไม่พบ IP ที่ถูกต้อง"; exit 1; }

echo "============================================"
echo " IP Country Check (v3)"
echo "============================================"
echo " จำนวน IP : $TOTAL"
echo " ไฟล์ผล   : $OUT (เรียงตามประเทศ)"
echo "============================================"
echo ""

TMP=$(mktemp /tmp/ipcountry.XXXXXX)
trap 'rm -f "$TMP"' EXIT

# ---------- เช็คทีละ IP ----------
i=0; ok=0; fail=0
for ip in "${IPS[@]}"; do
  i=$((i+1))
  resp=$(curl -s --max-time 8 "$API/$ip?fields=$FIELDS" 2>/dev/null)
  status=$(echo "$resp"  | sed -n '1p')
  country=$(echo "$resp" | sed -n '2p')
  cc=$(echo "$resp"      | sed -n '3p')
  city=$(echo "$resp"    | sed -n '4p')
  isp=$(echo "$resp"     | sed -n '5p')

  if [ "$status" = "success" ]; then
    printf "%s${TAB}%s${TAB}%s${TAB}%s${TAB}%s\n" "$country" "$cc" "$ip" "$city" "$isp" >> "$TMP"
    ok=$((ok+1))
  else
    printf "%s${TAB}%s${TAB}%s${TAB}%s${TAB}%s\n" "(ตรวจไม่ได้)" "??" "$ip" "-" "-" >> "$TMP"
    fail=$((fail+1))
  fi

  printf "\r  ตรวจแล้ว %d/%d ..." "$i" "$TOTAL"
  [ "$i" -lt "$TOTAL" ] && sleep "$DELAY"
done

echo ""; echo ""

# ---------- สร้างตาราง (เรียงตามประเทศ) เขียนลงไฟล์ ----------
{
  printf "%-18s %-4s %-40s %-15s %s\n" "ประเทศ" "CC" "IP" "เมือง" "ISP"
  printf "%-18s %-4s %-40s %-15s %s\n" "------------------" "--" "----------------------------------------" "---------------" "------------------------"
  sort -t"$TAB" -k1,1 "$TMP" | awk -F"$TAB" '{ printf "%-18s %-4s %-40s %-15s %s\n", $1, $2, $3, $4, $5 }'
} > "$OUT"

# ---------- แสดงตารางเต็มบนจอ (เหมือนในไฟล์) ----------
echo "===== ผลลัพธ์ (เรียงตามประเทศ) ====="
cat "$OUT"
echo ""

# ---------- สรุปต่อประเทศ ----------
echo "===== สรุปจำนวน IP ต่อประเทศ ====="
awk -F"$TAB" '{print $1}' "$TMP" | sort | uniq -c | sort -nr

echo ""
echo "============================================"
echo " เสร็จแล้ว"
echo " สำเร็จ : $ok | ตรวจไม่ได้ : $fail"
echo " ไฟล์ผล : $OUT"
echo "============================================"
