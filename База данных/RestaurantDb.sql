USE [master]
GO
/****** Object:  Database [Restaurant]    Script Date: 12.10.2020 14:03:42 ******/
CREATE DATABASE [Restaurant]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Restaurant', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Restaurant.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Restaurant_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Restaurant_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [Restaurant] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Restaurant].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Restaurant] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Restaurant] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Restaurant] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Restaurant] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Restaurant] SET ARITHABORT OFF 
GO
ALTER DATABASE [Restaurant] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Restaurant] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Restaurant] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Restaurant] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Restaurant] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Restaurant] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Restaurant] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Restaurant] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Restaurant] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Restaurant] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Restaurant] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Restaurant] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Restaurant] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Restaurant] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Restaurant] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Restaurant] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Restaurant] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Restaurant] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Restaurant] SET  MULTI_USER 
GO
ALTER DATABASE [Restaurant] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Restaurant] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Restaurant] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Restaurant] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Restaurant] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Restaurant] SET QUERY_STORE = OFF
GO
USE [Restaurant]
GO
/****** Object:  Table [dbo].[ClientsGroups]    Script Date: 12.10.2020 14:03:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientsGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Size] [int] NOT NULL,
	[TableId] [int] NULL,
	[Status] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tables]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tables](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Size] [int] NOT NULL,
	[FreeSize] [int] NOT NULL,
	[IsFree] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientsGroups]  WITH CHECK ADD  CONSTRAINT [FK_TableId] FOREIGN KEY([TableId])
REFERENCES [dbo].[Tables] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ClientsGroups] CHECK CONSTRAINT [FK_TableId]
GO
/****** Object:  StoredProcedure [dbo].[AddClientsGroup]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddClientsGroup]
    @Size int,
	@Status bit,
	@TableId int = null
AS
BEGIN
    INSERT INTO [ClientsGroups](Size, Status, TableId)
    VALUES (@Size, @Status, @TableId)
END
GO
/****** Object:  StoredProcedure [dbo].[AddClientsGroupAndUpdateTable]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddClientsGroupAndUpdateTable]
	@Size int,
	@Status bit,
	@TableId int = null,
	@IsFree bit,
	@FreeSize int
AS
	BEGIN TRANSACTION [Tran1]

	  BEGIN TRY

		  INSERT INTO [ClientsGroups](Size, Status, TableId)
		  VALUES (@Size, @Status, @TableId)

		  UPDATE [Tables] SET 
		  FreeSize = @FreeSize, 
	      IsFree = @IsFree
	      WHERE Id = @TableId

		  COMMIT TRANSACTION [Tran1]

	  END TRY

	  BEGIN CATCH

		  ROLLBACK TRANSACTION [Tran1]

	  END CATCH  
GO
/****** Object:  StoredProcedure [dbo].[GetClientsGroupInQueue]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetClientsGroupInQueue]
AS
BEGIN
	SELECT * 
	FROM dbo.ClientsGroups WHERE Status = 0
	ORDER BY Id ASC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetClientsGroupOnTable]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetClientsGroupOnTable]
AS
BEGIN
	SELECT * 
	FROM dbo.ClientsGroups WHERE Status = 1;
END
GO
/****** Object:  StoredProcedure [dbo].[GetClientsGroupTable]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetClientsGroupTable]
	@TableId int
AS
BEGIN
	SELECT * 
	FROM dbo.Tables WHERE Id = @TableId;
END
GO
/****** Object:  StoredProcedure [dbo].[GetFreeTables]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetFreeTables]
	@Size INT
AS
BEGIN
	SELECT * 
	FROM dbo.Tables WHERE FreeSize >= @Size 
	ORDER BY FreeSize ASC;
END
GO
/****** Object:  StoredProcedure [dbo].[RemoveClientsGroup]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoveClientsGroup]
    @Id int
AS
BEGIN
    DELETE FROM ClientsGroups WHERE Id = @Id
END
GO
/****** Object:  StoredProcedure [dbo].[RemoveClientsGroupAndUpdateTable]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoveClientsGroupAndUpdateTable]
	@Id int,
	@TableId int,
	@IsFree bit,
	@FreeSize int
AS
	BEGIN TRANSACTION [Tran2]

	  BEGIN TRY

		  DELETE FROM ClientsGroups WHERE Id = @Id

		  UPDATE [Tables] SET 
		  FreeSize = @FreeSize, 
	      IsFree = @IsFree
	      WHERE Id = @TableId

		  COMMIT TRANSACTION [Tran2]

	  END TRY

	  BEGIN CATCH

		  ROLLBACK TRANSACTION [Tran2]

	  END CATCH  
GO
/****** Object:  StoredProcedure [dbo].[UpdateClientsGroupAndUpdateTable]    Script Date: 12.10.2020 14:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateClientsGroupAndUpdateTable]
	@Id int,
	@Status bit,
	@TableId int,
	@IsFree bit,
	@FreeSize int
AS
	BEGIN TRANSACTION [Tran3]

	  BEGIN TRY

		  UPDATE [ClientsGroups] SET 
		  Status = @Status,
		  TableId = @TableId
		  WHERE Id = @Id

		  UPDATE [Tables] SET 
		  FreeSize = @FreeSize, 
	      IsFree = @IsFree
	      WHERE Id = @TableId

		  COMMIT TRANSACTION [Tran3]

	  END TRY

	  BEGIN CATCH

		  ROLLBACK TRANSACTION [Tran3]

	  END CATCH  
GO
USE [master]
GO
ALTER DATABASE [Restaurant] SET  READ_WRITE 
GO
