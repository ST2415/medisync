# MediSync — Flutter & FastAPI

แอปจัดการยา ประวัติการรับประทานยา และการนัดหมายทางการแพทย์ พัฒนาด้วย **Flutter** สำหรับแอปมือถือ และ **FastAPI** สำหรับ Backend API

> หมายเหตุ: โค้ด FastAPI อยู่ในโฟลเดอร์ `server_side` ส่วนแอป Flutter ให้รันคำสั่งจากโฟลเดอร์ที่มีไฟล์ `pubspec.yaml`

## สารบัญ

- [MediSync — Flutter \& FastAPI](#medisync--flutter--fastapi)
  - [สารบัญ](#สารบัญ)
  - [สิ่งที่ต้องติดตั้ง](#สิ่งที่ต้องติดตั้ง)
  - [1. เตรียมฐานข้อมูล](#1-เตรียมฐานข้อมูล)
  - [2. รัน FastAPI Server](#2-รัน-fastapi-server)
    - [Windows (PowerShell)](#windows-powershell)
  - [3. ตั้งค่า URL ของ API ใน Flutter](#3-ตั้งค่า-url-ของ-api-ใน-flutter)
    - [หา IPv4 ของคอมพิวเตอร์ (Windows)](#หา-ipv4-ของคอมพิวเตอร์-windows)
  - [4. รันแอป Flutter](#4-รันแอป-flutter)
  - [5. ทดสอบ API](#5-ทดสอบ-api)
  - [การแก้ปัญหาที่พบบ่อย](#การแก้ปัญหาที่พบบ่อย)
    - [Flutter เชื่อมต่อ API ไม่ได้](#flutter-เชื่อมต่อ-api-ไม่ได้)
    - [`ModuleNotFoundError` ตอนเริ่ม Server](#modulenotfounderror-ตอนเริ่ม-server)
    - [เชื่อมต่อฐานข้อมูลไม่ได้](#เชื่อมต่อฐานข้อมูลไม่ได้)
    - [`flutter pub get` ล้มเหลว](#flutter-pub-get-ล้มเหลว)
  - [ลำดับการเปิดโปรเจกต์ในแต่ละครั้ง](#ลำดับการเปิดโปรเจกต์ในแต่ละครั้ง)

## สิ่งที่ต้องติดตั้ง

- Python 3.10 ขึ้นไป (ควรใช้เวอร์ชันเดียวกับที่โปรเจกต์กำหนด)
- Flutter SDK และ Dart SDK ที่มากับ Flutter
- Android Studio พร้อม Android SDK/Emulator หรือโทรศัพท์ Android ที่เปิด USB debugging
- Git (ถ้าจะ clone Repository)
- ระบบฐานข้อมูลที่โปรเจกต์กำหนด เช่น MySQL หาก FastAPI Server เชื่อมต่อ MySQL ให้เปิดฐานข้อมูลก่อนรัน API

ตรวจสอบการติดตั้ง:

```bash
python --version
flutter --version
flutter doctor
```

## 1. เตรียมฐานข้อมูล

1. ตรวจสอบค่าการเชื่อมต่อฐานข้อมูลในไฟล์ตั้งค่าของ FastAPI Server เช่น `.env`, `database.py` หรือไฟล์ที่ใช้สร้าง connection
2. เปิดฐานข้อมูลตามที่โปรเจกต์กำหนด
3. หาก Repository มีไฟล์ SQL สำหรับสร้างตาราง/ข้อมูลเริ่มต้น (ตัวอย่างเช่น `sql-export/medisync.sql`) ให้นำเข้าไฟล์นั้นในฐานข้อมูลที่ถูกต้องก่อนเริ่ม Server
4. ตรวจสอบว่า database name, username, password, host และ port ใน FastAPI Server ตรงกับฐานข้อมูลที่เปิดอยู่

**อย่า commit รหัสผ่านหรือข้อมูลลับลง Git** หากมีไฟล์ `.env.example` ให้คัดลอกเป็น `.env` แล้วกรอกค่าของเครื่องตนเอง โดยไม่ต้อง push ไฟล์ `.env` ขึ้น Repository

## 2. รัน FastAPI Server

เปิด Terminal แล้วเข้าโฟลเดอร์ที่มีไฟล์ `main.py` ของ FastAPI

### Windows (PowerShell)

```powershell
cd path\to\server_side
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
```

ถ้ามีไฟล์ `requirements.txt` ให้ติดตั้ง dependencies:

```powershell
pip install -r requirements.txt
```

หากไม่มี `requirements.txt` ให้ติดตั้งแพ็กเกจที่โปรเจกต์ใช้งานตาม import ในโค้ด ตัวอย่างเช่น:

```powershell
pip install fastapi "uvicorn[standard]"
```

สั่งรัน Server โดยให้มือถือ/Emulator ในเครือข่ายเดียวกันเข้าถึงได้:

```powershell
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

> `main:app` หมายถึงไฟล์ `main.py` ที่มีตัวแปร FastAPI ชื่อ `app` หากไฟล์อยู่ในแพ็กเกจ เช่น `app/main.py` อาจต้องใช้ `app.main:app` แทน ให้ตรวจสอบโครงสร้างจริงของโปรเจกต์

เมื่อเริ่มทำงานแล้ว เปิดเอกสาร API ได้ที่:

- Swagger UI: `http://127.0.0.1:8000/docs`
- OpenAPI JSON: `http://127.0.0.1:8000/openapi.json`

อย่าปิด Terminal ที่กำลังรัน Server ขณะทดสอบแอป

## 3. ตั้งค่า URL ของ API ใน Flutter

Flutter ต้องเรียก URL ที่เข้าถึงจากอุปกรณ์ที่รันแอปได้ **อย่าใช้ `localhost` แบบเดียวกันทุกกรณี** เพราะ `localhost` ของ Emulator/มือถือหมายถึงตัวอุปกรณ์นั้นเอง

| สภาพแวดล้อม | Base URL ตัวอย่าง |
|---|---|
| Flutter รันบน Android Emulator | `http://10.0.2.2:8000` |
| Flutter รันบนโทรศัพท์จริง | `http://<IPv4-ของคอมพิวเตอร์>:8000` |
| Flutter รันบนเว็บในเครื่องเดียวกับ Server | `http://127.0.0.1:8000` |

### หา IPv4 ของคอมพิวเตอร์ (Windows)

```powershell
ipconfig
```

หา IPv4 Address ของ Wi-Fi/Ethernet ที่ใช้เชื่อมต่อเครือข่าย เช่น `192.168.1.25` แล้วตั้ง Base URL ในโค้ด Flutter เป็น `http://192.168.1.25:8000` (ใช้ IP จริงของเครื่องคุณแทนตัวอย่าง)

ค้นหาจุดที่กำหนด API URL ในโปรเจกต์ Flutter เช่น `api_service.dart`, `api_config.dart` หรือไฟล์ service ที่เรียก HTTP แล้วเปลี่ยน Base URL ให้ตรงกับสภาพแวดล้อม อย่าลืมให้โทรศัพท์และคอมพิวเตอร์อยู่ในเครือข่ายเดียวกัน และอนุญาต Python/Uvicorn ผ่าน Windows Firewall เฉพาะเครือข่ายที่เชื่อถือได้

หาก API ใช้ CORS และ Flutter Web เรียกไม่ผ่าน ให้ตรวจสอบการตั้งค่า CORS ใน FastAPI สำหรับ origin ที่ต้องการใช้งาน โดยไม่เปิดกว้างเกินความจำเป็น ส่วน Flutter Android/iOS แบบ Native โดยทั่วไปไม่ได้ใช้ CORS แบบเว็บเบราว์เซอร์

## 4. รันแอป Flutter

ให้รองรับ DevicePreview โดยเพิ่ม dependency ด้วยคำสั่ง flutter pub add device_preview 

import 'package:device_preview/device_preview.dart' 
ตั้งค่า locale: DevicePreview.locale(context) กับ builder: DevicePreview.appBuilder ใน MaterialApp
และสั่งให้ 
```
runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
);
```
## 5. ทดสอบ API

1. ให้ FastAPI Server ทำงานอยู่
2. เปิด `http://127.0.0.1:8000/docs` บนคอมพิวเตอร์
3. เลือก endpoint ที่ต้องการ แล้วกด **Try it out** → กรอกพารามิเตอร์ → **Execute**
4. ตรวจสอบ HTTP status code และ response JSON
5. ทดลองเปิดแอป Flutter และตรวจสอบว่าข้อมูลที่แสดงตรงกับ API/ฐานข้อมูล

ตัวอย่างตรวจสอบว่า Server ตอบสนองหรือไม่ (หากมี endpoint `/`):

```powershell
Invoke-WebRequest http://127.0.0.1:8000/
```

หากไม่มี endpoint `/` การได้ `404 Not Found` ที่ path นี้ไม่ได้แปลว่า Server ล่ม ให้ตรวจสอบ `/docs` หรือ endpoint ที่มีอยู่จริง

## การแก้ปัญหาที่พบบ่อย

### Flutter เชื่อมต่อ API ไม่ได้

- ตรวจสอบว่า FastAPI ยังทำงานอยู่ และเปิดด้วย `--host 0.0.0.0`
- Android Emulator ใช้ `10.0.2.2` เพื่อเข้าถึง Server บนคอมพิวเตอร์ ไม่ใช่ `127.0.0.1`
- โทรศัพท์จริงให้ใช้ IPv4 ของคอมพิวเตอร์ และเชื่อมต่อ Wi-Fi เครือข่ายเดียวกัน
- ตรวจสอบพอร์ต `8000`, Windows Firewall และ URL ในไฟล์ตั้งค่า Flutter
- ถ้า Android ปฏิเสธ HTTP แบบไม่เข้ารหัส ให้ตรวจสอบ Network Security Configuration ของแอปในโหมดพัฒนา หรือใช้ HTTPS ตามความเหมาะสม อย่าปิดข้อจำกัดด้านความปลอดภัยในแอปที่นำไปใช้งานจริงโดยไม่ประเมินความเสี่ยง

### `ModuleNotFoundError` ตอนเริ่ม Server

เปิด virtual environment ของ FastAPI Server และติดตั้ง dependencies อีกครั้ง:

```powershell
python -m pip install -r requirements.txt
```

ตรวจสอบด้วยว่ากำลังรันคำสั่งจากโฟลเดอร์ที่ถูกต้องและเลือก Python interpreter ที่ตรงกับ virtual environment

### เชื่อมต่อฐานข้อมูลไม่ได้

- ตรวจสอบว่า database service ทำงานอยู่
- ตรวจสอบ host, port, database name, username และ password
- ตรวจสอบว่า import ไฟล์ SQL ลงฐานข้อมูลที่ FastAPI Server ใช้งานจริงแล้ว
- อ่านข้อความ error ใน Terminal ของ FastAPI เพื่อดูสาเหตุที่แน่ชัด

### `flutter pub get` ล้มเหลว

- ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและเวอร์ชัน Flutter
- รัน `flutter doctor` เพื่อดูปัญหาการติดตั้ง SDK
- ตรวจสอบ `pubspec.yaml` และเวอร์ชัน dependencies ที่โปรเจกต์กำหนด

## ลำดับการเปิดโปรเจกต์ในแต่ละครั้ง

1. เปิดฐานข้อมูลก่อน (ถ้า FastAPI Server ใช้ฐานข้อมูลแยก)
2. เปิด Terminal ของ FastAPI Server และรัน FastAPI
3. ตรวจสอบ API ผ่าน `/docs`
4. เปิด Emulator/เชื่อมต่อโทรศัพท์
5. เปิด Terminal ของ Flutter แล้วรัน `flutter run`

> โปรเจกต์นี้เป็นงานเพื่อการศึกษา ไม่ควรใช้แทนคำแนะนำจากแพทย์หรือระบบเวชระเบียนจริง และไม่ควรใส่ข้อมูลสุขภาพส่วนบุคคลจริงลงในระบบทดลองที่ยังไม่มีมาตรการรักษาความปลอดภัยเหมาะสม
