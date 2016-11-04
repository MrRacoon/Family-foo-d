'use strict';

const PORT = 8081;
const q = require('./questions.js').getQuestion;
const WebSocketServer = require('ws').Server;
const wss = new WebSocketServer({ port: PORT });

console.log('starting websockets server on %s', PORT);

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
      console.log('ANSWERED: %s', attempt.name);
      acceptingAnswers = false;
      score[attempt.name] = (score[attempt.name] || 0) + 1;
      questionAnswered(attempt);
      setTimeout(newQuestion, 5000);
    }
  });
  ws.send(currentQuestion());
});

// =============================================================================

// isAlpha : Char -> Bool
function isAlpha (c) {
  return /[a-z]/ig.test(c)
}

// charMask : Char -> Char
function charMask (c) {
  return isAlpha(c) ? '*' : c;
}

// keepAllAlpha : String -> String
function keepAllAlpha (str) {
  return str.split('').filter(isAlpha).join('');
}

// sanatize : String -> String
function sanatize (str) {
  return keepAllAlpha(str).toLowerCase();
}

// mask : String -> String
function mask (str) {
  return str.split('').map(charMask).join('');
}

// Answers get some help by discounting anything other than alphaCharacters
// answersMatch : String -> String -> Bool
function answersMatch (str1, str2) {
  return sanatize(str1) === sanatize(str2);
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
    payload: { question: current.question, mask: mask(current.answer) },
  });
}

function makeNewAnswered(n, a, s) {
  return JSON.stringify({
    type: "answered",
    payload: { name: n, answer: a, score: s },
  });
}

// =============================================================================

function newQuestion () {
  current = q();
  sendToAll(currentQuestion());
  acceptingAnswers = true;
  console.log(current);
}

function questionAnswered(mess) {
  sendToAll(makeNewAnswered(mess.name, mess.answer, score[mess.name]));
}

function sendToAll(str) {
  wss.clients.forEach(function each(client) {
    client.send(str);
  });
}

// =============================================================================
