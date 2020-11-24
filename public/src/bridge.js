export default class Bridge 
{
    address = "ws://localhost:4000/ws"

    connection = null

    connect(gameId)
    {
        if (this.connection !== null) { 
            return Promise.resolve(this.connection)
        }

        return new Promise((resolve, reject)=> {
            this.connection = new WebSocket(this.address + '/' + gameId)

            this.connection.onopen = ()=> {
                console.log("connected")
                resolve(this.connection)
            }

            this.connection.onerror = (e)=> {
                reject(e)
            }
        })
    }

    submit(data) {  
        if (this.connection === null) {
            return null
        }    

        this.connection.send(JSON.stringify(data))
    }
}