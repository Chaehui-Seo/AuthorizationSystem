const jwt = require('jsonwebtoken')
const db = require('../db/db')
const { secret } = require('../config/config')

// 메모 생성
// 어드민 유저의 경우, 타인의 메모도 생성 가능
let createMemo = async function(req, res) {
	const color = req.body.color
	const content = req.body.content
	const userId = req.body.userId
	const isAdmin = req.body.isAdmin

	if (isAdmin == 0 ) {
		// 일반 유저
		const auth = req.get('Authorization')
		if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })

		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			if(err) return res.status(404).json({ success: false, message: "Invalid token" })

			const tokenUserId = encode["userId"]
			if (tokenUserId != userId) return res.status(404).json({ success: false, message: "Invalid token" })
			var sql = 'INSERT INTO Memos (color, content, userId) VALUES (?, ?, ?)'
			let query = db.query(sql, [color, content, userId], (err, result) => {
				if (err) return res.status(404).send({err})

				let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
				db.query(sql, [userId], (err, result) => {
					if (err) return res.status(400).send(err)
					res.status(201).send(result)
				})
			})
		})
	} else {
		// 어드민 유저
		var sql = 'INSERT INTO Memos (color, content, userId) VALUES (?, ?, ?)'
		let query = db.query(sql, [color, content, userId], (err, result) => {
			if (err) return res.status(400).send({err})

			let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
			db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).send(err)
				res.status(201).send(result)
			})
		})
	}
}

// 메모 수정
// 어드민 유저의 경우, 타인의 메모도 수정 가능
let editMemo = async function(req, res) {
	const id = req.body.id
	const userId = req.body.userId
	const color = req.body.color
	const content = req.body.content
	const isAdmin = req.body.isAdmin

	if (isAdmin == 0 ){
		// 일반 유저
		const auth = req.get('Authorization')
		if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })

		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			if ((err) || (tokenUserId != userId)) return res.status(404).json({ success: false, message: "Invalid token" })

			var sql = 'UPDATE Memos SET color=?, content=? WHERE id=?'
			let query = db.query(sql, [color, content, id], (err, result) => {
				if (err) return res.status(400).send({err})

				let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
				db.query(sql, [userId], (err, result) => {
					if (err) return res.status(400).send(err)
					res.status(201).send(result)
				})
			})
		})
	} else {
		// 어드민 유저
		var sql = 'UPDATE Memos SET color=?, content=? WHERE id=?'
		let query = db.query(sql, [color, content, id], (err, result) => {
			if (err) return res.status(400).send({err})

			let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
			db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).send(err)
				res.status(201).send(result)
			})
		})
	}
}

// 메모 삭제
// 어드민 유저의 경우, 타인의 메모도 삭제 가능
let deleteMemo = async function(req, res) {
	const id = req.body.id
	const userId = req.body.userId
	const isAdmin = req.body.isAdmin

	if (isAdmin == 0 ){
		// 일반유저
		const auth = req.get('Authorization')
		if (auth != null) return res.status(404).json({ success: false, message: "Invalid token" })

		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			if ((err) || (tokenUserId != userId)) return res.status(404).json({ success: false, message: "Invalid token" })

			var sql = 'DELETE FROM Memos WHERE Memos.id = ?'
			let query = db.query(sql, [id], (err, result) => {
				if (err) return res.status(400).send({err})

				let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
				db.query(sql, [userId], (err, result) => {
					if (err) return res.status(400).send(err)
					res.status(201).send(result)
				})
			})
		})
	} else {
		// 어드민 유저
		var sql = 'DELETE FROM Memos WHERE Memos.id = ?'
		let query = db.query(sql, [id], (err, result) => {
			if (err) return res.status(400).send({err})
			
			let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
			db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).send(err)
				res.status(201).send(result)
			})
		})
	}
}

// 메모 조회
// 어드민 유저의 경우, 타인의 메모 조회 가능 (어드민 페이지를 통해서 접근 가능)
let loadMemos = async function(req, res) {
	var userId = req.query.userId
	var isAdmin = req.query.isAdmin
	const auth = req.get('Authorization')

	if (isAdmin == 0) {
		// 일반 유저
		if (auth == null) return res.status(404).json({ success: false, message: "Invalid token" })
		const userToken = auth.split(' ')[1]
		jwt.verify(userToken, secret, (err, encode) => {
			const tokenUserId = encode["userId"]
			if ((err || (tokenUserId != userId))) return res.status(404).json({ success: false, message: "Invalid token" })
			
			let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
			db.query(sql, [userId], (err, result) => {
				if (err) return res.status(400).send(err)
				res.status(201).send(result)
			})
		})
	} else {
		// 어드민 유저
		let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
		db.query(sql, [userId], (err, result) => {
			if (err) return res.status(400).send(err)
			res.status(201).send(result)
		})
	}
}

module.exports = {
  createMemo: createMemo,
  editMemo: editMemo,
  deleteMemo: deleteMemo,
  loadMemos: loadMemos
}