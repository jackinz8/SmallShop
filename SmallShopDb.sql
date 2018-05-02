--use Nzhtest

--------------------------------------------------------------
CREATE TABLE [dbo].[Ref_Article](
	[ArticleId] [int] IDENTITY(1,1) Primary Key NOT NULL,
	[ArticleName] [nvarchar](50) NOT NULL,
	[ArticleDescription] [nvarchar](100),
	[Weight] int,
	[PriceEur] decimal,
	[Remark] [nvarchar](200),
	[IsActive] bit Default(1)
)
--drop table Ref_Article
select * from Ref_Article
insert into Ref_Article values
(N'APre',N'爱他美Pre段',800,14.95,'',1),
(N'A1',N'爱他美1段',800,14.95,'',1),
(N'A2',N'爱他美2段',800,14.95,'',1),
(N'A3',N'爱他美3段',800,14.95,'',1)
--delete from Ref_Article

---------------------------------------------------------------
--drop table OrderPos
--drop table Orders
CREATE TABLE [dbo].[Orders](
	OrderId			int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	CustomerId		int NOT NULL FOREIGN KEY REFERENCES Ref_Customers(CustomerId),
	AddressId		int NOT NULL FOREIGN KEY REFERENCES Ref_Addresses(AddressId),
	Cst_CostSumme		decimal default 0,
	Cst_Pack		decimal default 0,
	Cst_Express		decimal default 0,
	Cst_ExpressCivil	decimal default 0,
	Cst_Error		decimal default 0,
	Cst_Payed		decimal default 0,
	Cst_Gain as Cst_Payed-Cst_CostSumme-Cst_Pack-Cst_Express-Cst_ExpressCivil-Cst_Error,
	CreatedOn		datetime NOT NULL DEFAULT GETDATE(),
	PayedOn			datetime,
	SendOn			datetime,
	ReceivedOn		datetime,
	OrderStatus		int NOT NULL,
)
CREATE TABLE [dbo].[OrderPos](
	OrderId			int NOT NULL FOREIGN KEY REFERENCES Orders(OrderId),
	OrderPosId		int NOT NULL,
	ArticleId		int NOT NULL FOREIGN KEY REFERENCES Ref_Article(ArticleId),
	Cst_Price		decimal NOT NULL,
	Amount			int NOT NULL,
	Cst_PosSumme as Cst_Price*Amount,
	CreatedOn		datetime NOT NULL DEFAULT GETDATE(),
	primary key (OrderId, OrderPosId)
)


INSERT INTO [dbo].[Orders]
           ([CustomerId]
	       ,[AddressId]
           ,[Cst_CostSumme]
           ,[Cst_Pack]
           ,[Cst_Express]
           ,[Cst_ExpressCivil]
           ,[Cst_Error]
           ,[Cst_Payed]
           ,[CreatedOn]
           ,[PayedOn]
           ,[SendOn]
           ,[ReceivedOn]
           ,[OrderStatus])
     VALUES
           (1
	   ,1
           ,1200
           ,5
           ,300
           ,0
           ,0
           ,1800
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL
           ,1)
INSERT INTO [dbo].[OrderPos]
           ([OrderId]
           ,[OrderPosId]
           ,[ArticleId]
		   ,[Cst_Cost]
           ,[Cst_Price]
           ,[Amount]
           ,[CreatedOn])
     VALUES
           (1
           ,1
           ,6
		   ,120
           ,200
           ,3
           ,GETDATE()),
           (1
           ,2
           ,7
		   ,120
           ,200
           ,3
           ,GETDATE())