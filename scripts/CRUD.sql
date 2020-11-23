-- Championship
CREATE PROCEDURE Add_Championship
	@title nvarchar(50),
	@subtitle nvarchar(50),
	@date_str nvarchar(10),
	@prize_int int = 0 
AS
Begin
	DECLARE @date date;
	SET @date = TRY_CAST(@date_str as date);
	
	DECLARE @prize int;
	SET @prize = TRY_CAST(@prize_int as int);

	Insert into Championships(Title, Subtitle,Date, Prize_fond)
		values(@title,@subtitle,@date,@prize);
End;
go
CREATE PROCEDURE Find_Championship
	@title nvarchar(50)
AS
Begin
	SELECT * FROM Championships c where @title = RTRIM(c.Title);
End;
--exec Find_Championship 'Minsk cup';
go
CREATE PROCEDURE Update_Championship
	@id integer,
	@title nvarchar(50),
	@subtitle nvarchar(50),
	@date_str nvarchar(10),
	@prize_int int = 0 
AS
Begin
	DECLARE @date date;
	SET @date = TRY_CAST(@date_str as date);
	
	DECLARE @prize int;
	SET @prize = TRY_CAST(@prize_int as int);

	UPDATE Championships
	SET Title = @title,
		Subtitle = @subtitle,
		Date = @date,
		Prize_fond = @prize
	FROM Championships c
	WHERE c.ID = @id;
End;
--exec Update_Championship 55,'Minsk cup','local student cup 2020','4.2.2021',1000;
go
CREATE PROCEDURE Remove_Championship
	@id integer
AS
Begin
	DELETE FROM Championships where ID = @id;
End;
go

-- Game
CREATE PROCEDURE Add_Game
	@name nvarchar(50),
	@version nvarchar(50)
AS
Begin
	Insert into Games([Name], [Version])
		values(@name, @version);
End;
go
CREATE PROCEDURE Find_Game
	@name nvarchar(50),
	@version nvarchar(50)
AS
Begin
	if @version = ''
	SELECT * FROM Games c where @name = RTRIM(c.Name);
	else
	SELECT * FROM Games c where 
		@name = RTRIM(c.Name) and @version = RTRIM(c.Version) ;
End;
--exec Find_Game 'Stronghold','Crusader';
go
CREATE PROCEDURE Update_Game
	@id integer,
	@name nvarchar(50),
	@version nvarchar(50)
AS
Begin
	UPDATE Games
	SET Name = @name,
		Version = @version
	FROM Games c
	WHERE c.ID = @id;
End;
--exec Update_Championship 55,'Minsk cup','local student cup 2020','4.2.2021',1000;
go
CREATE PROCEDURE Remove_Game
	@id integer
AS
Begin
	DELETE FROM Games where ID = @id;
End;
go

-- Command
CREATE PROCEDURE Add_Command
	@name nvarchar(50)
AS
Begin
	Insert into Commands([Name])
		values(@name);
End;
go
CREATE PROCEDURE Find_Command
	@name nvarchar(50)
AS
Begin
	SELECT * FROM Commands c where @name = RTRIM(c.Name);
End;
go
CREATE PROCEDURE Update_Command
	@id integer,
	@name nvarchar(50)
AS
Begin
	UPDATE Commands
	SET Name = @name
	FROM Commands c
	WHERE c.ID = @id;
End;
go
CREATE PROCEDURE Remove_Command
	@id integer
AS
Begin
	DELETE FROM Commands where ID = @id;
End;
go

-- Command
CREATE PROCEDURE Add_Player
		@login nvarchar(50),
		@nickname nvarchar(50),
		@email nvarchar(50),
		@password nvarchar(50)
AS
Begin
	declare @errors integer = 0;
	set @errors = 
	(select count(*) from Users where Users.Login = @login)
	+
	(select count(*) from Players where Players.Nickname = @nickname) * 2
	+
	(select count(*) from Users where Users.Email = @email) * 5;

	if @errors=1 begin select 'Login already exist' return; end
	if @errors=2 begin select 'Nickname already exist' return; end
	if @errors=5 begin select 'Email already used' return; end
	if @errors=3 begin select 'Login and Nickname already used' return; end
	if @errors=6 begin select 'Login and Email already used' return; end
	if @errors=7 begin select 'Nickname and Email already used' return; end
	if @errors=8 begin select 'Login, Nickname and Email already used' return; end

	if @errors = 0
	begin
	insert into Players(Command_ID,Main_game_ID,Nickname)
		values(
			NULL,
			null,
			@nickname);

	declare @last_player int =
	(SELECT TOP 1 ID FROM Players where Players.Nickname = @nickname);
	
	declare @hashed_p varbinary(max) = 
	hashbytes('SHA2_512', CAST(@password as VARBINARY(max)));

	insert into Users(Login,Email,Password,IsAdmin,Player_ID)
		values(
			@login,
			@email,
			@hashed_p,
			0,
			@last_player);
	end;
