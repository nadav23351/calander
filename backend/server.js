const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
const app = express();
const port = 3000;

// הגדרת Middleware של CORS - מאפשר גישה מ-any דומיין
app.use(cors());

// Middleware to parse JSON
app.use(express.json());

// הגדרת החיבור למסד נתונים (MySQL)
const db = mysql.createConnection({
  host: 'localhost',  // הכתובת של השרת (localhost ב-WSL)
  user: 'root',       // שם המשתמש במסד הנתונים
  password: '12123434Nadav',       // סיסמת ה-root (אם יש)
  database: 'calendarDB' // שם מסד הנתונים שיצרנו
});

// בדיקת חיבור למסד הנתונים
db.connect((err) => {
  if (err) {
    console.error('Error connecting to the database: ', err);
    return;
  }
  console.log('Connected to the MySQL database');
});

// דף ראשי כדי לבדוק אם השרת פועל
app.get('/', (req, res) => {
  res.send('Hello World!');
});

// נתיב לקבלת כל האירועים
app.get('/events', (req, res) => {
  db.query('SELECT * FROM events', (err, results) => {
    if (err) {
      return res.status(500).send({ message: 'Error fetching events', error: err });
    }
    res.status(200).json(results);
  });
});

// נתיב להוספת אירוע למסד הנתונים
app.post('/events', (req, res) => {
  const { name, date, description } = req.body;

  // שאילתת SQL להוספת אירוע
  const query = 'INSERT INTO events (name, date, description) VALUES (?, ?, ?)';
  db.query(query, [name, date, description], (err, result) => {
    if (err) {
      return res.status(500).send({ message: 'Error creating event', error: err });
    }
    res.status(201).send({
      message: 'Event created successfully!',
      event: { name, date, description }
    });
  });
});

 
  
  

// תחילת השמיעה של השרת
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
