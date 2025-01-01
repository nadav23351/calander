# שימוש ב-Node.js כתשתית
FROM node:16

# הגדרת תיקיית העבודה
WORKDIR /app

# העתקת קבצי הבקאנד
COPY package*.json ./
RUN npm install
RUN apt-get update && apt-get install -y netcat
COPY server.js ./



# חשיפת הפורט של השרת
EXPOSE 3000

# הפעלת השרת
CMD ["node", "server.js"]
