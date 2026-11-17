import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
  id: root
  width: 640
  height: 480
  color: "#0e1009"

  property int userIndex: Math.max(userModel.lastIndex, 0)
  property string currentUser: userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1) || userModel.lastUser
  property bool loginFailed: false

  function nextUser(step) {
    if (userModel.count < 2) return
    userIndex = (userIndex + step + userModel.count) % userModel.count
    password.text = ""
    loginFailed = false
    password.forceActiveFocus()
  }

  property int sessionIndex: {
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1)
        return i
    }
    return sessionModel.lastIndex
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      root.loginFailed = true
      password.text = ""
      password.focus = true
    }
    function onLoginSucceeded() {
      root.loginFailed = false
    }
  }

  Image {
    anchors.fill: parent
    source: "background.webp"
    fillMode: Image.PreserveAspectCrop
    smooth: true
  }

  Rectangle {
    anchors.fill: parent
    color: "#0e1009"
    opacity: 0.28
  }

  Column {
    anchors.centerIn: parent
    spacing: 24

    Text {
      text: "SYSTEM ACCESS  //  SPARTAN-117"
      color: "#9dae5c"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 14
      font.letterSpacing: 3
      horizontalAlignment: Text.AlignHCenter
      width: parent.width
      opacity: 0.9
    }

    Image {
      id: logo
      source: "logo.png"
      width: Math.min(sourceSize.width, root.width * 0.55)
      height: sourceSize.width > 0 ? Math.round(width * sourceSize.height / sourceSize.width) : 0
      fillMode: Image.PreserveAspectFit
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 18

      Text {
        text: "<"
        color: root.loginFailed ? "#c85b47" : "#9dae5c"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 26
        opacity: userModel.count > 1 ? 1 : 0
        MouseArea {
          anchors.fill: parent
          anchors.margins: -12
          enabled: userModel.count > 1
          onClicked: root.nextUser(-1)
        }
      }

      Text {
        text: root.currentUser
        color: root.loginFailed ? "#c85b47" : "#d8d9b4"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 24
        width: 300
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
      }

      Text {
        text: ">"
        color: root.loginFailed ? "#c85b47" : "#9dae5c"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 26
        opacity: userModel.count > 1 ? 1 : 0
        MouseArea {
          anchors.fill: parent
          anchors.margins: -12
          enabled: userModel.count > 1
          onClicked: root.nextUser(1)
        }
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 16

      Image {
        source: root.loginFailed ? "lock-failed.png" : "lock.png"
        width: 34
        height: 38
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
      }

      Item {
        width: 420
        height: 67

        Image {
          id: entry
          source: root.loginFailed ? "entry-failed.png" : "entry.png"
          anchors.centerIn: parent
        }

        Text {
          anchors.centerIn: parent
          textFormat: Text.PlainText
          text: root.loginFailed ? "ACCESS DENIED" : "ENTER PASSWORD"
          visible: password.text.length === 0
          color: root.loginFailed ? "#c85b47" : "#737c58"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 18
          font.letterSpacing: 2
        }

        Row {
          anchors.centerIn: parent
          spacing: 8
          visible: password.text.length > 0

          Repeater {
            model: Math.min(password.text.length, 24)

            Image {
              source: "bullet.png"
              width: 8
              height: 8
            }
          }
        }

        TextInput {
          id: password
          anchors.fill: parent
          anchors.leftMargin: 20
          anchors.rightMargin: 20
          verticalAlignment: TextInput.AlignVCenter
          horizontalAlignment: TextInput.AlignHCenter
          echoMode: TextInput.Password
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 24
          font.letterSpacing: 5
          passwordCharacter: "\u2022"
          color: "transparent"
          selectionColor: "transparent"
          selectedTextColor: "transparent"
          cursorDelegate: Item {}
          focus: true

          onTextChanged: root.loginFailed = false

          Keys.onPressed: {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
              root.nextUser(1)
              event.accepted = true
              return
            }
            if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
              root.nextUser(-1)
              event.accepted = true
              return
            }
            if (event.key === Qt.Key_Escape) {
              password.text = ""
              root.loginFailed = false
              event.accepted = true
              return
            }
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              sddm.login(root.currentUser, password.text, root.sessionIndex)
              event.accepted = true
            }
          }
        }
      }
    }

    Text {
      text: "MECHA GREEN  //  OLIVE / AMBER"
      color: "#737c58"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 13
      font.letterSpacing: 2
      horizontalAlignment: Text.AlignHCenter
      width: parent.width
      opacity: 0.9
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 40
    text: "MCHOSE ACE 75  //  HALL EFFECT  //  8K"
    color: "#9dae5c"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 11
    font.letterSpacing: 2
    opacity: 0.45
  }

  Component.onCompleted: password.forceActiveFocus()
}
