// Define the API base URL
// const API_BASE_URL = 'http://localhost:3000/api';
const API_BASE_URL = 'https://backend.nadav.online/api';

// Function to fetch events from the API
async function getEvents() {
  try {
    const response = await axios.get(`${API_BASE_URL}/events`);
    const events = response.data;

    const eventsList = document.getElementById('events-list');
    eventsList.innerHTML = ''; // Clear previous content

    events.forEach(event => {
      const eventDiv = document.createElement('div');
      eventDiv.classList.add('event');
      eventDiv.innerHTML = `
        <h3>${event.name}</h3>
        <p>${event.date}</p>
        <button onclick="deleteEvent(${event.id})">מחק</button>
      `;
      eventsList.appendChild(eventDiv);
    });
  } catch (error) {
    console.error('Error fetching events:', error);
  }
}


// Function to delete an event
async function deleteEvent(eventId) {
  try {
    const response = await axios.delete(`${API_BASE_URL}/events/${eventId}`);
    console.log(response.data.message);

    // Refresh events list after deletion
    getEvents();
  } catch (error) {
    console.error('Error deleting event:', error);
  }
}

// Function to add a new event
async function addEvent() {
  const name = document.getElementById('event-name').value;
  const date = document.getElementById('event-date').value;

  try {
    const response = await axios.post(`${API_BASE_URL}/events`, { name, date });
    console.log(response.data.message);

    // Clear form fields after successful submission
    document.getElementById('event-name').value = '';
    document.getElementById('event-date').value = '';

    // Refresh events list
    getEvents();
  } catch (error) {
    console.error('Error adding event:', error);
  }
}

// Form submit event handler
document.getElementById('event-form').addEventListener('submit', function (event) {
  event.preventDefault();
  addEvent();
});

// Load events when page loads
getEvents();