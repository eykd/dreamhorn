// Based on https://github.com/forana/darmok-js/blob/development/src/util.js
var assert = require("assert")

var Ring = require('./core')

Ring.prototype.weighted_choice = function(options, weights) {
    assert(options.length == weights.length, "Options and weights must be the same length");
    assert(options.length > 0, "Must provide at least one option");

    var weightSum = _.reduce(weights, function(sum, weight) {
        return weight + sum;
    }, 0);

    assert(weightSum >= 0, "Weights must sum to zero (got " + JSON.stringify(weights) + ")");

    var random = Math.random();
    var rollingTotal = 0;
    for (var i=0; i<options.length; i++) {
        rollingTotal += weights[i]/weightSum;
        if (rollingTotal >= random) {
            return options[i];
        }
    }

    // shouldn't be possible, so let's throw a stupid message
    throw {"message": "weightedChoice() returned nothing"};
};
