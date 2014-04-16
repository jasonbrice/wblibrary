/**
 * Module dependencies.
 */

var routes = require('./routes');
var user = require('./routes/user');
var http = require('http');
var path = require('path');
var express = require('express'), passport = require('passport'), flash = require('connect-flash'), LocalStrategy = require('passport-local').Strategy;
var sqlite3 = require('sqlite3').verbose();
var sha1 = require('sha1');
var users= [{}];

function findById(id, fn) {
	var idx = id - 1;
	if (users[idx]) {
		fn(null, users[idx]);
	} else {
		fn(new Error('User ' + id + ' does not exist'));
	}
}


// Passport session setup.
// To support persistent login sessions, Passport needs to be able to
// serialize users into and deserialize users out of the session. Typically,
// this will be as simple as storing the user ID when serializing, and finding
// the user by ID when deserializing.
passport.serializeUser(function(user, done) {
	console.log('serializeUser');
	done(null, user.id);
});

passport.deserializeUser(function(id, done) {
	console.log('deserializeUser');
	findById(id, function(err, user) {
		done(err, user);
	});
});

// Use the LocalStrategy within Passport.
// Strategies in passport require a `verify` function, which accept
// credentials (in this case, a username and password), and invoke a callback
// with a user object. In the real world, this would query a database;
// however, in this example we are using a baked-in set of users.
passport.use(new LocalStrategy( function(username, password, done) {

	// Find the user by username. If there is no user with the given
	// username, or the password is not correct, set the user to `false` to
	// indicate failure and set a flash message. Otherwise, return the
	// authenticated `user`.
	//findByUsername( username, function(err, user) {

	var dbpath = "./database/db.sqlite";
	
	var db = new sqlite3.Database( dbpath, function(err) {
		if (err){
			console.log(err);
			return done( null, false, { message : 'Database problem: ' + err });
		}
	});

	var query = "select ID, FirstName, LastName, Email, Password, IsActive from User where lower(Email)='" + username.toLowerCase().trim() + "';";

	console.log("querying " + path.resolve(dbpath) + " with: " + query);

	db.get(query, function(err, row) {
		if (err){
			console.log(err);
			console.log("Database problem:");
			return done(null,false, {message : 'Database problem: ' + err});
		}
		if (row) {
			var user = { id : row.ID, username : row.Email, password : row.Password, email : row.Email };

			
			if (user.password === sha1(password)) 
			{
				users.push(user); // add user to known users
				console.log("Matching user found");
				return done( null, user); 

			} else {
				console.log("Invalid password");
				return done( null, false, { message : 'Invalid password' });
			}

		} else {
			console.log("Unknown user");
			return done( null, false, { message : 'Unknown user ' + username });
		}
		
		db.close();
		
	});

}));



var app = express();

var passport = require('passport'), LocalStrategy = require('passport-local').Strategy;


// all environments
app.set('port', process.env.PORT || 3045);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');

app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.static(path.join(__dirname, 'public')));/* app.use(express.static('public')); */
app.use(express.cookieParser());
app.use(express.session({
	secret : 'MTFBWY'
}));
app.use(flash());
app.use(passport.initialize());
app.use(passport.session());
app.use(app.router);

// development only
if ('development' == app.get('env')) {
	app.use(express.errorHandler());
}

app.get('/', routes.index);
app.get('/users', user.list);


// GET /login
// we're using a local implementation (rather than OAuth)
// https://github.com/jaredhanson/passport-local/blob/master/examples/login/app.js
app.get('/login', function(req, res) {
	res.render('login', {
		user : req.user,
		message : req.flash('error')
	});
});

// POST /login
// Use passport.authenticate() as route middleware to authenticate the
// request. If authentication fails, the user will be redirected back to the
// login page. Otherwise, the primary route function function will be called,
// which, in this example, will redirect the user to the home page.
//
// curl -v -d "username=bob&password=secret" http://localhost:3045/login
app.post('/login', passport.authenticate('local', {
	failureRedirect : '/login',
	failureFlash : true
}), function(req, res) {
	console.log('login success, redirecting to root');
	res.redirect('/');
});

app.get('/logout', function(req, res) {
	req.logout();
	res.redirect('/');
});

//register the route to view a list of users
app.get('/users/list', user.list);

// id will be available as req.params.id;
app.get('/users/edit/:id', user.edit);

http.createServer(app).listen(app.get('port'), function() {
	console.log('Express server listening on port ' + app.get('port'));
});

// Simple route middleware to ensure user is authenticated.
// Use this route middleware on any resource that needs to be protected. If
// the request is authenticated (typically via a persistent login session),
// the request will proceed. Otherwise, the user will be redirected to the
// login page.
function ensureAuthenticated(req, res, next) {
	if (req.isAuthenticated()) {
		console.log("user is authenticated");
		return next();
	}
	console.log("user is not authenticated, redirecting to login page");
	res.redirect('/login');
}
