const jwt = require('jsonwebtoken')

const db = require('../db/db')

const { secret } = require('../config/config')



let createMemo = async function(req, res) {
	const color = req.body.color
	const content = req.body.content
	const userId = req.body.userId

	const isAdmin = req.body.isAdmin

	if (isAdmin == 0 ){
		const auth = req.get('Authorization')

		if (auth == null) {
			res.status(404).json({ success: false, message: "Invalid token" })
		} else {
		    const userToken = auth.split(' ')[1]

		    jwt.verify(userToken, secret, (err, encode) => {
		    	if(err) { res.status(404).json({ success: false, message: "Invalid token" }) }
				else {
					const tokenUserId = encode["userId"]
					if (tokenUserId == userId) {
						var sql = 'INSERT INTO Memos (color, content, userId) VALUES (?, ?, ?)'
						let query = db.query(sql, [color, content, userId], (err, result) => {
							if (err) {res.status(404).send({err})}
							console.log(result)
							let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
							db.query(sql, [userId], (err, result) => {
								if (err) {
									res.status(400).send(err)
								}
								res.status(201).send(result)
							})
						})
					} else {
						res.status(404).json({ success: false, message: "Invalid token" })
					}
				}
			})
		}
	} else {
		var sql = 'INSERT INTO Memos (color, content, userId) VALUES (?, ?, ?)'
		let query = db.query(sql, [color, content, userId], (err, result) => {
			if (err) {res.status(400).send({err})}
			console.log(result)
			let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
			db.query(sql, [userId], (err, result) => {
				if (err) {
					res.status(400).send(err)
				}
				res.status(201).send(result)
			})
		})
	}
}

let editMemo = async function(req, res) {
	const id = req.body.id
	const userId = req.body.userId
	const color = req.body.color
	const content = req.body.content

	const isAdmin = req.body.isAdmin

	if (isAdmin == 0 ){
		const auth = req.get('Authorization')

		if (auth == null) {
			res.status(404).json({ success: false, message: "Invalid token" })
		} else {
		    const userToken = auth.split(' ')[1]

		    jwt.verify(userToken, secret, (err, encode) => {
		    	if(err) { res.status(404).json({ success: false, message: "Invalid token" }) }
				else {
					const tokenUserId = encode["userId"]
					if (tokenUserId == userId) {
						var sql = 'UPDATE Memos SET color=?, content=? WHERE id=?'
						let query = db.query(sql, [color, content, id], (err, result) => {
							if (err) {res.status(400).send({err})}
							console.log(result)
							let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
							db.query(sql, [userId], (err, result) => {
								if (err) {
									res.status(400).send(err)
								}
								res.status(201).send(result)
							})
						})
					} else {
						res.status(404).json({ success: false, message: "Invalid token" })
					}
				}
			})
		}
	} else {
		var sql = 'UPDATE Memos SET color=?, content=? WHERE id=?'
		let query = db.query(sql, [color, content, id], (err, result) => {
			if (err) {res.status(400).send({err})}
			console.log(result)
			let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
			db.query(sql, [userId], (err, result) => {
				if (err) {
					res.status(400).send(err)
				}
				res.status(201).send(result)
			})
		})
	}
}

let deleteMemo = async function(req, res) {
	const id = req.body.id
	const userId = req.body.userId

	const isAdmin = req.body.isAdmin

	if (isAdmin == 0 ){
		const auth = req.get('Authorization')

		if (auth == null) {
			res.status(404).json({ success: false, message: "Invalid token" })
		} else {
		    const userToken = auth.split(' ')[1]

		    jwt.verify(userToken, secret, (err, encode) => {
		    	if(err) { res.status(404).json({ success: false, message: "Invalid token" }) }
				else {
					const tokenUserId = encode["userId"]
					if (tokenUserId == userId) {
						var sql = 'DELETE FROM Memos WHERE Memos.id = ?'
						let query = db.query(sql, [id], (err, result) => {
							if (err) {res.status(400).send({err})}
							console.log(result)
							let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
							db.query(sql, [userId], (err, result) => {
								if (err) {
									res.status(400).send(err)
								}
								console.log(result)
								res.status(201).send(result)
							})
						})
					} else {
						res.status(404).json({ success: false, message: "Invalid token" })
					}
				}
			})
		}
	} else {
		var sql = 'DELETE FROM Memos WHERE Memos.id = ?'
		let query = db.query(sql, [id], (err, result) => {
			if (err) {res.status(400).send({err})}
			console.log(result)
			let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
			db.query(sql, [userId], (err, result) => {
				if (err) {
					res.status(400).send(err)
				}
				res.status(201).send(result)
			})
		})
	}
}

let loadMemos = async function(req, res) {
	var userId = req.query.userId
	var isAdmin = req.query.isAdmin

	const auth = req.get('Authorization')

	if (isAdmin == 0) {
		if (auth == null) {
			res.status(404).json({ success: false, message: "Invalid token" })
		} else {
		    const userToken = auth.split(' ')[1]

		    jwt.verify(userToken, secret, (err, encode) => {
		    	if(err) { res.status(404).json({ success: false, message: "Invalid token" }) }
				else {
					const tokenUserId = encode["userId"]
					if (tokenUserId == userId) {
						let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
						db.query(sql, [userId], (err, result) => {
							if (err) {
								res.status(400).send(err)
							}
							console.log(result)
							res.status(201).send(result)
						})
					} else {
						res.status(404).json({ success: false, message: "Invalid token" })
					}
				}
			})
		}
	} else {
		let sql = 'SELECT * FROM Memos WHERE Memos.userId = ?'
		db.query(sql, [userId], (err, result) => {
			if (err) {
				res.status(400).send(err)
			}
			console.log(result)
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