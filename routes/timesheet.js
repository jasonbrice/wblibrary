
var path = require('path');
var sqlite3 = require('sqlite3').verbose();
var expressValidator = require("express-validator");

var timesheets = null;
var timesheet = null;
var errors;
var title = null;
var affiliations = null;

var dbpath = "./database/db.sqlite";

var db;

exports.list = function(req, res){
	
	console.log("Accessing: " + __filename);
	
	var renderPage = "timesheet_list";
	
	db = new sqlite3.Database( dbpath, function(err) {
		if (err){
			console.log(err);
			return done( null, false, { message : 'Database problem: ' + err });
		}
	});

	var query = "select * from TIMESHEETS";

	console.log("querying " + path.resolve(dbpath) + " with: " + query);
	
	db.all(query, function(err, rows) {
		if (err){
			console.log("Database problem: " + err);
			res.render(renderPage, {error:'Database problem: ' + err});
		}
		if (rows) {
			console.log("found " + rows.length + " timesheets");
			timesheets = rows;
		}else{
			console.log("found 0 results");
		}
		
		console.log('Rendering ' + renderPage);
		
		res.render(renderPage, {title: 'Viewing ' + timesheets.length + ' timesheets', timesheets:timesheets});
		
		db.close();
		
	});
	
};

exports.save = function(req, res){
	
	console.log("Accessing: " + __filename);
};

exports.edit = function(req, res){
	
	console.log("Accessing: " + __filename);
	
    var renderPage = "timesheet_edit";
	
    var id = req.params.id;
	
	db = new sqlite3.Database( dbpath, function(err) {
		if (err){
			console.log(err);
			return done( null, false, { message : 'Database problem: ' + err });
		}
	});

	var query = "select * from TIMESHEETS where ID=" + id;

	console.log("querying " + path.resolve(dbpath) + " with: " + query);
	
	db.get(query, function(err, row) {
		if (err){
			console.log("Database problem: " + err);
			res.render(renderPage, {error:'Database problem: ' + err});
		}
		if (row) {
			console.log("found a timesheet");
			timesheet = row;
		}else{
			console.log("found 0 results");
		}
		
		console.log('Rendering ' + renderPage);
		
		res.render(renderPage, {title: 'Timesheet for ' + timesheet.Name, timesheet:timesheet});
		
		db.close();
		
	});
};