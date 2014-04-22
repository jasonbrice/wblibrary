
/* ======= This code was tested with version 3.8.1 of Sqlite (3.8.1 2013-10-17 12:57:35 c78be6d786c19073b3a6730dfe3fb1be54f5657a) ========= */
/* ======= To run this code from a command line, navigate to the directory containing the .sqlite database and type:              ========= */
/* =======                                                                                                                        ========= */
/* =======                                                              C:\SomeDirectory>sqlite3 db.sqlite < ddl.sql              ========= */
/* =======                                                               ^^ directory ^^          ^ db ^     ^ file^              ========= */
/* =======                                                                                                                        ========= */
/* =======                                                                                                                        ========= */
/* ======= You can perform standard queries on the database by opening a command line session:                                    ==========*/
/* =======                                                                               C:\SomeDirectory>sqlite3 db.sqlite       ========= */
/* ======= Or, use a free GUI tool like sqliteexpert: http://www.sqliteexpert.com/                                                ========= */
/* =======                                                                                                                        ========= */
/* =======                                                                                                                        ========= */
/* =======                             WARNING | WARNING | WARNING | WARNING!!                                                    ========= */
/* =======                              RUNNING THIS SCRIPT WILL DELETE ALL                                                       ========= */
/* =======                              DATA IN YOUR DATABASE. MAKE SURE YOU                                                      ========= */
/* =======                             HAVE A BACKUP IF YOU WANT TO KEEP ANY                                                      ========= */
/* =======                                   EXISTING DATA                                                                        ========= */
/* =======                                                                                                                        ========= */
/* ======================================================================================================================================== */

/** General environment settings *****************************************************/

PRAGMA foreign_keys = ON; -- this one is *really* important for referential integrity
--.echo ON -- turn this off it you want the database creation to run silently

/*************************************************************************************/


drop table if exists TimeEntry;
drop table if exists ApprovalStatus;
drop table if exists UserRole;
drop table if exists User;
drop table if exists Role;
drop table if exists Affiliation;



/*********	Affiliation table  *************************************************************
	____
	|ID				|primary key int not null
	|Name			|text - name of Affiliation (NJHS, NHS, CHAPS, Other)

*************************************************************************************/

create table if not exists Affiliation(
	ID integer primary key asc,
	Name text
);

drop index if exists idx_Affiliation_Name;
create index if not exists idx_Affiliation_Name on Affiliation(Name); 
			

/** User table *************************************************************
	____
	|ID				|primary key int not null
	|FirstName		|text
	|LastName		|text
	|Email          |text - will be used as login
	|Password		|sha1 hashed password
	|Created		|Date/Time
	|Updated		|Date/Time
	|UpdatedBy		|int not null (foreign key constrained to ID of user who updated)
	|IsActive		|bool (inactive users will be retained for history but cannot login and do not show in reports)
	|AffiliationID  |int (foreign key constrained to ID of Affiliation table)

*************************************************************************************/


create table if not exists User(
	ID integer primary key asc, 
	FirstName text, 
	LastName text, 
	Email text,
	Password text,
	Created DATETIME DEFAULT CURRENT_TIMESTAMP,
	Updated DATETIME DEFAULT CURRENT_TIMESTAMP,
	UpdatedBy int, 
	IsActive int, 
	AffiliationID integer, 
	FOREIGN KEY(AffiliationID) REFERENCES Affiliation(ID)
);

drop index if exists idx_fk_User_Affiliation;

create index if not exists idx_fk_User_Affiliation on User(AffiliationID);
	
/*********	Role table  *************************************************************
	____
	|ID				|primary key int not null
	|Name			|text - name of role (Admin, Volunteer, student)

*************************************************************************************/


create table if not exists Role(
	ID integer primary key asc,
	Name text
);

drop index if exists idx_Role_Name;
create index if not exists idx_Role_Name on Role(Name); 

/*********	UserRole table (resolves many-to-many relationship between User and Role) *
	____
	|ID				|primary key int not null
	|RoleID			|int foreign key to Role table
    |UserID			|int foreign key to User table

*************************************************************************************/

drop table if exists UserRole;

create table if not exists UserRole(
	ID integer primary key asc,
	UserID integer,
	RoleID integer,
	FOREIGN KEY(UserID) REFERENCES User(Id),
	FOREIGN KEY(RoleID) REFERENCES Role(Id)
);

drop index if exists idx_fk_UserRole_User;
drop index if exists idx_fk_UserRole_Role;

