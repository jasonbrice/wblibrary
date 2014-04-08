
/** General environment settings *****************************************************/

PRAGMA foreign_keys = ON; -- this one is *really* important for referential integrity

/*************************************************************************************/



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

drop table if exists User;

create table if not exists User(
	ID integer primary key asc, 
	FirstName text, 
	LastName text, 
	Email text,
	Password text,
	Created DATETIME DEFAULT CURRENT_TIMESTAMP,
	Updated DATETIME DEFAULT CURRENT_TIMESTAMP,
	UpdatedBy int, 
	IsActive int
);

			
	
/*********	Role table  *************************************************************
	____
	|ID				|primary key int not null
	|Name			|text - name of role (Admin, Volunteer, student)

*************************************************************************************/

drop table if exists Role;

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

drop table if exists TimeEntry;

create table if not exists TimeEntry(
	ID integer primary key asc,
	UserID integer,
	Hours number,
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

	
	