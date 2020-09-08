#!/usr/bin/env node

const repl = require('repl');
const fs = require('fs')


// Link to Elm code
var Elm = require('./main').Elm;
var main = Elm.Repl.Main.init();

// Eval function for the repl
function eval(input, _, __, callback) {
  // console.log ("Input: " + input)
  main.ports.put.subscribe(
    function putCallback (data) {
      main.ports.put.unsubscribe(putCallback)
      callback(null, data)
    }
  )
  main.ports.get.send(input)
}

function myWriter(output) {
  return output
}

console.log("\nType ':help' for help\n")

repl.start({ prompt: '> ', eval: eval, writer: myWriter});
