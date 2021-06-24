import { Elm } from "./Main.elm";

import "./js/latex-area"
import "./js/latex-preview"


// Пакет для работы с ShortCuts
import "elm-keyboard-shortcut"

// Инициализизация Elm приложения
const app = Elm.Main.init({ node: document.getElementById("root") });


const socket = new WebSocket('wss://echo.websocket.org');

function sendMsg(msg) {
  console.log("Sending", msg);
  switch (socket.readyState) {
    case socket.CLOSED:
      console.log("Error: Socket closed");
      break;
    case socket.CLOSING:
      console.log("Error: socket is closing");
      break;
    case socket.CONNECTING:
      console.log("Error: socket is connecting\n Retry in 1000");
      setTimeout(() => sendMsg(msg), 1000);
      break;
    case socket.OPEN:
      socket.send(msg);
  }
}

app.ports.sendMsg.subscribe(sendMsg);


socket.onopen = () => {
  socketOk = true;
}
socket.onmessage = (msgEvent) => {
  console.log("Received", msgEvent.data);
  app.ports.msgReceiver.send(msgEvent.data);
}
socket.onerror = () => {
  console.error("Socket error");
}
socket.onclose = () => {
  console.log("Socket closed");
} 