const { Client } = require('pg');

const client = new Client({
  host: 'postgres',  // Using the service name from docker-compose
  port: 5432,
  database: 'strapi',
  user: 'strapi',
  password: 'your_secure_password'
});

async function testConnection() {
  try {
    await client.connect();
    console.log('Successfully connected to PostgreSQL');
    const result = await client.query('SELECT NOW()');
    console.log('Database time:', result.rows[0].now);
  } catch (err) {
    console.error('Error connecting to PostgreSQL:', err);
  } finally {
    await client.end();
  }
}

testConnection();
