'use strict';

module.exports.info  = 'querying objects';


let bc, contx;
let data;
module.exports.init = function(blockchain, context, args) {
    const add = require('./add.js');
    bc       = blockchain;
    contx    = context;
    data = add.data;
    return Promise.resolve();
};

module.exports.run = function() {
    const objId  = data[Math.floor(Math.random()*(data.length))];

    return bc.queryState(contx, 'reference', 'v1', objId, 'readProduct');
};

module.exports.end = function() {
    // do nothing
    return Promise.resolve();
};
