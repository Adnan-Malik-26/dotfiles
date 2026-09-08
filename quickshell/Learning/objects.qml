import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 300
  visible: true
  title: "Interactive Objects"

  Rectangle {
    id: box
    x: 100; y: 80
    width: 200; height: 140
    color: "#4ecdc4"
    radius: 12

    Text {
      id: label
      text: "Click me!"
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 20
      font.bold: true
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        box.color = "#ff6b6b"
        label.text = "Clicked!"
      }
    }

    Timer {
      interval: 1000
      running: false
      onTriggered: {
        box.color = "#4ecdc4"
        label.text = "Click me!"
      }
    }
  }
}
