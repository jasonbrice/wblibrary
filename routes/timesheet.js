
var path = require('path');
var sqlite3 = require('sqlite3').verbose();
var expressValidator = require("express-validator");

var timesheets = null;
var timesheet = null;
var errors;
var title = null;
var affiliations = null;
var user = null;

var dbpath = "./database/db.sqlite";

var db;

exports.list = function(req, res){
	
	console.log("Accessing: " + __filename);
	
	user = req.session.user;
	
	var renderPage = "timesheet_list";
	
	db = new sqlite3.Database( dbpath, function(err) {
		if (err){
			console.log(err);
			return done( null, false, { message : 'Database problem: ' + err });
		}
	});

	var query = "select * from TIMESHEETS order by Updated desc;";
	if( !user.IsAdmin ) query += " where UserID=" + user.ID;

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
		
		res.render(renderPage, {title: 'Viewing ' + timesheets.length + ' timesheets', timesheets:timesheets, user:user});
		
		db.close();
		
	});
	
};

exports.save = function(req, res){
	
	console.log("Accessing: " + __filename);

	req.assert('Hours','Please enter the number of hours').notEmpty();
	req.assert('DateOfWork','Please enter the date of the work').notEmpty();
	
	errors = req.validationErrors();  
	
	if(errors){
		
		errors.forEach(function(error){ console.log('Error! ' + error.msg);});
		
		exports.edit(req, res, {errors: errors});
	}
	else{
		
		var sql;
		
		if(req.body.id){
		
			sql = "update TimeEntry set"
				+" Hours='" + req.body.Hours + "'"
				+" ,DateOfWork='" + req.body.DateOfWork + "'"
				+" ,Comment='" + req.body.Comment + "'"
				+" ,Updated=date('now')"
				+" ,UpdatedBy=" + req.session.user.ID
				+ " where ID=" + req.body.id + ";";
			
			console.log('updating user with query: ' + sql);
		}
		else{
			
			var dateparts = req.body.DateOfWork.valueOf().split('/');
			
			var workdate = dateparts[2] + "-" + dateparts[0] + "-" + dateparts[1];
				
			sql = "insert into TimeEntry(Hours, DateOfWork, Comment, UserID, Updated, UpdatedBy, CreatedBy, ApprovalStatusID) values("
			+ req.body.Hours
			+" , '" + workdate + "'" 
			+" ,'" + req.body.Comment + "'"
			+", " + req.session.user.ID
			+" , date('now')"
			+" ," + req.session.user.ID
			+" ," + req.session.user.ID
			+", (select ID from ApprovalStatus where name='Pending') "
			+ ");"; 
			
			console.log('creating timeentry with query: ' + sql);
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

	if(req.params.id){	
		   
	user = req.session.user;  
	
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
		
		if(timesheet.ApprovalStatus == 'Pending' || req.session.user.IsAdmin)
		{
			console.log('rendering ' + renderPage);
			res.render(renderPage, {title: 'Timesheet for ' + timesheet.Name, timesheet:timesheet});
		}else{
			console.log("user is not authorized, returning");
			AuthorizationError = "You are not authorized for that resource";
			res.redirect('/');
		}
		
		db.close();
		
	});
	
	}else{
		timesheet = { id : null, UserID : req.session.user.ID, Hours : 0, DateOfWork : '', Comment: '', ApprovalStatusID: null };
		res.render(renderPage, {title: 'Timesheet for ' + user.firstname + ' ' + user.lastname, timesheet:timesheet});
	}
};