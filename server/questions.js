const fs = require('fs');
const R = require('ramda');

function question(str) {
  const spl = R.split('`', str);
  return {
    question : spl[0],
    answer   : spl[1],
  };
}

const qs = R.map(question, R.split('\n', fs.readFileSync(__dirname + '/questions/questions_00', {
  encoding: 'utf-8'
})));

function getQuestion() {
  const r = Math.floor(Math.random() * qs.length);
  return qs[r];
}

module.exports = {
  getQuestion: getQuestion
};
