Use OC;
go

--------------------Random alghorythms-----------------------
CREATE PROCEDURE CreateRandomString
	@size integer,
	@String char(50) OUTPUT
AS
Begin
	SET @String = (
	SELECT
		c1 AS [text()]
	FROM
		(
		SELECT TOP (@size) c1
		FROM
		  (
		VALUES
		  ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J'),
		  ('K'), ('L'), ('M'), ('N'), ('O'), ('P'), ('Q'), ('R'), ('S'), ('T'),
		  ('U'), ('V'), ('W'), ('X'), ('Y'), ('Z'), ('0'), ('1'), ('2'), ('3'),
		  ('4'), ('5'), ('6'), ('7'), ('8'), ('9'), ('_')
		  ) AS T1(c1)
		ORDER BY ABS(CHECKSUM(NEWID()))
		) AS T2
	FOR XML PATH('')
	);
	End;

go

CREATE PROCEDURE CreateRandomNumber
	@size integer,
	@number integer OUTPUT
AS
Begin
	SET @number = TRY_CONVERT(int,(
	SELECT
		c1 AS [text()]
	FROM
		(
		SELECT TOP (2) c1
		FROM
		  (
		VALUES
		  ('1'), ('2'), ('3'), ('4'), ('5'), ('6'), ('7'), ('8'), ('9')
		  ) AS T1(c1)
		ORDER BY ABS(CHECKSUM(NEWID()))
		) AS T2
	FOR XML PATH('')
	));
	End;
go
--------------------|Championship|-----------------------
--delete Championships;
--DBCC CHECKIDENT ('Championships', RESEED, 0);
--select * from Championships;
--drop Procedure AI_Championship;
CREATE PROCEDURE AI_Championship
@number integer
AS
Begin
DECLARE @counter int;
SET @counter = 1;
DECLARE	@title nvarchar(50);
DECLARE	@subtitle nvarchar(50);
DECLARE @tmp_number integer;
DECLARE	@prize money;

While @counter <= @number
	BEGIN
	exec CreateRandomString 10, @title OUTPUT;
	exec CreateRandomString 30, @subtitle OUTPUT;
	exec CreateRandomNumber 4, @tmp_number OUTPUT;
	SET @prize = cast(@tmp_number as money);
	Insert into [Championships](Title, Subtitle, Prize_fond)
		values(@title,@subtitle,@tmp_number);
	SET @counter = @counter + 1;
	END;
End;

go
--------------------|Games|-----------------------
--delete Games;
--DBCC CHECKIDENT ('Games', RESEED, 0);
--select * from Games
--drop Procedure AI_Game;
CREATE PROCEDURE AI_Game
@number integer
AS
Begin
DECLARE @counter int;
SET @counter = 1;
DECLARE	@name nvarchar(50);
DECLARE	@version nvarchar(50);

While @counter <= @number
	BEGIN
	exec CreateRandomString 10, @name OUTPUT;
	exec CreateRandomString 30, @version OUTPUT;
	Insert into Games([Name], [Version])
		values(@name, @version);
	SET @counter = @counter + 1;
	END;
End;
go
--------------------|Command|-----------------------
--delete Commands;
--DBCC CHECKIDENT ('Commands', RESEED, 0);
--select * from Commands
--drop Procedure AI_Command;
Create Procedure AI_Command
@number integer
AS
Begin
DECLARE @counter int;
SET @counter = 1;
DECLARE	@name nvarchar(50);

While @counter <= @number
	BEGIN
	exec CreateRandomString 10, @name OUTPUT;
	Insert into Commands([Name])
		values(@name);
	SET @counter = @counter + 1;
	END;
End;
go
--------------------|Player|-----------------------
--delete Users;
--delete Players;
--DBCC CHECKIDENT ('Users', RESEED, 0);
--DBCC CHECKIDENT ('Players', RESEED, 0); 
--select * from Users;
--select * from Players;
--drop procedure AI_Player;
Create Procedure AI_Player 
@number integer
AS
Begin
DECLARE @counter int;
SET @counter = 1;
DECLARE	@login nvarchar(50);
DECLARE	@nickname nvarchar(50);
DECLARE	@email nvarchar(50);
DECLARE	@password nvarchar(50);
DECLARE	@max_command int;
DECLARE	@max_game int;
DECLARE @last_player int;

