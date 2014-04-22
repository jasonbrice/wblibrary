
/* ======= This code was tested with version 3.8.1 of Sqlite (3.8.1 2013-10-17 12:57:35 c78be6d786c19073b3a6730dfe3fb1be54f5657a) ========= */
/* ======= To run this code from a command line, navigate to the directory containing the .sqlite database and type:              ========= */
/* =======                                                                                                                        ========= */
/* =======                                                              C:\SomeDirectory>sqlite3 db.sqlite < dml.sql              ========= */
/* =======                                                               ^^ directory ^^          ^ db ^     ^ file^              ========= */

--.echo ON -- turn this off it you want the data insertion to run silently

/* set up affiliations */
delete from Affiliation where 1=1;
insert into Affiliation(Name) values( 'NJHS' );
insert into Affiliation(Name) values( 'NHS' );
insert into Affiliation(Name) values( 'CHAPS' );
insert into Affiliation(Name) values( 'Other' );


/* initial values for user table. NB that only the root admin user specifies the primary key, all others
   get assigned values by the database engine.   */
   
delete from User where 1=1;
   
insert into User(ID, FirstName, LastName, UpdatedBy, IsActive) values(1, 'Westbank', 'Admin', 1, 1);

/* password is sha1 hash of "HothIsCold" */
insert into User(FirstName, LastName, Email, Password, UpdatedBy, IsActive) values('Jason', 'Brice', 'jlbrice@gmail.com', '6196f0440c3902a5631dfdff5b4907ba1c2dd9a5', 1, 1);	

/* password is sha1 hash of "YodaIsWise" */
insert into User(FirstName, LastName, Email, Password, UpdatedBy, IsActive) values('Mary', 'Williams', 'mary@westbanklibrary.com', '214b231e4e6001c7006879b5e32fe36005ac7d8f', 1, 1);

/* password is sha1 hash of "XwingsAreFast" */
insert into User(FirstName, LastName, Email, Password, UpdatedBy, IsActive) values('Chris', 'Brailas', 'chris@westbanklibrary.com', '74bce0eac8ca620063ca4ae0692d3321be84a981', 1, 1);	

/* password is sha1 hash of "WookiesSmellBad" */
insert into User(FirstName, LastName, Email, Password, UpdatedBy, IsActive, AffiliationID) values('Volunteer', 'Test', 'volunteer@test.com', 'c70b6a4f740270880204fbee9c15da5e95211c62', 1, 1, (select ID from Affiliation where name='CHAPS'));	

/* password is sha1 hash of "PadawansAreSmall" */
insert into User(FirstName, LastName, Email, Password, UpdatedBy, IsActive) values('Student', 'Volunteer', 'student@test.com', '7eb7ab06e914b0280752a120fbb6d9378c7dd8e0', 1, 1, (select ID from Affiliation where name='NJHS'));	


/* initial values for Role table */
delete from Role where 1=1;
insert into Role(ID, Name) values(1, 'Admin');
insert into Role(ID, Name) values(2, 'Volunteer');
insert into Role(ID, Name) values(3, 'Student Volunteer');

/* initial values for UserRole resolution table */
delete from UserRole where 1=1;
insert into UserRole(UserID, RoleID) values( (select ID from User where FirstName='Jason' and LastName='Brice'), (select ID from Role where Name='Admin'));
insert into UserRole(UserID, RoleID) values( (select ID from User where FirstName='Mary' and LastName='Williams'), (select ID from Role where Name='Admin'));
insert into UserRole(UserID, RoleID) values( (select ID from User where FirstName='Chris' and LastName='Brailas'), (select ID from Role where Name='Admin'));

/* initial values for ApprovalStatus table */
delete from ApprovalStatus where 1=1;
insert into ApprovalStatus(ID, Name) values(1, 'Pending');
insert into ApprovalStatus(ID, Name) values(2, 'Approved');
insert into ApprovalStatus(ID, Name) values(3, 'Cancelled');


