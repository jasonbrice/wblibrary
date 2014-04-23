
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

	req.assert('Hours','Please enter the number of hours').notEmpty();
	req.assert('DateOfWork','Please enter a last name').notEmpty();
	
	errors = req.validationErrors();  
	
	if(errors){
		
		errors.forEach(function(error){ console.log('Error! ' + error.msg);});
		
		exports.edit(req, res, {errors: errors});
	}
	else{
		
		var sql;
		
		if(req.body.id){
		
			console.log('IsActive=' + req.body.IsActive);
			
			
			sql = "update TimeEntry set"
				+" Hours='" + req.body.Hours + "'"
				+" ,DateOfWork='" + req.body.DateOfWork + "'"
				+" ,Comment='" + req.body.Comment + "'"
				+" ,Updated=date('now')"
				+" ,UpdatedBy=" + req.session.user.id
				+ " where ID=" + req.body.id + ";";
			
			console.log('updating user with query: ' + sql);
		}
		else{
			sql = "insert into TimeEntry(Hours, DateOfWork, Comment, Updated, UpdatedBy, CreatedBy) values("
			+ req.body.Hours
			+" , " + req.body.DateOfWork 
			+" ,'" + req.body.Comment + "'"
			+" , date('now')"
			+" ," + req.session.user.id
			+" ," + req.session.user.id
			+ ");"; 
			
			console.log('creating user with query: ' + sql);
		}
		db = new sqlite3.Database( dbpath, function(err) {
			if (err){
				console.log(err);
				exports.edit(req, res, {errors: err});
			}
		});
		
		db.serialize(function(){
			db.run(sql, function(err) {
	            if (err) throw err;
	            process.nextTick(function() {
	            	db.close();
	    			return exports.list(req, res);    	
	            });			
		});
		
	});
	}
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