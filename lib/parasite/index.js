require('mochiscript');

var Middleware = require('./middleware');

module.exports.middleware = function () { 
  return new Middleware();
};

module.exports.Middleware = Middleware;
module.exports.clients    = require('./clients');
