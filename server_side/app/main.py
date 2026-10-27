from fastapi import FastAPI, HTTPException
from datetime import date, datetime
from pydantic import BaseModel
import sqlite3
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Medisync"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:60158",
        "http://127.0.0.1:60158",
    ],
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {
        "message": "Medisync API is running"
    }

@app.get("/health")
def health_check():
    return {
        "status": "ok"
    }


# user
class User(BaseModel):
    user_id: int
    name: str
    date_of_birth: str
    gender: str
    symptoms: str
    causes: str
    disease: str
    medicine: str

def get_db_connection():
    conn = sqlite3.connect('medisync.db')
    conn.row_factory = sqlite3.Row
    return conn

@app.get("/users")
def get_users():
    conn = get_db_connection()
    users = conn.execute("SELECT * FROM users").fetchall()
    conn.close()
    return [dict(user) for user in users]

@app.get("/user")
def get_user(user_id: int = None, name: str = None):
    if user_id is not None:
        conn = get_db_connection()
        user = conn.execute("SELECT * FROM users WHERE user_id = ?", (user_id,)).fetchone()
        conn.close()
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        return dict(user)
    if name is not None:
        conn = get_db_connection()
        user = conn.execute("SELECT * FROM users WHERE name = ?", (name,)).fetchone()
        conn.close()
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        return dict(user)


# Schedule
class Schedule(BaseModel):
    schedule_id: str
    user_id: int
    tpu_code: int
    time_to_take: str
    dosage_amount: int

def get_db_connection():
    conn = sqlite3.connect('medisync.db')
    conn.row_factory = sqlite3.Row
    return conn

@app.get("/schedules")
def get_schedules():
    conn = get_db_connection()
    schedules = conn.execute("SELECT * FROM schedules").fetchall()
    conn.close()
    return [dict(schedule) for schedule in schedules]

@app.get("/schedule")
def get_user(schedule_id: str = None, user_id: int = None):
    if schedule_id is not None:
        conn = get_db_connection() 
        schedule = conn.execute("SELECT * FROM schedules WHERE schedule_id = ?", (schedule_id,)).fetchone()
        conn.close()
        if schedule is None:
            raise HTTPException(status_code=404, detail="Schedule not found")
        return dict(schedule)
    if user_id is not None:
        conn = get_db_connection()
        schedule = conn.execute("SELECT * FROM schedules WHERE user_id = ?", (user_id,)).fetchone()
        conn.close()
        if schedule is None:
            raise HTTPException(status_code=404, detail="Schedule not found")
        return dict(schedule)


# medicine
class Medicine(BaseModel):
    tpu_code: int
    active_ingredient: str
    strength: str
    dosageform: str
    trade_name: str
    indications: str
    side_effects: str
    precautions: str

@app.get("/medicines")
def get_medicines():
    conn = get_db_connection()
    medicines = conn.execute("SELECT * FROM medicines").fetchall()
    conn.close()
    return [dict(medicine) for medicine in medicines]

@app.get("/medicine")
def get_medicine(tpu_code: int = None, trade_name: str = None):
    conn = get_db_connection()
    if tpu_code is not None:
        medicine = conn.execute("SELECT * FROM medicines WHERE tpu_code = ?", (tpu_code,)).fetchone()
        conn.close()
        if medicine is None:
            raise HTTPException(status_code=404, detail="Medicine not found")
        return dict(medicine)
    if trade_name is not None:
        medicine = conn.execute("SELECT * FROM medicines WHERE trade_name = ?", (trade_name,)).fetchone()
        conn.close()
        if medicine is None:
            raise HTTPException(status_code=404, detail="Medicine not found")
        return dict(medicine)
    

# appointment
class Appointment(BaseModel):
    appointment_id: str
    user_id: int
    appointment_date: str
    appointment_time: str
    status: str

@app.get("/appointments")
def get_appointments():
    conn = get_db_connection()
    appointments = conn.execute("SELECT * FROM appointments").fetchall()
    conn.close()
    return [dict(appointment) for appointment in appointments]

@app.get("/appointment")
def get_appointment(appointment_id: str = None, user_id: int = None):
    conn = get_db_connection()
    if appointment_id is not None:
        appointment = conn.execute("SELECT * FROM appointments WHERE appointment_id = ?", (appointment_id,)).fetchone()
        conn.close()
        if appointment is None:
            raise HTTPException(status_code=404, detail="Appointment not found")
        return dict(appointment)
    if user_id is not None:
        appointment = conn.execute("SELECT * FROM appointment WHERE user_id = ?", (user_id,)).fetchone()
        conn.close()
        if appointment is None:
            raise HTTPException(status_code=404, detail="Appointment not found")
        return dict(appointment)
    

# medication_log
class MedicationLog(BaseModel):
    log_id: str
    schedule_id: str
    action_time: str
    status: str
    side_effect: str

@app.get("/medication_logs")
def get_medication_logs():
    conn = get_db_connection()
    logs = conn.execute("SELECT * FROM medication_log").fetchall()
    conn.close()
    return [dict(log) for log in logs]

@app.get("/medication_log")
def get_medication_log(log_id: str = None, schedule_id: str = None):
    conn = get_db_connection()
    if log_id is not None:
        log = conn.execute("SELECT * FROM medication_log WHERE log_id = ?", (log_id,)).fetchone()
        conn.close()
        if log is None:
            raise HTTPException(status_code=404, detail="Log not found")
        return dict(log)
    if schedule_id is not None:
        logs = conn.execute("SELECT * FROM medication_log WHERE schedule_id = ?", (schedule_id,)).fetchall()
        conn.close()
        return [dict(item) for item in logs]

@app.get("/medication_log/{log_id}/log_history")
def get_medication_log_history(
    log_id: str,
    start_date: date,
    end_date: date
):
    if start_date > end_date:
        raise HTTPException(
            status_code=400,
            detail="start_date must not be after end_date"
        )

    conn = get_db_connection()

    try:
        logs = conn.execute(
            """
            SELECT log_id, schedule_id, action_time, status, side_effect
            FROM medication_log
            WHERE log_id = ?
              AND (
                substr(action_time, instr(action_time, '/') + 1)
              ) IS NOT NULL
            ORDER BY action_time ASC
            """,
            (log_id,)
        ).fetchall()

        result = []

        for log in logs:
            item = dict(log)

            try:
                # รูปแบบ action_time: วัน/เดือน/ปี ชั่วโมง:นาที
                action_date = datetime.strptime(
                    item["action_time"].strip(),
                    "%d/%m/%Y %H:%M"
                ).date()
                
            except (ValueError, TypeError):
                try:
                    action_date = datetime.strptime(
                        item["action_time"],
                        "%d/%m/%Y %H:%M"
                    ).date()
                except (ValueError, TypeError):
                    continue

            if start_date <= action_date <= end_date:
                result.append(item)

        return result

    finally:
        conn.close()
        
@app.delete("/medication_log/{log_id}")
def delete_medication_log(log_id: str):
    conn = get_db_connection()

    try:
        cursor = conn.execute(
            "DELETE FROM medication_log WHERE log_id = ?",
            (log_id,)
        )

        if cursor.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="Medication log not found"
            )

        conn.commit()
        return {
            "message": "ลบข้อมูลสำเร็จ",
            "log_id": log_id
        }

    finally:
        conn.close()
