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
  host: process.env.MYSQL_HOST, // הכתובת של השרת (localhost ב-WSL)
  port: 3306,
  user: process.env.MYSQL_USER,       // שם המשתמש במסד הנתונים
  password: process.env.MYSQL_PASSWORD,       // סיסמת ה-root (אם יש)
  database: process.env.MYSQL_DATABASE, // שם מסד הנתונים שיצרנו
  authPlugin: 'caching_sha2_password'
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
app.get('/api/events', (req, res) => {
  db.query('SELECT * FROM events', (err, results) => {
    if (err) {
      return res.status(500).send({ message: 'Error fetching events', error: err });
    }
    res.status(200).json(results);
  });
});

// נתיב להוספת אירוע למסד הנתונים
app.post('/api/events', (req, res) => {
  const { name, date } = req.body;

  const query = 'INSERT INTO events (name, date) VALUES (?, ?)';
  db.query(query, [name, date], (err, result) => {
    if (err) {
      return res.status(500).send({ message: 'Error creating event', error: err });
    }
    res.status(201).send({
      message: 'Event created successfully!',
      event: { name, date }
    });
  });
});

// נתיב למחיקת אירוע
app.delete('/api/events/:id', (req, res) => {
    const eventId = req.params.id;
  
    const query = 'DELETE FROM events WHERE id = ?';
    db.query(query, [eventId], (err, result) => {
      if (err) {
        return res.status(500).send({ message: 'Error deleting event', error: err });
      }
      res.status(200).send({ message: 'Event deleted successfully!' });
    });
  });
  

// תחילת השמיעה של השרת
app.listen(port, () => {
  console.log(`Server is running at ${port}`);
});
