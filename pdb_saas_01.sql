use master;
begin
declare @sql nvarchar(max);
select @sql = coalesce(@sql,'') + 'kill ' + convert(varchar, spid) + ';'
from master..sysprocesses
where dbid in (db_id('SaaSGate'),db_id('AtlanticDB'),db_id('CaribbeanDB'),db_id('MonacoDB')) and cmd = 'AWAITING COMMAND' and spid <> @@spid;
exec(@sql);
end;
go

if db_id('SaaSGate') 		is not null drop database SaaSGate;
if db_id('AtlanticDB') 		is not null drop database AtlanticDB;
if db_id('CaribbeanDB')  	is not null drop database CaribbeanDB;
if db_id('MonacoDB') 		is not null drop database MonacoDB;
create database AtlanticDB;
create database CaribbeanDB;
create database MonacoDB;
use PdbLogic;
exec Pdbinstall 'SaaSGate',@ColumnName='BrandId';
go
use SaaSGate;
exec PdbcreatePartition 'SaaSGate','AtlanticDB',1;
exec PdbcreatePartition 'SaaSGate','CaribbeanDB',2;
exec PdbcreatePartition 'SaaSGate','MonacoDB',3;

create table Brands
	(	BrandId				PartitionDBType			not null primary key
	,	Name				nvarchar(128)			not null unique
	);	
	
create table Games	
	(	BrandId				PartitionDBType			not null references Brands (BrandId)
	,	Id					tinyint					not null primary key
	,	Name				nvarchar(128)			not null unique
	,	Rules				nvarchar(500)
	);	
	
create table Dealers
	(	BrandId				PartitionDBType			not null references Brands (BrandId)
	,	Id					smallint identity(1,1) 	not null primary key
	,	DealerNumber		nvarchar(16)			not null unique
	,	FirstName			nvarchar(128)			not null
	,	LastName			nvarchar(128)			not null
	);
	
create table Players
	(	BrandId				PartitionDBType			not null references Brands (BrandId)
	,	Id					smallint identity(1,1) 	not null primary key
	,	PlayerNumber		nvarchar(16)			not null unique
	,	FirstName			nvarchar(128)			not null
	,	LastName			nvarchar(128)			not null
	,	EMail				nvarchar(128)	
	,	PhoneNumber			nvarchar(64)
	,	Country				nvarchar(2)
	,	City				nvarchar(128)
	,	Address				nvarchar(256)
	,	PostalCode			nvarchar(8)	
	,	Birthdate			date					
	,	NationalNumber		nvarchar(16)			
	,	ChipsPurchased		smallint				not null
	,	ChipsBet			smallint				not null
	,	ChipsWon			smallint				not null
	,	ChipsCashed			smallint				not null
	);
		
create table Tables	
	(	BrandId				PartitionDBType			not null references Brands (BrandId)
	,	Id					smallint identity(1,1) 	not null primary key
	,	TableNumber			nvarchar(16)			not null unique
	,	GameId				tinyint					not null references Games (Id)
	,	NextRoundDate		smalldatetime			
	,	MinimumPlayers		tinyint
	,	MaximumPlayers		tinyint
	,	MinimumPlayerChips	smallint
	,	MinimumTableChips	smallint
	,	MinimumRoundChips	smallint
	);	
	
create table Rounds
	(	BrandId				PartitionDBType			not null references Brands (BrandId)
	,	Id					bigint identity(1,1) 	not null primary key
	,	TableId				smallint				not null references Tables (Id)
	,	DealerId			smallint				not null references Dealers (Id)
	,	WinValue			nvarchar(512)			
	);
	
create table Bets
	(	BrandId				PartitionDBType			not null references Brands (BrandId)
	,	Id					bigint identity(1,1) 	not null primary key
	,	RoundId				bigint					not null references Rounds (Id)
	,	PlayerId			smallint				not null references Players (Id)
	,	Value				nvarchar(512)			not null
	,	ChipsBet			smallint				not null
	);
	
