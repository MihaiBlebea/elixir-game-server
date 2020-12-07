export default class Bridge 
{
    address = "ws://localhost:4000/ws"

    connection = null

    connect()
    {
        if (this.connection !== null) { 
            return Promise.resolve(this.connection)
        }

        return new Promise((resolve, reject)=> {
            this.connection = new WebSocket(this.address)

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

    createGame(gameName, playerCount = 1) {
        this.submit({
            type: "game_create",
            player_count: playerCount,
            game_name: gameName
        })
    }

    joinGame(gameId, playerName) {
        this.submit({
            type: "game_join",
            game_id: gameId,
            player_name: playerName
        })
    }

    movePlayer(gameId, playerId, x, y) {
        this.submit({
            type: "player_move",
            game_id: gameId,
            player_id: playerId,
            x,
            y
        })
    }
}