End;
go
CREATE PROCEDURE Find_Player
	@nickname nvarchar(50)
AS
Begin
	SELECT * FROM Players p where @nickname = RTRIM(p.Nickname);
End;
go
CREATE PROCEDURE Find_User
	@login nvarchar(50)
AS
Begin
	SELECT * FROM Users u where @login = RTRIM(u.Login);
End;
go
CREATE PROCEDURE Update_Player
	@id integer,
	@nickname nvarchar(50),
	@main_game int,
	@command int
AS
Begin
	UPDATE Players
	SET Nickname = @nickname,
		Main_game_ID =@main_game,
		Command_ID = @command
	FROM Players p
	WHERE p.ID = @id;
End;
go
CREATE PROCEDURE Update_User
	@id integer,
	@login nvarchar(50),
	@email nvarchar(50),
	@password nvarchar(50),
	@admin bit,
	@player int
AS
Begin
	declare @hashed_p varbinary(max) = 
	hashbytes('SHA2_512', CAST(@password as VARBINARY(max)));
	
	UPDATE Users
	SET Login = @login,
		Email =@email,
		Password =@hashed_p,
		IsAdmin = @admin,
		Player_ID = @player
	FROM Users u
	WHERE u.ID = @id;
End;
go
CREATE PROCEDURE Remove_Player
	@id integer
AS
Begin
	update Users
		SET Player_ID = null
		from Users
		where Player_ID = @id;
	DELETE FROM Players where ID = @id;
End;
go
CREATE PROCEDURE Remove_User
	@id integer
AS
Begin
	DELETE FROM Users where ID = @id;
End;
go

-- Single Achievement
CREATE PROCEDURE Add_SAchievement
	@player int,
	@game int,
	@championship int,
	@place int,
	@prize_int int,
	@withcommand bit
AS
Begin
	DECLARE @prize money = cast(@prize_int as money); 

	insert into SingleAchievements(Player_ID,Game_ID,Championship_ID,Place,Prize,WithCommand)
		values(
			@player,
			@game,
			@championship,
			@place,
			@prize,
			@withcommand)
End;
go
CREATE PROCEDURE Find_SAchivements
	@player int
AS
Begin
	SELECT * FROM SingleAchievements sa where @player= RTRIM(sa.Player_ID);
End;
go
CREATE PROCEDURE Find_SAchivement
	@player int,
	@game int,
	@championship int,
	@place int
AS
Begin
	SELECT top 1 * FROM SingleAchievements sa where 
	@player= RTRIM(sa.Player_ID) and
	@game= RTRIM(sa.Game_ID) and
	@championship= RTRIM(sa.Championship_ID) and
	@place= RTRIM(sa.Place);
End;
go
CREATE PROCEDURE Update_SAchievement
	@id int,
	@player int,
	@game int,
	@championship int,
	@place int,
	@prize_int int,
	@withcommand bit
AS
Begin
	UPDATE SingleAchievements
	SET Player_ID = @player,
		Game_ID = @game,
		Championship_ID = @championship,
		Place = @place,
		Prize = cast(@prize_int as money),
		WithCommand = @withcommand
	FROM SingleAchievements sa
	WHERE sa.ID = @id;
End;
go
CREATE PROCEDURE Remove_SAchievement
	@id integer
AS
Begin
	DELETE FROM SingleAchievements where ID = @id;
End;
go

-- Command Achievement
CREATE PROCEDURE Add_CAchievement
	@command int,
	@game int,
	@championship int,
	@place int,
	@prize_int int
AS
Begin
	DECLARE @prize money = cast(@prize_int as money); 

	insert into CommandAchievements(Command_ID,Game_ID,Championship_ID,Place,Prize)
		values(
			@command,
			@game,
			@championship,
			@place,
			@prize)
End;
go
CREATE PROCEDURE Find_CAchivements
	@command int
AS
Begin
	SELECT * FROM CommandAchievements sa where @command = RTRIM(sa.Command_ID);
End;
go
CREATE PROCEDURE Find_CAchivement
	@command int,
	@game int,
	@championship int,
	@place int
AS
Begin
	SELECT top 1 * FROM CommandAchievements sa where 
	@command= RTRIM(sa.Command_ID) and
	@game= RTRIM(sa.Game_ID) and
	@championship= RTRIM(sa.Championship_ID) and
	@place= RTRIM(sa.Place);
End;
go
CREATE PROCEDURE Update_CAchievement
	@id int,
	@command int,
	@game int,
	@championship int,
	@place int,
	@prize_int int,
	@withcommand bit
AS
Begin
	UPDATE CommandAchievements
	SET Command_ID = @command,
		Game_ID = @game,
		Championship_ID = @championship,
		Place = @place,
		Prize = cast(@prize_int as money)
	FROM CommandAchievements ca
	WHERE ca.ID = @id;
