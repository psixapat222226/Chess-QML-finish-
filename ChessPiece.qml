import QtQuick 2.15

Image {
    id: piece

    property int pieceX: 0
    property int pieceY: 0

    MouseArea {
        anchors.fill: parent
        drag.target: parent

        onPressed: {
            piece.z = 10

            let legalMoves = chessEngine.getLegalMovesForPiece(pieceX, pieceY)
            if (legalMoves.length > 0) {
                moveIndicators.fromX = pieceX
                moveIndicators.fromY = pieceY
                moveIndicators.legalMoves = legalMoves
                moveIndicators.visible = true
            }
        }

        onReleased: {
            let newX = Math.floor((piece.x + piece.width / 2) / cellSize)
            let newY = Math.floor((piece.y + piece.height / 2) / cellSize)

            newX = Math.max(0, Math.min(7, newX))
            newY = Math.max(0, Math.min(7, newY))

            if (chessEngine.processMove(pieceX, pieceY, newX, newY)) {
                moveIndicators.visible = false
            } else {
                piece.x = pieceX * cellSize
                piece.y = pieceY * cellSize
            }

            piece.z = 1
        }
    }
}
