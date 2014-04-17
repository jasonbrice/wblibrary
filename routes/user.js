
var path = require('path');
var sqlite3 = require('sqlite3').verbose();
var expressValidator = require("express-validator");

var users = null;
var errors;
var title = null;
var affiliations = null;

var dbpath = "./database/db.sqlite";

var db;

exports.list = function(req, res){
	
	console.log("Accessing: " + __filename);
	
	var renderPage = "user_list";
	
	db = new sqlite3.Database( dbpath, function(err) {
		if (err){
			console.log(err);
			return done( null, false, { message : 'Database problem: ' + err });
		}
	});

	var query = "select u.ID, u.FirstName, u.LastName, u.Email, u.Created, u.Updated, case when u.IsActive then 'Active' else 'Inactive' end as IsActive, a.Name as Affiliation from User u left outer join Affiliation a on AffiliationID=a.ID where u.IsActive=1;";

	console.log("querying " + path.resolve(dbpath) + " with: " + query);
	
	db.all(query, function(err, rows) {
		if (err){
			console.log("Database problem: " + err);
			res.render(renderPage, {error:'Database problem: ' + err});
		}
		if (rows) {
			console.log("found " + rows.length + " users");
			users = rows;
		}else{
			console.log("found 0 results");
		}
		
		console.log('Rendering ' + renderPage);
		
		res.render(renderPage, {title: 'Viewing ' + users.length + ' users', users:users});
		
		db.close();
		
	});
	
};

exports.save = function(req, res){
	
	console.log("Accessing: " + __filename);
	
	req.assert('FirstName','Please enter a first name').notEmpty();
	req.assert('LastName','Please enter a last name').notEmpty();
	req.assert('Email','Please enter a valid email address').notEmpty();
	req.assert('AffiliationId','Please select an affiliation').notEmpty();
	
	errors = req.validationErrors();  
	
	if(errors){
		
		errors.forEach(function(error){ console.log('Error! ' + error.msg);});
		
		exports.edit(req, res, {errors: errors});
	}
	else{
		
		var update = "update User set"
			+" FirstName='" + req.body.FirstName + "'"
			+" ,LastName='" + req.body.LastName + "'"
			+" ,Email='" + req.body.Email + "'"
			+" ,AffiliationId=" + req.body.AffiliationId 
			+" ,Updated=date('now')"
			+" ,UpdatedBy=" + req.session.user.id
			+ " where ID=" + req.body.id + ";";
		
		console.log('updating user with query: ' + update);
		
		db = new sqlite3.Database( dbpath, function(err) {
			if (err){
				console.log(err);
				exports.edit(req, res, {errors: err});
			}
		});
		
		db.serialize(function(){
			db.run(update, function(err) {
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
	
	db = new sqlite3.Database( dbpath, function(err) {
		if (err){
			console.log(err);
			return done( null, false, { message : 'Database problem: ' + err });
		}
	});
	
	readUserRow(req, res);
	
}; 


function readUserRow(req, res){
	
	var id = req.params.id;
		
	var query = "select u.ID, u.FirstName, u.LastName, u.Email, u.Created, u.Updated, u.IsActive, a.Name as Affiliation, u.AffiliationID as AffiliationId from User u left outer join Affiliation a on u.AffiliationID=a.ID where u.IsActive=1 and u.ID=" + id + ";";

	console.log("querying " + path.resolve(dbpath) + " with: " + query);
	
	db.get(query, function(err, row) {
		if (err){
			console.log("Database problem: " + err);
			res.render('renderPage', {error:'Database problem: ' + err});
		}
		if (row) {
			console.log("found results");
			users = row;
			readAffiliationRows(req, res);
		}else{
			console.log("found 0 results");
		}
		
	});
}


function readAffiliationRows(req, res){
	
	var query = " select * from Affiliation;";
	
	console.log("query: " + query);

	db.all(query, function(err, rows) {
		affiliations = rows;        
        console.log("Found: " + rows.length + " affiliations");
        renderUserAndClose(req, res);
    });
}


function renderUserAndClose(req, res){
	
	title =  "Viewing " + users.FirstName + " " + users.LastName;
	
	console.log(title);
	
	db.close();
	
	res.render('user_edit', {title: title, users: users, affiliations: affiliations, errors: errors});
	 
    
}
