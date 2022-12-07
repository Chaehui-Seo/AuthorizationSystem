const jwt = require('jsonwebtoken')
const db = require('../db/db')
const bcrypt = require('bcryptjs')
const nodemailer = require('nodemailer')
const { emailId, emailPw, secret } = require('../config/config')

// 전체 유저 조회
let loadUsers = async function(req, res) {
	let sql = 'SELECT * FROM Users'
	db.query(sql, (err, result) => {
		if (err) return res.status(400).send(err)
		return res.status(201).send(result)
	})
}

// 탈퇴하기
// 어드민 유저의 경우, 타 유저도 탈퇴시키기 가능
let withdraw = async function(req, res) {
	const userId = req.body.userId
	const isAdmin = req.body.isAdmin
	const password = req.body.password
	var hash = bcrypt.hashSync(password, 8)
    const bcryptPassword = bcrypt.compareSync(password, hash)

	if (isAdmin == 0 ){
		// 일반 유저
		const auth = req.get('Authorization')
		if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })
		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			if ((err) || (tokenUserId != userId)) return res.status(404).json({ success: false, message: "Invalid token" })

			var sql = 'SELECT * from Users WHERE (Users.userId = ?) LIMIT 1'
			let query = db.query(sql, [userId], (err, userResult) => {
				if (err) return res.status(400).json({ success: false, message: err })
				if (!userResult.length) return res.status(400).json({ success: false, message: "No user found" })

				bcrypt.compare(password, userResult[0].password, function(error, response) {
					if (!response) return res.status(401).json({ success: false, message: "incorrect password" })
					
					var sql = 'DELETE FROM Users WHERE Users.userId = ?'
					let query = db.query(sql, [userId], (err, result) => {
						if (err) return res.status(400).send({ success: false, message: err })
						res.status(201).send({ success: true, message: "Successfully withdrawal" })
					})
				})
			})
		})
	} else {
		// 어드민 유저
		var sql = 'DELETE FROM Users WHERE Users.userId = ?'
		let query = db.query(sql, [userId], (err, result) => {
			if (err) return res.status(400).send({ success: false, message: err })
			res.status(201).send({ success: true, message: "Successfully withdrawal" })
		})
	}
}

// FCM 토큰 저장
let setFcmToken = async function(req, res) {
	const userId = req.body.userId
	const fcmToken = req.body.fcmToken
    const auth = req.get('Authorization')

    if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })

	const userToken = auth.split(' ')[1]
	jwt.verify(userToken, secret, (err, encode) => {
		if(err) return res.status(404).json({ success: false, message: "Invalid token" })

		const tokenUserId = encode["userId"]
		if (tokenUserId != userId) return res.status(404).json({ success: false, message: "Invalid token" })
		var sql = 'UPDATE Users SET fcmToken=? WHERE userId=?'
		let query = db.query(sql, [fcmToken, userId], (err, result) => {
			if (err) return res.status(400).json({ success: false, message: err })
			res.status(201).json({ success: true, message: "Successfully Email Verified" })
		})
	})
}

// 로그인
let logIn = async function(req, res) {
	const userId = req.body.userId
	const password = req.body.password
	var hash = bcrypt.hashSync(password, 8)
    const bcryptPassword = bcrypt.compareSync(password, hash)

	var sql = 'SELECT * from Users WHERE (Users.userId = ?) LIMIT 1'
	let query = db.query(sql, [userId], (err, userResult) => {
		if (err) return res.status(400).json({ success: false, message: err })
		if (!userResult.length) return  res.status(402).json({ success: false, message: "No user found" })

		bcrypt.compare(password, userResult[0].password, function(error, response) {
			if (!response) return res.status(401).json({ success: false, message: "Incorrect password" })
			const accessToken = jwt.sign({
				userId : userId
			},
			secret,
			{
				expiresIn : '2h'
			})
			const refreshToken = jwt.sign({
				userId : userId
			},
			secret,
			{
				expiresIn : '14d'
			})

			// 유저 추가 작성
			sql = 'UPDATE Users SET refreshToken=? WHERE userId=?'
			let query = db.query(sql, [refreshToken, userId], (err, result) => {
				if (err) return res.status(400).json({ success: false, message: err })
				let sql = 'SELECT * FROM Users WHERE Users.userId = ?'
				db.query(sql, [userId], (err, result) => {
					if (err) return res.status(400).send(err)
					res.status(201).header('Token', accessToken).json(result)
				})
			})
		})
	})
}

