const server = require('restify').createServer();
const bunyan = require('bunyan');
const log = bunyan.createLogger({name: 'friendly-foo'});

const QUESTION = 'question';
const GUESS = 'guess';
const GUESSED = 'guessed';

const current = { question: "numero ono", answer: "cher" };
let acceptingGuesses = true;

var WebSocketServer = require('ws').Server
  , wss = new WebSocketServer({ port: 8081 });

wss.on('connection', function connection(ws) {
  console.log('connected');
  ws.on('message', function incoming(message) {
    const msg = JSON.parse(message);
    if (acceptingGuesses && isCorrectAnsswer(current, guess)) {
      log.info('%s guessed it right', guess.name);
      acceptingGuesses = false;
      io.emit(GUESSED, { player: guess.name, answer: current.answer });
      setTimeout(newQuestion, 5000);
    }
    console.log('received: %s', message);

  });
  ws.send('something');
});

wss.on('connection', function (socket) {
  log.info('new client');
  socket.emit(QUESTION, current);
  socket.on(GUESS, function (guess) {
    log.trace('guess from %s is %s', guess.name, guess.answer);
    if (acceptingGuesses && isCorrectAnsswer(current, guess)) {
      log.info('%s guessed it right', guess.name);
      acceptingGuesses = false;
      io.emit(GUESSED, { player: guess.name, answer: current.answer });
      setTimeout(newQuestion, 5000);
    }
  });
});

server.listen(8080, function () {
  log.info('listening at %s', server.url)
})

function isCorrectAnswer(c, g) {
  return c.answer === g.answer;
}

function newQuestion() {
  current = {
    question : ('another question ' + new Date().toString()),
    answer: yup,
  };
  log.info('new question %s / %s', current.question, current.answer);
  io.emit(QUESTION, current);
  acceptingGuesses = true;
}