DECLARE @hashed_p varbinary(max);
set @password = '12345';
set @hashed_p = hashbytes('SHA2_512', CAST(@password as VARBINARY(max)));
set @max_game = (select count(*) from Games);
set @max_command = (select count(*) from Commands);

WHILE @counter <= @number
	BEGIN
	exec CreateRandomString 7, @login OUTPUT;
	while (select count(*) from Users where Users.Login = @login) = 1
		exec CreateRandomString 7, @login OUTPUT;
	exec CreateRandomString 7, @nickname OUTPUT;
	while (select count(*) from Players where Players.Nickname = @nickname) = 1
		exec CreateRandomString 7, @nickname OUTPUT;
	exec CreateRandomString 5, @email OUTPUT;
	set @email = RTRIM(@email) + '@gmail.com';
	while (select count(*) from Users where Users.Email = @email) = 1
		begin
		exec CreateRandomString 5, @email OUTPUT;
		set @email = RTRIM(@email) + '@gmail.com';
		end

	insert into Players(Command_ID,Main_game_ID,Nickname)
		values(
			(ABS(CHECKSUM(NewId())) % (@max_command))+1,
			(ABS(CHECKSUM(NewId())) % (@max_game))+1,
			@nickname);

	SET @last_player = (SELECT TOP 1 ID FROM Players ORDER BY ID DESC);
	
	insert into Users(Login,Email,Password,IsAdmin,Player_ID)
		values(
			@login,
			@email,
			@hashed_p,
			0,
			@last_player);

	SET @counter = @counter+ 1;
	END;
End;
go
--------------------|Single achievements|-----------------------
--delete SingleAchievements;
--DBCC CHECKIDENT ('SingleAchievements', RESEED, 0);
--select * from SingleAchievements
--drop Procedure AI_SAchievements;
Create Procedure AI_SAchievements
@number integer
AS
Begin
DECLARE @counter int;
SET @counter = 1;
DECLARE	@max_championship int;
DECLARE	@max_game int;
DECLARE @max_player int;
DECLARE @place int;
DECLARE @prize int;

set @max_game = (select count(*) from Games);
set @max_championship = (select count(*) from Championships);
set @max_player = (select count(*) from Players);

WHILE @counter <= @number
	BEGIN
	SET @prize = cast(((ABS(CHECKSUM(NewId())) % (999900))+100) as money); 
	SET @place = ABS(CHECKSUM(NewId()) % 9)+1; 

	insert into SingleAchievements(Player_ID,Game_ID,Championship_ID,Place,Prize,WithCommand)
		values(
			(ABS(CHECKSUM(NewId())) % (@max_player))+1,
			(ABS(CHECKSUM(NewId())) % (@max_game))+1,
			(ABS(CHECKSUM(NewId())) % (@max_championship))+1,
			@place,
			@prize,
			(ABS(CHECKSUM(NewId())) % 2));

	SET @counter = @counter+ 1;
	END;
End;
go
--------------------|Command achievements|-----------------------
--delete CommandAchievements;
--DBCC CHECKIDENT ('CommandAchievements', RESEED, 0);
--select * from CommandAchievements;
--drop Procedure AI_CAchievements;
Create Procedure AI_CAchievements
@number integer
AS
Begin
DECLARE @counter int;
SET @counter = 1;
DECLARE	@max_championship int;
DECLARE	@max_game int;
DECLARE @max_command int;
DECLARE @place int;
DECLARE @prize int;

set @max_game = (select count(*) from Games);
set @max_championship = (select count(*) from Championships);
set @max_command = (select count(*) from Commands);