// 자동 로그인
let autoLogIn = async function(req, res) {
	const userId = req.body.userId

	var sql = 'SELECT * from Users WHERE (Users.userId = ?) LIMIT 1'
	let query = db.query(sql, [userId], (err, userResult) => {
		if (err) return res.status(400).json({ success: false, message: err })
		if (!userResult.length) return res.status(402).json({ success: false, message: "No user found" })

		const refreshToken = req.get('Authorization')
		if (refreshToken == null) return res.status(404).json({ success: false, message: "Invalid token" })

		const userToken = refreshToken.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			const dbToken = "Bearer " + userResult[0].refreshToken
			if ((err) || (tokenUserId != userId) || (dbToken != refreshToken)) return res.status(404).json({ success: false, message: "Invalid token" })

			const accessToken = jwt.sign({
				userId : userId
			},
			secret,
			{
				expiresIn : '2h'
			})

			const refreshToken = jwt.sign({
				userId : userId
			},
			secret,
			{
				expiresIn : '14d'
			})

			// 유저 추가 작성
			sql = 'UPDATE Users SET refreshToken=? WHERE userId=?'
			let query = db.query(sql, [refreshToken, userId], (err, result) => {
				if (err) { res.status(400).json({ success: false, message: err }) }
				let sql = 'SELECT * FROM Users WHERE Users.userId = ?'
				db.query(sql, [userId], (err, result) => {
					if (err) return res.status(400).send(err)
					res.status(201).header('Token', accessToken).json(result)
				})
			})
		})
	})
}

// 회원가입
let register = async function(req, res) {
	const userId = req.body.userId
	const nickName = req.body.nickName
	const password = req.body.password
	const modifiedPw = await bcrypt.hash(password, 8)

	// 회원가입 절차가 진행되는 중에 동일 아이디/닉네임이 생겼을 수 있으니 중복 확인 한 번 더 진행
	var sql = 'SELECT * FROM Users WHERE (Users.userId = ?) OR (Users.nickName = ?)'
	let query = db.query(sql, [userId, nickName], (err, result) => {
		if (err) return res.status(400).send({err})
		if (result.length != 0) return res.status(400).json({ success: false, message: "Unavailable userId or nickName" })

		// 중복 확인에서 문제가 없었다면 유저 추가
		// 가입과 동시에 로그인이 된다는 것을 전제로 하기 때문에 jwt 발급
		const accessToken = jwt.sign({
			userId : userId
		},
		secret,
		{
			expiresIn : '2h'
		})

		const refreshToken = jwt.sign({
			userId : userId
		},
		secret,
		{
			expiresIn : '14d'
		})

		// 유저 추가 작성
		sql = 'INSERT INTO Users (userId, nickName, password, refreshToken) VALUES (?, ?, ?, ?)'
		let query = db.query(sql, [userId, nickName, modifiedPw, refreshToken], (err, result) => {
			if (err) return res.status(400).json({ success: false, message: err })
			let sql = 'SELECT * FROM Users WHERE Users.userId = ?'
			db.query(sql, [userId], (err, userResult) => {
				if (err) return res.status(400).send(err)
				res.status(201).header('Token', accessToken).json(userResult)
			})
		})
	})
}

// 유저 차단 여부 변경
let changeUserBlock = async function(req, res) {
	const userId = req.body.userId
	const isBlocked = req.body.isBlocked
	const isAdmin = req.body.isAdmin

	if (isAdmin == 0) {
		// 일반 유저
		const auth = req.get('Authorization')
		if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })
		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			if ((err) || (tokenUserId != userId)) return res.status(404).json({ success: false, message: "Invalid token" })

			var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
			let query = db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).json({ success: false, message: err })
				if (!result.length) {
					// 계정이 없는 userId
					res.status(400).json({ success: false, message: "Unavailable userId" })
					return
				}
				// 이미 사용 중인 userId
				var sql = 'UPDATE Users SET isBlocked=? WHERE userId=?'
				let query = db.query(sql, [isBlocked, userId], (err, result) => {
					if (err) {res.status(400).json({ success: false, message: err })}
					let sql = 'SELECT * FROM Users'
					db.query(sql, (err, result) => {
						if (err) return res.status(400).send(err)
						res.status(201).send(result)
					})
				})
			})
		})
	} else {
		// 어드민 유저
		var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
		let query = db.query(sql, [userId], (err, result) => {
			if (err) return res.status(400).json({ success: false, message: err })
			console.log(result)
			if (!result.length) {
				// 계정이 없는 userId
				res.status(400).json({ success: false, message: "Unavailable userId" })
				return
			}
			// 이미 사용 중인 userId
			var sql = 'UPDATE Users SET isBlocked=? WHERE userId=?'
			let query = db.query(sql, [isBlocked, userId], (err, result) => {
				if (err) {res.status(400).json({ success: false, message: err })}
				console.log(result)
				let sql = 'SELECT * FROM Users'
				db.query(sql, (err, result) => {
					if (err) return res.status(400).send(err)
					res.status(201).send(result)
				})
			})
		})
	}
}

