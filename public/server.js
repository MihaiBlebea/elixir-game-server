const express = require('express')
const app = express()

app.use(express.static('./'))

app.get('/', (req, res) => {
    console.log('Should send the file')
    res.sendFile('index.html')
})

let server = app.listen(3000, () => {
    console.log(`server running at port http://localhost/${server.address().port}`)
})