const express = require('express')
const router = express.Router()

const controller = require('../service/userService')

router.get("/users", controller.loadUsers)

router.post('/users/create', controller.register)

router.post('/users/login', controller.logIn)

router.post('/users/auto-login', controller.autoLogIn)

router.post('/users/refresh-access-token', controller.refreshAccessToken)

router.post('/users/email-verification-register', controller.sendEmailverificationForRegister)

router.post('/users/userid-validation', controller.userIdValidation)

router.post('/users/nickname-validation', controller.nickNameValidation)

router.post('/users/email-verification-password', controller.sendEmailVerificationForPw)

router.post('/users/change-password', controller.changePassword)

router.post('/users/change-nickname', controller.changeNickname)

router.post('/users/change-email-verification', controller.changeEmailVerification)

router.post('/users/change-user-block', controller.changeUserBlock)

router.put('/users/email-verification-checked', controller.emailVerified)

router.put('/users/set-fcm-token', controller.setFcmToken)

router.delete("/users/withdrawal", controller.withdrawl)

module.exports = router