// 이메일 인증 여부 변경
let changeEmailVerification = async function(req, res) {
	const userId = req.body.userId
	const isEmailVerified = req.body.isEmailVerified
	const isAdmin = req.body.isAdmin

	if (isAdmin == 0) {
		// 일반 유저
		const auth = req.get('Authorization')
		if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })

		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			if ((err) || (tokenUserId != userId)) return res.status(404).json({ success: false, message: "Invalid token" })

			var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
			let query = db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).json({ success: false, message: err })
				if (!result.length) {
					// 계정이 없는 userId
					res.status(400).json({ success: false, message: "Unavailable userId" })
					return
				}
				// 이미 사용 중인 userId
				var sql = 'UPDATE Users SET isEmailVerified=? WHERE userId=?'
				let query = db.query(sql, [isEmailVerified, userId], (err, result) => {
					if (err) return res.status(400).json({ success: false, message: err })
					res.status(201).json({ success: true, message: "Successfully isEmailVerified Changed" })
				})
			})
		})
	} else {
		// 어드민 유저
		var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
		let query = db.query(sql, [userId], (err, result) => {
			if (err) return res.status(400).json({ success: false, message: err })

			if (!result.length) {
				// 계정이 없는 userId
				res.status(400).json({ success: false, message: "Unavailable userId" })
				return 
			}
			// 이미 사용 중인 userId
			var sql = 'UPDATE Users SET isEmailVerified=? WHERE userId=?'
			let query = db.query(sql, [isEmailVerified, userId], (err, result) => {
				if (err) return res.status(400).json({ success: false, message: err })
				res.status(201).json({ success: true, message: "Successfully isEmailVerified Changed" })
			})
		})
	}
}

// refreshToken 발급 및 저장
let refreshAccessToken = async function (req, res) {
	const userId = req.body.userId
	const auth = req.get('Authorization')

	if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })
	const userToken = auth.split(' ')[1]
	jwt.verify(userToken, secret, (err, encode) => {
		const tokenUserId = encode["userId"]
		if ((err) || (tokenUserId != userId)) return res.status(404).json({ success: false, message: "Invalid token" })

		const accessToken = jwt.sign({
			userId : userId
		},
		secret,
		{
			expiresIn : '2h'
		})
		const refreshToken = jwt.sign({
			userId : userId
		},
		secret,
		{
			expiresIn : '14d'
		})
		
		// 유저 추가 작성
		sql = 'UPDATE Users SET refreshToken=? WHERE userId=?'
		let query = db.query(sql, [refreshToken, userId], (err, result) => {
			if (err) { res.status(400).json({ success: false, message: err }) }
			let sql = 'SELECT * FROM Users WHERE Users.userId = ?'
			db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).send(err)
				res.status(201).header('Token', accessToken).json(result)
			})
		})
	})
}

