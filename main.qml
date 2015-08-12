import QtQuick 2.3
import QtQuick.Window 2.2

Window {
    id:snake
    visible: true
    width: 400
    height: 400
    title: "Snake"
    property int length: 5
    property int currentIndex: 814
    property int lastIndex: 813 // prevent self eating
    property int foodIndex: 820
    property int delta: 1 // left: -1; right: 1; up: -40; down: 40
    property bool food: true
    Item {
        id: keyhandler
        focus: true
        Keys.onPressed: {
            if(timer.running) {
                switch (event.key) {
                case Qt.Key_W:
                    if(currentIndex - 40 != lastIndex) delta = -40; break;
                case Qt.Key_S:
                    if(currentIndex + 40 != lastIndex) delta = 40; break;
                case Qt.Key_A:
                    if(currentIndex - 1 != lastIndex) delta = -1; break;
                case Qt.Key_D:
                    if(currentIndex + 1 != lastIndex) delta = 1; break;
                }
                event.accepted = true;
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            timer.running = false
            for(var i = 0; i < cell.model; ++i) cell.itemAt(i).duration = 0;
            length = 5
            currentIndex = 814
            lastIndex = 813
            foodIndex = 820
            food = false
            delta = 1
            timer.running = true
        }
    }
    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
    }
    Grid {
        id: grid
        anchors.fill: parent
        rows: 40
        columns: rows
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        Repeater {
            id: cell
            model: 1600
            Rectangle {
                color: "white"
                property int duration: 0
                width: 10
                height: width
                transformOrigin: Item.Center
                scale: duration != 0 ? 1 : 0
                radius: duration < 0 ? 5 : 0
                Behavior on scale {
                    NumberAnimation {
                        duration: 10
                        easing.type: Easing.OutExpo
                    }
                }
            }
        }
    }
    Timer {
       id: timer
       interval: 80
       repeat: true
       running: true
       triggeredOnStart: true
       onTriggered: {
           // check if dead
           if(currentIndex < 0 || currentIndex >= 1600 ||
                   Math.abs((currentIndex % 40) - (lastIndex % 40) == 39) ||
                   cell.itemAt(currentIndex).duration > 0) {
               stop();
           }
           // food
           if(!food) {
               do {
                   foodIndex = Math.floor(1600 * Math.random())
               } while(cell.itemAt(foodIndex).duration)
               cell.itemAt(foodIndex).duration = -1
               food = true
           }
           else if(currentIndex == foodIndex) {
               cell.itemAt(foodIndex).duration = ++snake.length
               currentIndex = foodIndex
               food = false
               snake.title = "Snake | Score: "
               snake.title += length - 5;
           }
           // cells processing
           cell.itemAt(snake.currentIndex).duration = snake.length
           for(var i = 0; i < cell.model; ++i) {
                if(cell.itemAt(i).duration > 0) --cell.itemAt(i).duration
           }
           lastIndex = currentIndex;
           currentIndex += delta;
       }
    }
}
