use Nzhtest

--DROP TABLE [OrderPos]
--DROP TABLE [Orders]

--DROP TABLE [Ref_Addresses]
--DROP TABLE [Ref_Customers]
--DROP TABLE [Ref_Article]

--DROP TABLE [Sys_OrderStatus]
--DROP TABLE [Sys_CustomerGroup]
--DROP TABLE [Sys_Currency]

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
CREATE TABLE [dbo].[Ref_Customers](
	[CustomerId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerName] [nvarchar](20) NULL,
	[DiscountGroup] [int] NULL,
	[Remark] [nvarchar](200) NULL,
	CONSTRAINT PK_CustomerId PRIMARY KEY (CustomerId),
	CONSTRAINT FK_DiscountGroup FOREIGN KEY([DiscountGroup]) REFERENCES [dbo].[Sys_CustomerGroup] ([DiscountGroupId]) ON DELETE CASCADE
)
GO

CREATE TABLE [dbo].[Ref_Addresses](
	[AddressId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NULL,
	[Receiver] [nvarchar](20) NULL,
	[AddressText] [nvarchar](100) NOT NULL,
	[Zip] [nvarchar](10) NULL,
	[Mobilephone] [nvarchar](20) NOT NULL,
	[ChineseId] [nvarchar](18) NULL,
	[Remark] [nvarchar](200) NULL,
	[Status] [int] CONSTRAINT DV_Status DEFAULT (1) NOT NULL,
	CONSTRAINT PK_AddressId PRIMARY KEY (AddressId),
	CONSTRAINT FK_CustomerId FOREIGN KEY (CustomerId) REFERENCES [dbo].[Ref_Customers] ([CustomerId]) ON DELETE CASCADE
)
GO

CREATE TABLE [dbo].[Ref_Article](
	[ArticleId] [int] IDENTITY(1,1) NOT NULL,
	[ArticleName] [nvarchar](50) NOT NULL,
	[ArticleDescription] [nvarchar](100),
	[Weight] int,
	[PriceEur] decimal,
	[SalePrice] decimal,
	[Remark] [nvarchar](200),
	[IsActive] bit Default(1),
	CONSTRAINT PK_ArticleId PRIMARY KEY (ArticleId)
)
GO

--2 Main Tables--
CREATE TABLE [dbo].[Orders](
	OrderId			int NOT NULL IDENTITY(1,1),
	CustomerId		int NOT NULL FOREIGN KEY REFERENCES Ref_Customers(CustomerId),
	AddressId		int NOT NULL CONSTRAINT FK_AddressId FOREIGN KEY REFERENCES Ref_Addresses(AddressId) ON DELETE CASCADE,
	Cst_CostSumme		decimal default 0,
	Cst_PriceSumme		decimal default 0,
	Cst_Pack		decimal default 0,
	Cst_Express		decimal default 0,
	Cst_ExpressCivil	decimal default 0,
	Cst_Error		decimal default 0,
	Cst_Payed		decimal default 0,
	Cst_Gain as Cst_Payed-Cst_CostSumme-Cst_Pack-Cst_Express-Cst_ExpressCivil-Cst_Error,
	CreatedOn		datetime NOT NULL DEFAULT GETDATE(),
	PayedOn			datetime,
	SentOn			datetime,
	ReceivedOn		datetime,
	OrderStatus	as (case when [ReceivedOn] IS NOT NULL then case when [PayedOn] IS NOT NULL then (6) else (5) end else case when [SentOn] IS NOT NULL then case when [PayedOn] IS NOT NULL then (4) else (3) end else case when [PayedOn] IS NOT NULL then (2) else (1) end end end)
	CONSTRAINT PK_OrderId PRIMARY KEY (OrderId),
)
GO

CREATE TABLE [dbo].[OrderPos](
	OrderId			int NOT NULL CONSTRAINT FK_OrderId FOREIGN KEY REFERENCES Orders(OrderId) ON DELETE CASCADE,
	OrderPosId		int NOT NULL,
	ArticleId		int NOT NULL CONSTRAINT FK_ArticleId FOREIGN KEY REFERENCES Ref_Article(ArticleId) ON DELETE CASCADE,
	Cst_Cost		decimal NOT NULL,
	Cst_Price		decimal NOT NULL,
	Amount			int NOT NULL,
	Cst_PosSumme as Cst_Price*Amount,
	CreatedOn		datetime NOT NULL CONSTRAINT DV_CreatedOn DEFAULT GETDATE(),
	CONSTRAINT PK_OrderId_OrderPosId PRIMARY KEY (OrderId, OrderPosId)
)

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[Trg_OrderPos_IUD]
   ON  [dbo].[OrderPos]
   AFTER INSERT,DELETE,UPDATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @OrderId int
	DECLARE @CstSumme decimal
	DECLARE @PrcSumme decimal

	-- update, insert
	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		SELECT @OrderId = OrderId FROM inserted
		SELECT @CstSumme = SUM(Cst_Cost), @PrcSumme = SUM(Cst_Price) FROM OrderPos WHERE OrderId = @OrderId
		UPDATE Orders SET Cst_CostSumme = @CstSumme, Cst_PriceSumme = @PrcSumme WHERE OrderId = @OrderId

	END

	-- delete
	IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
	BEGIN
		SELECT @OrderId = OrderId FROM deleted
		SELECT @CstSumme = SUM(Cst_Cost), @PrcSumme = SUM(Cst_Price) FROM OrderPos WHERE OrderId = @OrderId
		UPDATE Orders SET Cst_CostSumme = @CstSumme, Cst_PriceSumme = @PrcSumme WHERE OrderId = @OrderId
	END

END
GO
