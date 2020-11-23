Create database OC;
GO
use OC;
GO
--Championships

CREATE TABLE [Championships]
(
 [ID]         int IDENTITY (1, 1) NOT NULL ,
 [Title]      nvarchar(50) NOT NULL ,
 [Subtitle]   nvarchar(100) NULL ,
 [Date]       date NULL ,
 [Prize_fond] money NOT NULL ,

 CONSTRAINT [PK_championships] PRIMARY KEY CLUSTERED ([ID] ASC)
);
GO

--Games
CREATE TABLE [Games]
(
 [ID]      int IDENTITY (1, 1) NOT NULL ,
 [Name]    nvarchar(50) NOT NULL ,
 [Version] nvarchar(50) NOT NULL ,

 CONSTRAINT [PK_games] PRIMARY KEY CLUSTERED ([ID] ASC)
);
GO

--Commands
CREATE TABLE [Commands]
(
 [ID]   int IDENTITY (1, 1) NOT NULL ,
 [Name] nvarchar(50) NOT NULL ,

 CONSTRAINT [PK_commands] PRIMARY KEY CLUSTERED ([ID] ASC)
);
GO

--Players
CREATE TABLE [Players]
(
 [ID]           int IDENTITY (1, 1) NOT NULL ,
 [Command_ID]   int NULL ,
 [Main_game_ID] int NULL ,
 [Nickname]     nvarchar(50) NULL ,

 CONSTRAINT [PK_players] PRIMARY KEY CLUSTERED ([ID] ASC),
 CONSTRAINT [FK_Player_User] FOREIGN KEY ([Command_ID])  REFERENCES [Commands]([ID]),
 CONSTRAINT [FK_Player_MainGame] FOREIGN KEY ([Main_game_ID])  REFERENCES [Games]([ID])
);
GO


CREATE NONCLUSTERED INDEX [Idx_Player_command] ON [Players] 
 (
  [Command_ID] ASC
 )
GO

CREATE NONCLUSTERED INDEX [Idx_Player_game] ON [Players] 
 (
  [Main_game_ID] ASC
 )
GO

--Users
CREATE TABLE [Users]
(
 [ID]        int IDENTITY (1, 1) NOT NULL ,
 [Login]     nvarchar(50) NOT NULL ,
 [Email]     nvarchar(50) NULL ,
 [Password]  VARBINARY(max) NOT NULL ,
 [IsAdmin]   bit NOT NULL ,
 [Player_ID] int NULL ,

 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED ([ID] ASC),
 CONSTRAINT [FK_User_Player] FOREIGN KEY ([Player_ID])  REFERENCES [Players]([ID])
);
GO


CREATE NONCLUSTERED INDEX [Idx_User_player] ON [Users] 
 (
  [Player_ID] ASC
 )
GO

--Single achievements
CREATE TABLE [SingleAchievements]
(
 [ID]              int IDENTITY (1, 1) NOT NULL ,
 [Player_ID]       int NOT NULL ,
 [Game_ID]         int NOT NULL ,
 [Championship_ID] int NOT NULL ,
 [Place]           int NULL ,
 [Prize]           money NULL ,
 [WithCommand]     bit NOT NULL ,

 CONSTRAINT [PK_singleachievements] PRIMARY KEY CLUSTERED ([ID] ASC),
 CONSTRAINT [FK_SA_Player] FOREIGN KEY ([Player_ID])  REFERENCES [Players]([ID]),
 CONSTRAINT [FK_SA_Game] FOREIGN KEY ([Game_ID])  REFERENCES [Games]([ID]),
 CONSTRAINT [FK_SA_Championship] FOREIGN KEY ([Championship_ID])  REFERENCES [Championships]([ID])
);
GO


CREATE NONCLUSTERED INDEX [Idx_SA_player] ON [SingleAchievements] 
 (
  [Player_ID] ASC
 )
GO

CREATE NONCLUSTERED INDEX [Idx_SA_game] ON [SingleAchievements] 
 (
  [Game_ID] ASC
 )

GO

