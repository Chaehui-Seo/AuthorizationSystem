const express = require('express')
const router = express.Router()
const controller = require('../service/blockService')

router.get("/block-messages", controller.loadMessages)
router.post('/block-messages/create', controller.createMessage)
router.put('/block-messages/response', controller.sendResponse)
router.delete("/block-messages/delete", controller.deleteMessages)

module.exports = router