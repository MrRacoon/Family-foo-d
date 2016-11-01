const q = require('./questions.js').getQuestion;
const WebSocketServer = require('ws').Server;
const wss = new WebSocketServer({ port: 8081 });

let clients = [];
let score = {};
let acceptingAnswers = true;
let current = {
  question: "Ready?!!?",
  answer: "yeeee"
}

function sendToAll(message) {
  clients.forEach(function (client) {
    client.send(message);
  });
}

function isMatch(attempt) {
  return attempt.answer === current.answer;
}

function newQuestion () {
  current = q();
  console.log(current);
  sendToAll(JSON.stringify({
    type: "new",
    payload: current
  }))
  acceptingAnswers = true;
}

wss.on('connection', function connection(ws) {
  clients.push(ws);
  ws.on('message', function incoming(message) {
    const attempt = JSON.parse(message);
    console.log(attempt);

    if (acceptingAnswers && isMatch(attempt)) {
      acceptingGuesses = false;
      score[attempt.name] = (score[attempt.name] || 0) + 1;

      wss.clients.forEach(function each(client) {
        client.send(JSON.stringify({
          type: "answered",
          payload: {
            name: attempt.name
          }
        }));
      });

      setTimeout(function afterFiveSeconds() {
        newQuestion()
        wss.clients.forEach(function each(client) {
          client.send(JSON.stringify({
            type: "new",
            payload: current
          }));
        });
      }, 5000)
    }
  });
  ws.on('disconnect', function disconnecting() {
    clients = clients.filter(function notClient(c) { return c !== ws; });
  })
  ws.send(JSON.stringify({
    type: "new",
    payload: current
  }));
});
