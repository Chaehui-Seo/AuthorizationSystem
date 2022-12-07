const jwt = require('jsonwebtoken')
const db = require('../db/db')
const { secret } = require('../config/config')

// 차단 사유에 대한 메세지 생성
let createMessage = async function(req, res) {
	const fromUser = req.body.fromUser
	const toUser = req.body.toUser
	const content = req.body.content
	var sql = 'INSERT INTO BlockMessages (fromUser, toUser, content) VALUES (?, ?, ?)'
	let query = db.query(sql, [fromUser, toUser, content], (err, result) => {
		if (err) return res.status(400).send({err})
		res.status(201).json({ success: true, message: "Successfully message sent" })
	})
}

// 차단 사유 메세지에 대한 반응 (이모지 반응) 전송
let sendResponse = async function(req, res) {
	const id = req.body.id
	const userId = req.body.userId
	const response = req.body.response
	const auth = req.get('Authorization')
	if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })
	const userToken = auth.split(' ')[1]
	jwt.verify(userToken, secret, (err, encode) => {
		if(err) return res.status(404).json({ success: false, message: "Invalid token" }) 
		const tokenUserId = encode["userId"]
		if (tokenUserId != userId) return res.status(404).json({ success: false, message: "Invalid token" })
		var sql = 'UPDATE BlockMessages SET response=? WHERE id=?'
		let query = db.query(sql, [response, id], (err, result) => {
			if (err) return res.status(400).send({err})
			res.status(201).json({ success: true, message: "Successfully edited" })
		})
	})
}

// 차단 사유 메세지 조회
let loadMessages = async function(req, res) {
	var userId = req.query.userId
	const auth = req.get('Authorization')

	if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })
	const userToken = auth.split(' ')[1]
	jwt.verify(userToken, secret, (err, encode) => {
		if(err) return res.status(404).json({ success: false, message: "Invalid token" })
		const tokenUserId = encode["userId"]
		if (tokenUserId != userId) return res.status(404).json({ success: false, message: "Invalid token" })
		let sql = 'SELECT * FROM BlockMessages WHERE BlockMessages.toUser = ?'
		db.query(sql, [userId], (err, result) => {
			if (err) return res.status(400).send(err)
			res.status(201).send(result)
		})
	})
}

// 차단 사유 메세지 삭제
let deleteMessages = async function(req, res) {
	const toUser = req.body.toUser
	var sql = 'DELETE FROM BlockMessages WHERE BlockMessages.toUser = ?'
	let query = db.query(sql, [toUser], (err, result) => {
		if (err) return res.status(400).send({err})
		res.status(201).json({ success: true, message: "Successfully deleted" })
	})
}

module.exports = {
	createMessage: createMessage,
	sendResponse: sendResponse,
	loadMessages: loadMessages,
	deleteMessages: deleteMessages
}