// 닉네임 변경
let changeNickname = async function(req, res) {
	const userId = req.body.userId
	const nickName = req.body.nickName
	const isAdmin = req.body.isAdmin

	if (isAdmin == 0) {
		// 일반 유저
		const auth = req.get('Authorization')
		if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })
		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			if ((err) || (tokenUserId != userId)) return res.status(404).json({ success: false, message: "Invalid token" })

			var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
			let query = db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).json({ success: false, message: err })

				if (!result.length) {
					// 계정이 없는 userId
					res.status(400).json({ success: false, message: "Unavailable userId" })
					return
				}
				var sql = 'SELECT * FROM Users WHERE (Users.nickName = ?)'
				let query = db.query(sql, [nickName], (err, result) => {
					if (err) return res.status(400).json({ success: false, message: err })

					if (result.length) {
						// 이미 사용 중인 userId
						res.status(400).json({ success: false, message: "Unavailable nickName" })
						return
					}
					// 가능한 userId
					var sql = 'UPDATE Users SET nickName=? WHERE userId=?'
					let query = db.query(sql, [nickName, userId], (err, result) => {
						if (err) return res.status(400).json({ success: false, message: err })
						
						let sql = 'SELECT * FROM Users WHERE Users.userId = ?'
						db.query(sql, [userId], (err, result) => {
							if (err) return res.status(400).send(err)
							res.status(201).json(result)
						})
					})
				})
			})
		})
	} else {
		// 어드민 유저
		var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
		let query = db.query(sql, [userId], (err, result) => {
			if (err) return res.status(400).json({ success: false, message: err })

			if (!result.length) {
				// 계정이 없는 userId
				res.status(400).json({ success: false, message: "Unavailable userId" })
				return
			}
			var sql = 'SELECT * FROM Users WHERE (Users.nickName = ?)'
			let query = db.query(sql, [nickName], (err, result) => {
				if (err) return res.status(400).json({ success: false, message: err })
				
				if (result.length) {
					// 이미 사용 중인 userId
					res.status(400).json({ success: false, message: "Unavailable nickName" })
					return
				}
				// 가능한 userId
				var sql = 'UPDATE Users SET nickName=? WHERE userId=?'
				let query = db.query(sql, [nickName, userId], (err, result) => {
					if (err) return res.status(400).json({ success: false, message: err })
					
					let sql = 'SELECT * FROM Users WHERE Users.userId = ?'
					db.query(sql, [userId], (err, result) => {
						if (err) return res.status(400).send(err)
						res.status(201).json(result)
					})
				})
			})
		})
	}
}

// 비밀번호 변경
let changePassword = async function(req, res) {
	const userId = req.body.userId
	const newPw = req.body.newPw
	const modifiedPw = await bcrypt.hash(newPw, 8)
	const isAdmin = req.body.isAdmin

	if (isAdmin == 0) {
		// 일반 유저
		const auth = req.get('Authorization')
		if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })
		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			if ((err) || (tokenUserId != userId)) return res.status(404).json({ success: false, message: "Invalid token" })

			var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
			let query = db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).json({ success: false, message: err })

				if (!result.length) {
					// 계정이 없는 userId
					res.status(400).json({ success: false, message: "Unavailable userId" })
					return 
				}
				// 이미 사용 중인 userId
				var sql = 'UPDATE Users SET password=? WHERE userId=?'
				let query = db.query(sql, [modifiedPw, userId], (err, result) => {
					if (err) return res.status(400).json({ success: false, message: err })

					let sql = 'SELECT * FROM Users WHERE Users.userId = ?'
					db.query(sql, [userId], (err, result) => {
						if (err) return res.status(400).send(err)
						res.status(201).json(result)
					})
				})
			})
		})
	} else {
		// 어드민 유저
		var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
		let query = db.query(sql, [userId], (err, result) => {
			if (err) return res.status(400).json({ success: false, message: err })
			
			if (!result.length) {
				// 계정이 없는 userId
				res.status(400).json({ success: false, message: "Unavailable userId" })
				return 
			}
			// 이미 사용 중인 userId
			var sql = 'UPDATE Users SET password=? WHERE userId=?'
			let query = db.query(sql, [modifiedPw, userId], (err, result) => {
				if (err) return res.status(400).json({ success: false, message: err })
				
				let sql = 'SELECT * FROM Users WHERE Users.userId = ?'
				db.query(sql, [userId], (err, result) => {
					if (err) return res.status(400).send(err)
					res.status(201).json(result)
				})
			})
		})
	}
}

// 랜덤하게 인증번호 생성
var generateRandom = function (min, max) {
	var ranNum = Math.floor(Math.random()*(max-min+1)) + min
	return ranNum
}

