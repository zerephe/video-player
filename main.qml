import QtQuick 2.15
import QtMultimedia 6.3
import FileDialog 1.0

Window {
    width: 640
    height: 480
    color: "black"
    visible: true
    title: qsTr("Player")

    Item {
        width: parent.width
        height: parent.height

        MediaPlayer {
            id: player
            source: {
                switch (Qt.platform.os) {
                    case "android": return fileDialog.filePath
                    case "windows": return "file:///" + fileDialog.filePath
                }
            }

            audioOutput: AudioOutput {}
            videoOutput: videoOutput
        }

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }

        Component.onCompleted: {
            player.play()
        }
    }

    Rectangle {
        id: videoCover
        anchors.fill: parent
        color: "#37274e"
        opacity: 0
    }

    NumberAnimation {
        id: coverAnim
        target: videoCover
        property: "opacity"
        duration: 300
        easing.type: Easing.InOutQuad
    }

    Item {
        id: controls
        anchors.fill: parent

        Image {
            id: playPauseBtn
            anchors.centerIn: parent
            width: parent.width * 0.15
            height: parent.height * 0.15
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: {
                        if(player.playbackState == 1) {
                            return "qrc:/images/pause.png"
                        } else {
                            return "qrc:/images/play.png"
                        }
                    }

            MouseArea {
                id: playpauseArea
                anchors.fill: parent
                onClicked: () => {
                               if(player.playbackState == 1) {
                                   coverAnim.from = 0
                                   coverAnim.to = 0.5
                                   coverAnim.running = true
                                   player.pause()

                               } else {
                                   coverAnim.from = 0.5
                                   coverAnim.to = 0
                                   coverAnim.running = true
                                   player.play()
                               }
                           }
            }
        }

        Image {
            id: fileOpenIcon
            width: (parent.width + parent.height) * 0.025
            height: width
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 40
            smooth: true

            source: "qrc:/images/openFile.png"

            MouseArea {
                id: filePickerArea
                anchors.fill: parent
                onPressed: {
                    player.stop()

                    idleTimer.stop()
                    fileDialog.openFile()

                    if(videoCover.opacity) {
                        coverAnim.from = 0.5
                        coverAnim.to = 0
                        coverAnim.running = true
                    }
                    idleTimer.start()
                    player.play()
                }
            }
        }

        Rectangle {
            id: progressBarContainer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: parent.height * 0.1

            height: 4
            radius: 10

            color: "darkGray"

            Rectangle {
                id: progressBar
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: player.duration > 0 ? parent.width*player.position/player.duration : 0
                radius: parent.radius

                gradient: Gradient {
                    GradientStop {
                        position: 0.0; color: "#a91ca6"
                    }
                    GradientStop {
                        position: 0.4; color: "#6a14d1"
                    }
                    GradientStop {
                        position: 0.7; color: "#a91ca6"
                    }
                    GradientStop {
                        position: 1; color: "#6a14d1"
                    }
                    orientation: Gradient.Horizontal
                }
            }

            Item {
                id: vidSeeker
                x: progressBar.width - width/2
                y: -(height/2 - parent.height/2)
                width: 20
                height: 20

                Drag.active:  dragArea.drag.active
                Drag.hotSpot.x: 10
                Drag.hotSpot.y: 10

                Rectangle {
                    anchors.fill: parent
                    opacity: 0.5
                    radius: width * 0.5
                }

                Rectangle {
                    x: width/2 ; y: -(height/2 - parent.height/2)
                    width: parent.width/2
                    height: parent.height/2
                    radius: width * 0.5
                }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: parent
                    drag.maximumX: progressBarContainer.width - parent.width/2
                    drag.minimumX: -parent.width/2
                    drag.minimumY: -(parent.height/2 - progressBarContainer.height/2)
                    drag.maximumY: -(parent.height/2 - progressBarContainer.height/2)

                    onPositionChanged: () => {
                                           if (player.seekable) {
                                               player.position = player.duration * parent.x/progressBarContainer.width
                                           }
                                       }
                }
            }

            MouseArea {
                id: seekArea
                z: -1
                anchors.fill: parent
                onPressed: (mouse) => {
                               if (player.seekable) {
                                   player.position = player.duration * mouse.x/width
                               }
                           }
            }
        }
    }

    FileDialog {
        id: fileDialog
    }

    NumberAnimation {
        id: idleAnim
        target: controls
        property: "opacity"
        duration: 400
        easing.type: Easing.InOutQuad
    }

    Timer {
        id: idleTimer
        interval: 2000;
        running: true
        onTriggered: () => {
                         idleAnim.from = 1
                         idleAnim.to = 0
                         idleAnim.running = true
                         controls.enabled = false
                         windowArea.cursorShape = Qt.BlankCursor
                     }
    }

    TapHandler {
        id: tapHandler
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: handleIdle()
    }

    MouseArea {
        id: windowArea
        anchors.fill: parent
        onPressed: (mouse) => mouse.accepted = false
        hoverEnabled: true
        onPositionChanged: handleIdle()
    }

    function handleIdle() {
        idleTimer.restart()

        if(!controls.opacity){
            controls.enabled = true
            idleAnim.from = 0
            idleAnim.to = 1
            idleAnim.running = true
            windowArea.cursorShape = Qt.ArrowCursor
        }
    }
}
