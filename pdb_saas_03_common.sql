use master;
begin
declare @sql nvarchar(max);
select @sql = coalesce(@sql,'') + 'kill ' + convert(varchar, spid) + ';'
from master..sysprocesses
where dbid in (db_id('SaaSGate'),db_id('AtlanticDB'),db_id('CaribbeanDB'),db_id('MonacoDB'),db_id('SaaSGlobalDB'),db_id('SaaSCommonDB')) and cmd = 'AWAITING COMMAND' and spid <> @@spid;
exec(@sql);
end;
go

if db_id('SaaSGate') 		is not null drop database SaaSGate;
if db_id('SaaSCommonDB') 	is not null drop database SaaSCommonDB;
if db_id('SaaSGlobalDB') 	is not null drop database SaaSGlobalDB;
if db_id('AtlanticDB') 		is not null drop database AtlanticDB;
if db_id('CaribbeanDB')  	is not null drop database CaribbeanDB;
if db_id('MonacoDB') 		is not null drop database MonacoDB;
create database SaaSCommonDB;
create database SaaSGlobalDB;
create database AtlanticDB;
create database CaribbeanDB;
create database MonacoDB;
use PdbLogic;
exec Pdbinstall 'SaaSGate',@ColumnName='BrandId';
go
use SaaSGate;
exec PdbcreatePartition 'SaaSGate','SaaSCommonDB',@DatabaseTypeId=2;
exec PdbcreatePartition 'SaaSGate','SaaSGlobalDB',@DatabaseTypeId=3;
exec PdbcreatePartition 'SaaSGate','AtlanticDB',1;
exec PdbcreatePartition 'SaaSGate','CaribbeanDB',2;
exec PdbcreatePartition 'SaaSGate','MonacoDB',3;

create table Brands
	(	Id					tinyint					not null primary key
	,	Name				nvarchar(128)			not null unique
	);	
	
create table Games	
	(	Id					tinyint					not null primary key
	,	Name				nvarchar(128)			not null unique
	,	Rules				nvarchar(500)
	);	
	
create table Dealers
	(	BrandId				PartitionDBType			not null references Brands (Id)
	,	Id					smallint identity(1,1) 	not null primary key
	,	DealerNumber		nvarchar(16)			not null unique
	,	FirstName			nvarchar(128)			not null
	,	LastName			nvarchar(128)			not null
	);
	