create index if not exists idx_fk_UserRole_User on UserRole(UserID); 
create index if not exists idx_fk_UserRole_Role on UserRole(RoleID);
	


/*********	ApprovalStatus table  *************************************************************
	____
	|ID				|primary key int not null
	|Name			|text - name of status (Pending, Approved, Cancelled)

*************************************************************************************/


create table if not exists ApprovalStatus(
	ID integer primary key asc,
	Name text
);

drop index if exists idx_ApprovalStatus_Name;
create index if not exists idx_ApprovalStatus_Name on ApprovalStatus(Name); 

	
/**	TimeEntry table *************************************************************
	_____
	|ID					|primary key int not null
	|UserID				|foreign key int constrained to User table ID
	|Hours				|double not null default 0.0
	|DateOfWork         |the actual day volunteer time occurred (may be different than entry date)
	|Comment			|text - any notes about time
	|Created			|Date/Time initial record creation
	|CreatedBy			|foreign key int constrained to User table ID
	|Updated			|Date/Time most recent record update
	|UpdatedBy			|foreign key int constrained to User table ID
	|ApprovalStatusID	|foreign key int constrained to ApprovalStatus table ID

*************************************************************************************/


create table if not exists TimeEntry(
	ID integer primary key asc,
	UserID integer,
	Hours number,
	DateOfWork DATETIME DEFAULT CURRENT_TIMESTAMP,
	Comment text, 
	Created DATETIME DEFAULT CURRENT_TIMESTAMP,
	CreatedBy integer,
	Updated DATETIME DEFAULT CURRENT_TIMESTAMP,
	UpdatedBy integer,
	ApprovalStatusID integer, 
	FOREIGN KEY(UserID) REFERENCES User(Id),
	FOREIGN KEY(CreatedBy) REFERENCES User(Id),
	FOREIGN KEY(UpdatedBy) REFERENCES User(Id), 
	FOREIGN KEY(ApprovalStatusID) REFERENCES ApprovalStatus(ID)
);	

drop index if exists idx_fk_TimeEntry_User;
drop index if exists idx_fk_TimeEntry_Created;
drop index if exists idx_fk_TimeEntry_UpdatedBy;
drop index if exists idx_fk_TimeEntry_ApprovalStatus;

create index if not exists idx_fk_TimeEntry_User on TimeEntry(UserID);
create index if not exists idx_fk_TimeEntry_Created on TimeEntry(CreatedBy);
create index if not exists idx_fk_TimeEntry_UpdatedBy on TimeEntry(UpdatedBy);
create index if not exists idx_fk_TimeEntry_ApprovalStatus on TimeEntry(ApprovalStatusID); 



/* ======================= VIEWS =========================================	 */


drop view if exists TIMESHEETS;

/* Flatten the normalized relationship between user/timesheet (and user/user), do some formatting on data */
CREATE VIEW IF NOT EXISTS TIMESHEETS AS 
   select t.ID, u.FirstName || ' ' || u.LastName as Name,
   t.Hours, date(t.DateOfWork) as DateOfWork, 
   t.Comment, t.Created, t.Updated as Updated, u2.FirstName || ' ' || u2.LastName as CreatedByName, 
   u3.FirstName || ' ' || u3.LastName as UpdatedByName, a.Name as ApprovalStatus, 
   case when af.Name is null then 'None' else af.Name end as Affiliation, 
   u.ID as UserID, u2.ID as CreatedByID, u3.ID as UpdatedByID, af.ID as AffiliationID, 
   a.ID as ApprovalStatusID
   from TimeEntry t 
   left outer join User u on t.UserID = u.ID
   left outer join User u2 on t.CreatedBy = u2.ID
   left outer join User u3 on t.UpdatedBy = u3.ID
   left outer join Affiliation af on u.AffiliationID = af.ID
   left outer join ApprovalStatus a on t.ApprovalStatusID = a.ID;
   
   
   
drop view if exists USERS;

/* Flatten the normalized relationship between user/user, do some formatting on data */
CREATE VIEW IF NOT EXISTS USERS AS
  select 
  u.ID, u.FirstName, u.LastName, u.FirstName || ' ' || u.LastName as Name, 
  u.Email, u.Created, u.Updated, u2.FirstName || ' ' || u2.LastName as UpdatedByName, 
  case when u.IsActive=1 then 'Active' else 'Inactive' end as Status, 
  case when a.Name is null then 'None' else a.Name end as Affiliation
  
  from User u
  left outer join User u2 on u.UpdatedBy = u2.ID
  left outer join Affiliation a on u.AffiliationID = a.Id;
  
 