CREATE NONCLUSTERED INDEX [Idx_SA_championship] ON [SingleAchievements] 
 (
  [Championship_ID] ASC
 )
GO

--Command achievements
CREATE TABLE [CommandAchievements]
(
 [ID]              int IDENTITY (1, 1) NOT NULL ,
 [Game_ID]         int NOT NULL ,
 [Command_ID]      int NOT NULL ,
 [Championship_ID] int NOT NULL ,
 [Place]           int NULL ,
 [Prize]           money NULL ,

 CONSTRAINT [PK_commandachievements] PRIMARY KEY CLUSTERED ([ID] ASC),
 CONSTRAINT [FK_CA_Game] FOREIGN KEY ([Game_ID])  REFERENCES [Games]([ID]),
 CONSTRAINT [FK_CA_Command] FOREIGN KEY ([Command_ID])  REFERENCES [Commands]([ID]),
 CONSTRAINT [FK_CA_Championship] FOREIGN KEY ([Championship_ID])  REFERENCES [Championships]([ID])
);
GO


CREATE NONCLUSTERED INDEX [Idx_CA_game] ON [CommandAchievements] 
 (
  [Game_ID] ASC
 )
GO

CREATE NONCLUSTERED INDEX [Idx_CA_Command] ON [CommandAchievements] 
 (
  [Command_ID] ASC
 )
GO

CREATE NONCLUSTERED INDEX [Idx_CA_championship] ON [CommandAchievements] 
 (
  [Championship_ID] ASC
 )
GO

--single battles
CREATE TABLE [Single_battles]
(
 [ID]              int IDENTITY (1, 1) NOT NULL ,
 [Winner_ID]       int NOT NULL ,
 [Loser_ID]        int NOT NULL ,
 [Championship_ID] int NULL ,

 CONSTRAINT [PK_singlebattles] PRIMARY KEY CLUSTERED ([ID] ASC),
 CONSTRAINT [FK_SB_Winner] FOREIGN KEY ([Winner_ID])  REFERENCES [Players]([ID]),
 CONSTRAINT [FK_SB_Loser] FOREIGN KEY ([Loser_ID])  REFERENCES [Players]([ID]),
 CONSTRAINT [FK_SB_Championship] FOREIGN KEY ([Championship_ID])  REFERENCES [Championships]([ID])
);
GO


CREATE NONCLUSTERED INDEX [Idx_SB_winner] ON [Single_battles] 
 (
  [Winner_ID] ASC
 )
GO

CREATE NONCLUSTERED INDEX [Idx_SB_loser] ON [Single_battles] 
 (
  [Loser_ID] ASC
 )
GO

CREATE NONCLUSTERED INDEX [Idx_SB_championship] ON [Single_battles] 
 (
  [Championship_ID] ASC
 )
GO

--command battles
CREATE TABLE [Command_battles]
(
 [ID]              int IDENTITY (1, 1) NOT NULL ,
 [Winner_ID]       int NOT NULL ,
 [Loser_ID]        int NOT NULL ,
 [Championship_ID] int NULL ,

 CONSTRAINT [PK_commandbattles] PRIMARY KEY CLUSTERED ([ID] ASC),
 CONSTRAINT [FK_CB_Winner] FOREIGN KEY ([Winner_ID])  REFERENCES [Commands]([ID]),
 CONSTRAINT [FK_CB_Loser] FOREIGN KEY ([Loser_ID])  REFERENCES [Commands]([ID]),
 CONSTRAINT [FK_CB_Championship] FOREIGN KEY ([Championship_ID])  REFERENCES [Championships]([ID])
);
GO


CREATE NONCLUSTERED INDEX [Idx_CB_winner] ON [Command_battles] 
 (
  [Winner_ID] ASC
 )
GO

CREATE NONCLUSTERED INDEX [Idx_CB_loser] ON [Command_battles] 
 (
  [Loser_ID] ASC
 )
GO

CREATE NONCLUSTERED INDEX [Idx_CB_championship] ON [Command_battles] 
 (
  [Championship_ID] ASC
 )
GO
