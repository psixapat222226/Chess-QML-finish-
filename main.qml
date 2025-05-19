import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
Window {
    id: root
    width: 800
    height: 650
    visible: true
    title: "Шахматы"

    property int boardMargin: 20
    property int boardSize: Math.min(width, height - 50) - (2 * boardMargin)
    property int cellSize: boardSize / 8
    property var selectedPiece: null
    property bool inMenu: true
    property bool inSettings: false

    // Функция для преобразования логических координат в визуальные
    function logicalToVisualPos(x, y) {
        return {
            x: x * cellSize,
            y: (7 - y) * cellSize
        }
    }

    // Функция для преобразования визуальных координат в логические
    function visualToLogicalPos(x, y) {
        return {
            x: Math.floor(x / cellSize),
            y: 7 - Math.floor(y / cellSize)
        }
    }

    // Очистка всех индикаторов и выбранных фигур
    function clearAllSelections() {
        moveIndicators.visible = false
        if (selectedPiece !== null) {
            selectedPiece.highlighted = false
        }
        selectedPiece = null
    }

    // Функция для поиска всех кнопок загрузки
    function findAllLoadButtons() {
        var buttons = [];

        if (typeof loadButtonInSettings !== "undefined") {
            buttons.push(loadButtonInSettings);
        }

        return buttons;
    }

    component StyledButton: Item {
        id: buttonContainer
        width: 300
        height: 50

        property string buttonText: "Button"
        property bool isSmall: false
        property int fontSize: isSmall ? 14 : 16
        property bool enabled: true
        property color shadowColor: "#333333"
        property int shadowSize: 4
        property string objectName: ""

        signal clicked()

        Rectangle {
            id: shadow
            width: parent.width
            height: shadowSize
            color: shadowColor
            opacity: 0.5
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }

        Rectangle {
            id: styleButton
            width: parent.width
            height: parent.height - shadowSize
            color: "#828282"
            border.color: "#5A5A5A"
            border.width: 2
            anchors.top: parent.top

            Rectangle {
                width: parent.width - 4
                height: parent.height - 4
                x: 2
                y: 2
                color: mouseArea.pressed && buttonContainer.enabled ? "#5A5A5A" : "#6D6D6D"
                opacity: buttonContainer.enabled ? 1.0 : 0.5

                Text {
                    anchors.centerIn: parent
                    text: buttonContainer.buttonText
                    color: "white"
                    font.pixelSize: buttonContainer.fontSize
                    font.family: "Courier"
                    font.bold: true
                }
            }
        }

        states: State {
            name: "pressed"
            when: mouseArea.pressed && buttonContainer.enabled
            PropertyChanges {
                target: styleButton
                y: shadowSize / 2
            }
            PropertyChanges {
                target: shadow
                height: shadowSize / 2
            }
        }

        transitions: Transition {
            PropertyAnimation {
                properties: "y, height"
                duration: 50
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                if (buttonContainer.enabled) {
                    buttonContainer.clicked()
                }
            }
        }
    }

    Rectangle {
        id: menuScreen
        anchors.fill: parent
        visible: inMenu && !inSettings

        Image {
            anchors.fill: parent
            source: "qrc:/resources/images/fon.png"
            fillMode: Image.PreserveAspectCrop
        }

        ColumnLayout {
            anchors {
                bottom: parent.bottom
                bottomMargin: 100
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 20
            width: 300

            StyledButton {
                Layout.fillWidth: true
                buttonText: "Одиночная игра"
                onClicked: {
                    chessEngine.setGameMode("vsComputer")
                    chessEngine.startNewGame()
                    inMenu = false
                }
            }

            StyledButton {
                Layout.fillWidth: true
                buttonText: "Многопользовательский режим"
                onClicked: {
                    chessEngine.setGameMode("twoPlayers")
                    chessEngine.startNewGame()
                    inMenu = false
                }
            }

            StyledButton {
                Layout.fillWidth: true
                buttonText: "Настройки"
                onClicked: {
                    inSettings = true
                }
            }

            StyledButton {
                buttonText: "Выход из игры"
                Layout.fillWidth: true
                Layout.topMargin: 20
                onClicked: {
                    Qt.quit()
                }
            }
        }

        Rectangle {
            id: infoButton
            width: 40
            height: 40
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 20
            radius: 20
            color: infoMouseArea.containsMouse ? "#775544" : "#664433"
            border.color: "#886644"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "i"
                color: "white"
                font.pixelSize: 24
                font.family: "Courier"
                font.bold: true
            }

            MouseArea {
                id: infoMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    infoDialog.open()
                }
            }
        }
    }

    // Экран настроек
    Rectangle {
        id: settingsScreen
        anchors.fill: parent
        visible: inSettings
        property int selectedSaveIndex: -1
        onSelectedSaveIndexChanged: {

            if (typeof loadButtonInSettings !== "undefined") {
                loadButtonInSettings.enabled = chessEngine.getSavedGames().length > 0 && selectedSaveIndex >= 0;
            }

            if (typeof deleteButtonInSettings !== "undefined") {
                deleteButtonInSettings.enabled = chessEngine.getSavedGames().length > 0 && selectedSaveIndex >= 0;
            }
        }
        onVisibleChanged: {
            if (visible) {
                var currentSaves = chessEngine.getSavedGames();

                if (typeof settingsSavedGamesList !== "undefined") {
                    settingsSavedGamesList.model = null;
                    settingsSavedGamesList.model = currentSaves;
                }

                settingsScreen.selectedSaveIndex = -1;

                if (typeof loadButtonInSettings !== "undefined") {
                    loadButtonInSettings.enabled = currentSaves.length > 0 && settingsScreen.selectedSaveIndex >= 0;
                }

                if (typeof deleteButtonInSettings !== "undefined") {
                    deleteButtonInSettings.enabled = currentSaves.length > 0 && settingsScreen.selectedSaveIndex >= 0;
                }

                if (typeof deleteAllButtonInSettings !== "undefined") {
                    deleteAllButtonInSettings.enabled = currentSaves.length > 0;
                }
            }
        }

        Image {
            anchors.fill: parent
            source: "qrc:/resources/images/fon2.png"
            fillMode: Image.PreserveAspectCrop
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            width: 500

            Text {
                text: "НАСТРОЙКИ"
                font.pixelSize: 32
                font.family: "Courier"
                font.bold: true
                color: "white"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 60

            }

            Rectangle {
                Layout.fillWidth: true
                height: 200

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#35281E" }
                    GradientStop { position: 1.0; color: "#241812" }
                }
                radius: 10
                border.width: 2
                border.color: "#886644"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "Сложность"
                        font.pixelSize: 22
                        font.family: "Courier"
                        font.bold: true
                        color: "#E0C9A6"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Rectangle {
                            id: easyButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 85
                            radius: 8
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: chessEngine.difficulty === 1 ? "#7DE07D" : "#9A9A9A" }
                                GradientStop { position: 1.0; color: chessEngine.difficulty === 1 ? "#4DB74D" : "#6D6D6D" }
                            }
                            border.color: chessEngine.difficulty === 1 ? "#50FF50" : "#777777"
                            border.width: chessEngine.difficulty === 1 ? 3 : 2

                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "♙"
                                    font.pixelSize: 26
                                    font.family: "Arial"
                                    color: "white"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Легкий"
                                    font.pixelSize: 16
                                    font.family: "Courier"
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            MouseArea {
                                id: easyMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: chessEngine.difficulty = 1

                                onEntered: {
                                    if (chessEngine.difficulty !== 1) {
                                        parent.scale = 1.05;
                                    }
                                }
                                onExited: {
                                    if (chessEngine.difficulty !== 1) {
                                        parent.scale = 1.0;
                                    }
                                }
                                onPressed: {
                                    parent.scale = 0.95;
                                }
                                onReleased: {
                                    parent.scale = containsMouse ? 1.05 : 1.0;
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Rectangle {
                            id: mediumButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 85
                            radius: 8
                            // Градиентный фон для кнопки
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: chessEngine.difficulty === 2 ? "#7D9BE0" : "#9A9A9A" }
                                GradientStop { position: 1.0; color: chessEngine.difficulty === 2 ? "#4D77B7" : "#6D6D6D" }
                            }
                            border.color: chessEngine.difficulty === 2 ? "#5080FF" : "#777777"
                            border.width: chessEngine.difficulty === 2 ? 3 : 2

                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "♘"
                                    font.pixelSize: 26
                                    font.family: "Arial"
                                    color: "white"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Средний"
                                    font.pixelSize: 16
                                    font.family: "Courier"
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            MouseArea {
                                id: mediumMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: chessEngine.difficulty = 2

                                onEntered: {
                                    if (chessEngine.difficulty !== 2) {
                                        parent.scale = 1.05;
                                    }
                                }
                                onExited: {
                                    if (chessEngine.difficulty !== 2) {
                                        parent.scale = 1.0;
                                    }
                                }
                                onPressed: {
                                    parent.scale = 0.95;
                                }
                                onReleased: {
                                    parent.scale = containsMouse ? 1.05 : 1.0;
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Rectangle {
                            id: hardButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 85
                            radius: 8
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: chessEngine.difficulty === 3 ? "#E07D7D" : "#9A9A9A" }
                                GradientStop { position: 1.0; color: chessEngine.difficulty === 3 ? "#B74D4D" : "#6D6D6D" }
                            }
                            border.color: chessEngine.difficulty === 3 ? "#FF5050" : "#777777"
                            border.width: chessEngine.difficulty === 3 ? 3 : 2

                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "♕"
                                    font.pixelSize: 26
                                    font.family: "Arial"
                                    color: "white"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Сложный"
                                    font.pixelSize: 16
                                    font.family: "Courier"
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            MouseArea {
                                id: hardMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: chessEngine.difficulty = 3

                                onEntered: {
                                    if (chessEngine.difficulty !== 3) {
                                        parent.scale = 1.05;
                                    }
                                }
                                onExited: {
                                    if (chessEngine.difficulty !== 3) {
                                        parent.scale = 1.0;
                                    }
                                }
                                onPressed: {
                                    parent.scale = 0.95;
                                }
                                onReleased: {
                                    parent.scale = containsMouse ? 1.05 : 1.0;
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: savesSection
                Layout.fillWidth: true
                height: 300
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#35281E" }
                    GradientStop { position: 1.0; color: "#241812" }
                }
                radius: 10
                border.color: "#886644"
                border.width: 2

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "Сохранения"
                        font.pixelSize: 22
                        font.family: "Courier"
                        font.bold: true
                        color: "#E0C9A6"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#262626"
                        radius: 5

                        ListView {
                            id: settingsSavedGamesList
                            anchors.fill: parent
                            anchors.margins: 5
                            model: chessEngine.getSavedGames()
                            clip: true

                            onModelChanged: {
                                if (count === 0) {
                                    settingsScreen.selectedSaveIndex = -1;

                                    if (typeof loadButtonInSettings !== "undefined") {
                                        loadButtonInSettings.enabled = false;
                                    }
                                    if (typeof deleteButtonInSettings !== "undefined") {
                                        deleteButtonInSettings.enabled = false;
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                active: true
                                policy: ScrollBar.AsNeeded
                            }

                            delegate: Rectangle {
                                width: settingsSavedGamesList.width
                                height: 60
                                color: settingsScreen.selectedSaveIndex === index ? "#555555" : "#3D3D3D"
                                radius: 4
                                border.color: settingsScreen.selectedSaveIndex === index ? "#886644" : "#555555"
                                border.width: settingsScreen.selectedSaveIndex === index ? 2 : 1
                                property var gameData: modelData

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        settingsScreen.selectedSaveIndex = index
                                    }
                                }

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 2

                                    Text {
                                        text: parent.parent.gameData && parent.parent.gameData.name ?
                                              parent.parent.gameData.name : "Без названия"
                                        font.pixelSize: 14
                                        font.family: "Courier"
                                        font.bold: true
                                        color: "white"
                                    }

                                    Text {
                                        text: {
                                            var gameData = parent.parent.gameData;
                                            if (!gameData) return "Режим: Неизвестно";

                                            var modeText = gameData.gameMode === "vsComputer" ?
                                                          "Против ИИ" : "Два игрока";

                                            if (gameData.gameMode === "vsComputer") {
                                                var diffText = "";
                                                if (gameData.difficulty === 1) diffText = "Легкий";
                                                else if (gameData.difficulty === 2) diffText = "Средний";
                                                else if (gameData.difficulty === 3) diffText = "Сложный";
                                                else diffText = gameData.difficulty;

                                                modeText += " | " + diffText;
                                            }

                                            return modeText;
                                        }
                                        font.pixelSize: 12
                                        font.family: "Courier"
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        text: "Дата: " + (parent.parent.gameData && parent.parent.gameData.date ?
                                                        parent.parent.gameData.date : "Неизвестно")
                                        font.pixelSize: 12
                                        font.family: "Courier"
                                        color: "#DDDDDD"
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: settingsSavedGamesList.count === 0
                                text: "Нет сохранённых игр"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                font.family: "Courier"
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            id: loadButtonInSettings
                            objectName: "loadButtonInSettings"
                            Layout.fillWidth: true
                            height: 40
                            enabled: chessEngine.getSavedGames().length > 0 && settingsScreen.selectedSaveIndex >= 0
                            color: enabled ? (loadSettingsMouseArea.containsMouse ?
                                    (loadSettingsMouseArea.pressed ? "#4D8F4D" : "#6DAF6D") : "#5D9F5D") : "#444444"
                            radius: 5
                            border.color: enabled ? "#8AFF8A" : "#555555"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "Загрузить"
                                color: "white"
                                font.pixelSize: 14
                                font.family: "Courier"
                                font.bold: true
                            }

                            MouseArea {
                                id: loadSettingsMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (parent.enabled) {
                                        var index = settingsScreen.selectedSaveIndex;
                                        if (index >= 0 && chessEngine.loadGame(index)) {
                                            inSettings = false;
                                            inMenu = false;
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: deleteButtonInSettings
                            Layout.fillWidth: true
                            height: 40
                            enabled: chessEngine.getSavedGames().length > 0 && settingsScreen.selectedSaveIndex >= 0
                            color: enabled ? (deleteSettingsMouseArea.containsMouse ?
                                    (deleteSettingsMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D") : "#444444"
                            radius: 5
                            border.color: enabled ? "#FF8A8A" : "#555555"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "Удалить"
                                color: "white"
                                font.pixelSize: 14
                                font.family: "Courier"
                                font.bold: true
                            }

                            MouseArea {
                                id: deleteSettingsMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (parent.enabled) {
                                        var index = settingsScreen.selectedSaveIndex;
                                        if (index >= 0 && chessEngine.deleteGame(index)) {
                                            settingsScreen.selectedSaveIndex = -1;
                                            settingsSavedGamesList.model = null;
                                            settingsSavedGamesList.model = chessEngine.getSavedGames();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: deleteAllButtonInSettings
                        objectName: "deleteAllSavesButton"
                        Layout.fillWidth: true
                        height: 40
                        enabled: chessEngine.getSavedGames().length > 0
                        color: enabled ? (deleteAllMouseArea.containsMouse ?
                                (deleteAllMouseArea.pressed ? "#8F4D4D" : "#D74D4D") : "#C74D4D") : "#444444"
                        radius: 5
                        border.color: enabled ? "#FF8A8A" : "#555555"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "Удалить все сохранения"
                            color: "white"
                            font.pixelSize: 14
                            font.family: "Courier"
                            font.bold: true
                        }

                        MouseArea {
                            id: deleteAllMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (parent.enabled) {
                                    confirmDeleteAllDialog.open();
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Layout.bottomMargin: 60

                StyledButton {
                    buttonText: "Готово"
                    Layout.fillWidth: true
                    onClicked: {
                        inSettings = false
                    }
                }
            }
        }
    }

    // Игровой экран
    Item {
        anchors.fill: parent
        visible: !inMenu && !inSettings

        Image {
            anchors.fill: parent
            source: "qrc:/resources/images/fon2.png"
            fillMode: Image.PreserveAspectCrop
        }

        Text {
            id: statusText
            text: chessEngine.status
            font.pixelSize: 20
            font.family: "Courier"
            font.bold: true
            color: "white"
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
        }

        component ChessPiece: Image {
            id: piece

            property int pieceX: 0  // Логическая X координата (0-7)
            property int pieceY: 0  // Логическая Y координата (0-7)
            property bool highlighted: false
            property bool isAnimating: xAnimation.running || yAnimation.running

            Rectangle {
                anchors.fill: parent
                color: "yellow"
                opacity: piece.highlighted ? 0.3 : 0
                z: -1
            }
            Component.onCompleted: {
                let pos = logicalToVisualPos(pieceX, pieceY)
                x = pos.x
                y = pos.y
            }

            PropertyAnimation {
                id: xAnimation
                target: piece
                property: "x"
                duration: 200
                easing.type: Easing.OutQuad
            }

            PropertyAnimation {
                id: yAnimation
                target: piece
                property: "y"
                duration: 200
                easing.type: Easing.OutQuad
            }

            PropertyAnimation {
                id: bounceAnimation
                target: piece
                property: "scale"
                from: 1.0
                to: 1.15
                duration: 100
                onStopped: bounceEndAnimation.start()
            }

            PropertyAnimation {
                id: bounceEndAnimation
                target: piece
                property: "scale"
                to: 1.0
                duration: 100
            }

            function animateMove(newX, newY) {
                bounceAnimation.start()

                let newPos = logicalToVisualPos(newX, newY)
                xAnimation.to = newPos.x
                yAnimation.to = newPos.y
                xAnimation.start()
                yAnimation.start()

                pieceX = newX
                pieceY = newY
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (selectedPiece === piece) {
                        clearAllSelections()
                        return
                    }

                    clearAllSelections()
                    let legalMoves = chessEngine.getLegalMovesForPiece(pieceX, pieceY)

                    if (legalMoves.length > 0) {
                        moveIndicators.fromX = pieceX
                        moveIndicators.fromY = pieceY
                        moveIndicators.legalMoves = legalMoves
                        moveIndicators.visible = true

                        piece.highlighted = true
                        selectedPiece = piece
                    }
                }
            }
        }

        Rectangle {
            id: board
            width: boardSize
            height: boardSize
            color: "#FFFFFF"
            anchors {
                centerIn: parent
                verticalCenterOffset: -10
            }

            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: {
                    clearAllSelections()
                }
            }

            Grid {
                anchors.fill: parent
                rows: 8
                columns: 8

                Repeater {
                    model: 64

                    Rectangle {
                        width: cellSize
                        height: cellSize
                        color: {
                            let row = Math.floor(index / 8)
                            let col = index % 8
                            return (row + col) % 2 === 0 ? "#F1D9B5" : "#B98863"
                        }
                    }
                }
            }

            Repeater {
                id: piecesRepeater
                model: chessEngine.getPieces()

                ChessPiece {
                    width: cellSize
                    height: cellSize
                    source: resourceManager.getTexturePath(modelData.type)
                    pieceX: modelData.x
                    pieceY: modelData.y
                }
            }

            Item {
                id: moveIndicators
                anchors.fill: parent
                visible: false

                property var legalMoves: []
                property int fromX: -1
                property int fromY: -1

                Repeater {
                    id: movesRepeater
                    model: moveIndicators.legalMoves

                    Rectangle {
                        property var visualPos: logicalToVisualPos(modelData.x, modelData.y)

                        x: visualPos.x
                        y: visualPos.y
                        width: cellSize
                        height: cellSize
                        color: "transparent"
                        border.width: 3
                        border.color: "#32CD32"
                        radius: cellSize / 2
                        opacity: 0.7

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {

                                let fromX = moveIndicators.fromX;
                                let fromY = moveIndicators.fromY;
                                let toX = modelData.x;
                                let toY = modelData.y;

                                moveIndicators.visible = false;
                                let movingPiece = selectedPiece;
                                if (movingPiece) {
                                    movingPiece.highlighted = false;

                                    movingPiece.animateMove(toX, toY);

                                    let animationTimer = Qt.createQmlObject('import QtQuick 2.0; Timer {interval: 250; repeat: false; running: true;}',
                                                                           root, "AnimationTimer");

                                    animationTimer.triggered.connect(function() {
                                        chessEngine.processMove(fromX, fromY, toX, toY);

                                        selectedPiece = null;

                                        animationTimer.destroy();
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }

        Row {
            spacing: 30
            anchors {
                bottom: parent.bottom
                bottomMargin: 4
                horizontalCenter: parent.horizontalCenter
            }

            StyledButton {
                id: saveButton2
                width: 150
                height: 45
                buttonText: "Сохранить"
                isSmall: true
                enabled: chessEngine.getSavedGames().length < 10
                shadowColor: "#224422"
                onClicked: {
                    gameNameInput.text = ""
                    saveGameDialog.open()
                }
            }

            StyledButton {
                id: newGameButton
                width: 150
                height: 45
                buttonText: "Новая игра"
                isSmall: true
                onClicked: {
                    chessEngine.startNewGame()
                    clearAllSelections()
                }
            }

            StyledButton {
                id: undoButton
                width: 150
                height: 45
                buttonText: "Отменить ход"
                isSmall: true
                enabled: chessEngine.canUndo
                onClicked: {
                    chessEngine.undoLastMove()
                    if (chessEngine.vsComputer) {
                        chessEngine.undoLastMove()
                    }
                }
            }
            StyledButton {
                buttonText: "Меню"
                isSmall: true
                width: 150
                height: 45
                onClicked: {
                    inMenu = true
                }
            }
        }
    }

    Connections {
        target: chessEngine

        function onSavedGamesChanged() {
            var updatedSaves = chessEngine.getSavedGames();
            if (typeof saveButton2 !== "undefined") {
                saveButton2.enabled = updatedSaves.length < 10;
            }

            if (inSettings && typeof settingsSavedGamesList !== "undefined") {
                settingsSavedGamesList.model = null;
                Qt.callLater(function() {
                    settingsSavedGamesList.model = updatedSaves;
                });
            }

            if (typeof loadGameDialog !== "undefined" && loadGameDialog.visible) {
                savedGamesList.model = null;
                Qt.callLater(function() {
                    savedGamesList.model = updatedSaves;
                });
            }

            if (inSettings) {

                if (typeof loadButtonInSettings !== "undefined") {
                    loadButtonInSettings.enabled = updatedSaves.length > 0 && settingsScreen.selectedSaveIndex >= 0;
                }

                if (typeof deleteButtonInSettings !== "undefined") {
                    deleteButtonInSettings.enabled = updatedSaves.length > 0 && settingsScreen.selectedSaveIndex >= 0;
                }

                if (typeof deleteAllButtonInSettings !== "undefined") {
                    deleteAllButtonInSettings.enabled = updatedSaves.length > 0;
                }
            }
        }

        function onGameEnded(result) {
            showGameOverDialog(result)
        }

        function onPiecesChanged() {
            clearAllSelections()
            piecesRepeater.model = chessEngine.getPieces()
        }

        function onStatusChanged() {
            clearAllSelections()
        }

        function onPawnPromotion(fromX, fromY, toX, toY) {
            promotionDialog.fromX = fromX
            promotionDialog.fromY = fromY
            promotionDialog.toX = toX
            promotionDialog.toY = toY
            promotionDialog.open()
        }

        function onMoveExecuted(fromX, fromY, toX, toY, isCapture) {
            if (isCapture) {
                animateCapture(toX, toY);

                let captureTimer = Qt.createQmlObject('import QtQuick 2.0; Timer {interval: 150; repeat: false; running: true;}',
                                                    root, "CaptureTimer");

                captureTimer.triggered.connect(function() {
                    piecesRepeater.model = chessEngine.getPieces();
                    captureTimer.destroy();
                });
            } else {
                piecesRepeater.model = chessEngine.getPieces();
            }
        }
    }

    Dialog {
        id: confirmDeleteAllDialog
        title: "Удаление всех сохранений"
        modal: true
        width: 350
        height: 170

        background: Rectangle {
            color: "#3D3D3D"
            border.color: "#5A5A5A"
            border.width: 2
            radius: 6
        }

        header: Rectangle {
            color: "#553322"
            height: 45
            radius: 4

            Text {
                anchors.centerIn: parent
                text: confirmDeleteAllDialog.title
                font.pixelSize: 18
                font.family: "Courier"
                font.bold: true
                color: "white"
            }
        }

        anchors.centerIn: Overlay.overlay
        contentItem: Item {
            anchors.fill: parent

            Text {
                id: warningText
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: buttonsRow.top
                    bottomMargin: 20
                    topMargin: 50
                }
                text: "Вы уверены, что хотите удалить\nВСЕ сохранения?\nЭто действие нельзя отменить."
                font.pixelSize: 16
                font.family: "Courier"
                font.bold: true
                color: "#FF6666"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                id: buttonsRow
                width: parent.width
                spacing: 20
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 80
                    height: 40
                    color: confirmYesMouseArea.containsMouse ?
                           (confirmYesMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D"
                    radius: 6
                    border.color: "#FF8A8A"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Да"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmYesMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var count = chessEngine.getSavedGames().length;
                            for (var i = 0; i < count; i++) {
                                chessEngine.deleteGame(0);
                            }

                            settingsSavedGamesList.model = null;
                            settingsSavedGamesList.model = chessEngine.getSavedGames();
                            settingsScreen.selectedSaveIndex = -1;

                            if (typeof loadButtonInSettings !== "undefined") {
                                loadButtonInSettings.enabled = false;
                            }
                            if (typeof deleteButtonInSettings !== "undefined") {
                                deleteButtonInSettings.enabled = false;
                            }

                            if (typeof deleteAllButtonInSettings !== "undefined") {
                                deleteAllButtonInSettings.enabled = false;
                            }

                            confirmDeleteAllDialog.close();
                        }
                    }
                }

                Rectangle {
                    width: 80
                    height: 40
                    color: confirmNoMouseArea.containsMouse ?
                           (confirmNoMouseArea.pressed ? "#4D4D6F" : "#5D5D7D") : "#6D6D8D"
                    radius: 6
                    border.color: "#8A8AFF"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Нет"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmNoMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            confirmDeleteAllDialog.close();
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    Dialog {
        id: infoDialog
        title: "Инструкция"
        modal: true
        width: Math.min(parent.width * 0.8, 600)
        height: Math.min(parent.height * 0.8, 700)
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: "#664433"
            border.color: "#886644"
            border.width: 2
        }

        header: Rectangle {
            color: "#775544"
            height: 50

            Text {
                text: "ИНСТРУКЦИЯ"
                font.pixelSize: 24
                font.family: "Courier"
                font.bold: true
                color: "#FFFFFF"
                anchors.centerIn: parent
            }
        }

        contentItem: ScrollView {
            clip: true

            Column {
                width: infoDialog.width - 40
                spacing: 20
                padding: 20

                Text {
                    width: parent.width
                    text: "Шахматы - Руководство по игре"
                    font.pixelSize: 20
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "1. Главное меню"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• 'Одиночная игра' - игра против компьютера с выбранным уровнем сложности\n• 'Многопользовательский режим' - игра на одном устройстве, где 2 игрока ходят по очереди\n• 'Настройки' - изменение уровня сложности игры против компьютера и управление сохранениями\n• 'Выход из игры' - завершение работы приложения\n• Кнопка 'i' в правом верхнем углу - вызов данной инструкции"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "2. Игровой процесс"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• Щелкните по своей фигуре, чтобы выбрать её\n• Зеленые индикаторы покажут возможные ходы для выбранной фигуры\n• Щелкните по зеленому индикатору, чтобы сделать ход\n• Для отмены выбора фигуры щелкните по ней повторно или по любой пустой клетке\n• Текущий статус игры (чей ход) отображается в верхней части экрана\n• В режиме против компьютера, он автоматически делает ответный ход после вашего"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "3. Кнопки игрового интерфейса"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• 'Сохранить' - создает сохранение текущей партии (максимум 10 сохранений)\n• 'Новая игра' - начинает новую партию с текущими настройками\n• 'Отменить ход' - отменяет последний сделанный ход (в режиме против компьютера отменяются оба хода - ваш и компьютера)\n• 'Меню' - возврат в главное меню (текущая партия не будет автоматически сохранена)"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "4. Настройки"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• Выбор сложности компьютера:\n  - 'Легкий' (♙) - подходит для начинающих игроков\n  - 'Средний' (♘) - сбалансированный уровень сложности\n  - 'Сложный' (♕) - серьезный вызов даже для опытных игроков\n• Раздел 'Сохранения' позволяет управлять сохраненными партиями:\n  - Выберите сохранение из списка, затем используйте кнопки 'Загрузить' или 'Удалить'\n  - Кнопка 'Удалить все сохранения' позволяет очистить весь список (требует подтверждения)\n• Кнопка 'Готово' закрывает настройки и возвращает в главное меню"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "5. Сохранение и загрузка партий"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• При нажатии на кнопку 'Сохранить':\n  - Введите название для сохранения (обязательно)\n  - Нажмите кнопку 'Сохранить' или 'Отмена'\n  - Обратите внимание на счетчик доступных слотов (максимум 10 сохранений)\n• В настройках для работы с сохранениями:\n  - Выберите сохранение из списка (отображается название, режим игры, сложность и дата)\n  - Используйте кнопки 'Загрузить' или 'Удалить' для соответствующих действий"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "6. Особые ходы шахматной игры"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• Превращение пешки:\n  - При достижении пешкой противоположного края доски появится диалоговое окно\n  - Выберите фигуру, в которую хотите превратить пешку (ферзь, ладья, слон или конь)\n• Рокировка:\n  - Выберите короля, затем нажмите на клетку, куда он должен переместиться при рокировке (на две клетки влево или вправо)\n  - Ладья автоматически переместится на соответствующую позицию\n• Взятие на проходе:\n  - Если пешка соперника сделала ход на две клетки вперед, проходя мимо вашей пешки\n  - Ваша пешка может взять её 'на проходе', перемещаясь по диагонали за пешкой соперника"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "7. Завершение игры"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• Мат - король находится под шахом и нет ходов, чтобы его избежать (победа атакующей стороны)\n• Пат - король не под шахом, но нет легальных ходов (ничья)\n• Ничья по правилу 50 ходов - 50 ходов подряд без взятия фигур и без хода пешками\n• Недостаточный материал для мата - на доске недостаточно фигур для объявления мата\n• Троекратное повторение позиции - одна и та же позиция повторяется три раза\n• При завершении игры появится диалоговое окно с результатом"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }
            }
        }

        footer: Rectangle {
            color: "#664433"
            height: 60

            Rectangle {
                id: closeInfoButton
                anchors.centerIn: parent
                width: 120
                height: 40
                color: closeInfoMouseArea.containsMouse ? "#886655" : "#775544"
                radius: 5
                border.color: "#886644"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "Закрыть"
                    color: "white"
                    font.pixelSize: 16
                    font.family: "Courier"
                }

                MouseArea {
                    id: closeInfoMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        infoDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: promotionDialog
        title: "Превращение пешки"
        modal: true
        closePolicy: Dialog.NoAutoClose
        width: 280
        height: 280

        background: Rectangle {
            color: "#828282"
            border.color: "#5A5A5A"
            border.width: 2
        }

        header: Rectangle {
            color: "#6D6D6D"
            height: 40

            Text {
                anchors.centerIn: parent
                text: promotionDialog.title
                font.pixelSize: 18
                font.family: "Courier"
                font.bold: true
                color: "white"
            }
        }

        property int fromX: -1
        property int fromY: -1
        property int toX: -1
        property int toY: -1

        anchors.centerIn: Overlay.overlay
        Grid {
            anchors.centerIn: parent
            rows: 2
            columns: 2
            spacing: 20

            Rectangle {
                width: 80
                height: 80
                color: "#6D6D6D"
                border.color: "#5A5A5A"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: {
                        let side = promotionDialog.toY === 7 ? "white" : "black"
                        return resourceManager.getTexturePath(side + "Queen")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        chessEngine.promotePawn(
                            promotionDialog.fromX,
                            promotionDialog.fromY,
                            promotionDialog.toX,
                            promotionDialog.toY,
                            "queen"
                        )
                        promotionDialog.close()
                    }
                }
            }

            Rectangle {
                width: 80
                height: 80
                color: "#6D6D6D"
                border.color: "#5A5A5A"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: {
                        let side = promotionDialog.toY === 7 ? "white" : "black"
                        return resourceManager.getTexturePath(side + "Rook")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        chessEngine.promotePawn(
                            promotionDialog.fromX,
                            promotionDialog.fromY,
                            promotionDialog.toX,
                            promotionDialog.toY,
                            "rook"
                        )
                        promotionDialog.close()
                    }
                }
            }

            Rectangle {
                width: 80
                height: 80
                color: "#6D6D6D"
                border.color: "#5A5A5A"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: {
                        let side = promotionDialog.toY === 7 ? "white" : "black"
                        return resourceManager.getTexturePath(side + "Bishop")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        chessEngine.promotePawn(
                            promotionDialog.fromX,
                            promotionDialog.fromY,
                            promotionDialog.toX,
                            promotionDialog.toY,
                            "bishop"
                        )
                        promotionDialog.close()
                    }
                }
            }

            Rectangle {
                width: 80
                height: 80
                color: "#6D6D6D"
                border.color: "#5A5A5A"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: {
                        let side = promotionDialog.toY === 7 ? "white" : "black"
                        return resourceManager.getTexturePath(side + "Knight")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        chessEngine.promotePawn(
                            promotionDialog.fromX,
                            promotionDialog.fromY,
                            promotionDialog.toX,
                            promotionDialog.toY,
                            "knight"
                        )
                        promotionDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: saveGameDialog
        title: "Сохранить игру"
        modal: true
        width: 400
        height: 300

        // Улучшенный фон диалога
        background: Rectangle {
            color: "#3D3D3D"
            border.color: "#5A5A5A"
            border.width: 2
            radius: 6
        }

        header: Rectangle {
            color: "#553322"
            height: 45
            radius: 4

            Text {
                anchors.centerIn: parent
                text: saveGameDialog.title
                font.pixelSize: 20
                font.family: "Courier"
                font.bold: true
                color: "#FFFFFF"
            }
        }

        anchors.centerIn: Overlay.overlay
        property int availableSlots: Math.max(0, 10 - chessEngine.getSavedGames().length)
        property bool canSave: gameNameInput.text.trim().length > 0 && availableSlots > 0

        onOpened: {
            availableSlots = Math.max(0, 10 - chessEngine.getSavedGames().length);
            saveButton.enabled = gameNameInput.text.trim().length > 0 && availableSlots > 0;
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#664433"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "Введите название сохранения:"
                    font.pixelSize: 16
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                }
            }

            TextField {
                id: gameNameInput
                Layout.fillWidth: true
                height: 45
                placeholderText: "Название партии"
                placeholderTextColor: "#BBBBBB"

                background: Rectangle {
                    color: "#262626"
                    radius: 5
                    border.color: "#886644"
                    border.width: 2
                }

                color: "#FFFFFF"
                selectByMouse: true
                font.pixelSize: 16
                font.family: "Courier"
                leftPadding: 10

                onTextChanged: {
                    saveButton.enabled = text.trim().length > 0 && saveGameDialog.availableSlots > 0;
                }
            }

            Text {
                id: slotsInfoText
                text: "Максимум 10 сохранений. Доступно слотов: " + saveGameDialog.availableSlots
                font.pixelSize: 14
                font.family: "Courier"
                font.bold: true
                color: saveGameDialog.availableSlots > 0 ? "#FFDD99" : "#FF6666"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                visible: saveGameDialog.availableSlots <= 0
                text: "Достигнут лимит сохранений! Удалите старые записи."
                font.pixelSize: 14
                font.family: "Courier"
                font.bold: true
                color: "#FF6666"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                Rectangle {
                    id: saveButton
                    Layout.fillWidth: true
                    height: 45
                    enabled: gameNameInput.text.trim().length > 0 && saveGameDialog.availableSlots > 0
                    color: enabled ? (saveMouseArea.containsMouse ?
                           (saveMouseArea.pressed ? "#4D8F4D" : "#6DAF6D") : "#5D9F5D") : "#444444"
                    radius: 6
                    border.color: enabled ? "#8AFF8A" : "#555555"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Сохранить"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: saveMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (parent.enabled) {
                                if (chessEngine.saveGame(gameNameInput.text.trim())) {
                                    saveGameDialog.availableSlots = Math.max(0, 10 - chessEngine.getSavedGames().length);
                                    var updatedSaves = chessEngine.getSavedGames();
                                    if (typeof settingsSavedGamesList !== "undefined") {
                                        settingsSavedGamesList.model = null;
                                        settingsSavedGamesList.model = updatedSaves;
                                    }
                                    var loadButtonsInSettings = findAllLoadButtons();
                                    for (var i = 0; i < loadButtonsInSettings.length; i++) {
                                        if (loadButtonsInSettings[i]) {
                                            loadButtonsInSettings[i].enabled = updatedSaves.length > 0;
                                        }
                                    }
                                    saveGameDialog.close();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: cancelSaveButton
                    Layout.fillWidth: true
                    height: 45
                    color: cancelSaveMouseArea.containsMouse ?
                           (cancelSaveMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D"
                    radius: 6
                    border.color: "#FF8A8A"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Отмена"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelSaveMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            saveGameDialog.close()
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: loadGameDialog
        title: "Загрузить сохранённую партию"
        modal: true
        width: 400
        height: 500
        property int selectedGameIndex: -1

        background: Rectangle {
            color: "#3D3D3D"
            border.color: "#5A5A5A"
            border.width: 2
            radius: 6
        }

        header: Rectangle {
            color: "#553322"
            height: 45
            radius: 4

            Text {
                anchors.centerIn: parent
                text: loadGameDialog.title
                font.pixelSize: 20
                font.family: "Courier"
                font.bold: true
                color: "#FFFFFF"
            }
        }

        anchors.centerIn: Overlay.overlay

        onOpened: {
            savedGamesList.model = null;
            savedGamesList.model = chessEngine.getSavedGames();
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#262626"
                radius: 5
                border.color: "#444444"
                border.width: 1

                ListView {
                    id: savedGamesList
                    anchors.fill: parent
                    anchors.margins: 5
                    model: chessEngine.getSavedGames()
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }

                    delegate: Rectangle {
                        width: savedGamesList.width - 10
                        height: 80
                        color: loadGameDialog.selectedGameIndex === index ? "#555555" : "#3D3D3D"
                        radius: 5
                        border.color: loadGameDialog.selectedGameIndex === index ? "#886644" : "#555555"
                        border.width: loadGameDialog.selectedGameIndex === index ? 2 : 1

                        property var gameData: modelData

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                loadGameDialog.selectedGameIndex = index
                            }
                        }
                        Column {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 5

                            Text {
                                text: parent.parent.gameData && parent.parent.gameData.name ?
                                      parent.parent.gameData.name : "Без названия"
                                font.pixelSize: 16
                                font.family: "Courier"
                                font.bold: true
                                color: "white"
                            }

                            Text {
                                text: {
                                    var gameData = parent.parent.gameData;
                                    if (!gameData) return "Режим: Неизвестно";

                                    var modeText = "Режим: ";
                                    modeText += gameData.gameMode === "vsComputer" ? "Против ИИ" : "Два игрока";

                                    if (gameData.gameMode === "vsComputer") {
                                        var diffText = "";
                                        if (gameData.difficulty === 1) diffText = "Легкий";
                                        else if (gameData.difficulty === 2) diffText = "Средний";
                                        else if (gameData.difficulty === 3) diffText = "Сложный";
                                        else diffText = gameData.difficulty;

                                        modeText += " | Сложность: " + diffText;
                                    }

                                    return modeText;
                                }
                                font.pixelSize: 14
                                font.family: "Courier"
                                color: "white"
                            }

                            Text {
                                text: "Дата: " + (parent.parent.gameData && parent.parent.gameData.date ?
                                                parent.parent.gameData.date : "Неизвестно")
                                font.pixelSize: 14
                                font.family: "Courier"
                                color: "white"
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: savedGamesList.count === 0
                        text: "Нет сохранённых игр"
                        color: "#FFFFFF"
                        font.pixelSize: 16
                        font.family: "Courier"
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Выберите сохраненную партию"
                font.pixelSize: 16
                font.family: "Courier"
                color: "white"
                visible: loadGameDialog.selectedGameIndex === -1 && savedGamesList.count > 0
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    id: loadButton
                    Layout.fillWidth: true
                    height: 45
                    enabled: loadGameDialog.selectedGameIndex >= 0
                    color: enabled ? (loadMouseArea.containsMouse ?
                            (loadMouseArea.pressed ? "#4D8F4D" : "#6DAF6D") : "#5D9F5D") : "#444444"
                    radius: 6
                    border.color: enabled ? "#8AFF8A" : "#555555"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Загрузить"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: loadMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (parent.enabled && chessEngine.loadGame(loadGameDialog.selectedGameIndex)) {
                                loadGameDialog.close()
                                inMenu = false
                                inSettings = false
                            }
                        }
                    }
                }

                Rectangle {
                    id: deleteButton
                    Layout.fillWidth: true
                    height: 45
                    enabled: loadGameDialog.selectedGameIndex >= 0
                    color: enabled ? (deleteMouseArea.containsMouse ?
                            (deleteMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D") : "#444444"
                    radius: 6
                    border.color: enabled ? "#FF8A8A" : "#555555"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Удалить"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: deleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (parent.enabled && chessEngine.deleteGame(loadGameDialog.selectedGameIndex)) {
                                loadGameDialog.selectedGameIndex = -1
                                savedGamesList.model = null;
                                savedGamesList.model = chessEngine.getSavedGames();

                                if (inSettings && typeof settingsSavedGamesList !== "undefined") {
                                    settingsSavedGamesList.model = null;
                                    settingsSavedGamesList.model = chessEngine.getSavedGames();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: cancelLoadButton
                    Layout.fillWidth: true
                    height: 45
                    color: cancelLoadMouseArea.containsMouse ?
                           (cancelLoadMouseArea.pressed ? "#4D4D6F" : "#5D5D7D") : "#6D6D8D"
                    radius: 6
                    border.color: "#8A8AFF"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Отмена"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelLoadMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            loadGameDialog.selectedGameIndex = -1
                            loadGameDialog.close()
                        }
                    }
                }
            }
        }
    }

    Item {
        id: gameOverDialog
        anchors.fill: parent
        visible: false
        z: 1000

        property string resultText: ""

        Rectangle {
            id: gameOverOverlay
            anchors.fill: parent
            color: "#000000"
            opacity: 0

            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
        }

        Rectangle {
            id: gameOverContainer
            width: Math.min(parent.width * 0.8, 500)
            height: gameOverContent.height + 80
            anchors.centerIn: parent
            radius: 10
            scale: 0.5
            opacity: 0

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#35281E" }
                GradientStop { position: 1.0; color: "#241812" }
            }

            border {
                width: 3
                color: "#886644"
            }

            Behavior on scale {
                NumberAnimation { duration: 300; easing.type: Easing.OutBack }
            }
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }

            Image {
                source: "qrc:/resources/images/chessmen/white/king.png"
                width: 60
                height: 60
                opacity: 0.15
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 10
                }
            }

            Image {
                source: "qrc:/resources/images/chessmen/black/knight.png"
                width: 60
                height: 60
                opacity: 0.15
                anchors {
                    left: parent.left
                    top: parent.top
                    margins: 10
                }
            }

            Column {
                id: gameOverContent
                width: parent.width - 40
                anchors.centerIn: parent
                spacing: 20

                Text {
                    width: parent.width
                    text: "ПАРТИЯ ЗАВЕРШЕНА"
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        pixelSize: 28
                        family: "Courier"
                        bold: true
                    }
                    color: "#E0C9A6"
                }

                Rectangle {
                    width: parent.width * 0.8
                    height: 2
                    color: "#886644"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: gameOverDialog.resultText
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        pixelSize: 36
                        family: "Courier"
                        bold: true
                    }
                    color: {
                        if (gameOverDialog.resultText.includes("Белые")) return "#FFFFFF";
                        if (gameOverDialog.resultText.includes("Чёрные")) return "#000000";
                        return "#E0C9A6";
                    }
                    style: Text.Outline
                    styleColor: "#886644"
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 15

                    Rectangle {
                        width: 150
                        height: 50
                        radius: 5
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: newGameArea.pressed ? "#4D8F4D" : "#6DAF6D" }
                            GradientStop { position: 1.0; color: newGameArea.pressed ? "#3D7F3D" : "#5D9F5D" }
                        }
                        border.color: "#8AFF8A"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "Новая игра"
                            color: "white"
                            font {
                                pixelSize: 16
                                family: "Courier"
                                bold: true
                            }
                        }

                        MouseArea {
                            id: newGameArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                hideGameOverDialog()
                                chessEngine.startNewGame()
                            }
                        }
                    }

                    Rectangle {
                        width: 150
                        height: 50
                        radius: 5
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: mainMenuArea.pressed ? "#8F4D4D" : "#AF6D6D" }
                            GradientStop { position: 1.0; color: mainMenuArea.pressed ? "#7F3D3D" : "#9F5D5D" }
                        }
                        border.color: "#FF8A8A"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "В меню"
                            color: "white"
                            font {
                                pixelSize: 16
                                family: "Courier"
                                bold: true
                            }
                        }

                        MouseArea {
                            id: mainMenuArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                hideGameOverDialog()
                                inMenu = true
                            }
                        }
                    }
                }
            }
        }

        Timer {
            id: gameOverHideTimer
            interval: 300
            onTriggered: {
                if (gameOverOverlay.opacity === 0) {
                    gameOverDialog.visible = false
                }
            }
        }
    }

    function showGameOverDialog(result) {
        gameOverDialog.resultText = result
        gameOverDialog.visible = true
        gameOverOverlay.opacity = 0.7
        gameOverContainer.scale = 1.0
        gameOverContainer.opacity = 1.0
    }

    function hideGameOverDialog() {
        gameOverOverlay.opacity = 0
        gameOverContainer.scale = 0.5
        gameOverContainer.opacity = 0
        gameOverHideTimer.start()
    }

    function animateCapture(x, y) {
        for (let i = 0; i < piecesRepeater.count; i++) {
            let piece = piecesRepeater.itemAt(i);
            if (piece && piece.pieceX === x && piece.pieceY === y) {
                let opacityAnimation = Qt.createQmlObject('
                    import QtQuick 2.0;
                    PropertyAnimation {
                        target: capturedPiece
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 200
                    }', piece, "OpacityAnimation");

                opacityAnimation.capturedPiece = piece;
                opacityAnimation.start();

                let scaleAnimation = Qt.createQmlObject('
                    import QtQuick 2.0;
                    PropertyAnimation {
                        target: capturedPiece
                        properties: "scale"
                        from: 1.0
                        to: 1.3
                        duration: 200
                    }', piece, "ScaleAnimation");

                scaleAnimation.capturedPiece = piece;
                scaleAnimation.start();
                break;
            }
        }
    }
}
