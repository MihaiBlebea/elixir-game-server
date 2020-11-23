export default class Bridge 
{
    socket = null

    address = "ws://localhost:4000/ws"

    setup(gameId, callback) {
        console.log(this.address + '/' + gameId)
        this.socket = new WebSocket(this.address + '/' + gameId)

        this.socket.addEventListener("message", (event) => {
            callback(JSON.parse(event.data))
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