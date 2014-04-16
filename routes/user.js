
var path = require('path');
var sqlite3 = require('sqlite3').verbose();

var users = null;
var error = null;
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

	var query = "select u.ID, u.FirstName, u.LastName, u.Email, u.Created, u.Updated, a.Name as Affiliation from User u left outer join Affiliation a on AffiliationID=a.ID where u.IsActive=1;";

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

exports.edit = function(req, res){
	
	console.log("Accessing: " + __filename);
	
	db = new sqlite3.Database( dbpath, function(err) {
		if (err){
			console.log(err);
			return done( null, false, { message : 'Database problem: ' + err });
		}
	});
	
	readUserRow(req, res);
	
}


function readUserRow(req, res){
	
	var id = req.params.id;
		
	var query = "select u.ID, u.FirstName, u.LastName, u.Email, u.Created, u.Updated, a.Name as Affiliation, u.AffiliationID as AffiliationId from User u left outer join Affiliation a on u.AffiliationID=a.ID where u.IsActive=1 and u.ID=" + id + ";";

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
        renderAndClose(req, res);
    });
}


function renderAndClose(req, res){
	
	title =  "Viewing " + users.FirstName + " " + users.LastName;
	
	console.log(title);
	
	db.close();
	
	res.render('user_edit', {title: title, users: users, affiliations: affiliations});
	 
    
}
