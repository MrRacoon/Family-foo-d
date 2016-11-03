const fs = require('fs');
const R = require('ramda');

function question(str) {
  const spl = R.split('`', str);
  return {
    question : spl[0],
    answer   : spl[1],
  };
}

const makeQs = R.compose(R.map(question), R.split('\n'))

const qs = makeQs(
  fs.readFileSync(__dirname + '/questions/questions_00', {
    encoding: 'utf-8'
  })
);

function getQuestion() {
  return qs[Math.floor(Math.random() * qs.length)];
}

module.exports = {
  getQuestion: getQuestion
};
