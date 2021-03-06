/****** Object:  Table [dbo].[Cache]    Script Date: 2015-05-01 1:29:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cache](
	[Key] [varchar](512) NOT NULL,
	[Item] [varchar](2048) NOT NULL,
	[Stamp] [datetimeoffset](7) NOT NULL,
	[Slug] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[CAMPAIGN]    Script Date: 2015-05-01 1:29:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CAMPAIGN](
	[ID] [uniqueidentifier] NOT NULL,
	[PUBLISHER_ID] [uniqueidentifier] NOT NULL,
	[CAMPAIGN_NAME] [varchar](50) NOT NULL,
	[CAMPAIGN_DESC] [varchar](250) NOT NULL,
	[COUPON_DESC] [varchar](250) NOT NULL,
	[SLUG] [varchar](50) NOT NULL,
	[OFFER_ID] [uniqueidentifier] NOT NULL,
	[POST_OFFER_CODE] [varchar](50) NOT NULL,
	[ORGID] [int] NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
	[LAST_UPDATE] [datetimeoffset](7) NOT NULL,
	[COUPON_OFFER_ID] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[CAMPAIGN_PUBLICATION_REL]    Script Date: 2015-05-01 1:29:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CAMPAIGN_PUBLICATION_REL](
	[ID] [uniqueidentifier] NOT NULL,
	[CAMPAIGN_ID] [uniqueidentifier] NOT NULL,
	[PUBLICATION_ID] [uniqueidentifier] NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
	[IST_RFM_PUBLICATION] [bit] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[CAMPAIGN_RFM]    Script Date: 2015-05-01 1:29:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CAMPAIGN_RFM](
	[ID] [uniqueidentifier] NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[DESCRIPTION] [varchar](100) NULL,
	[ORG_ID] [int] NOT NULL,
	[START_DATE] [datetime] NOT NULL,
	[END_DATE] [datetime] NOT NULL,
	[SIGNON_CAMPAIGN] [uniqueidentifier] NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
	[LAST_UPDATE] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [Idx_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[CampaignSubscriber]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CampaignSubscriber](
	[Id] [uniqueidentifier] NOT NULL,
	[Uri] [varchar](512) NOT NULL,
	[CampaignId] [uniqueidentifier] NOT NULL,
	[State] [int] NOT NULL,
	[CouponId] [uniqueidentifier] NULL,
	[Created] [datetimeoffset](7) NOT NULL,
	[LastUpdate] [datetimeoffset](7) NOT NULL,
	[DynamicCodeId] [int] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CampaignSubscriber_Column]    Script Date: 2015-05-01 1:29:49 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_CampaignSubscriber_Column] ON [dbo].[CampaignSubscriber]
(
	[CampaignId] ASC,
	[Uri] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Table [dbo].[CONTENT_MANAGER]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CONTENT_MANAGER](
	[ID] [uniqueidentifier] NOT NULL,
	[PUBLISHER_ID] [uniqueidentifier] NOT NULL,
	[CONTENT_TYPE] [varchar](25) NOT NULL,
	[CONTENT] [varchar](max) NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[FIELD_SEQUENCE]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FIELD_SEQUENCE](
	[ID] [uniqueidentifier] NOT NULL,
	[CAMPAIGN_ID] [uniqueidentifier] NOT NULL,
	[FIELD_NAME] [varchar](50) NOT NULL,
	[SEQUENCE_NO] [int] NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[CAMPAIGN_ID] ASC,
	[FIELD_NAME] ASC,
	[SEQUENCE_NO] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[GENERIC_TEMPLATE]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GENERIC_TEMPLATE](
	[KEY] [varchar](100) NOT NULL,
	[VALUE] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Table] PRIMARY KEY CLUSTERED 
(
	[KEY] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[MESSAGE_TEMPLATE]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MESSAGE_TEMPLATE](
	[ID] [uniqueidentifier] NOT NULL,
	[CAMPAIGN_ID] [uniqueidentifier] NOT NULL,
	[KEY] [varchar](200) NOT NULL,
	[VALUE] [varchar](max) NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CAMPAIGN_ID] ASC,
	[KEY] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[OFFER]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OFFER](
	[ID] [uniqueidentifier] NOT NULL,
	[NAME] [varchar](100) NOT NULL,
	[DESCRIPTION] [varchar](100) NULL,
	[POS_OFFER_CODE] [varchar](50) NOT NULL,
	[ORG_ID] [int] NOT NULL,
	[TERMS_CONDITIONS] [varchar](max) NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
	[LAST_UPDATE] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [Pk_OFFER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[ORGANIZATION]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ORGANIZATION](
	[ID] [int] NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[TERMS_AND_CONDITIONS] [varchar](max) NOT NULL,
	[PRIVACY_POLICY] [varchar](max) NOT NULL,
	[LOGO_URL] [varchar](300) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[RFMCampaignNotificationState]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RFMCampaignNotificationState](
	[Id] [uniqueidentifier] NOT NULL,
	[state] [int] NOT NULL,
	[stamp] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[SEGMENT]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SEGMENT](
	[ID] [uniqueidentifier] NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[CAMPAIGN_RFM] [uniqueidentifier] NOT NULL,
	[OFFER_ID] [uniqueidentifier] NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
	[LAST_UPDATE] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [Pk_SEGMENTATION] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[SUBJECT_TEMPLATE]    Script Date: 2015-05-01 1:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SUBJECT_TEMPLATE](
	[ID] [uniqueidentifier] NOT NULL,
	[CAMPAIGN_ID] [uniqueidentifier] NOT NULL,
	[KEY] [varchar](200) NOT NULL,
	[VALUE] [varchar](2000) NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CAMPAIGN_ID] ASC,
	[KEY] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Index [IX_Cache_Column]    Script Date: 2015-05-01 1:29:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_Cache_Column] ON [dbo].[Cache]
(
	[Stamp] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [IX_SEGMENT_Offer]    Script Date: 2015-05-01 1:29:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_SEGMENT_Offer] ON [dbo].[SEGMENT]
(
	[OFFER_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
ALTER TABLE [dbo].[CAMPAIGN_RFM]  WITH CHECK ADD  CONSTRAINT [Fk_CAMPAIGN_RFM_SIGNON] FOREIGN KEY([SIGNON_CAMPAIGN])
REFERENCES [dbo].[CAMPAIGN] ([ID])
GO
ALTER TABLE [dbo].[CAMPAIGN_RFM] CHECK CONSTRAINT [Fk_CAMPAIGN_RFM_SIGNON]
GO
ALTER TABLE [dbo].[FIELD_SEQUENCE]  WITH NOCHECK ADD  CONSTRAINT [FK_Field_Seq_CampaignId] FOREIGN KEY([CAMPAIGN_ID])
REFERENCES [dbo].[CAMPAIGN] ([ID])
GO
ALTER TABLE [dbo].[FIELD_SEQUENCE] CHECK CONSTRAINT [FK_Field_Seq_CampaignId]
GO
ALTER TABLE [dbo].[RFMCampaignNotificationState]  WITH CHECK ADD  CONSTRAINT [FK_RFMCampaignNotificationState_ToCAMPAIGNRFM] FOREIGN KEY([Id])
REFERENCES [dbo].[CAMPAIGN_RFM] ([ID])
GO
ALTER TABLE [dbo].[RFMCampaignNotificationState] CHECK CONSTRAINT [FK_RFMCampaignNotificationState_ToCAMPAIGNRFM]
GO
ALTER TABLE [dbo].[SEGMENT]  WITH CHECK ADD  CONSTRAINT [Fk_SEGMENTATION_CAMPAIGN_RFM] FOREIGN KEY([CAMPAIGN_RFM])
REFERENCES [dbo].[CAMPAIGN_RFM] ([ID])
GO
ALTER TABLE [dbo].[SEGMENT] CHECK CONSTRAINT [Fk_SEGMENTATION_CAMPAIGN_RFM]
GO
ALTER TABLE [dbo].[SEGMENT]  WITH CHECK ADD  CONSTRAINT [Fk_SEGMENTATION_OFFER] FOREIGN KEY([OFFER_ID])
REFERENCES [dbo].[OFFER] ([ID])
GO
ALTER TABLE [dbo].[SEGMENT] CHECK CONSTRAINT [Fk_SEGMENTATION_OFFER]
GO
