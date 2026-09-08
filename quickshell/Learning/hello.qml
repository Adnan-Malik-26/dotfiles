import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 300
  visible: true
  title: "My first QML App"

  Rectangle {
    anchors.fill: parent
    gradient: Gradient {
      GradientStop {position: 0.0; color: "#bbbbff"}
      GradientStop {position: 1.0; color: "#ffffff"}
    }

    Text {
      text: "Hello, World!"
      anchors.centerIn: parent
      font.pixelSize: 32
      font.bold: true
      color: "#1a56db"
    }

    Text {
      text: "Welcome to QML"
      anchors {
        top: parent.verticalCenter
        horizontalCenter: parent.horizontalCenter
        topMargin: 40
      }
      font.pixelSize: 14
      color: "#888888"
      Text {
        text: "🚀"
        anchors {
          top: parent.bottom
          horizontalCenter: parent.horizontalCenter
          topMargin: 12
        }
      }
    }

  }
}
