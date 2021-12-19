const dotenv = require('dotenv')
dotenv.config()

module.exports = {
  emailId: process.env.emailId,
  emailPw: process.env.emailPw,
  secret: process.env.jwtSecret
}
