use OC
go

--exec ImportDBFromXml
CREATE PROCEDURE ImportDBFromXml
AS
BEGIN
	INSERT INTO Championships(Title,Subtitle,Date,Prize_fond)
	SELECT
	   MY_XML.Championship.query('Title').value('.', 'NVARCHAR(50)'),
	   MY_XML.Championship.query('Subtitle').value('.', 'NVARCHAR(100)'),
	   MY_XML.Championship.query('Date').value('.', 'DATE'),
	   MY_XML.Championship.query('Prize_fond').value('.', 'MONEY')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/Championships/Championship') AS MY_XML (Championship);

	INSERT INTO Commands(Name)
	SELECT
	   MY_XML.Command.query('Name').value('.', 'NVARCHAR(50)')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/Commands/Command') AS MY_XML (Command);

	INSERT INTO Games(Name,Version)
	SELECT
	   MY_XML.Game.query('Name').value('.', 'NVARCHAR(50)'),
	   MY_XML.Game.query('V').value('.', 'NVARCHAR(50)')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/Games/Game') AS MY_XML (Game);

	INSERT INTO Players(Nickname,Command_ID,Main_game_ID)
	SELECT
	   MY_XML.rec.query('Nickname').value('.', 'NVARCHAR(50)'),
	   MY_XML.rec.query('Command_ID').value('.', 'INT'),
	   MY_XML.rec.query('Main_game_ID').value('.', 'INT')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/Players/Player') AS MY_XML (rec);

	INSERT INTO Users(Login,Password,Email,IsAdmin,Player_ID)
	SELECT
	   MY_XML.rec.query('Login').value('.', 'NVARCHAR(50)'),
	   MY_XML.rec.query('Password').value('.', 'VARBINARY(max)'),
	   MY_XML.rec.query('Email').value('.', 'NVARCHAR(50)'),
	   MY_XML.rec.query('IsAdmin').value('.', 'BIT'),
	   MY_XML.rec.query('Player_ID').value('.', 'INT')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/Users/User') AS MY_XML (rec);

	INSERT INTO SingleAchievements(Championship_ID,Game_ID,Player_ID,Place,Prize,WithCommand)
	SELECT
	   MY_XML.rec.query('Championship_ID').value('.', 'INT'),
	   MY_XML.rec.query('Game_ID').value('.', 'INT'),
	   MY_XML.rec.query('Player_ID').value('.', 'INT'),
	   MY_XML.rec.query('Place').value('.', 'INT'),
	   MY_XML.rec.query('Prize').value('.', 'MONEY'),
	   MY_XML.rec.query('WithCommand').value('.', 'BIT')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/SingleAchievements/SingleAchievement') AS MY_XML (rec);

	INSERT INTO CommandAchievements(Championship_ID,Game_ID,Command_ID,Place,Prize)
	SELECT
	   MY_XML.rec.query('Championship_ID').value('.', 'INT'),
	   MY_XML.rec.query('Game_ID').value('.', 'INT'),
	   MY_XML.rec.query('Command_ID').value('.', 'INT'),
	   MY_XML.rec.query('Place').value('.', 'INT'),
	   MY_XML.rec.query('Prize').value('.', 'MONEY')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/CommandAchievements/CommandAchievement') AS MY_XML (rec);

	INSERT INTO Single_battles(Championship_ID,Winner_ID,Loser_ID)
	SELECT
	   MY_XML.rec.query('Championship_ID').value('.', 'INT'),
	   MY_XML.rec.query('Winner_ID').value('.', 'INT'),
	   MY_XML.rec.query('Loser_ID').value('.', 'INT')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/SingleBattles/SingleBattle') AS MY_XML (rec);

	INSERT INTO Command_battles(Championship_ID,Winner_ID,Loser_ID)
	SELECT
	   MY_XML.rec.query('Championship_ID').value('.', 'INT'),
	   MY_XML.rec.query('Winner_ID').value('.', 'INT'),
	   MY_XML.rec.query('Loser_ID').value('.', 'INT')
	FROM (SELECT CAST(MY_XML AS xml)
		  FROM OPENROWSET(BULK 'D:\temp.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
		  CROSS APPLY MY_XML.nodes('OC/CommandBattles/CommandBattle') AS MY_XML (rec);
END;