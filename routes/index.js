
/*
 * GET home page.
 */

exports.index = function(req, res){
	
	var title = 'Westbank Community Library Time Tracker';
	var message = req.session.user ? 'Welcome, ' + req.session.user.firstname + '!' : 'Welcome! Please log in to continue.';
	res.render('index', { title: title, message: message, user: req.session.user });
	
};