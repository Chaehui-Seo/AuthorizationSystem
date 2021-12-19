const express = require('express')
const router = express.Router()

const controller = require('../service/memoService')

router.get("/memos", controller.loadMemos)

router.post('/memos/create', controller.createMemo)

router.put('/memos/edit', controller.editMemo)

router.delete("/memos/delete", controller.deleteMemo)

module.exports = router