// 인증번호 전송 (비밀번호 변경 시)
let sendEmailVerificationForPw = async function(req, res) {
	const userId = req.body.userId

	var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
	let query = db.query(sql, [userId], (err, result) => {
		if (err) return res.status(400).json({ success: false, message: err })
		
		if (!result.length) {
			// 계정이 없는 userId
			res.status(402).json({ success: false, message: "Unavailable userId" })
			return 
		}
		// 이미 사용 중인 userId
		const number = generateRandom(111111,999999)
		const content = `인증번호는 ${ number } 입니다`

		let transporter = nodemailer.createTransport({
			host: "smtp.gmail.com",
			secure: true,
			auth: {
				user: emailId,
				pass: emailPw
			}
		})
		
		let mailOptions = {
			from: emailId,
			to: userId,
			subject: "인증번호 전송",
			text: content
		}

		//전송 시작
		transporter.sendMail(mailOptions, function(error, info){
			if (error) return res.status(400).json({ success: false, message: error })
			//전송 완료
			console.log("Finish sending email : " + info.response)
			res.status(201).json({ success: true, message: number })       
			transporter.close()
		})
	})
}

// 이메일 인증 시 인증했음을 저장
let emailVerified = async function(req, res) {
	const userId = req.body.userId

	var sql = 'UPDATE Users SET isEmailVerified=1 WHERE userId=?'
	let query = db.query(sql, [userId], (err, result) => {
		if (err) return res.status(400).json({ success: false, message: err })
		
		res.status(201).json({ success: true, message: "Successfully Email Verified" })
	})
}

// 닉네임 사용가능 여부 확인
let nickNameValidation = async function(req, res) {
	const nickName = req.body.nickName

	var sql = 'SELECT * FROM Users WHERE (Users.nickName = ?)'
	let query = db.query(sql, [nickName], (err, result) => {
		if (err) return res.status(400).json({ success: false, message: err })
		
		if (result.length) {
			// 이미 사용 중인 userId
			res.status(400).json({ success: false, message: "Unavailable nickName" })
			return
		}
		// 가능한 userId
		res.status(201).json({ success: true, message: "Available nickName" })
	})
}

// 아이디 사용가능 여부 확인
let userIdValidation = async function(req, res) {
	const userId = req.body.userId

	var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
	let query = db.query(sql, [userId], (err, result) => {
		if (err) return res.status(400).json({ success: false, message: err })
		
		if (result.length) {
			// 이미 사용 중인 userId
			res.status(400).json({ success: false, message: "Unavailable userId" })
			return
		}
		// 가능한 userId
		res.status(201).json({ success: true, message: "Available userId" })
	})
}

// 인증번호 전송 (회원가입 시)
let sendEmailverificationForRegister = async function(req, res) {
	const userId = req.body.userId

	var sql = 'SELECT * FROM Users WHERE (Users.userId = ?)'
	let query = db.query(sql, [userId], (err, result) => {
		if (err) return res.status(400).json({ success: false, message: err })
		
		if (result.length) {
			// 이미 사용 중인 userId
			res.status(400).json({ success: false, message: "Unavailable userId" })
			return
		}
		// 가능한 userId
		const number = generateRandom(111111,999999)
		const content = `인증번호는 ${ number } 입니다`

		let transporter = nodemailer.createTransport({
			host: "smtp.gmail.com",
			secure: true,
			auth: {
				user: emailId,
				pass: emailPw
			}
		})
		
		let mailOptions = {
			from: emailId,
			to: userId,
			subject: "인증번호 전송",
			text: content
		}

		//전송 시작!
		transporter.sendMail(mailOptions, function(error, info){
			if (error) return res.status(400).json({ success: false, message: error })
			//전송 완료
			console.log("Finish sending email : " + info.response)
			res.status(201).json({ success: true, message: number })
			transporter.close()
		})
	})
}

module.exports = {
  loadUsers: loadUsers,
  withdraw: withdraw,
  setFcmToken: setFcmToken,
  logIn: logIn,
  register:register,
  changeUserBlock: changeUserBlock,
  changeEmailVerification: changeEmailVerification,
  changeNickname: changeNickname,
  changePassword: changePassword,
  sendEmailVerificationForPw: sendEmailVerificationForPw,
  emailVerified: emailVerified,
  nickNameValidation: nickNameValidation,
  userIdValidation: userIdValidation,
  sendEmailverificationForRegister: sendEmailverificationForRegister,
  refreshAccessToken: refreshAccessToken,
  autoLogIn: autoLogIn
}