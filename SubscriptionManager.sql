/****** Object:  Table [dbo].[Audit]    Script Date: 2015-05-01 1:31:44 PM ******/
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
	[SubscriptionId] [uniqueidentifier] NOT NULL,
	[SubscriptionStatus] [int] NOT NULL,
	[RequestData] [varchar](max) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Index [IX_Audit_Column]    Script Date: 2015-05-01 1:31:45 PM ******/
CREATE CLUSTERED INDEX [IX_Audit_Column] ON [dbo].[Audit]
(
	[Stamp] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Table [dbo].[EMAIL_LIST]    Script Date: 2015-05-01 1:31:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EMAIL_LIST](
	[ID] [uniqueidentifier] NOT NULL,
	[SUBSCRIBER_ID] [uniqueidentifier] NOT NULL,
	[EMAIL_URL] [varchar](45) NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[FIELDS]    Script Date: 2015-05-01 1:31:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FIELDS](
	[ID] [uniqueidentifier] NOT NULL,
	[FIELD_NAME] [varchar](45) NOT NULL,
	[FIELD_DESCRIPTION] [varchar](45) NOT NULL,
	[FIELD_TYPE] [varchar](45) NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[MERCHANT_REQUESTED_FIELDS]    Script Date: 2015-05-01 1:31:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MERCHANT_REQUESTED_FIELDS](
	[ID] [uniqueidentifier] NOT NULL,
	[PUBLICATION_ID] [uniqueidentifier] NOT NULL,
	[FIELD_ID] [uniqueidentifier] NOT NULL,
	[REQUIRED] [varchar](1) NOT NULL DEFAULT ('N'),
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[PUBLICATION]    Script Date: 2015-05-01 1:31:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PUBLICATION](
	[ID] [uniqueidentifier] NOT NULL,
	[NAME] [varchar](100) NOT NULL,
	[DESCRIPTION] [varchar](200) NOT NULL,
	[PUBLICATION_TYPE] [varchar](45) NOT NULL,
	[PUBLISHER_ID] [uniqueidentifier] NOT NULL,
	[STATUS] [varchar](10) NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[Publisher]    Script Date: 2015-05-01 1:31:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Publisher](
	[Id] [uniqueidentifier] NOT NULL,
	[ExternalId] [varchar](128) NOT NULL,
	[Description] [varchar](128) NOT NULL,
	[Created] [datetimeoffset](7) NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF),
 CONSTRAINT [AK_Publisher_Column] UNIQUE CLUSTERED 
(
	[ExternalId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[SUBSCRIBER]    Script Date: 2015-05-01 1:31:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SUBSCRIBER](
	[ID] [uniqueidentifier] NOT NULL,
	[FNAME] [varchar](45) NULL,
	[LNAME] [varchar](45) NULL,
	[DOB] [datetime] NULL,
	[GENDER] [varchar](10) NULL,
	[ZIP] [varchar](10) NULL,
	[PHONE] [varchar](20) NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[SUBSCRIPTION]    Script Date: 2015-05-01 1:31:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SUBSCRIPTION](
	[ID] [uniqueidentifier] NOT NULL,
	[EMAIL_ID] [uniqueidentifier] NOT NULL,
	[SUBSCRIBER_ID] [uniqueidentifier] NOT NULL,
	[PUBLICATION_ID] [uniqueidentifier] NOT NULL,
	[STATUS] [int] NOT NULL,
	[OPTINTYPE] [int] NOT NULL,
	[CREATED] [datetimeoffset](7) NOT NULL,
	[LASTUPDATE] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
ALTER TABLE [dbo].[EMAIL_LIST]  WITH NOCHECK ADD  CONSTRAINT [FK_Email_Subscriber_id] FOREIGN KEY([SUBSCRIBER_ID])
REFERENCES [dbo].[SUBSCRIBER] ([ID])
GO
ALTER TABLE [dbo].[EMAIL_LIST] CHECK CONSTRAINT [FK_Email_Subscriber_id]
GO
ALTER TABLE [dbo].[MERCHANT_REQUESTED_FIELDS]  WITH NOCHECK ADD  CONSTRAINT [FK_Merchant_Requested_Fields_publication_id] FOREIGN KEY([PUBLICATION_ID])
REFERENCES [dbo].[PUBLICATION] ([ID])
GO
ALTER TABLE [dbo].[MERCHANT_REQUESTED_FIELDS] CHECK CONSTRAINT [FK_Merchant_Requested_Fields_publication_id]
GO
ALTER TABLE [dbo].[PUBLICATION]  WITH NOCHECK ADD  CONSTRAINT [FK_Publication_publisher_id] FOREIGN KEY([PUBLISHER_ID])
REFERENCES [dbo].[Publisher] ([Id])
GO
ALTER TABLE [dbo].[PUBLICATION] CHECK CONSTRAINT [FK_Publication_publisher_id]
GO
ALTER TABLE [dbo].[SUBSCRIPTION]  WITH NOCHECK ADD  CONSTRAINT [FK_Subscription_Email_id] FOREIGN KEY([EMAIL_ID])
REFERENCES [dbo].[EMAIL_LIST] ([ID])
GO
ALTER TABLE [dbo].[SUBSCRIPTION] CHECK CONSTRAINT [FK_Subscription_Email_id]
GO
ALTER TABLE [dbo].[SUBSCRIPTION]  WITH NOCHECK ADD  CONSTRAINT [FK_Subscription_Publication_id] FOREIGN KEY([PUBLICATION_ID])
REFERENCES [dbo].[PUBLICATION] ([ID])
GO
ALTER TABLE [dbo].[SUBSCRIPTION] CHECK CONSTRAINT [FK_Subscription_Publication_id]
GO
ALTER TABLE [dbo].[SUBSCRIPTION]  WITH NOCHECK ADD  CONSTRAINT [FK_Subscription_Subscriber_id] FOREIGN KEY([SUBSCRIBER_ID])
REFERENCES [dbo].[SUBSCRIBER] ([ID])
GO
ALTER TABLE [dbo].[SUBSCRIPTION] CHECK CONSTRAINT [FK_Subscription_Subscriber_id]
GO