create table Wins
	(	BrandId				PartitionDBType			not null references Brands (BrandId)
	,	Id					bigint identity(1,1) 	not null primary key
	,	BetId				bigint					not null references Bets (Id)
	,	ChipsWon			smallint				not null
	);

	
insert into PdbBrands (BrandId,Name) values (1,'Atlantic');
insert into PdbBrands (BrandId,Name) values (2,'Caribbean');
insert into PdbBrands (BrandId,Name) values (3,'Monaco');
	
insert into PdbGames (Id,Name) values (1,'Black Jack');
insert into PdbGames (Id,Name) values (2,'Texas Holdem');
insert into PdbGames (Id,Name) values (3,'Roulette');
insert into PdbGames (Id,Name) values (4,'Spades');
insert into PdbGames (Id,Name) values (5,'Craps');
	
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (1,'00001','Jessica','Rabbit');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (1,'00002','Betty','Rubble');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (1,'00003','Lois','Griffin');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (1,'00004','Lola','Bunny');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (2,'00005','Daisy','Duck');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (2,'00006','Tinker','Bell');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (2,'00007','Lara','Croft');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (2,'00008','Betty','Boop');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (3,'00009','Aeon','Flux');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (3,'00010','Harley','Quinn');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (3,'00011','Princess','Jasmine');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (3,'00012','Marge','Simpson');

insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (1,'00001','Daniel','Negreanu',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (1,'00002','Jack','McClelland',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (1,'00003','Tom','McEvoy',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (1,'00004','Bryan','Roberts',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (1,'00005','Eric','Drache',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (1,'00006','Barry','Greenstein',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (1,'00007','Erik','Seidel',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (2,'00008','Dan','Harrington',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (2,'00009','Mike','Sexton',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (2,'00010','Henry','Orenstein',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (2,'00011','Dewey','Tomko',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (2,'00012','Phil','Hellmuth',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (2,'00013','Billy','Baxter',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (2,'00014','Jack','Binion',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (3,'00015','Berry','Johnston',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (3,'00016','Bobby','Baldwin',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (3,'00017','Johnny','Chan',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (3,'00018','Lyle','Berman',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (3,'00019','Roger','Moore',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (3,'00020','Jack','Keller',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (3,'00021','Thomas','Preston',0,0,0,0);

insert into PdbTables (BrandId,TableNumber,GameId) values (1,'001-0001-00001',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (1,'001-0001-00002',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (1,'001-0002-00003',2);
insert into PdbTables (BrandId,TableNumber,GameId) values (1,'001-0002-00004',2);
insert into PdbTables (BrandId,TableNumber,GameId) values (1,'001-0003-00005',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (1,'001-0003-00006',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (1,'001-0004-00007',4);
insert into PdbTables (BrandId,TableNumber,GameId) values (1,'001-0005-00008',5);
insert into PdbTables (BrandId,TableNumber,GameId) values (2,'002-0001-00009',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (2,'002-0001-00010',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (2,'002-0002-00011',2);
insert into PdbTables (BrandId,TableNumber,GameId) values (2,'002-0002-00012',2);
insert into PdbTables (BrandId,TableNumber,GameId) values (2,'002-0003-00013',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (2,'002-0003-00014',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (2,'002-0004-00015',4);
insert into PdbTables (BrandId,TableNumber,GameId) values (2,'002-0005-00016',5);
insert into PdbTables (BrandId,TableNumber,GameId) values (3,'003-0001-00017',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (3,'003-0001-00018',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (3,'003-0002-00019',2);
insert into PdbTables (BrandId,TableNumber,GameId) values (3,'003-0002-00020',2);
insert into PdbTables (BrandId,TableNumber,GameId) values (3,'003-0003-00021',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (3,'003-0003-00022',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (3,'003-0004-00023',4);
insert into PdbTables (BrandId,TableNumber,GameId) values (3,'003-0005-00024',5);