End;
go
CREATE PROCEDURE Remove_CAchievement
	@id integer
AS
Begin
	DELETE FROM SingleAchievements where ID = @id;
End;
go

-- Single battles
CREATE PROCEDURE Add_SBattle
		@championship int,
		@winner int,
		@loser int
AS
Begin
	insert into Single_battles(Winner_ID,Loser_ID,Championship_ID)
		values(
		@winner,
		@loser,
		@championship)

End;
go
CREATE PROCEDURE Find_SBattles
	@player int,
	@championship int
AS
Begin
	if @championship = ''
	SELECT * FROM Single_battles sb where 
		@player = RTRIM(sb.Loser_ID) or
		@player = RTRIM(sb.Winner_ID);
	else
	SELECT * FROM Single_battles sb where 
		@player = RTRIM(sb.Loser_ID) or @player = RTRIM(sb.Winner_ID)
		and Championship_ID = @championship;
End;
go
CREATE PROCEDURE Find_SBattles_W
	@player int,
	@championship int
AS
Begin
	if @championship = ''
	SELECT * FROM Single_battles sb where 
		@player = RTRIM(sb.Winner_ID);
	else
	SELECT * FROM Single_battles sb where
		@player = RTRIM(sb.Winner_ID)
		and Championship_ID = @championship;
End;
go
CREATE PROCEDURE Find_SBattles_L
	@player int,
	@championship int
AS
Begin
	if @championship = ''
	SELECT * FROM Single_battles sb where 
		@player = RTRIM(sb.Loser_ID);
	else
	SELECT * FROM Single_battles sb where
		@player = RTRIM(sb.Loser_ID)
		and Championship_ID = @championship;
End;
go
CREATE PROCEDURE Find_SBattle
		@championship int,
		@winner int,
		@loser int
AS
Begin
	SELECT top 1 * FROM Single_battles sb where 
		@championship = RTRIM(sb.Championship_ID) and
		@winner = RTRIM(sb.Winner_ID) and
		@loser = RTRIM(sb.Loser_ID);
End;
go
CREATE PROCEDURE Update_SBattle
		@id int,
		@championship int,
		@winner int,
		@loser int
AS
Begin
	UPDATE Single_battles
	SET Championship_ID = @championship,
		Winner_ID = @winner,
		Loser_ID = @loser
	FROM Single_battles sb
	WHERE sb.ID = @id;
End;
go
CREATE PROCEDURE Remove_SBattle
	@id integer
AS
Begin
	DELETE FROM Single_battles where ID = @id;
End;
go

-- Command battles
CREATE PROCEDURE Add_CBattle
		@championship int,
		@winner int,
		@loser int
AS
Begin
	insert into Command_battles(Winner_ID,Loser_ID,Championship_ID)
		values(
		@winner,
		@loser,
		@championship)

End;
go
CREATE PROCEDURE Find_CBattles
	@player int,
	@championship int
AS
Begin
	if @championship = ''
	SELECT * FROM Command_battles sb where 
		@player = RTRIM(sb.Loser_ID) or
		@player = RTRIM(sb.Winner_ID);
	else
	SELECT * FROM Command_battles sb where 
		@player = RTRIM(sb.Loser_ID) or @player = RTRIM(sb.Winner_ID)
		and Championship_ID = @championship;
End;
go
CREATE PROCEDURE Find_CBattles_W
	@command int,
	@championship int
AS
Begin
	if @championship = ''
	SELECT * FROM Command_battles sb where 
		@command = RTRIM(sb.Winner_ID);
	else
	SELECT * FROM Command_battles sb where
		@command = RTRIM(sb.Winner_ID)
		and Championship_ID = @championship;
End;
go
CREATE PROCEDURE Find_CBattles_L
	@command int,
	@championship int
AS
Begin
	if @championship = ''
	SELECT * FROM Command_battles sb where 
		@command = RTRIM(sb.Loser_ID);
	else
	SELECT * FROM Command_battles sb where
		@command = RTRIM(sb.Loser_ID)
		and Championship_ID = @championship;
End;
go
CREATE PROCEDURE Find_CBattle
		@championship int,
		@winner int,
		@loser int
AS
Begin
	SELECT top 1 * FROM Command_battles sb where 
		@championship = RTRIM(sb.Championship_ID) and
		@winner = RTRIM(sb.Winner_ID) and
		@loser = RTRIM(sb.Loser_ID);
End;
go
CREATE PROCEDURE Update_CBattle
		@id int,
		@championship int,
		@winner int,
		@loser int
AS
Begin
	UPDATE Command_battles
	SET Championship_ID = @championship,
		Winner_ID = @winner,
		Loser_ID = @loser
	FROM Command_battles sb
	WHERE sb.ID = @id;
End;
go
CREATE PROCEDURE Remove_CBattle
	@id integer
AS
Begin
	DELETE FROM Command_battles where ID = @id;
End;
go