WHILE @counter <= @number
	BEGIN
	SET @prize = cast(((ABS(CHECKSUM(NewId())) % (999900))+100) as money); 
	SET @place = ABS(CHECKSUM(NewId()) % 9)+1; 

	insert into CommandAchievements(Command_ID,Game_ID,Championship_ID,Place,Prize)
		values(
			(ABS(CHECKSUM(NewId())) % (@max_command))+1,
			(ABS(CHECKSUM(NewId())) % (@max_game))+1,
			(ABS(CHECKSUM(NewId())) % (@max_championship))+1,
			@place,
			@prize);

	SET @counter = @counter+ 1;
	END;
End;
go
--------------------|Single battles|-----------------------
--delete Single_battles;
--DBCC CHECKIDENT ('Single_battles', RESEED, 0);
--select * from Single_battles;
--drop Procedure AI_SBattles;
Create Procedure AI_SBattles
@number integer
AS
Begin
DECLARE @counter int;
SET @counter = 1;
DECLARE	@max_championship int;
DECLARE @max_player int;
DECLARE @winner int;
DECLARE @loser int;

set @max_player = (select count(*) from Players);
set @max_championship = (select count(*) from Championships);

WHILE @counter <= @number
	BEGIN
	SET @winner = ABS(CHECKSUM(NewId()) % @max_player)+1; 
	SET @loser = ABS(CHECKSUM(NewId()) % @max_player)+1; 
	while @loser = @winner
		SET @loser = ABS(CHECKSUM(NewId()) % @max_player)+1;

	insert into Single_battles(Winner_ID,Loser_ID,Championship_ID)
		values(
		@winner,
		@loser,
		ABS(CHECKSUM(NewId()) % @max_championship)+1);

	SET @counter = @counter+ 1;
	END;
End;
go
--------------------|Command battles|-----------------------
--delete Command_battles;
--DBCC CHECKIDENT ('Command_battles', RESEED, 0);
--select * from Command_battles;
--drop Procedure AI_CBattles;
Create Procedure AI_CBattles
@number integer
AS
Begin
DECLARE @counter int;
SET @counter = 1;
DECLARE	@max_championship int;
DECLARE @max_command int;
DECLARE @winner int;
DECLARE @loser int;

set @max_command = (select count(*) from Commands);
set @max_championship = (select count(*) from Championships);

WHILE @counter <= @number
	BEGIN
	SET @winner = ABS(CHECKSUM(NewId()) % @max_command)+1; 
	SET @loser = ABS(CHECKSUM(NewId()) % @max_command)+1; 
	while @loser = @winner
		SET @loser = ABS(CHECKSUM(NewId()) % @max_command)+1;

	insert into Command_battles(Winner_ID,Loser_ID,Championship_ID)
		values(
		@winner,
		@loser,
		ABS(CHECKSUM(NewId()) % @max_championship)+1);

	SET @counter = @counter+ 1;
	END;
End;
go

--Clear all
delete Command_battles;
DBCC CHECKIDENT ('Command_battles', RESEED, 0);

delete Single_battles;
DBCC CHECKIDENT ('Single_battles', RESEED, 0);

delete CommandAchievements;
DBCC CHECKIDENT ('CommandAchievements', RESEED, 0);

delete SingleAchievements;
DBCC CHECKIDENT ('SingleAchievements', RESEED, 0);

delete Users;
delete Players;
DBCC CHECKIDENT ('Users', RESEED, 0);
DBCC CHECKIDENT ('Players', RESEED, 0); 

delete Commands;
DBCC CHECKIDENT ('Commands', RESEED, 0);

delete Games;
DBCC CHECKIDENT ('Games', RESEED, 0);

delete Championships;
DBCC CHECKIDENT ('Championships', RESEED, 0);
go

--Generate
EXEC AI_Championship 100;
EXEC AI_Game 100;
EXEC AI_Command 100;
EXEC AI_Player 300;
EXEC AI_SAchievements 600;
EXEC AI_CAchievements 600;
EXEC AI_SBattles 1000;
EXEC AI_CBattles 1000;
go

