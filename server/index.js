const q = require('./questions.js').getQuestion;
const WebSocketServer = require('ws').Server;
const wss = new WebSocketServer({ port: 8081 });

// =============================================================================

let score = {};
let acceptingAnswers = true;
let current = {
  question: "Ready?!!?",
  answer: "yeeee",
};

// =============================================================================

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    const attempt = JSON.parse(message);
    console.log(attempt);
    if (acceptingAnswers && answersMatch(current.answer, attempt.answer)) {
      acceptingGuesses = false;
      score[attempt.name] = (score[attempt.name] || 0) + 1;
      questionAnswered(attempt.name);
      setTimeout(newQuestion, 5000);
    }
  });
  ws.send(currentQuestion());
});

// =============================================================================

const ignoreChars =
  [ ' ', /\./, ',', '>', '<', '!', '@', '#', '$', '%', '^', '&', /\*/, /\(/, /\)/
  , /\[/, /\]/, '{', '}', '-', /\+/, '=', '_', ':', ';', /\?/, '/', '|', '`', '~'
  , /\\/
  ];

function rmChar(str, char) {
  return str.replace(new RegExp(char, 'gi'), '');
}

function rmChars(str) {
  return ignoreChars.reduce(rmChar, str)
}

function ignored(char) {
  return ignoreChars.indexOf(char) > -1;
}

function sanatize(str) {
  return rmChars(str).toLowerCase();
}

function answersMatch(a, b) {
  return sanatize(a) === sanatize(b);
}

// =============================================================================

function maskedQuestion() {
  return JSON.stringify({
    type: "new",
    payload: current,
  });
}

function currentQuestion() {
  return JSON.stringify({
    type: "new",
    payload: current,
  });
}

function makeNewAnswered(n) {
  return JSON.stringify({
    type: "answered",
    payload: { name: n },
  });
}

// =============================================================================

function newQuestion () {
  current = q();
  sendToAll(currentQuestion());
  acceptingAnswers = true;
  console.log(current);
}

function questionAnswered(n) {
  sendToAll(makeNewAnswered(n));
}

function sendToAll(str) {
  wss.clients.forEach(function each(client) {
    client.send(str);
  });
}

// =============================================================================
