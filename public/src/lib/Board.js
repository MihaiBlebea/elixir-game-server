const Box          = require('./Box')
const BrickWall    = require('./BrickWall')
const ConcreteWall = require('./ConcreteWall')
const Door         = require('./Door')
const Enemy = require('./Enemy')

class Board 
{
    _boxSize = 40

    _boardSize = 20

    _board = {}

    constructor(boardSize)
    {
        if (boardSize !== undefined) {
            this._boardSize = boardSize
        }

        this._generateBoard()
        this._generateLevel()
        this._generateEnemies()
    }

    addEntity(entity, x, y)
    {
        this._board[x][y].addEntity(entity)
    }

    getBoxAt(x, y) {
        return this._board[x][y]
    }

    getBoard()
    {
        return this._board
    }

    getBoardSize()
    {
        return this._boardSize
    }

    getBoxSize()
    {
        return this._boxSize
    }

    getRandomEmptyBox()
    {
        let empty = this._emptyBoxes()
        let index = this._getRandomInt(empty.length)

        return empty[index]
    }

    _generateBoard() 
    {
        for (let x = 0; x < this._boardSize; x++) {
            for (let y = 0; y < this._boardSize; y++) {
                if (this._board[x] === undefined) {
                    this._board[x] = {}
                }

                let box = new Box()
                if (x === 0 || y === 0 || x === this._boardSize - 1 || y === this._boardSize - 1) {
                    box.addEntity(new ConcreteWall())
                }
                
                if (x % 2 === 0 && y % 2 == 0) {
                    box.addEntity(new ConcreteWall())
                }

                this._board[x][y] = box
            }
        }
    }

    _generateLevel()
    {
        let emptyBoxes = this._emptyBoxes()
        let count = Math.floor(emptyBoxes.length / 2)

        for (let i = 0; i < count; i++) {
            let index    = this._getRandomInt(emptyBoxes.length)
            let position = emptyBoxes[index]

            this._board[position.x][position.y].addEntity(new BrickWall())

            if (i === count - 1) {
                this._board[position.x][position.y].addEntity(new Door())
            }

            emptyBoxes.splice(index, 1)
        }
    }

    _generateEnemies()
    {
        for (let i = 0; i < 1; i++) {
            let {x, y} = this.getRandomEmptyBox()
            this.addEntity(new Enemy(), x, y)
        }
    }

    run()
    {
        while(true) {

        }
    }

    _getRandomInt(max) {
        return Math.floor(Math.random() * max)
    }

    _emptyBoxes()
    {
        let emptyBoxes = []
        for (let x = 0; x < this._boardSize; x++) {
            for (let y = 0; y < this._boardSize; y++) {
                if (this._board[x][y].isEmpty() && !['1-2', '2-1'].includes(`${x}-${y}`)) {
                    emptyBoxes.push({x, y})
                }
            }
        }

        return emptyBoxes
    }
}

module.exports = Board