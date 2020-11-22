export default class Bridge 
{
    socket = null

    address = "ws://localhost:4000/ws/chat"

    setupSocket(callback) {
        this.socket = new WebSocket(this.address)

        this.socket.addEventListener("message", (event) => {
            // console.log("We got a message", event.data)
            // console.log(event.data)
            callback(JSON.parse(JSON.parse(JSON.stringify(event.data))))
        })

        this.socket.addEventListener("close", () => {
            this.setupSocket()
        })
    }

    submit(data) {        
        this.socket.send(
            JSON.stringify({
                data: data,
            })
        )
    }
}

// module.exports = Bridge