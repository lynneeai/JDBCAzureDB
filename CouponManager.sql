/****** Object:  Table [dbo].[Audit]    Script Date: 2015-05-01 1:27:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audit](
	[Id] [uniqueidentifier] NOT NULL,
	[Stamp] [datetimeoffset](7) NOT NULL,
	[Action] [int] NOT NULL,
	[RequestedBy] [varchar](128) NOT NULL,
	[RequestedByUrl] [varchar](128) NOT NULL,
	[CouponId] [uniqueidentifier] NOT NULL,
	[CouponStatus] [int] NOT NULL,
	[MiscData] [varchar](max) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Index [IX_Table_Column]    Script Date: 2015-05-01 1:27:52 PM ******/
CREATE CLUSTERED INDEX [IX_Table_Column] ON [dbo].[Audit]
(
	[Stamp] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Table [dbo].[Campaign]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Campaign](
	[Id] [uniqueidentifier] NOT NULL,
	[Description] [varchar](128) NOT NULL,
	[Created] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Description] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF),
 CONSTRAINT [AK_Campaign_Column] UNIQUE NONCLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[Coupon]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Coupon](
	[Id] [uniqueidentifier] NOT NULL,
	[OfferId] [uniqueidentifier] NOT NULL,
	[Created] [datetimeoffset](7) NOT NULL,
	[CouponStatus] [int] NOT NULL,
	[IssueeId] [uniqueidentifier] NOT NULL,
	[IssuerId] [uniqueidentifier] NOT NULL,
	[PosOfferCode] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[ExpiryRule]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExpiryRule](
	[Id] [uniqueidentifier] NOT NULL,
	[Expiry] [datetimeoffset](7) NOT NULL,
	[Created] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[IRule]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IRule](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[Type] [varchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF),
 CONSTRAINT [AK_IRule_Column] UNIQUE NONCLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[IRuleState]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IRuleState](
	[RuleId] [uniqueidentifier] NOT NULL,
	[OfferId] [uniqueidentifier] NOT NULL,
	[CouponId] [uniqueidentifier] NOT NULL,
	[Type] [varchar](max) NOT NULL,
	[State] [varchar](max) NOT NULL,
 CONSTRAINT [AK_Table_Column] UNIQUE CLUSTERED 
(
	[RuleId] ASC,
	[OfferId] ASC,
	[CouponId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[Issuer]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Issuer](
	[Id] [uniqueidentifier] NOT NULL,
	[Description] [varchar](128) NOT NULL,
	[Created] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Description] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF),
 CONSTRAINT [AK_Issuer_Column] UNIQUE NONCLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[MaxRedemptionsRule]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MaxRedemptionsRule](
	[Id] [uniqueidentifier] NOT NULL,
	[MaxRedemptions] [int] NOT NULL,
	[Created] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[Offer]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Offer](
	[Id] [uniqueidentifier] NOT NULL,
	[SaveStory] [varchar](128) NOT NULL,
	[Created] [datetimeoffset](7) NOT NULL,
	[CampaignId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[OfferToRule]    Script Date: 2015-05-01 1:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfferToRule](
	[OfferId] [uniqueidentifier] NOT NULL,
	[RuleId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[OfferId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
ALTER TABLE [dbo].[Coupon]  WITH NOCHECK ADD  CONSTRAINT [FK_Coupon_ToTable] FOREIGN KEY([IssuerId])
REFERENCES [dbo].[Issuer] ([Id])
GO
ALTER TABLE [dbo].[Coupon] CHECK CONSTRAINT [FK_Coupon_ToTable]
GO
ALTER TABLE [dbo].[Coupon]  WITH NOCHECK ADD  CONSTRAINT [FK_Coupon_ToTable_1] FOREIGN KEY([OfferId])
REFERENCES [dbo].[Offer] ([Id])
GO
ALTER TABLE [dbo].[Coupon] CHECK CONSTRAINT [FK_Coupon_ToTable_1]
GO
ALTER TABLE [dbo].[ExpiryRule]  WITH NOCHECK ADD  CONSTRAINT [FK_ExpiryRule_ToTable] FOREIGN KEY([Id])
REFERENCES [dbo].[IRule] ([Id])
GO
ALTER TABLE [dbo].[ExpiryRule] CHECK CONSTRAINT [FK_ExpiryRule_ToTable]
GO
ALTER TABLE [dbo].[MaxRedemptionsRule]  WITH NOCHECK ADD  CONSTRAINT [FK_MaxRedemptionsRule_ToTable] FOREIGN KEY([Id])
REFERENCES [dbo].[IRule] ([Id])
GO
ALTER TABLE [dbo].[MaxRedemptionsRule] CHECK CONSTRAINT [FK_MaxRedemptionsRule_ToTable]
GO
ALTER TABLE [dbo].[Offer]  WITH CHECK ADD  CONSTRAINT [FK_Offer_ToTable] FOREIGN KEY([CampaignId])
REFERENCES [dbo].[Campaign] ([Id])
GO
ALTER TABLE [dbo].[Offer] CHECK CONSTRAINT [FK_Offer_ToTable]
GO
ALTER TABLE [dbo].[OfferToRule]  WITH NOCHECK ADD  CONSTRAINT [FK_OfferToRule_ToTable] FOREIGN KEY([RuleId])
REFERENCES [dbo].[IRule] ([Id])
GO
ALTER TABLE [dbo].[OfferToRule] CHECK CONSTRAINT [FK_OfferToRule_ToTable]
GO
