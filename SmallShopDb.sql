use Nzhtest

--3 Sys Tables--
CREATE TABLE [dbo].[Sys_OrderStatus](
	[OrderStatusId] [int] NOT NULL,
	[OrderStatusName] [nvarchar](8) NOT NULL,
	CONSTRAINT PK_OrderStatusId  PRIMARY KEY ([OrderStatusId])
)
GO
CREATE TABLE [dbo].[Sys_CustomerGroup](
	[DiscountGroupId] [int] NOT NULL,
	[DiscountGroupName] [nvarchar](3) NOT NULL,
	[DiscountValue] [int],
	[DiscountPercent] [int],
	CONSTRAINT PK_DiscountGroupId PRIMARY KEY ([DiscountGroupId])
)
GO
CREATE TABLE [dbo].[Sys_Currency](
	[CurrencyId] [int] IDENTITY(1,1) NOT NULL,
	[Currency] [decimal](10, 2) NOT NULL,
	[FromDate] [datetime] CONSTRAINT DV_FromDate DEFAULT GETDATE() NOT NULL,
	CONSTRAINT PK_CurrencyId  PRIMARY KEY ([CurrencyId])
)
GO

--3 Ref Tables--
CREATE TABLE [dbo].[Ref_Article](
	[ArticleId] [int] IDENTITY(1,1) Primary Key NOT NULL,
	[ArticleName] [nvarchar](50) NOT NULL,
	[ArticleDescription] [nvarchar](100),
	[Weight] int,
	[PriceEur] decimal,
	[Remark] [nvarchar](200),
	[IsActive] bit Default(1)
)


--3 Main Tables--
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


--drop table Ref_Article
--drop table OrderPos
--drop table Orders