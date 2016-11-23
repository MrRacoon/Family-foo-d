'use strict';

const PORT = 8081;
const HOST = '127.0.0.1';
const q = require('./questions.js').getQuestion;
const WebSocketServer = require('ws').Server;
const wss = new WebSocketServer({ port: PORT });

console.log('starting websockets server at %s on %s', HOST, PORT);

// =============================================================================

let score = {};
let votes = [];
let acceptingAnswers = true;
let conId = 1;
let current;

newQuestion();

// =============================================================================

wss.on('connection', function connection(ws) {
  ws.id = conId++;
  console.log('CON: %s', ws.id)
  conId = conId++;
  ws.on('message', function incoming(message) {
    console.log('MSG: %s', message);
    const msg = JSON.parse(message);
    if (msg.vote && votes.indexOf(ws.id) === -1) {
      votes.push(ws.id)
      ws.name = msg.vote;
      const threshold = Math.floor(wss.clients.length / 2)
      if (threshold < votes.length) {
        newQuestion();
      } else {
        updateVoteCount();
      }
    }
    if (msg.name && msg.answer) {
      if (acceptingAnswers && answersMatch(current.answer, msg.answer)) {
        console.log('ANS: %s', msg.name);
        acceptingAnswers = false;
        score[msg.name] = (score[msg.name] || 0) + 1;
        questionAnswered(msg);
        setTimeout(newQuestion, 5000);
      }
    }
    if (msg.points) {
      console.log('PTS: %s %s', ws.id, msg.points)
      sendToOne(ws, pointsOf(msg.points))
    }
  });
  ws.on('close', function diconnected(code, message) {
    console.log('DIS: %s %s', code, message);
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

function sendToOne(sock, msg) {
  console.log('SND: %s %s', sock.id, msg)
  sock.send(msg);
}

function sendToAll(str) {
  console.log('S2A: %s', str)
  wss.clients.forEach(function each(client) {
    client.send(str);
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

function voteCount() {
  return JSON.stringify({
    type: "votes",
    payload: {
      count: votes.length,
      participants: wss.clients
        .filter(function onlyNamedAndVoted(c) {
          return !!c.name && votes.indexOf(c.id) > -1;
        })
        .map(function getName(c) {
          return c.name;
        })
    },
  });
}

function pointsOf(n) {
  return JSON.stringify({
    type: "points",
    payload: {
      points: score[n] || 0,
    },
  });
}

// =============================================================================

function newQuestion () {
  current = q();
  votes = [];
  sendToAll(currentQuestion());
  acceptingAnswers = true;
  console.log('NEW: %s', JSON.stringify(current));
}

function questionAnswered(mess) {
  sendToAll(makeNewAnswered(mess.name, mess.answer, score[mess.name]));
}

function updateVoteCount() {
  sendToAll(voteCount());
}
