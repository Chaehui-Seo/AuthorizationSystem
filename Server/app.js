const express = require('express')

const userRouter = require('./routers/user')
const memoRouter = require('./routers/memo')
const blockRouter = require('./routers/block')

const port = process.env.PORT

const app = express()
app.use(express.urlencoded({extended: true}))
app.use(express.json())
app.use(userRouter)
app.use(memoRouter)
app.use(blockRouter)

app.listen(port, () => {
	console.log('Server running on port %d...', port)
})