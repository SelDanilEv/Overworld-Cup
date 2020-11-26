use OC
go

--exec ExportDBToXml
--DROP PROCEDURE ExportDBToXml
CREATE PROCEDURE ExportDBToXml
AS
BEGIN
--	SELECT 
--	(SELECT ID,RTRIM(Name)as Name,RTRIM(Version) as Version from Games FOR XML PATH('Game'),TYPE) as Games,
--	(SELECT ID,RTRIM(Title)as Title,RTRIM(Subtitle) as Subtitle,Date,Prize_fond from Championships FOR XML PATH('Championship'),TYPE)as Championships,
--	(SELECT ID,RTRIM(Name)as Name from Commands FOR XML PATH('Command'),TYPE)as Commands,
--	(SELECT ID,RTRIM(Nickname)as Nickname,Main_game_ID,Command_ID from Players FOR XML PATH('Player'),TYPE)as Players,
--	(SELECT ID,RTRIM(Login)as Login,Password,Email,IsAdmin,Player_ID from Users FOR XML PATH('User'),TYPE)as Users,
--	(SELECT ID,Championship_ID,Game_ID,Player_ID,Place,Prize,WithCommand from SingleAchievements FOR XML PATH('SingleAchievement'),TYPE)as SingleAchievements,
--	(SELECT ID,Championship_ID,Game_ID,Command_ID,Place,Prize from CommandAchievements FOR XML PATH('CommandAchievement'),TYPE)as CommandAchievements,
--	(SELECT ID,Championship_ID,Winner_ID,Loser_ID from Single_battles FOR XML PATH('SingleBattle'),TYPE)as SingleBattles,
--	(SELECT ID,Championship_ID,Winner_ID,Loser_ID from Command_battles FOR XML PATH('CommandBattle'),TYPE)as CommandBattles
--	FOR XML PATH('OC'),TYPE

	--to use xp_cmdshell
	EXEC master.dbo.sp_configure 'show advanced options', 1
		RECONFIGURE WITH OVERRIDE;
	EXEC master.dbo.sp_configure 'xp_cmdshell', 1
		RECONFIGURE WITH OVERRIDE;

	-- Save XML records to a file
	DECLARE @fileName nVARCHAR(500)
	DECLARE @sep CHAR(1) = ','
	DECLARE @presqlStr VARCHAR(500)= 'USE OC;SELECT '
	DECLARE @postsqlStr VARCHAR(500)= ' FOR XML PATH(''''),TYPE, ROOT(''OC'')'
	DECLARE @gameQ VARCHAR(500)= '(SELECT ID,RTRIM(Name)as Name,RTRIM(Version) as V from Games FOR XML PATH(''Game''),TYPE) as Games '
	DECLARE @championshipQ VARCHAR(500)= '(SELECT ID,RTRIM(Title)as Title,RTRIM(Subtitle) as Subtitle,Date,Prize_fond from Championships FOR XML PATH(''Championship''),TYPE)as Championships '
	DECLARE @commandQ VARCHAR(500)= '(SELECT ID,RTRIM(Name)as Name from Commands FOR XML PATH(''Command''),TYPE)as Commands '
	DECLARE @playerQ VARCHAR(500)= '(SELECT ID,RTRIM(Nickname)as Nickname,Main_game_ID,Command_ID from Players FOR XML PATH(''Player''),TYPE)as Players '
	DECLARE @userQ VARCHAR(500)= '(SELECT ID,RTRIM(Login)as Login,Password,Email,IsAdmin,Player_ID from Users FOR XML PATH(''User''),TYPE)as Users '
	DECLARE @SAQ VARCHAR(500)= '(SELECT ID,Championship_ID,Game_ID,Player_ID,Place,Prize,WithCommand from SingleAchievements FOR XML PATH(''SingleAchievement''),TYPE)as SingleAchievements '
	DECLARE @CAQ VARCHAR(500)= '(SELECT ID,Championship_ID,Game_ID,Command_ID,Place,Prize from CommandAchievements FOR XML PATH(''CommandAchievement''),TYPE)as CommandAchievements '
	DECLARE @SBQ VARCHAR(500)= '(SELECT ID,Championship_ID,Winner_ID,Loser_ID from Single_battles FOR XML PATH(''SingleBattle''),TYPE)as SingleBattles '
	DECLARE @CBQ VARCHAR(500)= '(SELECT ID,Championship_ID,Winner_ID,Loser_ID from Command_battles FOR XML PATH(''CommandBattle''),TYPE)as CommandBattles '

	DECLARE @sqlStr VARCHAR(5000) = @presqlStr +
									@gameQ+@sep+
									@championshipQ+@sep+
									@commandQ+@sep+
									@playerQ+@sep+
									@userQ+@sep+
									@SAQ+@sep+
									@CAQ+@sep+
									@SBQ+@sep+
									@CBQ+
									@postsqlStr

	DECLARE @sqlCmd VARCHAR(5500)

	SET @fileName = 'D:\temp.xml'
	SET @sqlCmd = 'bcp "' + @sqlStr + '" queryout ' + @fileName + ' -w -T'
	EXEC xp_cmdshell @sqlCmd
END

