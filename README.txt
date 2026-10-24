วิธีรัน backend:
1. เปิด terminal ในโฟลเดอร์ backend/ นี้
2. รัน: npm install
3. รัน: node app.js
4. เปิดเบราว์เซอร์หรือ Bruno ไปที่ http://localhost:3000/api/games

ไฟล์ games.db จะถูกสร้างขึ้นอัตโนมัติตอนรันครั้งแรก (ถ้ายังไม่มีไฟล์นี้อยู่)
พร้อมข้อมูลตัวอย่าง 32 เกม ครอบคลุม 12 หมวดหมู่
ไม่ต้องติดตั้ง SQLite เองแยกต่างหาก เพราะ better-sqlite3 จัดการให้ในตัว

วิธีเปิด frontend:
เปิดไฟล์ frontend/index.html ด้วยเบราว์เซอร์โดยตรง (หรือใช้ Live Server)
โดยต้องเปิด backend (node app.js) ทิ้งไว้ด้วย เพราะหน้าเว็บทุกหน้าดึงข้อมูลจริงจาก API

=== API endpoints ===

GET /api/games
  คืนรายการเกม รองรับ query string สำหรับค้นหา/กรอง/จัดเรียง:
    ?category=RPG              กรองตามหมวดหมู่ (ค้นหาแบบ substring)
    ?q=zelda                   ค้นหาจากชื่อเกม/หมวดหมู่/คำอธิบาย (ใช้กับช่องค้นหาบนเว็บ)
    ?sort=score_desc           จัดเรียง: score_desc, score_asc, title_asc, title_desc, newest
    ?editors_pick=1            เฉพาะเกมที่เป็นตัวเลือกของบรรณาธิการ
    ?limit=8                   จำกัดจำนวนผลลัพธ์
  พารามิเตอร์ทั้งหมดใช้ร่วมกันได้ เช่น
    /api/games?q=โลกเปิด&category=RPG&sort=score_desc&limit=6

GET /api/categories
  คืนรายชื่อหมวดหมู่ทั้งหมดพร้อมจำนวนเกมจริงในแต่ละหมวด (ใช้แสดงในหน้าหมวดหมู่)

GET /api/games/:id
  คืนข้อมูลเกมเดียวตาม id (ใช้ในหน้ารายละเอียดเกม) คืน 404 ถ้าไม่พบ

=== หน้าเว็บ (frontend) ===

index.html        หน้าแรก — ดึงสถิติ/รีวิวยอดนิยม/หมวดหมู่/เกมคะแนนสูงสุด/เกมล่าสุด จาก API จริงทั้งหมด
categories.html   รวมหมวดหมู่ทั้งหมด พร้อมจำนวนเกมจริงในแต่ละหมวด
category.html     รายการเกมในหมวดหมู่ที่เลือก (เข้าถึงผ่าน ?name=หมวดหมู่)
search.html       หน้าค้นหา/ฟิลเตอร์เกม พิมพ์คำค้นหาแล้วผลลัพธ์อัปเดตทันที
                  พร้อมฟิลเตอร์หมวดหมู่ / เรียงลำดับ / เฉพาะตัวเลือกบรรณาธิการ
game-detail.html  รายละเอียดเกม (เข้าถึงผ่าน ?id=รหัสเกม)

ช่องค้นหาบน nav ของทุกหน้า พิมพ์แล้วกด Enter จะพาไปหน้า search.html พร้อมคำค้นหานั้นทันที

=== ระบบบัญชีผู้ใช้ ===

หน้า frontend/auth.html รองรับสมัครสมาชิก/เข้าสู่ระบบด้วยอีเมลและรหัสผ่าน
รวมถึง Google OAuth ผ่าน Supabase Auth โดยไม่ต้องเพิ่ม endpoint สำหรับรหัสผ่านใน backend

ตั้งค่า frontend/auth-config.js ด้วยค่า Supabase Project URL และ public anon key
จาก Supabase Dashboard > Project Settings > API Keys (ห้ามใส่ secret/service-role key ใน frontend)

ตั้งค่า Supabase Dashboard > Authentication:
1. เปิด Email provider และกำหนดว่าจะต้องยืนยันอีเมลก่อนเข้าใช้งานหรือไม่
2. เปิด Google provider พร้อม Client ID/Client Secret จาก Google Cloud Console
3. เพิ่ม URL ของหน้าเว็บ (เช่น http://localhost:5500/auth.html และ URL production)
   ใน Authentication > URL Configuration > Redirect URLs
4. ตั้งค่า Authorized redirect URI ใน Google Cloud เป็น
   https://<project-ref>.supabase.co/auth/v1/callback

ทดสอบผ่าน Live Server หรือเว็บเซิร์ฟเวอร์ที่ใช้ http/https แทนการเปิดไฟล์ด้วย file://

=== ความคิดเห็นใต้รายละเอียดเกม ===

1. เปิด Supabase Dashboard > SQL Editor
2. ถ้าเคยสร้างตารางแล้ว ให้คัดลอกและรัน SQL ฉบับล่าสุดจากไฟล์ supabase-comments.sql
   เพื่ออัปเดต policy/trigger และตั้งค่าดาวส่วนตัวของเจ้าของคอมเมนต์
   (ตาราง games ต้องมีอยู่ก่อนแล้ว)
3. เปิดหน้า game-detail.html?id=<รหัสเกม> และเข้าสู่ระบบเพื่อโพสต์ความคิดเห็น

ความคิดเห็นจะแยกตาม game_id; เปิดหน้าเกมแต่ละเกมเพื่อดูเฉพาะความคิดเห็นของเกมนั้น
ทุกคนอ่านได้ แต่เฉพาะผู้ใช้ที่เข้าสู่ระบบโพสต์และลบความคิดเห็นของตัวเองได้
เจ้าของคอมเมนต์ที่เข้าสู่ระบบเท่านั้นที่กำหนดดาว 1–5 ให้คอมเมนต์ตัวเองได้
ผู้ใช้อื่นเห็นดาวแต่กดไม่ได้ และไม่มีระบบคะแนนรวมหรือค่าเฉลี่ย
ฐานข้อมูลจะกำหนดชื่อและอีเมลจากบัญชีที่ยืนยันตัวตนโดยอัตโนมัติ
ชื่อและอีเมลของผู้โพสต์จะแสดงต่อสาธารณะตามรูปแบบที่ขอ อย่าโพสต์ด้วยบัญชีที่ไม่ต้องการ
เปิดเผยอีเมลให้ผู้เข้าชมเว็บไซต์ทุกคน
