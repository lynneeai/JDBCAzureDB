/****** Object:  Table [dbo].[tblAlerts]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAlerts](
	[OrgId] [int] NULL,
	[TimeStamp] [datetimeoffset](7) NULL,
	[AlertId] [varchar](6) NULL,
	[AlertData] [varchar](64) NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_tblAlerts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblArchivedInterceptor]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblArchivedInterceptor](
	[IntId] [int] NOT NULL,
	[IntSerial] [varchar](12) NULL,
	[OrgId] [int] NULL,
	[LocId] [int] NULL,
	[ForwardURL] [varchar](100) NULL,
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
	[DynCodeFormat] [varchar](50) NULL,
	[Security] [int] NULL,
	[ErrorLog] [bit] NULL,
	[WpaPSK] [varchar](64) NULL,
	[SSId] [varchar](32) NULL,
	[CanDate] [datetimeoffset](7) NULL,
	[CmdURL] [varchar](100) NULL,
	[CmdChkInt] [int] NULL,
 CONSTRAINT [PK_ArchivedInterceptor] PRIMARY KEY CLUSTERED 
(
	[IntId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblArchivedOrg]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblArchivedOrg](
	[OrgId] [int] NOT NULL,
	[OrgName] [nvarchar](100) NULL,
	[ApplicationKey] [varchar](40) NULL,
	[IPAddress] [varchar](15) NULL,
	[Owner] [nvarchar](100) NULL,
	[CanDate] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ArchivedOrg] PRIMARY KEY CLUSTERED 
(
	[OrgId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblArchivedUser]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblArchivedUser](
	[UserId] [varchar](5) NOT NULL,
	[OrgId] [int] NULL,
	[Password] [varchar](40) NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[RegDate] [datetimeoffset](7) NULL,
	[AccessLevel] [int] NULL,
	[CanDate] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ArchivedUser] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblAuthorization]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAuthorization](
	[RoleId] [int] NOT NULL,
	[ResourceId] [int] NOT NULL,
 CONSTRAINT [PK_tblAuthorization] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC,
	[ResourceId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblCmdQueue]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCmdQueue](
	[IntSerial] [varchar](12) NOT NULL,
	[Cmd] [int] NULL,
	[CmdTime] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_tblCmdQueue] PRIMARY KEY CLUSTERED 
(
	[IntSerial] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblContent]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblContent](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[OrgId] [int] NULL,
	[Code] [varchar](20) NULL,
	[Category] [nvarchar](30) NULL,
	[Model] [nvarchar](30) NULL,
	[Manufacturer] [nvarchar](30) NULL,
	[PartNumber] [nvarchar](30) NULL,
	[ProductLine] [nvarchar](30) NULL,
	[ManufacturerSKU] [varchar](50) NULL,
	[UnitMeasure] [varchar](15) NULL,
	[UnitPrice] [real] NULL,
	[Misc1] [nvarchar](50) NULL,
	[Misc2] [nvarchar](50) NULL,
 CONSTRAINT [PK_Content] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblCountries]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCountries](
	[CountryID] [int] NOT NULL,
	[ISO2] [char](2) NULL,
	[CountryName] [varchar](80) NOT NULL,
	[LongCountryName] [varchar](80) NOT NULL,
	[ISO3] [char](3) NULL,
	[NumCode] [varchar](6) NULL,
	[UNMemberState] [varchar](12) NULL,
	[CallingCode] [varchar](8) NULL,
	[CCTLD] [varchar](5) NULL,
	[Enable] [int] NULL,
 CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblDeviceScan]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDeviceScan](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IntSerial] [varchar](12) NULL,
	[ScanDate] [datetimeoffset](7) NULL,
	[ScanData] [varchar](max) NULL,
	[CallHomeRedmptionData] [varchar](max) NULL,
	[ScanSession] [numeric](10, 0) NULL,
	[SequenceMsd] [int] NULL,
	[SequenceLsd] [int] NULL,
 CONSTRAINT [PK_DeviceScan] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblDeviceScanBatch]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDeviceScanBatch](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IntSerial] [varchar](12) NOT NULL,
	[Stamp] [datetimeoffset](7) NOT NULL,
	[Session] [int] NOT NULL,
	[ExternalId] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblDeviceStatus]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDeviceStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IntSerial] [varchar](12) NULL,
	[LogDate] [datetimeoffset](7) NULL,
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
	[ErrorLog] [varchar](max) NULL,
	[WpaPSK] [varchar](64) NULL,
	[SSId] [varchar](32) NULL,
	[CmdURL] [varchar](100) NULL,
	[CmdChkInt] [int] NULL,
	[RevId] [varchar](64) NULL,
 CONSTRAINT [PK_DeviceStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblDynamicCode]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDynamicCode](
	[DynCID] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [varchar](5) NULL,
	[RequestDate] [datetimeoffset](7) NULL,
	[CellPhone] [varchar](64) NULL,
	[CallHomeData] [varchar](64) NULL,
	[CallHomeURL] [varchar](256) NULL,
	[CallHomeTimeoutValue] [int] NULL,
	[RedemptionData] [varchar](63) NULL,
	[MetaData] [varchar](max) NULL,
	[OrgId] [int] NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_DynamicCode] PRIMARY KEY CLUSTERED 
(
	[DynCID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblErrorLog]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblErrorLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RoutineName] [varchar](30) NULL,
	[FieldName] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[ErrorCode] [int] NULL,
	[RoutineID] [varchar](20) NULL,
 CONSTRAINT [PK_tblLog991] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblInterceptor]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblInterceptor](
	[IntId] [int] IDENTITY(1,1) NOT NULL,
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
	[InterceptorType] [int] NOT NULL DEFAULT ((0)),
 CONSTRAINT [PK_Interceptor_2] PRIMARY KEY CLUSTERED 
(
	[IntId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblInterceptorID]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblInterceptorID](
	[IntSerial] [varchar](12) NOT NULL,
	[EmbeddedId] [varchar](10) NULL,
	[Key] [binary](16) NULL,
 CONSTRAINT [PK_Interceptor_1] PRIMARY KEY CLUSTERED 
(
	[IntSerial] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblLocation]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblLocation](
	[LocId] [int] IDENTITY(1,1) NOT NULL,
	[LocDesc] [nvarchar](50) NULL,
	[OrgId] [int] NULL,
	[UnitSuite] [varchar](15) NULL,
	[Street] [nvarchar](200) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [varchar](50) NULL,
	[PostalCode] [varchar](10) NULL,
	[Latitude] [numeric](9, 6) NULL,
	[Longitude] [numeric](9, 6) NULL,
	[LocType] [nvarchar](50) NULL,
	[LocSubType] [nvarchar](50) NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[LocId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblOrganization]    Script Date: 2015-07-17 10:37:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOrganization](
	[OrgId] [int] IDENTITY(1,1) NOT NULL,
	[OrgName] [nvarchar](100) NULL,
	[ApplicationKey] [varchar](40) NULL,
	[IpAddress] [varchar](15) NULL,
	[Owner] [int] NULL,
 CONSTRAINT [PK_ut_Organization] PRIMARY KEY CLUSTERED 
(
	[OrgId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblResourceId]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblResourceId](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ResourceId] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblRole]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRole](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_RoleId] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblScanBatches]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblScanBatches](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IntSerial] [varchar](12) NULL,
	[OrgName] [nvarchar](100) NULL,
	[DeliveryTime] [datetimeoffset](7) NULL,
	[ForwardURL] [varchar](100) NULL,
	[UnitSuite] [varchar](15) NULL,
	[Street] [nvarchar](100) NULL,
	[City] [varchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [varchar](50) NULL,
	[PostalCode] [varchar](10) NULL,
	[LocType] [nvarchar](50) NULL,
	[LocSubType] [nvarchar](50) NULL,
	[IntLocDesc] [varchar](100) NULL,
	[ScanData] [varchar](max) NULL,
	[ScanDate] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ScanBatches] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblSession]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSession](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SessionKey] [varchar](40) NULL,
	[LastActivity] [datetimeoffset](7) NULL,
	[Timeout] [int] NULL,
	[UserId] [varchar](5) NULL,
	[OrgId] [int] NULL,
	[AccessLevel] [int] NULL,
 CONSTRAINT [PK_Session] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblState]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblState](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CountryID] [int] NULL,
	[CountryName] [varchar](80) NULL,
	[StateOrProvince] [varchar](80) NULL,
 CONSTRAINT [PK_tblState] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblSystemEvents]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSystemEvents](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Routine] [varchar](50) NULL,
	[EventType] [int] NULL,
	[EventLevel] [int] NULL,
	[EventData] [varchar](max) NULL,
	[CreatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_SystemEvents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblTempdevicescan]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTempdevicescan](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[a] [varchar](50) NOT NULL,
	[i] [varchar](12) NOT NULL,
	[b] [nvarchar](max) NOT NULL,
	[status] [varchar](5) NULL,
 CONSTRAINT [PK_tblTempdevicescan] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblTempScanBatches]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTempScanBatches](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IntSerial] [varchar](12) NOT NULL,
	[OrgName] [nvarchar](100) NOT NULL,
	[DeliveryTime] [datetimeoffset](7) NULL,
	[ForwardURL] [varchar](100) NULL,
	[UnitSuite] [varchar](15) NULL,
	[Street] [nvarchar](100) NULL,
	[City] [varchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [varchar](50) NULL,
	[PostalCode] [varchar](10) NULL,
	[LocType] [nvarchar](50) NULL,
	[LocSubType] [nvarchar](50) NULL,
	[IntLocDesc] [varchar](100) NULL,
	[ScanData] [varchar](max) NOT NULL,
 CONSTRAINT [PK_tblTempScanBatches] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblUser]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUser](
	[UserId] [varchar](5) NOT NULL,
	[OrgId] [int] NULL,
	[Password] [varchar](40) NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[RegDate] [datetimeoffset](7) NULL,
	[AccessLevel] [int] NULL,
	[Credential] [nvarchar](max) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
/****** Object:  Table [dbo].[tblUserActivity]    Script Date: 2015-07-17 10:37:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserActivity](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [varchar](5) NULL,
	[ActDate] [datetimeoffset](7) NULL,
	[Activity] [int] NULL,
	[Recorded] [varchar](50) NULL,
	[RecordType] [int] NULL,
	[ActivityData] [varchar](max) NULL,
 CONSTRAINT [PK_UserActivity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
ALTER TABLE [dbo].[tblContent]  WITH CHECK ADD  CONSTRAINT [FK_Content_Organization] FOREIGN KEY([OrgId])
REFERENCES [dbo].[tblOrganization] ([OrgId])
GO
ALTER TABLE [dbo].[tblContent] CHECK CONSTRAINT [FK_Content_Organization]
GO
ALTER TABLE [dbo].[tblDeviceScan]  WITH CHECK ADD  CONSTRAINT [FK_DeviceScan_InterceptorID] FOREIGN KEY([IntSerial])
REFERENCES [dbo].[tblInterceptorID] ([IntSerial])
GO
ALTER TABLE [dbo].[tblDeviceScan] CHECK CONSTRAINT [FK_DeviceScan_InterceptorID]
GO
ALTER TABLE [dbo].[tblDeviceStatus]  WITH CHECK ADD  CONSTRAINT [FK_DeviceStatus_InterceptorID] FOREIGN KEY([IntSerial])
REFERENCES [dbo].[tblInterceptorID] ([IntSerial])
GO
ALTER TABLE [dbo].[tblDeviceStatus] CHECK CONSTRAINT [FK_DeviceStatus_InterceptorID]
GO
ALTER TABLE [dbo].[tblDynamicCode]  WITH CHECK ADD  CONSTRAINT [FK_DynamicCode_Org] FOREIGN KEY([OrgId])
REFERENCES [dbo].[tblOrganization] ([OrgId])
GO
ALTER TABLE [dbo].[tblDynamicCode] CHECK CONSTRAINT [FK_DynamicCode_Org]
GO
ALTER TABLE [dbo].[tblDynamicCode]  WITH CHECK ADD  CONSTRAINT [FK_DynamicCode_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[tblUser] ([UserId])
GO
ALTER TABLE [dbo].[tblDynamicCode] CHECK CONSTRAINT [FK_DynamicCode_User]
GO
ALTER TABLE [dbo].[tblInterceptor]  WITH CHECK ADD  CONSTRAINT [FK_Interceptor_InterceptorID] FOREIGN KEY([IntSerial])
REFERENCES [dbo].[tblInterceptorID] ([IntSerial])
GO
ALTER TABLE [dbo].[tblInterceptor] CHECK CONSTRAINT [FK_Interceptor_InterceptorID]
GO
ALTER TABLE [dbo].[tblInterceptor]  WITH CHECK ADD  CONSTRAINT [FK_Interceptor_Location] FOREIGN KEY([LocId])
REFERENCES [dbo].[tblLocation] ([LocId])
GO
ALTER TABLE [dbo].[tblInterceptor] CHECK CONSTRAINT [FK_Interceptor_Location]
GO
ALTER TABLE [dbo].[tblInterceptor]  WITH CHECK ADD  CONSTRAINT [FK_Interceptor_Organization] FOREIGN KEY([OrgId])
REFERENCES [dbo].[tblOrganization] ([OrgId])
GO
ALTER TABLE [dbo].[tblInterceptor] CHECK CONSTRAINT [FK_Interceptor_Organization]
GO
ALTER TABLE [dbo].[tblLocation]  WITH CHECK ADD  CONSTRAINT [FK_Location_Organization] FOREIGN KEY([OrgId])
REFERENCES [dbo].[tblOrganization] ([OrgId])
GO
ALTER TABLE [dbo].[tblLocation] CHECK CONSTRAINT [FK_Location_Organization]
GO
ALTER TABLE [dbo].[tblScanBatches]  WITH CHECK ADD  CONSTRAINT [FK_ScanBatches_InterceptorID] FOREIGN KEY([IntSerial])
REFERENCES [dbo].[tblInterceptorID] ([IntSerial])
GO
ALTER TABLE [dbo].[tblScanBatches] CHECK CONSTRAINT [FK_ScanBatches_InterceptorID]
GO
ALTER TABLE [dbo].[tblSession]  WITH CHECK ADD  CONSTRAINT [FK_Session_Organization] FOREIGN KEY([OrgId])
REFERENCES [dbo].[tblOrganization] ([OrgId])
GO
ALTER TABLE [dbo].[tblSession] CHECK CONSTRAINT [FK_Session_Organization]
GO
ALTER TABLE [dbo].[tblSession]  WITH CHECK ADD  CONSTRAINT [FK_Session_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[tblUser] ([UserId])
GO
ALTER TABLE [dbo].[tblSession] CHECK CONSTRAINT [FK_Session_User]
GO
ALTER TABLE [dbo].[tblUser]  WITH CHECK ADD  CONSTRAINT [FK_User_Organization] FOREIGN KEY([OrgId])
REFERENCES [dbo].[tblOrganization] ([OrgId])
GO
ALTER TABLE [dbo].[tblUser] CHECK CONSTRAINT [FK_User_Organization]
GO
