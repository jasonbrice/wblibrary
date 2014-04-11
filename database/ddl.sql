
/* ======= This code was tested with version 3.8.1 of Sqlite (3.8.1 2013-10-17 12:57:35 c78be6d786c19073b3a6730dfe3fb1be54f5657a) ========= */
/* ======= To run this code from a command line, navigate to the directory containing the .sqlite database and type:              ========= */
/* =======                                                                                                                        ========= */
/* =======                                                              C:\SomeDirectory>sqlite3 db.sqlite < ddl.sql              ========= */
/* =======                                                               ^^ directory ^^          ^ db ^     ^ file^              ========= */

/** General environment settings *****************************************************/

PRAGMA foreign_keys = ON; -- this one is *really* important for referential integrity
--.echo ON -- turn this off it you want the database creation to run silently

/*************************************************************************************/

drop table if exists TimeEntry;
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
	


	
/**	TimeEntry table *************************************************************
	_____
	|ID				|primary key int not null
	|UserID			|foreign key int constrained to User table ID
	|Hours			|double not null default 0.0
	|Created		|Date/Time initial record creation
	|CreatedBy		|foreign key int constrained to User table ID
	|Updated		|Date/Time most recent record update
	|UpdatedBy		|foreign key int constrained to User table ID

*************************************************************************************/



create table if not exists TimeEntry(
	ID integer primary key asc,
	UserID integer,
	Hours number,
	Comment text, 
	Created DATETIME DEFAULT CURRENT_TIMESTAMP,
	CreatedBy integer,
	Updated DATETIME DEFAULT CURRENT_TIMESTAMP,
	UpdatedBy integer,
	FOREIGN KEY(UserID) REFERENCES User(Id),
	FOREIGN KEY(CreatedBy) REFERENCES User(Id),
	FOREIGN KEY(UpdatedBy) REFERENCES User(Id)
);	

drop index if exists idx_fk_TimeEntry_User;
drop index if exists idx_fk_TimeEntry_Created;
drop index if exists idx_fk_TimeEntry_UpdatedBy;

create index if not exists idx_fk_TimeEntry_User on TimeEntry(UserID);
create index if not exists idx_fk_TimeEntry_Created on TimeEntry(CreatedBy);
create index if not exists idx_fk_TimeEntry_UpdatedBy on TimeEntry(UpdatedBy);

	
	