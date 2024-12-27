// פונקציה לשלוח בקשה לשרת ולקבל את האירועים
async function getEvents() {
  try {
      const response = await fetch('http://localhost:3000/events');
      const events = await response.json();

      const eventsList = document.getElementById('events-list');
      eventsList.innerHTML = ''; // ניקוי התוכן הקודם

      events.forEach(event => {
          const eventDiv = document.createElement('div');
          eventDiv.classList.add('event');
          eventDiv.innerHTML = `<h3>${event.name}</h3><p>${event.date}</p>`; // תיקון כאן
          eventsList.appendChild(eventDiv);
      });
  } catch (error) {
      console.error('Error fetching events:', error);
  }
}

// שליחה של אירוע חדש לשרת
async function addEvent(event) {
  const name = document.getElementById('event-name').value;
  const date = document.getElementById('event-date').value;

  const response = await fetch('http://localhost:3000/events', {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify({ name, date })
  });

  const data = await response.json();
  console.log(data.message); // הודעה על הצלחה

  // עדכון רשימת האירועים
  getEvents();
}

// אירוע של שליחת הטופס
document.getElementById('event-form').addEventListener('submit', function (event) {
  event.preventDefault();
  addEvent(event);
});

// קריאה להציג את האירועים עם טעינת הדף
getEvents();
