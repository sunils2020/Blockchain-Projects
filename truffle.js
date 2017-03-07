var DefaultBuilder = require("truffle-default-builder");

module.exports = {
  build: new DefaultBuilder({
    "index.html": "index.html",
    "app.js": ["javascripts/app.js"],"calendar.js":["javascripts/calendar.js"],"moment.js":["javascripts/moment.js"],
    "app.css": ["stylesheets/app.css"],"calendar.css":["stylesheets/calendar.css"],
    "images/": "images/"
  }),
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
};
