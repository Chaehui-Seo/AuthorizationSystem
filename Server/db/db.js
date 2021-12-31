require('dotenv').config()

const mysql = require('mysql')

const db = mysql.createConnection({
	host:  process.env.dbHost,
	user: process.env.dbUser,
	password: process.env.dbPassword,
	database: process.env.dbName
})

db.connect((err) => {
	if (err) {
		throw err;
	}
	console.log('MySql connected')
})

module.exports = db