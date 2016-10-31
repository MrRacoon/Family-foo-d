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
  current = {
    question: "I'm thinking of a number between one and ten",
    answer: Math.round(Math.random() * 9) + ''
  };
  console.log(current);
  sendToAll(JSON.stringify({
    type: "NewQuestion",
    payload: current
  }))
}

wss.on('connection', function connection(ws) {
  clients.push(ws);
  ws.on('message', function incoming(message) {
    const attempt = JSON.parse(message);
    console.log(attempt);
    if (acceptingAnswers && isMatch(attempt)) {
      acceptingGuesses = false;
      score[attempt.name] = (score[attempt.name] || 0) + 1;
      newQuestion()
    }
  });
  ws.on('disconnect', function disconnecting() {
    clients = clients.filter(function notClient(c) { return c !== ws; });
  })
  ws.send(JSON.stringify(current));
});