create table Players
	(	BrandId				PartitionDBType			not null references Brands (Id)
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
	(	BrandId				PartitionDBType			not null references Brands (Id)
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
	(	BrandId				PartitionDBType			not null references Brands (Id)
	,	Id					bigint identity(1,1) 	not null primary key
	,	TableId				smallint				not null references Tables (Id)
	,	DealerId			smallint				not null references Dealers (Id)
	,	WinValue			nvarchar(512)			
	);
	
create table Bets
	(	BrandId				PartitionDBType			not null references Brands (Id)
	,	Id					bigint identity(1,1) 	not null primary key
	,	RoundId				bigint					not null references Rounds (Id)
	,	PlayerId			smallint				not null references Players (Id)
	,	Value				nvarchar(512)			not null
	,	ChipsBet			smallint				not null
	);
	
create table Wins
	(	BrandId				PartitionDBType			not null references Brands (Id)
	,	Id					bigint identity(1,1) 	not null primary key
	,	BetId				bigint					not null references Bets (Id)
	,	ChipsWon			smallint				not null
	);
	
insert into PdbBrands (Id,Name) values (1,'Atlantic');
insert into PdbBrands (Id,Name) values (2,'Caribbean');
insert into PdbBrands (Id,Name) values (3,'Monaco');
insert into PdbBrands (Id,Name) values (4,'Macau');
insert into PdbBrands (Id,Name) values (5,'Las Vegas');
insert into PdbBrands (Id,Name) values (6,'Sun City');
		
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
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (4,'00013','Poison','Ivy');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (4,'00014','Turanga','Leela');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (5,'00015','April','ONeil');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (5,'00016','MaryJane','Watson');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (6,'00017','Cheryl','Blossom');
insert into PdbDealers (BrandId,DealerNumber,FirstName,LastName) values (6,'00018','Selena','Kyle');

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
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (4,'00022','David','Reese',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (4,'00023','Benny','Binion',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (5,'00024','Fred','Ferris',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (5,'00025','Jack','Straus',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (6,'00026','Doyle','Brunson',0,0,0,0);
insert into PdbPlayers (BrandId,PlayerNumber,FirstName,LastName,ChipsPurchased,ChipsBet,ChipsWon,ChipsCashed) values (6,'00027','Henry','Green',0,0,0,0);

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
insert into PdbTables (BrandId,TableNumber,GameId) values (4,'004-0001-00025',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (4,'004-0001-00026',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (4,'004-0003-00027',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (4,'004-0003-00028',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (5,'005-0001-00029',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (5,'005-0001-00030',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (5,'005-0003-00031',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (5,'005-0003-00032',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (6,'006-0001-00033',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (6,'006-0001-00034',1);
insert into PdbTables (BrandId,TableNumber,GameId) values (6,'006-0003-00035',3);
insert into PdbTables (BrandId,TableNumber,GameId) values (6,'006-0003-00036',3);

create synonym Employees for Dealers;
go
create synonym Customers for Players;
go

create view TopDealers
as
	select Dealers.BrandId,Dealers.Id,Dealers.DealerNumber,Dealers.FirstName,Dealers.LastName,Brands.Name BrandName,isnull(Rounds.ChipsGained,0) ChipsGained
	from PdbDealers Dealers
	join PdbBrands 	Brands on Dealers.BrandId = Brands.Id
	left join (	select Rounds.BrandId,Rounds.DealerId,isnull(sum(Bets.ChipsBet)-isnull(sum(Wins.ChipsWon),0),0) ChipsGained
				from PdbRounds Rounds
				left join PdbBets Bets on Rounds.BrandId = Bets.BrandId and Rounds.Id = Bets.RoundId
				left join PdbWins Wins on Bets.BrandId = Wins.BrandId and Bets.Id = Wins.BetId
				group by Rounds.BrandId,Rounds.DealerId) Rounds on Dealers.BrandId = Rounds.BrandId and Dealers.Id = Rounds.DealerId;
go

create view TopPlayers
as				
	select Players.BrandId,Players.Id,Players.PlayerNumber,Players.FirstName,Players.LastName,isnull(Rounds.ChipsEarned,0) ChipsEarned
	from PdbPlayers Players
	join PdbBrands 	Brands on Players.BrandId = Brands.Id
	left join (	select Rounds.BrandId,Bets.PlayerId,isnull(sum(Wins.ChipsWon)-isnull(sum(Bets.ChipsBet),0),0) ChipsEarned
				from PdbRounds Rounds
				join PdbBets Bets on Rounds.BrandId = Bets.BrandId and Rounds.Id = Bets.RoundId
				left join PdbWins Wins on Bets.BrandId = Wins.BrandId and Bets.Id = Wins.BetId
				group by Rounds.BrandId,Bets.PlayerId) Rounds on Players.BrandId = Rounds.BrandId and Players.Id = Rounds.PlayerId;
go
				
if object_id('getTopDealers','P') is not null drop procedure getTopDealers
go 
create procedure getTopDealers-- 
as
begin
	select top 10 Dealers.DealerNumber,Dealers.FirstName,Dealers.LastName,Brands.Name BrandName,isnull(Rounds.ChipsGained,0) ChipsGained
	from PdbDealers Dealers
	join PdbBrands 	Brands on Dealers.BrandId = Brands.Id
	left join (	select Rounds.BrandId,Rounds.DealerId,isnull(sum(Bets.ChipsBet)-isnull(sum(Wins.ChipsWon),0),0) ChipsGained
				from PdbRounds Rounds
				left join PdbBets Bets on Rounds.BrandId = Bets.BrandId and Rounds.Id = Bets.RoundId
				left join PdbWins Wins on Bets.BrandId = Wins.BrandId and Bets.Id = Wins.BetId
				group by Rounds.BrandId,Rounds.DealerId) Rounds on Dealers.BrandId = Rounds.BrandId and Dealers.Id = Rounds.DealerId
	order by isnull(Rounds.ChipsGained,0) desc;
end;
go

if object_id('getTopDealersPU','P') is not null drop procedure getTopDealersPU
go 
create procedure getTopDealersPU-- 
	(	@BrandId tinyint = null
	)
as
begin
	select top 10 Dealers.DealerNumber,Dealers.FirstName,Dealers.LastName,Brands.Name BrandName,isnull(Rounds.ChipsGained,0) ChipsGained
	from Dealers
	join Brands	on Dealers.BrandId = Brands.Id
	left join (	select Rounds.BrandId,Rounds.DealerId,isnull(sum(Bets.ChipsBet)-isnull(sum(Wins.ChipsWon),0),0) ChipsGained
				from Rounds
				left join Bets on Rounds.BrandId = Bets.BrandId and Rounds.Id = Bets.RoundId
				left join Wins on Bets.BrandId = Wins.BrandId and Bets.Id = Wins.BetId
				group by Rounds.BrandId,Rounds.DealerId) Rounds on Dealers.BrandId = Rounds.BrandId and Dealers.Id = Rounds.DealerId
	where Dealers.BrandId = @BrandId
	order by isnull(Rounds.ChipsGained,0) desc;
end;
go

if object_id('getTopPlayers','P') is not null drop procedure getTopPlayers
go 
create procedure getTopPlayers-- 
as
begin
	select top 10 Players.PlayerNumber,Players.FirstName,Players.LastName,isnull(Rounds.ChipsEarned,0) ChipsEarned
	from PdbPlayers Players
	join PdbBrands 	Brands on Players.BrandId = Brands.Id
	left join (	select Rounds.BrandId,Bets.PlayerId,isnull(sum(Wins.ChipsWon)-isnull(sum(Bets.ChipsBet),0),0) ChipsEarned
				from PdbRounds Rounds
				join PdbBets Bets on Rounds.BrandId = Bets.BrandId and Rounds.Id = Bets.RoundId
				left join PdbWins Wins on Bets.BrandId = Wins.BrandId and Bets.Id = Wins.BetId
				group by Rounds.BrandId,Bets.PlayerId) Rounds on Players.BrandId = Rounds.BrandId and Players.Id = Rounds.PlayerId
	order by isnull(Rounds.ChipsEarned,0) desc;
end;
go

if object_id('getTopPlayersPU','P') is not null drop procedure getTopPlayersPU
go 
create procedure getTopPlayersPU-- 
	(	@BrandId tinyint = null
	)
as
begin
	select top 10 Players.PlayerNumber,Players.FirstName,Players.LastName,isnull(Rounds.ChipsEarned,0) ChipsEarned
	from Players
	join Brands on Players.BrandId = Brands.Id
	left join (	select Rounds.BrandId,Bets.PlayerId,isnull(sum(Wins.ChipsWon)-isnull(sum(Bets.ChipsBet),0),0) ChipsEarned
				from Rounds
				join Bets on Rounds.BrandId = Bets.BrandId and Rounds.Id = Bets.RoundId
				left join Wins on Bets.BrandId = Wins.BrandId and Bets.Id = Wins.BetId
				group by Rounds.BrandId,Bets.PlayerId) Rounds on Players.BrandId = Rounds.BrandId and Players.Id = Rounds.PlayerId
	where Players.BrandId = @BrandId
	order by isnull(Rounds.ChipsEarned,0) desc;
end;
go

if object_id('purchaseChips','P') is not null drop procedure purchaseChips
go 
create procedure purchaseChips
	(	@PlayerNumber		nvarchar(16)
	,	@PurchaseValue		decimal(18,3)
	,	@ChipsPurchased		smallint
	)
as
begin
	set nocount on;
	
	declare @BrandId		tinyint;
	declare @PlayerId		smallint;
	declare @FirstName		nvarchar(128);
	declare @LastName		nvarchar(128);
	declare @ChipsBalance	smallint;
	
	select @BrandId = BrandId,@PlayerId = Id,@FirstName = FirstName,@LastName = LastName,@ChipsBalance = isnull(ChipsPurchased,0) + isnull(ChipsWon,0) - isnull(ChipsBet,0) - isnull(ChipsCashed,0)
	from PdbPlayers
	where PlayerNumber = @PlayerNumber;
	
	if isnull(@PlayerId,0) <> 0
	begin
		update PdbPlayers
		set ChipsPurchased = ChipsPurchased + @ChipsPurchased
		where BrandId 	= @BrandId
		  and Id 		= @PlayerId;
		
		print 'Player ' + @FirstName + ' ' + @LastName + ' purchased ' + cast(isnull(@ChipsPurchased,0) as nvarchar(max)) + ' Chips Successfully (New Balance ' + cast(isnull(@ChipsBalance,0) + isnull(@ChipsPurchased,0) as nvarchar(max)) + ')';
	end
	else
		print 'Failed to purchase Chips - Cannot find player by number ' + @PlayerNumber;
	
	set nocount off;
end;
go

if object_id('purchaseChipsPU','P') is not null drop procedure purchaseChipsPU
go 
create procedure purchaseChipsPU
	(	@BrandId			tinyint
	,	@PlayerNumber		nvarchar(16)
	,	@PurchaseValue		decimal(18,3)
	,	@ChipsPurchased		smallint
	)
as
begin
	set nocount on;
	
	declare @PlayerId		smallint;
	declare @FirstName		nvarchar(128);
	declare @LastName		nvarchar(128);
	declare @ChipsBalance	smallint;
	
	select @BrandId = BrandId,@PlayerId = Id,@FirstName = FirstName,@LastName = LastName,@ChipsBalance = isnull(ChipsPurchased,0) + isnull(ChipsWon,0) - isnull(ChipsBet,0) - isnull(ChipsCashed,0)
	from Players
	where BrandId = @BrandId
	  and PlayerNumber = @PlayerNumber;
	
	if isnull(@PlayerId,0) <> 0
	begin
		update Players
		set ChipsPurchased = ChipsPurchased + @ChipsPurchased
		where BrandId 	= @BrandId
		  and Id 		= @PlayerId;
		
		print 'Player ' + @FirstName + ' ' + @LastName + ' purchased ' + cast(isnull(@ChipsPurchased,0) as nvarchar(max)) + ' Chips Successfully (New Balance ' + cast(isnull(@ChipsBalance,0) + isnull(@ChipsPurchased,0) as nvarchar(max)) + ')';
	end
	else
		print 'Failed to purchase Chips - Cannot find player by number ' + @PlayerNumber;
	
	set nocount off;
end;
go