/* test values for timesheet... !!! DELETE !!! when ready for production */

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='student@test.com'), 5, '2014-04-11', 'Friday''s work', 
          (select ID from User where Email='student@test.com'), '2014-04-11 10:00:00', (select ID from User where Email='student@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='student@test.com'), 5, '2014-04-12', 'Saturday!', 
          (select ID from User where Email='student@test.com'), '2014-04-12 10:00:00', (select ID from User where Email='student@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='student@test.com'), 5, '2014-04-13', 'Every day''s like Sunday...', 
          (select ID from User where Email='student@test.com'), '2014-04-12 10:00:00', (select ID from User where Email='student@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='student@test.com'), 5, '2014-04-14', 'Monday Monday', 
          (select ID from User where Email='student@test.com'), '2014-04-13 10:00:00', (select ID from User where Email='student@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);


insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='student@test.com'), 5, '2014-04-15', 'THIS WAS HARD WORK', 
          (select ID from User where Email='student@test.com'), '2014-04-15 10:00:00', (select ID from User where Email='student@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='student@test.com'), 4, '2014-04-16', 'Have I won the lottery yet?', 
          (select ID from User where Email='student@test.com'), '2014-04-16 10:00:00', (select ID from User where Email='student@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='student@test.com'), 5, '2014-04-17', 'I feel so... erudite!', 
          (select ID from User where Email='student@test.com'), '2014-04-17 10:00:00', (select ID from User where Email='mary@westbanklibrary.com'), 
		  (select ID from ApprovalStatus where Name='Approved')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='student@test.com'), 5, '2014-04-17', 'Oops, this is a duplicate.', 
          (select ID from User where Email='student@test.com'), '2014-04-17 10:00:00', (select ID from User where Email='mary@westbanklibrary.com'), 
		  (select ID from ApprovalStatus where Name='Cancelled')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='volunteer@test.com'), 5, '2014-04-11', 'Hooray it''s FRIDAY', 
          (select ID from User where Email='volunteer@test.com'), '2014-04-11 10:00:00', (select ID from User where Email='volunteer@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='volunteer@test.com'), 5, '2014-04-12', 'Caturday?', 
          (select ID from User where Email='volunteer@test.com'), '2014-04-12 10:00:00', (select ID from User where Email='volunteer@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='volunteer@test.com'), 5, '2014-04-13', 'Sunny day Sunday', 
          (select ID from User where Email='volunteer@test.com'), '2014-04-12 10:00:00', (select ID from User where Email='volunteer@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='volunteer@test.com'), 5, '2014-04-14', 'Money day Monday?', 
          (select ID from User where Email='volunteer@test.com'), '2014-04-13 10:00:00', (select ID from User where Email='volunteer@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);


insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='volunteer@test.com'), 5, '2014-04-15', 'I CAN HAZ BOOKS?', 
          (select ID from User where Email='volunteer@test.com'), '2014-04-15 10:00:00', (select ID from User where Email='volunteer@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='volunteer@test.com'), 4, '2014-04-16', 'Help me Dewy Decimal, you''re my only hope', 
          (select ID from User where Email='volunteer@test.com'), '2014-04-16 10:00:00', (select ID from User where Email='volunteer@test.com'), 
		  (select ID from ApprovalStatus where Name='Pending')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='volunteer@test.com'), 5, '2014-04-17', 'Is that Mark Twain frozen in carbonite?', 
          (select ID from User where Email='volunteer@test.com'), '2014-04-17 10:00:00', (select ID from User where Email='mary@westbanklibrary.com'), 
		  (select ID from ApprovalStatus where Name='Approved')
		);

insert into timeentry(UserID, Hours, DateOfWork, Comment, CreatedBy, Updated, UpdatedBy, ApprovalStatusID) 
  values(
          (select ID from User where Email='volunteer@test.com'), 5, '2014-04-17', 'Oops, this is another duplicate.', 
          (select ID from User where Email='volunteer@test.com'), '2014-04-17 10:00:00', (select ID from User where Email='mary@westbanklibrary.com'), 
		  (select ID from ApprovalStatus where Name='Cancelled')
		);
