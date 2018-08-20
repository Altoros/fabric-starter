'use strict';

module.exports.info  = 'add object';

let data = [];
let bc, contx;
module.exports.init = function(blockchain, context, args) {
    bc = blockchain;
    contx = context;
    return Promise.resolve();
};

let prefix = ('' + Math.random()).substr(2, 8);
/**
 * Generate unique key for the transaction
 * @returns {String} key
 */
function generateObject() {
    return prefix + (data.length+1);
}

module.exports.run = function() {
    let newObject = generateObject();
    data.push(newObject);
    return bc.invokeSmartContract(contx, 'reference', 'v1',
        [{transaction_type: 'initProduct', name: newObject, desc: newObject + ' desc', status: 1, owner: 'a', lastUpdated: Date.now()}],
        60);
};

module.exports.end = function() {
    return Promise.resolve();
};

module.exports.data = data;
