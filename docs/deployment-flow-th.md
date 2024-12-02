# คู่มือการ Deploy ระบบ

เอกสารนี้อธิบายขั้นตอนการ Deploy ระบบทั้งในส่วนของ Development และ Production

## ภาพรวม

ระบบใช้ CI/CD pipeline ผ่าน GitHub Actions เพื่อทำการ Deploy อัตโนมัติ โดยแบ่งเป็น 2 workflow:
- Development deployment (`deploy-dev.yml`)
- Production deployment (`deploy-prod.yml`)

## การเตรียมระบบ

### สิ่งที่ต้องมี
1. VPS บน Digital Ocean หรือ Cloud Provider อื่นๆ
2. ติดตั้ง Docker และ Docker Compose บนเซิร์ฟเวอร์
3. Repository บน GitHub พร้อม Secrets ที่จำเป็น
4. Domain Name สำหรับ Frontend และ CMS
5. SSL Certificate (จัดการโดย Nginx)

## ขั้นตอนการ Deploy สำหรับ Development

### การเริ่มทำงาน
- Push โค้ดไปที่ branch `develop`
- สั่งรันด้วยตนเองผ่าน GitHub Actions UI

### ขั้นตอน
1. **สร้าง Docker Images**
   - Build Image สำหรับ CMS
   - Build Image สำหรับ Frontend
   - ติด Tag `:dev`
   - Push ขึ้น GitHub Container Registry (GHCR)

2. **Deploy**
   - เชื่อมต่อเซิร์ฟเวอร์ผ่าน SSH
   - ดึง Images ล่าสุด
   - อัพเดทคอนเทนเนอร์ด้วย `docker-compose.yml`
   - ลบ Images เก่า

## ขั้นตอนการ Deploy สำหรับ Production

### การเริ่มทำงาน
- Push โค้ดไปที่ branch `main`
- สั่งรันด้วยตนเองผ่าน GitHub Actions UI

### ขั้นตอน
1. **Build และ Test**
   - ดึงโค้ดล่าสุด
   - ติดตั้ง Node.js dependencies
   - รันชุดทดสอบ
   - หยุดทันทีถ้าการทดสอบล้มเหลว

2. **สร้าง Docker Images**
   - Build Image สำหรับ CMS
   - Build Image สำหรับ Frontend
   - ติด Tag `:latest` และ `:${git-sha}`
   - Push ขึ้น GitHub Container Registry

3. **Deploy**
   - เชื่อมต่อเซิร์ฟเวอร์ผ่าน SSH
   - ดึง Images ล่าสุด
   - อัพเดทคอนเทนเนอร์ด้วย `docker-compose.prod.yml`
   - ลบ Images เก่า

4. **ตรวจสอบระบบ**
   - ตรวจสอบการเข้าถึง Frontend
   - ตรวจสอบการเข้าถึง CMS admin
   - ลองใหม่สูงสุด 3 ครั้ง ห่างกัน 5 วินาที

## GitHub Secrets ที่จำเป็น

### สำหรับ Development
- `VPS_HOST`: IP หรือ hostname ของเซิร์ฟเวอร์
- `VPS_USERNAME`: ชื่อผู้ใช้ SSH
- `VPS_SSH_KEY`: Private key สำหรับ SSH
- `GITHUB_TOKEN`: Token สำหรับเข้าถึง GitHub

### สำหรับ Production
- `PROD_VPS_HOST`: IP หรือ hostname ของเซิร์ฟเวอร์
- `PROD_VPS_USERNAME`: ชื่อผู้ใช้ SSH
- `PROD_VPS_SSH_KEY`: Private key สำหรับ SSH
- `PROD_FRONTEND_DOMAIN`: โดเมนของ Frontend
- `PROD_CMS_DOMAIN`: โดเมนของ CMS
- `GITHUB_TOKEN`: Token สำหรับเข้าถึง GitHub

## การติดตามระบบ

ระบบมีเครื่องมือสำหรับติดตามดังนี้:
1. **Prometheus**: เก็บ Metrics
2. **Grafana**: แสดงผลและ Dashboard
3. **Loki**: รวบรวม Logs

การเข้าถึง Dashboard:
- Development: 
  - Grafana: `http://dev-domain:3000`
  - Prometheus: `http://dev-domain:9090`
- Production:
  - Grafana: `http://prod-domain:3000`
  - Prometheus: `http://prod-domain:9090`

## การ Rollback

หากการ Deploy มีปัญหา:

1. **Rollback อัตโนมัติ**
   - ระบบตรวจสอบจะล้มเหลว
   - เวอร์ชันก่อนหน้ายังคงทำงานอยู่

2. **Rollback ด้วยตนเอง**
   ```bash
   # เชื่อมต่อเซิร์ฟเวอร์
   ssh user@server

   # กลับไปใช้เวอร์ชันก่อนหน้า
   cd /opt/shopping-online
   docker-compose pull frontend:previous-tag cms:previous-tag
   docker-compose up -d

   # ตรวจสอบสถานะ
   docker-compose ps
   ```

## การแก้ไขปัญหา

ปัญหาที่พบบ่อยและวิธีแก้:

1. **ตรวจสอบระบบล้มเหลว**
   - ดู logs: `docker-compose logs frontend cms`
   - ตรวจสอบการตั้งค่า Nginx
   - ตรวจสอบ SSL certificates

2. **ปัญหาเกี่ยวกับ Container**
   - ดูสถานะ container: `docker ps -a`
   - ดู logs: `docker logs container_name`
   - ตรวจสอบพื้นที่: `df -h`

3. **ปัญหาเกี่ยวกับฐานข้อมูล**
   - ตรวจสอบ PostgreSQL logs
   - ตรวจสอบการเชื่อมต่อฐานข้อมูล
   - ตรวจสอบสถานะ Redis

## ความปลอดภัย

1. **การจัดการ Secrets**
   - เก็บข้อมูลสำคัญใน GitHub Secrets
   - ไม่เก็บรหัสผ่านในโค้ด
   - หมุนเวียน SSH keys เป็นประจำ

2. **การควบคุมการเข้าถึง**
   - จำกัดการเข้าถึง SSH
   - แยก Container
   - อัพเดทความปลอดภัยสม่ำเสมอ

3. **ความปลอดภัยเครือข่าย**
   - เข้ารหัส SSL/TLS
   - ตั้งค่า Firewall
   - จำกัดการเรียกใช้งานใน Nginx
