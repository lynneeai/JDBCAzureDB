/****** Object:  Table [dbo].[DW_Campaign_Dim]    Script Date: 2015-06-03 2:38:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Campaign_Dim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[OrgId] [int] NOT NULL,
	[StartTimePeriodId] [int] NOT NULL,
	[ExternalCampaignId] [uniqueidentifier] NOT NULL,
	[EndTimePeriodId] [int] NULL,
 CONSTRAINT [PK_DW_Campaign_Dim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_CampaignOfferItem_Fact]    Script Date: 2015-06-03 2:38:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_CampaignOfferItem_Fact](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CampaignId] [int] NOT NULL,
	[SegmentId] [int] NOT NULL,
	[SegmentComponentId] [int] NOT NULL,
	[OfferId] [int] NOT NULL,
	[SubscriptionId] [int] NOT NULL,
	[PosRedemptionCode] [nvarchar](max) NOT NULL,
	[ExternalOfferItemId] [uniqueidentifier] NOT NULL,
	[OrgId] [int] NOT NULL,
	[PublicationId] [int] NOT NULL,
	[Stamp] [datetimeoffset](7) NOT NULL,
	[TimePeriodId] [int] NOT NULL,
 CONSTRAINT [PK_DW_CampaignOfferItem_Fact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_CampaignOfferRedemption_Fact]    Script Date: 2015-06-03 2:38:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_CampaignOfferRedemption_Fact](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CampaignOfferItemId] [int] NOT NULL,
	[TimePeriodId] [int] NOT NULL,
	[CampaignId] [int] NOT NULL,
	[SegmentId] [int] NOT NULL,
	[OfferId] [int] NOT NULL,
	[SegmentComponentId] [int] NOT NULL,
	[SubscriptionId] [int] NOT NULL,
	[PosRedemptionCode] [nvarchar](max) NOT NULL,
	[LocId] [int] NOT NULL,
	[IntSerialId] [int] NOT NULL,
	[PublicationId] [int] NOT NULL,
	[OrgId] [int] NOT NULL,
	[Stamp] [datetimeoffset](7) NOT NULL,
	[ExternalOfferItemId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_DW_CampaignOfferRedemption_Fact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Interceptor_Dim]    Script Date: 2015-06-03 2:38:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Interceptor_Dim](
	[IntId] [int] NOT NULL,
	[IntSerial] [varchar](12) NULL,
	[OrgId] [int] NULL,
	[LocId] [int] NULL,
	[IntLocDesc] [varchar](100) NULL,
	[ForwardURL] [varchar](100) NULL,
	[ForwardType] [int] NULL,
	[MaxBatchWaitTime] [int] NULL,
	[DeviceStatus] [int] NULL,
	[StartURL] [varchar](100) NULL,
	[ReportURL] [varchar](100) NULL,
	[ScanURL] [varchar](100) NULL,
	[BkupURL] [varchar](100) NULL,
	[Capture] [int] NULL,
	[CaptureMode] [int] NULL,
	[RequestTimeoutValue] [int] NULL,
	[CallHomeTimeoutMode] [int] NULL,
	[CallHomeTimeoutData] [varchar](50) NULL,
	[DynCodeFormat] [varchar](5550) NULL,
	[Security] [int] NULL,
	[ErrorLog] [bit] NULL,
	[WpaPSK] [varchar](64) NULL,
	[SSId] [varchar](32) NULL,
	[CmdURL] [varchar](100) NULL,
	[CmdChkInt] [int] NULL,
 CONSTRAINT [PK_Interceptor_2] PRIMARY KEY CLUSTERED 
(
	[IntId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Location_Dim]    Script Date: 2015-06-03 2:38:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Location_Dim](
	[LocId] [int] NOT NULL,
	[LocDesc] [nvarchar](50) NULL,
	[OrgId] [int] NULL,
	[UnitSuite] [varchar](15) NULL,
	[Street] [nvarchar](200) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [varchar](50) NULL,
	[PostalCode] [varchar](10) NULL,
	[Latitude] [numeric](18, 15) NULL,
	[Longitude] [numeric](18, 15) NULL,
	[LocType] [nvarchar](50) NULL,
	[LocSubType] [nvarchar](50) NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[LocId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Offer_Dim]    Script Date: 2015-06-03 2:38:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Offer_Dim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[ExternalOfferId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_DW_Offer_Dim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Organization_Dim]    Script Date: 2015-06-03 2:38:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Organization_Dim](
	[OrgId] [int] NOT NULL,
	[OrgName] [nvarchar](100) NULL,
	[ApplicationKey] [varchar](40) NULL,
	[IpAddress] [varchar](15) NULL,
	[Owner] [int] NULL,
	[StartWeekOnSunday] [bit] NULL,
 CONSTRAINT [PK_ut_Organization] PRIMARY KEY CLUSTERED 
(
	[OrgId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Product_Dim]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Product_Dim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[UPC] [varchar](12) NOT NULL,
	[EAN] [varchar](13) NOT NULL,
	[Price] [decimal](15, 2) NULL,
	[Cost] [decimal](15, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Publication_Dim]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Publication_Dim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ExternalId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_DW_Publication_Dim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_RedemptionTransaction_Idx]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_RedemptionTransaction_Idx](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransactionId] [bigint] NOT NULL,
	[RedemptionId] [int] NOT NULL,
 CONSTRAINT [PK_DW_RedemptionTransaction_Idx] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Segment_Dim]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Segment_Dim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_DW_Segment_Dim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_SegmentComponent_Dim]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_SegmentComponent_Dim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_DW_SegmentComponent_Dim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Subscription_Dim]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Subscription_Dim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Uri] [nvarchar](max) NOT NULL,
	[ExternalSubscriptionId] [uniqueidentifier] NOT NULL,
	[Stamp] [datetimeoffset](7) NOT NULL,
	[TimePeriodId] [int] NOT NULL,
	[OrgId] [int] NOT NULL,
 CONSTRAINT [PK_DW_Subscription_Dim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Time_Dim]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Time_Dim](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[Quarter] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Day] [int] NOT NULL,
	[DayOfWeek] [int] NOT NULL,
	[Hour] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Transaction_Dim]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Transaction_Dim](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TimePeriodId] [int] NOT NULL,
	[IntSerial] [varchar](12) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_Transaction_Idx]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_Transaction_Idx](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransactionId] [bigint] NOT NULL,
	[ScanData] [varchar](max) NOT NULL,
	[AssocScanData] [varchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[DW_TransactionLine_Fact]    Script Date: 2015-06-03 2:38:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW_TransactionLine_Fact](
	[TransactionId] [bigint] NOT NULL,
	[Line] [int] NOT NULL,
	[IntSerial] [varchar](12) NOT NULL,
	[ScanData] [varchar](max) NOT NULL,
	[OriginalScanDate] [datetimeoffset](7) NOT NULL,
	[OriginalScanId] [bigint] NOT NULL,
	[Units] [int] NULL,
	[Sales] [decimal](15, 2) NULL,
	[Margin] [decimal](15, 2) NULL,
	[RedemptionData] [varchar](max) NULL,
 CONSTRAINT [PK_TransactionLine] PRIMARY KEY CLUSTERED 
(
	[TransactionId] ASC,
	[Line] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Index [IX_DW_Campaign_Dim_ExtId]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DW_Campaign_Dim_ExtId] ON [dbo].[DW_Campaign_Dim]
(
	[ExternalCampaignId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [IX_DW_CampaignOfferItem_Fact_ExtOfferItemId]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DW_CampaignOfferItem_Fact_ExtOfferItemId] ON [dbo].[DW_CampaignOfferItem_Fact]
(
	[ExternalOfferItemId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [FK_OrgId]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE NONCLUSTERED INDEX [FK_OrgId] ON [dbo].[DW_Location_Dim]
(
	[OrgId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [IX_DW_Offer_Dim_ExtId]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DW_Offer_Dim_ExtId] ON [dbo].[DW_Offer_Dim]
(
	[ExternalOfferId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [IX_DW_Publication_Dim_ExtId]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DW_Publication_Dim_ExtId] ON [dbo].[DW_Publication_Dim]
(
	[ExternalId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [IX_DW_RedemptionTransaction_Idx_RdmpId]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DW_RedemptionTransaction_Idx_RdmpId] ON [dbo].[DW_RedemptionTransaction_Idx]
(
	[RedemptionId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [IX_DW_Subscription_Dim_ExtId]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DW_Subscription_Dim_ExtId] ON [dbo].[DW_Subscription_Dim]
(
	[ExternalSubscriptionId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [FK_Time_Day]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE NONCLUSTERED INDEX [FK_Time_Day] ON [dbo].[DW_Time_Dim]
(
	[Day] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [FK_Time_DayOfWeek]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE NONCLUSTERED INDEX [FK_Time_DayOfWeek] ON [dbo].[DW_Time_Dim]
(
	[DayOfWeek] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [FK_Time_Hour]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE NONCLUSTERED INDEX [FK_Time_Hour] ON [dbo].[DW_Time_Dim]
(
	[Hour] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [FK_Time_Month]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE NONCLUSTERED INDEX [FK_Time_Month] ON [dbo].[DW_Time_Dim]
(
	[Month] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [FK_Time_Quarter]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE NONCLUSTERED INDEX [FK_Time_Quarter] ON [dbo].[DW_Time_Dim]
(
	[Quarter] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [FK_Time_Year]    Script Date: 2015-06-03 2:38:08 PM ******/
CREATE NONCLUSTERED INDEX [FK_Time_Year] ON [dbo].[DW_Time_Dim]
(
	[Year] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
ALTER TABLE [dbo].[DW_Location_Dim]  WITH NOCHECK ADD  CONSTRAINT [FK_Location_Organization] FOREIGN KEY([OrgId])
REFERENCES [dbo].[DW_Organization_Dim] ([OrgId])
GO
ALTER TABLE [dbo].[DW_Location_Dim] CHECK CONSTRAINT [FK_Location_Organization]
GO
