import QtQuick
import Quickshell

PanelWindow {
  implicitWidth: 600
  implicitHeight: 36
  color: "#010101"

  Row {
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      leftMargin: 12
    }
    spacing: 8

    Rectangle { implicitWidth: 8; implicitHeight: 8; radius: 4; color: "#00ff88" }
    Text { text: "Workspace 1"; color: "#e0e0e0"; font.pixelSize: 13 }
  }

  Text {
    text: "Hello, Adnan!"
    anchors.centerIn: parent
    color: "#e6e6e6"
    font.pixelSize: 14
  }

  Text {
    text: "✕"
    anchors {
      right: parent.right
      verticalCenter: parent.verticalCenter
      rightMargin: 12
    }
    color: "#e0e0e0"
    font.pixelSize: 14
  }

  Column {
    Text {
      text: "2026"
      anchors{
        right: parent.right
      }
      color: "#e6e6e6"
      font.pixelSize: 14
    }
  }
}
