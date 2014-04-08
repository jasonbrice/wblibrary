/**
 * Login using passport with passport-local strategy
 */

var path = require('path');
var sqlite3 = require('sqlite3').verbose();
var db;

exports.get = function(req, res){
	console.log("Serving " + __filename);
	
	res.render('login', { title: 'Please log in with your email and password' });
	    
};	

