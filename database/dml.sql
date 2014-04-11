
/* ======= This code was tested with version 3.8.1 of Sqlite (3.8.1 2013-10-17 12:57:35 c78be6d786c19073b3a6730dfe3fb1be54f5657a) ========= */
/* ======= To run this code from a command line, navigate to the directory containing the .sqlite database and type:              ========= */
/* =======                                                                                                                        ========= */
/* =======                                                              C:\SomeDirectory>sqlite3 db.sqlite < dml.sql              ========= */
/* =======                                                               ^^ directory ^^          ^ db ^     ^ file^              ========= */

--.echo ON -- turn this off it you want the data insertion to run silently

/* set up affiliations */
insert into Affiliation(Name) values( 'NJHS' );
insert into Affiliation(Name) values( 'NHS' );
insert into Affiliation(Name) values( 'CHAPS' );
insert into Affiliation(Name) values( 'Other' );


/* initial values for user table. NB that only the root admin user specifies the primary key, all others
   get assigned values by the database engine.   */
insert into User(ID, FirstName, LastName, UpdatedBy, IsActive) values(1, 'Westbank', 'Admin', 1, 1);

/* password is sha1 hash of "HothIsCold" */
insert into User(FirstName, LastName, Email, Password, UpdatedBy, IsActive) values('Jason', 'Brice', 'jlbrice@gmail.com', '74bce0eac8ca620063ca4ae0692d3321be84a981', 1, 1);	

/* password is sha1 hash of "YodaIsWise" */
insert into User(FirstName, LastName, Email, Password, UpdatedBy, IsActive) values('Mary', 'Williams', 'mary@westbanklibrary.com', '214b231e4e6001c7006879b5e32fe36005ac7d8f', 1, 1);

/* password is sha1 hash of "XwingsAreFast" */
insert into User(FirstName, LastName, Email, Password, UpdatedBy, IsActive) values('Chris', 'Brailas', 'chris@westbanklibrary.com', '6196f0440c3902a5631dfdff5b4907ba1c2dd9a5', 1, 1);	

/* initial values for Role table */
insert into Role(ID, Name) values(1, 'Admin');
insert into Role(ID, Name) values(2, 'Volunteer');
insert into Role(ID, Name) values(3, 'Student Volunteer');

/* initial values for UserRole resolution table */
insert into UserRole(UserID, RoleID) values( (select ID from User where FirstName='Jason' and LastName='Brice'), (select ID from Role where Name='Admin'));
insert into UserRole(UserID, RoleID) values( (select ID from User where FirstName='Mary' and LastName='Williams'), (select ID from Role where Name='Admin'));
insert into UserRole(UserID, RoleID) values( (select ID from User where FirstName='Chris' and LastName='Brailas'), (select ID from Role where Name='Admin'));

;
