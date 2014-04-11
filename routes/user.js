
var path = require('path');
var sqlite3 = require('sqlite3').verbose();

var users = null;
var error = null;
var title = null;

exports.list = function(req, res){
	console.log("Accessing: " + __filename);
	
var dbpath = "./database/db.sqlite";
	
	var db = new sqlite3.Database( dbpath, function(err) {
		if (err){
			console.log(err);
			return done( null, false, { message : 'Database problem: ' + err });
		}
	});

	var query = "select u.ID, u.FirstName, u.LastName, u.Email, u.Created, u.Updated, a.Name as Affiliation from User u left outer join Affiliation a on AffiliationID=a.ID where u.IsActive=1;";

	console.log("querying " + path.resolve(dbpath) + " with: " + query);
	
	var errorMessage;
	
	db.all(query, function(err, rows) {
		if (err){
			console.log("Database problem: " + err);
			res.render('user', {error:'Database problem: ' + err});
		}
		if (rows) {
			console.log("found " + rows.length + " results");
			users = rows;
		}else{
			console.log("found 0 results");
		}
		
		res.render('user', {title: 'viewing ' + users.length + ' users', users:users});
		
		db.close();
		
		
	});

	
	
};

