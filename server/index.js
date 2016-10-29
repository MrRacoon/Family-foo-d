const server = require('restify').createServer();
const io = require('socket.io').listen(server.server);
const bunyan = require('bunyan');
const log = bunyan.createLogger({name: 'friendly-foo'});

const QUESTION = 'question';
const GUESS = 'guess';
const GUESSED = 'guessed';

const current = { question: "numero ono", answer: "cher" };
let acceptingGuesses = true;

io.sockets.on('connection', function (socket) {
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
