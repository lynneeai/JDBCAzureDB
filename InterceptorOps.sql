/****** Object:  UserDefinedFunction [dbo].[fn_GetGeoDistance]    Script Date: 2015-07-08 11:47:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Indhumathi T
-- Create date: 22.5.2013
-- Description:	Calculate distance between 2 geographical coordinates
-- =============================================
CREATE FUNCTION [dbo].[fn_GetGeoDistance] 
(
	@refLat		AS NUMERIC(18, 9),
    @refLong	AS NUMERIC(18, 9),
    @tabLat		AS NUMERIC(18, 9),
    @tabLong	AS NUMERIC(18, 9)
)
RETURNS varchar(100)
AS
BEGIN
	--refLat and refLong is the point from which you want to know the places close to.
	--tabLat and tabLong are the retrieved table values (latitude and longitude)
	
	--Local variables description
	--@R is the radius of the earth.
		--@R in Miles 3956.55 
		--@R in Kilometers 6367.45
		--@R in Feet 20890584
		--@R in Meters 6367450
		--@R Default feet (Garmin rel elev) 20890584
	--@ReturnResult used to return results
	
		Declare @R NUMERIC(18, 9)
		Declare @ReturnResult NUMERIC(18, 9)

		SET @R = 6367450;
	  
		SET @ReturnResult = @R *(2 * Asin(Min(Sqrt(Sin((Radians(@tabLat - @refLat)) / 2) 
                 * Sin((Radians(@tabLat - @refLat)) / 2) 
                 + Cos(Radians(@refLat))
                 * Cos(Radians(@tabLat)) 
                 * Sin((Radians(@tabLong - @refLong)) / 2) 
                 * Sin((Radians(@tabLong - @refLong)) / 2)))));     
                 
		RETURN @ReturnResult

END


GO
/****** Object:  UserDefinedFunction [dbo].[FN_IS_DateTimeoffset]    Script Date: 2015-07-08 11:47:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select [dbo].[FN_IS_DateTimeoffset] '2013-05-18T11:30:55.0030000 -02:30'
CREATE FUNCTION [dbo].[FN_IS_DateTimeoffset] (  
 @t Nvarchar(MAX))
RETURNS int
AS 
BEGIN
DECLARE @zone AS varchar(50)
DECLARE @date2 AS varchar(50)
DECLARE @date3 AS varchar(50)
DECLARE @time1 AS varchar(18)
DECLARE @zonehh AS varchar(4)
DECLARE @zonemm AS varchar(4)
DECLARE @time2 AS varchar(30)
DECLARE @time3 AS varchar(12)
DECLARE @result AS int
SET @result=0
IF (CHARINDEX('T',@t) <> 0 AND (CHARINDEX('+',@t) <> 0 OR CHARINDEX('-',@t) <> 0))
BEGIN

   IF(CHARINDEX('+',@t) <> 0)
   BEGIN
	 SET @date2=(SELECT substring(@t,1,CHARINDEX('+',@t)-1))
	 SET @zone=(SELECT substring(@t,CHARINDEX('+',@t)+1,len(@t)))
	 SET @time1=(SELECT substring(@date2,CHARINDEX('T',@date2)+1,len(@date2)))
	 SET @date2=(SELECT substring(@t,1,CHARINDEX('T',@t)-1))
   END
   ELSE IF(CHARINDEX('-',@t) <> 0)
   BEGIN
	SET @date2=(SELECT substring(@t,1,CHARINDEX('T',@t)-1))
	SET @zone=(SELECT substring(@t,CHARINDEX('T',@t)+1,len(@t)))
	SET @time1=(SELECT substring(@zone,1,CHARINDEX('-',@zone)-1))
	SET @zone=(SELECT substring(@zone,CHARINDEX('-',@zone)+1,len(@zone)))
   END
	SET @zonehh=(SELECT substring(@zone,1,CHARINDEX(':',@zone)-1))
	SET @zonemm=(SELECT substring(@zone,CHARINDEX(':',@zone)+1,len(@zone)))	
	IF(ISDATE(@date2) = 1)
	BEGIN
	  SET @time2=replace(replace(@time1,':',''),'.','')
	  IF(isnumeric(@time2)=1)
	  BEGIN
	    SET @time3=(SELECT substring(@time1,1,12))
		SET @date3=@date2+' '+@time3
		IF(ISDATE(@date3) = 1)
		BEGIN
		IF((@zonehh between '00' and '14') AND (@zonemm between '00' and '59')) SET @result= 1
		ELSE SET @result= 0
		END
	  END
	END  	
END		
return @result 
END


GO
/****** Object:  UserDefinedFunction [dbo].[FN_REMOVE_SPECIAL_CHARACTER]    Script Date: 2015-07-08 11:47:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN_REMOVE_SPECIAL_CHARACTER] (  
 @INPUT_STRING Nvarchar(MAX))
RETURNS NVARCHAR(MAX)
AS 
BEGIN
 
--declare @testString varchar(100),
DECLARE @NEWSTRING NVARCHAR(MAX) 
SET @NEWSTRING = @INPUT_STRING ; 
Declare @ReplaceString varchar(max) =left(@NEWSTRING, len(@NEWSTRING)-1)
SET @NEWSTRING=right(@ReplaceString, len(@ReplaceString)-1);
With SPECIAL_CHARACTER as
(
SELECT '{' as item
UNION ALL 
SELECT '}' as item
UNION ALL 
SELECT '"' as item

UNION ALL 
SELECT '(' as item
UNION ALL 
SELECT ')' as item
UNION ALL 
SELECT '!' as item
UNION ALL 
SELECT '?' as item
UNION ALL 
SELECT '@' as item
UNION ALL 
--SELECT '*' as item
--UNION ALL 
SELECT '%' as item
UNION ALL 
SELECT '$' as item
 )
SELECT @NEWSTRING = Replace(@NEWSTRING,ITEM,'') FROM SPECIAL_CHARACTER 
return @NEWSTRING 
END


GO
/****** Object:  UserDefinedFunction [dbo].[fnSplitColoumn]    Script Date: 2015-07-08 11:47:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create function [dbo].[fnSplitColoumn] (@String nvarchar(4000), @Delimiter char(1))  
Returns @Results Table (Timestampdata NVARCHAR(1000),errorcode NVARCHAR(1000),errordata NVARCHAR(1000)
)  
As  
Begin  
Declare @Index int  
Declare @Slice nvarchar(4000)  
Select @Index = 1  
If @String Is NULL Return 

DECLARE @temp Table (id int identity(1,1) , Items nvarchar(4000))  

While @Index != 0  
Begin  
Select @Index = CharIndex(@Delimiter, @String)  
If @Index != 0  
Select @Slice = left(@String, @Index - 1)  
else  
Select @Slice = @String  
Insert into @temp(Items) Values (@Slice)  
Select @String = right(@String, Len(@String) - @Index)  
If Len(@String) = 0 break  
End  
insert into @Results (Timestampdata) select Items from @temp where id =1  
update @Results set errorcode = ( select Items from @temp where id =2  )
  update @Results set errordata = ( select Items from @temp where id =3  )
Return  
End


GO
/****** Object:  UserDefinedFunction [dbo].[Splitrow]    Script Date: 2015-07-08 11:47:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[Splitrow] (@String nvarchar(max), @Delimiter char(1))  
Returns @Results Table (Items nvarchar(max))  
As  
Begin  
Declare @Index int  
Declare @Slice nvarchar(max)  
Select @Index = 1  
If @String Is NULL Return   
While @Index != 0  
Begin  
Select @Index = CharIndex(@Delimiter, @String)  
If @Index != 0  
Select @Slice = left(@String, @Index - 1)  
else  
Select @Slice = @String  
Insert into @Results(Items) Values (@Slice)  
Select @String = right(@String, Len(@String) - @Index)  
If Len(@String) = 0 break  
End  
Return  
End


GO
/****** Object:  UserDefinedFunction [dbo].[TRIM]    Script Date: 2015-07-08 11:47:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TRIM](@String VARCHAR(MAX), @Char varchar(5))
RETURNS VARCHAR(MAX)
BEGIN
RETURN SUBSTRING(@String,PATINDEX('%[^' + @Char + ' ]%',@String)
    ,(DATALENGTH(@String)+2 - (PATINDEX('%[^' + @Char + ' ]%'
    ,REVERSE(@String)) + PATINDEX('%[^' + @Char + ' ]%',@String)
    )))
END


GO
/****** Object:  UserDefinedFunction [dbo].[UDF_ParseAlphaChars]    Script Date: 2015-07-08 11:47:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UDF_ParseAlphaChars]
(
@string VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
DECLARE @IncorrectCharLoc SMALLINT
SET @IncorrectCharLoc = PATINDEX('%[^0-9A-Za-z]%', @string)
WHILE @IncorrectCharLoc > 0
BEGIN
SET @string = STUFF(@string, @IncorrectCharLoc, 1, '')
SET @IncorrectCharLoc = PATINDEX('%[^0-9A-Za-z]%', @string)
END
SET @string = @string
RETURN @string
END


GO
/****** Object:  Table [dbo].[tblAlerts]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblArchivedInterceptor]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblArchivedOrg]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblArchivedUser]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblAuthorization]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblCmdQueue]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblContent]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblCountries]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblDeviceScan]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblDeviceScanBatch]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblDeviceStatus]    Script Date: 2015-07-08 11:47:46 AM ******/
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
/****** Object:  Table [dbo].[tblDynamicCode]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblErrorLog]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblInterceptor]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblInterceptorID]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblLocation]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblOrganization]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblResourceId]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblRole]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblScanBatches]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblSession]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblState]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblSystemEvents]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblTempdevicescan]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblTempScanBatches]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblUser]    Script Date: 2015-07-08 11:47:47 AM ******/
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
/****** Object:  Table [dbo].[tblUserActivity]    Script Date: 2015-07-08 11:47:47 AM ******/
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
SET ANSI_PADDING ON

GO
/****** Object:  Index [AlertsIdIndex]    Script Date: 2015-07-08 11:47:48 AM ******/
CREATE NONCLUSTERED INDEX [AlertsIdIndex] ON [dbo].[tblAlerts]
(
	[AlertId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ContentIndex]    Script Date: 2015-07-08 11:47:48 AM ******/
CREATE NONCLUSTERED INDEX [ContentIndex] ON [dbo].[tblContent]
(
	[Code] ASC,
	[OrgId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DeviceScanIntSerial]    Script Date: 2015-07-08 11:47:48 AM ******/
CREATE NONCLUSTERED INDEX [DeviceScanIntSerial] ON [dbo].[tblDeviceScan]
(
	[IntSerial] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DeviceScanIntSerialSeq]    Script Date: 2015-07-08 11:47:48 AM ******/
CREATE NONCLUSTERED INDEX [DeviceScanIntSerialSeq] ON [dbo].[tblDeviceScan]
(
	[IntSerial] ASC,
	[SequenceMsd] ASC,
	[SequenceLsd] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DeviceStatusIntSerialIndex]    Script Date: 2015-07-08 11:47:48 AM ******/
CREATE NONCLUSTERED INDEX [DeviceStatusIntSerialIndex] ON [dbo].[tblDeviceStatus]
(
	[IntSerial] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Interceptorindex]    Script Date: 2015-07-08 11:47:48 AM ******/
CREATE NONCLUSTERED INDEX [Interceptorindex] ON [dbo].[tblInterceptor]
(
	[IntSerial] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ScanBatchIntSerialIndex]    Script Date: 2015-07-08 11:47:48 AM ******/
CREATE NONCLUSTERED INDEX [ScanBatchIntSerialIndex] ON [dbo].[tblScanBatches]
(
	[IntSerial] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [TempScanBatchIntSerialIndex]    Script Date: 2015-07-08 11:47:48 AM ******/
CREATE NONCLUSTERED INDEX [TempScanBatchIntSerialIndex] ON [dbo].[tblTempScanBatches]
(
	[IntSerial] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
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
/****** Object:  StoredProcedure [dbo].[sp_MSforeach_worker]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
 * This is the worker proc for all of the "for each" type procs.  Its function is to read the
 * next replacement name from the cursor (which returns only a single name), plug it into the
 * replacement locations for the commands, and execute them.  It assumes the cursor "hCForEach***"
 * has already been opened by its caller.
 * worker_type is a parameter that indicates whether we call this for a database (1) or for a table (0)
 */
create proc [dbo].[sp_MSforeach_worker]
	@command1 nvarchar(2000), @replacechar nchar(1) = N'?', @command2 nvarchar(2000) = null, @command3 nvarchar(2000) = null, @worker_type int =1
as

	create table #qtemp (	/* Temp command storage */
		qnum				int				NOT NULL,
		qchar				nvarchar(2000)	COLLATE database_default NULL
	)

	set nocount on
	declare @name nvarchar(517), @namelen int, @q1 nvarchar(2000), @q2 nvarchar(2000)
   declare @q3 nvarchar(2000), @q4 nvarchar(2000), @q5 nvarchar(2000)
	declare @q6 nvarchar(2000), @q7 nvarchar(2000), @q8 nvarchar(2000), @q9 nvarchar(2000), @q10 nvarchar(2000)
	declare @cmd nvarchar(2000), @replacecharindex int, @useq tinyint, @usecmd tinyint, @nextcmd nvarchar(2000)
   declare @namesave nvarchar(517), @nametmp nvarchar(517), @nametmp2 nvarchar(258)

	declare @local_cursor cursor
	if @worker_type=1	
		set @local_cursor = hCForEachDatabase
	else
		set @local_cursor = hCForEachTable
	
	open @local_cursor
	fetch @local_cursor into @name

	/* Loop for each database */
	while (@@fetch_status >= 0) begin
		/* Initialize. */

      /* save the original dbname */
      select @namesave = @name
		select @useq = 1, @usecmd = 1, @cmd = @command1, @namelen = datalength(@name)
		while (@cmd is not null) begin		/* Generate @q* for exec() */
			/*
			 * Parse each @commandX into a single executable batch.
			 * Because the expanded form of a @commandX may be > OSQL_MAXCOLLEN_SET, we'll need to allow overflow.
			 * We also may append @commandX's (signified by '++' as first letters of next @command).
			 */
			select @replacecharindex = charindex(@replacechar, @cmd)
			while (@replacecharindex <> 0) begin

            /* 7.0, if name contains ' character, and the name has been single quoted in command, double all of them in dbname */
            /* if the name has not been single quoted in command, do not doulbe them */
            /* if name contains ] character, and the name has been [] quoted in command, double all of ] in dbname */
            select @name = @namesave
            select @namelen = datalength(@name)
            declare @tempindex int
            if (substring(@cmd, @replacecharindex - 1, 1) = N'''') begin
               /* if ? is inside of '', we need to double all the ' in name */
               select @name = REPLACE(@name, N'''', N'''''')
            end else if (substring(@cmd, @replacecharindex - 1, 1) = N'[') begin
               /* if ? is inside of [], we need to double all the ] in name */
               select @name = REPLACE(@name, N']', N']]')
            end else if ((@name LIKE N'%].%]') and (substring(@name, 1, 1) = N'[')) begin
               /* ? is NOT inside of [] nor '', and the name is in [owner].[name] format, handle it */
               /* !!! work around, when using LIKE to find string pattern, can't use '[', since LIKE operator is treating '[' as a wide char */
               select @tempindex = charindex(N'].[', @name)
               select @nametmp  = substring(@name, 2, @tempindex-2 )
               select @nametmp2 = substring(@name, @tempindex+3, len(@name)-@tempindex-3 )
               select @nametmp  = REPLACE(@nametmp, N']', N']]')
               select @nametmp2 = REPLACE(@nametmp2, N']', N']]')
               select @name = N'[' + @nametmp + N'].[' + @nametmp2 + ']'
            end else if ((@name LIKE N'%]') and (substring(@name, 1, 1) = N'[')) begin
               /* ? is NOT inside of [] nor '', and the name is in [name] format, handle it */
               /* j.i.c., since we should not fall into this case */
               /* !!! work around, when using LIKE to find string pattern, can't use '[', since LIKE operator is treating '[' as a wide char */
               select @nametmp = substring(@name, 2, len(@name)-2 )
               select @nametmp = REPLACE(@nametmp, N']', N']]')
               select @name = N'[' + @nametmp + N']'
            end
            /* Get the new length */
            select @namelen = datalength(@name)

            /* start normal process */
				if (datalength(@cmd) + @namelen - 1 > 2000) begin
					/* Overflow; put preceding stuff into the temp table */
					if (@useq > 9) begin
						close @local_cursor
						if @worker_type=1	
							deallocate hCForEachDatabase
						else
							deallocate hCForEachTable
							
						--raiserror 55555 N'sp_MSforeach_worker assert failed:  command too long'
						return 1
					end
					if (@replacecharindex < @namelen) begin
						/* If this happened close to beginning, make sure expansion has enough room. */
						/* In this case no trailing space can occur as the row ends with @name. */
						select @nextcmd = substring(@cmd, 1, @replacecharindex)
						select @cmd = substring(@cmd, @replacecharindex + 1, 2000)
						select @nextcmd = stuff(@nextcmd, @replacecharindex, 1, @name)
						select @replacecharindex = charindex(@replacechar, @cmd)
						insert #qtemp values (@useq, @nextcmd)
						select @useq = @useq + 1
						continue
					end
					/* Move the string down and stuff() in-place. */
					/* Because varchar columns trim trailing spaces, we may need to prepend one to the following string. */
					/* In this case, the char to be replaced is moved over by one. */
					insert #qtemp values (@useq, substring(@cmd, 1, @replacecharindex - 1))
					if (substring(@cmd, @replacecharindex - 1, 1) = N' ') begin
						select @cmd = N' ' + substring(@cmd, @replacecharindex, 2000)
						select @replacecharindex = 2
					end else begin
						select @cmd = substring(@cmd, @replacecharindex, 2000)
						select @replacecharindex = 1
					end
					select @useq = @useq + 1
				end
				select @cmd = stuff(@cmd, @replacecharindex, 1, @name)
				select @replacecharindex = charindex(@replacechar, @cmd)
			end

			/* Done replacing for current @cmd.  Get the next one and see if it's to be appended. */
			select @usecmd = @usecmd + 1
			select @nextcmd = case (@usecmd) when 2 then @command2 when 3 then @command3 else null end
			if (@nextcmd is not null and substring(@nextcmd, 1, 2) = N'++') begin
				insert #qtemp values (@useq, @cmd)
				select @cmd = substring(@nextcmd, 3, 2000), @useq = @useq + 1
				continue
			end

			/* Now exec() the generated @q*, and see if we had more commands to exec().  Continue even if errors. */
			/* Null them first as the no-result-set case won't. */
			select @q1 = null, @q2 = null, @q3 = null, @q4 = null, @q5 = null, @q6 = null, @q7 = null, @q8 = null, @q9 = null, @q10 = null
			select @q1 = qchar from #qtemp where qnum = 1
			select @q2 = qchar from #qtemp where qnum = 2
			select @q3 = qchar from #qtemp where qnum = 3
			select @q4 = qchar from #qtemp where qnum = 4
			select @q5 = qchar from #qtemp where qnum = 5
			select @q6 = qchar from #qtemp where qnum = 6
			select @q7 = qchar from #qtemp where qnum = 7
			select @q8 = qchar from #qtemp where qnum = 8
			select @q9 = qchar from #qtemp where qnum = 9
			select @q10 = qchar from #qtemp where qnum = 10
			truncate table #qtemp
			exec (@q1 + @q2 + @q3 + @q4 + @q5 + @q6 + @q7 + @q8 + @q9 + @q10 + @cmd)
			select @cmd = @nextcmd, @useq = 1
		end /* while @cmd is not null, generating @q* for exec() */

		/* All commands done for this name.  Go to next one. */
		fetch @local_cursor into @name
	end /* while FETCH_SUCCESS */
	close @local_cursor
	if @worker_type=1	
		deallocate hCForEachDatabase
	else
		deallocate hCForEachTable
		
	return 0


GO
/****** Object:  StoredProcedure [dbo].[sp_MSforeachtable]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE proc [dbo].[sp_MSforeachtable]
	@command1 nvarchar(2000), @replacechar nchar(1) = N'?', @command2 nvarchar(2000) = null,
   @command3 nvarchar(2000) = null, @whereand nvarchar(2000) = null,
	@precommand nvarchar(2000) = null, @postcommand nvarchar(2000) = null
as
	/* This proc returns one or more rows for each table (optionally, matching @where), with each table defaulting to its own result set */
	/* @precommand and @postcommand may be used to force a single result set via a temp table. */

	/* Preprocessor won't replace within quotes so have to use str(). */
	declare @mscat nvarchar(12)
	select @mscat = ltrim(str(convert(int, 0x0002)))

	if (@precommand is not null)
		exec(@precommand)

	/* Create the select */
   exec(N'declare hCForEachTable cursor global for select ''['' + REPLACE(schema_name(syso.schema_id), N'']'', N'']]'') + '']'' + ''.'' + ''['' + REPLACE(object_name(o.id), N'']'', N'']]'') + '']'' from dbo.sysobjects o join sys.all_objects syso on o.id = syso.object_id '
         + N' where OBJECTPROPERTY(o.id, N''IsUserTable'') = 1 ' + N' and o.category & ' + @mscat + N' = 0 '
         + @whereand)
	declare @retval int
	select @retval = @@error
	if (@retval = 0)
		exec @retval = dbo.sp_MSforeach_worker @command1, @replacechar, @command2, @command3, 0

	if (@retval = 0 and @postcommand is not null)
		exec(@postcommand)

	return @retval

GO
/****** Object:  StoredProcedure [dbo].[up_Authentication]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ganesh
-- Create date: 05.6.2013
-- Routine:		Common Store Procedure
-- =============================================
CREATE PROCEDURE [dbo].[up_Authentication] 
	
	@URLapplicationKey	AS VARCHAR(41),
	@sessionKey			AS VARCHAR(41)

AS
BEGIN
	--[up_Authentication] '4A79DB236006635250C7470729F1BFA30DE691D7','FA336C57D07DEC77953F6D6E79B8BED3363B18E4'
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
	SET NOCOUNT ON;
	DECLARE @ReturnResult AS VARCHAR(MAX)
	DECLARE @IsExist AS INT
	IF(@URLapplicationKey = '' OR @URLapplicationKey IS NULL)
		BEGIN
			SET	@ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
				--if applicationKey = “public” get matching record FROM dbo.tblOrganization 
				--(0 – not used - IP address not valid
				--(1 – debug/info - IP Address Update
				--(2 – warning - UnAuthorized
				--(3 – critical) - Bad Request
			EXEC upi_SystemEvents 'Authenticate',1013,3,@URLapplicationKey
		END	
	ELSE IF(@sessionKey = '' OR @sessionKey IS NULL)
		BEGIN
			SET	@ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
			EXEC upi_SystemEvents 'Authenticate',1013,3,@sessionKey
		END
	ELSE 
		BEGIN
			SET @IsExist = (SELECT COUNT(*) FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)			
			IF(@IsExist = 0)
				BEGIN
					SET	@ReturnResult = '400' SELECT @ReturnResult AS Returnvalue1					
					EXEC upi_SystemEvents 'Authenticate',1014,3,@sessionKey
				END
			ELSE IF(@IsExist > 0)
				BEGIN
						DECLARE @IsSessionExpired as datetimeoffset(7)
						SET @IsSessionExpired = (SELECT DATEADD(MINUTE,([timeout]/60),[lastActivity]) FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)						
						IF(SYSDATETIMEOFFSET() > @IsSessionExpired)
						BEGIN
							DELETE FROM dbo.[tblSession] WHERE sessionKey = @sessionKey
							SET	@ReturnResult = '408' SELECT @ReturnResult	AS Returnvalue	
							EXEC upi_SystemEvents 'Authenticate',1015,3,@sessionKey					
						END
						ELSE
						BEGIN
							DECLARE @IsOrgExist AS INT
							SET @IsOrgExist = (SELECT COUNT(*) FROM dbo.tblOrganization WHERE applicationKey = @URLapplicationKey)
							IF(@IsOrgExist = 0)
								BEGIN
									SET	@ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
									EXEC upi_SystemEvents 'Authenticate',1016,3,@URLapplicationKey	
								END
							ELSE IF(@IsOrgExist > 0)
								BEGIN							
									SET	@ReturnResult = 'OK' SELECT @ReturnResult AS Returnvalue
								END
						END
				END
		END
END
--[up_Authentication] '4A79DB236006635250C7470729F1BFA30DE691D7','t234567891234567891234567891234567891234'


GO
/****** Object:  StoredProcedure [dbo].[up_CheckAndDeleteExpiredSessionKey]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[up_CheckAndDeleteExpiredSessionKey]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Delete FROM dbo.[tblSession] where SYSDATETIMEOFFSET() > DATEADD(minute,60,DATEADD(minute,[timeout]/60, lastActivity))

	--Create table #temptable(id int,value int)
	--insert into #temptable select id,DateDiff(minute,DATEADD(minute,60,DATEADD(minute,[timeout]/60, lastActivity)),SYSDATETIMEOFFSET()) As Value  from tblsession
	--delete from tblsession where id in(select id from #temptable where value > 0)	
	Return		
	
END


--exec [up_CheckAndDeleteExpiredSessionKey]



GO
/****** Object:  StoredProcedure [dbo].[up_CheckAndGetApplicationKey]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		IHorse
-- Create date: 20-08-2013
-- Description:	Used to retrieve the applicationKey based on the UserId
-- ==================================================================
--up_CheckAndGetApplicationKey '001RW'
CREATE PROCEDURE [dbo].[up_CheckAndGetApplicationKey]
	@userId as VARCHAR(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Isexist AS INT
	DECLARE @applicationKey AS VARCHAR(40)
	
	SET @Isexist = (SELECT COUNT(*) FROM dbo.tblUSER WHERE UserId = @userId)
    IF(@Isexist = 0)
    BEGIN
		SET @applicationKey = '400' SELECT @applicationKey
    END
    ELSE IF (@Isexist = 1)
    BEGIN
		SET @applicationKey = (SELECT tblOrganization.ApplicationKey
		FROM  tblOrganization INNER JOIN tblUser ON tblOrganization.OrgId = tblUser.OrgId
		WHERE (tblUser.UserId = @userId)) SELECT @applicationKey
    END
END


GO
/****** Object:  StoredProcedure [dbo].[up_CheckOldPasswordAndReset]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[up_CheckOldPasswordAndReset]
	
	@OldPassword	AS VARCHAR(40),
	@NewPassword	AS VARCHAR(40),
	@SessionKey		AS VARCHAR(40) 
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @IsExist	AS INT
	DECLARE @Oldpwd		AS VARCHAR(40)
	DECLARE @Newpwd		AS VARCHAR(40)
	
	/* Summary: Convert the old password to MD5 format for Confirming */
	SET @Oldpwd = CONVERT(VARCHAR(40),HashBytes('SHA1',@OldPassword),2); 
		
	/* Summary: It will check for old password and session[userId] is Match*/
	SET	@IsExist = (SELECT COUNT(*) FROM dbo.tblUser WHERE [Password] = @Oldpwd AND UserId = (SELECT userId FROM dbo.tblSession WHERE SessionKey = @SessionKey))	
	IF(@IsExist = 1)
	/* Summary: If match, it returns 1 (It states that new password updated successfully)*/
	BEGIN
		/* Summary: Convert the New password to MD5 format for Updating*/
		SET @Newpwd = CONVERT(VARCHAR(40),HashBytes('SHA1',@NewPassword),2); 
		UPDATE [tblUser] SET [Password] = @Newpwd WHERE userId = (SELECT userId FROM dbo.tblSession WHERE SessionKey = @SessionKey)
		SELECT @IsExist
	END
	ELSE IF(@IsExist = 0) 
	/* Summary: If no match, it returns 0 (It states that old password not matched)*/
	BEGIN
		SELECT @IsExist
	END	
END
--up_CheckOldPasswordAndReset 'NewPassword',password,'52041F81675FDC027B9E55466AAE940D'


GO
/****** Object:  StoredProcedure [dbo].[up_CheckSessionKeyTimeOut]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<iHORSE>
-- Create date: <11-09-2013>
-- Description:	<Used to check the session Key timeout of an particular userId before proceeding to delete>
-- =============================================
--up_CheckSessionKeyTimeOut '001RW'
CREATE PROCEDURE [dbo].[up_CheckSessionKeyTimeOut] 
	@UserId AS VARCHAR(5)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;		
	
		DECLARE @ReturnResult AS INT
		
		DELETE FROM dbo.[tblSession] WHERE UserId = @UserId AND (SYSDATETIMEOFFSET() > (SELECT DATEADD(MINUTE,([timeout]/60),[lastActivity])))
		SET	@ReturnResult = @@ROWCOUNT 
		IF(@ReturnResult <> 0)
		BEGIN
			IF EXISTS (SELECT 1 FROM TBLSESSION WHERE UserId = @UserId)
			BEGIN
				SELECT '400|1260 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1260)
				--'400|1857 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1857)+CONVERT(VARCHAR,@intId)
			END
			ELSE 
			BEGIN
				SELECT '200'
			END 
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM TBLSESSION WHERE UserId = @UserId)
		BEGIN			
			SELECT '200'
		END
		ELSE
		BEGIN
			SELECT '400|1260 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1260)
		END
END


GO
/****** Object:  StoredProcedure [dbo].[up_CmdQueue]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prakash G
-- Create date: 18.09.2013
-- Routine:		InterceptorCmdQueue
-- Method:		GET
-- Description:	Retrieve Status
-- =============================================
CREATE PROCEDURE [dbo].[up_CmdQueue]

	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgId				AS INT,	
	@locId				AS INT,	
	@intID				AS INT,	
	@intSerial			AS VARCHAR(12)
	
	AS
	BEGIN
	SET NOCOUNT ON;
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @accessLevel used to store AccessLevel value
	
	DECLARE @ReturnResult	AS VARCHAR(100)
	DECLARE @accessLevel	AS INT

	--SET @date			= SYSDATETIMEOFFSET();
	--SET @UserId			= (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	
	IF(ISNULL(@orgId,0)=0)SET @orgId = 0
	IF(ISNULL(@locId,0)=0)SET @locId = 0
	IF(ISNULL(@intID,0)=0)SET @intID = 0
	IF(ISNULL(@intSerial,'')='')SET @intSerial = ''
 
		/* Summary: Check whether locid,intID,intSerail are passed or not */
		IF(@locId=0 AND @intID = 0 AND @intSerial='')  
		BEGIN
				/* Summary: Check whether orgId = -1. If it is true select all Interceptor record from Interceptor table */
				IF(@orgId = -1)
				BEGIN
					IF(@accessLevel = 1 or @accessLevel = 2)
					BEGIN
						
						SELECT '<list>'+ (SELECT ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
						CASE ISNULL(Cmd,'') WHEN '1' THEN 'Reboot' WHEN '2' THEN 'Update' WHEN '3' THEN 'Status' ELSE 'NULL' END AS 'Cmd'
						FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial
						JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
						JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
						LEFT OUTER JOIN tblCmdQueue C ON C.intSerial=t.intSerial
						FOR XML RAW )+'</list>'	
						RETURN;
					END
				END
				/* Summary: Check whether orgId is passed or not */
				IF(@orgId <> 0)
			  	BEGIN
			  	/* Summary:If orgId passed use it to get Organization record */
			  	  IF EXISTS(SELECT 1 FROM dbo.[tblorganization] WITH (NOLOCK) WHERE orgid=@orgId )
					BEGIN
					/* Summary: use the orgId to find matching Interceptor records */
					   IF EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WITH (NOLOCK) WHERE orgid=@orgId )
							BEGIN
								/*Summary:Check if the user is authorized to make this request. */
						       	IF(@accessLevel = 1 OR @accessLevel = 2  OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))) OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))))
									BEGIN
										SELECT '<list>'+ (SELECT ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
										CASE ISNULL(Cmd,'') WHEN '1' THEN 'Reboot' WHEN '2' THEN 'Update' WHEN '3' THEN 'Status' ELSE 'NULL' END AS 'Cmd' 
										FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial 
										JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId 	
										JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
										LEFT OUTER JOIN tblCmdQueue C ON C.intSerial=t.intSerial WHERE t.orgid=@orgid FOR XML RAW )+'</list>'		
										RETURN;
									 END
								ELSE
								/* Summary:Raise an Error Message. If user is not within scope*/	
									BEGIN
										SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
										RETURN;
									END
							  END
							  /* Summary:Raise an Error Message, If Interceptor record is not found for the given orgdid in the Interceptor table */
							 ELSE
						     BEGIN
								 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
								 RETURN;
							END	
						END 
						/* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */	
						ELSE
						BEGIN
						    SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
							RETURN;
						END
					END
					 /* Summary:Raise an Error Message.If none of field Passed */
					ELSE
					BEGIN 
					      SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
						  RETURN;
				    END
		END
		/* Summary:If locId is passed, search for the Location record */
		ELSE IF(@orgId = 0 AND  @intID= 0 AND @intSerial ='' )
		BEGIN
			IF(@locId <> 0)
				BEGIN
					/* Summary:if locid  use it to get all matching Location records */
					IF EXISTS(SELECT 1 FROM dbo.[tblLocation] WITH (NOLOCK) WHERE locId = @locId )
			    	BEGIN
						/* Summary:if locid  use it to get all matching Interceptor records*/
						IF EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WITH (NOLOCK) WHERE locId=@locId )
						BEGIN
								/* Summary :Check if the user is authorized to make this request.
								Summary :If the accessLevel is SysAdminRW, then the following fields are returned */
								IF(@accessLevel = 1 OR @accessLevel = 2 )
								BEGIN
									SELECT '<list>'+ (SELECT ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
									CASE ISNULL(Cmd,'') WHEN '1' THEN 'Reboot' WHEN '2' THEN 'Update' WHEN '3' THEN 'Status' ELSE 'NULL' END AS 'Cmd'
									FROM dbo.tblinterceptor t 
									INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial 
									JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
									JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
									LEFT OUTER JOIN tblCmdQueue C ON C.intSerial=t.intSerial
									WHERE t.locId=@locId FOR XML RAW )+'</list>'			
								 	RETURN;
								END
						    ELSE
						    /* Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of Location[OrgId] then the following fields are returned */
							IF((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid =@locId  and s.sessionkey=@sessionKey))) 
							BEGIN
																
								SELECT '<list>'+ (SELECT ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
								CASE ISNULL(Cmd,'') WHEN '1' THEN 'Reboot' WHEN '2' THEN 'Update' WHEN '3' THEN 'Status' ELSE 'NULL' END AS 'Cmd' 
								FROM dbo.tblinterceptor t 
								JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
								JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
								INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial 
								LEFT OUTER JOIN tblCmdQueue C ON C.intSerial=t.intSerial
								WHERE t.locId=@locId 
								and t.Orgid=(SELECT TOP 1 O.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid =@locId  and s.sessionkey=@sessionKey) FOR XML RAW )+'</list>'	
								RETURN;
							END
							/* Summary: If accessLevel is OrgAdminRW or OrgUserRW, then check if Session[OrgId] is the same asLocation[OrgId] then the following fields are returned */
							ELSE IF((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND( EXISTS(SELECT l.orgId FROM dbo.[tblLocation] l INNER JOIN [tblSession] S on l.orgId =S.orgID INNER JOIN [tblOrganization] O ON l.orgId=O.orgId  WHERE S.sessionKey = @sessionKey and l.LocId=@LocId)))
							BEGIN
							     								
								 SELECT '<list>'+ (SELECT ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
								 CASE ISNULL(Cmd,'') WHEN '1' THEN 'Reboot' WHEN '2' THEN 'Update' WHEN '3' THEN 'Status' ELSE 'NULL' END AS 'Cmd' 
								 FROM dbo.tblinterceptor t
								 JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
								 JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
								 INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial 
								 LEFT OUTER JOIN tblCmdQueue C ON C.intSerial=t.intSerial
								 WHERE t.locId=@locId and t.Orgid=(SELECT l.orgId FROM dbo.[tblLocation] l INNER JOIN [tblSession] S on l.orgId =S.orgID INNER JOIN [tblOrganization] O ON l.orgId=O.orgId  WHERE S.sessionKey = @sessionKey and l.LocId=@LocId) FOR XML RAW )+'</list>'	
								 RETURN;
							
							END
							/* Summary:Raise an Error Message. If user is not within scope*/	
							ELSE
						    BEGIN
								 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
								 RETURN;
							END	
					END 
					
					/* Summary:Raise an Error Message, If Interceptor record is not found for the given Locid in the Interceptor table */
					ELSE
					BEGIN
						 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
						 RETURN;
					END
					END	
			    	/* Summary: Raise an error message (400). If Location record is not found for the given Locid in the Location table. */	   
					ELSE
					BEGIN
				         SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
						 RETURN;
					END	
				END	
				/* Summary:Raise an Error Message.If none of field Passed */
				ELSE
				BEGIN
					 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
					 RETURN;
				END	
			END 
			/* Summary:if intID,intSerial  passed, search for the particular Interceptor record only */
			ELSE IF(@locId=0 AND @orgId = 0 )
			BEGIN
				IF(@intID <> 0 AND @intSerial <>'') 
				BEGIN	
					 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
					 RETURN;
				END
				ELSE
				IF(@intID <> 0 AND @intSerial='') 
				BEGIN
				/* Summary:if intID  use it to get  matching Interceptor record */
				IF (EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WITH (NOLOCK) WHERE intID=@intID))
		        BEGIN
		        /*Summary:If a matching Interceptorrecord  is found, use Interceptor[orgID] to check scope of user*/
		        /*Summary :If the accessLevel is SysAdminRW, then the following fields are returned*/
					IF(@accessLevel = 1 OR (@accessLevel = 2 ) OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId INNER JOIN tblinterceptor AS t  ON t.orgid=O.OrgId WHERE  s.sessionkey=@sessionKey AND t.intID=@intID  ))) OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT t.orgId FROM dbo.[tblinterceptor] t INNER JOIN [tblSession] S on t.orgId = S.orgID WHERE S.sessionKey = @sessionKey AND t.intID=@intID  ))))
					BEGIN
						SELECT '<list>'+ (SELECT ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
						CASE ISNULL(Cmd,'') WHEN '1' THEN 'Reboot' WHEN '2' THEN 'Update' WHEN '3' THEN 'Status' ELSE 'NULL' END AS 'Cmd'  
						FROM dbo.tblinterceptor t 
						JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
						JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
						INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial
						LEFT OUTER JOIN tblCmdQueue C ON C.intSerial=t.intSerial
						WHERE t.intID=@intID  FOR XML RAW )+'</list>'		
						RETURN;
					END
					/* Summary:Raise an Error Message. If user is not within scope*/	 
					ELSE
					BEGIN
						 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
						 RETURN;
					END	
		      	END
		      		/* Summary:Raise an Error Message, If Interceptor record is not found for the given Intid in the Interceptor table */
		      	ELSE
				BEGIN
					 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
					 RETURN;
				END
			END	  
			ELSE
		       IF(@intSerial<>'' AND @intID = 0)
		        BEGIN
				/* Summary:if intSerial  use it to get  matching Interceptor record */
		        IF (EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WITH (NOLOCK) WHERE intSerial=@intSerial))
		        BEGIN
					/* Summary:If a matching Interceptorrecord  is found, use Interceptor[orgID] to check scope of user */
					/* Summary :If the accessLevel is SysAdminRW, then the following fields are returned */
					IF(@accessLevel = 1 OR @accessLevel = 2  OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId INNER JOIN tblinterceptor AS t  ON t.orgid=O.OrgId WHERE  s.sessionkey=@sessionKey AND t.intSerial=@intSerial ))) OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT t.orgId FROM dbo.[tblinterceptor] t INNER JOIN [tblSession] S on t.orgId = S.orgID  WHERE S.sessionKey = @sessionKey AND  t.intSerial=@intSerial ))))
					BEGIN
							SELECT '<list>'+ (SELECT ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
							CASE ISNULL(Cmd,'') WHEN '1' THEN 'Reboot' WHEN '2' THEN 'Update' WHEN '3' THEN 'Status' ELSE 'NULL' END AS 'Cmd' 
							FROM dbo.tblinterceptor t  JOIN dbo.tblOrganization O on t.OrgId=O.OrgId
							JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId 
							INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial
							LEFT OUTER JOIN tblCmdQueue C ON C.intSerial=t.intSerial
							WHERE t.intSerial=@intSerial FOR XML RAW  )+'</list>'		
							RETURN;
						END
						/* Summary:Raise an Error Message. If user is not within scope*/	
						ELSE
						BEGIN
							 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
							 RETURN;
						END	
		           		END
		           		/* Summary:Raise an Error Message, If Interceptor record is not found for the given Intserial in the Interceptor table */
						ELSE
						BEGIN
							 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
							 RETURN;
						END
				END
				/* Summary:Raise an Error Message.If none of field Passed */
		        ELSE
				BEGIN
					 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
					 RETURN;
				END
		END 
		/* Summary:Raise an Error Message.If more than one of orgId, locId, intId or intSerial are passed */
		ELSE
		BEGIN
			 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','0' AS 'Cmd' FOR XML RAW )+'</list>'
			 RETURN;
		END
	END
--exec up_CmdQueue '4A79DB236006635250C7470729F1BFA30DE691D7','6B05DB6DC930458646C3F560481C38E61E233D47',-1,0,0,''



GO
/****** Object:  StoredProcedure [dbo].[up_cmdURL]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_cmdURL] 
	@intid	AS INT
AS
BEGIN
	SET NOCOUNT ON;
	IF(EXISTS(SELECT INTID FROM dbo.tblinterceptor WHERE intid=@intid))
	BEGIN
		SELECT ISNULL(CmdURL,'null') AS 'CmdURL' FROM dbo.tblinterceptor WHERE intid=@intid
	END
	ELSE
	SELECT '400' 
END


GO
/****** Object:  StoredProcedure [dbo].[up_GetArchivedUserDetailsByOrgID]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================
-- Author:		iHorse
-- Create date: 10.06.2013
-- Routine:		User
-- Method:		Get
-- Description:	Returns one or more User records based on Access level and Organization Id
-- =======================================================================================
CREATE PROCEDURE [dbo].[up_GetArchivedUserDetailsByOrgID] 

	@sessionKey		AS VARCHAR(40),
	@orgId			AS INT
		
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @accessLevel AS INT
	DECLARE @IsSessionExist AS INT 
	
	SET @IsSessionExist = (SELECT COUNT(*) FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	SET @accessLevel = (SELECT accessLevel FROM dbo.[tblSession] where @sessionKey = sessionKey)
	
	IF(@IsSessionExist = 0)
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate','0' AS 'AccessLevel', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
	END
	ELSE IF(@IsSessionExist <> 0)
	BEGIN
	IF(@accessLevel = 1 OR @accessLevel = 2 OR @accessLevel = 5 OR @accessLevel = 6)
	BEGIN
		IF(@orgId = 0)
		BEGIN
			SELECT '<list>'+(
				SELECT U.UserId  AS 'UserId', U.FirstName AS 'FirstName', U.LastName  AS 'LastName', U.RegDate AS 'RegDate',U.AccessLevel AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.tblArchivedUser U 
				FOR XML RAW )+'</list>'
		END
		ELSE IF(@orgId <> 0)
		BEGIN
			IF EXISTS(SELECT 1 FROM dbo.tblArchivedUser WHERE OrgId=@orgId)
			BEGIN
				SELECT '<list>'+(
					SELECT U.UserId  AS 'UserId', U.FirstName AS 'FirstName', U.LastName  AS 'LastName', U.RegDate AS 'RegDate',U.AccessLevel AS 'AccessLevel', '0' AS 'ErrId'
					FROM dbo.tblArchivedUser U WHERE U.OrgId = @orgId 
					FOR XML RAW )+'</list>'	
			END
			ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate','0' AS 'AccessLevel', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				END
		END
	END
	ELSE
	BEGIN
		IF(@accessLevel = 3 OR @accessLevel = 4)
		BEGIN
			IF(@orgId = 0)
			BEGIN
				SELECT '<list>'+(
				SELECT U.UserId  AS 'UserId', U.FirstName AS 'FirstName', U.LastName  AS 'LastName', U.RegDate AS 'RegDate',U.AccessLevel AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.tblArchivedUser U
				FOR XML RAW )+'</list>'
			END
			ELSE	
			IF(EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId WHERE S.SessionKey = @sessionKey ))
			BEGIN
				IF(@orgId <> 0)
					BEGIN
						SELECT '<list>'+(
						SELECT U.UserId  AS 'UserId', U.FirstName AS 'FirstName', U.LastName  AS 'LastName', U.RegDate AS 'RegDate',U.AccessLevel AS 'AccessLevel', '0' AS 'ErrId'
						FROM dbo.tblArchivedUser U WHERE U.OrgId = @orgId 
						FOR XML RAW )+'</list>'
					END
			END
		END
	END
	END
       
END
--[up_GetArchivedUserDetailsByOrgID] '581920EEBD73CBA7A59FEA18D106315E',1


GO
/****** Object:  StoredProcedure [dbo].[up_GetCountryNames]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		iHorse
-- Create date: 04.07.2013
-- Routine:		All
-- Method:		Get
-- Description:	Return all country names
-- =============================================
CREATE PROCEDURE [dbo].[up_GetCountryNames] 

AS
BEGIN
	SET NOCOUNT ON;
	
		SELECT '<list>'+(SELECT CountryID as 'countryId', CountryName as 'countryName'
		FROM dbo.tblCountries WHERE [Enable]=1  FOR XML RAW )+'</list>'
		
END
--[up_GetCountryNames]


GO
/****** Object:  StoredProcedure [dbo].[up_GetInterceptorDetails]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		iHorse
-- Create date: 4.07.2013
-- Routine:		InterceptorDetails
-- Method:		Get
-- Description:	Returns one or more Interceptor 
-- records based on Access level and Organization Id and Location ID
-- ==================================================================
CREATE PROCEDURE [dbo].[up_GetInterceptorDetails] 

	@sessionKey		AS VARCHAR(40),
	@orgId			AS INT,
	@locId			AS INT,
	@routine        AS INT
		
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @accessLevel		AS INT
	DECLARE @IsSessionExist		AS INT 
	Declare @scanData			AS VARCHAR(MAX)
	DECLARE @intserial			AS VARCHAR(20)
	DECLARE @timestamp			AS DATETIMEOFFSET(7)
	DECLARE @Key				AS VARCHAR(12)
	DECLARE @IntOrgId			AS INT
	DECLARE @COUNT_SERIAL		AS INT
	
	SET @COUNT_SERIAL = 1
	
	CREATE TABLE #DeviceScan ([IntSerial] [VARCHAR](12) NULL, [ScanData] [VARCHAR](MAX) NULL,[ScanTimestamp] [VARCHAR](MAX) NULL, id int IDENTITY(1,1) NOT NULL)
	CREATE table #table1([IntSerial] [VARCHAR](12) NULL)
	CREATE table #table2([IntId] [VARCHAR](12) NULL,[IntSerial] [VARCHAR](12) NULL,[OrgId] int,[ErrId] int)
	
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] where @sessionKey = sessionKey)
	SET @IsSessionExist = (SELECT COUNT(*) FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	
	IF(@IsSessionExist = 0)
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
		RETURN;
	END
	ELSE IF(@IsSessionExist <> 0)
		BEGIN
		  IF(@routine = 3)
		  BEGIN
		    IF(ISNULL(@orgId,'')='' AND ISNULL(@locId,'')=''  )
		    BEGIN
				IF(@accessLevel = 1 OR @accessLevel = 2)
				BEGIN
				IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial))
				BEGIN
					SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
					FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial  FOR XML RAW )+'</list>'		
					RETURN;
				END
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				END
				END
				ELSE IF((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				BEGIN
				    IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				    BEGIN
				    	SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
						FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))FOR XML RAW )+'</list>'		
						RETURN;
				    END
				    ELSE
				    BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
				    END		
				END
				ELSE IF((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				BEGIN
				    IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))
				    BEGIN
						SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
						FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey) FOR XML RAW )+'</list>'		
						RETURN;
					END
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
					END
				END
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				END
			END--(ORGID locID IS NULL END)
			ELSE IF(ISNULL(@orgId,'0') <> 0 AND ISNULL(@locId,'0') <> 0)
		    BEGIN
		    IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId AND t.LocId=@locId))
		    BEGIN
			  IF((@accessLevel = 1 OR @accessLevel = 2) OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId)))OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))))
				 BEGIN
					SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
					FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId AND t.LocId=@locId  FOR XML RAW )+'</list>'		
					RETURN;
				 END
				 ELSE
				 BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				 END
			END
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				RETURN;
			END	
			END--(ORGID Not  NULL END Locid not NUll END)
			ELSE IF(ISNULL(@orgId,'0') <> 0 AND ISNULL(@locId,'0') = 0)
			BEGIN
			IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId ))
		    BEGIN
			IF((@accessLevel = 1 OR @accessLevel = 2) OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId)))OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))))
				BEGIN
					SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
					FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId   FOR XML RAW )+'</list>'		
					RETURN;
				END
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				END
			END 
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				RETURN;
			END
			END
			ELSE IF(ISNULL(@orgId,'0') = 0 AND ISNULL(@locId,'0') <> 0)
				BEGIN
				IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE  t.LocId=@locId ))
					 BEGIN
					 IF(@accessLevel = 1 OR @accessLevel = 2) 
						 BEGIN
							SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
							FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.LocId=@locId   FOR XML RAW )+'</list>'		
							RETURN;
						 END
					 ELSE IF((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
						BEGIN
						 IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
							BEGIN
				    			SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
								FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))FOR XML RAW )+'</list>'		
								RETURN;
							END
						 ELSE
						 BEGIN
							SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
							RETURN;
						 END		
					END
					ELSE IF((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
					BEGIN
						IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))
						BEGIN
							SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
							FROM dbo.tblinterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey) FOR XML RAW )+'</list>'		
							RETURN;
						END
						ELSE
						BEGIN
							SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
							RETURN;
						END
					END	--accesslevel end
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
					END
			  	END --locid exist end
				ELSE
				 BEGIN
				 SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				 RETURN;
				END
			END --condition false
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				RETURN;
				END
			END--Routine
			
			--For Archived Interceptor  Details----
			ELSE IF(@routine = 2)
			BEGIN
		    IF(ISNULL(@orgId,'')='' AND ISNULL(@locId,'')=''  )
		    BEGIN
				IF(@accessLevel = 1 OR @accessLevel = 2)
				BEGIN
					IF(EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial))
					BEGIN
						SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
						FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial  FOR XML RAW )+'</list>'		
						RETURN;
					END
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
					END
				END
				ELSE IF((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				BEGIN
				    IF(EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				    BEGIN
				    	SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
						FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))FOR XML RAW )+'</list>'		
						RETURN;
				    END
				    ELSE
				    BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
				    END		
				END
				ELSE IF((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				BEGIN
				    IF(EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))
				    BEGIN
						SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
						FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey) FOR XML RAW )+'</list>'		
						RETURN;
					END
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
					END
				END
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				END
			END--(ORGID locID IS NULL END)
			ELSE IF(ISNULL(@orgId,'0') <> 0 AND ISNULL(@locId,'0') <> 0)
		    BEGIN
		    IF(EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId AND t.LocId=@locId))
		    BEGIN
			IF((@accessLevel = 1 OR @accessLevel = 2) OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId)))OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))))
			BEGIN
				SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
				FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId AND t.LocId=@locId  FOR XML RAW )+'</list>'		
				RETURN;
			END
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				RETURN;
			END
			END
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				RETURN;
			END
			END--(ORGID Not  NULL END Locid not NUll END)
			ELSE IF(ISNULL(@orgId,'0') <> 0 AND ISNULL(@locId,'0') = 0)
			BEGIN
			IF(EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId ))
		    BEGIN
				IF((@accessLevel = 1 OR @accessLevel = 2) OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId)))OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))))
				BEGIN
					SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
					FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId   FOR XML RAW )+'</list>'		
					RETURN;
				 END
				 ELSE
				 BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				 END
			END 
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				RETURN;
			END
			END
			ELSE IF(ISNULL(@orgId,'0') = 0 AND ISNULL(@locId,'0') <> 0)
				BEGIN
				IF(EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE  t.LocId=@locId ))
					BEGIN
					IF(@accessLevel = 1 OR @accessLevel = 2) 
						BEGIN
							SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
							FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.LocId=@locId   FOR XML RAW )+'</list>'		
							RETURN;
						END
						ELSE IF((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
						BEGIN
							IF(EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
							BEGIN
				    			SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
								FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))FOR XML RAW )+'</list>'		
								RETURN;
							END
						 ELSE
						 BEGIN
							SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
							RETURN;
						 END		
					END
					ELSE IF((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
					BEGIN
						IF(EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))
						BEGIN
							SELECT '<list>'+ (SELECT t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
							FROM dbo.tblArchivedInterceptor t inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey) FOR XML RAW )+'</list>'		
							RETURN;
						END
						ELSE
						BEGIN
							SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
							RETURN;
						END
					END	--accesslevel end
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
					END
			  	END --locid exist end
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				END
			END --condition false
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				RETURN;
			END
		 END
		 --For Device Scan Details----
		ELSE IF(@routine = 1)
		BEGIN
		    IF(ISNULL(@orgId,'0')=0 AND ISNULL(@locId,'0')=0)
			BEGIN
				IF(@accessLevel = 1 OR @accessLevel = 2)
				BEGIN
					IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial))
					BEGIN
					INSERT INTO #DeviceScan SELECT d.IntSerial,d.ScanData,d.ScanDate FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial 
		
					DECLARE KEY_Cursor CURSOR FOR SELECT D.IntSerial FROM dbo.#DeviceScan D
					OPEN KEY_Cursor; 
					FETCH NEXT FROM KEY_Cursor INTO @Key;
					WHILE @@FETCH_STATUS = 0
					BEGIN
			
						SELECT @scanData = D.ScanData FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
						SELECT @intserial = D.IntSerial FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
						SELECT @timestamp= D.ScanTimestamp FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
			
						SELECT @IntOrgId =  OrgId FROM dbo.tblInterceptor WHERE IntSerial = @intserial
						SET @COUNT_SERIAL =@COUNT_SERIAL+1

						/*Summay: Check if DeviceScan[scanData] is a dynamic code */
						IF(@scanData like '%~%' AND @scanData not like '%~deleteitem/prev%' AND @scanData not like '%~deleteitem/next%')
					BEGIN
						/*Summary: Use the dynCID to search for the DynamicCode record where dynCID is sandwiched between the ~ and the first “/” */
						IF EXISTS (SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2)))
						BEGIN
					 	/*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
							IF EXISTS (SELECT 1 FROM dbo.tblContent C JOIN tblInterceptor I ON C.OrgId=@IntOrgId  --C.OrgId
							 WHERE C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))))
							BEGIN
							/*Summay: If Content records found return the following fields */
							    IF(@scanData like '%*CH*%')
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
									JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
									AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))) AND DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
								ELSE
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
									JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
									AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))) AND DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
							END
							ELSE
							/*Summay: If Content records not found return the following fields */
							BEGIN
								IF(@scanData like '%*CH*%')
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp AND
									DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
								ELSE
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData  AND D.ScanDate= @timestamp AND
									DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
							END
						END
					END
					/*Summay: Check if DeviceScan[scanData] is not a dynamic code */
					ELSE
					BEGIN
						/*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
						IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @scanData AND C.OrgId = @IntOrgId)
						BEGIN
							/*Summay: If Content records found return the following fields */
							insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
							FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID
							JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
							WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
							AND C.Code = @scanData
						END
						ELSE
						/*Summay: If Content records not found return the following fields */
						BEGIN
							insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
							FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID
							JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
							WHERE D.IntSerial = @intSerial 
							AND D.ScanData =@scanData AND D.ScanDate= @timestamp
						END
					END
						FETCH NEXT FROM KEY_Cursor INTO @Key;
					END;
					CLOSE KEY_Cursor;
					DEALLOCATE KEY_Cursor;
					IF ((SELECT COUNT(*) FROM #table2) = 0)
					BEGIN
						INSERT INTO #table2 SELECT 0,0,0,400
					END
					SELECT '<list>'+ (SELECT distinct t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', t.ErrId AS 'ErrId'
					FROM #table2 t FOR XML RAW )+'</list>'	
					RETURN;	
					END
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
					END
				 END
				 ELSE IF((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				 BEGIN
				 IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				    BEGIN
		INSERT INTO #DeviceScan SELECT d.IntSerial,d.ScanData,d.ScanDate FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))
		
		DECLARE KEY_Cursor CURSOR FOR SELECT D.IntSerial FROM dbo.#DeviceScan D
		OPEN KEY_Cursor; 
		FETCH NEXT FROM KEY_Cursor INTO @Key;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @scanData = D.ScanData FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
			SELECT @intserial = D.IntSerial FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
			SELECT @timestamp= D.ScanTimestamp FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
			
			SELECT @IntOrgId =  OrgId FROM dbo.tblInterceptor WHERE IntSerial = @intserial
			SET @COUNT_SERIAL =@COUNT_SERIAL+1

				/*Summay: Check if DeviceScan[scanData] is a dynamic code */
					IF(@scanData like '%~%' AND @scanData not like '%~deleteitem/prev%' AND @scanData not like '%~deleteitem/next%')
					BEGIN
						/*Summary: Use the dynCID to search for the DynamicCode record where dynCID is sandwiched between the ~ and the first “/” */
						IF EXISTS (SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2)))
						BEGIN
					 	/*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
							IF EXISTS (SELECT 1 FROM dbo.tblContent C JOIN tblInterceptor I ON C.OrgId=@IntOrgId  --C.OrgId
							 WHERE C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))))
							BEGIN
							/*Summay: If Content records found return the following fields */
							    IF(@scanData like '%*CH*%')
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
									JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
									AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))) AND DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
								ELSE
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
									JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
									AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))) AND DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
							END
							ELSE
							/*Summay: If Content records not found return the following fields */
							BEGIN
								IF(@scanData like '%*CH*%')
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp AND
									DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
								ELSE
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData  AND D.ScanDate= @timestamp AND
									DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
							END
						END
					END
					/*Summay: Check if DeviceScan[scanData] is not a dynamic code */
					ELSE
					BEGIN
						/*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
						IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @scanData AND C.OrgId = @IntOrgId)
						BEGIN
							/*Summay: If Content records found return the following fields */
							insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
							FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID
							JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
							WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
							AND C.Code = @scanData
						END
						ELSE
						/*Summay: If Content records not found return the following fields */
						BEGIN
							insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
							FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID
							JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
							WHERE D.IntSerial = @intSerial 
							AND D.ScanData =@scanData AND D.ScanDate= @timestamp
						END
					END
					FETCH NEXT FROM KEY_Cursor INTO @Key;
				END;
				CLOSE KEY_Cursor;
				DEALLOCATE KEY_Cursor;
				IF ((SELECT COUNT(*) FROM #table2) = 0)
				BEGIN
					INSERT INTO #table2 SELECT 0,0,0,400
				END
				SELECT '<list>'+ (SELECT distinct t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', t.ErrId AS 'ErrId'
				FROM #table2 t FOR XML RAW )+'</list>'	
				RETURN;	
				    END
				    ELSE
				    BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
				    END		
				END
				ELSE IF((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
				BEGIN
				    IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))
				    BEGIN
		INSERT INTO #DeviceScan SELECT d.IntSerial,d.ScanData,d.ScanDate FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial where t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)
		
		DECLARE KEY_Cursor CURSOR FOR SELECT D.IntSerial FROM dbo.#DeviceScan D
		OPEN KEY_Cursor; 
		FETCH NEXT FROM KEY_Cursor INTO @Key;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SELECT @scanData = D.ScanData FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
			SELECT @intserial = D.IntSerial FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
			SELECT @timestamp= D.ScanTimestamp FROM #DeviceScan D WHERE D.id = @COUNT_SERIAL
			
			SELECT @IntOrgId =  OrgId FROM dbo.tblInterceptor WHERE IntSerial = @intserial
			SET @COUNT_SERIAL =@COUNT_SERIAL+1

				/*Summay: Check if DeviceScan[scanData] is a dynamic code */
					IF(@scanData like '%~%' AND @scanData not like '%~deleteitem/prev%' AND @scanData not like '%~deleteitem/next%')
					BEGIN
						/*Summary: Use the dynCID to search for the DynamicCode record where dynCID is sandwiched between the ~ and the first “/” */
						IF EXISTS (SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2)))
						BEGIN
					 	/*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
							IF EXISTS (SELECT 1 FROM dbo.tblContent C JOIN tblInterceptor I ON C.OrgId=@IntOrgId  --C.OrgId
							 WHERE C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))))
							BEGIN
							/*Summay: If Content records found return the following fields */
							    IF(@scanData like '%*CH*%')
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
									JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
									AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))) AND DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									
								END
								ELSE
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
									JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
									AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))) AND DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									
								END
							END
							ELSE
							/*Summay: If Content records not found return the following fields */
							BEGIN
								IF(@scanData like '%*CH*%')
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp AND
									DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
								ELSE
								BEGIN
									insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
									FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID 
									JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
									WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData  AND D.ScanDate= @timestamp AND
									DC.DynCID = (SELECT SUBSTRING(@scanData,CHARINDEX('~',@scanData)+1,CHARINDEX('/',@scanData)-2))
								END
							END
						END
					END
					/*Summay: Check if DeviceScan[scanData] is not a dynamic code */
					ELSE
					BEGIN
						/*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
						IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @scanData AND C.OrgId = @IntOrgId)
						BEGIN
							/*Summay: If Content records found return the following fields */
							insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
							FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID
							JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId =@IntOrgId -- I.OrgId
							WHERE D.IntSerial = @intSerial AND D.ScanData =@scanData AND D.ScanDate= @timestamp
							AND C.Code = @scanData
						END
						ELSE
						/*Summay: If Content records not found return the following fields */
						BEGIN
							insert into #table2 SELECT I.IntId,I.IntSerial,O.OrgId,'0'
							FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON L.LocId=I.LocID
							JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
							WHERE D.IntSerial = @intSerial 
							AND D.ScanData =@scanData AND D.ScanDate= @timestamp
						END
					END
					FETCH NEXT FROM KEY_Cursor INTO @Key;
				END;
				CLOSE KEY_Cursor;
				DEALLOCATE KEY_Cursor;
				IF ((SELECT COUNT(*) FROM #table2) = 0)
				BEGIN
					INSERT INTO #table2 SELECT 0,0,0,400
				END
				SELECT '<list>'+ (SELECT distinct t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', t.ErrId AS 'ErrId'
				FROM #table2 t FOR XML RAW )+'</list>'	
				RETURN;	
					END
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
					END
				END
				ELSE
				BEGIN
				 SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				 RETURN;
				END
			END--(ORGID locID IS NULL END)
			
			ELSE IF(ISNULL(@orgId,'0') <> 0 AND ISNULL(@locId,'0') <> 0)
				BEGIN
		     IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId AND t.LocId=@locId))
		     BEGIN
			  IF((@accessLevel = 1 OR @accessLevel = 2) OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId)))OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))))
				 BEGIN
					SELECT '<list>'+ (SELECT distinct t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
					FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId AND t.LocId=@locId  FOR XML RAW )+'</list>'		
					RETURN;
				 END
				 ELSE
				 BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				 END
			 END
			 ELSE
			 BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
			 END	 
				 
			END--(ORGID Not  NULL END Locid not NUll END)
			
			ELSE IF(ISNULL(@orgId,'0') <> 0 AND ISNULL(@locId,'0') = 0)
				BEGIN
			IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId ))
		     BEGIN
			  IF((@accessLevel = 1 OR @accessLevel = 2) OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId)))OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))))
				 BEGIN
					SELECT '<list>'+ (SELECT distinct t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
					FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.orgid=@orgId   FOR XML RAW )+'</list>'		
					RETURN;
				 END
				 ELSE
				 BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
					RETURN;
				 END
				END 
			ELSE
			BEGIN
			  SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
              RETURN;
			END
				
			END
			
			ELSE IF(ISNULL(@orgId,'0') = 0 AND ISNULL(@locId,'0') <> 0)
				BEGIN
				IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE  t.LocId=@locId ))
					 BEGIN
					 IF(@accessLevel = 1 OR @accessLevel = 2) 
						 BEGIN
							SELECT '<list>'+ (SELECT distinct t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
							FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial WHERE t.LocId=@locId   FOR XML RAW )+'</list>'		
							RETURN;
						 END
					 ELSE IF((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
						BEGIN
						 IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
							BEGIN
				    			SELECT '<list>'+ (SELECT distinct t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
								FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid IN (SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and S.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))FOR XML RAW )+'</list>'		
								RETURN;
							END
						 ELSE
						 BEGIN
							SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
							RETURN;
						 END		
					END
					ELSE IF((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey))))
					BEGIN
						IF(EXISTS(SELECT 1 FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey)))
						BEGIN
							SELECT '<list>'+ (SELECT distinct t.IntId AS 'IntId', t.IntSerial AS 'IntSerial', t.OrgId AS 'OrgId', '0' AS 'ErrId'
							FROM dbo.tblinterceptor t inner join tblDeviceScan d ON t.IntSerial = d.IntSerial inner join tblinterceptorId i on t.intSerial=i.intSerial where t.LocId=@locId AND t.orgid=(SELECT OrgId FROM dbo.[tblSession] where @sessionKey = sessionKey) FOR XML RAW )+'</list>'		
							RETURN;
						END
						ELSE
						BEGIN
							SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
							RETURN;
						END
					END	--accesslevel end
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
						RETURN;
					END
			  	END --locid exist end
				ELSE
				 BEGIN
				 SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				 RETURN;
				END
			END --condition false
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'IntId', '0' AS 'IntSerial', '0' AS 'OrgId', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
				RETURN;
			END
		END
		END	
	END
--SELECT * FROM dbo.tblorganization


GO
/****** Object:  StoredProcedure [dbo].[up_GetInterceptorIdDetails]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		iHorse	
-- Create date: 05.06.2013
-- Routine:		InterceptorID
-- Method:		DELETE	
-- Description:	deletes an existing InterceptorID record
-- ==================================================================
CREATE PROCEDURE [dbo].[up_GetInterceptorIdDetails] 

	@sessionKey		AS VARCHAR(40),
	@IntSerial	    AS VARCHAR(12)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
    DECLARE @IsExist			AS INT
	
	SET @IsExist = (SELECT COUNT(*) FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)			
	IF((ISNULL(@IntSerial,'') = '') OR @IsExist=0)
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'IntSerial','0' AS 'EmbeddedId','400' AS 'ErrId' FOR XML RAW )+'</list>'					
		EXEC upi_SystemEvents 'Organization',0,'3','EVENTDATA'
		RETURN;
	END
	ELSE IF EXISTS(SELECT 1 FROM dbo.tblInterceptorID WHERE IntSerial=@IntSerial)
	BEGIN
		SELECT '<list>'+( SELECT IntSerial AS 'IntSerial',EmbeddedId AS 'EmbeddedId','0' AS 'ErrId'
		FROM dbo.tblInterceptorID WHERE IntSerial=@IntSerial FOR XML RAW )+'</list>'
	END
	ELSE
	BEGIN
		SELECT '<list>'+(SELECT '0' AS 'IntSerial','0' AS 'EmbeddedId','400|2555 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 2555)+convert(varchar,@IntSerial) AS 'ErrId' FOR XML RAW )+'</list>'					
		EXEC upi_SystemEvents 'Organization',0,'3','EVENTDATA'
		RETURN;
	END
	--/*Summary:If the accessLevel is not SysAdminRW, then send a HTTP response “401 Unauthorised*/
	
END
--EXEC up_GetInterceptorIdDetails '3CEB756A7BDED3C44CD38206C68A3776687FC376','11111111111p'


GO
/****** Object:  StoredProcedure [dbo].[up_GetLocationsByOrgID]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ihorse
-- Create date: 12-08-2013
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[up_GetLocationsByOrgID] 

	@sessionKey AS VARCHAR(40),
	@orgId AS INT,
	@intId AS INT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @IsSessionExist	AS INT 
	DECLARE @AccessLevel	AS INT
	
	SET @IsSessionExist = (SELECT COUNT(*) FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	SET @accessLevel = (SELECT accessLevel FROM dbo.[tblSession] where @sessionKey = sessionKey)
	
	IF(@IsSessionExist = 0)
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'orgId', '0' AS 'locId', '0' AS 'locDesc', '0' AS 'LocType', '0' AS 'LocSubType', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
	END
	IF(@accessLevel=1 OR @accessLevel=2)
	BEGIN
		IF(ISNULL(@orgId,0)=0)
		BEGIN
			if(@intId=2)--LOC TYPE
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(LocType,'')) AS 'LocType', '0' AS 'locId','0' as 'locDesc', '0' AS 'orgId','0' AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L FOR XML RAW )+'</list>'
			END
			ELSE if(@intId=3)--LOC SUBTYPE
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(LocSubType,'')) AS 'LocSubType','0' AS 'locId','0' as 'locDesc' , '0' AS 'LocType','0' AS 'orgId' , '0' AS 'ErrId'
				FROM dbo.tblLocation L FOR XML RAW )+'</list>'
			END
			ELSE
			BEGIN
			--SELECT '<list>'+(SELECT isnull(OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc' , isnull(LocType,'') AS 'LocType', isnull(LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
			--FROM dbo.tblLocation L FOR XML RAW )+'</list>'
				SELECT '<list>'+(SELECT isnull(OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc' , isnull(LocType,'') AS 'LocType', isnull(LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L FOR XML RAW )+'</list>'
			END
		END
		ELSE
		BEGIN
		--exec [up_GetLocationsByOrgID] '6B05DB6DC930458646C3F560481C38E61E233D43','4',1
			if(@intId=2)
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(LocType,'')) AS 'LocType', '0' AS 'locId','0' as 'locDesc', '0' AS 'orgId','0' AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L WHERE OrgId = @orgId FOR XML RAW )+'</list>'
			END
			ELSE IF(@intId=3)
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(LocSubType,'')) AS 'LocSubType','0' AS 'locId','0' as 'locDesc' , '0' AS 'LocType','0' AS 'orgId' , '0' AS 'ErrId'
				FROM dbo.tblLocation L WHERE OrgId = @orgId FOR XML RAW )+'</list>'
			END
			ELSE
			BEGIN
				SELECT '<list>'+(SELECT isnull(OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc', isnull(LocType,'') AS 'LocType', isnull(LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L WHERE OrgId = @orgId FOR XML RAW )+'</list>'
			END
		END
	END
	ELSE IF(@accessLevel=3 OR @accessLevel=4)
	BEGIN
		IF(ISNULL(@orgId,0)=0)
		BEGIN
			if(@intId=2)
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(L.LocType,'')) AS 'LocType', '0' AS 'locId','0' as 'locDesc','0' AS 'orgId','0' AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey
				FOR XML RAW )+'</list>'
			END
			ELSE IF(@intId=3)
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(L.LocSubType,'')) AS 'LocSubType','0' AS 'locId','0' as 'locDesc' , '0' AS 'LocType','0' AS 'orgId' , '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey
				FOR XML RAW )+'</list>'
			END
			ELSE
			BEGIN
				SELECT '<list>'+(SELECT isnull(L.OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc', isnull(L.LocType,'') AS 'LocType', isnull(L.LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey
				FOR XML RAW )+'</list>'
			END
			
			--SELECT '<list>'+(SELECT isnull(L.OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc', isnull(L.LocType,'') AS 'LocType', isnull(L.LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
			--FROM dbo.tblLocation L
			--INNER JOIN tblOrganization O on O.OrgId=L.OrgId
			--INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey
			--FOR XML RAW )+'</list>'
		END
		ELSE
		BEGIN
		--exec [up_GetLocationsByOrgID] '6B05DB6DC930458646C3F560481C38E61E233D43','0',2
			IF(@intId=2)
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(L.LocType,'')) AS 'LocType', '0' AS 'locId','0' as 'locDesc', '0' AS 'orgId','0' AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey 
				and O.OrgId = @orgId
				FOR XML RAW )+'</list>'
			END
			ELSE IF(@intId=3)
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(L.LocSubType,'')) AS 'LocSubType','0' AS 'locId','0' as 'locDesc' , '0' AS 'LocType','0' AS 'orgId' , '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey 
				and O.OrgId = @orgId
				FOR XML RAW )+'</list>'
			END
			ELSE
			BEGIN
				SELECT '<list>'+(SELECT isnull(L.OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc', isnull(L.LocType,'') AS 'LocType', isnull(L.LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey 
				and O.OrgId = @orgId
				FOR XML RAW )+'</list>'
			END
			
			--SELECT '<list>'+(SELECT isnull(L.OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc', isnull(L.LocType,'') AS 'LocType', isnull(L.LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
			--FROM dbo.tblLocation L
			--INNER JOIN tblOrganization O on O.OrgId=L.OrgId
			--INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey 
			--and O.OrgId = @orgId
			--FOR XML RAW )+'</list>'
		END
	END
	ELSE IF(@accessLevel=5 OR @accessLevel=6 OR @accessLevel=7 OR @accessLevel=8)
	BEGIN
		IF(@intId=2)
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(L.LocType,'')) AS 'LocType', '0' AS 'locId','0' as 'locDesc', '0' AS 'orgId','0' AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.OrgId = S.orgID WHERE S.sessionKey = @sessionKey
				FOR XML RAW )+'</list>'
			END
			ELSE IF(@intId=3)
			BEGIN
				SELECT '<list>'+(SELECT distinct(isnull(L.LocSubType,'')) AS 'LocSubType','0' AS 'locId','0' as 'locDesc' , '0' AS 'LocType','0' AS 'orgId' , '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.OrgId = S.orgID WHERE S.sessionKey = @sessionKey
				FOR XML RAW )+'</list>'
			END
			ELSE
			BEGIN
				SELECT '<list>'+(SELECT isnull(L.OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc', isnull(L.LocType,'') AS 'LocType', isnull(L.LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
				FROM dbo.tblLocation L
				INNER JOIN tblOrganization O on O.OrgId=L.OrgId
				INNER JOIN [tblSession] S on O.OrgId = S.orgID WHERE S.sessionKey = @sessionKey
				FOR XML RAW )+'</list>'
			END
			
		--SELECT '<list>'+(SELECT isnull(L.OrgId,'') AS 'orgId', isnull(L.LocId,'') AS 'locId',CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc +'('+ convert(varchar,L.LocId) +')' else L.Street +','+ L.City + ','+ L.State + '('+ convert(varchar,L.LocId) +')'  end as 'locDesc', isnull(L.LocType,'') AS 'LocType', isnull(L.LocSubType,'') AS 'LocSubType', '0' AS 'ErrId'
		--FROM dbo.tblLocation L
		--INNER JOIN tblOrganization O on O.OrgId=L.OrgId
		--INNER JOIN [tblSession] S on O.OrgId = S.orgID WHERE S.sessionKey = @sessionKey
		--FOR XML RAW )+'</list>'
	END
END

--exec [up_GetLocationsByOrgID] '6B05DB6DC930458646C3F560481C38E61E233D43','0',2

GO
/****** Object:  StoredProcedure [dbo].[up_GetOrganizationNames]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Indhumathi T
-- Create date: 04.07.2013
-- Routine:		All
-- Method:		Get
-- Description:	Return Organization Names
-- =============================================
CREATE PROCEDURE [dbo].[up_GetOrganizationNames] 
	
	@id			AS VARCHAR(MAX),
	@routine	AS VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	--Routines
	--1 - Organization
	--2 - Location
	--3 - Interceptor
	--4 - Alerts
	--5 - Archived Organization
	--6 - Archived Interceptor 
	
	DECLARE @TMP TABLE ([ID] INT)
	DECLARE @TMP1 TABLE ([ID] INT, [OwnerName] VARCHAR(MAX) null)
		
	IF(@routine = 1 OR @routine = 2 OR @routine =4 OR @routine = 5)
	BEGIN
		INSERT INTO @TMP([ID]) SELECT items  FROM Splitrow(@id,',')
		IF(@routine = 1 OR @routine = 2 OR @routine =4)
		BEGIN
			INSERT INTO @TMP1([ID] ,[OwnerName]) SELECT T.id,o.OrgName 
			FROM dbo.tblOrganization o JOIN @TMP T ON o.orgid = T.ID
			SELECT '<list>'+( SELECT isnull(T.ID,'') AS 'orgid', isnull(T.OwnerName,'') AS 'orgName','0' AS 'locid','0' AS 'locdesc' FROM @TMP1 T FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@routine = 5)
		BEGIN
			INSERT INTO @TMP1([ID] ,[OwnerName]) SELECT T.id,OrgName FROM (SELECT OrgId,OrgName,ApplicationKey,IpAddress,[Owner] FROM dbo.tblorganization union SELECT OrgId,OrgName,ApplicationKey,IpAddress,[Owner]  FROM dbo.tblarchivedorg)  temp JOIN #TMP T ON orgid = T.ID
			SELECT '<list>'+( SELECT isnull(T.ID,'') AS 'orgid', isnull(T.OwnerName,'') AS 'orgName','0' AS 'locid','0' AS 'locdesc' FROM @TMP1 T FOR XML RAW )+'</list>'
			RETURN;
		END
	END
	ELSE IF(@routine = 3 OR @routine = 6)
	BEGIN
		DECLARE @CURSORID int
		DECLARE @TMP2 TABLE (id INT identity,orgloc VARCHAR(MAX) )
		DECLARE @TMP3 TABLE (id INT identity,[orgid] VARCHAR(MAX), [locid] VARCHAR(MAX),orgname VARCHAR(MAX),locdesc VARCHAR(MAX) )
		INSERT INTO @TMP2([orgloc]) SELECT items  FROM Splitrow(@id,'|') 
		DECLARE TEMP_cursor CURSOR FOR SELECT t.id FROM @TMP2 t
				 OPEN TEMP_cursor;  
				 FETCH NEXT FROM TEMP_cursor INTO @CURSORID;
				 WHILE @@FETCH_STATUS = 0  
				 BEGIN
				        DECLARE @orgval AS VARCHAR(MAX)
				        DECLARE @locval AS VARCHAR(MAX)
				        DECLARE @NameValuePairs AS NVARCHAR(MAX)
									
						SELECT @NameValuePairs  = t.orgloc FROM @TMP2 t WHERE t.ID = @CURSORID
						SET @orgval = LTRIM(RTRIM(SUBSTRING(@NameValuePairs, 1, CHARINDEX(',', @NameValuePairs) - 1)))
						SET @locval = LTRIM(RTRIM(SUBSTRING(@NameValuePairs, CHARINDEX(',', @NameValuePairs) + 1, LEN(@NameValuePairs))))
						INSERT INTO @TMP3(orgid,orgname,locid,locdesc) SELECT o.orgid,o.orgname,L.locid,CASE WHEN isnull(L.Locdesc,'') != ''  then L.Locdesc  else L.Street +','+ L.City + ','+ L.State  end as 'locDesc'  FROM dbo.tblOrganization o inner join tbllocation L ON o.orgid = l.orgid WHERE o.orgid=@orgval and l.locid=@locval
					    FETCH NEXT FROM TEMP_cursor INTO @CURSORID;
				END
				CLOSE TEMP_cursor;
			    DEALLOCATE TEMP_cursor;
		        Delete FROM @TMP2
			SELECT '<list>'+( SELECT isnull(T.orgid,'') AS 'orgid', isnull(T.orgname,'') AS 'orgname',isnull(T.locid,'') AS 'locid', isnull(T.locdesc,'') AS 'locdesc' FROM @TMP3 T FOR XML RAW )+'</list>'
			RETURN;
	END
END

GO
/****** Object:  StoredProcedure [dbo].[up_GetStatesNameByCountryId]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ihorse Technologies
-- Create date: 18.09.2013
-- Routine:		Getting states list 
-- Method:		Get
-- Description:	Return states list based on countryId
-- =============================================
--[up_GetStatesNameByCountryId] 40
CREATE PROCEDURE [dbo].[up_GetStatesNameByCountryId] 
@CountryId AS INT

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IsExist AS INT
	SET @IsExist = (SELECT COUNT(*) FROM dbo.[tblState] WHERE [CountryID] = @CountryId)
	IF(@IsExist > 0)
		BEGIN
			SELECT '<list>'+(SELECT [Id]
		  ,[CountryName]
		  ,'200' as [ErrId] 
		FROM [dbo].[tblState] WHERE [CountryID] = @CountryId FOR XML RAW )+'</list>'
		END
	ELSE
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'Id', '' AS 'CountryName', '204' AS 'ErrId' FOR XML RAW )+'</list>'
		END		
END
--[up_GetCountryNames]


GO
/****** Object:  StoredProcedure [dbo].[up_GetStatesNameByCountryName]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ihorse Technologies
-- Create date: 18.09.2013
-- Routine:		Getting states list 
-- Method:		Get
-- Description:	Return states list based on countryId
-- =============================================
--[up_GetStatesNameByCountryName] 'canada'
CREATE PROCEDURE [dbo].[up_GetStatesNameByCountryName] 
@CountryName AS Varchar(150)

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IsExist AS INT
	SET @IsExist = (SELECT COUNT(*) FROM dbo.tblState WHERE CountryName = @CountryName)
	--SELECT @IsExist
	IF(@IsExist > 0)
		BEGIN
			SELECT '<list>'+(SELECT dbo.tblState.StateOrProvince, dbo.tblState.Id, '200' AS 'ErrId'
				FROM dbo.tblCountries INNER JOIN
                      dbo.tblState ON dbo.tblCountries.CountryID = dbo.tblState.CountryID
				WHERE dbo.tblCountries.CountryName = @CountryName FOR XML RAW )+'</list>'
		END
	ELSE
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'Id', '' AS 'CountryName', '204' AS 'ErrId' FOR XML RAW )+'</list>'
		END		
END



--[up_GetCountryNames]


GO
/****** Object:  StoredProcedure [dbo].[up_GetUserDetailsByOrgID]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================
-- Author:		Indhumathi T
-- Create date: 10.06.2013
-- Routine:		User
-- Method:		Get
-- Description:	Returns one or more User records based on Access level and Organization Id
-- =======================================================================================
CREATE PROCEDURE [dbo].[up_GetUserDetailsByOrgID] 

	@sessionKey		AS VARCHAR(40),
	@orgId			AS INT,
	@userId			AS VARCHAR(5)
		
AS
BEGIN
	SET NOCOUNT ON;
	
	if(ISNULL(@userId,'')='')	SET @userId = ''
	if(ISNULL(@orgId,0)=0)		SET @orgId = 0

	DECLARE @ReturnResult	AS VARCHAR(100)
	DECLARE @accessLevel	AS INT
	DECLARE @eventData		AS VARCHAR(1000)
	
	SET @accessLevel = (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	If((@accessLevel = 1 OR @accessLevel = 2) AND @userId = -1 )
	BEGIN
			
		Declare @SessionorgId AS INT
		SET @SessionorgId =(SELECT orgid FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
		SELECT '<list>'+(
		SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
		FROM dbo.[tblUser] U WHERE U.OrgId = @SessionorgId
		FOR XML RAW )+'</list>'
		--select * FROM dbo.[tblUser] U WHERE U.OrgId = @SessionorgId and @accessLevel in (1,2)
		RETURN;
	END
	IF(((@orgId <>0 AND @orgId IS NOT NULL) OR (@userId <>'' AND @userId IS NOT NULL)) AND (@accessLevel = 7 OR @accessLevel = 8))
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '400' AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	
	IF(@orgId <> 0)
	BEGIN
		IF (NOT EXISTS (SELECT OrgId FROM dbo.[tblSession] WHERE OrgId = @orgId AND @sessionKey = sessionKey) AND (@accessLevel = 5 OR @accessLevel = 6))
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName', '0' AS 'RegDate', '0' AS 'AccessLevel', '400' AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	END
	
	IF((@orgId IS NOT NULL AND @orgId <> 0) AND (@userId <>'' AND @userId IS NOT NULL))
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName', '0' AS 'RegDate', '0' AS 'AccessLevel', '400' AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	/*Summary: If organization id passed */
	
	IF(ISNULL(@orgId,0) != 0)
	BEGIN
    IF EXISTS (SELECT 1 FROM dbo.tblOrganization WHERE Orgid = @orgId)
    BEGIN
		IF((@accessLevel = 1 OR @accessLevel = 2) 
		OR ((@accessLevel = 3 OR @accessLevel = 4) AND EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId WHERE S.SessionKey = @sessionKey))
		OR ((@accessLevel = 5 OR @accessLevel = 6)))
		BEGIN
			IF(@accessLevel = 5 OR @accessLevel = 6)
			BEGIN
				SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.[tblUser] U WHERE U.AccessLevel >= @AccessLevel AND U.OrgId IN (SELECT [OrgId] FROM dbo.[tblOrganization] O )
				FOR XML RAW )+'</list>'
			END
			ELSE
			IF(@accessLevel = 7 OR @accessLevel = 8)
			BEGIN
				SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.tblUser U WHERE U.OrgId = @orgId 
				FOR XML RAW )+'</list>'
			END
			ELSE IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE Owner <> @orgId)
			BEGIN
			SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.[tblUser] U WHERE U.OrgId = @orgId AND U.AccessLevel >= @AccessLevel
				FOR XML RAW )+'</list>'
			END
			ELSE
			BEGIN
			SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.[tblUser] U WHERE U.AccessLevel >= @AccessLevel AND U.OrgId IN (SELECT [OrgId]
				FROM dbo.[tblOrganization] O WHERE O.Owner IN (@orgId))
				FOR XML RAW )+'</list>'
			END
			RETURN;
        END
        ELSE IF(@accessLevel = 3 OR @accessLevel = 4)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate','0' AS 'AccessLevel', '4011' AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
    END
    ELSE
    BEGIN
        SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '400' AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	END	
	
	/*Summary: If user id passed */
	IF(ISNULL(@userId,'') != '' )
	BEGIN
	IF EXISTS (SELECT 1 FROM dbo.tblUser WHERE UserId = @userId)
	BEGIN
		IF((@accessLevel = 1 OR @accessLevel = 2) 
		OR ((@accessLevel = 3 OR @accessLevel = 4) AND EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblUser U ON O.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey and U.UserId = @userId ))
		OR ((@accessLevel = 3 OR @accessLevel = 4) AND
		NOT EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblUser U ON O.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey and U.UserId = @userId ) AND
		(EXISTS (SELECT S.OrgId FROM dbo.tblSession S JOIN tblUser U ON U.OrgId = S.OrgId  WHERE U.UserId = @userId AND S.SessionKey = @sessionKey))) OR
		((@accessLevel = 5 OR @accessLevel = 6) AND (EXISTS (SELECT S.OrgId FROM dbo.tblSession S JOIN tblUser U ON U.OrgId = S.OrgId  WHERE U.UserId = @userId and S.SessionKey = @sessionKey ))))
		BEGIN
			IF(@accessLevel = 1 OR @accessLevel = 2)
			BEGIN
				SELECT '<list>'+(SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.tblUser U WHERE U.UserId = @userId
				FOR XML RAW )+'</list>'
			END
			ELSE
			BEGIN
				SELECT '<list>'+(SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.tblUser U WHERE U.UserId = @userId 
				FOR XML RAW )+'</list>'
			END
			RETURN;
		END
		ELSE
        BEGIN
			IF(@accessLevel = 3 OR @accessLevel = 4 OR @accessLevel = 5 OR @accessLevel = 6) 
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '4012' AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
            END
        END
	END
	ELSE
    BEGIN
        SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '400' AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	END
	
	IF((@orgId = 0 OR @orgId IS NULL) AND (@userId = '' OR @userId IS NULL))
	BEGIN
		DECLARE @smporgId AS INT
		SET @smporgId = (SELECT s.OrgId FROM dbo.tblSession S WHERE s.SessionKey = @sessionKey)
		IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE OrgId=@smporgId)
		BEGIN
		 IF(@accessLevel = 1 OR @accessLevel = 2)
		 BEGIN
			SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.[tblUser] U INNER JOIN tblOrganization o ON U.OrgId=o.OrgId 
				FOR XML RAW )+'</list>'
				---select * FROM dbo.[tblUser] U INNER JOIN tblOrganization o ON U.OrgId=o.OrgId  
		END	
		ELSE IF(@accessLevel = 3 OR @accessLevel = 4)
		BEGIN
			--SELECT '<list>'+(
			--	SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
			--	FROM dbo.[tblUser] U INNER JOIN tblOrganization o ON U.OrgId=o.OrgId 
			--	WHERE U.AccessLevel >= @AccessLevel AND U.OrgId=@smporgId
			--	FOR XML RAW )+'</list>'
			IF(@AccessLevel = 3)
			BEGIN
			--changed for dashboard team
				SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				--FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
				--AND U.AccessLevel >= @AccessLevel AND U.OrgId=@smporgId
				FROM dbo.[tblUser] U WHERE U.AccessLevel > = @AccessLevel 
				AND (U.OrgId IN (SELECT [OrgId] FROM dbo.[tblOrganization] O WHERE O.Owner IN (@smporgId)) or U.OrgId IN (@smporgId))
				FOR XML RAW )+'</list>'
			END
			ELSE IF(@AccessLevel = 4)
			BEGIN
				SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				--FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
				--AND U.AccessLevel >= @AccessLevel AND U.OrgId=@smporgId
				FROM dbo.[tblUser] U WHERE (U.AccessLevel > = @AccessLevel OR U.AccessLevel=3)
				AND (U.OrgId IN (SELECT [OrgId] FROM dbo.[tblOrganization] O WHERE O.Owner IN (@smporgId)) or U.OrgId IN (@smporgId))
				FOR XML RAW )+'</list>'
			END
			RETURN;
		END
		ELSE IF(@accessLevel = 5 OR @accessLevel = 6)
		BEGIN
		declare @sampUserid AS VARCHAR(5)
		set @sampUserid = (SELECT userId FROM dbo.tblsession WHERE sessionKey = @sessionKey)
		  SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.[tblUser] U INNER JOIN tblOrganization o ON U.OrgId=o.OrgId 
				WHERE U.AccessLevel >= @AccessLevel and U.OrgId=@smporgId	
				and U.userId <> @sampUserid
				FOR XML RAW )+'</list>'
		END
		ELSE IF(@accessLevel = 7 OR @accessLevel = 8)
		BEGIN
			SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.[tblUser] U INNER JOIN [tblOrganization] O ON O.OrgId=U.OrgId  WHERE O.orgId=@smporgId AND  U.UserId=(SELECT s.UserId FROM dbo.tblSession S WHERE s.SessionKey = @sessionKey)
				FOR XML RAW )+'</list>'
		END
		END
		ELSE
		BEGIN
		SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', (ISNULL(U.RegDate,'')) AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0' AS 'ErrId'
				FROM dbo.[tblUser] U WHERE U.AccessLevel >= @AccessLevel AND U.OrgId IN (SELECT [OrgId]
				FROM dbo.[tblOrganization] O WHERE O.Owner IN (@smporgId))
				FOR XML RAW )+'</list>'
		 
		END
END 
END
--[up_GetUserDetailsByOrgID] 'C3E1C3B5EFB52B9A146A07006A1979A1A02A18A1',0,-1

--select * from tblsession

--select * from tbluser 


GO
/****** Object:  StoredProcedure [dbo].[up_GetUserDetailsBySessionKey]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		iHorse
-- Create date: 13.08.2013
-- Description:	Get user details using sessionKey
-- =============================================
CREATE PROCEDURE [dbo].[up_GetUserDetailsBySessionKey] 

	@SessionKey AS VARCHAR(40)
	
AS
BEGIN
	SET NOCOUNT ON;
    SELECT '<list>'+(
		SELECT tblSession.SessionKey, tblSession.UserId, tblSession.OrgId, tblSession.AccessLevel, tblUser.FirstName, ISNULL(tblUser.LastName,'') AS 'LastName'
		FROM dbo.tblSession INNER JOIN
		tblUser ON tblSession.UserId = tblUser.UserId WHERE tblSession.SessionKey = @SessionKey
		FOR XML RAW )+'</list>'
END

--[up_GetUserDetailsBySessionKey] '171B6D219630BD93D4E1177A5D1FE3FC'


GO
/****** Object:  StoredProcedure [dbo].[up_GetVarAndOrgAlertList]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		iHorse
-- Create date: 13.08.2013
-- Description:	Get Organization list using sessionKey
-- ==================================================================
CREATE PROCEDURE [dbo].[up_GetVarAndOrgAlertList] 

	@sessionKey AS VARCHAR(40) 
	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @IsSessionExist AS INT 
	DECLARE @AccessLevel	AS INT
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	
	SET @IsSessionExist = (SELECT COUNT(*) FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	IF(@IsSessionExist = 0)
	BEGIN
		SET @ReturnResult = '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress','0' AS 'OwnerId', '0' AS 'Owner', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
		SELECT @ReturnResult
	END
	ELSE IF(@IsSessionExist <> 0)
	BEGIN
		SET @AccessLevel = (SELECT AccessLevel FROM dbo.tblSession WHERE SessionKey = @sessionKey)
		IF(@AccessLevel = 1 OR @AccessLevel = 2)
		BEGIN 
			SELECT '<list>'+(
			SELECT distinct C.Orgid AS 'Orgid',O.OrgName + ' ('+ convert(VARCHAR,C.Orgid) +')' AS 'OrgName', O.ApplicationKey AS 'ApplicationKey', CASE O.IpAddress WHEN '' THEN '0' ELSE ISNULL(O.IpAddress,'0') END AS 'IpAddress', O.Owner AS 'OwnerId',
			(SELECT TOP 1 org.OrgName FROM dbo.tblOrganization org WHERE org.OrgId = O.Owner ) AS 'Owner', '0' AS 'ErrId'
			FROM dbo.tblOrganization O inner join tblAlerts C on O.orgid=C.orgid WHERE O.[Owner] != 0 FOR XML RAW )+'</list>'  
		END
		ELSE IF (@AccessLevel = 3 OR @AccessLevel = 4)	
		BEGIN
			SELECT '<list>'+(
			SELECT distinct C.Orgid AS 'Orgid',O.OrgName + ' ('+ convert(VARCHAR,C.Orgid) +')' AS 'OrgName', O.ApplicationKey AS 'ApplicationKey', CASE O.IpAddress WHEN '' THEN '0' ELSE ISNULL(O.IpAddress,'0') END AS 'IpAddress', O.Owner AS 'OwnerId',
			(SELECT TOP 1 org.OrgName FROM dbo.tblOrganization org WHERE org.OrgId = O.Owner ) AS 'Owner', '0' AS 'ErrId'
			FROM dbo.tblOrganization O inner join tblAlerts C on O.orgid=C.orgid WHERE O.Owner = (SELECT orgId FROM dbo.tblSession WHERE SessionKey = @sessionKey) FOR XML RAW )+'</list>' 
		END	  			
	END		
END
--[up_GetVarAndOrganizationList] '77743E44A71169925C29485C4AF5AD57'


GO
/****** Object:  StoredProcedure [dbo].[up_GetVarAndOrganizationList]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		iHorse
-- Create date: 13.08.2013
-- Description:	Get Organization list using sessionKey
-- ==================================================================
CREATE PROCEDURE [dbo].[up_GetVarAndOrganizationList] 

	@sessionKey AS VARCHAR(40) 
	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @IsSessionExist AS INT 
	DECLARE @AccessLevel	AS INT
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	
	SET @IsSessionExist = (SELECT COUNT(*) FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	IF(@IsSessionExist = 0)
	BEGIN
		SET @ReturnResult = '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress','0' AS 'OwnerId', '0' AS 'Owner', '400' AS 'ErrId' FOR XML RAW )+'</list>' 
		SELECT @ReturnResult
	END
	ELSE IF(@IsSessionExist <> 0)
	BEGIN
		SET @AccessLevel = (SELECT AccessLevel FROM dbo.tblSession WHERE SessionKey = @sessionKey)
		IF(@AccessLevel = 1 OR @AccessLevel = 2)
		BEGIN 
			SELECT '<list>'+(
			SELECT O.Orgid AS 'Orgid',O.OrgName + ' ('+ convert(varchar,O.Orgid) +')' AS 'OrgName', O.ApplicationKey AS 'ApplicationKey', CASE O.IpAddress WHEN '' THEN '0' ELSE ISNULL(O.IpAddress,'0') END AS 'IpAddress', O.Owner AS 'OwnerId',
			(SELECT TOP 1 org.OrgName FROM dbo.tblOrganization org WHERE org.OrgId = O.Owner ) AS 'Owner', '0' AS 'ErrId'
			FROM dbo.tblOrganization O WHERE O.[Owner] != 0 FOR XML RAW )+'</list>'  
		END
		ELSE IF (@AccessLevel = 3 OR @AccessLevel = 4)	
		BEGIN
			SELECT '<list>'+(
			SELECT O.Orgid AS 'Orgid',O.OrgName + ' ('+ convert(varchar,O.Orgid) +')' AS 'OrgName', O.ApplicationKey AS 'ApplicationKey', CASE O.IpAddress WHEN '' THEN '0' ELSE ISNULL(O.IpAddress,'0') END AS 'IpAddress', O.Owner AS 'OwnerId',
			(SELECT TOP 1 org.OrgName FROM dbo.tblOrganization org WHERE org.OrgId = O.Owner ) AS 'Owner', '0' AS 'ErrId'
			FROM dbo.tblOrganization O WHERE O.Owner = (SELECT orgId FROM dbo.tblSession WHERE SessionKey = @sessionKey) FOR XML RAW )+'</list>' 
		END	  			
	END		
END
--[up_GetVarAndOrganizationList] '77743E44A71169925C29485C4AF5AD57'


GO
/****** Object:  StoredProcedure [dbo].[up_InterceptorDeviceStatusDeActive]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		iHorse
-- Create date: 13.08.2013
-- Routine:		InterceptorDeviceStatusDeActive
-- Method:		PUT
-- Description:	Update an Interceptor Device Status field to DeActive
-- ==================================================================
CREATE PROCEDURE [dbo].[up_InterceptorDeviceStatusDeActive] 
	
	@intId AS INT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- 400 - Bad Request
	-- 200 - Success
	-- Local variables descriptions
	-- @ReturnResult used to return results
	
	DECLARE @ReturnResult AS VARCHAR(100)
	
	IF EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntId = @intId)
	BEGIN
		UPDATE tblInterceptor SET DeviceStatus = 2 WHERE IntId = @intId
		SET	@ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
	END
	ELSE SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
	
END
-- exec [upu_Interceptor] 'A1A2A3A4A5A6A7A8','630523D723572A326E276452B5F6578A','12','3','44'---AccessLevel 1(SysAdminRW)


GO
/****** Object:  StoredProcedure [dbo].[upd_Alert]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		iHorse
-- Create date: 26.07.2013
-- Routine:		Alert
-- Method:		Delete
-- Description:	Deletes an existing Alert record
-- =============================================
--exec [upd_Alert] '90CBBAE833A64E032A14BACB3335D4EAA5420DE3','B20493693B3A4BD7D26F2E5467BD9AAA00801B67',1,'{"alertid":"400"}'
CREATE PROCEDURE [dbo].[upd_Alert] 
	
	@applicationKey	AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@orgId			AS INT,
	@delList		AS NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 201 - Created
	    
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @sessionOrgID used to store the session OrgID
	-- @AlertVar used to store the deleteList
	-- @recorded used to store current activity Id
	-- @CURSORID used for Cursor
	-- @itemProcessed used to store the total item Processed
	-- @recordsDeleted used to store the deleted items
	-- @badItems used to store error items
	-- @alertId used to store the alerdid
	-- @Error used to store the error
	-- @ErrorMessage used to return the error message
	-- @NameValuePairs,@NameValuePair,@Name,@Value,@Property used to process the dellist object
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @sessionOrgID	AS INT
	DECLARE @AlertVar		AS NVARCHAR(MAX)
	DECLARE	@recorded		AS VARCHAR(100)
	DECLARE @CURSORID		AS INT
	DECLARE @itemProcessed	AS INT
	DECLARE @recordsDeleted AS INT
	DECLARE @badItems		AS INT
	DECLARE @alertId		AS NVARCHAR(20)
	DECLARE @Error			AS VARCHAR(10)
	DECLARE @ErrorMessage	AS NVARCHAR(MAX)
	DECLARE @NameValuePairs AS VARCHAR(MAX) 
    DECLARE @NameValuePair  AS VARCHAR(100)
	DECLARE @Name           AS VARCHAR(100)
	DECLARE @Value          AS VARCHAR(100)
	DECLARE @Property TABLE ([id] INT ,[Name] VARCHAR(100),[Value] VARCHAR(100))
	
	SET @ErrorMessage	= '';
	SET @itemProcessed	= 0;
	SET @recordsDeleted	= 0;
	SET @badItems		= 0;
	SET @date			= SYSDATETIMEOFFSET();
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE @sessionKey = sessionKey)
	SET @sessionOrgID	= (SELECT orgid FROM dbo.tblsession WHERE sessionKey = @sessionKey )
	SET @UserId			= (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)

	IF(ISNULL(@orgId,'')='') SET @orgId = 0;
	
	/* Summary :Create Temporary table(for Internal Use) */
	CREATE TABLE #TempScan1 (ID INT IDENTITY(1,1) NOT NULL,alertId NVARCHAR(Max))

  /* Summary:if Session[accessLevel] = SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW then do the following */ 
	   
	IF(@accessLevel = 1 OR @accessLevel =3 OR @accessLevel =5 OR @accessLevel =7)
	BEGIN
		/* Summary:Raise an Error Message(400). If orgId parameter passed and user = OrgAdmin or OrgUser */
		IF(@orgId <> 0)
		BEGIN
			IF(@accessLevel = 5 OR @accessLevel=7)
			BEGIN
				SET @ReturnResult = '400|3004 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 3004)+'->'+convert(varchar,@orgId)
				SELECT @ReturnResult AS Returnvalue
				RETURN;
			END
		END
		
		/*Summary:Raise an Error Message(400).If orgId is not passed and Session[accessLevel] is either SysAdminRW or  VarAdminRW */
		
		IF(@orgId = 0)
		BEGIN
			IF(@accessLevel = 1 OR @accessLevel=3)
			BEGIN
				SET @ReturnResult = '400|3003 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 3003)
				SELECT @ReturnResult AS Returnvalue
				RETURN;
			END
			ELSE IF(@accessLevel = 5 OR @accessLevel=7)
			BEGIN
			 SET @orgId=@sessionOrgID;
			END
		END
		
		/* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */
		IF NOT EXISTS(SELECT OrgId FROM dbo.tblOrganization WHERE OrgId = @orgId)
		BEGIN
			SET @ReturnResult = '400|3005 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 3005)+'->'+convert(varchar,@orgId)
			SELECT @ReturnResult AS Returnvalue
			RETURN;
		END
		
		/* Summary: Raise an error message (400). If contentData field not passed */
		IF(ISNULL(@delList,'') = '')
		BEGIN
			SET @ReturnResult = '400|3006 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 3006)
			SELECT @ReturnResult AS Returnvalue
			RETURN;
		END
		
		SET @AlertVar =REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(@delList,'{',''),'}',''),'"',''),'[',''),']','');
		INSERT INTO #TempScan1(alertId)Select items from Splitrow(@AlertVar,',')
        /* Summary: If the Organization record is found, check if the user is authorized to make this request */
							 /* Summary: If accessLevel is SysAdminRW */
							 /* Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of organization[OrgId] */
							 /* Summary: If accessLevel is OrgAdminRW or OrgUserRW, then check if Session[OrgId] is the same as organization[OrgId] */
		
        IF((@accessLevel = 1) OR ((@accessLevel = 3) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and  o.orgId=@orgId))) OR 
        ((@accessLevel = 5 OR @accessLevel=7 ) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgID = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))))
		BEGIN
			 DECLARE Alert_cursor CURSOR FOR SELECT t.ID FROM dbo.#TempScan1 t WITH(NOLOCK)
			 OPEN Alert_cursor;  
			 FETCH NEXT FROM Alert_cursor INTO @CURSORID;
			 WHILE @@FETCH_STATUS = 0  
				  BEGIN
				       	SELECT @NameValuePairs  = t.alertId from dbo.#TempScan1 t where t.ID = @CURSORID
						SET @Name = SUBSTRING(@NameValuePairs, 1, CHARINDEX(':', @NameValuePairs) - 1)
						SET @Value = SUBSTRING(@NameValuePairs, CHARINDEX(':', @NameValuePairs) + 1, LEN(@NameValuePairs))
						SET @Name = LTRIM(RTRIM(@Name))
                        SET @Value = LTRIM(RTRIM(@Value))
						SET @itemProcessed = @itemProcessed+1;
						SET @alertId='';
						
						/* Summary: To check the Label in json List  */  
						IF(LOWER(@Name) = 'alertid')
                            SET @alertId=@Value;
                         ELSE
                         BEGIN
                            SET  @Error='Error'; 
                            SET @ErrorMessage = @ErrorMessage+(select +'|3008 '+Description +'|'+ FieldName  FROM dbo.tblErrorLog where ErrorCode= 3008)
                         END
                          
						/* Summary:if entry does not contain AlertID add error message + bad data to errors return field, and increment badItems count make sure that code + passed orgId (or Session[orgId]
                             if orgId not passed) does not already exist in Alert
                             if match found in alert add error message + bad data to errors return field, and increment badItems count */
                      
                       IF(isnull(@Error,'') = '' AND (ISNULL(@alertId,'')<> '') AND (EXISTS(SELECT AlertId FROM dbo.tblAlerts  WHERE AlertId=@alertId AND OrgId=@orgId)))                   
						BEGIN
							SELECT @recorded = CONVERT(VARCHAR(50),Id)FROM dbo.tblAlerts c WHERE c.AlertId=@alertId AND c.OrgId=@orgId
							DELETE FROM dbo.tblAlerts WHERE AlertId=@alertId AND OrgId=@orgId; 
							SET @recordsDeleted=@recordsDeleted+1;
							UPDATE [tblSession] SET lastActivity=SYSDATETIMEOFFSET() WHERE sessionKey=@sessionKey
							EXEC upi_UserActivity @UserId,@date,4,@alertId,19,'Delete'
						END
						ELSE
						BEGIN
							SET @badItems=@badItems+1;
							IF(ISNULL(@alertId,'')='')SET @ErrorMessage = @ErrorMessage+(select +'|3009 ' +Description +'|'+ FieldName  FROM dbo.tblErrorLog where ErrorCode= 3009)  --+'->'+convert(varchar,@alertId)
						    ELSE IF(NOT EXISTS(SELECT AlertId FROM dbo.tblAlerts  WHERE AlertId=@alertId AND OrgId=@orgId))SET @ErrorMessage = @ErrorMessage+(select +'|3010 ' +Description +'|' +  FieldName  FROM dbo.tblErrorLog where ErrorCode= 3010)+'->'+convert(varchar,@alertId)
					  	END
					FETCH NEXT FROM Alert_cursor INTO @CURSORID;
				 END
			  CLOSE Alert_cursor;
			  DEALLOCATE Alert_cursor;
		      SET @ReturnResult='200'
              SELECT @ReturnResult +'|itemsProcessed = '+convert(varchar,@itemProcessed)+'|recordsDeleted = '+convert(varchar,@recordsDeleted)+'|badItems = '+convert(varchar,@badItems)+ @ErrorMessage  AS Returnvalue
              RETURN;
		END
		
		/* Summary: Raise an Error Message.User not within scope*/
		ELSE
		BEGIN
			IF(@accessLevel = 3)
			BEGIN
				SET @ReturnResult = '401|3001 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 3001)+'->'+convert(varchar,isnull(@accessLevel,'0'))
				SELECT @ReturnResult AS Returnvalue
				RETURN;
			END
			ELSE IF(@accessLevel = 5 OR @accessLevel=7 ) 
			BEGIN
				SET @ReturnResult = '400|3005 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 3005)+'->'+convert(varchar,isnull(@accessLevel,'0'))
				SELECT @ReturnResult AS Returnvalue
				RETURN;
			END
		END
	END
	
	/* Summary:Raise an Error Message,if Session[accessLevel] != SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW */
	ELSE
	BEGIN
		SET @ReturnResult = '401|3001 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 3001)+'->'+convert(varchar,isnull(@accessLevel,'0'))
		SELECT @ReturnResult AS Returnvalue
		RETURN;
	END
	
END


GO
/****** Object:  StoredProcedure [dbo].[upd_Authenticate]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================
-- Author:		Dinesh
-- Create date: 17.04.2013
-- Routine:		Authenticate
-- Method:		Delete
-- Description:	Deletes a User Session Record
-- Delete Authenticate (Not sure and clear idea about system Events and InsertUserActivity)
-- =======================================================================================
CREATE PROCEDURE [dbo].[upd_Authenticate] 

		@applicationkey AS VARCHAR(40),
		@sessionkey		AS VARCHAR(40)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	
	-- Output DESCRIPTIONs
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables DESCRIPTIONs
	-- @ReturnResult used to return results
	-- @LIUserID used to get userid FROM user
	
	SET NOCOUNT ON;
	DECLARE @ReturnResult	AS VARCHAR(10)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @LIUserID		AS VARCHAR(5)
	DECLARE	@recorded		AS INT
	
	SET @LIUserID = (SELECT UserId FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	SET @date=SYSDATETIMEOFFSET()
	
    /*applicationkey is not passed return Error:400 Bad Request*/
    IF (@applicationkey='' OR @applicationkey IS NULL)
	BEGIN
		SET @ReturnResult='400';
		EXEC upi_SystemEvents 'Authenticate',1027,3,@applicationkey
		SELECT @ReturnResult as ReturnData
		RETURN; 
	END
	IF (@sessionkey='' OR @sessionkey IS NULL)
	BEGIN
		SET @ReturnResult='400';
		EXEC upi_SystemEvents 'Authenticate',1021,3,@applicationkey
		SELECT @ReturnResult as ReturnData
		RETURN;
	END
	
	/*Use sessionkey and applicationkey to search session and organization record
	if record not found return Error:400 Bad Request*/
	IF EXISTS (SELECT 1 FROM dbo.tblOrganization WHERE applicationKey=@applicationkey)
	AND EXISTS(SELECT 1 FROM dbo.tblSession WHERE SessionKey=@sessionkey)
		BEGIN
			SET @recorded = (SELECT S.Id FROM dbo.tblSession S WHERE S.SessionKey = @sessionkey)
			DELETE FROM dbo.[tblSession] WHERE sessionKey=@sessionkey;
			EXEC upi_UserActivity @LIUserID,@date,4,@recorded,0,'Delete'
			SET @ReturnResult='200';	
			SELECT @ReturnResult as ReturnData
		END
	ELSE
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM dbo.tblOrganization WHERE applicationKey=@applicationkey)
			BEGIN
				SET @ReturnResult='400';
				EXEC upi_SystemEvents 'Authenticate',1007,3,@applicationkey
				SELECT @ReturnResult as ReturnData
				RETURN; 
			END
			ELSE IF NOT EXISTS(SELECT 1 FROM dbo.tblSession WHERE SessionKey=@sessionkey)
			BEGIN
				SET @ReturnResult='400';
				EXEC upi_SystemEvents 'Authenticate',1028,3,@sessionkey
				SELECT @ReturnResult as ReturnData
				RETURN; 
			END
		END
	
END
--[upd_Authenticate] 'A1A2A3A4A5A6A7A8','53666AFF0F8AADD3CCEC29C938C9B316'


GO
/****** Object:  StoredProcedure [dbo].[upd_Content]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		iHorse
-- Create date: 06.06.2013
-- Routine:		Content
-- Method:		Delete
-- Description:	Deletes an existing Content record
-- ===============================================
  
CREATE PROCEDURE [dbo].[upd_Content] 
	
	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgId				AS INT,
	@delList			AS NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 201 - Created
	    
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @eventData used to store event data description
	-- @sessionOrgID used to store the session OrgID
	-- @intID used to store the content ID
	-- @contentVar used to store the contentdata
	-- @CURSORID used to cursor
	-- @itemProcessed used to count the content records
	-- @recordsCreated used to count the good content records
	-- @badItems  used to count the Bad content records
		
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE	@recorded		AS VARCHAR(50)
	DECLARE @sessionOrgID	AS INT
	DECLARE @intID			AS INT
	DECLARE @contentVar		AS NVARCHAR(MAX)
	DECLARE @CURSORID		AS INT
	DECLARE @itemProcessed	AS INT
	DECLARE @recordsDeleted AS INT
	DECLARE @badItems		AS INT
	DECLARE @code			AS NVARCHAR(20)
	DECLARE @Error			AS NVARCHAR(10)
	DECLARE @ErrorMessage	AS NVARCHAR(MAX)
	DECLARE @NameValuePairs AS NVARCHAR(MAX) 
    DECLARE @NameValuePair  AS NVARCHAR(100)
	DECLARE @Name           AS NVARCHAR(50)
	DECLARE @Value          AS NVARCHAR(50)
	DECLARE @id				AS INT
	DECLARE @Count			AS INT
	DECLARE @Property TABLE ([id] INT ,[Name] VARCHAR(50),[Value]  VARCHAR(50))
		
	SET @ErrorMessage	= '';
	SET @itemProcessed	= 0;
	SET @recordsDeleted	= 0;
	SET @badItems		= 0;
	SET @date			= SYSDATETIMEOFFSET();
	SET @UserId			= (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE @sessionKey = sessionKey)
	SET @sessionOrgID	= (SELECT orgid FROM dbo.tblsession WHERE sessionKey = @sessionKey )

	/* Summary :Create Temporary table(for Internal Use) */
	CREATE TABLE #TempScan1 (ID INT IDENTITY(1,1) NOT NULL,code NVARCHAR(Max))

    /* Summary:if Session[accessLevel] = SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW then do the following */ 
	IF(@accessLevel = 1 OR @accessLevel =3 OR @accessLevel =5 OR @accessLevel =7)
	BEGIN
		/* Summary:Raise an Error Message(400). If orgId parameter passed and user = OrgAdmin or OrgUser */
		IF(ISNULL(@orgId,'') <> '')
		BEGIN
			IF(@accessLevel = 5 OR @accessLevel=7)
			BEGIN
				SET @ReturnResult = '400|2853 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 2853)+'->'+convert(varchar,@orgId) 
				SELECT @ReturnResult AS Returnvalue
				RETURN;
			END
		END
		
		/*Summary:Raise an Error Message(400).If orgId is not passed and Session[accessLevel] is either SysAdminRW or  VarAdminRW */
		IF(ISNULL(@orgId,'') = '')
		BEGIN
			IF(@accessLevel = 1 OR @accessLevel=3)
			BEGIN
				SET @ReturnResult = '400|2852 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 2852)
				SELECT @ReturnResult AS Returnvalue
				RETURN;
			END
			ELSE IF(@accessLevel = 5 OR @accessLevel=7)
			BEGIN
			 SET @orgId=@sessionOrgID;
			END
		END
		
		/* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */
		IF NOT EXISTS(SELECT OrgId FROM dbo.tblOrganization WHERE OrgId = @orgId)
		BEGIN
			SET @ReturnResult = '400|2855 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 2855)+'->'+convert(varchar,@orgId)
			SELECT @ReturnResult AS Returnvalue
			RETURN;
		END
		
		/* Summary: Raise an error message (400). If contentData field not passed */
		IF(ISNULL(@delList,'') = '')
		BEGIN
			SET @ReturnResult = '400|2854 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 2854)
			 SELECT @ReturnResult AS Returnvalue
			RETURN;
		END
		SET @contentVar =REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(@delList,'{',''),'}',''),'"',''),'[',''),']','');
		INSERT INTO #TempScan1(code)Select items from Splitrow(@contentVar,',')
			
       /* Summary: If the Organization record is found, check if the user is authorized to make this request */
			/*  Summary: If accessLevel is SysAdminRW */
			/* Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of organization[OrgId] */
			/* Summary: If accessLevel is OrgAdminRW or OrgUserRW, then check if Session[OrgId] is the same as organization[OrgId] */
		           
		IF((@accessLevel = 1) OR ((@accessLevel = 3) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))) OR ((@accessLevel = 5 OR @accessLevel=7 ) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgID = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))))
		BEGIN
		 DECLARE Content_cursor CURSOR FOR SELECT t.ID FROM dbo.#TempScan1 t WITH(NOLOCK)
			  OPEN Content_cursor;  
			  FETCH NEXT FROM Content_cursor INTO @CURSORID;
			  WHILE @@FETCH_STATUS = 0  
				  BEGIN
				       	SELECT @NameValuePairs  = t.code from dbo.#TempScan1 t where t.ID = @CURSORID
						SET @id	= 1;
						SET @Name	= SUBSTRING(@NameValuePairs, 1, CHARINDEX(':', @NameValuePairs) - 1)
						SET @Value	= SUBSTRING(@NameValuePairs, CHARINDEX(':', @NameValuePairs) + 1, LEN(@NameValuePairs))
						SET @Name	= LTRIM(RTRIM(@Name))
                        SET @Value	= LTRIM(RTRIM(@Value))
                        SET @Code	= '';
						SET @itemProcessed = @itemProcessed + 1;
						
						/* Summary: To check the Label in json List  */  
						IF(LOWER(@Name) = 'code')
							SET @Code=@Value;
                        ELSE
                        BEGIN
                            SET  @Error='Error'; 
                            SET @ErrorMessage = @ErrorMessage+(select +'|2856 ' +Description +'|' +  FieldName  FROM dbo.tblErrorLog where ErrorCode= 2856)+ @Name + ',DataSet No->'+convert(varchar,@CURSORID)
                        END
                         /*
                         if code passed, use it to retrieve Content record  
                         if no match for code in Content add error message to errors return field and return JSON data with HTTP “400 Bad Request”  
                         if code not passed use passed orgId (or Session[orgId] if orgId not passed) to retrieve all matching Content records 
                         if no match for orgId in Content add error message to errors return field and return JSON data with HTTP “400 Bad Request”
                         */
						IF(ISNULL(@Error,'') = '')
						BEGIN  
							IF((ISNULL(@Code,'')<> ''  AND (EXISTS(SELECT CODE FROM dbo.tblcontent WHERE CODE=@Code AND OrgId=@orgId))))                   
							BEGIN
								SELECT @recorded = CONVERT(VARCHAR(50),Id)FROM dbo.tblContent c WHERE c.Code=@code AND c.OrgId=@orgId
								DELETE FROM dbo.[tblContent] WHERE CODE=@code AND OrgId=@orgId; 
								SET @recordsDeleted=@recordsDeleted+1;
								UPDATE [tblSession] SET lastActivity=SYSDATETIMEOFFSET() WHERE sessionKey=@sessionKey
								EXEC upi_UserActivity @UserId,@date,4,@recorded,17,'Delete'
								SET @recorded=''
							END
							ELSE
							BEGIN
								SET @badItems=@badItems+1;
								IF(ISNULL(@Code,'')= '')
								BEGIN
									SET @ErrorMessage = @ErrorMessage+(select +'|2858 ' +Description +'|' +  FieldName  FROM dbo.tblErrorLog where ErrorCode= 2858)+ ',DataSet No->'+convert(varchar,@CURSORID)
								END
								ELSE IF(NOT EXISTS(SELECT CODE FROM dbo.tblcontent WHERE CODE=@Code AND OrgId=@orgId))
								BEGIN
									SET @ErrorMessage = @ErrorMessage+(select +'|2857 ' +Description +'|' +  FieldName  FROM dbo.tblErrorLog where ErrorCode= 2857)+'->'+CONVERT(varchar,@Code) + ',DataSet No->'+CONVERT(varchar,@CURSORID)
								END
							END
						END  
					FETCH NEXT FROM Content_cursor INTO @CURSORID;
				 END
			  CLOSE Content_cursor;
			  DEALLOCATE Content_cursor;
		      SET @ReturnResult='200'
              SELECT @ReturnResult +'|itemsProcessed = '+CONVERT(varchar,@itemProcessed)+'|recordsDeleted = '+CONVERT(varchar,@recordsDeleted)+'|badItems = '+CONVERT(varchar,@badItems)+ @ErrorMessage  AS Returnvalue
              RETURN;
		END
		 /* Summary: Raise an Error Message.User not within scope*/
		ELSE
		BEGIN
			SET @ReturnResult = '401|2851 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 2851)+'->'+CONVERT(varchar,ISNULL(@accessLevel,'0'))
			SELECT @ReturnResult AS Returnvalue
			EXEC upi_SystemEvents 'Content',2851,3,@accessLevel
			RETURN;
	 	END
	END
	/* Summary:Raise an Error Message,if Session[accessLevel] != SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW */
	ELSE 
	BEGIN
		SET @ReturnResult = '401|2851 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 2851)+'->'+CONVERT(varchar,ISNULL(@accessLevel,'0'))
		SELECT @ReturnResult AS Returnvalue
		EXEC upi_SystemEvents 'Content',2851,3,@accessLevel
		RETURN;
	END
END
--exec upd_Content 'F1F2F3F4F5F6F7F8','631D4FDAA78BB96309B6CEDB4E90406E2E8963EE','1','[{"code":"Contentcode34"},{"code":"testcode2"}]'  
--exec upd_Content 'F1F2F3F4F5F6F7F8','94D7D740E7CB18105549228535C903844E00D458','1','[{"code":"TW55BDA"}]'


GO
/****** Object:  StoredProcedure [dbo].[upd_Interceptor]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================
-- Author:		iHorse
-- Create date: 24.05.2013
-- Routine:		Organization
-- Method:		Delete
-- Description:	Deletes an existing Interceptor record
-- ===================================================
CREATE PROCEDURE [dbo].[upd_Interceptor] 
	
	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@intId			AS INT
	
AS
BEGIN
--[upd_Interceptor] '4A79DB236006635250C7470729F1BFA30DE691D7','E97F6C87DB69225D62904F62264FAE25F972AA14',77836
	SET NOCOUNT ON;

	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @recorded		AS VARCHAR(50)
	
	SET @date = SYSDATETIMEOFFSET();
	SET @UserId =(SELECT userId FROM dbo.tblSession S WHERE sessionKey = @sessionKey)
	SET @accessLevel = (SELECT accessLevel FROM dbo.[tblSession] where @sessionKey = sessionKey)
	
	/* Summary: Raise an error message if an access level field is not SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW in the Session data store */
	IF(@accessLevel <> 1 AND @accessLevel <> 3 AND @accessLevel <> 5 AND @accessLevel <> 7 )
	BEGIN
		SET @ReturnResult = '401'
		EXEC upi_SystemEvents 'Interceptor',1852,3,@accessLevel
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
	
	/* Summary: Raise an error message if an interceptor id is not passed */
	IF((ISNULL(@intId,'') = ''))
	BEGIN
		SET @ReturnResult = '400|1853 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 1853)
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
	ELSE
	BEGIN
	/*Summary: Search the Interceptor record from the Interceptor data store by using Interceptor id */
		IF EXISTS (SELECT 1 FROM dbo.tblInterceptor WHERE IntId = @intId)
		BEGIN
		/*Summary: Search matching record in Interceptor Data Store using passed Interceptor id */
			IF EXISTS (SELECT 1 FROM dbo.tblOrganization O JOIN tblInterceptor I ON O.OrgId=I.OrgId WHERE I.IntId=@intId)
			BEGIN
			/*Summary: Checking if accessLevel is SysAdminRW or 
					If Session[OrgId] matches Organization[owner] when accesslevel is VarAdminRW or
					If Session[OrgId] is the same as Organization[orgId] when accesslevel is either OrgAdminRW or OrgUserRW*/
					--[upd_Interceptor] 'A1A2A3A4A5A6A7A8','t234567891234567891234567891234567891234',36
				IF((@accessLevel = 1) OR 
				((@accessLevel =3) AND (EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.Owner=S.OrgId INNER JOIN tblInterceptor I ON I.OrgId = O.OrgId WHERE S.SessionKey = @sessionKey AND I.IntId=@intId))) OR
				((@accessLevel = 5 OR @accessLevel = 7 ) AND (EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.OrgId=S.OrgId INNER JOIN tblInterceptor I ON I.OrgId = O.OrgId WHERE S.SessionKey = @sessionKey and I.IntId = @intId))))
				BEGIN
					/* Summary: Raise an error message if an Interceptor[deviceStatus] field is not ‘deactivated’ */
					IF EXISTS (SELECT 1 FROM dbo.tblInterceptor WHERE IntId = @intId AND ISNULL(DeviceStatus,0) <> 2)
					BEGIN
						SET @ReturnResult = '400|1857 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1857)+convert(varchar,@intId)
						SELECT @ReturnResult AS ReturnData
						RETURN;
					END
					ELSE IF EXISTS (SELECT 1 FROM dbo.tblInterceptor WHERE IntId = @intId AND ISNULL(DeviceStatus,0) = 2)
					BEGIN
						SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId) FROM dbo.tblInterceptor WHERE IntId=@intId
						EXEC upi_ArchivedInterceptor @intId,@date
						DELETE tblInterceptor WHERE IntId=@intId
						UPDATE tblSession SET lastActivity = @date WHERE sessionKey = @sessionKey
						EXEC upi_UserActivity @UserId,@date,4,@recorded,4,'Delete'
						SET @ReturnResult = '200'
						SELECT @ReturnResult AS ReturnData
						RETURN;
					END
				END
				ELSE
				BEGIN
					/* Summary: Raise an error message if passed locId have no matching record*/
					IF(@accessLevel =3 OR @accessLevel =5 OR @accessLevel =7)
					BEGIN
						SET @ReturnResult = '401|1854 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1854)+convert(varchar,@intId)
						EXEC upi_SystemEvents 'Interceptor',1854,3,@intId
						SELECT @ReturnResult AS ReturnData
					END
				END
			END
			ELSE
			BEGIN
				/* Summary: Raise an error message if passed intId have no matching record in Organization Data Store*/
				SET @ReturnResult = '400|1858 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1858)+convert(varchar,@intId)
				EXEC upi_SystemEvents 'Interceptor',1858,3,@intId
				SELECT @ReturnResult AS ReturnData
				RETURN;
			END
		END
		ELSE
		BEGIN
			/* Summary: Raise an error message if passed intId have no matching record in Interceptor Data Store*/
			SET @ReturnResult = '400|1858 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1858)+convert(varchar,@intId)
			SELECT @ReturnResult AS ReturnData
			RETURN;
		END
	END
END

--[upd_Interceptor] 'BFD81EE3ED27AD31C95CA75E21365973','4AE4D7D24BE791F89A76FE551A2DFF15',8


GO
/****** Object:  StoredProcedure [dbo].[upd_InterceptorID]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================
-- Author:		iHorse	
-- Create date: 05.06.2013
-- Routine:		InterceptorID
-- Method:		DELETE	
-- Description:	deletes an existing InterceptorID record
-- =======================================================

CREATE PROCEDURE [dbo].[upd_InterceptorID] 

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@IntSerial	    AS VARCHAR(12)

AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @UserId			AS VARCHAR(5)
	
	SET @UserId			= (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	SET @date			= SYSDATETIMEOFFSET();
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] where @sessionKey = sessionKey)
	
	/*Summary:If the accessLevel is not SysAdminRW, then send a HTTP response “401 Unauthorised*/
	IF(@accessLevel = 1)
	BEGIN
		/*Summary:Check if the idList field is passed,if not passed return error:400 Bad Request*/
		IF(ISNULL(@IntSerial,'') = '')
		BEGIN
		    SET @ReturnResult = '400|2553 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 2553)
		END	
		ELSE
		BEGIN
		/*Summary:if intSerial in use by any Interceptor record (cannot delete an InterceptorID
			record if the interceptor serial number is still in use)
			If error set:Return Error 400 Bad Request */
			IF EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial=@IntSerial) OR EXISTS(SELECT 1 FROM dbo.tblDeviceScan WHERE IntSerial=@IntSerial)
			OR EXISTS(SELECT 1 FROM dbo.tblDeviceStatus WHERE IntSerial=@IntSerial)OR EXISTS(SELECT 1 FROM dbo.tblScanBatches WHERE IntSerial=@IntSerial)
			BEGIN
				 SET @ReturnResult = '400|2554 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 2554)+convert(varchar,@IntSerial)
			END
			ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM dbo.tblInterceptorID WHERE IntSerial=@IntSerial) 
					BEGIN
						IF(@ReturnResult LIKE '%|%')
						BEGIN
							SELECT @ReturnResult AS ReturnData
							RETURN;
						END
						ELSE
						BEGIN
							DELETE FROM dbo.tblInterceptorID WHERE IntSerial=@IntSerial
							UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
							EXEC upi_UserActivity @UserId,@date,4,@IntSerial,5,'Delete'
							SET @ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
						END
					END
					ELSE
					BEGIN
						SET @ReturnResult = '400|2555 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 2555)+convert(varchar,@IntSerial)
					END
				END
		END
	END
	ELSE
	BEGIN
		 SET @ReturnResult = '401' SELECT @ReturnResult AS Returnvalue
		 EXEC upi_SystemEvents 'InterceptorID',2551,3,@accessLevel
		 RETURN;
	END
	IF(@ReturnResult LIKE '%|%')
	BEGIN
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
END
--EXEC upd_InterceptorID 'A1A2A3A4A5A6A7A8','1F57AADAF59DC22E2EECF4E974A35D20','1111100000'
--EXEC upd_InterceptorID '4A79DB236006635250C7470729F1BFA30DE691D1','CF5CA2271E9507985CCB42F6F3C2F02A7BBE2C9D','SN0000111122'


GO
/****** Object:  StoredProcedure [dbo].[upd_Location]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrews S
-- Create date: 20.05.2013
-- Routine:		Location
-- Method:		Delete
-- Description:	Deletes a Location record
-- =============================================
CREATE PROCEDURE [dbo].[upd_Location] 

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@locId			AS INT
	
AS
BEGIN
	SET NOCOUNT ON;	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success	
	
	-- Local variables descriptions	
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @recorded		AS VARCHAR(50)
	
	SET @date			= SYSDATETIMEOFFSET();
	SET @accessLevel	= (SELECT AccessLevel FROM dbo.[tblSession] where sessionKey= @sessionKey )	
	SET @UserId			= (SELECT UserId FROM dbo.[tblSession] where sessionKey= @sessionKey )
	
	/*Summary: Raise an error message if accessLevel is not SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW*/
	IF(@accessLevel=2 OR @accessLevel=4 OR @accessLevel=6 OR @accessLevel=8)
	BEGIN
		SET @ReturnResult = '401'
		EXEC upi_SystemEvents 'Location',1656,3,@accessLevel
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
	ELSE
	/*Summary: Raise an error message if locId is not passed*/
	IF(@locId =0)
	BEGIN
		SET @ReturnResult = '400|1658 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog where ErrorCode= 1658)
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END	
	ELSE IF(@locId <>0)
	BEGIN
			/*Summary: Check if the passed locId have a matching record in Location Data Store*/
			IF EXISTS (SELECT 1 FROM dbo.[tblLocation] WHERE LocId = @locId)
			BEGIN
			/*Summary: Check if the passed locId have a matching record in Organization Data Store*/
						IF EXISTS(SELECT 1 FROM dbo.[tblOrganization] WHERE OrgId=(SELECT OrgId FROM dbo.[tblLocation] WHERE LocId=@locId))
						BEGIN
								IF(@accessLevel=1)
								BEGIN
								/*Summary: Raise an eror messge if the passed locId have a matching record in Interceptor Data Store*/
									IF EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WHERE LocId=@locId)
									BEGIN
										SET @ReturnResult = '400|1657 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1657)+convert(varchar,@locId)
										SELECT @ReturnResult AS ReturnData
										RETURN;
									END
									ELSE
									BEGIN
										/*Summary: Using the passed locId delete the matching record in Location Data Store*/
										SET @recorded = (SELECT LocId FROM dbo.[tblLocation] WHERE LocId=@locId)
										DELETE FROM dbo.[tblLocation] WHERE LocId=@locId
										UPDATE tblSession SET lastActivity = @date WHERE sessionKey = @sessionKey
										EXEC upi_UserActivity @UserId,@date,4,@recorded,2,'Delete'
										SET @ReturnResult = '200'
										SELECT @ReturnResult AS ReturnData
										RETURN;										
									END		
								END
								IF(@accessLevel=3)
								BEGIN
									IF EXISTS(SELECT 1 FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON L.OrgId = O.OrgId WHERE S.SessionKey = @sessionKey AND L.LocId = @locId)
									BEGIN
										/*Summary: Raise an eror messge if the passed locId have a matching record in Interceptor Data Store*/
										IF EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WHERE LocId=@locId)
										BEGIN
											SET @ReturnResult = '400|1657 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1657)+convert(varchar,@locId)
											SELECT @ReturnResult AS ReturnData
											RETURN;
										END
										ELSE
										BEGIN
										/*Summary: Using the passed locId delete the matching record in Location Data Store*/
											SET @recorded = (SELECT LocId FROM dbo.[tblLocation] WHERE LocId=@locId)
											DELETE FROM dbo.[tblLocation] WHERE LocId=@locId
											UPDATE tblSession SET lastActivity = @date WHERE sessionKey = @sessionKey
											EXEC upi_UserActivity @UserId,@date,4,@recorded,2,'Delete'
											SET @ReturnResult = '200'
											SELECT @ReturnResult AS ReturnData
											RETURN;										
										END		
									END
									ELSE
									BEGIN
										SET @ReturnResult = '401|1656 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1656)+convert(varchar,@locId)
										EXEC upi_SystemEvents 'Location',1656,3,@accessLevel
										SELECT @ReturnResult AS ReturnData
										RETURN;
									END	
								END	
								IF(@accessLevel=5 OR @accessLevel=7)
								BEGIN
									IF EXISTS(SELECT 1 FROM dbo.tblSession S WHERE S.OrgId = (SELECT OrgId FROM dbo.[tblLocation] WHERE LocId=@locId) AND S.SessionKey = @sessionKey)
									BEGIN
										/*Summary: Raise an eror messge if the passed locId have a matching record in Interceptor Data Store*/
										IF EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WHERE LocId=@locId)
										BEGIN
											SET @ReturnResult = '400|1657 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1657)+convert(varchar,@locId)
											SELECT @ReturnResult AS ReturnData
											RETURN;
										END
										ELSE
										BEGIN
											/*Summary: Using the passed locId delete the matching record in Location Data Store*/
											SET @recorded = (SELECT LocId FROM dbo.[tblLocation] WHERE LocId=@locId)
											DELETE FROM dbo.[tblLocation] WHERE LocId=@locId
											UPDATE tblSession SET lastActivity = @date WHERE sessionKey = @sessionKey
											EXEC upi_UserActivity @UserId,@date,4,@recorded,2,'Delete'
											SET @ReturnResult = '200'
											SELECT @ReturnResult AS ReturnData
											RETURN;																						
										END		
									END
									ELSE
									BEGIN
										SET @ReturnResult = '401|1656 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1656)+convert(varchar,@locId)
										--EXEC upi_SystemEventsdata 'Location',1656,3
										EXEC upi_SystemEvents 'Location',1656,3,@accessLevel
										SELECT @ReturnResult AS ReturnData
										RETURN;
									END			
								END	
						END
						ELSE
						BEGIN
							/*Summary: Raise an error message if there is no match in Organization Data Store*/
							SET @ReturnResult = '400|1655 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1655)+convert(varchar,@locId)
							EXEC upi_SystemEvents 'Location',1655,3,@locId
							SELECT @ReturnResult AS ReturnData
						END					
			END
			ELSE
			BEGIN
				/*Summary: Raise an error message if there is no match in Location Data Store*/
				SET @ReturnResult = '400|1654 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode= 1654)+convert(varchar,@locId)
				SELECT @ReturnResult AS ReturnData
			END
	END
END
--[upd_Location] 'A1A2A3A4A5A6A7A8','5EDBCF0BFB5C3C4B942FAAC335F1B178','5'


GO
/****** Object:  StoredProcedure [dbo].[upd_Organization]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:		iHorse
-- Create date: 26.04.2013
-- Routine:		Organization
-- Method:		Delete
-- Description:	Deletes an existing Organization record
-- =====================================================
CREATE PROCEDURE [dbo].[upd_Organization] 

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@orgId			AS INT
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @Date used to store the current date and time from the SQL Server
	-- @AccessLevel used to store AccessLevel value
	-- @Recorded id of record accessed by user
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @Date			AS DATETIMEOFFSET(7)
	DECLARE @AccessLevel	AS INT
	DECLARE	@Recorded		AS VARCHAR(100)
	
	SET @Date			= SYSDATETIMEOFFSET();
	SET @UserId			= (SELECT userId FROM dbo.tblSession S WHERE sessionKey = @sessionKey)
	SET @AccessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	
	/* Summary:Set orgId to zero if orgId is null or empty */
	IF(ISNULL(@orgId,'') = '') SET @orgId = 0;
	
	/* Summary: Raise an error message If mandatory field organization id is not supplied. */
	IF (@orgId = 0)
	BEGIN
		SET @ReturnResult = '400|1451 '+(SELECT Description +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1451)
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
	ELSE 
	/* Summary: Raise an error message if an access level field is NOT SysAdminRW or VarAdminRW */
	IF(@AccessLevel != 1 AND @AccessLevel != 3)
	BEGIN
		SET @ReturnResult = '401|1452 '+(SELECT Description +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1452)+'->'+convert(varchar,@orgId)
		EXEC upi_SystemEvents 'Organization',1452,3,@accessLevel
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
	/* Summary: Check if the passed orgId is in the organization table or not.*/
	IF EXISTS (SELECT 1 FROM dbo.tblOrganization WHERE orgID = @orgId)
	BEGIN
	/* Summary: Raise an error message (401). If there is no match among Organization[owner] against session[orgId] tables for the given organization[orgId]. */
		IF (@AccessLevel=1 OR(EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.[Owner] = S.OrgId WHERE O.OrgId = @orgId AND S.SessionKey = @sessionKey AND @AccessLevel=3)))
		BEGIN
		/* Summary: Raise an error message (400). If there is a match among the tables Location,User and Interceptor for the given Organization. */
			IF (EXISTS (SELECT OrgId FROM dbo.tblInterceptor WHERE orgID = @orgId) OR EXISTS(SELECT OrgId FROM dbo.tblUser WHERE orgID = @orgId) 
			OR EXISTS (SELECT OrgId FROM dbo.tblLocation WHERE orgID = @orgId))
			BEGIN
				SET @ReturnResult = '400|1453 '+(SELECT Description +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1453)+'->'+convert(varchar,@orgId)
				EXEC upi_SystemEvents 'Organization',1453,3,@orgId
				SELECT @ReturnResult AS ReturnData
				RETURN;
			END
			ELSE
			BEGIN
				/* Summary: Create a new ArchivedOrg record using all the data from the Organization table. 
				In addition to these fields, add a field ‘canDate’ and set it to the current date/time.
				Delete Organization record from Organization table using @orgId
				Create a new record under UserActivity table and return a string '200' for successfully deleted the organization record from the organization table.*/
				
				SET @Recorded = (SELECT OrgId FROM dbo.tblOrganization WHERE orgId = @orgId)
				SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId)FROM dbo.tblOrganization O WHERE orgId = @orgId
				EXEC upi_ArchivedOrg @orgId, @Date
				DELETE tblOrganization WHERE orgId = @orgId
				UPDATE tblSession SET lastActivity = @Date WHERE sessionKey = @sessionKey
				EXEC upi_UserActivity @UserId,@Date,1,@Recorded,4,'Delete'
				SET @ReturnResult = '200'
				SELECT @ReturnResult AS ReturnData
				RETURN;
			END
		END
		ELSE
		BEGIN
			SET @ReturnResult = '401|1452 '+(SELECT Description +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1452)+'->'+convert(varchar,@accessLevel)
			EXEC upi_SystemEvents 'Organization',1452,3,@accessLevel
			SELECT @ReturnResult AS ReturnData
			RETURN; 
		END
	END
	ELSE
	BEGIN
		/* Summary: Raise an error message (400) if there is no matching record for the passed orgId in the organization table.*/
		SET @ReturnResult = '400|1454 '+(SELECT Description +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1454)+'->'+convert(varchar,@orgId)
		EXEC upi_SystemEvents 'Organization',1454,3,@orgId
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
END
--[upd_Organization] 'A1A2A3A4A5A6A7A8','3B8D032C7FDDFEFDC66802F2CE67B90F',16


GO
/****** Object:  StoredProcedure [dbo].[upd_User]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Indhumathi T
-- Create date: 03.05.2013
-- Routine:		User
-- Method:		Delete
-- Description:	Deletes a User record
-- =============================================
CREATE PROCEDURE [dbo].[upd_User] 

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@userId			AS VARCHAR(5)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions	-- @ReturnResult used to return results
	-- @date used to store the current date and time FROM the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @eventData used to store event data description
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @LIUserID		AS VARCHAR(5)
	DECLARE @recorded		AS VARCHAR(100)
	
	SET @LIUserID	= (SELECT UserId FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	SET @date		= SYSDATETIMEOFFSET();
	SET @accessLevel= (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	
	IF(@accessLevel = 2 OR @accessLevel =4 OR @accessLevel =6  OR @accessLevel =7  OR @accessLevel =8)
	BEGIN
		SET @ReturnResult = '401'
		EXEC upi_SystemEvents 'User',1262,3,@accessLevel
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
			
	IF EXISTS (SELECT 1 FROM dbo.[tblUser] WHERE userId = @userId)
	BEGIN
		/* Summary: If accessLevel is SysAdminRW, then delete the User and return a string '200' and make an entry in ArchivedUser and UserActivity data stores. */
		/* Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of User[OrgId] 
				If it is true delete the User and return a string '200' and make an entry in ArchivedUser and UserActivity data stores.
				If not true then check if Session[OrgId] is the same as User[OrgId]. 
					If it is true then delete the User and return a string '200'. If not true then return a string '401' and logged in the SystemEvents data store.*/
		/* Summary: If accessLevel is OrgAdminRW, then check if Session[OrgId] is the same as User[OrgId].
					If it is true then delete the User and return a string '200' and make an entry in ArchivedUser and UserActivity data store. 
					If it is not true then return a string '401' and logged in the SystemEvents data store.*/
		IF((@accessLevel = 1) OR
		((@accessLevel = 3) AND EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblUser U ON O.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey and U.UserId = @userId )) OR
		((@accessLevel = 3) AND (NOT EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblUser U ON O.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey and U.UserId = @userId )) AND
		(EXISTS (SELECT S.OrgId FROM dbo.tblSession S INNER JOIN tblUser U ON S.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey AND U.UserId=@userId))) OR
		((@accessLevel = 5) and (@userId in(SELECT u.UserId FROM dbo.tblSession S INNER JOIN tblUser U ON S.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey ))))
		BEGIN
		--[upd_User] 'B1B2B3B4B5B6B7B8','2075D91F997797D9AADC628B7F87A1D1FD93F099','779KS'
			IF ((EXISTS (SELECT 1 FROM dbo.tblSession S INNER JOIN tblUser U ON S.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey AND @userId = s.UserId)))
			BEGIN
				SET @ReturnResult = '400|1259 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1259)+CONVERT(VARCHAR,@userId)
				SELECT @ReturnResult AS ReturnData
				RETURN;
			END
			ELSE IF(EXISTS (SELECT 1 FROM dbo.tblSession S WHERE S.UserId = @userId))
			BEGIN
				SET @ReturnResult = '400|1260 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1260)+CONVERT(VARCHAR,@userId)
				SELECT @ReturnResult AS ReturnData
				RETURN;
			END
			ELSE
			BEGIN
				SET @recorded = (SELECT UserId FROM dbo.[tblUser] WHERE userId = @userId)
				EXEC upi_ArchivedUsers @userId,@date
				DELETE [tblUser] WHERE userId = @userId
				UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
				EXEC upi_UserActivity @LIUserID,@date,4,@recorded,3,'Delete'
				SET @ReturnResult = '200'	
				SELECT @ReturnResult AS ReturnData
				RETURN;
			END
		END
		ELSE
		BEGIN
			IF(@accessLevel = 3 OR @accessLevel =5)
			BEGIN
				SET @ReturnResult = '401|1262 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1262)+CONVERT(VARCHAR,@accessLevel)
				EXEC upi_SystemEvents 'User',1262,3,@accessLevel
				SELECT @ReturnResult AS ReturnData
				RETURN;
			END
		END
	END
	ELSE
	BEGIN
	/* Summary: Raise an error message if User records not found in the User data store for the given user. */
		SET @ReturnResult = '400|1259 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1259)+CONVERT(VARCHAR,@userId)
		EXEC upi_SystemEvents 'User',1259,3,@userId
		SELECT @ReturnResult AS ReturnData
		RETURN;
	END
END
--[upd_User] '4A79DB236006635250C7470729F1BFA30DE691D7','1234567891234567891234567891234567891234','01111'
--[upd_User] 'B1B2B3B4B5B6B7B8','2075D91F997797D9AADC628B7F87A1D1FD93F099','779KS'


GO
/****** Object:  StoredProcedure [dbo].[upi_ArchivedInterceptor]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		iHorse
-- Create date: 24.05.2013
-- Routine:		Common Stored Procedure for all routines
-- Method:		Post
-- Description:	Create a new Archived Interceptor record
-- ==================================================================
CREATE PROCEDURE [dbo].[upi_ArchivedInterceptor]

		@intId		AS INT,
		@canDate	AS DATETIMEOFFSET(7)
		
AS
BEGIN

	SET NOCOUNT ON;
	
	INSERT INTO tblArchivedInterceptor (IntId,IntSerial,OrgId,LocId,ForwardURL,DeviceStatus,StartURL,ReportURL,ScanURL,BkupURL,
		Capture,CaptureMode,RequestTimeoutValue,CallHomeTimeoutMode,CallHomeTimeoutData,DynCodeFormat,Security,ErrorLog,WpaPSK,
		SSId,CmdURL,CmdChkInt,CanDate)
	SELECT I.IntId,I.IntSerial,I.OrgId,I.LocId,I.ForwardURL,I.DeviceStatus,I.StartURL,I.ReportURL,I.ScanURL,I.BkupURL,
		I.Capture,I.CaptureMode,I.RequestTimeoutValue,I.CallHomeTimeoutMode, I.CallHomeTimeoutData, I.DynCodeFormat, I.Security, I.ErrorLog,I.WpaPSK,
		I.SSId,I.CmdURL,I.CmdChkInt,@canDate
	FROM dbo.tblInterceptor I WHERE I.IntId = @intId
	
END


GO
/****** Object:  StoredProcedure [dbo].[upi_ArchivedOrg]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		iHorse
-- Create date: 26.04.2013
-- Routine:		Common Stored Procedure for all routines
-- Method:		Post
-- Description:	Create a new Archived Organization record
-- ==================================================================
CREATE PROCEDURE [dbo].[upi_ArchivedOrg]
	
	@orgId		AS INT,
	@canDate	AS DATETIMEOFFSET(7)
	
AS
BEGIN

	SET NOCOUNT ON;
	
	INSERT INTO tblArchivedOrg (OrgID,OrgName,applicationKey,ipAddress,owner,canDate)
	SELECT orgId,orgName,applicationKey,ipAddress,owner, @canDate FROM dbo.tblOrganization WHERE orgID = @orgId
	
END


GO
/****** Object:  StoredProcedure [dbo].[upi_ArchivedUsers]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		iHorse
-- Create date: 03.05.2013
-- Routine:		Common Stored Procedure for all routines
-- Method:		Post
-- Description:	Create a new Archived Users record
-- ==================================================================
CREATE PROCEDURE [dbo].[upi_ArchivedUsers]

		@userId		AS VARCHAR(5),
		@canDate	AS DATETIMEOFFSET(7)
		
AS
BEGIN

	SET NOCOUNT ON;
	
	INSERT INTO tblArchivedUser (userId,orgID,[password],firstName,lastName,regDate,accessLevel,canDate)
	SELECT a.userId,a.orgID,a.password,a.firstName,a.lastName,a.regDate,a.accessLevel,@canDate FROM dbo.tblUser a WHERE a.UserId = @userId
END


GO
/****** Object:  StoredProcedure [dbo].[upi_Authenticate]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dinesh
-- Create date:	15.04.2013
-- Routine:		Authenticate
-- Method:		POST
-- Description:	Insert User Session Records
-- =============================================
CREATE PROCEDURE [dbo].[upi_Authenticate] 

	@applicationKey AS VARCHAR(40),
	@orgId			AS INT,
	@userId			AS VARCHAR(5),
	@password		AS VARCHAR(40),
	@timeout		AS INT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @md5SessionKey used to set MD5 hexdigest session key
	-- @ReturnResult used to return results
	-- @sessiontime used to get default time out
	-- @eventData used to store event data description
	-- @IsExist used to find record already exist

	DECLARE @md5SessionKey			AS VARCHAR(150)
	DECLARE @ReturnResult			AS VARCHAR(100)
	DECLARE @sessiontime			AS INT
	DECLARE @IsExist				AS INT
	DECLARE @tmpOrgId				AS INT
	DECLARE @tmpOrgApplicationkey	AS VARCHAR(40)
	DECLARE @tmpUserId				AS VARCHAR(5)
	DECLARE @tmpUserOrgId			AS INT
	DECLARE @tmpUserAccessLevel		AS INT
	DECLARE @tmpUserPassword		AS VARCHAR(40)
	DECLARE @date					AS DATETIMEOFFSET(7)
	DECLARE	@recorded				AS INT
	DECLARE @useridandpasswrd       AS VARCHAR(100)
	
	SET @recorded	= (SELECT O.OrgId FROM dbo.tblOrganization O WHERE O.ApplicationKey = @applicationKey)
	SET @password	= CONVERT(VARCHAR(40),HashBytes('SHA1',@password),2); 
	SET @date		= SYSDATETIMEOFFSET()
	
	SET @sessiontime = (SELECT CASE 
	WHEN @timeout BETWEEN 300 and 1800 THEN @timeout
	WHEN @timeout IS NULL OR @timeout= 0 THEN 900
	WHEN @timeout < 300 THEN 400
	WHEN @timeout > 1800 THEN 400
	ELSE 900 END)
	
	IF(@sessiontime = 400)
	BEGIN
		SET @ReturnResult = '400';
		EXEC upi_SystemEvents 'Authenticate',1008,3,@sessiontime
		SELECT @ReturnResult AS ReturnData1;
		RETURN;
	END
	
	IF(@applicationkey = '' OR @applicationkey IS NULL)
	BEGIN
		SET @ReturnResult = '400';
		EXEC upi_SystemEvents 'Authenticate',1009,3,@applicationkey
		SELECT @ReturnResult AS ReturnData1;
		RETURN;
	END	
	
	/* To check orgId is Empty Return Error:400 Bad Request 
	   if above condition fail Pass orgId to get Matching Organization Record,If No Record found Return Error:401 unauthorised*/
	IF(@applicationkey = 'public')
	BEGIN
		IF (@orgid='' OR @orgid IS NULL)
		BEGIN
			SET @ReturnResult = '400';
			EXEC upi_SystemEvents 'Authenticate',1000,3,@orgid
			SELECT @ReturnResult AS ReturnData2;
			RETURN;
		END
	    ELSE IF EXISTS (SELECT 1 FROM dbo.tblOrganization WHERE orgID=@orgid)
		BEGIN
			SELECT @tmpOrgId =[OrgId],@tmpOrgApplicationkey =ApplicationKey FROM dbo.tblOrganization WHERE orgID=@orgid
		END
		ELSE
		BEGIN
			SET @ReturnResult = '400';
			EXEC upi_SystemEvents 'Authenticate',1001,3,@orgid
			SELECT @ReturnResult AS ReturnData;
			RETURN;
		END
	END
	
	/* use the applicationKey to search for the Organization record, Matching Organization Record is not found Return Error:400 Bad Request*/
	ELSE IF(@applicationkey <> 'public')
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.tblOrganization WHERE ApplicationKey=@applicationKey)
		BEGIN
			SELECT @tmpOrgId =[OrgId],@tmpOrgApplicationkey =ApplicationKey FROM dbo.tblOrganization WHERE ApplicationKey=@ApplicationKey	
		END
		ELSE
		BEGIN
			SET @ReturnResult = '400';
			EXEC upi_SystemEvents 'Authenticate',1010,3,@applicationKey
			SELECT @ReturnResult AS ReturnData4;
			RETURN;
		END
	END
  /*Use passed userid to get User Record , If record not found return Error:400 Bad Request*/
	IF EXISTS (SELECT 1 FROM dbo.tblUser WHERE UserId=@userId)
	BEGIN
		SELECT @tmpUserId = [userId],@tmpUserOrgId =[orgID],@tmpUserAccessLevel=[accessLevel],
		@tmpUserPassword  = [Password] FROM dbo.tblUser WHERE userId=@userid			
	END
	ELSE
	BEGIN
		SET @ReturnResult = '400';
		EXEC upi_SystemEvents 'Authenticate',1025,3,@userId
		SELECT @ReturnResult AS ReturnResult1;
		RETURN;
	END
  
    /*Check Organizaion's orgID against User[OrgId] AND passed userId and password against the User*/
   /*To get sessionkey an MD5 hexdigest – 32 characters*/ 
 
	SET @md5SessionKey = CONVERT(VARCHAR(40),HashBytes('SHA1',(CAST(@userid AS VARCHAR(30)) +'|'+CONVERT(VARCHAR(26), SYSDATETIMEOFFSET(), 109))),2);          --CONVERT(VARCHAR(32),HashBytes('MD5', 'Value1'),2) 
	IF(@tmpOrgId=@tmpUserOrgId)
		BEGIN
			IF (@tmpUserId = @userid AND @tmpUserPassword=@password)
			BEGIN
				INSERT INTO [tblSession] (sessionKey,lastActivity,[timeout],userId,orgID,accessLevel) 
				SELECT @md5SessionKey,SYSDATETIMEOFFSET(),@sessiontime,@tmpUserId ,@tmpUserOrgId,@tmpUserAccessLevel  
				IF (@applicationkey <> 'public') SELECT @md5SessionKey AS sessionKey
				ELSE
				SELECT @md5SessionKey+'|'+@tmpOrgApplicationkey AS applicationkey
				EXEC upi_UserActivity @UserId,@date,1,@recorded,0,'Create'
			END
			ELSE
			BEGIN
				SET @ReturnResult = '400';
				SET @useridandpasswrd=@userid+','+@password
				EXEC upi_SystemEvents 'Authenticate',1029,3,@useridandpasswrd
				SELECT @ReturnResult AS ReturnResult2;
				RETURN;
			END
		END
	ELSE
	BEGIN
		SET @ReturnResult = '401';
		EXEC upi_SystemEvents 'Authenticate',1014,3,@orgid
		SELECT @ReturnResult AS ReturnResult
		RETURN;
	END
END
/****** Script for SelectTopNRows command FROM SSMS  ******/
--[upi_Authenticate] 'C1C2C3C4C5C6C7C8',2,'001RW',password,1800
--[upi_Authenticate] ''' or 1=1 and Rownum=1 --',0,'SPU01',Password,300


GO
/****** Object:  StoredProcedure [dbo].[upi_Content]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prakash G
-- Create date: 06.06.2013
-- Routine:		Content
-- Method:		POST 
-- Description:	Creates a new Content record
-- =============================================
CREATE PROCEDURE [dbo].[upi_Content] 
	
	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgId				AS INT,
	@contentData		AS NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 201 - Created
	    
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time FROM the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @eventData used to store event data description
	-- @sessionOrgID used to store the session OrgID
	-- @contentID used to store the content ID
	-- @contentVar used to store the contentdata
	-- @CURSORID used to cursor
	-- @itemProcessed used to COUNT the content records
	-- @recordsCreated used to COUNT the good content records
	-- @badItems  used to COUNT the Bad content records
		
	DECLARE @ReturnResult		AS NVARCHAR(MAX)
	DECLARE @UserId				AS VARCHAR(5)
	DECLARE @date				AS DATETIMEOFFSET(7)
	DECLARE @accessLevel		AS INT
	DECLARE @sessionOrgID		AS INT
	DECLARE @contentID			AS INT
	DECLARE @contentVar			AS NVARCHAR(MAX)
	DECLARE @CURSORID			AS INT
	DECLARE @itemProcessed		AS INT
	DECLARE @recordsCreated		AS INT
	DECLARE @badItems			AS INT
	DECLARE @DESCRIPTION		AS NVARCHAR(500)
	DECLARE	@Code				AS VARCHAR(20)
	DECLARE @Category			AS NVARCHAR(60)
	DECLARE @Model				AS NVARCHAR(60)
	DECLARE @Manufacturer		AS NVARCHAR(60)
	DECLARE @PartNumber			AS NVARCHAR(60)
	DECLARE @ProductLine		AS NVARCHAR(60)
	DECLARE @ManufacturerSKU	AS VARCHAR(50)
	DECLARE @UnitMeasure		AS VARCHAR(15)
	DECLARE @UnitPrice			AS VARCHAR(50) 
	DECLARE @Misc1				AS NVARCHAR(100)
	DECLARE @Misc2				AS NVARCHAR(100)
	DECLARE @Error				AS NVARCHAR(10)
	DECLARE @ErrorMessage		AS NVARCHAR(MAX)
	DECLARE @NameValuePairs		AS VARCHAR(MAX) 
    DECLARE @NameValuePair		AS VARCHAR(100)
	DECLARE @Name				AS VARCHAR(100)
	DECLARE @Value				AS VARCHAR(100)
	DECLARE @id					AS INT
	DECLARE @Count				AS INT
	DECLARE @Property TABLE ([id] INT ,[Name]  VARCHAR(100),[Value] VARCHAR(100))
	
	SET @itemProcessed	= 0;
	SET @recordsCreated = 0;
	SET @badItems		= 0;
	SET @ErrorMessage	= '';
	SET @contentData	= REPLACE(@contentData,'\','');
	SET @date			= SYSDATETIMEOFFSET();
	SET @UserId			= (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE @sessionKey = sessionKey)
	SET @sessionOrgID	= (SELECT orgid FROM dbo.tblsession WHERE sessionKey = @sessionKey )
	
	/* Summary :Create Temporary table(for Internal Use) */
	CREATE TABLE #TempScan (ID INT IDENTITY(1,1) NOT NULL,contentData NVARCHAR(Max))
	
	/* Summary:if Session[accessLevel] = SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW then do the following */ 
	IF(@accessLevel = 1 OR @accessLevel =3 OR @accessLevel =5 OR @accessLevel =7)
	BEGIN
		/* Summary:Raise an Error Message(400). If orgId parameter passed and user = OrgAdmin or OrgUser */
		IF(ISNULL(@orgId,'') <> '')
		BEGIN
			IF(@accessLevel = 5 OR @accessLevel=7)
			BEGIN
				SET @ReturnResult = '400|2803 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2803)+'->'+CONVERT(VARCHAR,@orgId)
				SELECT @ReturnResult AS Returnvalue
				RETURN;
			END
		END
		
		/*Summary:Raise an Error Message(400).If orgId is not passed and Session[accessLevel] is either SysAdminRW or  VarAdminRW */
		IF(ISNULL(@orgId,0) = 0)
		BEGIN
			IF(@accessLevel = 1 OR @accessLevel=3)
			BEGIN
				IF(ISNULL(@orgId,0) = 0 AND ISNULL(@contentData,'') = '')
				BEGIN
					SET @ReturnResult = '400|2802 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2802)  --+'->'+CONVERT(VARCHAR,@orgId)
					SELECT @ReturnResult AS Returnvalue
					RETURN;
				END
				ELSE IF(ISNULL(@orgId,0) = 0)
				BEGIN
					SET @ReturnResult = '400|2812 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2812)  --+'->'+CONVERT(VARCHAR,@orgId)
					SELECT @ReturnResult AS Returnvalue
					RETURN;
				END
			END
			ELSE IF(@accessLevel = 5 OR @accessLevel=7)
			BEGIN
				SET @orgId=@sessionOrgID;
			END
		END
		
	   /* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */
		  
		IF NOT EXISTS(SELECT OrgId FROM dbo.tblOrganization WHERE OrgId = @orgId)
		BEGIN
		    SET @ReturnResult = '400|2805 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2805)+'->'+CONVERT(VARCHAR,@orgId)
			SELECT @ReturnResult AS Returnvalue
			RETURN;
		END
		
		/* Summary: Raise an error message (400). If contentData field not passed */
		IF(ISNULL(@contentData,'') = '')
		BEGIN
			SET @ReturnResult = '400|2804 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2804)
			SELECT @ReturnResult AS Returnvalue
			RETURN;
		END
		
		/* Summary: If the Organization record is found, check if the user is authorized to make this request */
			/* Summary: If accessLevel is SysAdminRW */
			/* Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of organization[OrgId] */
			/* Summary: If accessLevel is OrgAdminRW or OrgUserRW, then check if Session[OrgId] is the same as organization[OrgId] */
		IF((@accessLevel = 1) OR ((@accessLevel = 3) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))) OR ((@accessLevel = 5 OR @accessLevel=7 ) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgID = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))))
		BEGIN
			SET @contentVar=Replace(@contentData,'},{','}^{');
		    SET @contentVar =REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(@contentVar,'{',''),'}',''),'"',''),'[',''),']','');
		   -- PRINT @contentVar
		  	INSERT INTO #TempScan (contentData)SELECT items FROM Splitrow(@contentVar,'^')
			DECLARE TEMP_cursor CURSOR FOR SELECT t.ID FROM dbo.#TempScan t WITH(NOLOCK)
			OPEN TEMP_cursor;  
			FETCH NEXT FROM TEMP_cursor INTO @CURSORID;
			WHILE @@FETCH_STATUS = 0  
			BEGIN  				      
				SET @id=0;
				SELECT @NameValuePairs = D.contentData FROM dbo.#TempScan D WHERE D.ID = @CURSORID
				WHILE LEN(@NameValuePairs) > 0
				BEGIN
					SET  @id=@id+1;
					SET @NameValuePair = LEFT(@NameValuePairs, ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs) - 1, -1),LEN(@NameValuePairs)))
					SET @NameValuePairs = SUBSTRING(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs), 0), LEN(@NameValuePairs)) + 1, LEN(@NameValuePairs))

					SET @Name  = SUBSTRING(@NameValuePair, 1, CHARINDEX(':', @NameValuePair) - 1)
					SET @Value = SUBSTRING(@NameValuePair, CHARINDEX(':', @NameValuePair) + 1, LEN(@NameValuePair))
                    SET @Name  = LTRIM(RTRIM(@Name))
                    SET @Value = LTRIM(RTRIM(@Value))
					INSERT INTO @Property ([id], [Name], [Value] ) VALUES ( @id,@Name, @Value )
				END
				SET @itemProcessed = @itemProcessed + 1;
				SET @Code = '';
                SET @DESCRIPTION = ''; 
                SET @Category = ''; 
				SET @Model = ''; 
                SET @Manufacturer = ''; 
                SET @PartNumber = ''; 
                SET @ProductLine = ''; 
                SET @ManufacturerSKU = ''; 
                SET @UnitMeasure = ''; 
                SET @UnitPrice = '';
                SET @Misc1 = '';
                SET @Misc2 = '';
                SET @Error = ''; 
                SET @Count = (SELECT COUNT(*) FROM @Property)
                DECLARE @i	int
                SET @i=1
                WHILE( @i <= @Count)
                BEGIN
                          SET @Name=(SELECT Name FROM @Property WHERE id=@i)
                          SET @Value=(SELECT [Value] FROM @Property WHERE id=@i)
                          SET @i=@i + 1;
                          IF(LOWER(@Name) = 'code')
                            SET @Code=@Value;
                          ELSE IF(LOWER(@Name) = 'description') 
                             SET @DESCRIPTION=@Value; 
                          ELSE IF(LOWER(@Name) = 'category') 
                             SET @Category=@Value; 
                          ELSE IF(LOWER(@Name) = 'model') 
                             SET @Model=@Value; 
                          ELSE IF(LOWER(@Name) = 'manufacturer') 
                             SET @Manufacturer=@Value; 
                          ELSE IF(LOWER(@Name) = 'partNumber') 
                             SET @PartNumber=@Value; 
                          ELSE IF(LOWER(@Name) = 'productLine') 
                             SET @ProductLine=@Value; 
                          ELSE IF(LOWER(@Name) = 'manufacturerSKU') 
                             SET @ManufacturerSKU=@Value; 
                          ELSE IF(LOWER(@Name) = 'unitMeasure') 
                             SET @UnitMeasure=@Value; 
                          ELSE IF(LOWER(@Name) = 'unitPrice') 
                             SET @UnitPrice=@Value;
                          ELSE IF(LOWER(@Name) = 'misc1') 
                             SET @Misc1=@Value;
                          ELSE IF(LOWER(@Name) = 'misc2') 
                             SET @Misc2=@Value;
                          ELSE
                          BEGIN
                            SET  @Error='Error'; 
                            SET @ErrorMessage = @ErrorMessage+(SELECT +'|2806 ' +DESCRIPTION +'|' +  FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode= 2806)  + @Name + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
                          END 
                END 
                 /* Summary:if entry does not contain code, unitPrice, description add error message + bad data to errors return field, and increment badItems COUNT make sure that code + passed orgId (or Session[orgId] if orgId not passed) does not already exist in Content
					if match found in Content add error message + bad data to errors return field, and increment badItems COUNT */
                      
				IF(isnull(@Error,'') = '')
                BEGIN
					IF(((ISNULL(@Code,'')<> '' AND ISNULL(@UnitPrice,'')<>'' AND ISNULL(@DESCRIPTION,'')<>'') AND (NOT EXISTS(SELECT CODE FROM dbo.tblcontent WHERE CODE=@Code AND OrgId=@orgId)) AND (isnumeric(@UnitPrice)=1)) )                         
						BEGIN
							INSERT INTO tblContent(OrgId,Code,Category,Model,Manufacturer,PartNumber,ProductLine,ManufacturerSKU,[DESCRIPTION],UnitMeasure,UnitPrice,Misc1,Misc2)VALUES(@orgId,@Code,ISNULL(@Category,'None'),ISNULL(@Model,'None'),ISNULL(@Manufacturer,'None'),ISNULL(@PartNumber,'None'),ISNULL(@ProductLine,'None'),ISNULL(@ManufacturerSKU,'None'),@DESCRIPTION,ISNULL(@UnitMeasure,'None'),@UnitPrice,ISNULL(@Misc1,'None'),ISNULL(@Misc2,'None'))
							SET @contentID = @@IDENTITY
							SET @recordsCreated  =@recordsCreated  +1
							UPDATE [tblSession] SET lastActivity=SYSDATETIMEOFFSET() WHERE sessionKey=@sessionKey
							EXEC upi_UserActivity @UserId,@date,1,@contentID,17,'Create'
						END 
						/* Summary:Here collect the BadItems and return the Error message*/
						ELSE
						BEGIN
							SET @badItems=@badItems+1
							IF(ISNULL(@Code,'')= '')
							BEGIN
								SET @ErrorMessage = @ErrorMessage+(SELECT +'|2807 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 2807)+ ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
							END
							ELSE IF(EXISTS(SELECT CODE FROM dbo.tblcontent WHERE CODE=@Code AND OrgId=@orgId))
							BEGIN
								SET @ErrorMessage = @ErrorMessage+(SELECT +'|2810 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 2810)+'->'+CONVERT(VARCHAR,@Code) + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
							END
							IF(ISNULL(@DESCRIPTION,'') = '')
							BEGIN
								SET @ErrorMessage = @ErrorMessage+(SELECT +'|2809 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 2809)+'->'+CONVERT(VARCHAR,@Code) + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
							END
							IF(ISNULL(@UnitPrice,'') = '')
							BEGIN
								SET @ErrorMessage = @ErrorMessage+(SELECT +'|2808 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 2808)+'->'+CONVERT(VARCHAR,@Code)+ ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
							END
							ELSE  IF(isnumeric(@UnitPrice)=0)
							BEGIN
								SET @ErrorMessage = @ErrorMessage+(SELECT +'|2811 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 2811)+'->'+CONVERT(VARCHAR,@UnitPrice)+ ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
							END
						END
				END
                DELETE FROM @Property
                SET @i=@i+1;
                FETCH NEXT FROM TEMP_cursor INTO @CURSORID;
		    	END
			    CLOSE TEMP_cursor;
			    DEALLOCATE TEMP_cursor;
				SET @ReturnResult = '200' +'|itemsProcessed = '+ CONVERT(VARCHAR,@itemProcessed)+'|badItems = '+CONVERT(VARCHAR,@badItems)+'|recordsCreated = '+CONVERT(VARCHAR,@recordsCreated)+ @ErrorMessage
				SELECT @ReturnResult AS Returnvalue
				RETURN ;
		END
		/* Summary: Raise an Error Message.User not within scope*/
		ELSE
		BEGIN
			SET @ReturnResult = '400|2801 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2801)+'->'+CONVERT(VARCHAR,isnull(@accessLevel,'0'))
	        SELECT @ReturnResult AS Returnvalue
			EXEC upi_SystemEvents 'Content',2801,3,@accessLevel
			RETURN;
		END
		END
		ELSE
		/* Summary:Raise an Error Message,if Session[accessLevel] != SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW */
		BEGIN
			SET @ReturnResult = '401|2801 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2801)+'->'+CONVERT(VARCHAR,isnull(@accessLevel,'0'))
	        SELECT @ReturnResult AS Returnvalue
			EXEC upi_SystemEvents 'Content',2801,3,@accessLevel
			RETURN;
		END
END
--exec [upi_Content] 'A1A2A3A4A5A6A7A8','43C1F1912AECF99C181388048172761D9F51BD6E',1,'{{"   ASCode":"MHNSSS" ,"  Category":"  testcategory","Model":"modeltest","Manufacturer":"manufact","PartNumber":"partno","ProductLine":"prodcutlinetest","ManufacturerSKU":"manufact","DESCRIPTION":"","UnitMeasure":"34","UnitPrice":"","Misc1":"hi","Misc2":""},{"Code":"ARNRRR  ","Category":""," Model":"","Manufacturer":"","PartNumber":"","ProductLine":"","ManufacturerSKU":"","DESCRIPTION":"qweqe","UnitMeasure":"","UnitPrice":"2502","Misc1":"","Misc2":""}}'
--exec [upi_Content] '3053FFA62F1E7B2E995C310296D50091ABF17B3E','9C728316E4C1D5F561AA44A09510B21D5ABD1285',1,'[{"Code":"Loyalty Card #","Category":"testcategory","Model":"modeltest","Manufacturer":"manufact","PartNumber":"partno","ProductLine":"prodcutlinetest","ManufacturerSKU":"manufact","DESCRIPTION":"welcome","UnitMeasure":"34","UnitPrice":"200","Misc1":"hi","Misc2":"well"},{"Code":"SKU CARD","Category":"testcategory","Model":"modeltest","Manufacturer":"manufact","PartNumber":"partno","ProductLine":"prodcutlinetest","ManufacturerSKU":"manufact","DESCRIPTION":"welcome","UnitMeasure":"34","UnitPrice":"200","Misc1":"hi","Misc2":"well"}]'



GO
/****** Object:  StoredProcedure [dbo].[upi_Device_Authenticate]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- Author:		iHorse
-- Create date: 26.06.2013
-- Routine:		DeviceBackup(upi_DeviceBackup_Authenticate)
-- Method:		POST
-- Description:	handles HTTP requests (from Interceptor devices) that are uploading
--				backed up scan data (Interceptors locally backup scan data if API connection
--				is lost, then bulk upload scan data when connection re-established)
-- ========================================================================================
CREATE PROCEDURE [dbo].[upi_Device_Authenticate] 
	
	@a AS VARCHAR(40),
	@i AS VARCHAR(12),
	@b AS NVARCHAR(MAX)
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @eventData used to store event data description
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @scanObject		AS NVARCHAR(MAX)
	DECLARE @t				AS NVARCHAR(MAX)
    DECLARE @d				AS VARCHAR(500)
    DECLARE @CURSORID		AS INT
    DECLARE @failureCOUNT	AS INT
    DECLARE @passCOUNT		AS INT
    DECLARE @tempCOUNT		AS INT
    
    SET @date			= SYSDATETIMEOFFSET();
	SET @tempCOUNT		= 0;
	SET @failureCOUNT	= 0;
	SET @passCOUNT		= 0;
	
	--Summary :Create Temporary table(for Internal Use)
	CREATE TABLE #TempScan (ID INT IDENTITY(1,1) NOT NULL,ScanDate NVARCHAR(Max),ScanData NVARCHAR(Max))
	
	--Summary: If any of the input fields are not passed, return a HTTP response “400 Bad Request”. *
	IF((ISNULL(@a,'') = '') OR (ISNULL(@i,'') = '') OR (ISNULL(@b,'')= ''))
	BEGIN
		SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
		EXEC upi_SystemEventsData 'DeviceBackup',2307,3
		RETURN;
	END
	
	--Summary :Use the passed i to search for the InterceptorID record. If record not found, return a HTTP response “400 Bad Request”. *
	IF(NOT EXISTS(SELECT 1 FROM dbo.tblInterceptorID WHERE IntSerial=@i))
	BEGIN
		SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
		EXEC upi_SystemEventsData 'DeviceBackup',2303,3
		RETURN;
	END
	
	-- Summary:Create an MD5 hexdigest of InterceptorID[embeddedID]. If hexdigest does not match passed a, return a HTTP response “400 Bad Request”. *
	IF(@a <> (SELECT top 1 CONVERT(VARCHAR(40),HashBytes('SHA1', EmbeddedId),2) FROM dbo.tblInterceptorID WHERE IntSerial=@i))
	BEGIN
		SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
	    EXEC upi_SystemEventsData 'DeviceBackup',2304,3
		RETURN;
	END
	
	--Summary:Split the Unwanted Characters and Insert the Temporary Table
	SET @scanObject = dbo.[FN_REMOVE_SPECIAL_CHARACTER](@b);
	SET @scanObject = REPLACE(@scanObject,' ','');
	SET @scanObject = REPLACE(REPLACE(@scanObject,',d:','#'),'t:','');
	
	INSERT INTO #TempScan (ScanDate,ScanData)SELECT  LTRIM(RTRIM(SUBSTRING(items, 1,CHARINDEX('#', items)-1))) as ScanDate,LTRIM(RTRIM(SUBSTRING(items, CHARINDEX('#', items)+1, LEN(items)))) as  ScanData from Splitrow(@scanObject,',')
	SET @tempCOUNT = (SELECT COUNT(*) from #TempScan)
	
	DECLARE DEVICESCAN_CURSOR CURSOR FOR SELECT t.ID FROM dbo.#TempScan t WITH(NOLOCK)
	OPEN DEVICESCAN_CURSOR;  
	FETCH NEXT FROM DEVICESCAN_CURSOR INTO @CURSORID;
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		SELECT @d  = D.ScanData from dbo.#TempScan D where D.ID = @CURSORID
		SELECT @t  = D.ScanDate from dbo.#TempScan D where D.ID = @CURSORID
				   	   
		IF(ISNULL(@t,'')<>'' AND ISNULL(@d,'')<>'' )
		BEGIN 
		IF (CHARINDEX('T',@t) <> 0)
			BEGIN
				DECLARE @datetimeoffset datetimeoffset(7) = @t;
				DECLARE @date1 dateTIME= @datetimeoffset;
				IF(ISDATE(@date1) = 1)
				BEGIN
					IF((CHARINDEX('~',@d)) <> 0) 
				   	BEGIN
				   	IF(ISNUMERIC((SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) = 1)
				   		BEGIN
							SET  @passCOUNT = @passCOUNT + 1;
						END
						ELSE
						BEGIN
							SET @failureCOUNT = @failureCOUNT + 1;
							SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
							EXEC upi_SystemEventsData 'DeviceBackup',2306,3
							RETURN;
						END
					END
					ELSE
					BEGIN
						SET  @passCOUNT = @passCOUNT + 1;
					END 
				END
				ELSE 
				BEGIN
					SET @failureCOUNT = @failureCOUNT+1
					SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
					RETURN;
				END
			END
			ELSE
			BEGIN
				SET @failureCOUNT = @failureCOUNT + 1;
				SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
				EXEC upi_SystemEventsData 'DeviceBackup',2306,3
				RETURN;
			END
		END
		ELSE
		BEGIN
			SET @failureCOUNT = @failureCOUNT + 1;
			SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
			EXEC upi_SystemEventsData 'DeviceBackup',2305,3
			RETURN;
		END
		FETCH NEXT FROM DEVICESCAN_CURSOR INTO @CURSORID;
	END
	CLOSE DEVICESCAN_CURSOR;
	DEALLOCATE DEVICESCAN_CURSOR;
	IF(@tempCOUNT = @passCOUNT)
	BEGIN
		SET @ReturnResult = '201' SELECT @ReturnResult AS Returnvalue
		RETURN;
	END
END
--EXEC upi_DeviceBackup_Authenticate 'FD8DCDDAEE3CD7F75683820A05F3C3E9','Int50',' {{"t":"2013-06-18T11:30:55.003","d":"XYAZS"}'


GO
/****** Object:  StoredProcedure [dbo].[upi_DeviceBackup]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- Author:		Prakash G
-- Create date: 29.05.2013
-- Routine:		DeviceBackup

-- Method:		POST
-- Description:	handles HTTP requests (from Interceptor devices) that are uploading
--				backed up scan data (Interceptors locally backup scan data if API connection
--				is lost, then bulk upload scan data when connection re-established)
-- ========================================================================================

--'32 character MD5 hexdigest of Interceptor’s embedded ID','serial no',''
--exec [upi_DeviceBackup] 'FD8DCDDAEE3CD7F75683820A05F3C3E9','Int50','2011-01-01 00:00:00.000','~57/*CH*ABC'
--EXEC upi_DeviceBackup '3D4F2BF07DC1BE38B20CD6E46949A1071F9D0E3D','III111111',' {{"t":"2013-06-18T11:30:55.003","d":"aaaaaa"}}'
--EXEC upi_DeviceBackup 'FD8DCDDAEE3CD7F75683820A05F3C3E9','Int50',' {{"t":"2013-05-18T11:30:55.003","d":"~14/*CH*ABC"}, {"t":"2013-05-18T11:30:55.007","d":"FGHIJK"}}'
--EXEC upi_DeviceBackup 'FEF605D5648CDAD840E1FEEBC8535374','Int61','{{"t":"2013-05-18T11:30:55.003","d":"~16/*CH*ABC"}, {"t":"2013-05-18T11:30:55.007","d":"ABCDSEF"}}'
--EXEC upi_DeviceBackup 'FD8DCDDAEE3CD7F75683820A05F3C3E9','Int50','{{"t":"2013-05-18T11:30:55.003","d":"~16/*CH*ABC"}, {"t":"2013-05-18T11:30:55.007","d":"ABCDSEF"}}'
--EXEC upi_DeviceBackup 'FEF605D5648CDAD840E1FEEBC8535374','Int61',' {{"t":"2013-05-18T11:30:55.003","d":"~14/*CH*ABC"}, {"t":"2013-05-18T11:30:55.007","d":"FGHIJK"}}'

CREATE PROCEDURE [dbo].[upi_DeviceBackup] 
	
	@a VARCHAR(40),
	@i VARCHAR(12),
	@b NVARCHAR(MAX)
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @eventData used to store event data description
	
	DECLARE @ReturnResult AS VARCHAR(100)
	DECLARE @date AS datetimeoffset(7)
	DECLARE @eventData AS VARCHAR(1000)
	DECLARE @severData AS VARCHAR(50)
	DECLARE @scanObject AS NVARCHAR(max)
	DECLARE @t AS  NVARCHAR(max)
    DECLARE @d varchar(500)
    DECLARE @CURSORID INT
    DECLARE @CURSORID1 INT
    DECLARE @scandata AS NVARCHAR(max)
    
    DECLARE @count INT
	--Summary :Create Temporary table(for Internal Use)
	--DROP table #TempScan
	CREATE TABLE #TempScan (ID INT IDENTITY(1,1) NOT NULL,ScanDate NVARCHAR(Max),ScanData NVARCHAR(Max))
    SET @scandata =''
	SET @count = 1
	SET @date = SYSDATETIMEOFFSET();
	SET @eventData = 'Routine=DeviceBackup; Event=POST' + '; a=' + Convert(VARCHAR(50), @a) + '; Intserial='+ Convert(VARCHAR(12), @i) + ';Scan Data ='+ Convert(VARCHAR(MAX), @b)+')'
	
	--Summary: If any of the input fields are not passed, return a HTTP response “400 Bad Request”. *
	IF((ISNULL(@a,'') = '') OR (ISNULL(@i,'') = '') OR (ISNULL(@b,'')= ''))
	BEGIN
	 SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
	 EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
	 RETURN;
	END
	--Summary :Use the passed i to search for the InterceptorID record. If record not found, return a HTTP response “400 Bad Request”. *
	IF(NOT EXISTS(SELECT 1 FROM dbo.tblInterceptorID WHERE IntSerial=@i))
	BEGIN
	 SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
	 EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
	 RETURN;
	END
	--select  CONVERT(VARCHAR(32),HashBytes('MD5', 'E504'),2)  
	-- Summary:Create an MD5 hexdigest of InterceptorID[embeddedID]. If hexdigest does not match passed a, return a HTTP response “400 Bad Request”. *
	IF(@a <> (SELECT top 1 CONVERT(VARCHAR(40),HashBytes('SHA1', EmbeddedId),2) FROM dbo.tblInterceptorID WHERE IntSerial=@i))
	BEGIN
		SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
		EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
		RETURN;
	END
	
	--Summary:Split the Unwanted Characters and Insert the Temporary Table
	
	SET @scanObject=dbo.[FN_REMOVE_SPECIAL_CHARACTER](@b);
	--print @scanObject
	SET @scanObject=Replace(Replace(@scanObject,',d:','#'),'t:','');
	--print @scanObject
	INSERT INTO #TempScan (ScanDate,ScanData)Select  Ltrim(Rtrim(Substring(items, 1,Charindex('#', items)-1))) as ScanDate,Ltrim(Rtrim(Substring(items, Charindex('#', items)+1, LEN(items)))) as  ScanData from Splitrow(@scanObject,',')
	--select * from #TempScan
	DECLARE DEVICESCAN_CURSOR CURSOR FOR SELECT t.ID FROM dbo.#TempScan t WITH(NOLOCK)
				  OPEN DEVICESCAN_CURSOR;  
				  FETCH NEXT FROM DEVICESCAN_CURSOR INTO @CURSORID;
				   WHILE @@FETCH_STATUS = 0  
				   BEGIN
						SELECT @d  = D.ScanData from dbo.#TempScan D where D.ID = @CURSORID
				   		SELECT @t  = D.ScanDate from dbo.#TempScan D where D.ID = @CURSORID
				   	   --Summary:Check the passed JSON object b to see if all the entries are valid.If not, then return a HTTP response “400 Bad Request”.*  If all entries are valid, then return a HTTP response “201 Created”
				   	   
				   	   	IF(ISNULL(@t,'')<>'' AND ISNULL(@d,'')<>'' )
				   	   	BEGIN 
--EXEC upi_DeviceBackup '3D4F2BF07DC1BE38B20CD6E46949A1071F9D0E3D','III111111',' {{"t":"2013-05-18T11:30:55.0030000+00:00","d":"aaaaaa"}}'

				   	  
				   	      IF (CHARINDEX('T',@t) <> 0)
				   	      BEGIN
				   		 	IF((CHARINDEX('~',@d)) <> 0) 
				   		  	BEGIN
				   		 		IF(ISNUMERIC((SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) = 1)
				   		 		BEGIN
									SET @ReturnResult = '201' 
								END
								ELSE
								BEGIN
									SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
									EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
									RETURN;
							    END
							   END--notDynamic Code 
							 ELSE
							 BEGIN
								SET @ReturnResult = '201'
							 END  
						END
							ELSE
							 BEGIN
							 SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
								EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
								RETURN;
							 END
						END
						
					ELSE
					BEGIN
						SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
						EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
						RETURN;
				    END
				     --return;
					 --Summary: Create a new DeviceScan record with the values in the list item
    
					--INSERT INTO tblDeviceScan(IntSerial,ScanDate,ScanData,CallHomeRedmptionData)VALUES(@i,@t,@d,'');
						FETCH NEXT FROM DEVICESCAN_CURSOR INTO @CURSORID;
				  END
			 CLOSE DEVICESCAN_CURSOR;
			 DEALLOCATE DEVICESCAN_CURSOR;
			 
			 DECLARE DEVICESCAN_CURSOR1 CURSOR FOR SELECT t.ID FROM dbo.#TempScan t WITH(NOLOCK)
				  OPEN DEVICESCAN_CURSOR1;  
				  FETCH NEXT FROM DEVICESCAN_CURSOR1 INTO @CURSORID;
				   WHILE @@FETCH_STATUS = 0  
				   BEGIN
						SELECT @d  = D.ScanData from dbo.#TempScan D where D.ID = @CURSORID
				   		SELECT @t  = D.ScanDate from dbo.#TempScan D where D.ID = @CURSORID
				   		INSERT INTO tblDeviceScan(IntSerial,ScanDate,ScanData,CallHomeRedmptionData)VALUES(@i,@t,@d,'');
						FETCH NEXT FROM DEVICESCAN_CURSOR1 INTO @CURSORID;
				  END
			 CLOSE DEVICESCAN_CURSOR1;
			 DEALLOCATE DEVICESCAN_CURSOR1;
			 
	--Summary:Use the passed i to get the Interceptor record.
	
	IF(EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial=@i))
		BEGIN
		--Summary:get the Location record using Interceptor[locId] AND get the Organization record using Interceptor[orgId]
		
		--IF(EXISTS(SELECT 1 FROM dbo.tblInterceptor  INNER JOIN  tblOrganization  ON tblOrganization.orgId=tblInterceptor.orgId INNER JOIN tblLocation ON tblLocation.locId=tblInterceptor.locid and tblLocation.orgid=tblOrganization.orgId WHERE tblInterceptor.IntSerial=@i))
		   --BEGIN
		    --Summary: Check the Interceptor[forwardURL] field. If it  is not empty, the do the following
		     IF((SELECT TOP 1 forwardURL FROM dbo.tblInterceptor WHERE IntSerial=@i) < > '')
		      BEGIN
		      IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WHERE IntSerial=@i),'')= '0')
				BEGIN
				--print'forwardurl=0'
	     	      DECLARE SCAN_CURSOR CURSOR FOR SELECT t.ID FROM dbo.#TempScan t WITH(NOLOCK)
				  OPEN SCAN_CURSOR;  
				  FETCH NEXT FROM SCAN_CURSOR INTO @CURSORID;
				   WHILE @@FETCH_STATUS = 0  
				   BEGIN
				   	SELECT @d  = D.ScanData from dbo.#TempScan D where D.ID = @CURSORID
				   	SELECT @t  = D.ScanDate from dbo.#TempScan D where D.ID = @CURSORID
				   
				   	  --EXEC upi_DeviceBackup 'E6A6A63057A146F86C6D0F94142F9F49','A1','{{"t":"2013-05-18T11:30:55.003","d":"~14/*CH*ABC"},{"t":"2013-05-18T11:30:55.003","d":"~14/ABC"},{"t":"2013-05-18T11:30:55.007","d":"FGHIJK"},{"t":"2013-09-18T11:30:55.007","d":"REDEM123"},{"t":"2013-07-18T11:30:55.003","d":"~57/*CH*ABC"},{"t":"2013-06-18T11:30:55.003","d":"~10/*CH*ABC"},{"t":"2013-06-18T11:30:55.003","d":"~10/ABC"}}'
					
					  IF(@d like '%~%')
             			BEGIN
						/*Summary: Use the dynCID to search for the DynamicCode record where dynCID is sandwiched between the ~ and the first “/” */
							IF(NOT EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
							   SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
							   EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							  --RETURN;
							END
							----Summay:Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code]
							ELSE
							IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.OrgId =ISNULL((SELECT TOP 1 I.orgId FROM dbo.tblInterceptor I WHERE I.IntSerial=@i),'')  AND 
							C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
							/*Summay: If Content records found return the following fields */
							select 'Dynamic With Content Match'
								SELECT '<list>'+(
								SELECT TOP 1 @i AS 'IntSerial', I.IntLocDesc AS 'IntLocDesc', O.OrgName AS 'OrgName', L.UnitSuite AS 'UnitSuite', L.Street AS 'Street',
								L.City AS 'City',L.State AS 'State',L.Country AS 'Country',L.PostalCode AS 'PostalCode',L.LocType AS 'LocType',L.LocSubType AS 'LocSubType',
								D.ScanDate AS 'ScanDate', DC.RedemptionData AS 'Code',DC.CellPhone AS 'CellPhone',C.Category AS 'Category',C.Model AS 'Model',C.Manufacturer AS 'Manufacturer',  -- DC.MetaData AS 'MetaData',
								C.PartNumber AS 'PartNumber',C.ProductLine AS 'ProductLine',C.ManufacturerSKU AS 'ManufacturerSKU',C.Description AS 'Description',
								C.UnitMeasure AS 'UnitMeasure', C.UnitPrice AS 'UnitPrice',C.Misc1 AS 'Misc1', C.Misc2 AS 'Misc2',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
								JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
								AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
								AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
								AND C.Code =(SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
							   FOR XML RAW )+'</list>'
							   EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							  --RETURN;
							END
							ELSE
							/*Summay: If Content records not found return the following fields */
							BEGIN
							select 'Dynamic With Not Content Match'
								SELECT '<list>'+(
								SELECT TOP 1 I.IntSerial AS 'IntSerial', I.IntLocDesc AS 'IntLocDesc', O.OrgName AS 'OrgName', L.UnitSuite AS 'UnitSuite', L.Street AS 'Street',
								L.City AS 'City',L.State AS 'State',L.Country AS 'Country',L.PostalCode AS 'PostalCode',L.LocType AS 'LocType',L.LocSubType AS 'LocSubType',
								D.ScanDate AS 'ScanData', DC.RedemptionData AS 'Code',DC.CellPhone AS 'CellPhone',    --DC.MetaData AS 'MetaData',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
								AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								FOR XML RAW )+'</list>'
								EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
								--RETURN;
							END
						END-- NOT DYANMIC CODE 
						/*Summay: Check if DeviceScan[scanData] is not a dynamic code */
						/*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
						ELSE IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @d AND C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i))
						BEGIN
							/*Summay: If Content records found return the following fields */
						select 'Not Dynamic With Content Match'
							SELECT '<list>'+(
								SELECT TOP 1 I.IntSerial AS 'IntSerial', I.IntLocDesc AS 'IntLocDesc', O.OrgName AS 'OrgName', L.UnitSuite AS 'UnitSuite', L.Street AS 'Street',
								L.City AS 'City',L.State AS 'State',L.Country AS 'Country',L.PostalCode AS 'PostalCode',L.LocType AS 'LocType',L.LocSubType AS 'LocSubType',
								D.ScanDate AS 'ScanData', D.ScanData AS 'Code','0' AS 'CellPhone', '0' AS 'MetaData',C.Category AS 'Category',C.Model AS 'Model',C.Manufacturer AS 'Manufacturer',
								C.PartNumber AS 'PartNumber',C.ProductLine AS 'ProductLine',C.ManufacturerSKU AS 'ManufacturerSKU',C.Description AS 'Description',
								C.UnitMeasure AS 'UnitMeasure', C.UnitPrice AS 'UnitPrice',C.Misc1 AS 'Misc1', C.Misc2 AS 'Misc2',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i)
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
								AND C.Code = @d
							FOR XML RAW )+'</list>'
							EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							--RETURN;
						END
						ELSE
						/*Summay: If Content records not found return the following fields */
						BEGIN
						select 'Not Dynamic With Not Content Match'
							SELECT '<list>'+(
								SELECT TOP 1 I.IntSerial AS 'IntSerial', I.IntLocDesc AS 'IntLocDesc', O.OrgName AS 'OrgName', L.UnitSuite AS 'UnitSuite', L.Street AS 'Street',
								L.City AS 'City',L.State AS 'State',L.Country AS 'Country',L.PostalCode AS 'PostalCode',L.LocType AS 'LocType',L.LocSubType AS 'LocSubType',
								D.ScanDate AS 'ScanData', D.ScanData AS 'Code','0' AS 'CellPhone', '0' AS 'MetaData',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
							FOR XML RAW )+'</list>'
							
							EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							--RETURN;
						END
						 
				FETCH NEXT FROM SCAN_CURSOR INTO @CURSORID;
			 END
			 CLOSE SCAN_CURSOR;
			 DEALLOCATE SCAN_CURSOR;
            END
			   --EXEC upi_DeviceBackup 'FEF605D5648CDAD840E1FEEBC8535374','Int61','{{"t":"2013-05-18T11:30:55.003","d":"~14/*CH*ABC"},{"t":"2013-05-18T11:30:55.003","d":"~14/ABC"},{"t":"2013-05-18T11:30:55.007","d":"FGHIJK"},{"t":"2013-09-18T11:30:55.007","d":"REDEM123"},{"t":"2013-07-18T11:30:55.003","d":"~57/*CH*ABC"},{"t":"2013-06-18T11:30:55.003","d":"~10/*CH*ABC"},{"t":"2013-06-18T11:30:55.003","d":"~10/ABC"}}'   
              --SUMMARY:if Interceptor[forwardURL] = 1 (batch forwarding)
               ELSE
               IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WHERE IntSerial=@i),'')= '1')
               BEGIN
                 -- Summary:if it doesn’t exist, create a temporary data store with the same fields as ScanBatches, called TempScanBatches
                -- print 'forwardtype=1'
                  IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'tblTempScanBatches'))
				   BEGIN
				   
				    CREATE TABLE [dbo].tblTempScanBatches([Id] [int] IDENTITY(1,1) NOT NULL,[IntSerial] [varchar](12) NOT NULL,[OrgName] [nvarchar](100) NOT NULL,[DeliveryTime] [datetimeoffset](7) NULL,[ForwardURL] [varchar](100) NULL,
	                [UnitSuite] [varchar](15) NULL,[Street] [nvarchar](100) NULL,[City] [varchar](50) NULL,[State] [nvarchar](100) NULL,[Country] [varchar](50) NULL,[PostalCode] [varchar](10) NULL,[LocType] [nvarchar](50) NULL,[LocSubType] [nvarchar](50) NULL,
	                 [IntLocDesc] [varchar](100) NULL,[ScanData] [varchar](max) NOT NULL)
				   END
				   IF(NOT EXISTS(SELECT 1 FROM dbo.tblTempScanBatches where IntSerial=@i))
				   BEGIN
				    DECLARE ScanDataNotExist_Cursor CURSOR FOR SELECT ID FROM #TempScan WITH(NOLOCK)
				    OPEN ScanDataNotExist_Cursor; 
						FETCH NEXT FROM ScanDataNotExist_Cursor INTO @CURSORID;
						WHILE @@FETCH_STATUS = 0  
						BEGIN
						SELECT @d  = D.ScanData from dbo.#TempScan D where D.ID = @CURSORID
				     	SELECT @t  = D.ScanDate from dbo.#TempScan D where D.ID = @CURSORID
				   
				    IF(@d like '%~%')
             		BEGIN
             	
             			/*Summary: Use the dynCID to search for the DynamicCode record where dynCID is sandwiched between the ~ and the first “/” */
						IF(NOT EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
						BEGIN
						   Select 'notexist'
						   SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
						   EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
						  -- RETURN;
						END
						----Summay:Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code]
						ELSE IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.OrgId =ISNULL((SELECT TOP 1 I.orgId FROM dbo.tblInterceptor I WHERE I.IntSerial=@i),'')  AND 
							C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID =(SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
							--Summary:To check the CallHomeURL then This “redemptionData”” <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.
							IF(@d LIKE '%*CH*%')
							BEGIN
							select 'NotExist-DynamicWith-ContentMatch-CallHomeURL'
							 --Summay: If Content records found return the following fields 
							 
								--INSERT tblTempScanBatches  SELECT   I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata + '{'+ (SELECT 'code:' + ' ' + DC.RedemptionData +' '+  'cellphone:'+' '+ convert(varchar,DC.cellphone) +' '+'metaData:' +' '+ convert(varchar,DC.metadata)  +' '+ 'RedemptionData:' +DC.RedemptionData  +''+ 'category:'+'' + C.category +' '+'model:' +' ' +C.model +' '+'manufacturer:'+' '+C.manufacturer+' '+'partNumber:'+''+C.partNumber +' '+'productLine:'+''+C.productLine+' '+'manufacturerSKU:'+' '+C.manufacturerSKU+''+'description:'+' '+ C.description+''+'unitMeasure:'+' '+C.unitMeasure+''+'unitPrice:'+' '+CONVERT(VARCHAR,C.unitPrice)+'misc1:'+''+C.misc1+' '+'misc2:'+''+C.misc2 
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
								JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
								AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}'
							    EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							   --RETURN;
							
							END
							ELSE
							BEGIN
							   select  'NotExist-DynamicWith-ContentMatch-NotCallHomeURL'
							--Summay: If Content records found return the following fields 
								--INSERT tblTempScanBatches  SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata +'{'+ (SELECT 'code:' +' ' + DC.RedemptionData +' '+  'cellphone:'+' '+ DC.cellphone +' '+'metaData:' +' '+ DC.metaData +''+ 'category:'+'' + C.category +' '+'model:' +' ' +C.model +' '+'manufacturer:'+' '+C.manufacturer+' '+'partNumber:'+''+C.partNumber +' '+'productLine:'+''+C.productLine+' '+'manufacturerSKU:'+' '+C.manufacturerSKU+''+'description:'+' '+ C.description+''+'unitMeasure:'+' '+C.unitMeasure+''+'unitPrice:'+' '+CONVERT(VARCHAR,C.unitPrice)+'misc1:'+''+C.misc1+' '+'misc2:'+' '+ C.misc2  
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
								JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
								AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}'
							    EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							   --RETURN;
							   END
							END
							--Summay: If Content records not found return the following fields 
							ELSE
							
							--Summary:To check the CallHomeURL then This “redemptionData”” <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.
							IF(@d LIKE '%*CH*%')
							BEGIN
							select 'NotExist-DynamicWith-ContentNotMatch-CallHomeURL'
								--INSERT tblTempScanBatches  SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata +'{'+ ( SELECT 'code:' +' ' + DC.RedemptionData +' '+  'cellphone:'+' '+ DC.cellphone +' '+'metaData:' +' '+ DC.metaData +'' + 'RedemptionData:' +DC.RedemptionData 
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
								AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}'
								EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
						    END
						    ELSE
							BEGIN
						    select 'NotExist-DynamicWith-ContentNotMatch-NotCallHomeURL'
							  -- INSERT tblTempScanBatches  SELECT   I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata +'{'+ (SELECT 'code:' + ' ' + DC.RedemptionData +' '+  'cellphone:'+' '+ DC.cellphone +' '+'metaData:' +' '+ DC.metaData  
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
								AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) +'}'
								EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
								--RETURN;
							END
					 		
						END----Dynamic record
						ELSE -- Not Dynamic code
						IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @d AND C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i))
						BEGIN
						 select 'NotExist-NotDynamic-ContentMatch'
							/*Summay: If Content records found return the following fields */
						    --INSERT tblTempScanBatches  SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
						       SET @scandata = @scandata +'{'+ (SELECT 'code:' +' ' + @d +' '+ 'category:'+'' + C.category +' '+'model:' +' ' +C.model +' '+'manufacturer:'+' '+C.manufacturer+' '+'partNumber:'+''+C.partNumber +' '+'productLine:'+''+C.productLine+' '+'manufacturerSKU:'+' '+C.manufacturerSKU+''+'description:'+' '+ C.description+''+'unitMeasure:'+' '+C.unitMeasure+''+'unitPrice:'+' '+CONVERT(VARCHAR,C.unitPrice)+'misc1:'+''+C.misc1+' '+'misc2:'+''+C.misc2  
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
								AND C.Code = @d ) +'}'
							EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							--RETURN;
						END
						ELSE
						/*Summay: If Content records not found return the following fields */
						BEGIN
						 select 'NotExist-NotDynamic-NotContentMatch'
				
						--INSERT tblTempScanBatches  SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
						SET @scandata = @scandata +'{'+ (SELECT  'code:' +' ' + @d  
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d) + '}'
							 EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							--RETURN;
						END
								   
				   FETCH NEXT FROM ScanDataNotExist_Cursor INTO @CURSORID;
			     END
		     	CLOSE ScanDataNotExist_Cursor;
		     	
			   DEALLOCATE ScanDataNotExist_Cursor;
			   
			   
			   INSERT tblTempScanBatches SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc,@scandata  FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) and  I.IntSerial=@i
			  SET  @scandata='';					
			  END--	  Not exist temptblscanbtahces
			  ELSE
			  BEGIN
			 -- print 'exist'
			  SET @scandata= @scandata + (SELECT ScanData FROM dbo.tblTempScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial =tblTempScanBatches.intserial where TBLINTERCEPTOR.intserial=@i)
			   -- if data exists in TempScanBatches and scanDate <=TempScanBatches[deliveryTime] +Interceptor[maxBatchWaitTime] append data to end of list TempScanBatches[scanData]:
			   DECLARE ScanDataExist_Cursor CURSOR FOR SELECT ID FROM #TempScan WITH(NOLOCK)
			   OPEN ScanDataExist_Cursor  
						FETCH NEXT FROM ScanDataExist_Cursor INTO @CURSORID
						WHILE @@FETCH_STATUS = 0  
						BEGIN
						SELECT @d  = D.ScanData from dbo.#TempScan D where D.ID = @CURSORID
				     	SELECT @t  = D.ScanDate from dbo.#TempScan D where D.ID = @CURSORID
				    IF(CONVERT(datetimeoffset(7),@t) <=(SELECT  CONVERT(datetimeoffset(7),DeliveryTime)+ CONVERT(datetime,MaxBatchWaitTime) FROM dbo.tblTempScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial =tblTempScanBatches.intserial where TBLINTERCEPTOR.intserial=@i ))
					--IF(CONVERT(datetimeoffset(7),@t) <=(SELECT  CONVERT(datetimeoffset(7),DeliveryTime) + CONVERT(datetimeoffset(7),MaxBatchWaitTime)  FROM dbo.tblTempScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial =tblTempScanBatches.intserial where TBLINTERCEPTOR.intserial=@i ))
					 BEGIN
				    IF(@d like '%~%')
             		BEGIN
             		
						/*Summary: Use the dynCID to search for the DynamicCode record where dynCID is sandwiched between the ~ and the first “/” */
						IF(NOT EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
						BEGIN
						   SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue
						   EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
						  RETURN;
						END
			   		        --Summay:Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code]
							IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.OrgId =ISNULL((SELECT TOP 1 I.orgId FROM dbo.tblInterceptor I WHERE I.IntSerial=@i),'')  AND 
							C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
							
							--Summary:To check the CallHomeURL then This “redemptionData”” <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.
							IF(@d LIKE '%*CH*%')
							BEGIN
							select 'Exist-DynamicWith-ContentMatch-CallHomeURL'
							 --Summay: If Content records found return the following fields 
							 
								--INSERT tblTempScanBatches  SELECT   I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata + '{'+ (SELECT TOP 1 'code:' + ' ' + DC.RedemptionData +' '+  'cellphone:'+' '+ convert(varchar,DC.cellphone) +' '+'metaData:' +' '+ convert(varchar,DC.metadata)  +' '+ 'RedemptionData:' +DC.RedemptionData  +''+ 'category:'+'' + C.category +' '+'model:' +' ' +C.model +' '+'manufacturer:'+' '+C.manufacturer+' '+'partNumber:'+''+C.partNumber +' '+'productLine:'+''+C.productLine+' '+'manufacturerSKU:'+' '+C.manufacturerSKU+''+'description:'+' '+ C.description+''+'unitMeasure:'+' '+C.unitMeasure+''+'unitPrice:'+' '+CONVERT(VARCHAR,C.unitPrice)+'misc1:'+''+C.misc1+' '+'misc2:'+''+C.misc2 
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
								JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
								AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}'
							    EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							   --RETURN;
							
							END
							ELSE
							BEGIN
							   select  'Exist-DynamicWith-ContentMatch-NotCallHomeURL'
							--Summay: If Content records found return the following fields 
								--INSERT tblTempScanBatches  SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata +'{'+ (SELECT 'code:' +' ' + DC.RedemptionData +' '+  'cellphone:'+' '+ DC.cellphone +' '+'metaData:' +' '+ DC.metaData +''+ 'category:'+'' + C.category +' '+'model:' +' ' +C.model +' '+'manufacturer:'+' '+C.manufacturer+' '+'partNumber:'+''+C.partNumber +' '+'productLine:'+''+C.productLine+' '+'manufacturerSKU:'+' '+C.manufacturerSKU+''+'description:'+' '+ C.description+''+'unitMeasure:'+' '+C.unitMeasure+''+'unitPrice:'+' '+CONVERT(VARCHAR,C.unitPrice)+'misc1:'+''+C.misc1+' '+'misc2:'+' '+ C.misc2  
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
								JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
								AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}'
							    EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							   --RETURN;
							  END
							END
							
							ELSE
							/*Summay: If Content records not found return the following fields */
							--Summary:To check the CallHomeURL then This “redemptionData”” <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.
							IF(@d LIKE '%*CH*%')
							BEGIN
							select 'Exist-DynamicWith-ContentNotMatch-CallHomeURL'
								--INSERT tblTempScanBatches  SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata +'{'+ ( SELECT 'code:' +' ' + DC.RedemptionData +' '+  'cellphone:'+' '+ DC.cellphone +' '+'metaData:' +' '+ DC.metaData +'' + 'RedemptionData:' +DC.RedemptionData 
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
								AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}'
								EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
						    END
						    ELSE
							BEGIN
						    select 'Exist-DynamicWith-ContentNotMatch-NotCallHomeURL'
							  -- INSERT tblTempScanBatches  SELECT   I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata +'{'+ (SELECT 'code:' + ' ' + DC.RedemptionData +' '+  'cellphone:'+' '+ DC.cellphone +' '+'metaData:' +' '+ DC.metaData  
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
								AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) +'}'
								EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
								--RETURN;
							END
					 		
						END----Dynamic record
						ELSE -- Not Dynamic code
						IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @d AND C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i))
						BEGIN
						select 'Exist-NotDynamic-ContentMatch'
							/*Summay: If Content records found return the following fields */
						   -- INSERT tblTempScanBatches  SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
								SET @scandata = @scandata +'{'+ (SELECT TOP 1 'code:' +' ' + @d +' '+ 'category:'+'' + C.category +' '+'model:' +' ' +C.model +' '+'manufacturer:'+' '+C.manufacturer+' '+'partNumber:'+''+C.partNumber +' '+'productLine:'+''+C.productLine+' '+'manufacturerSKU:'+' '+C.manufacturerSKU+''+'description:'+' '+ C.description+''+'unitMeasure:'+' '+C.unitMeasure+''+'unitPrice:'+' '+CONVERT(VARCHAR,C.unitPrice)+'misc1:'+''+C.misc1+' '+'misc2:'+''+C.misc2 
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
								AND C.Code = @d ) + '}'
								EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							--RETURN;
						END
						ELSE
						/*Summay: If Content records not found return the following fields */
						BEGIN
						select 'Exist-NotDynamic-ContentMatch'
						--INSERT tblTempScanBatches  SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc ,
						SET @scandata = @scandata +'{'+ (SELECT  TOP 1 'code:' +' ' + @d  as Scandata 
								FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId 
								JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
								WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d) + '}'
							EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
							--RETURN;
						 END
						  UPDATE  tblTempScanBatches SET ScanData=@scandata WHERE IntSerial=@i
			        END --calculate the Delivery time
			       -- if data exists in TempScanBatches and scanDate > TempScanBatches[deliveryTime] +Interceptor[maxBatchWaitTime] then send an HTTP POST request to forwardURL (see internal routine BatchDispatcher for format and content of HTTP POST request). If HTTP response is “200 Ok” log event in SystemEvents.
			       -- + MaxBatchWaitTime 
		           ELSE IF(CONVERT(datetimeoffset(7),@t) >(SELECT CONVERT(datetimeoffset(7),DeliveryTime)+ CONVERT(datetime,MaxBatchWaitTime) FROM dbo.tblTempScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial =tblTempScanBatches.intserial where TBLINTERCEPTOR.intserial= @i  ))--@i--
		           BEGIN
		            SELECT '<list>'+(SELECT  IntSerial AS 'IntSerial', isnull(IntLocDesc,'0') AS 'IntLocDesc', OrgName AS 'OrgName', UnitSuite AS 'UnitSuite',Street AS 'Street',
			    	City AS 'City',State AS 'State',Country AS 'Country',PostalCode AS 'PostalCode',LocType AS 'LocType',LocSubType AS 'LocSubType',
				    DeliveryTime AS 'ScanDate',ForwardURL AS 'ForwardURL',ScanData AS 'ScanData'
				    FROM dbo.tblTempScanBatches where IntSerial=@i
				    FOR XML RAW )+'</list>'
				    
		            SET @ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
	                EXEC upi_SystemEvents 'DeviceBackup',0,2,@eventData
	                --RETURN;
		          END
			        FETCH NEXT FROM ScanDataExist_Cursor INTO @CURSORID;
			     END
		     	CLOSE ScanDataExist_Cursor;
			   DEALLOCATE ScanDataExist_Cursor;
			 
			  END
			 END
			END-- --FORWARD TYPE=1
		
	--END --  CHECK ORG,lOC,INTERCEOTOR
  END -- CHECK INTERCEPTOR		
END


GO
/****** Object:  StoredProcedure [dbo].[upi_DeviceBackup_Authenticate]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Author:		Prakash G
-- Create date: 26.06.2013
-- Routine:		DeviceBackup(upi_DeviceBackup_Authenticate)
-- Method:		POST
-- Description:	handles HTTP requests (FROM Interceptor devices) that are uploading
--				backed up scan data (Interceptors locally backup scan data if API connection
--				is lost, then bulk upload scan data when connection re-established)
-- =============================================================================================
--EXEC upi_DeviceBackup_Authenticate 'F7C3BC1D808E04732ADF679965CCC34CA7AE3441','INT123456123','[ { "t": "2014-02-10T15:47:47.0371937Z", "s": "395", "d": "123456789012" } ]'
CREATE PROCEDURE [dbo].[upi_DeviceBackup_Authenticate] 
	
	@a VARCHAR(40),
	@i VARCHAR(12),
	@b Nvarchar(MAX)
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time FROM the SQL Server
	-- @scanObject used to store the data(@d)
	-- @t used to store the scandate
	-- @t used to store the scandata
	-- @CURSORID used to cursor
	-- @passCount used to COUNT the Success data
	-- @failureCount used to COUNT the Failure data
	-- @tempcount used to COUNT the data
	
	DECLARE @ReturnResult		AS VARCHAR(100)
	DECLARE @date				AS DATETIMEOFFSET(7)
	DECLARE @scanObject			AS Nvarchar(MAX)
	DECLARE @t					AS Nvarchar(MAX)
    DECLARE @d					AS Nvarchar(MAX)
    DECLARE @s					AS Nvarchar(100)
    DECLARE @CURSORID			AS INT
    DECLARE @failureCount		AS INT
    DECLARE @passCount			AS INT
    DECLARE @tempcount			AS INT
    DECLARE @Error				AS NVARCHAR(15)
	DECLARE @ErrorMessage		AS NVARCHAR(MAX)
	DECLARE @NameValuePairs		AS VARCHAR(MAX) 
    DECLARE @NameValuePair		AS VARCHAR(MAX)
	DECLARE @Name				AS VARCHAR(MAX)
	DECLARE @Value				AS VARCHAR(MAX)
	DECLARE @id					AS INT
	DECLARE @Count				AS INT
	DECLARE @Property TABLE ([id] INT ,[Name] VARCHAR(MAX),[Value] VARCHAR(MAX))
    
    /*Summary :Create Temporary table(for Internal Use)*/
	CREATE TABLE #TempScan(ID INT IDENTITY(1,1) NOT NULL,contentData NVARCHAR(Max))

	--CREATE TABLE #wholeTempScan(ID INT IDENTITY(1,1) NOT NULL,contentData1 Nvarchar(Max))

	SET @date			 =  SYSDATETIMEOFFSET();
	SET @b				 =  REPLACE(@b,'\','');
	SET @tempcount		 =  0;
	SET @failureCount	 =  0;
	SET @passCount		 =  0;
	IF(ISNULL(@a,'')='') SET @a = '';
	IF(ISNULL(@i,'')='') SET @i = '';
	IF(ISNULL(@b,'')='') SET @b = ''
		
	/* Summary: Raise an error message(400) If mandatory field Authentication String(@a),intserial number(@i),Data(@b) are not supplied. */
	IF(@a =  '' OR @i =  '' OR @b =  '')
	BEGIN
	    IF( @a =  ''AND @i =  '' AND @b =  '') EXEC upi_SystemEvents 'DeviceBackup',2307,3,''
        ELSE IF(@a =  '' AND @i =  '') EXEC upi_SystemEvents 'DeviceBackup',2311,3,''
        ELSE IF(@a =  '' AND  @b =  '') EXEC upi_SystemEvents 'DeviceBackup',2312,3,''
        ELSE IF(@b =  '' AND @i =  '') EXEC upi_SystemEvents 'DeviceBackup',2313,3,''
        ELSE IF(@a =  '') EXEC upi_SystemEvents 'DeviceBackup',2301,3,''
        ELSE IF(@i =  '') EXEC upi_SystemEvents 'DeviceBackup',2314,3,''	
        ELSE IF(@b =  '') EXEC upi_SystemEvents 'DeviceBackup',2305,3,''	
        SET @ReturnResult =  '400'
	    SELECT @ReturnResult AS Returnvalue
	    RETURN;
	END
	
	/* Summary: Raise an error message (400). If InterceptorID record is not found for the given intserail number(@i) in the InterceptorID table. */
	IF(NOT EXISTS(SELECT 1 FROM dbo.tblInterceptorID WITH(NOLOCK)  WHERE IntSerial = @i))
	BEGIN
		EXEC upi_SystemEvents 'DeviceBackup',2303,3,@i
		SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue
		RETURN;
	END
	--select CONVERT(VARCHAR(40),HASHBYTES('SHA1','1111111111'),2)
	/* Summary: Raise an error message (400). Create an SHA1 hexdigest of InterceptorID[embeddedID]. If hexdigest does not match passed authentication String(@a) */
	IF(@a <> (SELECT top 1 CONVERT(VARCHAR(40),HASHBYTES('SHA1', EmbeddedId),2) FROM dbo.tblInterceptorID WITH(NOLOCK)  WHERE IntSerial = @i))
	BEGIN
	
		EXEC upi_SystemEvents 'DeviceBackup',2304,3,@a
		SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue
	    RETURN;
	END

	/*Summary:Split the Unwanted Characters and Insert the Temporary Table */
	INSERT INTO #TempScan(contentData)SELECT items FROM Splitrow((select REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(REPLACE(@b,'},{','}#{'),'{',''),'}',''),'"',''),'[',''),']','')),'#')
	SET @tempcount = (SELECT COUNT(*) FROM #TempScan)
	

	DECLARE DEVICESCAN_CURSOR CURSOR FOR SELECT t.ID FROM dbo.#TempScan t WITH(NOLOCK)
	OPEN DEVICESCAN_CURSOR;  
	FETCH NEXT FROM DEVICESCAN_CURSOR INTO @CURSORID;
	WHILE @@FETCH_STATUS =  0  
				   BEGIN
					    SET @id = 0;
						SELECT @NameValuePairs  =  D.contentData FROM dbo.#TempScan D WITH(NOLOCK)  WHERE D.ID =  @CURSORID
						WHILE LEN(@NameValuePairs) > 0
						BEGIN
							SET  @id = @id+1;
							SET @NameValuePair =  LEFT(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs) - 1, -1),LEN(@NameValuePairs)))
							SET @NameValuePairs =  SUBSTRING(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs), 0),LEN(@NameValuePairs)) + 1, LEN(@NameValuePairs))
							SET @Name = LTRIM(RTRIM(SUBSTRING(@NameValuePair, 1, CHARINDEX(':', @NameValuePair) - 1)))
							SET @Value = LTRIM(RTRIM(SUBSTRING(@NameValuePair, CHARINDEX(':', @NameValuePair) + 1, LEN(@NameValuePair))))
                            INSERT INTO @Property ([id], [Name], [Value] ) VALUES ( @id,@Name, @Value )
						END
						SET @d = '';
                        SET @t = '';
                        SET @s = '';
                        SET @Error = ''; 
						SET @Count =  (SELECT COUNT(*) FROM @Property )
						
                        DECLARE @ic	int
                        SET @ic = 1
                        
                        WHILE( @ic < =  @Count)
                        BEGIN
							 SET @Name = (SELECT Name FROM @Property WHERE id = @ic)
							 SET @Value = (SELECT [Value] FROM @Property WHERE id = @ic)
							 SET @ic = @ic + 1;
                             IF(LOWER(@Name) =  'd') SET @d = @Value;
							 ELSE IF(LOWER(@Name) =  't') SET @t = @Value; 
							 ELSE IF(LOWER(@Name) =  's') SET @s = CONVERT(VARCHAR,@Value); 
							 ELSE
							 BEGIN
								SET  @Error = 'Error'; 
							 END 
                        END 
                        
                        /*Summary: If @t and @d are passed then proceed other wise increment the failure COUNT*/
                        
				   	   	IF(ISNULL(@t,'')<>'' AND ISNULL(@d,'')<>'' AND  ISNULL(@s,'')<> '')
				   	   	BEGIN 	 
				   	   	/*Summary:Increment the failure COUNT.If Spilted values  @t(scan date) is not timeoffset date format otherwise Increment Passed COUNT */ 
						IF (CHARINDEX('T',@t) <> 0 AND (CHARINDEX('+',@t) <> 0 OR CHARINDEX('-',@t) <> 0  OR CHARINDEX('Z',@t) <> 0) )
				   	    BEGIN
				   			DECLARE @zone AS VARCHAR(50)
				   			DECLARE @date2 AS VARCHAR(50)
				   			DECLARE @date3 AS VARCHAR(50)
				   			DECLARE @time1 AS VARCHAR(18)
				   			DECLARE @zonehh AS VARCHAR(4)
				   			DECLARE @zonemm AS VARCHAR(4)
							IF(CHARINDEX('Z',@t)<> 0)
							BEGIN
								SET @date2 = (SELECT SUBSTRING(@t,1,CHARINDEX('T',@t)-1))
				   				SET @zone = (SELECT SUBSTRING(@t,CHARINDEX('T',@t)+1,LEN(@t)))
				   				SET @time1 = (SELECT SUBSTRING(@zone,1,CHARINDEX('Z',@zone)-1))
								SET @zonehh ='00'
				   			    SET @zonemm ='00' 
							END
				   			ELSE IF(CHARINDEX('+',@t) <> 0)
				   			BEGIN
				   				SET @date2 = (SELECT SUBSTRING(@t,1,CHARINDEX('+',@t)-1))
				   				SET @zone = (SELECT SUBSTRING(@t,CHARINDEX('+',@t)+1,LEN(@t)))
				   				SET @time1 = (SELECT SUBSTRING(@date2,CHARINDEX('T',@date2)+1,LEN(@date2)))
				   				SET @date2 = (SELECT SUBSTRING(@t,1,CHARINDEX('T',@t)-1))
								SET @zonehh = (SELECT SUBSTRING(@zone,1,CHARINDEX(':',@zone)-1))
				   			    SET @zonemm = (SELECT SUBSTRING(@zone,CHARINDEX(':',@zone)+1,LEN(@zone)))
							END
				   			ELSE IF(CHARINDEX('-',@t) <> 0)
				   			BEGIN
				   				SET @date2 = (SELECT SUBSTRING(@t,1,CHARINDEX('T',@t)-1))
				   				SET @zone = (SELECT SUBSTRING(@t,CHARINDEX('T',@t)+1,LEN(@t)))
				   				SET @time1 = (SELECT SUBSTRING(@zone,1,CHARINDEX('-',@zone)-1))
				   				SET @zone = (SELECT SUBSTRING(@zone,CHARINDEX('-',@zone)+1,LEN(@zone)))
								SET @zonehh = (SELECT SUBSTRING(@zone,1,CHARINDEX(':',@zone)-1))
				   			    SET @zonemm = (SELECT SUBSTRING(@zone,CHARINDEX(':',@zone)+1,LEN(@zone)))
							END
							IF(ISDATE(@date2) =  1)
							BEGIN
							   DECLARE @time2 AS VARCHAR(30)
							   DECLARE @time3 AS VARCHAR(12)
							   SET @time2 = REPLACE(REPLACE(@time1,':',''),'.','')

							   IF(ISNUMERIC(@time2) = 1)
							   BEGIN
							   SET @time3 = (SELECT SUBSTRING(@time1,1,12))
						       SET @date3 = @date2+' '+@time3
						       IF(ISDATE(@date3) =  1)
						       BEGIN
									IF((@zonehh between '00' and '14') AND (@zonemm between '00' and '59'))
									BEGIN
									/*Summary:IF Spilted values  @d(scan data) is contain '~'  then proceed otherwise increment the Passedcount   */ 
									IF((CHARINDEX('~',@d)) <> 0) 
				   		  			BEGIN
				   		  				/*Summary:IF Spilted values  @d(scan data) is contain '~' and '/' and get the dyncid then increment the Passedcount otherwise increment the failure COUNT   */ 
				   		  				  				
				   		  				IF(ISNUMERIC((SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) =  1)
				   		 				BEGIN
				   		 					SET  @passCount = @passCount + 1;
										END
										ELSE IF(@d  like '%deleteItem/next%' or @d like '%deleteItem/prev%' or @d like '%returnitem/pass' or @d like '%returnitem/nopass')
										BEGIN
				   		 					SET  @passCount = @passCount + 1;
										END
										ELSE
								 		/*Summary:Increment the failure COUNT.IF Spilted values  @d(scan data) is does not contain '~' and '/' */
								    	BEGIN
											SET @failureCount = @failureCount + 1;
											SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue
											EXEC upi_SystemEvents 'DeviceBackup',2306,3,@d
											RETURN;
										END
									END
									/*Summary:Increment the Passed COUNT.IF Spilted values  @d(scan data) is does not contain '~'  */
									ELSE
									BEGIN
										SET  @passCount = @passCount + 1;
									END 
								END
								ELSE
								BEGIN
									/*Summary:Increment the faliure COUNT.IF Spilted values  @d(scan data) is not Passed */
									SET @failureCount =  @failureCount+1
									SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue
								    RETURN;
								END
							END
							ELSE 
							BEGIN
							    /*Summary:Increment the faliure COUNT.IF Spilted values  @d(scan data) is not Passed */
								SET @failureCount =  @failureCount+1
								SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue
								RETURN;
							END
						END
						ELSE 
						BEGIN
							/*Summary:Increment the faliure COUNT.IF Spilted values  @t(scan date) is not correct format */
							SET @failureCount =  @failureCount+1
							SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue
							RETURN;
						END
					END
					ELSE 
					BEGIN
						/*Summary:Increment the faliure COUNT.IF Spilted values  @t(scan date) is not correct format */
						SET @failureCount =  @failureCount+1
						SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue
						RETURN;
					END
				END
				ELSE
				BEGIN
					/*Summary:Increment the faliure COUNT.IF Spilted values  @t(scan date) is not correct format */
					SET @failureCount = @failureCount + 1;
					SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue
					EXEC upi_SystemEvents 'DeviceBackup',2306,3,@d
					RETURN;
				END
			END
			ELSE
			BEGIN
				/*Summary:Increment the faliure COUNT. IF Spilted values @t(scan date) and @d(scan data) are missing */
				SET @failureCount = @failureCount + 1;
				SET @ReturnResult =  '400' SELECT @ReturnResult AS Returnvalue1
				EXEC upi_SystemEvents 'DeviceBackup',2305,3,@d
				RETURN;
		    END
			DELETE FROM @Property
            SET @ic = @ic+1;
      	FETCH NEXT FROM DEVICESCAN_CURSOR INTO @CURSORID;
		END
		CLOSE DEVICESCAN_CURSOR;
		DEALLOCATE DEVICESCAN_CURSOR;
		
		/*Summary:Return 201 created.If @tempcount and @passcount is equal */
		IF(@tempcount =  @passCount)
		BEGIN
			 IF (NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA =  'dbo' AND  TABLE_NAME =  'tblTempdevicescan'))
			 BEGIN
				    CREATE TABLE [dbo].tblTempdevicescan( [Id] [int] IDENTITY(1,1) primary key NOT NULL,a [VARCHAR](50) NOT NULL,i [VARCHAR](12) NOT NULL,b Nvarchar(MAX) NOT NULL,status varchar(5) NULL)
				END
		    insert into tblTempdevicescan(a,i,b,status) values(@a,@i,@b,'1')
		   SET @ReturnResult =  '201' SELECT @ReturnResult AS Returnvalue
		   RETURN;
	    END
		
	END
--EXEC upi_DeviceBackup_Authenticate 'F7C3BC1D808E04732ADF679965CCC34CA7AE3441','INT123456123','{{"t":"2014-01-22T21:56:44.5126931Z","s":"1","d":"XYAZS"}'
--EXEC upi_DeviceBackup_Authenticate 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111','[ { "t": "2014-02-10T15:47:47.0371937Z", "s": "395", "d": "123456789012" } ]'
--EXEC upi_DeviceBackup_Authenticate 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111','{\"t\":\"2013-06-18T16:50:55.003+05:30\",\"s\":\"1\",\"d\":\"~65/*CH*ABC\"},{\"t\":\"2013-05-18T11:32:55.0030000+00:00\",\"s\":\"1\",\"d\":\"Contentcode4\"},{\"t\":\"2013-05-18T11:33:55.0030000+00:00\",\"s\":\"1\",\"d\":\"ContentNotMatch\"},{\"t\":\"2013-05-18T11:34:55.0030000+00:00\",\"s\":\"1\",\"d\":\"~65/*CH*Contentcode2\"},{\"t\":\"2013-05-18T11:34:55.0030000+00:00\",\"s\":\"1\",\"d\":\"~75/deleteItem/next\"}'
--EXEC upi_DeviceBackup_Authenticate 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111','{"t":"2014-02-10T15:47:47.0371937Z","s":"395","d":"123456789012"},{"t":"2014-02-10T15:58:53.3182569Z","s":"397","d":"123456789012"},{"t":"1970-01-01T05:39:28.57+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:34.15+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:36.46+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:37.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:40.85+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.27+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:42.11+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:57.53+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:58.63+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:02.73+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:03.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:04.74+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:05.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:06.81+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:07.9+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"2014-02-10T15:58:53.3182569Z","s":"397","d":"123456789012"},{"t":"1970-01-01T05:39:28.57+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:34.15+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:36.46+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:37.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:40.85+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.27+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:42.11+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:57.53+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:58.63+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:02.73+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:03.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:04.74+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:05.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:06.81+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:07.9+05:30","s":"409","d":"123456789012"},{"t":"2014-02-10T15:58:53.3182569Z","s":"397","d":"123456789012"},{"t":"1970-01-01T05:39:28.57+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:34.15+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:36.46+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:37.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:40.85+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.27+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:42.11+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:57.53+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:58.63+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:40.85+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.27+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:42.11+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:57.53+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:58.63+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.27+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:42.11+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:57.53+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:58.63+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:02.73+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:03.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:04.74+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:05.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:06.81+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:07.9+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:08.87+05:30","s":"409","d":"123456789012"},{"t":"2014-02-10T15:58:53.3182569Z","s":"397","d":"123456789012"},{"t":"1970-01-01T05:39:28.57+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:34.15+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:36.46+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:37.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:40.85+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.27+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:42.11+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:57.53+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:58.63+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:02.73+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:03.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:04.74+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:05.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:06.81+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:07.9+05:30","s":"409","d":"123456789012"},{"t":"2014-02-10T15:58:53.3182569Z","s":"397","d":"123456789012"},{"t":"1970-01-01T05:39:28.57+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:34.15+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:36.46+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:37.75+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:40.85+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.27+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:42.11+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:57.53+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:58.63+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:40.85+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.27+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:41.76+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:42.11+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:57.53+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:58.63+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:01.69+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:39:59.6+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"},{"t":"1970-01-01T05:40:00.67+05:30","s":"409","d":"123456789012"}'
--EXEC upi_DeviceBackup_Authenticate 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111','{"t":"2013-05-18T11:30:55.0030000+00:00","d":"~65/*CH*ABC"},{"t":"2013-05-18T11:30:55.0030000+00:00","d":"cozumodb1"}'



GO
/****** Object:  StoredProcedure [dbo].[upi_DeviceBackup_callForwardURL]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Author:		Prakash G
-- Create date: 26.06.2013
-- Routine:		DeviceBackup(upi_DeviceBackup_callForwardURL)
-- Method:		POST
-- Description:	Handles HTTP requests (from Interceptor devices) that are uploading
--				backed up scan data (Interceptors locally backup scan data if API connection
--				is lost, then bulk upload scan data when connection re-established)
-- =============================================================================================
CREATE PROCEDURE [dbo].[upi_DeviceBackup_callForwardURL] 
	
	@a VARCHAR(40),
	@i VARCHAR(12),
	@b NVARCHAR(MAX),
	@tempid varchar(50)
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @eventData used to store event data description 
	
	DECLARE @ReturnResult		AS	VARCHAR(MAX)
	DECLARE @date				AS	DATETIMEOFFSET(7)
	DECLARE @severData			AS	VARCHAR(50)
	DECLARE @scanObject			AS	NVARCHAR(MAX)
	DECLARE @t					AS	NVARCHAR(MAX)
    DECLARE @d					AS	NVARCHAR(500)
    DECLARE @s					AS	NVARCHAR(100)
    DECLARE @CURSORID			AS	INT
    DECLARE @Error				AS	NVARCHAR(15)
	DECLARE @ErrorMessage		AS	NVARCHAR(MAX)
	DECLARE @NameValuePairs		AS	VARCHAR(MAX) 
    DECLARE @NameValuePair		AS	VARCHAR(100)
	DECLARE @Name				AS	VARCHAR(50)
	DECLARE @Value				AS	VARCHAR(100)
	DECLARE @id					AS	INT
	DECLARE @Count				AS	INT
	DECLARE @date1				AS	DATETIMEOFFSET(7)
	Declare @intOrgId			AS  varchar(5);
	Declare @intLocId			AS  varchar(5);
		
	DECLARE @Property TABLE ([id] INT ,[Name] VARCHAR(50),[Value] VARCHAR(50))
	
	SET @date =  SYSDATETIMEOFFSET();
    SET @b =   REPLACE(@b,'\','');
    
    
	/* Summary:Split the Unwanted Characters and Insert the Temporary Table */
	--SET @scanObject =  REPLACE(@b,'},{','}#{');

	

	SET @scanObject =  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(@b,'{',''),'}',''),'"',''),'[',''),']','');
		   	   
				   	    SET @id = 0;
						SET @NameValuePairs  = @scanObject
						WHILE LEN(@NameValuePairs) > 0
						BEGIN
						    SET  @id = @id+1;
							SET @NameValuePair =  LEFT(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs) - 1, -1),LEN(@NameValuePairs)))
						    SET @NameValuePairs =  SUBSTRING(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs), 0),LEN(@NameValuePairs)) + 1, LEN(@NameValuePairs))
							SET @Name	 =  LTRIM(RTRIM(SUBSTRING(@NameValuePair, 1, CHARINDEX(':', @NameValuePair) - 1)))
							SET @Value	 =  LTRIM(RTRIM(SUBSTRING(@NameValuePair, CHARINDEX(':', @NameValuePair) + 1, LEN(@NameValuePair))))
							INSERT INTO @Property ([id], [Name], [Value])VALUES (@id,@Name, @Value)
						END
						SET @d = '';
                        SET @t = '';
                        SET @s = '';
                        SET @Error = ''; 
						SET @Count =  (SELECT count(*) FROM @Property)
                        DECLARE @i1	int
                        SET @i1 = 1
                        WHILE(@i1 < =  @Count)
                        BEGIN
							SET @Name = (SELECT Name FROM @Property  WHERE id = @i1)
							SET @Value = (SELECT [Value] FROM @Property WHERE id = @i1)
							SET @i1 = @i1 + 1;
							IF(LOWER(@Name) =  'd')
								SET @d =  @Value;
							ELSE IF(LOWER(@Name) =  't') 
							BEGIN
								SET @t =   LTRIM(Rtrim(@Value)); 
								SET @t=Replace(@t,' ','');
							END	
							ELSE IF(LOWER(@Name) =  's') 
								SET @s =  @Value
							ELSE
							BEGIN
                            SET  @Error = 'Error';
							END 
						END 
						IF(@Error = '')
						BEGIN
						   INSERT INTO tblDeviceScan(IntSerial,ScanDate,ScanData,CallHomeRedmptionData,ScanSession)VALUES(@i,CONVERT(DATETIMEOFFSET(7),@t),@d,'',@s);
						END
						--DELETE FROM @Property
                       --  SET @i1 = @i1+1
       
	   update  tblTempdevicescan set status='0' where a=@a and i=@i and id=@tempid
	                 
 /* Summary: Check the Interceptor[forwardURL] field. If it  is not empty, the do the following */	 
 IF((SELECT TOP 1 forwardURL FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i) < > '')
 BEGIN
 /* Summary: if Interceptor[forwardType] =  1 (batch forwarding) then do the folowing step*/
	IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i),'') =  '1' OR ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i),'') =  '3')
    BEGIN
    /*Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.*/
		IF(@d LIKE '%*CH*%')
		BEGIN	
			/*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first “/” */
			IF EXISTS(SELECT 1 FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2)))
			BEGIN
			 (SELECT CONVERT(VARCHAR,@i)+'|'+CONVERT(NVARCHAR(30), SYSDATETIMEOFFSET(), 126)+'|'+CONVERT(VARCHAR(MAX),ISNULL(CallHomeURL,'0'))+'|'+CONVERT(VARCHAR,ISNULL(CallHomeData,'0')) FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2)))
			  RETURN;
			END
			/*Summary: if does not exist records in DynamicCode  then Error(BadRequest) */
			ELSE 
			SELECT '201'
		END
		ELSE
		BEGIN
			SELECT 'NOTDYNAMIC'
		END
	END
	ELSE IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i),'') =  '0')
	BEGIN
	/*Summary:Use the passed i to get the Interceptor record.*/
	IF(EXISTS(SELECT 1 FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i))
		BEGIN
		    SET @intOrgId=(SELECT TOP 1 OrgId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i) 
			SET @intLocId=(SELECT TOP 1 LocId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i)
		      /*Summary :To Check the @d(Data) is Dynamic or Not */
		         IF(@d like '%~%')
		         BEGIN
		         /*Summary :To Check the @d(Data) is Special Dynamic or Not */
		    	  	   IF(@d  like '%DeleteItem/next%' or @d like '%DeleteItem/prev%' or @d like '%returnitem/pass%' or @d like '%returnitem/nopass%')
             			BEGIN
             			/*Summay:Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code] */
             			IF EXISTS (SELECT 1 FROM dbo.tblContent C WITH(NOLOCK) WHERE C.Code =  SUBSTRING(@d,14,len(@d)) AND C.OrgId =@intOrgId)
						BEGIN
							/*Summay: If Content records found return the following fields */
							SELECT '<list>'+(
								SELECT TOP 1 ISNULL(I.IntSerial,'') AS 'IntSerial', ISNULL(I.IntLocDesc,'') AS 'IntLocDesc', ISNULL(O.OrgName,'') AS 'OrgName', ISNULL(L.UnitSuite,'') AS 'UnitSuite',ISNULL(L.Street,'') AS 'Street',
								ISNULL(L.City,'') AS 'City',ISNULL(L.State,'') AS 'State',ISNULL(L.Country,'') AS 'Country',ISNULL(L.PostalCode,'') AS 'PostalCode',ISNULL(L.LocType,'') AS 'LocType',ISNULL(L.LocSubType,'') AS 'LocSubType',
								ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',@d AS 'Code','^!%' AS 'CellPhone', '^!%' AS 'MetaData',ISNULL(C.Category,'') AS 'Category',ISNULL(C.Model,'') AS 'Model',ISNULL(C.Manufacturer,'') AS 'Manufacturer',
								ISNULL(C.PartNumber,'') AS 'PartNumber',ISNULL(C.ProductLine,'') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'') AS 'ManufacturerSKU',ISNULL(C.Description,'') AS 'Description',
								ISNULL(C.UnitMeasure,'') AS 'UnitMeasure',ISNULL(C.UnitPrice,'') AS 'UnitPrice',ISNULL(C.Misc1,'') AS 'Misc1', ISNULL(C.Misc2,'') AS 'Misc2',ISNULL(I.ForwardURL,'') AS 'ForwardURL',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O  WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C  WITH(NOLOCK) ON C.OrgId =@intOrgId
								WHERE I.OrgId = @intOrgId AND  O.OrgId =  @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =@i AND D.ScanData = @d
								AND C.Code =  SUBSTRING(@d,14,len(@d))
							FOR XML RAW )+'</list>'
							RETURN;
						END
						ELSE
						/*Summay: If Content records not found return the following fields */
						BEGIN
							SELECT '<list>'+(
							 	SELECT TOP 1 ISNULL(I.IntSerial,'') AS 'IntSerial', ISNULL(I.IntLocDesc,'') AS 'IntLocDesc', ISNULL(O.OrgName,'') AS 'OrgName', ISNULL(L.UnitSuite,'') AS 'UnitSuite', ISNULL(L.Street,'') AS 'Street',
								ISNULL(L.City,'') AS 'City',ISNULL(L.State,'') AS 'State',ISNULL(L.Country,'') AS 'Country',ISNULL(L.PostalCode,'') AS 'PostalCode',ISNULL(L.LocType,'') AS 'LocType',ISNULL(L.LocSubType,'') AS 'LocSubType',
								ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',@d AS 'Code','^!%' AS 'CellPhone', '^!%' AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
								'^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
								'^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',ISNULL(I.ForwardURL,'') AS 'ForwardURL',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L 
								WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial 
								WHERE I.OrgId = @intOrgId AND  O.OrgId = @intOrgId AND L.OrgId = @intOrgId AND L.LocId=@intLocId AND D.IntSerial = @i AND D.ScanData = @d
							FOR XML RAW )+'</list>'
							RETURN;
						END
						END
						/*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first “/” */
							ELSE IF(NOT EXISTS(SELECT 1 FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
								SELECT '<list>'+(
								SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
								'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
								'0' AS 'ScanDate','0' AS 'ScanSession','0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
								'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
								'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL',
								'0' AS 'ErrId' FOR XML RAW )+'</list>'
								EXEC upi_SystemEvents 'DeviceBackup',2308,3,@d
							   RETURN;
							END
							/*Summay:Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code] */
							ELSE
							IF EXISTS (SELECT 1 FROM dbo.tblContent C WITH(NOLOCK) WHERE C.OrgId = @intOrgId  AND 
							C.Code =  (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
							/*Summay: If Content records found return the following fields */
								SELECT '<list>'+(
								SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'') AS 'IntLocDesc',ISNULL(O.OrgName,'') AS 'OrgName', ISNULL(L.UnitSuite,'') AS 'UnitSuite', ISNULL(L.Street,'') AS 'Street',
								ISNULL(L.City,'') AS 'City',ISNULL(L.State,'') AS 'State',ISNULL(L.Country,'') AS 'Country',ISNULL(L.PostalCode,'') AS 'PostalCode',ISNULL(L.LocType,'') AS 'LocType',ISNULL(L.LocSubType,'') AS 'LocSubType',
								ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'') AS 'Code',ISNULL(DC.CellPhone,'') AS 'CellPhone',ISNULL(DC.MetaData,'') AS 'MetaData',ISNULL(C.Category,'') AS 'Category',ISNULL(C.Model,'') AS 'Model',ISNULL(C.Manufacturer,'') AS 'Manufacturer',  
								ISNULL(C.PartNumber,'') AS 'PartNumber',ISNULL(C.ProductLine,'') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'') AS 'ManufacturerSKU',ISNULL(C.Description,'') AS 'Description',
								ISNULL(C.UnitMeasure,'') AS 'UnitMeasure', ISNULL(C.UnitPrice,'') AS 'UnitPrice',ISNULL(C.Misc1,'') AS 'Misc1',ISNULL( C.Misc2,'') AS 'Misc2',ISNULL(I.ForwardURL,'') AS 'ForwardURL',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C WITH(NOLOCK) ON C.OrgId =  I.OrgId
								JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId = @intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d
								AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								FOR XML RAW )+'</list>'
							   RETURN;
							END
							ELSE
							/*Summay: If Content records not found return the following fields */
							BEGIN
								SELECT '<list>'+(
								SELECT TOP 1 ISNULL(I.IntSerial,'') AS 'IntSerial',ISNULL(I.IntLocDesc,'') AS 'IntLocDesc',ISNULL(O.OrgName,'') AS 'OrgName', ISNULL(L.UnitSuite,'') AS 'UnitSuite', ISNULL(L.Street,'') AS 'Street',
								ISNULL(L.City,'') AS 'City',ISNULL(L.State,'') AS 'State',ISNULL(L.Country,'') AS 'Country',ISNULL(L.PostalCode,'') AS 'PostalCode',ISNULL(L.LocType,'') AS 'LocType',ISNULL(L.LocSubType,'') AS 'LocSubType',
								ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'') AS 'Code',ISNULL(DC.CellPhone,'') AS 'CellPhone',ISNULL(DC.MetaData,'') AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
								'^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
								'^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',ISNULL(I.ForwardURL,'') AS 'ForwardURL',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblDynamicCode DC  WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId =@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								FOR XML RAW )+'</list>'
								RETURN;
							END
						
						/*Summay: Check if DeviceScan[scanData] is not a dynamic code */
						/*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
						END
						ELSE IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code =  @d AND C.OrgId =@intOrgId)
						BEGIN
						/*Summay: If Content records found return the following fields */
							SELECT '<list>'+(
								SELECT TOP 1 ISNULL(I.IntSerial,'') AS 'IntSerial', ISNULL(I.IntLocDesc,'') AS 'IntLocDesc', ISNULL(O.OrgName,'') AS 'OrgName', ISNULL(L.UnitSuite,'') AS 'UnitSuite',ISNULL(L.Street,'') AS 'Street',
								ISNULL(L.City,'') AS 'City',ISNULL(L.State,'') AS 'State',ISNULL(L.Country,'') AS 'Country',ISNULL(L.PostalCode,'') AS 'PostalCode',ISNULL(L.LocType,'') AS 'LocType',ISNULL(L.LocSubType,'') AS 'LocSubType',
								ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(D.ScanData,'') AS 'Code','^!%' AS 'CellPhone', '^!%' AS 'MetaData',ISNULL(C.Category,'') AS 'Category',ISNULL(C.Model,'') AS 'Model',ISNULL(C.Manufacturer,'') AS 'Manufacturer',
								ISNULL(C.PartNumber,'') AS 'PartNumber',ISNULL(C.ProductLine,'') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'') AS 'ManufacturerSKU',ISNULL(C.Description,'') AS 'Description',
								ISNULL(C.UnitMeasure,'') AS 'UnitMeasure',ISNULL(C.UnitPrice,'') AS 'UnitPrice',ISNULL(C.Misc1,'') AS 'Misc1', ISNULL(C.Misc2,'') AS 'Misc2',ISNULL(I.ForwardURL,'') AS 'ForwardURL',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C WITH(NOLOCK) ON C.OrgId =  @intOrgId
								WHERE O.OrgId =  @intOrgId AND L.OrgId = @intOrgId  AND L.LocId=@intLocId AND D.IntSerial =  @i 
								AND D.ScanData = @d AND C.Code =  @d
							FOR XML RAW )+'</list>'
							RETURN;
						END
						ELSE
						/*Summay: If Content records not found return the following fields */
						BEGIN
							SELECT '<list>'+(
							 	SELECT TOP 1 ISNULL(I.IntSerial,'') AS 'IntSerial', ISNULL(I.IntLocDesc,'') AS 'IntLocDesc', ISNULL(O.OrgName,'') AS 'OrgName', ISNULL(L.UnitSuite,'') AS 'UnitSuite', ISNULL(L.Street,'') AS 'Street',
								ISNULL(L.City,'') AS 'City',ISNULL(L.State,'') AS 'State',ISNULL(L.Country,'') AS 'Country',ISNULL(L.PostalCode,'') AS 'PostalCode',ISNULL(L.LocType,'') AS 'LocType',ISNULL(L.LocSubType,'') AS 'LocSubType',
								ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(D.ScanData,'') AS 'Code','^!%' AS 'CellPhone', '^!%' AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
								'^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
								'^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',ISNULL(I.ForwardURL,'') AS 'ForwardURL',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId = @intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d 
							FOR XML RAW )+'</list>'
							RETURN;
						END
					END--Check Intserial END
					END-- Check forward type = 0 end
					ELSE IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i),'') =  '2')
					BEGIN
					/*Summary:Use the passed i to get the Interceptor record.*/
					IF(EXISTS(SELECT 1 FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i))
					BEGIN
						SET @intOrgId=(SELECT TOP 1 OrgId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i) 
						SET @intLocId=(SELECT TOP 1 LocId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i)
		   			 /*Summary :To Check the @d(Data) is Dynamic or Not */
				       IF(@d like '%~%' AND( @d NOT like '%DeleteItem/next%' AND @d NOT like '%DeleteItem/prev%' AND @d Not like '%returnitem/pass%' and @d not like '%returnitem/nopass%'))
					   BEGIN
							/*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first “/” */
							IF(NOT EXISTS(SELECT 1 FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
								SELECT '<list>'+(
								SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
								'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
								'0' AS 'ScanDate','0' AS 'ScanSession','0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
								'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
								'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL',
								'0' AS 'ErrId' FOR XML RAW )+'</list>'
								EXEC upi_SystemEvents 'DeviceBackup',2308,3,@d
							   RETURN;
							END
							/*Summay:Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code] */
							ELSE
							IF EXISTS (SELECT 1 FROM dbo.tblContent C WITH(NOLOCK) WHERE C.OrgId = @intOrgId  AND 
							C.Code =  (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
							/*Summay: If Content records found return the following fields */
								SELECT '<list>'+(
								SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'') AS 'IntLocDesc',ISNULL(O.OrgName,'') AS 'OrgName', ISNULL(L.UnitSuite,'') AS 'UnitSuite', ISNULL(L.Street,'') AS 'Street',
								ISNULL(L.City,'') AS 'City',ISNULL(L.State,'') AS 'State',ISNULL(L.Country,'') AS 'Country',ISNULL(L.PostalCode,'') AS 'PostalCode',ISNULL(L.LocType,'') AS 'LocType',ISNULL(L.LocSubType,'') AS 'LocSubType',
								ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'') AS 'Code',ISNULL(DC.CellPhone,'') AS 'CellPhone',
								ISNULL(DC.MetaData,'') AS 'MetaData',ISNULL(C.Category,'') AS 'Category',ISNULL(C.Model,'') AS 'Model',ISNULL(C.Manufacturer,'') AS 'Manufacturer',  
								ISNULL(C.PartNumber,'') AS 'PartNumber',ISNULL(C.ProductLine,'') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'') AS 'ManufacturerSKU',ISNULL(C.Description,'') AS 'Description',
								ISNULL(C.UnitMeasure,'') AS 'UnitMeasure', ISNULL(C.UnitPrice,'') AS 'UnitPrice',ISNULL(C.Misc1,'') AS 'Misc1',ISNULL( C.Misc2,'') AS 'Misc2',ISNULL(I.ForwardURL,'') AS 'ForwardURL',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C WITH(NOLOCK) ON C.OrgId =  I.OrgId
								JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId = @intOrgId AND L.LocId=@intLocId  AND D.IntSerial =  @i AND D.ScanData = @d
								AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								FOR XML RAW )+'</list>'
							   RETURN;
							END
							ELSE
							/*Summay: If Content records not found return the following fields */
							BEGIN
								SELECT '<list>'+(
								SELECT TOP 1 ISNULL(I.IntSerial,'') AS 'IntSerial',ISNULL(I.IntLocDesc,'') AS 'IntLocDesc',ISNULL(O.OrgName,'') AS 'OrgName', ISNULL(L.UnitSuite,'') AS 'UnitSuite', ISNULL(L.Street,'') AS 'Street',
								ISNULL(L.City,'') AS 'City',ISNULL(L.State,'') AS 'State',ISNULL(L.Country,'') AS 'Country',ISNULL(L.PostalCode,'') AS 'PostalCode',ISNULL(L.LocType,'') AS 'LocType',ISNULL(L.LocSubType,'') AS 'LocSubType',
								ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'') AS 'Code',ISNULL(DC.CellPhone,'') AS 'CellPhone',ISNULL(DC.MetaData,'') AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
								'^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
								'^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',ISNULL(I.ForwardURL,'') AS 'ForwardURL',
								'0' AS 'ErrId'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId =  @intOrgId	AND O.OrgId = @intOrgId AND L.OrgId =@intOrgId AND L.LocId=@intLocId 
								AND D.IntSerial =  @i AND D.ScanData = @d AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								FOR XML RAW )+'</list>'
								RETURN;
							END --No content Rec match
					
						END--Dynamic Rec END
						ELSE
						BEGIN
							SELECT '<list>'+(
								SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
								'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
								'0' AS 'ScanDate','0' AS 'ScanSession','0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
								'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
								'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL',
								'0' AS 'ErrId' FOR XML RAW )+'</list>'
								EXEC upi_SystemEvents 'DeviceBackup',2308,3,@d
							   RETURN;
						END
					END--Check Intserial END
					END--check forward type-2
					--
 END--check forward url end
 ELSE
 BEGIN
	SET @ReturnResult =  '201' SELECT @ReturnResult AS Returnvalue
	RETURN;
 END
END
--EXEC upi_DeviceBackup_callForwardURL 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111','{"t":"2013-06-18T11:20:55.0030000+00:00","s":"1","d":"~65/*CH*ABC"}'
--,{"t":"2013-05-18T11:32:55.0030000 +00:00","s":"1","d":"Contentcode4"},{"t":"2013-05-18T11:33:55.0030000 +00:00","s":"1","d":"ContentNotMatch"},{"t":"2013-05-18T11:34:55.0030000 +00:00","s":"1","d":"~65/*CH*Contentcode2"},{"t":"2013-05-18T11:34:55.0030000 +00:00","s":"1","d":"~75/deleteItem/next"}'
--EXEC upi_DeviceBackup_callForwardURL '2966C08B8EB3D42C71F04C89FFBECB44059154C5','887010785102','{"t":"2013-05-18T11:55:55.003000 +00:00","s":"1","d":"super"}'
--EXEC upi_DeviceBackup_callForwardURL 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111','{"t":"2013-05-18T11:32:55.0030000 +00:00","s":"1","d":"Contentcode4"}'



GO
/****** Object:  StoredProcedure [dbo].[upi_DeviceBackup_checkForwardType]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Author:		Prakash G
-- Create date: 26.06.2013
-- Routine:		DeviceBackup(upi_DeviceBackup_checkForwardType)
-- Method:		POST
-- Description:	Handles HTTP requests (from Interceptor devices) that are uploading
--				backed up scan data (Interceptors locally backup scan data if API connection
--				is lost, then bulk upload scan data when connection re-established)
-- =============================================================================================
--EXEC upi_DeviceBackup_checkForwardType12 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111',' { "t": "2014-02-10T15:47:47.0371937Z", "s": "395", "d": "123456789012" }',''
CREATE PROCEDURE [dbo].[upi_DeviceBackup_checkForwardType] 
	
	@a			VARCHAR(40),
	@i			VARCHAR(12),
	@b			NVARCHAR(MAX),
	@response	VARCHAR(MAX) 
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @eventData used to store event data description
	-- @scanObject used to store the @b item.
	-- @t used to store the scan Date
	-- @d used to store the scan Data
	-- @scandata used to store the Data
	
	DECLARE @ReturnResult		AS VARCHAR(100)
	DECLARE @date				AS DATETIMEOFFSET(7)
	DECLARE @scanObject			AS NVARCHAR(MAX)
	DECLARE @scandata			AS NVARCHAR(MAX)
    DECLARE @t					AS NVARCHAR(MAX)
    DECLARE @d					AS NVARCHAR(500)
    DECLARE @s					AS NVARCHAR(100)
    DECLARE @CURSORID			AS INT
    DECLARE @Error				AS NVARCHAR(15)
	DECLARE @ErrorMessage		AS NVARCHAR(MAX)
	DECLARE @NameValuePairs		AS VARCHAR(MAX) 
    DECLARE @NameValuePair		AS VARCHAR(100)
	DECLARE @Name				AS NVARCHAR(100)
	DECLARE @Value				AS NVARCHAR(100)
	DECLARE @id					AS INT
	DECLARE @Count				AS INT
	DECLARE @date1				AS DATETIMEOFFSET(7)
	Declare @intOrgId			AS  varchar(5);
	Declare @intLocId			AS  varchar(5);	

	DECLARE @Property TABLE ([id] INT ,[Name] NVARCHAR(100),[Value] NVARCHAR(100))
    
    SET @date		 =  SYSDATETIMEOFFSET();
	SET @scandata	 =  ''
	SET @b			 =  REPLACE(@b,'\','');
  	SET @scanObject =  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(@b,'{',''),'}',''),'"',''),'[',''),']','');
	print @scanObject

		   		SET @id = 0;
				SET @NameValuePairs= @scanObject
				print '@NameValuePairs'
				print @scanObject
				WHILE LEN(@NameValuePairs) > 0
					BEGIN
						SET  @id = @id+1;
	                        SET @NameValuePair =  LEFT(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs) - 1, -1),LEN(@NameValuePairs)))
							SET @NameValuePairs =  SUBSTRING(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs), 0),LEN(@NameValuePairs)) + 1, LEN(@NameValuePairs))
							SET @Name =  LTRIM(RTRIM(SUBSTRING(@NameValuePair, 1, CHARINDEX(':', @NameValuePair) - 1)))
							SET @Value =  LTRIM(RTRIM(SUBSTRING(@NameValuePair, CHARINDEX(':', @NameValuePair) + 1, LEN(@NameValuePair))))
							INSERT INTO @Property ([id], [Name], [Value]) VALUES ( @id,@Name, @Value )
						END
						SET @d = '';
                        SET @t = '';
                        SET @s = '';
                        SET @Error = ''; 
						SET @Count =  (SELECT count(*) FROM @Property)
                        DECLARE @ic	int
                        SET @ic = 1
                        WHILE( @ic < =  @Count)
                        BEGIN
							SET @Name = (SELECT Name FROM @Property WHERE id = @ic)
							SET @Value = (SELECT [Value] FROM @Property WHERE id = @ic)
							SET @ic = @ic + 1;
							IF(LOWER(@Name) =  'd')	SET @d = @Value;
							ELSE IF(LOWER(@Name) =  't') 
							BEGIN
								SET @t =   LTRIM(Rtrim(@Value)); 
								SET @t=Replace(@t,' ','');
							END   
							ELSE IF(LOWER(@Name) =  's') 
								SET @s = CONVERT(VARCHAR,@Value)
							ELSE
							BEGIN
								SET  @Error = 'Error'; 
							END 
						END 

						                     

             /*Summary:if Interceptor[forwardURL] =  0 then log sending of HTTP event in SystemEvents */

			 IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i),'') =  '0' OR ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i),'') =  '2')
             BEGIN
					SELECT '<list>'+(SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName','0' AS 'UnitSuite','0' AS 'Street',
			    			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
							'0' AS 'ScanDate','0' AS 'ForwardURL','0' AS 'ScanSession','0' AS 'ScanData','OK' AS 'ErrId' FOR XML RAW )+'</list>'
					EXEC upi_SystemEvents 'DeviceBackup',2309,1,@i
			  END
              ELSE
               /*Summary:if Interceptor[forwardURL] =  1 (batch forwarding) then do the following */
              IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i),'') =  '1')
              BEGIN
				  SET @intOrgId=(SELECT TOP 1 OrgId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i) 
				  SET @intLocId=(SELECT TOP 1 LocId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i)

                 /*Summary:if it doesn’t exist, create a temporary data store with the same fields as ScanBatches, called TempScanBatches*/

                   IF (NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA =  'dbo' AND  TABLE_NAME =  'tblTempScanBatches'))
				   BEGIN
				    CREATE TABLE [dbo].tblTempScanBatches( [Id] [int] IDENTITY(1,1) NOT NULL,[IntSerial] [VARCHAR](50) NOT NULL,[OrgName] [nVARCHAR](100) NOT NULL,[DeliveryTime] [DATETIMEOFFSET](7) NULL,[ForwardURL] [VARCHAR](100) NULL,
	                [UnitSuite] [VARCHAR](15) NULL,[Street] [nVARCHAR](100) NULL,[City] [VARCHAR](50) NULL,[State] [nVARCHAR](100) NULL,[Country] [VARCHAR](50) NULL,[PostalCode] [VARCHAR](10) NULL,[LocType] [nVARCHAR](50) NULL,[LocSubType] [nVARCHAR](50) NULL,
	                [IntLocDesc] [VARCHAR](100) NULL,[ScanData] [VARCHAR](max) NOT NULL)
				   END

				   /* Summary:If ScanBatches does not exist then create the new record  in TempScanBatches */
				     SET @scandata = '';

				   /*Summary :To Check the @d(Data) is Dynamic or Not */
				    IF(@d like '%~%')
					BEGIN
						 /*Summary :To Check the @d(Data) is Special Dynamic or Not */
		    	  		IF(@d  like '%deleteItem/next%' or @d like '%deleteItem/prev%' or @d  like '%returnitem/pass%' or @d  like '%returnitem/nopass%')
             			BEGIN
             				         											
             				IF EXISTS (SELECT 1 FROM dbo.tblContent C WITH(NOLOCK) WHERE C.Code =SUBSTRING(@d,14,len(@d)) AND C.OrgId = @intOrgId)
							BEGIN
							/*Summay: If Content records found return the following fields */
						    SET @scandata =  @scandata +ISNULL('{'+ (SELECT TOP 1 '"code":' +'"'+ ISNULL(@d,'NULL') +'",'+'"category":'+'"'+ ISNULL(C.category,'NULL') +'",'+'"model":' +'"' + ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ ISNULL(C.manufacturer,'NULL') +'",'+'"partNumber":'+'"'+ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ ISNULL(C.productLine,'NULL') +'",'+'"manufacturerSKU":'+'"'+ ISNULL(C.manufacturerSKU,'NULL') +'",'+'"description":'+'"'+ ISNULL(C.description,'NULL') +'",'+'"unitMeasure":'+'"'+ISNULL(C.unitMeasure,'NULL') +'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL') +'",'+'"misc1":'+'"'+ISNULL(C.misc1,'NULL')+'",'+'"misc2":'+'"'+ISNULL(C.misc2,'NULL')+'"'  
							FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
							JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C  WITH(NOLOCK) ON C.OrgId =  I.OrgId
							WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d
							AND C.Code = SUBSTRING(@d,14,len(@d))) +'}','')
							END
							ELSE
							BEGIN
						    /*Summay: If Content records not found return the following fields */
							SET @scandata =  @scandata +ISNULL('{'+ (SELECT TOP 1  '"code":' +'"' + ISNULL(@d,'NULL') +'"' 
							FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
							JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId
							AND D.IntSerial =  @i AND D.ScanData = @d) + '}','')
							END
             			END
             	     	/*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first "/" */
						ELSE IF(NOT EXISTS(SELECT 1 FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
						BEGIN
							SELECT '<list>'+(SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName','0' AS 'UnitSuite','0' AS 'Street',
			    			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
							'0' AS 'ScanDate','0' AS 'ForwardURL','0' AS 'ScanSession','0' AS 'ScanData','OK' AS 'ErrId' FOR XML RAW )+'</list>'
							EXEC upi_SystemEvents 'DeviceBackup',2307,1,@d
							RETURN;
						END
						/*Summay:Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code]*/
						
						ELSE IF EXISTS (SELECT 1 FROM dbo.tblContent C WITH(NOLOCK) WHERE C.OrgId = @intOrgId  AND 
							C.Code =  (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
							/*Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.*/
							IF(@d LIKE '%*CH*%')
							BEGIN
								/*Summay: If Content records found return the following fields  */
							 	SET @scandata =  @scandata + ISNULL('{'+ (SELECT TOP 1 '"code":' + '"' + ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'NULL') +'",'+'"metaData":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.metadata,-1),'NULL') +'",'+'"RedemptionData":'+'"'+ ISNULL(@response,'NULL')+'",'+ '"category":'+'"'+ISNULL( C.category,'NULL') +'",'+'"model":' +'"'+ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ ISNULL(C.productLine,'NULL') +'",'+'"manufacturerSKU":'+'"'+ ISNULL(C.manufacturerSKU,'NULL') +'",'+'"description":'+'"'+ ISNULL(C.description,'NULL') +'",'+'"unitMeasure":'+'"'+ ISNULL(C.unitMeasure,'NULL') +'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ ISNULL(C.misc1,'NULL') +'",'+'"misc2":'+'"'+ ISNULL(C.misc2,'NULL') +'"'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C WITH(NOLOCK) ON C.OrgId =  I.OrgId
								JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d
								AND C.Code =(SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
							END
							ELSE
							BEGIN
							    /*Summay: If Content records found return the following fields */
								SET @scandata =  @scandata +ISNULL('{'+ (SELECT  TOP 1 '"code":' +'"' + ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(DC.cellphone,'NULL') +'",'+'"metaData":' +'"'+ ISNULL(DC.metaData,'NULL') +'"'+ '"category":'+'"'+ ISNULL(C.category,'NULL') +'",'+'"model":' +'"'+ ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ ISNULL(C.productLine,'NULL')+'",'+'"manufacturerSKU":'+'"'+ ISNULL(C.manufacturerSKU,'NULL')+'",'+'"description":'+'"'+ ISNULL(C.description,'NULL') +'",'+'"unitMeasure":'+'"'+ ISNULL(C.unitMeasure,'NULL')+'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ ISNULL(C.misc1,'NULL') +'",'+'"misc2":'+'"'+ ISNULL(C.misc2,'NULL') +'"' 
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C WITH(NOLOCK) ON C.OrgId =  I.OrgId
								JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d
								AND C.Code =  (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
							 END
							END
							/*Summay: If Content records not found return the following fields */
							ELSE
							/* Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.*/
							IF(@d LIKE '%*CH*%')
							BEGIN
								SET @scandata =  @scandata +ISNULL('{'+ ( SELECT TOP 1 '"code":' +'"' + ISNULL(DC.RedemptionData,'NULL') +'",'+  '"cellphone":'+'"'+ ISNULL(DC.cellphone,'NULL') +'",'+'"metaData":' +'"'+ ISNULL(DC.metaData,'NULL') +'",' + '"RedemptionData":' + ISNULL(@response,'NULL')+'"'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId  AND D.IntSerial =  @i AND D.ScanData = @d 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
						    END
						    ELSE
							BEGIN
							 	SET @scandata =  @scandata +ISNULL('{'+ (SELECT TOP 1 '"code":' + '"' + ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(DC.cellphone,'NULL') +'",'+'"metaData":' +'"'+ ISNULL(DC.metaData,'NULL')+'"' 
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) +'}','')
							END
						END --Dynamic record END
						/*Summay: if DeviceScan[scanData] is not a dynamic code then do the following */
						ELSE 
						IF EXISTS (SELECT 1 FROM dbo.tblContent C WITH(NOLOCK) WHERE C.Code =  @d AND C.OrgId = @intOrgId)
						BEGIN
							/*Summay: If Content records found return the following fields */
						    SET @scandata =  @scandata +ISNULL('{'+ (SELECT TOP 1 '"code":' +'"' +ISNULL(@d,'')+'",'+'"category":'+'"' + ISNULL(C.category,'NULL')+'",'+'"model":' +'"'+ ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ ISNULL(C.manufacturer,'NULL') +'",'+'"partNumber":'+'"'+ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ ISNULL(C.productLine,'NULL') +'",'+'"manufacturerSKU":'+'"'+ ISNULL(C.manufacturerSKU,'NULL') +'",'+'"description":'+'"'+ ISNULL(C.description,'NULL') +'",'+'"unitMeasure":'+'"'+ISNULL(C.unitMeasure,'NULL') +'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ISNULL(C.misc1,'NULL')+'",'+'"misc2":'+'"'+ISNULL(C.misc2,'NULL')+'"'
							FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
							JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C WITH(NOLOCK) ON C.OrgId =  I.OrgId
							WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d
							AND C.Code =  @d ) +'}','')
						END
						ELSE
						BEGIN
						    /*Summay: If Content records not found return the following fields */
							SET @scandata =  @scandata +ISNULL('{'+ (SELECT TOP 1  '"code":' +'"' + ISNULL(@d,'NULL') +'"' 
							FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
							JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId
							AND D.IntSerial =  @i AND D.ScanData = @d) + '}','')
						END
						/* Summary:If ScanBatches does not exist then create new scanBatches  record*/
						--select @scandata
				IF(NOT EXISTS(SELECT 1 FROM dbo.tblTempScanBatches WITH(NOLOCK) WHERE IntSerial = @i))
				BEGIN
					INSERT tblTempScanBatches SELECT  I.intSerial ,O.orgName,CONVERT(DATETIMEOFFSET(7),@t),I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc,@scandata  
					FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId = O.OrgId JOIN tblLocation L ON I.OrgId = L.OrgId  AND I.LocId = L.LocId 
					WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId and  I.IntSerial = @i
					EXEC upi_SystemEvents 'DeviceBackup',2309,1,@d
					
					SELECT '<list>'+(SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName','0' AS 'UnitSuite','0' AS 'Street',
			    	'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
					'0' AS 'ScanDate','0' AS 'ForwardURL','0' AS 'ScanSession','0' AS 'ScanData','OK' AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END
			    /* Summary:If ScanBatches already exist then append the scandata in scanBatches */
				ELSE IF(EXISTS(SELECT 1 FROM dbo.tblTempScanBatches WITH(NOLOCK) WHERE IntSerial = @i)) 
			    BEGIN
					IF(CONVERT(DATETIMEOFFSET(7),@t) < =  CONVERT(DATETIMEOFFSET(7),(SELECT  DeliveryTime + CONVERT(datetime, MaxBatchWaitTime)  FROM dbo.tblTempScanBatches  WITH(NOLOCK) inner join  TBLINTERCEPTOR WITH(NOLOCK) on TBLINTERCEPTOR.intserial = tblTempScanBatches.intserial WHERE TBLINTERCEPTOR.intserial = @i )))
					BEGIN
						 DECLARE @scandata1 AS NVARCHAR(MAX)
						 SET @scandata1 =  (SELECT top 1 ScanData FROM dbo.tblTempScanBatches WITH(NOLOCK) inner join  TBLINTERCEPTOR  WITH(NOLOCK) on TBLINTERCEPTOR.intserial = tblTempScanBatches.intserial WHERE TBLINTERCEPTOR.intserial = @i)+ @scandata 
						 UPDATE  tblTempScanBatches SET ScanData = @scandata1,DeliveryTime = CONVERT(DATETIMEOFFSET(7),@t) WHERE IntSerial = @i
						 EXEC upi_SystemEvents 'DeviceBackup',2309,1,@d
							
							--select @scandata1
						 SELECT '<list>'+(SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName','0' AS 'UnitSuite','0' AS 'Street',
			    		 '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
						 '0' AS 'ScanDate','0' AS 'ForwardURL','0' AS 'ScanSession','0' AS 'ScanData','OK' AS 'ErrId' FOR XML RAW )+'</list>'
						 RETURN;
					END
			    	/* Summary:if data exists in TempScanBatches and scanDate > TempScanBatches[deliveryTime] +Interceptor[maxBatchWaitTime] then send an HTTP POST request to forwardURL (see internal routine BatchDispatcher for format and content of HTTP POST request). If HTTP response is “200 Ok” log event in SystemEvents.*/
					ELSE 
					IF(CONVERT(DATETIMEOFFSET(7),@t) >(SELECT CONVERT(DATETIMEOFFSET(7), DeliveryTime) + CONVERT(datetime, MaxBatchWaitTime)  FROM dbo.tblTempScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial = tblTempScanBatches.intserial WHERE TBLINTERCEPTOR.intserial =  @i))--@i--
					BEGIN
						 SELECT '<list>'+(SELECT  ISNULL(IntSerial,'') AS 'IntSerial', ISNULL(IntLocDesc,'0') AS 'IntLocDesc', ISNULL(OrgName,'') AS 'OrgName',ISNULL(UnitSuite,'') AS 'UnitSuite',ISNULL(Street,'') AS 'Street',
			    	     ISNULL(City,'') AS 'City',ISNULL(State,'') AS 'State',ISNULL(Country,'') AS 'Country',ISNULL(PostalCode,'') AS 'PostalCode',ISNULL(LocType,'') AS 'LocType',ISNULL(LocSubType,'') AS 'LocSubType',
				         ISNULL(CONVERT(CHAR(33),DeliveryTime,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(ForwardURL,'') AS 'ForwardURL','0' AS 'ScanSession',ISNULL(@scandata,'')  AS 'ScanData','0' AS 'ErrId'
				         FROM dbo.tblTempScanBatches WITH(NOLOCK) WHERE IntSerial = @i
				         FOR XML RAW )+'</list>'
				         EXEC upi_SystemEvents 'DeviceBackup',2309,1,@d
				         RETURN;
				   END
			   END
			   
			   
		END 
		--
			  ELSE
               /*Summary:if Interceptor[forwardURL] =  1 (batch forwarding) then do the following */
              IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i),'') =  '3')
              BEGIN
				SET @intOrgId=(SELECT TOP 1 OrgId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i) 
				SET @intLocId=(SELECT TOP 1 LocId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @i)
                 /*Summary:if it doesn’t exist, create a temporary data store with the same fields as ScanBatches, called TempScanBatches*/
                   IF (NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA =  'dbo' AND  TABLE_NAME =  'tblTempScanBatches'))
				   BEGIN
				    CREATE TABLE [dbo].tblTempScanBatches( [Id] [int] IDENTITY(1,1) NOT NULL,[IntSerial] [VARCHAR](50) NOT NULL,[OrgName] [nVARCHAR](100) NOT NULL,[DeliveryTime] [DATETIMEOFFSET](7) NULL,[ForwardURL] [VARCHAR](100) NULL,
	                [UnitSuite] [VARCHAR](15) NULL,[Street] [nVARCHAR](100) NULL,[City] [VARCHAR](50) NULL,[State] [nVARCHAR](100) NULL,[Country] [VARCHAR](50) NULL,[PostalCode] [VARCHAR](10) NULL,[LocType] [nVARCHAR](50) NULL,[LocSubType] [nVARCHAR](50) NULL,
	                [IntLocDesc] [VARCHAR](100) NULL,[ScanData] [VARCHAR](max) NOT NULL)
				   END
				   /* Summary:If ScanBatches does not exist then create the new record  in TempScanBatches */
				   
				   SET @scandata = '';
				   /*Summary :To Check the @d(Data) is Dynamic or Not */
				    IF(@d like '%~%' AND( @d NOT like '%deleteItem/next%' AND @d NOT like '%deleteItem/prev%' AND @d Not like '%returnitem/pass%' and @d not like '%returnitem/nopass%'))
					BEGIN
					
					   	/*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first "/" */
						IF(NOT EXISTS(SELECT 1 FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
						BEGIN
							SELECT '<list>'+(SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName','0' AS 'UnitSuite','0' AS 'Street',
			    			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
							'0' AS 'ScanDate','0' AS 'ForwardURL','0' AS 'ScanSession','0' AS 'ScanData','OK' AS 'ErrId' FOR XML RAW )+'</list>'
							EXEC upi_SystemEvents 'DeviceBackup',2307,1,@d
							RETURN;
						END
						/*Summay:Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code]*/
						
						ELSE IF EXISTS (SELECT 1 FROM dbo.tblContent C WITH(NOLOCK) WHERE C.OrgId = @intOrgId  AND 
							C.Code =  (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
							BEGIN
							--select 'a1'
							/*Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.*/
							IF(@d LIKE '%*CH*%')
							BEGIN
								/*Summay: If Content records found return the following fields  */
							 	SET @scandata =  @scandata + ISNULL('{'+ (SELECT TOP 1 '"code":' + '"' + ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'NULL') +'",'+'"metaData":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.metadata,-1),'NULL') +'",'+'"RedemptionData":'+'"'+ ISNULL(@response,'NULL')+'",'+ '"category":'+'"'+ISNULL( C.category,'NULL') +'",'+'"model":' +'"'+ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ ISNULL(C.productLine,'NULL') +'",'+'"manufacturerSKU":'+'"'+ ISNULL(C.manufacturerSKU,'NULL') +'",'+'"description":'+'"'+ ISNULL(C.description,'NULL') +'",'+'"unitMeasure":'+'"'+ ISNULL(C.unitMeasure,'NULL') +'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ ISNULL(C.misc1,'NULL') +'",'+'"misc2":'+'"'+ ISNULL(C.misc2,'NULL') +'"'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C WITH(NOLOCK) ON C.OrgId =  I.OrgId
								JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d
								AND C.Code =  (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
							END
							ELSE
							BEGIN
							    /*Summay: If Content records found return the following fields */
								SET @scandata =  @scandata +ISNULL('{'+ (SELECT  TOP 1 '"code":' +'"' + ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(DC.cellphone,'NULL') +'",'+'"metaData":' +'"'+ ISNULL(DC.metaData,'NULL') +'",'+ '"category":'+'"'+ ISNULL(C.category,'NULL') +'",'+'"model":' +'"'+ ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ ISNULL(C.productLine,'NULL')+'",'+'"manufacturerSKU":'+'"'+ ISNULL(C.manufacturerSKU,'NULL')+'",'+'"description":'+'"'+ ISNULL(C.description,'NULL') +'",'+'"unitMeasure":'+'"'+ ISNULL(C.unitMeasure,'NULL')+'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ ISNULL(C.misc1,'NULL') +'",'+'"misc2":'+'"'+ ISNULL(C.misc2,'NULL') +'"' 
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblContent C WITH(NOLOCK) ON C.OrgId =  I.OrgId
								JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d
								AND C.Code =  (SELECT RedemptionData FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
							 END
							END
							/*Summay: If Content records not found return the following fields */
							ELSE
							/* Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.*/
							IF(@d LIKE '%*CH*%')
							BEGIN
							
								SET @scandata =  @scandata +ISNULL('{'+ ( SELECT TOP 1 '"code":' +'"' + ISNULL(DC.RedemptionData,'NULL') +'",'+  '"cellphone":'+'"'+ ISNULL(DC.cellphone,'NULL') +'",'+'"metaData":' +'"'+ ISNULL(DC.metaData,'NULL') +'",' + '"RedemptionData":' + ISNULL(@response,'NULL')+'"'
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
							END
						    ELSE
							BEGIN
							 	SET @scandata =  @scandata +ISNULL('{'+ (SELECT TOP 1 '"code":' + '"' + ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(DC.cellphone,'NULL') +'",'+'"metaData":' +'"'+ ISNULL(DC.metaData,'NULL')+'"' 
								FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN tblOrganization O WITH(NOLOCK) ON I.OrgId = O.OrgId JOIN tblLocation L WITH(NOLOCK) ON I.OrgId = L.OrgId and L.LocId = I.LocID
								JOIN tblDeviceScan D WITH(NOLOCK) ON D.IntSerial = I.IntSerial JOIN tblDynamicCode DC WITH(NOLOCK) ON DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
								WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId AND D.IntSerial =  @i AND D.ScanData = @d 
								AND DC.DynCID =  (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) +'}','')
							END
						END --Dynamic record END
						/*Summay: if DeviceScan[scanData] is not a dynamic code then do the following */
						ELSE 
						BEGIN
							SELECT '<list>'+(SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName','0' AS 'UnitSuite','0' AS 'Street',
			    		   '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
						   '0' AS 'ScanDate','0' AS 'ForwardURL','0' AS 'ScanSession','0' AS 'ScanData','OK' AS 'ErrId' FOR XML RAW )+'</list>'
						   RETURN;
						END
						/* Summary:If ScanBatches does not exist then create new scanBatches  record*/
				IF(NOT EXISTS(SELECT 1 FROM dbo.tblTempScanBatches WITH(NOLOCK) WHERE IntSerial = @i))
				BEGIN
					INSERT tblTempScanBatches SELECT  I.intSerial ,O.orgName,@t,I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc,@scandata  FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId = O.OrgId JOIN tblLocation L ON I.OrgId = L.OrgId  AND I.LocId = L.LocId 
					WHERE I.OrgId = @intOrgId AND O.OrgId = @intOrgId AND L.OrgId=@intOrgId AND L.LocId=@intLocId and  I.IntSerial = @i
					EXEC upi_SystemEvents 'DeviceBackup',2309,1,@d
					
					SELECT '<list>'+(SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName','0' AS 'UnitSuite','0' AS 'Street',
			    	'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
					'0' AS 'ScanDate','0' AS 'ForwardURL','0' AS 'ScanSession','0' AS 'ScanData','OK' AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END
			    /* Summary:If ScanBatches already exist then append the scandata in scanBatches */
				ELSE IF(EXISTS(SELECT 1 FROM dbo.tblTempScanBatches WITH(NOLOCK) WHERE IntSerial = @i)) 
			    BEGIN
			 		IF(CONVERT(DATETIMEOFFSET(7),@t) < =  CONVERT(DATETIMEOFFSET(7),(SELECT  DeliveryTime + CONVERT(datetime, MaxBatchWaitTime)  FROM dbo.tblTempScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial = tblTempScanBatches.intserial WHERE TBLINTERCEPTOR.intserial = @i )))
					BEGIN
					   
						 DECLARE @scandata2 AS NVARCHAR(MAX)
						 SET @scandata2 =  (SELECT top 1 ScanData FROM dbo.tblTempScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial = tblTempScanBatches.intserial WHERE TBLINTERCEPTOR.intserial = @i)+ @scandata 
						 UPDATE  tblTempScanBatches SET ScanData = @scandata2,DeliveryTime = CONVERT(DATETIMEOFFSET(7),@t) WHERE IntSerial = @i
						 EXEC upi_SystemEvents 'DeviceBackup',2309,1,@d
							
						 SELECT '<list>'+(SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName','0' AS 'UnitSuite','0' AS 'Street',
			    		 '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
						 '0' AS 'ScanDate','0' AS 'ForwardURL','0' AS 'ScanSession','0' AS 'ScanData','OK' AS 'ErrId' FOR XML RAW )+'</list>'
						 RETURN;
					END
			    	/* Summary:if data exists in TempScanBatches and scanDate > TempScanBatches[deliveryTime] +Interceptor[maxBatchWaitTime] then send an HTTP POST request to forwardURL (see internal routine BatchDispatcher for format and content of HTTP POST request). If HTTP response is “200 Ok” log event in SystemEvents.*/
					ELSE 
					IF(CONVERT(DATETIMEOFFSET(7),@t) >(SELECT CONVERT(DATETIMEOFFSET(7), DeliveryTime) + CONVERT(datetime, MaxBatchWaitTime)  FROM dbo.tblTempScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial = tblTempScanBatches.intserial WHERE TBLINTERCEPTOR.intserial =  @i))--@i--
					BEGIN
					 
						 SELECT '<list>'+(SELECT  ISNULL(IntSerial,'') AS 'IntSerial', ISNULL(IntLocDesc,'0') AS 'IntLocDesc', ISNULL(OrgName,'') AS 'OrgName',ISNULL(UnitSuite,'') AS 'UnitSuite',ISNULL(Street,'') AS 'Street',
			    	     ISNULL(City,'') AS 'City',ISNULL(State,'') AS 'State',ISNULL(Country,'') AS 'Country',ISNULL(PostalCode,'') AS 'PostalCode',ISNULL(LocType,'') AS 'LocType',ISNULL(LocSubType,'') AS 'LocSubType',
				         ISNULL(CONVERT(CHAR(33),DeliveryTime,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(ForwardURL,'') AS 'ForwardURL','0' AS 'ScanSession',ISNULL(@scandata,'')  AS 'ScanData','0' AS 'ErrId'
				         FROM dbo.tblTempScanBatches WITH(NOLOCK) WHERE IntSerial = @i
				         FOR XML RAW )+'</list>'
				         EXEC upi_SystemEvents 'DeviceBackup',2309,1,@d
				         RETURN;
				   END
			   END
			   END
							
END
--EXEC upi_DeviceBackup_checkForwardType '0DCBC3FD087CFA927C114E5E9B07A9C49AEA2DF8','123456789123','{{"t":"2018-05-18T11:30:55.0030000+00:00","s":"1","d":"~84/*CH*ABC"}}','sdfsdfdsfsfsdf sfs sdf sfd sf sdf dsfsd fsdf'
--EXEC upi_DeviceBackup_checkForwardType 'A1E5F316FDAE2CF45B2E586FFE0D656E7E4980E4','123456789123','{{\"t\":\"2013-05-18T11:30:55.0030000+00:00\",\"s\":\"1\",\"d\":\"~/deleteItem/next"}}','{"redemptionData":"Success"}'

--EXEC upi_DeviceBackup_checkForwardType 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111','{"t":"2013-05-18T11:32:55.0030000 +00:00","s":"1","d":""~75/*CH*Contentcode4""}','Super'
--',{"t":"2013-05-18T11:33:55.0030000 +00:00","s":"1","d":"ContentNotMatch"},{"t":"2013-05-18T11:34:55.0030000 +00:00","s":"1","d":"~65/*CH*Contentcode2"},{"t":"2013-05-18T11:34:55.0030000 +00:00","s":"1","d":"~75/deleteItem/next"}'


GO
/****** Object:  StoredProcedure [dbo].[upi_DeviceBackup_Result]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Author:		Prakash G
-- Create date: 26.06.2013
-- Routine:		DeviceBackup(upi_DeviceBackup_Result)
-- Method:		POST
-- Description:	Handles HTTP requests (from Interceptor devices) that are uploading
--				backed up scan data (Interceptors locally backup scan data if API connection
--				is lost, then bulk upload scan data when connection re-established)
-- =============================================================================================
CREATE PROCEDURE [dbo].[upi_DeviceBackup_Result] 
	
	@a					AS VARCHAR(40),
	@i					AS VARCHAR(12),
	@b					AS NVARCHAR(MAX),
	@response			AS VARCHAR(MAX), 
	@requestAndresponse	AS VARCHAR(MAX),
	@curScandata		AS VARCHAR(MAX)
	
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @eventData used to store event data description
	
	DECLARE @ReturnResult		AS VARCHAR(100)
	DECLARE @date				AS DATETIMEOFFSET(7)
	DECLARE @severData			AS VARCHAR(50)
	DECLARE @scanObject			AS NVARCHAR(MAX)
    DECLARE @scandata			AS NVARCHAR(MAX)
    DECLARE @t					AS NVARCHAR(MAX)
    DECLARE @d					AS NVARCHAR(500)
    DECLARE @s					AS NVARCHAR(100)
    DECLARE @CURSORID			AS INT
    DECLARE @Error				AS NVARCHAR(15)
	DECLARE @ErrorMessage		AS NVARCHAR(MAX)
	DECLARE @NameValuePairs		AS VARCHAR(MAX) 
    DECLARE @NameValuePair		AS VARCHAR(100)
	DECLARE @Name				AS NVARCHAR(100)
	DECLARE @Value				AS NVARCHAR(100)
	DECLARE @id					AS INT
	DECLARE @Count				AS INT
	DECLARE @date1				AS DATETIMEOFFSET(7)	
	DECLARE @Property TABLE ([id] INT ,[Name] NVARCHAR(100),[Value] NVARCHAR(100))
	
	
	SET @b =   REPLACE(@b,'\','');
	SET @date =  SYSDATETIMEOFFSET();
	
	/*Summary:Split the Unwanted Characters and Insert the Temporary Table */
	SET @scanObject = REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(@b,'{',''),'}',''),'"',''),'[',''),']','');
	
					    SET @id = 0;
						SELECT @NameValuePairs  = @scanObject
						WHILE LEN(@NameValuePairs) > 0
						BEGIN
							SET  @id = @id+1;
							SET @NameValuePair =  LEFT(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs) - 1, -1),LEN(@NameValuePairs)))
							SET @NameValuePairs =  SUBSTRING(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs), 0),LEN(@NameValuePairs)) + 1, LEN(@NameValuePairs))
							SET @Name =  LTRIM(RTRIM(SUBSTRING(@NameValuePair, 1, CHARINDEX(':', @NameValuePair) - 1)))
							SET @Value = LTRIM(RTRIM(SUBSTRING(@NameValuePair, CHARINDEX(':', @NameValuePair) + 1, LEN(@NameValuePair))))
							INSERT INTO @Property ([id], [Name], [Value]) VALUES ( @id,@Name, @Value )
						END
						SET @d = '';
                        SET @t = '';
                        SET @s = '';
                        SET @Error = ''; 
						SET @Count =  (SELECT count(*) FROM @Property)
                        DECLARE @ic	int
                        SET @ic = 1
                        WHILE( @ic < =  @Count)
                        BEGIN
                          SET @Name = (SELECT Name FROM @Property WHERE id = @ic)
                          SET @Value = (SELECT [Value] FROM @Property WHERE id = @ic)
                          SET @ic = @ic + 1;
                          IF(LOWER(@Name) =  'd') SET @d = @Value;
                          ELSE IF(LOWER(@Name) =  't') 
                          BEGIN
							SET @t =   LTRIM(Rtrim(@Value)); 
							SET @t=Replace(@t,' ','');
                          END   
                          ELSE IF(LOWER(@Name) =  's') 
                             SET @s = CONVERT(VARCHAR,@Value)
                          ELSE
                          BEGIN
                            SET  @Error = 'Error'; 
                          END 
                       END 
                       /*Summary: Create a new DeviceScan record with the values in the list item @i,@t,@d */
				
	/* Summary; If HTTP response is “200 Ok” log event in SystemEvents.*/
	
	IF(@response =  '200 OK')
	BEGIN
	   EXEC upi_SystemEvents 'DeviceBackup',2310,1,'200 OK'
	END
	/* Summary: If HTTP response is not “200 Ok” log HTTP request and response in SystemEvents.*/
	ELSE
	BEGIN
	   EXEC upi_SystemEvents 'DeviceBackup',2302,1,@requestAndresponse
	END
	
	/*Summary :clear the contents of TempScanBatches*/
	TRUNCATE TABLE dbo.tblTempScanBatches
	/*Summary: create a new record in TempScanBatches using the current data */
	INSERT dbo.tblTempScanBatches SELECT ISNULL(I.intSerial,'') ,ISNULL(O.orgName,''),CONVERT(DATETIMEOFFSET(7),@t),ISNULL(I.ForwardURL,''),ISNULL(L.unitSuite,''),ISNULL(L.street,''),ISNULL(L.city,''),ISNULL(L.state,''),ISNULL(L.country,''),ISNULL(L.postalCode,''),ISNULL(L.locType,''),ISNULL(L.locSubType,''),ISNULL(I.intLocDesc,''),ISNULL(@curScandata,'')  
		FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId = O.OrgId JOIN tblLocation L ON I.LocId = L.LocId 
		WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial = @i) AND O.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial = @i) AND L.LocId = (SELECT TOP 1 It.LocId FROM dbo.tblInterceptor It WHERE It.IntSerial = @i) and  I.IntSerial = @i
	SET @ReturnResult =  '201' SELECT @ReturnResult 			
END
--exec [upi_DeviceBackup_Result] 'A1E5F316FDAE2CF45B2E586FFE0D656E7E4980E4','987654321112','{{ "t":"2013-05-18T11:30:55.003", "d":"~83/*CH*ABC"}}','OK'

GO
/****** Object:  StoredProcedure [dbo].[upi_DeviceScan_Authenticate]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author:			Dineshkumar G
-- Create date:		30.05.2013
-- Routine:			DeviceScan
-- Method:			POST
-- Description:		Creates a new DeviceScan record using passed scan data, also handles “Call Home” requests
-- Modified Author: Prakash G
-- Modified Date:	27.06.2013
-- =============================================================================================================

--exec [upi_DeviceScan_Authenticate] '7FEF5C2865C3DAC9872FED67A238D2EECBA9C1FA','0080A395321E','Scanneddata'
CREATE PROCEDURE [dbo].[upi_DeviceScan_Authenticate] 

	@a	AS VARCHAR(40),
	@i	AS VARCHAR(12),
	@d	AS VARCHAR(Max)
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @eventData used to store event data description
	
	DECLARE @ReturnResult	AS NVARCHAR(MAX)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @tempResult		AS NVARCHAR(MAX)

	SET @date = SYSDATETIMEOFFSET();
		
	/* Summary: Raise an error message(400) If mandatory field Authentication String(@a),intserial number(@i),Data(@d) are not supplied. */
	IF((ISNULL(@a,'') = '') OR (ISNULL(@i,'') = '') OR (ISNULL(@d,'')= ''))
	BEGIN
        IF((ISNULL(@a,'') = '') AND (ISNULL(@i,'') = '') AND (ISNULL(@d,'')= ''))  EXEC upi_SystemEvents 'DeviceScan',2251,3,''
        ELSE IF((ISNULL(@a,'') = '') AND (ISNULL(@i,'') = '')) EXEC upi_SystemEvents 'DeviceScan',2253,3,''
        ELSE IF((ISNULL(@a,'') = '') AND (ISNULL(@d,'') = '')) EXEC upi_SystemEvents 'DeviceScan',2257,3,''
        ELSE IF((ISNULL(@d,'') = '') AND (ISNULL(@i,'') = '')) EXEC upi_SystemEvents 'DeviceScan',2259,3,''
        ELSE IF((ISNULL(@a,'') = '')) EXEC upi_SystemEvents 'DeviceScan',2262,3,''
        ELSE IF((ISNULL(@i,'') = '')) EXEC upi_SystemEvents 'DeviceScan',2263,3,''	
        ELSE IF((ISNULL(@d,'') = '')) EXEC upi_SystemEvents 'DeviceScan',2264,3,''	
        SET @ReturnResult = '400'
	    SELECT @ReturnResult AS Returnvalue1
	    RETURN;
	END
	
	/* Summary: Raise an error message (400). If InterceptorID record is not found for the given intserail number(@i) in the InterceptorID table. */
	IF(NOT EXISTS(SELECT 1 FROM dbo.tblInterceptorID WHERE IntSerial COLLATE Latin1_General_CS_AS=@i))
	BEGIN
	      SET @ReturnResult = '400'
		  EXEC upi_SystemEvents 'DeviceScan',2254,3,@i
		  SELECT @ReturnResult AS Returnvalue2
	      RETURN;
	END
	
	/* Summary: Raise an error message (400). Create an MD5 hexdigest of InterceptorID[embeddedID]. If hexdigest does not match passed authentication String(@a) */
	IF(@a <> (SELECT top 1 CONVERT(VARCHAR(40),HashBytes('SHA1', EmbeddedId),2) FROM dbo.tblInterceptorID WHERE IntSerial COLLATE Latin1_General_CS_AS=@i))
	BEGIN
	     SET @ReturnResult = '400'
		 EXEC upi_SystemEvents 'DeviceScan',2252,3,@a
		 SELECT @ReturnResult AS Returnvalue3
		 RETURN;
	END
	
	/* Summary: Raise an error message (400). If Interceptor record is not found for the given intserail number(@i) in the Interceptor table. */
	IF(NOT EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial COLLATE Latin1_General_CS_AS=@i))
	BEGIN
		 SET @ReturnResult = '400'
		 EXEC upi_SystemEvents 'DeviceScan',2255,3,@i
		 SELECT @ReturnResult AS Returnvalue4
		 RETURN;
	END
	ELSE
	
   /* Summary:Raise an error message (400).Use passed i to get Interceptor record.If Interceptor[deviceStatus] is not "active" */
   	IF(1 <>(SELECT TOP 1 DeviceStatus FROM dbo.tblInterceptor WHERE IntSerial COLLATE Latin1_General_CS_AS=@i))
	BEGIN
		 SET @ReturnResult = '400'
		 EXEC upi_SystemEvents 'DeviceScan',2256,3,@i
		 SELECT @ReturnResult AS Returnvalue5
		 RETURN;
	 END
			
	/*Post Authentication start*/
	/*Summary:If d contains "*CH*" then Proceed */
	IF(@d LIKE '%*CH*%')
	BEGIN
			/*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first “/”  */
			IF EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2)))
			BEGIN
		
				SET @ReturnResult=(SELECT ISNULL(Nullif(CONVERT(VARCHAR(500),CallHomeData),''),'None')+'|'+ CONVERT(VARCHAR(100),@i)+'|'+CONVERT(VARCHAR(100),SYSDATETIMEOFFSET())+'|'+ISNULL(Nullif(CONVERT(VARCHAR(100),CallHomeURL),''),'None') FROM dbo.tblDynamicCode WHERE DynCID =(SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2)))
				SELECT @ReturnResult AS Returnvalue
				RETURN;
			END
			/*Summary: Raise an Error Message. If DynamicCode record is not found for the given dyncid  in the dynamiccode table.  */
			ELSE
			BEGIN
			    SET @ReturnResult = '400'
		        EXEC upi_SystemEvents 'DeviceScan',2258,3,@d
				SELECT @ReturnResult AS Returnvalue6
				RETURN;
			END
	END
	/*Summary:If d does not contain "*CH*" then return HTTP code “201 Created” */
	ELSE
	BEGIN
		SET @ReturnResult = '201' SELECT @ReturnResult AS Returnvalue
		RETURN;
	END
END



GO
/****** Object:  StoredProcedure [dbo].[upi_DeviceScan_callHomeURL]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author:        Prakash G
-- Create date: 12.06.2013
-- Routine:       DeviceScan (upi_DeviceScan_callHomeURL)
--Modified by  :Dineshkumar G
-- Method:        POST
-- Description:   Creates a new DeviceScan record using passed scan data, also handles “Call Home” requests
-- =============================================================================================================
--exec [upi_DeviceScan_callHomeURL] 'C191E16993B7FC19955CFF4D37C577827D7763DF','000000000001','~65/*CH*abc','RedDatafromCallHomeURL'
--exec [upi_DeviceScan_callHomeURL] 'E8248CBE79A288FFEC75D7300AD2E07172F487F6','111111111111','~DeleteItem/prev',''
CREATE PROCEDURE [dbo].[upi_DeviceScan_callHomeURL] 
      
      @a                            AS VARCHAR(32),
      @i                            AS VARCHAR(50),
      @d                            AS VARCHAR(Max),
    @callHomeRedemption AS VARCHAR(MAX) 
AS
BEGIN

      SET NOCOUNT ON;
      
      -- Output descriptions
      -- 400 - Bad Request
      -- 201 - Created
      -- 200 - Success
      
      -- Local variables descriptions
      -- @ReturnResult used to return results
      -- @date used to store the current date and time from the SQL Server
      -- @eventData used to store event data description
      
      DECLARE @ReturnResult   AS VARCHAR(MAX)
      DECLARE @date                 AS DATETIMEOFFSET(7)
      DECLARE @scandata       AS NVARCHAR(MAX)
      DECLARE @MaxBatchtime   AS INT
      
      SET @date = SYSDATETIMEOFFSET();
      
      /* Summary:If the data(@d) contains *CH* then Assign the callHomeRedemptionData is @callHomeRedemption input Parameter  */
      IF(@d LIKE '%*CH*%')
      BEGIN
            SET @callHomeRedemption=(SELECT CASE WHEN @callHomeRedemption='504 Gateway Timeout' THEN 'timeout' ELSE @callHomeRedemption END)
      END
      ELSE
      /* Summary:If the data(@d) does not contains *CH* then Assign the callHomeRedemptionData  is Empty*/
      BEGIN
            SET @callHomeRedemption=''
      END
      
      /*Summary: Create a new DeviceScan record with the values in the list item @i,@t,@d,@callHomeRedemption */
      INSERT INTO tblDeviceScan(IntSerial,ScanDate,ScanData,scanSession,CallHomeRedmptionData) VALUES(@i,@date,@d,0,@callHomeRedemption)
      
      /*Summary:Use the passed i to get the Interceptor record*/

      IF(EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial=@i))
      BEGIN
            /*Summary: Check the Interceptor[forwardURL] field. If it  is not empty, then do the following */
          
            IF(ISNULL((SELECT TOP 1 forwardURL FROM dbo.tblInterceptor WHERE IntSerial=@i),'') < > '')
            BEGIN
                  /*Summary: if Interceptor[forwardType] = 0 (single item forwarding) then:send an HTTP POST request to forwardURL with a JSON object embedded in the request body */
                  IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WHERE IntSerial=@i),'')= '0')
            BEGIN
               /*Summary :To Check the @d(Data) is Dynamic Code or Not */
                   IF(@d LIKE '%~%')
                                BEGIN
                                  /*Summary :To Check the @d(Data) is Special Dynamic Code or Not */
                                  
                           IF(@d LIKE '%DeleteItem/next%' or @d LIKE '%DeleteItem/prev%' or @d like '%returnitem/pass' or @d like '%returnitem/nopass')
                              BEGIN
                                    IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @d AND C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i))
                                          BEGIN
                                          /*Summay: If Content records found return the following fields */
                                          SELECT '<list>'+(
                                          SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                          ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                          
                                          ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'None') AS 'ScanSession', @d AS 'Code','^!%' AS 'CellPhone', '^!%' AS 'MetaData',ISNULL(C.Category,'None') AS 'Category',ISNULL(C.Model,'None') AS 'Model',ISNULL(C.Manufacturer,'None') AS 'Manufacturer',
                                          ISNULL(C.PartNumber,'None') AS 'PartNumber',ISNULL(C.ProductLine,'None') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'None') AS 'ManufacturerSKU',ISNULL(C.Description,'None') AS 'Description',
                                          ISNULL(C.UnitMeasure,'None') AS 'UnitMeasure', ISNULL(C.UnitPrice,'None') AS 'UnitPrice',ISNULL(C.Misc1,'None') AS 'Misc1', ISNULL(C.Misc2,'None') AS 'Misc2',ISNULL(I.ForwardURL,'None') AS 'ForwardURL','^!%' AS 'RedemptionData',
                                          '200' AS 'ErrId'
                                          FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                          JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i)
                                          WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                          AND C.Code = @d
                                          FOR XML RAW )+'</list>'
                                          
                                          EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                          RETURN;
                                    END
                                    ELSE
                                 /*Summay: If Content records not found return the following fields */
                                    BEGIN
                                          SELECT '<list>'+(
                                          SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                          ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                          ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'None') AS 'ScanSession',@d AS 'Code','^!%' AS 'CellPhone', '^!%' AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
                                          '^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
                                          '^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',I.ForwardURL AS 'ForwardURL','^!%' AS 'RedemptionData',
                                          '200' AS 'ErrId'
                                          FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                          JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
                                          WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                          FOR XML RAW )+'</list>'
                                          
                                          EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                          RETURN;
                                    END
                         END
                              /*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first “/” */
                  
                             ELSE IF EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2)))
                              BEGIN
                              /*Summay: If Content records found return the following fields */
                              /*Summary: Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code] if not Dynamic code, use passed d to match against Content[code] */
                                    IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.OrgId =ISNULL((SELECT TOP 1 I.orgId FROM dbo.tblInterceptor I WHERE I.IntSerial=@i),'')  AND 
                                    C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
                                    BEGIN
                                    /* Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request*/
                                          IF(@d LIKE '%*CH*%')
                                          BEGIN
                                          SELECT '<list>'+(
                                                SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                                ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                                ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'None') AS 'Code',ISNULL(DC.CellPhone,'None') AS 'CellPhone',ISNULL(DC.MetaData,'None') AS 'MetaData', ISNULL(C.Category,'None') AS 'Category',ISNULL(C.Model,'None') AS 'Model',ISNULL(C.Manufacturer,'None') AS 'Manufacturer',  
                                                ISNULL(C.PartNumber,'None') AS 'PartNumber',ISNULL(C.ProductLine,'None') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'None') AS 'ManufacturerSKU',ISNULL(C.Description,'None') AS 'Description',
                                                ISNULL(C.UnitMeasure,'None') AS 'UnitMeasure', ISNULL(C.UnitPrice,'None') AS 'UnitPrice',ISNULL(C.Misc1,'None') AS 'Misc1',ISNULL(C.Misc2,'None') AS 'Misc2',ISNULL(I.ForwardURL,'None') AS 'ForwardURL',ISNULL(@callHomeRedemption,'None') AS 'RedemptionData',
                                                '200' AS 'ErrId'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId  AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                                JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                                AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                                AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                                AND C.Code =(SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                FOR XML RAW )+'</list>'
                                                
                                                EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                                RETURN;
                                          END
                                        ELSE
                                          BEGIN
                                                SELECT '<list>'+(
                                                SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                                ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                                ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'None') AS 'Code',ISNULL(DC.CellPhone,'None') AS 'CellPhone',ISNULL(DC.MetaData,'None') AS 'MetaData', ISNULL(C.Category,'None') AS 'Category',ISNULL(C.Model,'None') AS 'Model',ISNULL(C.Manufacturer,'None') AS 'Manufacturer',  
                                                ISNULL(C.PartNumber,'None') AS 'PartNumber',ISNULL(C.ProductLine,'None') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'None') AS 'ManufacturerSKU',ISNULL(C.Description,'None') AS 'Description',
                                                ISNULL(C.UnitMeasure,'None') AS 'UnitMeasure', ISNULL(C.UnitPrice,'None') AS 'UnitPrice',ISNULL(C.Misc1,'None') AS 'Misc1',ISNULL(C.Misc2,'None') AS 'Misc2',ISNULL(I.ForwardURL,'None') AS 'ForwardURL','^!%' AS 'RedemptionData',
                                                '200' AS 'ErrId'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                                JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                                AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                                AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                                AND C.Code =(SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                              FOR XML RAW )+'</list>'
                                          
                                        EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                        RETURN;
                                          END
                                    END
                                    /*Summay: If Content records not found return the following fields */
                                    ELSE
                                    BEGIN
                                          /* Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request*/
                                          IF(@d LIKE '%*CH*%')
                                          BEGIN
                                               SELECT '<list>'+(
                                                SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                                ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                                ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'None') AS 'Code',ISNULL(DC.CellPhone,'None') AS 'CellPhone',ISNULL(DC.MetaData,'None') AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
                                                '^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
                                                '^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',I.ForwardURL AS 'ForwardURL',ISNULL(@callHomeRedemption,'None') AS 'RedemptionData',
                                                '200' AS 'ErrId'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
                                                AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                FOR XML RAW )+'</list>'
                                             
                                              EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                                RETURN;
                                          END
                                          ELSE
                                          BEGIN
                                                SELECT '<list>'+(
                                                SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                                ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                                ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'None') AS 'Code',ISNULL(DC.CellPhone,'None') AS 'CellPhone',ISNULL(DC.MetaData,'None') AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
                                                '^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
                                                '^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',I.ForwardURL AS 'ForwardURL','^!%' AS 'RedemptionData',
                                                '200' AS 'ErrId'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID 
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
                                                AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                FOR XML RAW )+'</list>'
                                            
                                              EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                                RETURN;
                                          END
                                    END
                              END
                              
                              /*Summary: if no match in DynamicCode then log an error in SystemEvents */   
                              ELSE
                              BEGIN
                              
                                    SELECT '<list>'+(
                                    SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                                    '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                                    '0' AS 'ScanDate','0' AS 'ScanSession', '0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                                    '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                                    '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                                    '400' AS 'ErrId' FOR XML RAW )+'</list>'
                                    
                                    EXEC upi_SystemEvents 'DeviceScan',2258,3,@d
                                    RETURN;
                              END
                        END
                  
                        /*Summay: if DeviceScan[scanData] is not a dynamic code then do the following */
                        
                        ELSE 
                        BEGIN
                            /*Summay: Match DeviceScan[scanData] against Content[Code] and Interceptor[orgId] against Content[orgId]) */
                            
                              IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @d AND C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i))
                              BEGIN
                                    /*Summay: If Content records found return the following fields */
                                    SELECT '<list>'+(
                                    SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                    ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                    ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'None') AS 'ScanSession', ISNULL(D.ScanData,'None') AS 'Code','^!%' AS 'CellPhone', '^!%' AS 'MetaData',ISNULL(C.Category,'None') AS 'Category',ISNULL(C.Model,'None') AS 'Model',ISNULL(C.Manufacturer,'None') AS 'Manufacturer',
                                    ISNULL(C.PartNumber,'None') AS 'PartNumber',ISNULL(C.ProductLine,'None') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'None') AS 'ManufacturerSKU',ISNULL(C.Description,'None') AS 'Description',
                                    ISNULL(C.UnitMeasure,'None') AS 'UnitMeasure', ISNULL(C.UnitPrice,'None') AS 'UnitPrice',ISNULL(C.Misc1,'None') AS 'Misc1', ISNULL(C.Misc2,'None') AS 'Misc2',ISNULL(I.ForwardURL,'None') AS 'ForwardURL',ISNULL(@callHomeRedemption,'None') AS 'RedemptionData',
                                    '200' AS 'ErrId'
                                    FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                    JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i)
                                    WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                    AND C.Code = @d
                                    FOR XML RAW )+'</list>'
                                    
                                    EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                    RETURN;
                              END
                              ELSE
                              /*Summay: If Content records not found return the following fields */
                              BEGIN
                                    SELECT '<list>'+(
                                    SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                    ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                    ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'None') AS 'ScanSession',ISNULL(D.ScanData,'None') AS 'Code','^!%' AS 'CellPhone', '^!%' AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
                                    '^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
                                    '^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',I.ForwardURL AS 'ForwardURL','^!%' AS 'RedemptionData',
                                    '200' AS 'ErrId'
                                    FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                    JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
                                    WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                    FOR XML RAW )+'</list>'
                                    
                                    EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                    RETURN;
                              END
                        END--forwartype=0 
                  END
                        /*Summary: if Interceptor[forwardType] = 0 (single item forwarding) then:send an HTTP POST request to forwardURL with a JSON object embedded in the request body */
                  ELSE  
                  IF(ISNULL((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WHERE IntSerial=@i),'')= '2')
            BEGIN
             /*Summary :To Check the @d(Data) is Dynamic Code or Not */
              IF(@d LIKE '%~%' AND (@d  NOT LIKE '%DeleteItem/next%' AND @d NOT LIKE '%DeleteItem/prev%' AND @d NOT like '%returnitem/pass' AND @d NOT like '%returnitem/nopass'))
                    BEGIN
                                    
                        /*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first “/” */
                  
                              IF EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2)))
                              BEGIN
                              /*Summay: If Content records found return the following fields */
                              /*Summary: Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code] if not Dynamic code, use passed d to match against Content[code] */
                                    IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.OrgId =ISNULL((SELECT TOP 1 I.orgId FROM dbo.tblInterceptor I WHERE I.IntSerial=@i),'')  AND 
                                    C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
                                    BEGIN
                                    /* Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request*/
                                          IF(@d LIKE '%*CH*%')
                                          BEGIN
                                          SELECT '<list>'+(
                                                SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                                ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                                ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'None') AS 'Code',ISNULL(DC.CellPhone,'None') AS 'CellPhone',ISNULL(DC.MetaData,'None') AS 'MetaData', ISNULL(C.Category,'None') AS 'Category',ISNULL(C.Model,'None') AS 'Model',ISNULL(C.Manufacturer,'None') AS 'Manufacturer',  
                                                ISNULL(C.PartNumber,'None') AS 'PartNumber',ISNULL(C.ProductLine,'None') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'None') AS 'ManufacturerSKU',ISNULL(C.Description,'None') AS 'Description',
                                                ISNULL(C.UnitMeasure,'None') AS 'UnitMeasure', ISNULL(C.UnitPrice,'None') AS 'UnitPrice',ISNULL(C.Misc1,'None') AS 'Misc1',ISNULL(C.Misc2,'None') AS 'Misc2',ISNULL(I.ForwardURL,'None') AS 'ForwardURL',ISNULL(@callHomeRedemption,'None') AS 'RedemptionData',
                                                '200' AS 'ErrId'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId  AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                                JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                                AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                                AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                                AND C.Code =(SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                FOR XML RAW )+'</list>'
                                                
                                                EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                                RETURN;
                                          END
                                        ELSE
                                          BEGIN
                                                SELECT '<list>'+(
                                                SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                                ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                                ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'None') AS 'Code',ISNULL(DC.CellPhone,'None') AS 'CellPhone',ISNULL(DC.MetaData,'None') AS 'MetaData', ISNULL(C.Category,'None') AS 'Category',ISNULL(C.Model,'None') AS 'Model',ISNULL(C.Manufacturer,'None') AS 'Manufacturer',  
                                                ISNULL(C.PartNumber,'None') AS 'PartNumber',ISNULL(C.ProductLine,'None') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'None') AS 'ManufacturerSKU',ISNULL(C.Description,'None') AS 'Description',
                                                ISNULL(C.UnitMeasure,'None') AS 'UnitMeasure', ISNULL(C.UnitPrice,'None') AS 'UnitPrice',ISNULL(C.Misc1,'None') AS 'Misc1',ISNULL(C.Misc2,'None') AS 'Misc2',ISNULL(I.ForwardURL,'None') AS 'ForwardURL','^!%' AS 'RedemptionData',
                                                '200' AS 'ErrId'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                                JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                                AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                                AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                                AND C.Code =(SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                              FOR XML RAW )+'</list>'
                                          
                                        EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                        RETURN;
                                          END
                                    END
                                    /*Summay: If Content records not found return the following fields */
                                    ELSE
                                    BEGIN
                                          /* Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request*/
                                          IF(@d LIKE '%*CH*%')
                                          BEGIN
                                               SELECT '<list>'+(
                                                SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                                ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                                ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'None') AS 'Code',ISNULL(DC.CellPhone,'None') AS 'CellPhone',ISNULL(DC.MetaData,'None') AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
                                                '^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
                                                '^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',I.ForwardURL AS 'ForwardURL',ISNULL(@callHomeRedemption,'None') AS 'RedemptionData',
                                                '200' AS 'ErrId'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
                                                AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                FOR XML RAW )+'</list>'
                                             
                                              EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                                RETURN;
                                          END
                                          ELSE
                                          BEGIN
                                                SELECT '<list>'+(
                                                SELECT TOP 1 @i AS 'IntSerial', ISNULL(I.IntLocDesc,'None') AS 'IntLocDesc', ISNULL(O.OrgName,'None') AS 'OrgName',ISNULL(L.UnitSuite,'None') AS 'UnitSuite', ISNULL(L.Street,'None') AS 'Street',
                                                ISNULL(L.City,'None') AS 'City',ISNULL(L.State,'None') AS 'State',ISNULL(L.Country,'None') AS 'Country',ISNULL(L.PostalCode,'None') AS 'PostalCode',ISNULL(L.LocType,'None') AS 'LocType',ISNULL(L.LocSubType,'None') AS 'LocSubType',
                                                ISNULL(CONVERT(CHAR(33),D.ScanDate,126),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate',ISNULL(D.ScanSession,'') AS 'ScanSession',ISNULL(DC.RedemptionData,'None') AS 'Code',ISNULL(DC.CellPhone,'None') AS 'CellPhone',ISNULL(DC.MetaData,'None') AS 'MetaData','^!%' AS 'Category','^!%' AS 'Model','^!%' AS 'Manufacturer',  
                                                '^!%' AS 'PartNumber','^!%' AS 'ProductLine','^!%' AS 'ManufacturerSKU','^!%' AS 'Description',
                                                '^!%' AS 'UnitMeasure', '^!%' AS 'UnitPrice','^!%' AS 'Misc1', '^!%' AS 'Misc2',I.ForwardURL AS 'ForwardURL','^!%' AS 'RedemptionData',
                                                '200' AS 'ErrId'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID 
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
                                                AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                FOR XML RAW )+'</list>'
                                            
                                              EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                                                RETURN;
                                          END
                                    END
                              END
                              
                              /*Summary: if no match in DynamicCode then log an error in SystemEvents */   
                              ELSE
                              BEGIN
                              
                                    SELECT '<list>'+(
                                    SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                                    '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                                    '0' AS 'ScanDate','0' AS 'ScanSession', '0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                                    '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                                    '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                                    '400' AS 'ErrId' FOR XML RAW )+'</list>'
                                    
                                    EXEC upi_SystemEvents 'DeviceScan',2258,3,@d
                                    RETURN;
                              END --if no match in DynamicCode  end
                          END
                          ELSE
                          BEGIN
                              
                                    SELECT '<list>'+(
                                    SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                                    '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                                    '0' AS 'ScanDate','0' AS 'ScanSession', '0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                                    '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                                    '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                                    '201' AS 'ErrId' FOR XML RAW )+'</list>'
                                    RETURN;
                          END
                        
                        END--forward type=2
                  
                  ELSE IF((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WHERE IntSerial=@i)= '3')
                  BEGIN
                  /* Summary:If ScanBatches already exist then append the scandata in scanBatches */
                     IF(EXISTS(SELECT 1 FROM dbo.tblScanBatches WHERE IntSerial=@i))
                        BEGIN
                        SET @scandata='';
                        SET @scandata= @scandata + (SELECT ScanData FROM dbo.tblScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial =tblScanBatches.intserial WHERE TBLINTERCEPTOR.intserial=@i)
                        END
                        /* Summary:If ScanBatches does not exist then create new scanBatches  record*/
                        ElSE
                        BEGIN
                              SET @scandata='';
                        END 
                         /*Summary :To Check the @d(Data) is Dynamic or Not */
                        IF(@d LIKE '%~%' AND (@d NOT LIKE '%DeleteItem/next%' AND @d NOT LIKE '%DeleteItem/prev%' AND @d NOT like '%returnitem/pass' AND @d NOT like '%returnitem/nopass'))
                  BEGIN
                       /*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first “/” */
                              IF EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2)))
                              BEGIN
                              /*Summay: If Content records found return the following fields */
                              /*Summary: Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code] if not Dynamic code, use passed d to match against Content[code] */
                                    IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.OrgId =ISNULL((SELECT TOP 1 I.orgId FROM dbo.tblInterceptor I WHERE I.IntSerial=@i),'')  AND 
                                    C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID =(SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
                                    BEGIN
                                          /*Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.*/
                                          IF(@d LIKE '%*CH*%')
                                          BEGIN
                                                SET @scandata = @scandata +ISNULL('{'+ (SELECT TOP 1 '"code":' + '"' + ISNULL(DC.RedemptionData,'ISNULL') +'",'+  '"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'ISNULL') +'",'+'"metaData":' +'"'+ ISNULL(CONVERT(VARCHAR,DC.metaData,-1),'NULL')+'",'+ '"RedemptionData":' +'"'+  + ISNULL(@callHomeRedemption,'NULL')+'",'+ '"category":'+'"' + ISNULL(C.category,'NULL') +'",'+'"model":' +'"' +ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ISNULL(C.productLine,'NULL')+'",'+'"manufacturerSKU":'+'"'+ISNULL(C.manufacturerSKU,'NULL')+'",'+'"description":'+'"'+ ISNULL(C.description,'NULL')+'",'+'"unitMeasure":'+'"'+ISNULL(C.unitMeasure,'NULL')+'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ISNULL(C.misc1,'NULL')+'",'+'"misc2":'+'"'+ISNULL(C.misc2,'NULL')+'"' 
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                                JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                                AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
                                          END
                                          ELSE
                                          BEGIN
                                              SET @scandata = @scandata +ISNULL('{'+ (SELECT  TOP 1 '"code":' +'"' + ISNULL( DC.RedemptionData,'NULL') +'",'+  '"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'NULL') +'",'+'"metaData":' +'"'+ ISNULL(CONVERT(VARCHAR,DC.metaData,-1),'NULL') +'",'+ '"category":'+'"' + ISNULL(C.category,'NULL') +'",'+'"model":' +'"' +ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ISNULL(C.productLine,'NULL')+'",'+'"manufacturerSKU":'+'"'+ISNULL(C.manufacturerSKU,'NULL')+'",'+'"description":'+'"'+ISNULL( C.description,'NULL')+'",'+'"unitMeasure":'+'"'+ISNULL(C.unitMeasure,'NULL')+'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ISNULL(C.misc1,'NULL')+'",'+'"misc2":'+'"'+ISNULL(C.misc2,'NULL')+'"'  
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                                JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                                AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
                                          END
                                    END
                                    /*Summay: If Content records not found return the following fields */
                                    ELSE
                                    BEGIN
                                          /* Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request*/
                                          IF(@d LIKE '%*CH*%')
                                          BEGIN
                                                SET @scandata = @scandata +ISNULL('{'+ ( SELECT  TOP 1 '"code":' +'"' +ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'NULL')+'",'+'"metaData":' +'"'+ ISNULL(CONVERT(VARCHAR,DC.metaData,-1),'NULL') +'",' + '"RedemptionData":' +'"'+ ISNULL(@callHomeRedemption,'NULL')+'"'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
                                                AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
                                          END
                                        ELSE
                                          BEGIN
                                                SET @scandata = @scandata +ISNULL('{'+ (SELECT  TOP 1 '"code":' + '"' + ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'NULL') +'",'+'"metaData":' +'"'+ ISNULL(CONVERT(VARCHAR,DC.metaData,-1),'NULL')+'"' 
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
                                                AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) +'}','')
                                          END
                                    END
                              /*Summary: if no match in DynamicCode then log an error in SystemEvents */
                              END
                              ELSE
                              BEGIN
                                    SELECT '<list>'+(
                                    SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                                    '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                                    '0' AS 'ScanDate','0' AS 'ScanSession', '0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                                    '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                                    '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                                    '400' AS 'ErrId' FOR XML RAW )+'</list>'
                                    
                                    EXEC upi_SystemEvents 'DeviceScan',2258,1,@d
                                    RETURN;
                              END
                        
                        /* Summary:If ScanBatches already exist then append the scandata in scanBatches */
                        IF EXISTS(SELECT 1 FROM dbo.tblScanBatches WHERE IntSerial=@i)
                        BEGIN
        
                        --DeliveryTime = DATEADD(ss,numOfSeconds,DateField)
                              SET @MaxBatchtime=(SELECT TOP 1 ISNULL(MaxBatchWaitTime,0) FROM dbo.tblInterceptor WHERE IntSerial=@i)
                              
                              UPDATE  tblScanBatches SET ScanData=@scandata,DeliveryTime=DATEADD(ss,@MaxBatchtime,@date) WHERE IntSerial=@i
                              EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                              SELECT '<list>'+(
                              SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                              '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                              '0' AS 'ScanDate','0' AS 'ScanSession', '0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                              '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                              '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                              '0' AS 'ErrId' FOR XML RAW )+'</list>'
                              RETURN      
                        END
                        ElSE
                        BEGIN
                              /* Summary:If ScanBatches does not exist then create new scanBatches  record*/
                              SET @MaxBatchtime=(SELECT TOP 1 ISNULL(MaxBatchWaitTime,0) FROM dbo.tblInterceptor WHERE IntSerial=@i)
                              INSERT tblScanBatches SELECT  I.intSerial ,O.orgName,DATEADD(ss,@MaxBatchtime,@date),I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc,@scandata,@date  FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId  AND L.LocId=I.LocID
                              WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) and  I.IntSerial=@i
                              
                              EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                              
                            SELECT '<list>'+(
                              SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                              '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                              '0' AS 'ScanDate','0' AS 'ScanSession','0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                              '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                              '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                              '0' AS 'ErrId' FOR XML RAW )+'</list>'
                              
                              RETURN      
                      END
                  END
                  ELSE
                  BEGIN
     SELECT '<list>'+(
                    SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                              '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                        '0' AS 'ScanDate','0' AS 'ScanSession','0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                              '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                        '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                        '201' AS 'ErrId' FOR XML RAW )+'</list>'
                        RETURN 
                  END
                  --3END
                  END  
                   
                  /* Summary: if Interceptor[forwardType] = 1 (batch forwarding) then do the folowing step*/
                  ELSE IF((SELECT TOP 1 [forwardtype] FROM dbo.tblInterceptor WHERE IntSerial=@i)= '1')
                  BEGIN
                  /* Summary:If ScanBatches already exist then append the scandata in scanBatches */
                     IF(EXISTS(SELECT 1 FROM dbo.tblScanBatches WHERE IntSerial=@i))
                        BEGIN
                        SET @scandata='';
                        SET @scandata= @scandata + (SELECT ScanData FROM dbo.tblScanBatches inner join  TBLINTERCEPTOR on TBLINTERCEPTOR.intserial =tblScanBatches.intserial WHERE TBLINTERCEPTOR.intserial=@i)
                        END
                        /* Summary:If ScanBatches does not exist then create new scanBatches  record*/
                        ElSE
                        BEGIN
                              SET @scandata='';
                        END 
                         /*Summary :To Check the @d(Data) is Dynamic or Not */
                        IF(@d LIKE '%~%')
                  BEGIN
                        IF(@d LIKE '%DeleteItem/next%' or @d LIKE '%DeleteItem/prev%' or @d like '%returnitem/pass' or @d like '%returnitem/nopass')
                              BEGIN
                                    IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @d AND C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i))
                                          BEGIN
                                          /*Summay: If Content records found return the following fields */
                                          SET @scandata = @scandata +ISNULL('{'+ (SELECT TOP 1 '"code":' + '"' + ISNULL(@d,'ISNULL') +'",'+ '"category":'+'"' + ISNULL(C.category,'NULL') +'",'+'"model":' +'"' +ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ISNULL(C.productLine,'NULL')+'",'+'"manufacturerSKU":'+'"'+ISNULL(C.manufacturerSKU,'NULL')+'",'+'"description":'+'"'+ ISNULL(C.description,'NULL')+'",'+'"unitMeasure":'+'"'+ISNULL(C.unitMeasure,'NULL')+'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ISNULL(C.misc1,'NULL')+'",'+'"misc2":'+'"'+ISNULL(C.misc2,'NULL')+'"' 
                                          FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                          JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i)
                                          WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                          AND C.Code = @d) + '}','')
                                          
                                    END
                                    ELSE
                                 /*Summay: If Content records not found return the following fields */
                                    BEGIN
                                          SET @scandata = @scandata + ISNULL('{'+ (SELECT TOP 1 '"code":' + '"' + ISNULL(@d,'ISNULL') 
                                          FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                          JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial
                                          WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d ) + '}','')
                                    END
                         END
                       /*Summary: Use the dynCID to search for the DynamicCode record WHERE dynCID is sandwiched between the ~ and the first “/” */
                              ELSE IF EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2)))
                              BEGIN
                              /*Summay: If Content records found return the following fields */
                              /*Summary: Check for matching Content record: use Interceptor[orgId] plus:if Dynamic Code, use DynamicCode[redemptionData] to match against Content[code] if not Dynamic code, use passed d to match against Content[code] */
                                    IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.OrgId =ISNULL((SELECT TOP 1 I.orgId FROM dbo.tblInterceptor I WHERE I.IntSerial=@i),'')  AND 
                                    C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID =(SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))))
                                    BEGIN
                                          /*Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request.*/
                                          IF(@d LIKE '%*CH*%')
                                          BEGIN
                                                SET @scandata = @scandata +ISNULL('{'+ (SELECT TOP 1 '"code":' + '"' + ISNULL(DC.RedemptionData,'ISNULL') +'",'+  '"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'ISNULL') +'",'+'"metaData":' +'"'+ ISNULL(CONVERT(VARCHAR,DC.metaData,-1),'NULL')+'",'+ '"RedemptionData":' +'"'+  + ISNULL(@callHomeRedemption,'NULL')+'",'+ '"category":'+'"' + ISNULL(C.category,'NULL') +'",'+'"model":' +'"' +ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ISNULL(C.productLine,'NULL')+'",'+'"manufacturerSKU":'+'"'+ISNULL(C.manufacturerSKU,'NULL')+'",'+'"description":'+'"'+ ISNULL(C.description,'NULL')+'",'+'"unitMeasure":'+'"'+ISNULL(C.unitMeasure,'NULL')+'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ISNULL(C.misc1,'NULL')+'",'+'"misc2":'+'"'+ISNULL(C.misc2,'NULL')+'"' 
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                                JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                                AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
                                          END
                                          ELSE
                                          BEGIN
                                              SET @scandata = @scandata +ISNULL('{'+ (SELECT  TOP 1 '"code":' +'"' + ISNULL( DC.RedemptionData,'NULL') +'",'+  '"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'NULL') +'",'+'"metaData":' +'"'+ ISNULL(CONVERT(VARCHAR,DC.metaData,-1),'NULL') +'",'+ '"category":'+'"' + ISNULL(C.category,'NULL') +'",'+'"model":' +'"' +ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ISNULL(C.manufacturer,'NULL')+'",'+'"partNumber":'+'"'+ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ISNULL(C.productLine,'NULL')+'",'+'"manufacturerSKU":'+'"'+ISNULL(C.manufacturerSKU,'NULL')+'",'+'"description":'+'"'+ISNULL( C.description,'NULL')+'",'+'"unitMeasure":'+'"'+ISNULL(C.unitMeasure,'NULL')+'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ISNULL(C.misc1,'NULL')+'",'+'"misc2":'+'"'+ISNULL(C.misc2,'NULL')+'"'  
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                                JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                                AND C.Code = (SELECT RedemptionData FROM dbo.tblDynamicCode WHERE DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
                                          END
                                    END
                                    /*Summay: If Content records not found return the following fields */
                                    ELSE
                                    BEGIN
                                          /* Summary:To check the CallHomeURL then This "redemptionData" <redemptionData> received from callHomeURL  will be added only if the passed d contains a Call Home request*/
                                          IF(@d LIKE '%*CH*%')
                                          BEGIN
                                                SET @scandata = @scandata +ISNULL('{'+ ( SELECT  TOP 1 '"code":' +'"' +ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'NULL')+'",'+'"metaData":' +'"'+ ISNULL(CONVERT(VARCHAR,DC.metaData,-1),'NULL') +'",' + '"RedemptionData":' +'"'+ ISNULL(@callHomeRedemption,'NULL')+'"'
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
                                                AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) + '}','')
                                          END
                                        ELSE
                                          BEGIN
                                                SET @scandata = @scandata +ISNULL('{'+ (SELECT  TOP 1 '"code":' + '"' + ISNULL(DC.RedemptionData,'NULL') +'",'+'"cellphone":'+'"'+ ISNULL(CONVERT(VARCHAR,DC.cellphone,64),'NULL') +'",'+'"metaData":' +'"'+ ISNULL(CONVERT(VARCHAR,DC.metaData,-1),'NULL')+'"' 
                                                FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                                JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblDynamicCode DC ON DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))
                                                WHERE I.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d 
                                                AND DC.DynCID = (SELECT SUBSTRING(@d,CHARINDEX('~',@d)+1,CHARINDEX('/',@d)-2))) +'}','')
                                          END
                                    END
                              END
                              /*Summary: if no match in DynamicCode then log an error in SystemEvents */
                              ELSE
                              BEGIN
                                    SELECT '<list>'+(
                                    SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                                    '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                                    '0' AS 'ScanDate','0' AS 'ScanSession', '0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                                    '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                                    '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                                    '400' AS 'ErrId' FOR XML RAW )+'</list>'
                                    
                                    EXEC upi_SystemEvents 'DeviceScan',2258,1,@d
                                    RETURN;
                              END
                        END
                        /*Summay: if DeviceScan[scanData] is not a dynamic code then do the following */
                        ELSE
                        BEGIN
                              IF EXISTS (SELECT 1 FROM dbo.tblContent C WHERE C.Code = @d AND C.OrgId = (SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i))
                              BEGIN
                              /*Summay: If Content records found return the following fields */
                                    SET @scandata = @scandata +ISNULL('{'+ (SELECT  TOP 1 '"code":' +'"' + ISNULL(@d,'NULL') +'",'+ '"category":'+'"'+ ISNULL(C.category,'NULL') +'",'+'"model":' +'"' + ISNULL(C.model,'NULL') +'",'+'"manufacturer":'+'"'+ ISNULL(C.manufacturer,'NULL') +'",'+'"partNumber":'+'"'+ ISNULL(C.partNumber,'NULL') +'",'+'"productLine":'+'"'+ISNULL(C.productLine,'NULL')+'",'+'"manufacturerSKU":'+'"'+ISNULL(C.manufacturerSKU,'NULL')+'",'+'"description":'+'"'+ISNULL(C.description,'NULL') +'",'+'"unitMeasure":'+'"'+ISNULL(C.unitMeasure,'NULL')+'",'+'"unitPrice":'+'"'+ISNULL(CONVERT(VARCHAR,C.unitPrice),'NULL')+'",'+'"misc1":'+'"'+ISNULL(C.misc1,'NULL')+'",'+'"misc2":'+'"'+ISNULL(C.misc2,'NULL')+'"'  
                                    FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                    JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial JOIN tblContent C ON C.OrgId = I.OrgId
                                    WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND D.IntSerial = @i AND D.ScanData =@d
                                    AND C.Code = @d ) +'}','')
                              END
                              ELSE
                              BEGIN
                                    /*Summay: If Content records not found return the following fields */
                                    SET @scandata = @scandata +ISNULL('{'+ (SELECT  TOP 1 '"code":' +'"' + ISNULL(@d,'NULL')+'"'  
                                    FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId AND L.LocId=I.LocID
                                    JOIN tblDeviceScan D ON D.IntSerial=I.IntSerial WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                    AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) 
                                    AND D.IntSerial = @i AND D.ScanData =@d) + '}','')
                              END
                        END
                        /* Summary:If ScanBatches already exist then append the scandata in scanBatches */
                        IF EXISTS(SELECT 1 FROM dbo.tblScanBatches WHERE IntSerial=@i)
                        BEGIN
                        --DeliveryTime = DATEADD(ss,numOfSeconds,DateField)
                              SET @MaxBatchtime=(SELECT TOP 1 ISNULL(MaxBatchWaitTime,0) FROM dbo.tblInterceptor WHERE IntSerial=@i)
                              
                              UPDATE  tblScanBatches SET ScanData=@scandata,DeliveryTime=DATEADD(ss,@MaxBatchtime,@date) WHERE IntSerial=@i
                              EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                              SELECT '<list>'+(
                              SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                              '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                              '0' AS 'ScanDate','0' AS 'ScanSession', '0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                              '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                              '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                              '0' AS 'ErrId' FOR XML RAW )+'</list>'
                              RETURN      
                        END
                        ElSE
                        BEGIN
                              /* Summary:If ScanBatches does not exist then create new scanBatches  record*/
                              SET @MaxBatchtime=(SELECT TOP 1 ISNULL(MaxBatchWaitTime,0) FROM dbo.tblInterceptor WHERE IntSerial=@i)
                              INSERT tblScanBatches SELECT  I.intSerial ,O.orgName,DATEADD(ss,@MaxBatchtime,@date),I.ForwardURL,L.unitSuite,L.street,L.city,L.state,L.country,L.postalCode,L.locType,L.locSubType,I.intLocDesc,@scandata,@date  FROM dbo.tblInterceptor I JOIN tblOrganization O ON I.OrgId=O.OrgId JOIN tblLocation L ON I.OrgId=L.OrgId  AND L.LocId=I.LocID
                              WHERE I.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND O.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) AND L.OrgId =(SELECT TOP 1 It.orgId FROM dbo.tblInterceptor It WHERE It.IntSerial=@i) and  I.IntSerial=@i
                              
                              EXEC upi_SystemEvents 'DeviceScan',2261,1,@i
                              
                            SELECT '<list>'+(
                              SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                              '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                              '0' AS 'ScanDate','0' AS 'ScanSession','0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                              '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                              '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                              '0' AS 'ErrId' FOR XML RAW )+'</list>'
                              
                              RETURN      
                      END 
                  END
            END
            ELSE
            BEGIN
                SELECT '<list>'+(
                        SELECT  '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
                              '0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
                        '0' AS 'ScanDate','0' AS 'ScanSession','0' AS 'Code','0' AS 'CellPhone','0' AS 'MetaData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',  
                              '0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'Description',
                        '0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1', '0' AS 'Misc2','0' AS 'ForwardURL','0' AS 'RedemptionData',
                        '201' AS 'ErrId' FOR XML RAW )+'</list>'
                        RETURN      
            END
            
      END               
END

GO
/****** Object:  StoredProcedure [dbo].[upi_DeviceStatus]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author:		Dineshkumar G
-- Create date: 01.06.2013
-- Modified Date:18.02.2013
-- Routine:		DeviceStatus
-- Method:		POST
-- Description:	Handles HTTP requests (from Interceptor devices) that are sending status reports
-- Modified By :G.Prakash(07.15.2013)

-- =============================================================================================================

CREATE PROCEDURE [dbo].[upi_DeviceStatus]
@a VARCHAR (40), @intSerial VARCHAR (12), @startURL VARCHAR (100), @reportURL VARCHAR (100), @scanURL VARCHAR (100), @bkupURL VARCHAR (100), @capture INT, @captureMode INT, @requestTimeoutValue INT, @callHomeTimeoutMode INT, @callHomeTimeoutData VARCHAR (50), @dynCodeFormat VARCHAR (5550), @security INT, @errorLog VARCHAR (MAX), @wpaPSK VARCHAR (64), @ssid VARCHAR (40), @CmdURL VARCHAR (100), @cmdChkInt INT, @RevId VARCHAR (12)
AS
BEGIN

 SET NOCOUNT ON;
 
 -- Output descriptions
 -- 400 - Bad Request
 -- 201 - Created
 -- 200 - Success
 
 -- Local variables descriptions
 -- @ReturnResult used to return results
 -- @date used to store the current date and time from the SQL Server
 -- @eventData used to store event data description
 
 DECLARE @ReturnResult AS VARCHAR(MAX)
 DECLARE @date   AS DATETIMEOFFSET(7)
 DECLARE @intID   AS INT
 DECLARE @orgId   AS INT
 DECLARE @eventData  AS VARCHAR(1000)
 DECLARE @severData  AS VARCHAR(50)
 DECLARE @ErroglogData AS VARCHAR(1000)
 DECLARE @AlertDate  AS VARCHAR(1000)
 DECLARE @AlertID  AS VARCHAR(1000)
 DECLARE @AlertData  AS VARCHAR(1000)
 DECLARE @NameValuePairs AS NVARCHAR(MAX) 
 DECLARE @NameValuePair	AS NVARCHAR(100)
 DECLARE @timestamp	AS NVARCHAR(100)
 DECLARE @errorcode	AS NVARCHAR(100)
 DECLARE @errordata	AS NVARCHAR(100)
 DECLARE @id AS INT
 DECLARE @CURSORID AS INT
 DECLARE @Count	AS INT
 DECLARE @Errorreturn AS int
 DECLARE @timestamp1 	AS NVARCHAR(100)
 DECLARE @Property TABLE ([id] INT IDENTITY(1,1) ,[timestamp] Nvarchar(100),[errorcode] NVARCHAR(100),[errordata] NVARCHAR(100))
 DECLARE @TempScan table (ID INT IDENTITY(1,1) NOT NULL,contentData NVARCHAR(Max))

 SET @date = SYSDATETIMEOFFSET();
 
 SET @eventData = 'a=' + Convert(VARCHAR(32), @a) + '; Intserial='+ Convert(VARCHAR(12), @intSerial)+ ';  startURL='+ Convert(VARCHAR(100), @startURL)+ '; reportURL='+ Convert(VARCHAR(100), @reportURL)+ '; scanURL='+ Convert(VARCHAR(50), @scanURL)+ '; bkupURL='+ Convert(VARCHAR(100), @bkupURL)+ '; 
 capture='+ Convert(VARCHAR(50), @capture)+ '; captureMode='+ Convert(VARCHAR(50), @captureMode)+ '; requestTimeoutValue='+ Convert(VARCHAR(50), @requestTimeoutValue)+ '; callHomeTimeoutMode='+ Convert(VARCHAR(50), @callHomeTimeoutMode)+ '; callHomeTimeoutData='+ Convert(VARCHAR(50), @callHomeTimeoutData)+ '; dynCodeFormat='+ Convert(VARCHAR(50), @dynCodeFormat)+ '; errorLog='+ Convert(VARCHAR(50), @errorLog)+ '; wpaPSK='+ Convert(VARCHAR(50), @wpaPSK)+ ';ssid='+ Convert(VARCHAR(50), @ssid)+';CmdURL='+ Convert(VARCHAR(100), @CmdURL)+ '; cmdChkInt='+ Convert(VARCHAR(100), @cmdChkInt)+ '; RevId='+ Convert(VARCHAR(50), @RevId)
 
--OR (ISNULL(@callHomeTimeoutData,'') = '') OR (ISNULL(@errorLog,'') = '')
 IF((ISNULL(@intSerial,'') = '') OR (ISNULL(@a,'') = '') OR (ISNULL(@startURL,'') = '') OR (ISNULL(@reportURL,'') = '') OR (ISNULL(@scanURL,'') = '')
	OR (ISNULL(@bkupURL,'') = '') OR (ISNULL(@cmdURL,'') = '')
    OR @dynCodeFormat IS NULL  OR (@callHomeTimeoutData = '') OR (@errorLog = '')
	OR (@wpaPSK = '') OR (@ssid = '') OR (ISNULL(@revId,'') = '')
	OR @capture IS NULL OR @captureMode IS NULL OR @requestTimeoutValue IS NULL OR @callHomeTimeoutMode IS NULL
	OR @security IS NULL OR @cmdChkInt IS NULL)
 BEGIN
  SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue1
     RETURN;
 END
 ELSE
 BEGIN
 --select CONVERT(VARCHAR(40),HashBytes('SHA1','TEST00001111'),2)
  IF EXISTS(SELECT 1 FROM dbo.tblInterceptorID WHERE IntSerial=@intSerial)
  AND EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial=@intSerial)
  BEGIN
   IF(@a <> (SELECT top 1 CONVERT(VARCHAR(40),HashBytes('SHA1', EmbeddedId),2) FROM dbo.tblInterceptorID WHERE IntSerial=@intSerial))
   BEGIN
    SET @ReturnResult = '400' SELECT @ReturnResult AS Returnvalue2
    EXEC upi_SystemEvents 'DeviceStatus',2453,3,@a
    RETURN;
   END
   ELSE
   BEGIN
	INSERT INTO @TempScan(contentData)SELECT items from Splitrow(@errorLog,';')

	/*------------------Cursor Open---------*/
	  DECLARE TEMP_cursor CURSOR FOR SELECT t.ID FROM @TempScan t 
			OPEN TEMP_cursor;  
			FETCH NEXT FROM TEMP_cursor INTO @CURSORID;
			WHILE @@FETCH_STATUS  =  0  
				  BEGIN
						 SET @id = 0;
						 SELECT @NameValuePairs   =  D.contentData from @TempScan D WHERE D.ID  =  @CURSORID
						 IF(@NameValuePairs LIKE '%///%///%') 
						 BEGIN
							  WHILE LEN(@NameValuePairs) > 0
							  BEGIN
								 SET  @id = @id+1;
								 SET @NameValuePair  =  LEFT(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(';', @NameValuePairs) - 1, -1),LEN(@NameValuePairs)))
								 SET @NameValuePairs  =  SUBSTRING(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(';', @NameValuePairs), 0),LEN(@NameValuePairs)) + 1, LEN(@NameValuePairs))
								 set @NameValuePair = replace (@NameValuePair,'///', '¶')
								 
								 INSERT INTO @Property([timestamp], [errorcode], [errordata])SELECT Timestampdata, errorcode, errordata  from fnSplitColoumn(@NameValuePair,'¶')
     						 END
						END
						ELSE
						BEGIN
						select '400' AS 'Return Value2'
							--Return '400'
						END
				  FETCH NEXT FROM TEMP_cursor INTO @CURSORID;
				  END
			CLOSE TEMP_cursor;
			DEALLOCATE TEMP_cursor;
/***-----------------Cursor Closed --------------------****/

/***------ Validate Error Code,Timestamp,Error data Start	-------**/
					
						SELECT @Count =COUNT(*) FROM @Property
						DECLARE @i	INT
                        SET @i = 1
						DECLARE @errorcount int
						SET @errorcount= 0;
                        WHILE( @i < =  @Count)
                        BEGIN
							SELECT @timestamp1 =isnull([timestamp],''),@errorcode =isnull([errorcode],''),@errorData =isnull([errordata],'') FROM @Property WHERE id = @i
							IF(@timestamp1 <> '' and @errorcode <> '' and @errorData <> '')
							BEGIN
						
							   IF (CHARINDEX('T',@timestamp1) <> 0 AND (CHARINDEX('+',@timestamp1) <> 0 OR CHARINDEX('-',@timestamp1) <> 0 OR CHARINDEX('Z',@timestamp1) <> 0))
								BEGIN
									 DECLARE @zone AS varchar(50)
									 DECLARE @date2 AS varchar(50)
									 DECLARE @date3 AS varchar(50)
									 DECLARE @time1 AS VARCHAR(18)
									 DECLARE @AlertDateime1 AS varchar(18)
									 DECLARE @zonehh AS varchar(4)
									 DECLARE @zonemm AS varchar(4)
								IF(CHARINDEX('Z',@timestamp1)<> 0)
								BEGIN
									SET @date2 = ( SUBSTRING(@timestamp1,1,CHARINDEX('T',@timestamp1)-1))
				   					SET @zone = ( SUBSTRING(@timestamp1,CHARINDEX('T',@timestamp1)+1,LEN(@timestamp1)))
				   					SET @AlertDateime1 = ( SUBSTRING(@zone,1,CHARINDEX('Z',@zone)-1))
									SET @zonehh ='00'
				   					SET @zonemm ='00' 
																		
								END
								ELSE IF(CHARINDEX('+',@timestamp1) <> 0)
             					BEGIN
							
									SET @date2=( substring(@timestamp1,1,CHARINDEX('+',@timestamp1)-1))
									SET @zone=( substring(@timestamp1,CHARINDEX('+',@timestamp1)+1,len(@timestamp1)))
									SET @AlertDateime1=(SELECT substring(@date2,CHARINDEX('T',@date2)+1,len(@date2)))
									SET @date2=( substring(@timestamp1,1,CHARINDEX('T',@timestamp1)-1))
									SET @zonehh=( substring(@zone,1,CHARINDEX(':',@zone)-1))
									SET @zonemm=( substring(@zone,CHARINDEX(':',@zone)+1,len(@zone))) 
									
								END
								ELSE IF(CHARINDEX('-',@timestamp1) <> 0)
								BEGIN
							        Declare @CntSign AS int
							        SET  @CntSign=(select len(@timestamp1) - len(replace(@timestamp1, '-', '')))
									IF(@CntSign = 3)
									BEGIN
									 SET @date2=( substring(@timestamp1,1,CHARINDEX('T',@timestamp1)-1))
									 SET @zone=( substring(@timestamp1,CHARINDEX('T',@timestamp1)+1,len(@timestamp1)))
									 SET @AlertDateime1=( substring(@zone,1,CHARINDEX('-',@zone)-1))
								     SET @zone=( substring(@zone,CHARINDEX('-',@zone)+1,len(@zone)))
									 SET @zonehh=( substring(@zone,1,CHARINDEX(':',@zone)-1))
									 SET @zonemm=( substring(@zone,CHARINDEX(':',@zone)+1,len(@zone))) 
								  END
								  ELSE
								  BEGIN
									SET @errorcount= @errorcount + 1;
								  END
								END
											
								IF(ISDATE(@date2) = 1)
								BEGIN
									 
									 DECLARE @AlertDateime2 AS varchar(30)
									 DECLARE @AlertDateime3 AS varchar(12)
									 SET @AlertDateime2=replace(replace(@AlertDateime1,':',''),'.','')
									 
					
								 IF(isnumeric(@AlertDateime2)=1)
								 BEGIN
								
								 SET @AlertDateime3=(SELECT substring(@AlertDateime1,1,12))
								 SET @date3=@date2+' '+@AlertDateime3
								
									 IF(ISDATE(@date3) = 1)
									 BEGIN
										IF((@zonehh between '00' and '14') AND (@zonemm between '00' and '59'))
										BEGIN
					
     										IF(isnumeric(@errorcode)=1)  
												BEGIN    
													IF(len(@errorcode)=3) 
													BEGIN
													 --IF(@AlertData='bypassmode')
													 --BEGIN
													 IF(@errorcount = 0)
													 BEGIN
														 SET @errorcount = @errorcount + 0 
													 END
													 ELSE  SET @errorcount = @errorcount + 1
													END   --length of error code
													ELSE  SET @errorcount = @errorcount + 1
												END --isnuemric of error Code
												ELSE  SET @errorcount = @errorcount + 1
          
										 END --@zonehh @zonemm
										 ELSE  SET @errorcount = @errorcount + 1
								 END --ISDATE(@date3)
								 ELSE  SET @errorcount = @errorcount + 1
							 END --@AlertDateime2
							ELSE  SET @errorcount = @errorcount + 1
						END --ISDATE(@date2) 
						ELSE  SET @errorcount = @errorcount + 1
					 END --time check
					 ELSE   SET @errorcount = @errorcount + 1
					 END--null check
				  ELSE   SET @errorcount = @errorcount + 1
							SET @i = @i + 1;
				END

	/***------ Validate Error Code,Timestamp,Error data End	-------**/			
		
	IF( @errorcount = 0 )
	BEGIN		
		INSERT INTO tblDeviceStatus(IntSerial,LogDate,StartURL, ReportURL,ScanURL, BkupURL,Capture, CaptureMode, RequestTimeoutValue, CallHomeTimeoutMode, CallHomeTimeoutData, DynCodeFormat, [Security], ErrorLog, WpaPSK,SSId,CmdURL,CmdChkInt,RevId)
		VALUES(@intSerial,@date,@startURL, @reportURL, @scanURL, @bkupURL, @capture, @captureMode, @requestTimeoutValue, @callHomeTimeoutMode, @callHomeTimeoutData, @dynCodeFormat, @security, @errorLog, @wpaPSK, @ssid,@CmdURL,@cmdChkInt,@RevId)  
	---	SET @intID = @@IDENTITY
	 -- SET @ErroglogData= @errorLog
		SELECT  @orgId=orgid FROM dbo.tblInterceptor i WHERE IntSerial=@intSerial
		IF EXISTS(SELECT 1 FROM @Property WHERE errorcode='900' AND errordata='bypassmode' AND id=1)
			BEGIN
				SELECT  @timestamp=[timestamp],@AlertID=errorcode , @AlertData=errordata from @Property WHERE id=1
				INSERT INTO  tblAlerts(OrgId,[TimeStamp],AlertId,AlertData)VALUES(@orgId,@timestamp,'900','bypassmode')
			END
		EXEC upi_SystemEvents 'DeviceStatus',2455,1,@eventData
		SELECT '201' AS 'Returnvalue'
	END
	ELSE
	BEGIN
	select '400' AS 'ReturnValue1'
		--Return '400'
	END
 END  
 
  END
 END
END

--{"a":"c191e16993b7fc19955cff4d37c577827d7763df","intSerial":"000000000001","startURL":"http://cozumoapi.cloudapp.net/api/DeviceSetting","reportURL":"http://cozumoapi.cloudapp.net/api/DeviceStatus","scanURL":"http://cozumoapi.cloudapp.net/api/DeviceScan","bkupURL":"http://cozumoapi.cloudapp.net/api/DeviceBackup","cmdURL":"http://cozumoapi.cloudapp.net/api/ICmd","capture":"1","captureMode":"0","requestTimeoutValue":"200",callHomeTimeoutMode:"2","callHomeTimeoutData":"ABCDEF123","dynCodeFormat":"~*[1,12]/*[1,63]","security":"0","errorLog":"1997- 07-16T19:20:30.45+01:00///400///Bad Request","wpaPSK":"1","ssid":"43B81B4F768D0549AB4F178022DEB384", "cmdChkInt":"15","revId":"Cozumo Firmware 4.1"}
--{"a":"E6A6A63057A146F86C6D0F94142F9F49","intSerial":"A2","publicIP":"192.168.1.20","privateIP":"74.86.127","startURL":"http://starturl","reportURL":"http://reporturl","scanURL":"http://scanurl","bkupURL":"http://backupurl","capture":"1",
--"captureMode":"1","requestTimeoutValue":"1","callHomeTimeoutMode":"300","callHomeTimeoutData":"200","dynCodeFormat":"1","security":"1","errorLog":"errorlog","wpaPSK":"wpa","port":"8040","ssid":"123"}
--exec [upi_DeviceStatus] 'c191e16993b7fc19955cff4d37c577827d7763df','000000000001','http://cozumoapi.cloudapp.net/api/DeviceSetting','http://cozumoapi.cloudapp.net/api/DeviceStatus','http://cozumoapi.cloudapp.net/api/DeviceScan','http://cozumoapi.cloudapp.net/api/DeviceBackup','1','0','200','2',NULL,'~*[1,12]/*[1,63]','0','2014-03-13T20:14:03.7074695Z///902///Scanner??Disconnected;2014-03-13T20:17:50.7474695Z///400///URL: cozumoapi.cloudapp.net\\/api\\/DeviceScan | POST {\"a\": \"7FEF5C2865C3DAC9872FED67A238D2EECBA9C1FA\", \"i\": \"0080A395321E\", \"d\": \"~4444\\/9\" };2014-03-13T20:19:23.5974695Z///960///Invalid Barcode: ~12345/456/*CH*/8906;2014-03-13T20:25:56.8574695Z///961///Invalid Config Barcode: Param=dynCodeFormat Value=~*[1',NULL,NULL,'http://cozumoapi.cloudapp.net/api/ICmd','15','Cozumo Firmware 4.1'
--exec [upi_DeviceStatus] '99e0c2a5993faad32664fd8e9264f0082605841d','INT2222222AB','http://cozumoapi.cloudapp.net/api/DeviceSetting','http://cozumoapi.cloudapp.net/api/DeviceStatus','http://cozumoapi.cloudapp.net/api/DeviceScan','http://cozumoapi.cloudapp.net/api/DeviceBackup','1','0','200','2',NULL,'','0','1997-07-16T19:20:30.45+01:00///900///bypassmode;2014-02-06T23:26:18.7739667Z///900///bypassmo',NULL,NULL,'http://cozumoapi.cloudapp.net/api/ICmd','15','Cozumo Firmware 4.1'



GO
/****** Object:  StoredProcedure [dbo].[upi_DynamicCode]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================================
-- Author:		Prakash G
-- Create date: 10.06.2013
-- Routine:		DynamicCode
-- Method:		POST
-- Description:	Returns binary image data (uuencoded, PNG image format) for a QR Code
--              Also creates a DynamicCode record.This routine enables metadata to be 
--              linked to a transaction. Metadata is stored in a DynamicCode record. 
--				The record ID is embedded into a QR Code image. When the QR Code is scanned/intercepted the
--              embedded record ID can be extracted and used to retrieve the DynamicCode record.
-- =========================================================================================================
CREATE PROCEDURE [dbo].[upi_DynamicCode] 
	
	@applicationKey			AS VARCHAR(40),
	@sessionKey				AS VARCHAR(40),
	@cellPhone				AS VARCHAR(64),
	@callHomeData			AS VARCHAR(64),
	@callHomeURL			AS VARCHAR(256),
	@callHomeTimeoutValue	AS INT,
	@redemptionData			AS VARCHAR(63),
	@metaData				AS NVARCHAR(256)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	    
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @RedemptionID used to return RedemptionData
	-- @intID  used to return the DYNCID
	-- @errorReturn used to store the error message
		
	DECLARE @ReturnResult	AS NVARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @RedemptionID	AS VARCHAR(63)
	DECLARE @intID			AS INT
	DECLARE @errorReturn	AS NVARCHAR(MAX)
	
	SET @errorReturn	= '400'
	SET @date			= SYSDATETIMEOFFSET();
	SET @UserId			= (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE @sessionKey = sessionKey)
	
	 /* Summary: if Session[accessLevel] != SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW then return HTTP code “401 Unauthorized */
	 IF(@accessLevel<>1 AND @accessLevel<>3 AND @accessLevel<>5 AND @accessLevel<>7)
		BEGIN
			SET	@ReturnResult = '401'
			SELECT @ReturnResult AS Returnvalue1
			EXEC upi_SystemEvents 'DynamicCode',2173,3,@accessLevel
			RETURN;
		END
	/* Summary:Raise an Error Message. if the mandatory fields cellPhone and  redemptionData are not passed */

	IF(ISNULL(@cellPhone,'')='' OR ISNULL(@redemptionData,'')='')
	BEGIN
	 	IF(ISNULL(@cellPhone,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|2152 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 2152)
		IF(ISNULL(@redemptionData,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|2156 ' + DESCRIPTION +'|' + FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 2156)
	END
	
  	/* Summary:Raise an Error Message.If any of the data exceeds the max length or cellPhone number already exists in data store*/
  	
	IF(LEN(@cellPhone) > 64 OR LEN(@redemptionData)> 63 OR LEN(@callHomeData) > 64 OR LEN(@callHomeURL) > 256 OR LEN(@metaData) > 256 OR EXISTS(SELECT CellPhone FROM dbo.tblDynamicCode WHERE CellPhone = @cellPhone))
	BEGIN
	  ---IF EXISTS(SELECT 1 FROM dbo.tblDynamicCode WHERE CellPhone = @cellPhone)SET @errorReturn = @errorReturn+(SELECT +'|2153 ' + DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode= 2153)+ @cellPhone
	  IF(LEN(@cellPhone) > 64) SET @errorReturn = @errorReturn+(SELECT +'|2154 ' + DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode= 2154)+ @cellPhone
	  IF(LEN(@redemptionData)> 63) SET @errorReturn = @errorReturn+(SELECT +'|2158 ' + DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode= 2158)+CONVERT(VARCHAR,@redemptionData)
	  IF(LEN(@callHomeData) > 64) SET @errorReturn = @errorReturn+(SELECT +'|2161 ' + DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode= 2161)+CONVERT(VARCHAR,@callHomeData)
	  IF(LEN(@callHomeURL) > 256) SET @errorReturn = @errorReturn+(SELECT +'|2165 ' + DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode= 2165)+CONVERT(VARCHAR,@callHomeURL)
	  IF(LEN(@metaData) > 256) SET @errorReturn = @errorReturn+(SELECT +'|2172 ' + DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode= 2172)+CONVERT(VARCHAR,@metaData)
	END
		
	/* Summary:Raise an Error Message.max 63 alphanumeric characters,If any of the data exceeds the max length.(if callHomeData passed then max length is 59 alphanumeric characters)*/ 
	
	IF(ISNULL(@callHomeData,'')<> '')
	 BEGIN
		 IF(LEN(@redemptionData) > 59)
		 BEGIN
		   SET @errorReturn = @errorReturn+(SELECT +'|2158 ' + DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode= 2158)+CONVERT(VARCHAR,@redemptionData)
		 END
	 END
	
	IF(((ISNULL(@callHomeData,'')<> '' AND ISNULL(@callHomeURL,'') ='' )) OR ((ISNULL(@callHomeData,'')= '' AND ISNULL(@callHomeURL,'') <>'' )))
	BEGIN
		/* Summary:Raise an Error Message. If callHomeURL is passed and callHomeData is not passed  */
		IF(ISNULL(@callHomeData,'')= '' AND ISNULL(@callHomeURL,'') <>'' )SET @errorReturn = @errorReturn+(SELECT +'|2160 ' + DESCRIPTION +'|' + FieldName   FROM dbo.tblErrorLog WHERE ErrorCode= 2160)
		
		/* Summary:Raise an Error Message .If callHomeData is passed and callHomeURL is not passed  */
		IF(ISNULL(@callHomeData,'')<> '' AND ISNULL(@callHomeURL,'') ='' )SET @errorReturn =@errorReturn +(SELECT +'|2164 '+ DESCRIPTION +'|' + FieldName   FROM dbo.tblErrorLog WHERE ErrorCode= 2164)
	END
	/*Summary: Here Used to UsesDefined Funtion TRIM*/
    SET @redemptionData=(SELECT dbo.TRIM(@redemptionData,'/'))

	/* Summary:Raise an Error Message.if redemptionData has more than one entry */
	IF((CHARINDEX('/', @redemptionData)> 0 AND (ISNULL(@callHomeData,'')<> '')))
	BEGIN
	   SET @errorReturn =@errorReturn +(SELECT +'|2159 '+ DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode= 2159)+CONVERT(VARCHAR,@redemptionData)
	END
	/* Summary: Raise an Error Message(400) If any errors set in errors return field */
    IF(@errorReturn like '%|%')
	BEGIN
		SET	@ReturnResult = @errorReturn SELECT @ReturnResult AS Returnvalue
		RETURN;
	END
	ELSE
	BEGIN
		INSERT INTO tbldynamiccode(UserId,RequestDate,CellPhone,CallHomeData,CallHomeURL,CallHomeTimeoutValue,RedemptionData,metaData)VALUES(@UserId,@date,@cellPhone,@callHomeData,@callHomeURL,ISNULL(NULLIF(@callHomeTimeoutValue,0),100),@redemptionData,@metaData)
		SET @intID = @@IDENTITY
		UPDATE [tblSession] SET lastActivity=SYSDATETIMEOFFSET() WHERE sessionKey=@sessionKey
		EXEC upi_UserActivity @UserId,@date,1,@intID,8,'Create'
		SET @RedemptionID = (SELECT RedemptionData FROM dbo.tbldynamiccode WHERE DynCId=@intID)
        SET @ReturnResult='200' 
        IF(ISNULL(@callHomeData,'')<> '')
        BEGIN
			SELECT @ReturnResult +'|'+ '~'+CONVERT(VARCHAR,@intID) +'/'+'*CH*'+CONVERT(VARCHAR(63),@RedemptionID) AS Returnvalue
        END
        ELSE
        BEGIN
			SELECT @ReturnResult +'|'+ '~'+CONVERT(VARCHAR,@intID) +'/'+CONVERT(VARCHAR(63),@RedemptionID) AS Returnvalue
        END
		RETURN;
    END
END
--exec [upi_DynamicCode] 'A1A2A3A4A5A6A7A8','1234567891234567891234567891234567891234','7898767888','','','300','abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz1234567890123456789','MetaDataXYZ'



GO
/****** Object:  StoredProcedure [dbo].[upi_Interceptor]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prakash G
-- Create date: 22.05.2013
-- Routine:		Interceptor
-- Method:		POST
-- Description:	Create an Interceptor record
-- =============================================
CREATE PROCEDURE [dbo].[upi_Interceptor] 
	
	@applicationKey	AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@intSerial		AS VARCHAR(12),
	@locId			AS INT,
	@orgId			AS INT
AS
BEGIN
	SET NOCOUNT ON;
	
		-- Output descriptions
	    -- 400 - Bad Request
	    -- 401 - Unauthorized
	    -- 201 - Created
	    
	    -- Local variables descriptions
		-- @ReturnResult used to return results
		-- @UserId used to store userId value	
		-- @date used to store the current date and time from the SQL Server
		-- @accessLevel used to store AccessLevel value
		-- @eventData used to store event data description
		-- @sessionOrgID used to store the session OrgID
		-- @deviceStatus used to return the Device Status
		-- @intID used to return the Interceptor ID
		-- @errorReturn used to store the error message.
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @sessionOrgID	AS INT
	DECLARE @deviceStatus	AS INT
	DECLARE @intID			AS INT
	DECLARE @errorReturn	AS NVARCHAR(MAX)
	DECLARE @tempResult		AS NVARCHAR(MAX)

	SET @errorReturn	= '400';
	SET @date			= SYSDATETIMEOFFSET();
	SET @UserId			= (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE @sessionKey = sessionKey)
	
	SET @sessionOrgID=(SELECT orgid FROM dbo.tblsession WHERE sessionKey = @sessionKey)

	/* Summary : if Session[accessLevel] = SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW  then do the following */
	IF(@accessLevel = 1 OR @accessLevel =3 OR @accessLevel =5 OR @accessLevel =7)
	BEGIN
	    /*Summary:If accessLevel is SysAdminRW or VarAdminRW and if OrgId is not passed, then Add error message to the output JSON data  and send it with the HTTP response “400 Bad Request”. */
	   /*Summary:Raise an Error Message ,IF mandatory field (locid,intserial,orgid) are not Passed*/
	    IF(@accessLevel=1 OR @accessLevel=3)
		BEGIN
	 		IF(ISNULL(@orgId,'')!='')
	 		BEGIN
	 			IF(ISNULL(@intSerial,'')= '' OR ISNULL(@locId,'')='')
				BEGIN
					IF(ISNULL(@intSerial,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1760 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1760)
					IF(ISNULL(@locId,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1759 ' + DESCRIPTION +'|' + FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1759)
				END
	 		END
	 		ELSE
			BEGIN
			    SET	@errorReturn = @errorReturn+'|1752 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1752)
			    IF(ISNULL(@intSerial,'')= '' OR ISNULL(@locId,'')='')
				BEGIN
					IF(ISNULL(@intSerial,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1760 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1760)
					IF(ISNULL(@locId,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1759 ' + DESCRIPTION +'|' + FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1759)
				END
			END
		END
		ELSE
		/*Summary: If accessLevel is OrgAdminRW or OrgUserRW and if OrgId is passed , then Add error message to the output  JSON data  and send it with the HTTP response "400 Bad Request" */
		 /*Summary:Raise an Error Message ,IF mandatory field (locid,intserial) are not Passed*/
		IF(@accessLevel = 5 OR @accessLevel=7)
			BEGIN
				IF(ISNULL(@orgId,'') ='') 
					BEGIN
					     IF(ISNULL(@intSerial,'')='' OR ISNULL(@locId,'')='')
						 BEGIN
							IF(ISNULL(@intSerial,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1760 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1760)
							IF(ISNULL(@locId,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1759 ' + DESCRIPTION +'|' + FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1759)
						  END
						  ELSE
						  BEGIN
							SET @orgId=@sessionOrgID
						  END
					 END
					ELSE
					BEGIN
						SET @errorReturn = @errorReturn+'|1753 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1753)
						IF(ISNULL(@intSerial,'')='' OR ISNULL(@locId,'')='')
					    BEGIN
							IF(ISNULL(@intSerial,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1760 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1760)
							IF(ISNULL(@locId,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1759 ' + DESCRIPTION +'|' + FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1759)
					    END
					END
				END
				
			/* Summary:Raise an Error Message,If locId is passed, matching Location record is not found */
			
			 IF(ISNULL(@locId,'') !='')
			 BEGIN
				IF(NOT EXISTS(SELECT 1 FROM dbo.[tblLocation] WITH (NOLOCK) WHERE locId = @locId))
				BEGIN
					SET @errorReturn = @errorReturn+'|1761 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1761)+'->'+CONVERT(VARCHAR,@locId)
				END
			END  
			 
			 /* Summary:Raise an Error Message,If intSerial is passed, matching InterceptorID record is not found */
			
			IF(ISNULL(@intSerial,'') !='')
				BEGIN
				IF(EXISTS(SELECT 1 FROM dbo.[tblInterceptorID] WHERE intserial=@intSerial))
				BEGIN
				    /*Summary:Raise an Error Message,If a matching Interceptor record is found*/
				    IF(EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE intserial=@intSerial))
					BEGIN
						SET @errorReturn = @errorReturn+'|1758 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1758)+'->'+CONVERT(VARCHAR,@intSerial)
					END
				END
				ELSE
				BEGIN
					SET @errorReturn = @errorReturn+'|1757 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1757)+'->'+CONVERT(VARCHAR,@intSerial)
				END
			END
			/*Summary:Raise an Error Message(400),If @errorReturn contains "|" */
		 	IF(@errorReturn LIKE '%|%')
			BEGIN
				SELECT @errorReturn AS ReturnData
				RETURN;
			END
			ELSE
	        /* Summary: If the Organization record is found,then do the following*/
		 	IF(EXISTS(SELECT 1 FROM dbo.[tblorganization] WITH (NOLOCK) WHERE orgid=@orgId))  
			BEGIN
				/* Summary:If orgId passed use it to get Organization record and If locId is passed, use it to search the Location data store. */
				/* Summary:If locId is passed, use it to search the Location data store.If a matching Location record is not found, add error message to the output  JSON data  (errors field) */
				IF(EXISTS(SELECT 1 FROM dbo.[tblLocation] WITH (NOLOCK) JOIN tblOrganization WITH (NOLOCK) ON [tblOrganization].orgID = [tblLocation].orgID WHERE tblLocation.LocId = @locId AND tblLocation.OrgId=@orgId))
					BEGIN
							/* Summary: If the Organization record is found, check if the user is authorized to make this request */
							/* Summary: If accessLevel is SysAdminRW */
							/* Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of Location[OrgId] */
							/* Summary: If accessLevel is OrgAdminRW or OrgUserRW, then check if Session[OrgId] is the same as Location[OrgId] */
					         IF((@accessLevel = 1) or ((@accessLevel = 3) AND (EXISTS (SELECT o.orgid FROM dbo.tblOrganization AS O INNER JOIN tblSession AS S ON O.Owner = S.OrgId INNER JOIN [tbllocation] AS I ON O.OrgId = I.OrgId WHERE O.OrgId =@orgId  and s.sessionkey=@sessionKey and I.locId=@locId))) OR ((@accessLevel = 5 OR @accessLevel=7) AND (EXISTS(SELECT O.orgId FROM dbo.[tblOrganization] AS O JOIN [tblSession] AS S ON O.OrgId=S.orgid INNER JOIN [tbllocation] AS I ON O.OrgId = I.OrgId WHERE  O.orgid=@orgId AND sessionKey = @sessionKey AND I.locId=@locId ))))
					          BEGIN
					              INSERT INTO tblInterceptor(IntSerial,OrgId,LocId,IntLocDesc,ForwardURL,ForwardType,MaxBatchWaitTime,DeviceStatus,startURL,ReportURL,ScanURL,BkupURL,CmdURL,Capture,CaptureMode,RequestTimeoutValue,CallHomeTimeoutMode,CallHomeTimeoutData,DynCodeFormat,[Security],errorLog,wpaPSK,ssid,cmdChkInt)
								  VALUES(@intSerial,@orgId,@locId,NULL,NULL,1,15,0,'api.cozumo.com/api/DeviceSetting','api.cozumo.com/api/DeviceStatus','api.cozumo.com/api/DeviceScan','api.cozumo.com/api/DeviceBackup','api.cozumo.com/api/ICmd',1,1,200,0,NULL,'["~*[1,12]/*[1,63]"]',0,'0',NULL,NULL,'15')
								  SET @intID = @@IDENTITY
						          UPDATE [tblSession] SET lastActivity=SYSDATETIMEOFFSET() WHERE sessionKey=@sessionKey
						          EXEC upi_UserActivity @UserId,@date,1,@intID,4,'CREATE'
						          SET @deviceStatus = (SELECT TOP 1 DeviceStatus FROM dbo.tblInterceptor WHERE intId=@intID)
                                  SET @ReturnResult='201' 
                                  SELECT @ReturnResult +'|'+CONVERT(VARCHAR,@intID) +'|'+CONVERT(VARCHAR,@deviceStatus) AS Returnvalue
                                  RETURN ;
							  END
							  /* Summary:Raise an error Message,If user is not scope with organization */
							  ELSE
							  BEGIN
							 	  SET @ReturnResult = '401|1754 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1754)+'->'+CONVERT(VARCHAR,@accessLevel)
							 	  SELECT @ReturnResult AS ReturnData
								  EXEC upi_SystemEvents 'Interceptor',1754,3,@accessLevel
								  RETURN;
							  END
					END
					ELSE
					BEGIN
						/* Summary:Raise an Error Message(400). If the Location and Organization record is not found */ 
						SET @ReturnResult = '400|1756 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1756)+'->'+CONVERT(VARCHAR,@orgId)+ ',' + CONVERT(VARCHAR,@locId)
						SELECT @ReturnResult AS ReturnData
						SET @tempResult=(CONVERT(VARCHAR,@orgId)+ ',' + CONVERT(VARCHAR,@locId))
						EXEC upi_SystemEvents 'Interceptor',1756,3,@tempResult
						RETURN;
					END
			END
			ELSE
			BEGIN
			 /* Summary:Raise an Error Message(400). If the Organization record is not found */ 
			  SET @ReturnResult = '400|1762 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1762)+'->'+CONVERT(VARCHAR,@orgId)
			  SELECT @ReturnResult AS ReturnData
			  EXEC upi_SystemEvents 'Interceptor',1762,3,@orgId
			  RETURN;
			 END
		END
		/*Summary:Raise an Error Message (401).if Session[accessLevel] != SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW */
		ELSE
		BEGIN 
			SET @ReturnResult = '401|1754 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1754)+'->'+CONVERT(VARCHAR,ISNULL(@accessLevel,'0'))
		    SELECT @ReturnResult AS ReturnData
			EXEC upi_SystemEvents 'Interceptor',1754,3,@accessLevel
		    RETURN;
		END
END
-- exec [upi_Interceptor] 'A1A2A3A4A5A6A7A8','B10B233B66957D7CA5B5B1CEE4A82B0C892DAAA4','9876540','8','2'---AccessLevel 1(SysAdminRW)
GO
/****** Object:  StoredProcedure [dbo].[upi_InterceptorID]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- Author:			Dineshkumar G	
-- Create date:		05.06.2013
-- Routine:			InterceptorID
-- Method:			POST
-- Description:		Creates one or more InterceptorID records
-- Modidfied By:	G.Prakash
-- ======================================================================================
CREATE PROCEDURE [dbo].[upi_InterceptorID] 

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@idList			AS NVARCHAR(MAX)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	
	DECLARE @ReturnResult			AS VARCHAR(MAX)
	DECLARE @date					AS DATETIMEOFFSET(7)
	DECLARE @accessLevel			AS INT
	DECLARE @UserId					AS VARCHAR(5)
	DECLARE @scanObject				AS NVARCHAR(MAX)
	DECLARE @currentCount			AS VARCHAR(10)
	DECLARE @TempInterceptorIdCount AS VARCHAR(10)
	DECLARE @errorReturn			AS VARCHAR(MAX)
	DECLARE @id						AS INT
	DECLARE @CURSORID				AS INT
	DECLARE @itemProcessed			AS INT
	DECLARE @recordsCreated			AS INT
	DECLARE @badItems				AS INT
	DECLARE @intSerial				AS VARCHAR(MAX)
	DECLARE @embeddedID				AS VARCHAR(MAX)
	DECLARE @Error					AS NVARCHAR(10)
	DECLARE @ErrorMessage			AS NVARCHAR(MAX)
	DECLARE @NameValuePairs			AS NVARCHAR(MAX) 
    DECLARE @NameValuePair			AS NVARCHAR(100)
	DECLARE @Name					AS NVARCHAR(100)
	DECLARE @Value					AS NVARCHAR(100)
	DECLARE @Count					AS INT
	DECLARE @Property TABLE ([id] INT ,[Name] NVARCHAR(100),[Value] NVARCHAR(100))
	
	CREATE TABLE #TempScan (ID INT IDENTITY(1,1) NOT NULL,contentData NVARCHAR(Max))
	CREATE TABLE #TempInterceptorID (intserial NVARCHAR(MAX),embeddedid NVARCHAR(MAX))
	
	SET @itemProcessed		= 0;
	SET @recordsCreated		= 0;
	SET @badItems			= 0;
	SET @ErrorMessage		= '';
	SET @UserId				= (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey  =  @sessionKey)
	SET @date				= SYSDATETIMEOFFSET();
	SET @accessLevel		= (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey  =  sessionKey)
	SET @errorReturn		= '400'
	
	/*Summary:If the accessLevel is not SysAdminRW, then send a HTTP response “401 Unauthorised*/
	IF(@accessLevel  =  1)
	BEGIN
		/*Summary:Check if the idList field is passed,if not passed return error:400 Bad Request*/
		IF(ISNULL(@idList,'')  =  '')
		BEGIN
			SET @errorReturn  =  @errorReturn+'|'+'2502 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode =  2502)
			SELECT @errorReturn AS ReturnData
			RETURN;
		END	
		ELSE
		BEGIN
			SET @scanObject = Replace(@idList,'},{','}#{');
		    SET @scanObject  = REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(@scanObject,'{',''),'}',''),'"',''),'[',''),']','');
		    INSERT INTO #TempScan(contentData)SELECT items from Splitrow(@scanObject,'#')
		    
		    DECLARE TEMP_cursor CURSOR FOR SELECT t.ID FROM dbo.#TempScan t WITH(NOLOCK)
			OPEN TEMP_cursor;  
			FETCH NEXT FROM TEMP_cursor INTO @CURSORID;
			WHILE @@FETCH_STATUS  =  0  
				  BEGIN
				  SET @id = 0;
						SELECT @NameValuePairs   =  D.contentData from dbo.#TempScan D WHERE D.ID  =  @CURSORID
						WHILE LEN(@NameValuePairs) > 0
						BEGIN
						    SET  @id = @id+1;
							SET @NameValuePair  =  LEFT(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs) - 1, -1),LEN(@NameValuePairs)))
						    SET @NameValuePairs  =  SUBSTRING(@NameValuePairs,ISNULL(NULLIF(CHARINDEX(',', @NameValuePairs), 0),LEN(@NameValuePairs)) + 1, LEN(@NameValuePairs))
                            SET @Name  =  LTRIM(RTRIM(SUBSTRING(@NameValuePair, 1, CHARINDEX(':', @NameValuePair) - 1)))
						    SET @Value  =  LTRIM(RTRIM(SUBSTRING(@NameValuePair, CHARINDEX(':', @NameValuePair) + 1, LEN(@NameValuePair))))
                            INSERT INTO @Property ([id], [Name], [Value] )VALUES ( @id,@Name, @Value )
						END	
						SET @itemProcessed = @itemProcessed+1;
						SET @intSerial  = ''
						SET @embeddedID = ''
						SET @Count =  (SELECT COUNT(*) FROM @Property)
						
						DECLARE @i	INT
                        SET @i = 1
                        WHILE( @i < =  @Count)
                        BEGIN
							SET @Name = (SELECT Name FROM @Property WHERE id = @i)
							SET @Value = (SELECT [Value] FROM @Property WHERE id = @i)
							SET @i = @i + 1;
							/* Summary:Raise an Error Message,If Label is not Correct*/
							IF(LOWER(@Name)  =  'intserial')
								SET @intSerial = @Value;
							ELSE IF(LOWER(@Name)  =  'embeddedid') 
								SET @embeddedID = @Value; 
							ELSE   
							BEGIN
								SET  @Error = 'Error'; 
								SET @errorReturn  =  @errorReturn+(SELECT +'|2513 ' +DESCRIPTION +'|' +  FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode =  2513) + @Name + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
							END 
                       END
                       IF(ISNULL(@Error,'')  =  '')
					   BEGIN  
							/* Summary:If intSerial,EmbeddedID is  passed and format is correct then do the following step */
							IF((ISNULL(@intSerial,'')<> '' AND ISNULL(@embeddedID,'')<>'' ) AND (len(@embeddedID) =  10 AND len(@intSerial) = 12) AND (@intSerial NOT LIKE '%[^a-zA-Z0-9]%')AND (@embeddedID NOT LIKE '%[^a-zA-Z0-9]%') )
							BEGIN
							      /* Summary:If intSerial,EmbeddedID is passed but does not matching InterceptorID,TempInterceptorID then do the following step */
								IF (NOT EXISTS(SELECT IntSerial FROM dbo.tblInterceptorID ii WHERE IntSerial = @intSerial) AND NOT EXISTS(SELECT embeddedID FROM dbo.tblInterceptorID ii WHERE embeddedID = @embeddedID) AND NOT EXISTS(SELECT intserial FROM #TempInterceptorID  WHERE intserial = @intSerial) AND NOT EXISTS(SELECT embeddedID FROM #TempInterceptorID  WHERE embeddedID = @embeddedID) )
								BEGIN 
									SET @recordsCreated = @recordsCreated + 1
									INSERT INTO #TempInterceptorID VALUES(@intSerial,@embeddedID)
								END
								ELSE
								BEGIN
								IF EXISTS(SELECT 1 FROM #TempInterceptorID  WHERE intserial = @intSerial)
									 SET @errorReturn  =  @errorReturn+'|'+'2515 '+(SELECT DESCRIPTION +'|' + FieldName  +'->' FROM dbo.tblErrorLog WHERE ErrorCode =  2515) + @intSerial + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
									 IF EXISTS(SELECT 1 FROM #TempInterceptorID  WHERE embeddedID = @embeddedID)
									 SET @errorReturn  =  @errorReturn+'|'+'2516 '+(SELECT DESCRIPTION +'|' + FieldName  +'->' FROM dbo.tblErrorLog WHERE ErrorCode =  2516) + @embeddedID + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID) 
								END
							END
							/* Summary:Raise an Error Message,If intSerial is not passed */
							IF(ISNULL(@intSerial,'') <> '')
							BEGIN
								/* Summary:Raise an Error Message,If intSerial is passed,Length is Execeed */
								IF(len(@intSerial) = 12) 
								BEGIN
									/* Summary:Raise an Error Message,If intSerial is passed,format is wrong */
									IF(@intSerial NOT LIKE '%[^a-zA-Z0-9]%')
									BEGIN
										/* Summary:Raise an Error Message,If intSerial is passed, matching InterceptorID record is not found */
										IF(EXISTS(SELECT IntSerial FROM dbo.tblInterceptorID ii WHERE IntSerial = @intSerial) )
										SET @errorReturn  =  @errorReturn+'|'+'2510 '+(SELECT DESCRIPTION +'|' + FieldName  +'->' FROM dbo.tblErrorLog WHERE ErrorCode =  2510) + @intSerial + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
									END
									ELSE
									BEGIN
										SET @errorReturn  =  @errorReturn+'|'+'2511 '+(SELECT DESCRIPTION +'|' + FieldName  +'->' FROM dbo.tblErrorLog WHERE ErrorCode =  2511) + @intSerial + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
									END	
								END
								ELSE
								BEGIN
									SET @errorReturn  =  @errorReturn+'|'+'2501 '+(SELECT DESCRIPTION +'|' + FieldName  +'->' FROM dbo.tblErrorLog WHERE ErrorCode =  2501)+ @intSerial + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
								END
							END
							ELSE
							BEGIN
								SET @errorReturn  =  @errorReturn+'|'+'2508 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode =  2508)+ ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
							END
				  
							/* Summary:Raise an Error Message,If embeddedID is not passed */
							IF(ISNULL(@embeddedID,'') <> '' )
							BEGIN
								/* Summary:Raise an Error Message,If embeddedID is passed, Length is Execeed */
								IF(len(@embeddedID) =  10)
								BEGIN
									/* Summary:Raise an Error Message,If embeddedID is passed,format is wrong */
									IF(@embeddedID NOT LIKE '%[^a-zA-Z0-9]%')
									BEGIN
										/* Summary:Raise an Error Message,If embeddedID is passed, matching InterceptorID record is not found */
										IF(EXISTS(SELECT embeddedID FROM dbo.tblInterceptorID ii WHERE embeddedID = @embeddedID) )
										SET @errorReturn  =  @errorReturn+'|'+'2514 '+(SELECT DESCRIPTION +'|' + FieldName  +'->' FROM dbo.tblErrorLog WHERE ErrorCode =  2514) + @embeddedID + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
									END
									ELSE
									BEGIN			
										SET @errorReturn  =  @errorReturn+'|'+'2512 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode =  2512)+ @embeddedID + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
								    END	
								END
								ELSE
								BEGIN
									SET @errorReturn  =  @errorReturn+'|'+'2504 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode =  2504)+ @embeddedID + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
								END
						 END		
						 ELSE
						 BEGIN
							SET @errorReturn  =  @errorReturn+'|'+'2509 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode =  2509) + ',DataSet No->'+CONVERT(VARCHAR,@CURSORID)
						 END
					END 
				    SET  @Error = ''
				    SET @intSerial = ''
				    SET @embeddedID = ''              
				    DELETE FROM @Property
                    SET @i = @i+1;
				  FETCH NEXT FROM TEMP_cursor INTO @CURSORID;
		    	  END
			CLOSE TEMP_cursor;
			DEALLOCATE TEMP_cursor;
			
			IF(@errorReturn LIKE '%|%')
			BEGIN
				SELECT @errorReturn AS ReturnData
				RETURN;
			END
			ELSE
			BEGIN
				IF(@recordsCreated  = @itemProcessed)
				BEGIN
					INSERT INTO tblInterceptorID SELECT * from #TempInterceptorID
					SET @currentCount = (SELECT @@ROWCOUNT)
					UPDATE [tblSession] SET lastActivity  =  @date WHERE sessionKey  =  @sessionKey
					EXEC upi_UserActivity @UserId,@date,1,@idList,5,'Create'
					SELECT '201'+'|'+@currentCount
				END	
			END
		END
	END
	ELSE
	BEGIN
		 SET @ReturnResult  =  '401' SELECT @ReturnResult AS Returnvalue
		 EXEC upi_SystemEvents 'InterceptorID',2505,3,@accessLevel
		 RETURN;
	END
END
--EXEC upi_InterceptorID '4A79DB236006635250C7470729F1BFA30DE691D7','9C728316E4C1D5F561AA44A09510B21D5ABD1285','[{"Code":"code11","Category":"testcategory","Model":"modeltest","Manufacturer":"manufact","PartNumber":"partno","ProductLine":"prodcutlinetest","ManufacturerSKU":"manufact","Description":"description","UnitMeasure":"34","UnitPrice":"200","Misc1":"hi","Misc2":"well"},{"Code":"code22","Category":"testcategory","Model":"modeltest","Manufacturer":"manufact","PartNumber":"partno","ProductLine":"prodcutlinetest","ManufacturerSKU":"manufact","Description":"description","UnitMeasure":"34","UnitPrice":"200","Misc1":"hi","Misc2":"well"},{"Code":"code33","Category":"testcategory","Model":"modeltest","Manufacturer":"manufact","PartNumber":"partno","ProductLine":"prodcutlinetest","ManufacturerSKU":"manufact","Description":"description","UnitMeasure":"34","UnitPrice":"200","Misc1":"hi","Misc2":"well"}]'



GO
/****** Object:  StoredProcedure [dbo].[upi_InterceptorRebootAndUpdate]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author:				iHorse and iHorse 
-- Create date:			18.06.2013
-- Routine:				InterceptorReboot and InterceptorUpdate 
-- Method:				POST
-- Modified By:         iHorse
-- Reboot DESCRIPTION:	Sends a command to the Interceptor causing it to cycle it’s power 
--						(device powers down and back up). Note: this causes the Interceptor to go
--						through its normal start up procedure (Interceptor makes an HTTP call to
--						startURL, gets content for its configurable settings fields, then sends a
--						status report to reportURL)
-- Update DESCRIPTION:	sends a command to the Interceptor causing it to make an HTTP request
--						to startURL to get the content for its configurable settings fields 
--						(the Interceptor firmware updates its configurable settings fields using 
--						data returned by the HTTP request).
-- =============================================================================================================
--exec upi_InterceptorRebootAndUpdate '4A79DB236006635250C7470729F1BFA30DE691D7','4DAFDF6DCA47106424A8A253F7453CB31AC13652','987654321111','',1
--exec upi_InterceptorRebootAndUpdate 'DEV-ABC111',''
CREATE PROCEDURE [dbo].[upi_InterceptorRebootAndUpdate] 
     
     @applicationKey	VARCHAR(40),
	 @sessionKey		VARCHAR(40),
	 @intSerial			VARCHAR(12),
	 @intId				INT,
	 @method			INT
	 
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	
	DECLARE @ReturnResult		AS VARCHAR(MAX)
	DECLARE @UserId				AS VARCHAR(5)
	DECLARE @date				AS DATETIMEOFFSET(7)
	DECLARE @accessLevel		AS INT
	DECLARE @errorReturn		AS VARCHAR(1000)
	DECLARE @unauthorizedError	AS VARCHAR(1000)
	
	SET @date				= SYSDATETIMEOFFSET();
	SET @UserId				= (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	SET @accessLevel		= (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	SET @errorReturn		= '400'
	SET @unauthorizedError	= '401'

	/* Summary: Raise an error message if an access level field is SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW in the Session data store */
	IF(@accessLevel <> 1 AND @accessLevel <> 3 AND @accessLevel <> 5 AND @accessLevel <> 7)
	BEGIN
		IF(@method=1)
		BEGIN
			SET	@unauthorizedError = @unauthorizedError+'|'+'1902 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1902)
			SELECT @unauthorizedError AS 'ReturmValue'
			EXEC upi_SystemEvents 'InterceptorReboot',1902,3,@accessLevel	
			RETURN; 
		END
		ELSE IF(@method=2)
		BEGIN
			SET	@unauthorizedError = @unauthorizedError+'|'+'2002 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2002)
			SELECT @unauthorizedError AS 'ReturmValue'
			--EXEC upi_SystemEventsData 'InterceptorUpdate',2002,3
			EXEC upi_SystemEvents 'InterceptorUpdate',2002,3,@accessLevel	
			RETURN; 
		END
		
	END
	ELSE
	/* Summary: Raise an error message if both intId and intSerial are not passed */
	IF(ISNULL(@intId,0) = '' AND ISNULL(@intSerial,'') = '')
	BEGIN
		IF(@method=1)
		BEGIN
			SET	@errorReturn = @errorReturn+'|'+'1904 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1904)	
		END
		ELSE
		BEGIN
			SET	@errorReturn = @errorReturn+'|'+'2006 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2006)	
		END
		SELECT @errorReturn AS 'ReturmValue'
		RETURN; 
	END
	ELSE
	/* Summary: Raise an error message if both intId and intSerial are passed */
	IF(ISNULL(@intId,0) != 0 AND ISNULL(@intSerial,'') != '')
	BEGIN
		IF(@method=1)
		BEGIN
			SET	@errorReturn = @errorReturn+'|'+'1903 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1903)
		END
		ELSE
		BEGIN
			SET	@errorReturn = @errorReturn+'|'+'2003 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2003)
		END
		SELECT @errorReturn AS 'ReturmValue'
		RETURN; 
	END
	ELSE
	IF(ISNULL(@intId,0) != 0 OR ISNULL(@intSerial,'') != '')
	BEGIN
	/*Summay: Use the intId or intSerial passed to search for the Interceptor record. */
		IF EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE (IntId=@intId OR IntSerial = @intSerial))
		BEGIN
		/*Summary: Search for the Organization record using orgId */
			IF EXISTS (SELECT 1 FROM dbo.tblOrganization O JOIN tblInterceptor I ON O.OrgId=I.OrgId WHERE (I.IntId=@intId OR I.IntSerial = @intSerial) AND O.OrgId=I.OrgId)
			BEGIN
				/*Summary: Check if access level is SysAdminRW / 
					If access level is VarAdminRW and if Organization[owner] matches Session[orgId] / 
					If access level is OrgAdminRW or OrgUserRW and if Session[orgId] is the same as the orgId.*/				
				
				IF((@accessLevel=1) OR
				((@accessLevel=3) AND EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.Owner=S.OrgId JOIN tblInterceptor I ON I.orgId = O.orgId WHERE S.SessionKey=@sessionKey AND O.Owner=S.OrgId AND (I.IntId = @intId OR I.intserial = @intSerial))) OR
				((@accessLevel=5 OR @accessLevel=7) AND EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.OrgId=S.OrgId JOIN tblInterceptor I ON I.orgId = O.orgId WHERE S.SessionKey=@sessionKey AND O.OrgId=S.OrgId AND (I.IntId = @intId OR I.intserial = @intSerial))))
				BEGIN
				/*Summary: Issue an HTTP GET command to the Interceptor using IP address and port number from DeviceStatus[publicIP] and DeviceStatus[port] 
					with the following URL parameters:“reboot=1” “a=<authentication string>”, WHERE <authentication string> is a 32 character 
					MD5 hexdigest of InterceptorID[embeddedID] */
					
					IF(ISNULL(@intSerial,'')='') SELECT @intSerial = (SELECT IntSerial FROM dbo.tblInterceptor WHERE tblInterceptor.IntId = @intId)
					
					IF EXISTS(SELECT 1 FROM dbo.tblCmdQueue WHERE IntSerial=@intSerial)
					BEGIN
						DELETE FROM dbo.tblCmdQueue WHERE IntSerial=@intSerial
					END
					INSERT INTO tblCmdQueue (IntSerial, Cmd, CmdTime) VALUES (@intSerial, @method, SYSDATETIMEOFFSET())
					SET @ReturnResult = '200' SELECT @ReturnResult AS ReturnData
					EXEC upi_UserActivity @UserId,@date,1,@intSerial,0,'Create'
					UPDATE [tblSession] SET lastActivity=@date WHERE sessionKey=@sessionKey
				END
				ELSE
				BEGIN
					IF(@method=1)
					BEGIN
						SET	@unauthorizedError = @unauthorizedError+'|'+'1906 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1906)
						EXEC upi_SystemEvents 'InterceptorReboot',1906,3,@accessLevel	
						SELECT @unauthorizedError AS 'Returnvalue'
						RETURN; 
					END
					ELSE IF(@method=2)
					BEGIN
						SET	@unauthorizedError = @unauthorizedError+'|'+'2007 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 2007)
						EXEC upi_SystemEvents 'InterceptorUpdate',2007,3,@accessLevel		
						SELECT @unauthorizedError AS 'Returnvalue'
						RETURN; 
					END
				END
			END
			ELSE
			BEGIN
				SET @ReturnResult = '400' SELECT @ReturnResult AS ReturnData
			END
		END
		ELSE
		BEGIN
			IF (NOT EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntId=@intId) AND @intId <> 0)
					SET	@errorReturn = @errorReturn+'|'+'1905 '+(SELECT DESCRIPTION +' |' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1905)+convert(varchar,@intId)	
			ELSE IF (NOT EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial=@intSerial)AND @intSerial <> '')
					SET	@errorReturn = @errorReturn+'|'+'1907 '+(SELECT DESCRIPTION +' |' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1907)+convert(varchar,@intSerial)
			SELECT @errorReturn AS 'ReturnValue'
			RETURN;
		END
	END
	
END


GO
/****** Object:  StoredProcedure [dbo].[upi_Location]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dinesh
-- Create date: 18.5.2013
-- Routine:		Location
-- Method:		POST
-- DESCRIPTION:	Creates a new Location record
-- =============================================
CREATE PROCEDURE [dbo].[upi_Location]

	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@unitSuite			AS VARCHAR(15),
	@street				AS NVARCHAR(200),
	@city				AS NVARCHAR(50),
	@state				AS VARCHAR(50),
	@country			AS VARCHAR(50),
	@postalCode			AS VARCHAR(10),
	@orgId				AS INT,
	@locType			AS VARCHAR(50),
	@locSubType			AS VARCHAR(50),
	@locDesc			AS VARCHAR(50),
	@latitude			AS NUMERIC(9,6),
	@Longitude			AS NUMERIC(9,6)
AS
BEGIN
	SET NOCOUNT ON;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	 
	 -- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	-- 201 - Created
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @errorReturn used to set Error returns
	-- @sessionAccessLevel used to store AccessLevel value
	-- @md5Password used to get MD5 Password 
	-- @sessionorgId used to get orgId from Organization
	-- @date used to store the current date and time from the SQL Server
	
	 DECLARE @sessionAccessLevel	AS INT
	 DECLARE @md5Password			AS VARCHAR(32)
	 DECLARE @sessionorgId			AS NVARCHAR(100)
	 DECLARE @date					AS DATETIMEOFFSET(7)
	 DECLARE @returnResult			AS VARCHAR(MAX)
	 DECLARE @UserId				AS VARCHAR(5)
	 DECLARE @errorReturn			AS VARCHAR(MAX)
	 DECLARE @recorded				AS VARCHAR(1000)
	
	 SET @errorReturn = '400'
	 SET @sessionAccessLevel = (SELECT accessLevel FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)
	 IF (@latitude=0)	SET @latitude = NULL
	 IF (@Longitude=0)	SET @Longitude = NULL
	
	 /* Summary: if Session[accessLevel] != SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW then return HTTP code “401 Unauthorized */
	 IF(@sessionAccessLevel<>1 AND @sessionAccessLevel<>3 AND @sessionAccessLevel<>5 AND @sessionAccessLevel<>7)
		BEGIN
			SET	@ReturnResult = '401'
			SELECT @ReturnResult AS Returnvalue1
			EXEC upi_SystemEvents 'Location',1579,3,@sessionAccessLevel
			RETURN;
		 END
		 
	 /* Summary: check if the Mandatory fields are supplied or not */
	IF(ISNULL(@street,'')= '' OR ISNULL(@city,'')= '' OR ISNULL(@state,'')= '' OR ISNULL(@country,'')= '' OR ISNULL(@postalCode,'')= '')
	BEGIN
		--IF(ISNULL(@UnitSuite,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1558 ' +DESCRIPTION +'|' +  FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1558)
		IF(ISNULL(@street,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1560 ' + DESCRIPTION +'|' + FieldName  FROM dbo.tblErrorLog WHERE ErrorCode= 1560)
		IF(ISNULL(@city,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1562 ' +DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1562)
		IF(ISNULL(@state,'')= '') SET @errorReturn = @errorReturn +(SELECT +'|1564 ' +DESCRIPTION +'|' + FieldName   FROM dbo.tblErrorLog WHERE ErrorCode= 1564)
		IF(ISNULL(@country,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1566 ' +DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1566)
		IF(ISNULL(@postalCode,'')= '') SET @errorReturn = @errorReturn+(SELECT +'|1568 ' +DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1568)
	END
	
	/* Summary: accessLevel is SysAdminRW or VarAdminRW is orgId passed, If no Return Error:400 Bad Request */
	IF(@sessionAccessLevel=1 OR @sessionAccessLevel=3)
	BEGIN
		IF(@orgId=0 OR @orgId IS NULL)
		BEGIN
			SET @errorReturn = @errorReturn +(SELECT +'|1557 ' +DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1557)
		END
	END
	ELSE
	BEGIN
		IF(@orgId=0 OR @orgId IS NULL)
		BEGIN
			SET	@orgId =(SELECT orgID FROM dbo.[tblSession] WHERE sessionKey=@sessionKey)
		END 
		ELSE
		BEGIN
			SET @errorReturn = @errorReturn +'|1573 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1573)+CONVERT(VARCHAR,@orgId)
		END
	END
	IF(@orgId<>0 AND @orgId IS NOT NULL) AND
	NOT EXISTS(SELECT orgID FROM dbo.tblOrganization WHERE orgID=@orgId)
	BEGIN
		SET @errorReturn = @errorReturn +'|1572 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode= 1572)+CONVERT(VARCHAR,@orgId)
	END
	IF(@errorReturn like '%|%')
	BEGIN
		SET	@ReturnResult = @errorReturn SELECT @ReturnResult AS Returnvalue
		RETURN;
	END
	ELSE
	BEGIN
		SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),LocId) FROM dbo.tblLocation WHERE OrgId=@orgId and UnitSuite=@unitSuite and
		Street=@street and City=@city and State=@state and Country = @country and PostalCode = @postalCode and LocType=@locType and LocSubType = @locSubType
		and LocDesc = @locDesc and Latitude = @latitude and Longitude=@Longitude
		
		INSERT INTO tblLocation(OrgId, UnitSuite, Street, City, [State],Country,PostalCode,LocType,LocSubType,LocDesc, Latitude, Longitude) 
		VALUES(@orgId, @UnitSuite, @street, @city, @state, @country, @postalCode, @locType, @locSubType, @locDesc, @latitude, @Longitude)
		
		SET @ReturnResult =(SELECT @@identity)
		SET @UserId=(SELECT userId FROM dbo.[tblSession] WHERE  sessionKey=@sessionKey)	
		UPDATE [tblSession] SET lastActivity=SYSDATETIMEOFFSET() WHERE sessionKey=@sessionKey
		EXEC upi_UserActivity @UserId,@date,1,@recorded,2,'Create'
		SELECT '201' +'|'+ @ReturnResult AS Returnvalue
	END
END
--[upi_Location] '4A79DB236006635250C7470729F1BFA30DE691D7','1234567891234567891234567891234567891234','','','','','','',0,'','','',0,0

GO
/****** Object:  StoredProcedure [dbo].[upi_Organization]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		iHorse
-- Create date: <Create Date,,>
-- Routine:		Organization
-- Method:		POST
-- DESCRIPTION:	Insert Organization Records
-- =============================================
CREATE PROCEDURE [dbo].[upi_Organization]

	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgName			AS NVARCHAR(100),
	@ipAddress			AS VARCHAR(15),
	@applicationKeyOrg	AS VARCHAR(40)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @errorReturn used to set Error returns
	-- @accessLevel used to store AccessLevel value
	-- @md5ApplicationKey used to get Md5 hexdigest Applicationkey
	-- @owner used to get orgId from Organization
	-- @UserId used to get userid from user
	-- @date used to store the current date and time from the SQL Server
	
	SET NOCOUNT ON;
	DECLARE @returnResult		AS VARCHAR(MAX)
	DECLARE @accessLevel		AS INT
	DECLARE @md5ApplicationKey	AS VARCHAR(40)
	DECLARE @owner				AS NVARCHAR(100)
	DECLARE @UserId				AS Varchar(5)
	DECLARE @date				As DATETIMEOFFSET(7)
	DECLARE @errorReturn		AS VARCHAR(1000)
	 
	SET @accessLevel = (SELECT accessLevel FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)
	SET @errorReturn='400'
	 
	/* if Session[accessLevel] != SysAdminRW or VarAdminRW then return HTTP code “401 Unauthorized */
	IF(@accesslevel <>1 AND @accesslevel <>3)
	BEGIN
		SET	@ReturnResult = '401' SELECT @ReturnResult AS Returnvalue
		EXEC upi_SystemEvents 'Interceptor',1357,3,@accessLevel
		RETURN;
	END
		
	 /* check Mandatory fields are supplied */
	IF(@orgName = '' OR @orgName IS NULL)
	BEGIN
		SET	@errorReturn = @errorReturn+'|1352 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1352)
	END
	
	IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE OrgName=@orgName)
	BEGIN
		SET	@errorReturn = @errorReturn+'|1358 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1358)
		SELECT @errorReturn AS ReturnData
		RETURN;
	END
		
	/* applicationKeyOrg or ipAddress passed and Session[accessLevel] != SysAdminRW Return Error*/
	 IF((@applicationKeyOrg IS NOT NULL and @applicationKeyOrg <>'') or (@ipAddress IS NOT NULL and @ipAddress<>''))
	BEGIN
		IF(@accessLevel = 3)
			BEGIN
				SET	@errorReturn = @errorReturn+'|1356 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1356)
			END
	END
		
	/*If no errors found create Organization Record */
	IF(@applicationKeyOrg = '' OR @applicationKeyOrg IS NULL)
	BEGIN
		SET @md5ApplicationKey = (SELECT IDENT_CURRENT('tblOrganization'))
		SET @md5ApplicationKey = @md5ApplicationKey+1;
		SET @md5ApplicationKey = (SELECT CONVERT(VARCHAR(40),HashBytes('SHA1', @md5ApplicationKey),2))
	END
	ELSE
	BEGIN
		SET @md5ApplicationKey=(SELECT CONVERT(VARCHAR(40),HashBytes('SHA1', @applicationKeyOrg),2))
	END
	
	IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE ApplicationKey=@md5ApplicationKey)
	BEGIN
		SET	@errorReturn = @errorReturn+'|1359 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode= 1359)
		SELECT @errorReturn AS ReturnData
		RETURN;
	END	
		
	IF(@errorReturn LIKE '%|%')
	BEGIN
		SELECT @errorReturn AS ReturnData
		RETURN;
	END
	
	SET @owner		= (SELECT orgID FROM dbo.[tblSession] WHERE sessionKey=@sessionKey)
	SET @ipAddress	= (SELECT CASE WHEN @ipAddress IS NULL THEN '' ELSE @ipAddress END)
	SET @date		= SYSDATETIMEOFFSET()
	SET @UserId		= (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey=@sessionKey)
	
	INSERT INTO tblOrganization(orgName, applicationKey, ipAddress, [owner]) VALUES(@orgName, @md5ApplicationKey, @ipAddress, @owner)
	
	SET @ReturnResult = (SELECT @@identity)
	UPDATE [tblSession] SET lastActivity=SYSDATETIMEOFFSET() WHERE sessionKey=@sessionKey
	EXEC upi_UserActivity @UserId,@date,1,@ReturnResult,1,'Create'
	SELECT '201'+'|'+@ReturnResult AS Returnvalue
END
--[upi_Organization] '4A79DB236006635250C7470729F1BFA30DE691D1','CA27F054988196425E7A8C6ED596A50A6BF36BC0','IHorseTechnology','123.123.123.123','23232323233333333333333333333333'
--[upi_Organization] '4A79DB236006635250C7470729F1BFA30DE691D7','DC77C9775F79B1A4B0F3A27B75753998','isol','192.168.1.1','ABCD1234'


GO
/****** Object:  StoredProcedure [dbo].[upi_SystemEvents]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		 iHorse
-- Create date:  23.04.2013
-- Routine:		 Common Stored Procedure for all routines
-- Method:		 POST
-- Description:  Create new system events record
-- ==================================================================
CREATE PROCEDURE [dbo].[upi_SystemEvents] 
	
	@routine	AS VARCHAR(50),
	@eventType	AS INT,
	@eventLevel AS INT,
	@eventData	AS VARCHAR(MAX)

AS
BEGIN
	INSERT INTO dbo.tblSystemEvents(routine,eventType,eventLevel,[eventData],[CreatedOn])
	VALUES (@routine,@eventType,@eventLevel,@eventData,SYSDATETIMEOFFSET())
END
--EXEC upi_SystemEvents 'Post',3,'1','dsaf'


GO
/****** Object:  StoredProcedure [dbo].[upi_SystemEventsData]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:		 iHorse
-- Create date:  23.04.2013
-- Routine:		 Common Stored Procedure for all routines
-- Method:		 POST
-- Description:  Create new system events record
-- ==================================================================
CREATE PROCEDURE [dbo].[upi_SystemEventsData] 
	
	@routine	AS VARCHAR(50),
	@ErrorCode	AS INT,
	@eventLevel AS INT

AS
BEGIN

	DECLARE @inteventType  AS INT
	DECLARE @txteventData  AS VARCHAR(MAX)
	
	SET @inteventType = (SELECT ErrorCode FROM dbo.tblErrorLog WHERE ErrorCode = @ErrorCode)
	SET @txteventData = (SELECT Description FROM dbo.tblErrorLog WHERE ErrorCode = @ErrorCode)
	
	--INSERT INTO tblSystemEvents(routine,eventType,eventLevel,[eventData])
	--VALUES (@routine,@eventType,@eventLevel,@eventData)
	INSERT INTO tblSystemEvents(routine,eventType,eventLevel,[eventData])
	VALUES (@routine,@inteventType,@eventLevel,@txteventData)
	
	
END
--EXEC upi_SystemEvents 'Post',3,'1','dsaf'


GO
/****** Object:  StoredProcedure [dbo].[upi_User]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================== 
-- Author:		Dinesh
-- Create date: 3.5.2013
-- Routine:		User
-- Method:		POST
-- Description:	creates a User record
-- ==================================================================== 
CREATE PROCEDURE [dbo].[upi_User]

	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@password			AS VARCHAR(40),
	@firstName			AS NVARCHAR(50),
	@lastName			AS NVARCHAR(50),
	@accessLevel		AS INT,
	@orgId				AS INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	 
	 -- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @errorReturn used to set Error returns
	-- @sessionAccessLevel used to store AccessLevel value
	-- @md5Password used to get MD5 Password 
	-- @sessionorgId used to get orgId from Organization
	-- @date used to store the current date and time from the SQL Server
	
	SET NOCOUNT ON;
	DECLARE @sessionAccessLevel		AS INT
	DECLARE @md5Password			AS VARCHAR(40)
	DECLARE @sessionorgId			AS NVARCHAR(100)
	DECLARE @date					As DATETIMEOFFSET(7)
	DECLARE @returnResult			AS VARCHAR(10)
	DECLARE @errorReturn			AS VARCHAR(1000)
	DECLARE @chars					AS NCHAR(26)
	DECLARE @num					AS NCHAR(10)
	 
	SET @num		 = N'0123456789'
	SET @chars		 = N'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	SET @errorReturn = '400'

	DECLARE @userId Varchar(5)
	START:		
		SET @userId = SUBSTRING(@num, CAST((RAND() * LEN(@num)) AS INT) + 1, 1)
            + SUBSTRING(@num, CAST((RAND() * LEN(@num)) AS INT) + 1, 1)
            + SUBSTRING(@num, CAST((RAND() * LEN(@num)) AS INT) + 1, 1)
            + SUBSTRING(@chars, CAST((RAND() * LEN(@chars)) AS INT) + 1, 1)
            + SUBSTRING(@chars, CAST((RAND() * LEN(@chars)) AS INT) + 1, 1)
	IF EXISTS (SELECT 1 FROM dbo.tblUser WHERE UserId <> @userId)		-- WHILE User:UserId <> @userId

	SET @sessionAccessLevel = (SELECT accessLevel FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)
	
	/* Summary:Session[accessLevel] != SysAdminRW or VarAdminRW or OrgAdminRW then return “401 Unauthorized” */
	IF(@sessionAccessLevel<>1 AND @sessionAccessLevel<>3 AND @sessionAccessLevel<>5)
	BEGIN
		SET @returnResult = '401'  SELECT @returnResult AS Returnvalue
		RETURN;
	END
	
	/*Summary:If accessLevel is VarAdminRW/RO or SysAdminRW , then check if the following fields are passed. If not, add missing fields
	errors Return field */
	IF(@sessionAccessLevel = 1 OR @sessionAccessLevel = 3)
	BEGIN
				IF(@sessionKey IS NULL OR @sessionKey = '' OR @password = '' OR @password IS NULL OR @firstName = '' OR @firstName IS NULL
				OR @lastName = '' OR @lastName IS NULL OR @accessLevel = '' OR @accessLevel = 0 OR @accessLevel IS NULL OR @orgId = 0 OR @orgId IS NULL)
				BEGIN
					IF(ISNULL(@password,'') = '')
					BEGIN
						SET	@errorReturn = @errorReturn+'|1158 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1158)
					END
					IF(ISNULL(@firstName,'') = '')
					BEGIN
						SET	@errorReturn = @errorReturn+'|1161 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1161)
					END
					IF(ISNULL(@lastName,'') = '')
					BEGIN
						SET	@errorReturn = @errorReturn+'|1164 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1164)
					END
					IF(@accessLevel IS NULL OR @accessLevel = 0)
					BEGIN
						SET	@errorReturn = @errorReturn+'|1171 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1171)
					END
					IF(@orgId IS NULL OR @orgId = 0)
					BEGIN
						SET	@errorReturn = @errorReturn+'|1172 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1172)
					END
					SELECT @errorReturn AS Returnvalue1	
					EXEC upi_SystemEvents 'User',1173,3,''
					RETURN;
				END
	END
		 /*Summary: If accessLevel is OrgAdminRW, then check if the following fields are passed. If not, add missing fields to error return field*/
	ELSE
	BEGIN
			IF(@sessionKey IS NULL OR @sessionKey = '' OR @password = '' OR @password IS NULL OR @firstName = '' OR @firstName IS NULL
			   OR @lastName = '' OR @lastName IS NULL OR @accessLevel = '' OR @accessLevel IS NULL OR (@orgId IS NOT NULL AND @orgId>0))
				BEGIN
					IF(ISNULL(@password,'') = '')
					BEGIN
						SET	@errorReturn = @errorReturn+'|1158 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1158)
					END
					IF(ISNULL(@firstName,'') = '')
					BEGIN
						SET	@errorReturn = @errorReturn+'|1161 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1161)
					END
					IF(ISNULL(@lastName,'') = '')
					BEGIN
						SET	@errorReturn = @errorReturn+'|1164 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1164)
					END
					IF(ISNULL(@accessLevel,'') = '')
					BEGIN
						SET	@errorReturn = @errorReturn+'|1171 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1171)
					END
					
					IF(@orgId IS NOT NULL AND @orgId>0)
					BEGIN
						SET	@errorReturn = @errorReturn+'|1167 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1167)
					END
					SELECT @errorReturn AS Returnvalue2		
					EXEC upi_SystemEvents 'User',1174,3,''
					RETURN; 
				END
	END
	 
	/* Summary:Session[accessLevel] = SysAdminRW then all access levels are accepted */
	IF(@sessionAccessLevel = 1)
	BEGIN
		IF(@accessLevel<>1 AND @accessLevel<>2 AND @accessLevel<>3 AND @accessLevel<>4 AND @accessLevel<>5 AND @accessLevel<>6 AND @accessLevel<>7 AND @accessLevel<>8)
		BEGIN
			SET	@errorReturn = @errorReturn+'|1175 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1175)+'->'+CONVERT(VARCHAR,@accessLevel)		
		END
	END
	/* Summary:Session[accessLevel] = VarAdminRW then VarAdminRW or VarAdminRO or OrgAdminRW or OrgAdminRO are accepted */
	ELSE IF(@sessionAccessLevel = 3)
	BEGIN
		IF(@accessLevel<>3 AND @accessLevel<>4 AND @accessLevel<>5 AND @accessLevel<>6)
		BEGIN
			SET	@errorReturn = @errorReturn+'|1175 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1175)+'->'+CONVERT(VARCHAR,@accessLevel)		
		END
	END
	/* Summary:Session[accessLevel] = OrgAdminRW then OrgAdminRW or OrgAdminRO or OrgUserRW or OrgUserRO are accepted */
	ELSE IF(@sessionAccessLevel = 5)
	BEGIN
		IF(@accessLevel<>5 AND @accessLevel<>6 AND @accessLevel<>7 AND @accessLevel<>8)
		BEGIN
			SET	@errorReturn = @errorReturn+'|1175 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1175)+'->'+CONVERT(VARCHAR,@accessLevel)		
		END
	END
	
	/*Summary:If any errors return JSON data with HTTP code “400 Bad Request”*/
	IF(@errorReturn LIKE '%|%')
	BEGIN
		SELECT @errorReturn AS ReturnData
	END
	/*Create User record using data from passed fields*/
	ELSE
		BEGIN
			SET @md5Password = (SELECT CONVERT(VARCHAR(40),HashBytes('SHA1', @password),2))
			
			SET @sessionorgId = (SELECT orgID FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)
			SET @orgId = (SELECT CASE WHEN @orgId IS NULL OR @orgId = 0 THEN @sessionorgId ELSE @orgId END)
			SET @date = SYSDATETIMEOFFSET()
	        BEGIN TRY
				INSERT INTO [tblUser](userId, orgID, [password], firstName, lastName, regDate, accessLevel) VALUES(@userId, @orgId, @md5Password, @firstName, @lastName, SYSDATETIMEOFFSET(), @accessLevel)
			END TRY
			BEGIN CATCH
				SET	@errorReturn = @errorReturn+'|1168 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1168)+'->'+CONVERT(VARCHAR,@orgId)
				SELECT @errorReturn	
			END CATCH
			
			UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @UserId,@date,1,@UserId,3,'Create'
			SELECT '201'+'|'+@userId AS Returnvalue
			
		END
END
--[upi_User] '000D12B8772F1CB72364C216BC2E01E7075FD098','204E7AEFB58FD917F62D216B27D0AF67FA8CA41C','labc','dinesh','kumar',5,0
--[upi_User] '4A79DB236006635250C7470729F1BFA30DE691D7','123456789','abcd','dinesh','kumar',0,1


GO
/****** Object:  StoredProcedure [dbo].[upi_UserActivity]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:			iHorse
-- Create date:		15.04.2013
-- Routine:			Common Stored Procedure for all routines
-- Method:			POST
-- Description:		Create New User Activty Record
-- =================================================================
CREATE PROCEDURE [dbo].[upi_UserActivity]

	@userId			AS VARCHAR(5),
	@actDate		AS DATETIMEOFFSET(7),
	@activity		AS INT,
	@recorded		AS VARCHAR(50),
	@recordType		AS INT,
	@activityData	AS TEXT

AS
BEGIN

	INSERT INTO tblUserActivity(userId,actDate,activity,recorded,recordType,activityData) 
		VALUES (@UserId, @actDate,@activity, @recorded, @recordType, @activityData)	
	
END


GO
/****** Object:  StoredProcedure [dbo].[ups_Alert]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================== 
-- Author:		Prakash G
-- Create date: 26.7.2013
-- Routine:		Alert
-- Method:		GET
-- Description:	returns one or more Alerts records
-- ==================================================================== 
CREATE PROCEDURE [dbo].[ups_Alert] 

	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgId				AS INT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
    -- 204 -No content
	    
	-- Local variables descriptions
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @eventData used to store event data description
	-- @sessionOrgID used to store the session OrgID
	-- @recorded used to store the current activity ID
	    
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @sessionOrgID	AS INT
	DECLARE	@recorded		AS VARCHAR(50)
	
	SET @date			 = SYSDATETIMEOFFSET();
	SET @UserId			 = (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @accessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE @sessionKey = sessionKey)
	SET @sessionOrgID	 = (SELECT orgid FROM dbo.tblsession WHERE sessionKey = @sessionKey )
	
	
	/* Summary: Check the OrgId Passed or Not */
	IF(ISNULL(@orgId,'0') <> '0')
	BEGIN
	/* Summary:Raise an Error Message.If orgId parameter passed and user = OrgAdmin or OrgUser */
		IF(@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8)
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'orgId','1/1/1900 11:11:11AM +05:30' AS 'TimeStamp','0' AS 'AlertId','0' AS 'AlertData','400|2953 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2953) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	END
	
	IF((@accessLevel = 3 OR @accessLevel = 4) AND @orgId=-1)
	BEGIN
		IF(EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and O.orgId in(SELECT d.orgId FROM dbo.tblOrganization d where d.Owner=@sessionOrgID  )))
		BEGIN
			SELECT '<list>'+(SELECT ISNULL(CONVERT(VARCHAR,a.orgId),'NULL') AS 'orgId',ISNULL(CONVERT(CHAR(33),a.[TimeStamp], 126),'1/1/1900 11:11:11AM +05:30') AS 'TimeStamp',ISNULL(a.AlertId,'NULL') AS 'AlertId',ISNULL(a.AlertData,'NULL') AS 'AlertData','200' AS 'ErrId'   FROM dbo.tblAlerts a INNER JOIN tblOrganization o ON a.OrgId = o.OrgId WHERE a.OrgId in(SELECT isnull(d.orgId,'0') FROM dbo.tblOrganization d where d.Owner=@sessionOrgID )  FOR XML RAW )+'</list>'
			RETURN;
		END
	END	
		
	
	/*  Summary:Raise an Error Message. If orgId is not passed and Session[accessLevel] is either SysAdminRW/RO or  VarAdminRW/RO */
	IF(ISNULL(@orgId,'0') = 0)
	BEGIN
		IF(@accessLevel = 1 OR @accessLevel = 2 OR @accessLevel = 3 OR @accessLevel = 4)
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'orgId','1/1/1900 11:11:11AM +05:30' AS 'TimeStamp','0' AS 'AlertId','0' AS 'AlertData','400|2952 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2952) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8)
		BEGIN
		   SET @orgId = @sessionOrgID;
		END
	END
	
	/* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */
	IF NOT EXISTS(SELECT OrgId FROM dbo.tblOrganization WHERE OrgId = @orgId)
	BEGIN
		SELECT '<list>'+(SELECT '0' AS 'orgId','1/1/1900 11:11:11AM +05:30' AS 'TimeStamp','0' AS 'AlertId','0' AS 'AlertData','400|2954 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2954) AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
		
	/* Summary: If the Organization record is found, check if the user is authorized to make this request */
			/*  Summary: If accessLevel is SysAdminRW/RO */
			/* Summary: If accessLevel is VarAdminRW/RO, then check if Session[OrgId] is the owner of organization[OrgId] */
			/* Summary: If accessLevel is OrgAdminRW/RO or OrgUserRW/RO then check if Session[OrgId] is the same as organization[OrgId] */	

	IF((@accessLevel = 1 OR @accessLevel = 2) OR 
	((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and O.orgId = @orgId )))
	 OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8 ) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgID = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId = @orgId))))
	BEGIN
	
		IF(EXISTS(SELECT a.AlertId FROM dbo.tblAlerts a INNER JOIN tblOrganization o ON a.OrgId = o.OrgId WHERE a.OrgId = @orgId))
		BEGIN
			SELECT '<list>'+(SELECT ISNULL(CONVERT(VARCHAR,a.orgId),'NULL') AS 'orgId',ISNULL(CONVERT(CHAR(33),a.[TimeStamp], 126),'1/1/1900 11:11:11AM +05:30') AS 'TimeStamp',ISNULL(a.AlertId,'NULL') AS 'AlertId',ISNULL(a.AlertData,'NULL') AS 'AlertData','200' AS 'ErrId'   FROM dbo.tblAlerts a INNER JOIN tblOrganization o ON a.OrgId = o.OrgId WHERE a.OrgId = @orgId  FOR XML RAW )+'</list>'
			SELECT @recorded =  COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),a.AlertId) FROM dbo.tblAlerts a INNER JOIN tblOrganization o ON a.OrgId = o.OrgId WHERE a.OrgId = @orgId
			UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @UserId,@date,3,@recorded,19,'Retrieve'
			RETURN;
		END
		/*Summary:Retrun an  message (204).If a matching Alert  orgid is not found in Alert Data store*/
		ELSE
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'orgId','1/1/1900 11:11:11AM +05:30' AS 'TimeStamp','0' AS 'AlertId','0' AS 'AlertData','204' AS 'ErrId' FOR XML RAW )+'</list>'
			UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @UserId,@date,3,0,19,'Retrieve'
			RETURN;
		END
	END
	/* Summary: Raise an Error Message.User not within scope*/
	ELSE
	BEGIN
		SELECT '<list>'+(SELECT '0' AS 'orgId','1/1/1900 11:11:11AM +05:30' AS 'TimeStamp','0' AS 'AlertId','0' AS 'AlertData','401|2955 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2955)+ ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	
END
--EXEC  [dbo].[ups_Alert] 'DA4B9237BACCCDF19C0760CAB7AEC4A8359010B0','6B05DB6DC930458646C3F560481C38E61E233D47','20'

GO
/****** Object:  StoredProcedure [dbo].[ups_ArchivedInterceptor]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================== 
-- Author:		Dineshkumar G
-- Create date: 04.06.2013
-- Routine:		ArchivedInterceptor
-- Method:		GET
-- Description:	returns one or more ArchivedInterceptor records
-- ==================================================================== 

CREATE PROCEDURE [dbo].[ups_ArchivedInterceptor]

	@applicationKey		AS	VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgId				AS INT,	
	@locId				AS INT,	
	@intID				AS INT,	
	@intSerial			AS VARCHAR(12)
	
	AS
	BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @recorded used to stroe the current actvity
		
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE	@recorded		AS VARCHAR(100)
	
	SET @recorded		 = ''
	SET @date			 = SYSDATETIMEOFFSET();
	SET @UserId			 = (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	SET @accessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)

	IF(ISNULL(@orgId,0) = 0)SET @orgId = 0
	IF(ISNULL(@locId,0) = 0)SET @locId = 0
	IF(ISNULL(@intID,0) = 0)SET @intID = 0
	IF(ISNULL(@intSerial,'') = '')SET @intSerial = ''
	
	/*Summary:If the accessLevel is not SysAdminRW/RO, then send a HTTP response “401 Unauthorised*/
	IF(@accessLevel = 1 OR @accessLevel = 2)
	BEGIN
	
		/* Summary: Raise an error message If none of orgId, locId or intId or intSerial are passed */
		IF(@orgId = 0 AND @locId = 0 AND @intID = 0 AND @intSerial = '')
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2604 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2604) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END  
		ELSE IF(@intId != 0 AND @intSerial != '' AND @orgId != 0 AND @locId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2603 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2603)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intID,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intSerial,'')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intId != 0 AND @intSerial != '' AND @orgId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2610 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2610)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intID,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intId != 0 AND @intSerial != '' AND @locId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2609 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2609)+ CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intID,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intId != 0 AND @orgId != '' AND @locId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2607 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2607)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intID,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intSerial != '' AND @orgId != '' AND @locId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2608 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2608)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@orgId != 0 AND @locId != 0  )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2611 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2611)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@locId,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@orgId != 0 AND @intSerial != '')
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2613 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2613)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@orgId != 0 AND @intId != 0)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2612 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2612)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intID,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@locId != 0 AND @intSerial != '')
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2615 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2615)+ CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@locId != 0 AND @intId != 0)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2614 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2614)+ CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intID,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intSerial != '' AND @intId != 0)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2617 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2617)+ CONVERT(VARCHAR,ISNULL(@intID,'0'))+','+CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE
		BEGIN      /* Summary: Raise an error message;IF orgId, locId or intId or intSerial any one passed and does not match ArchivedInterceptor records */
				    IF EXISTS(SELECT 1 FROM dbo.tblArchivedInterceptor WHERE IntId = @intId OR IntSerial = @intSerial OR OrgId = @orgId OR LocId = @locId)
					BEGIN	  
					    SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId) FROM dbo.tblArchivedInterceptor t  JOIN dbo.tblOrganization O on t.OrgId = O.OrgId JOIN dbo.tblLocation L on t.OrgId = L.OrgId AND t.LocId = l.LocId WHERE t.IntId = @intId OR t.IntSerial = @intSerial
					    SELECT '<list>'+( SELECT IntId AS 'IntId',ISNULL(IntSerial,'NULL') AS 'IntSerial',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',ISNULL(CONVERT(VARCHAR,t.OrgId),'NULL') AS 'OrgId',ISNULL(ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,CaptureMode),'NULL') AS 'CaptureMode',
						ISNULL(CONVERT(VARCHAR,CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(CallHomeTimeoutData,'NULL') AS 'CallHomeTimeoutData',ISNULL(DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,[Security]),'NULL') AS 'security',ISNULL(StartURL,'NULL') AS 'startURL',ISNULL(ReportURL,'NULL') AS 'reportURL',
						ISNULL(ScanURL,'NULL') AS 'scanURL',ISNULL(BkupURL,'NULL') AS 'bkupURL',ISNULL(CONVERT(VARCHAR,RequestTimeoutValue),'NULL') AS 'requestTimeoutValue',ISNULL(WpaPSK,'NULL') AS 'wpaPSK',ISNULL(SSId,'NULL') AS 'ssid',ISNULL(CONVERT(CHAR(33),CanDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'canDate',ISNULL(CmdURL,'NULL') AS 'CmdURL',ISNULL(CONVERT(VARCHAR,CmdChkInt),'NULL') AS 'CmdChkInt','0|accessLevel|'+CONVERT(VARCHAR,@accessLevel) AS 'ErrId'
						FROM dbo.tblArchivedInterceptor t
						JOIN dbo.tblOrganization O ON t.OrgId = O.OrgId
					    JOIN dbo.tblLocation L ON t.OrgId = L.OrgId AND t.LocId = l.LocId
						WHERE t.IntId = @intId OR t.IntSerial = @intSerial OR t.OrgId = @orgId OR t.LocId = @locId FOR XML RAW )+'</list>'	
					    
						UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
						EXEC upi_UserActivity @UserId,@date,3,@recorded,14,'Retrieve'
						RETURN;
					    
					END
					ELSE
					BEGIN
						IF(@orgId != 0)	SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2605 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2605)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
						IF(@locId != 0)	SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2606 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2606)+ CONVERT(VARCHAR,ISNULL(@locId,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
						IF(@intId != 0)	SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2618 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2618)+ CONVERT(VARCHAR,ISNULL(@intID,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
						IF(@intSerial != '')SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','400|2616 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2616)+ CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
						RETURN;
					END
				END
	END	
	ELSE
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'LocId','0' AS 'OrgId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'security','0' AS 'startURL','0' AS 'reportURL','0' AS 'scanURL','0' AS 'bkupURL','0' AS 'requestTimeoutValue','0' AS 'wpaPSK','0' AS 'ssid','1/1/1900 11:11:11AM +05:30' AS 'canDate','0' AS 'CmdURL','0' AS 'cmdChkInt','401|2601 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2601)+ CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
		EXEC upi_SystemEvents 'ArchivedInterceptor',2601,3,@accessLevel
		RETURN;
	END
END
--exec ups_ArchivedInterceptor '4A79DB236006635250C7470729F1BFA30DE691D7','DE5E3FDDC97C184BFEDE0741E7887771EC5BB22B',2,0,0,''


GO
/****** Object:  StoredProcedure [dbo].[ups_ArchivedOrganization]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================== 
-- Author:		Dineshkumar G
-- Create date: 24.05.2013
-- Routine:		ArchivedOrganization
-- Method:		Get
-- Description:	Returns one or more ArchivedOrganization records
-- ==================================================================== 
CREATE PROCEDURE [dbo].[ups_ArchivedOrganization] 

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@orgId			AS INT
		
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @recorded used to store the current actvity
	
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @recorded		AS VARCHAR(100)
	
	SET @date			 = SYSDATETIMEOFFSET();
	SET @UserId			 = (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	SET @accessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	 
	IF(ISNULL(@orgId,0) = 0)	SET @orgId = 0
	
	/* Summary: Raise an error message if an access level field is Not SysAdminRW/RO in the Session data store */
	IF(@accessLevel <> 1 AND @accessLevel <> 2)
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress', '0' AS 'Owner', '400|2701 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2701)+ CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
		EXEC upi_SystemEvents 'ArchivedOrganization',2701,3,@accessLevel
		RETURN;
	END
	/* Summary:If orgId is passed and is  “*”, retrieve all ArchivedOrganizationrecords */
	IF(@orgId = -1)
	BEGIN
			SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId) FROM dbo.tblArchivedOrg O 
			JOIN tblOrganization org on org.OrgId = O.[Owner]
			IF(@recorded != '')
			BEGIN
				SELECT '<list>'+(
				SELECT O.Orgid AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName',ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',		
				ISNULL(CONVERT(VARCHAR,O.owner),'NULL') As 'Owner',
			    '0|accessLevel'+ ISNULL(ISNULL(CONVERT(VARCHAR,@accessLevel),''),'') AS 'ErrId'
				FROM dbo.tblArchivedOrg O 
				left JOIN tblOrganization org ON org.OrgId = O.[Owner]
				FOR XML RAW )+'</list>'
				
				UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
				EXEC upi_UserActivity @UserId,@date,3,@recorded,16,'Retrieve'
				RETURN;
			END
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress', '0' AS 'Owner','400|2704 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2704) AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
			END
	END
	/* Summary:If orgId is passed and is  “-2”, retrieve all distinct ArchivedOrganization records (For dashboard team)*/
	IF(@orgId = -2)
	BEGIN
			SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId) FROM dbo.tblArchivedOrg O 
			JOIN tblOrganization org on org.OrgId = O.[Owner]
			IF(@recorded != '')
			BEGIN
				SELECT '<list>'+(
				SELECT distinct(convert(varchar(max),O.orgid)) AS 'Orgid',ISNULL(O.OrgName,'NULL')+ '['+ convert(varchar(max),O.orgid)+']' AS 'OrgName',ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',		
				ISNULL(CONVERT(VARCHAR,O.owner),'NULL') As 'Owner',
			    '0|accessLevel'+ ISNULL(ISNULL(CONVERT(VARCHAR,@accessLevel),''),'') AS 'ErrId'
				FROM dbo.tblArchivedOrg O 
				left JOIN tblOrganization org ON org.OrgId = O.[Owner]
				FOR XML RAW )+'</list>'
				--UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
				--EXEC upi_UserActivity @UserId,@date,3,@recorded,16,'Retrieve'
				RETURN;
			END
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress', '0' AS 'Owner','400|2704 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2704) AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
			END
	END
	/* Summary:If orgId is not passed, Return Error: 400 Bad Request
	   If orgId is passed and is not “*”, search for a matching ArchivedOrganization record
	*/
	ELSE IF(@orgId = 0 )
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress', '0' AS 'Owner','400|2703 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2703) AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	ELSE
	BEGIN
			SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId)FROM dbo.tblArchivedOrg O 
			JOIN tblOrganization org on org.OrgId = O.[Owner]
			WHERE O.OrgId = @orgId
			IF(@recorded != '')
			BEGIN
				SELECT '<list>'+(
				SELECT O.Orgid AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName', ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',
				ISNULL(CONVERT(VARCHAR,O.owner),'NULL') As 'Owner',
				'0|accessLevel'+ISNULL(ISNULL(CONVERT(VARCHAR,@accessLevel),''),'') AS 'ErrId'
				FROM dbo.tblArchivedOrg O 
				left JOIN tblOrganization org ON org.OrgId = O.[Owner]
				WHERE O.OrgId = @orgId
				FOR XML RAW )+'</list>'
				UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
				EXEC upi_UserActivity @UserId,@date,3,@recorded,16,'Retrieve'
				RETURN;
			END
			ELSE
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress', '0' AS 'Owner','400|2704 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2704) AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
			END
	END
END
--[ups_ArchivedOrganization] 'C1C2C3C4C5C6C7C8','818E5150D238F3BCE7300785C019077C14793933',-2

GO
/****** Object:  StoredProcedure [dbo].[ups_ArchivedUser]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:		Dineshkumar G	
-- Create date: 05.06.2013
-- Routine:		ArchievedUser
-- Method:		Get
-- Description:	returns one or more ArchivedUser records
-- ==============================================================
CREATE PROCEDURE [dbo].[ups_ArchivedUser]

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@userId			AS VARCHAR(5),
	@orgId			AS INT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @recorded used to store current activity
	
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE	@recorded		AS VARCHAR(100)
	
	SET @recorded = ''
	IF(ISNULL(@orgId,0) = 0)SET @orgId = 0
	IF(ISNULL(@userId,'') = '')SET @userId = ''
	
	SET @date = SYSDATETIMEOFFSET();
	SET @accessLevel = (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
   
	/*Summary:If the accessLevel is not SysAdminRW/RO, then send a HTTP response “401 Unauthorised*/
	IF(@accessLevel = 1 OR @accessLevel = 2)
	BEGIN
	  /* Summary:Raise an Error Message,Both Userid,orgid is not passed */
		IF(@userId = '' AND @orgId = 0)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName',@date AS 'RegDate', '0' AS 'AccessLevel', '400|2654 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2654) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		/* Summary:Raise an Error Message,Both Userid,orgid is passed */
		ELSE IF(@userId ! = '' AND  @orgId! = 0)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName',@date AS 'RegDate', '0' AS 'AccessLevel', '400|2653 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2653)+ CONVERT(VARCHAR,ISNULL(@userId,'0')) + ',' +CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE
		BEGIN
		  /* Summary:If userid Passed then to do the following step */
			IF(@userId ! = '')
			BEGIN
				/* Summary:Raise an Error Message,If userid is passed, matching tblArchivedUser record is not found */
				IF EXISTS(SELECT 1 FROM dbo.tblArchivedUser WHERE UserId = @userId)
				BEGIN
				    SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),UserId)FROM dbo.tblArchivedUser U WHERE U.UserId = @userId
					SELECT '<list>'+(SELECT ISNULL(U.UserId,'NULL')  AS 'UserId', ISNULL(U.FirstName,'NULL') AS 'FirstName', ISNULL(U.LastName,'NULL')  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',ISNULL(CONVERT(VARCHAR,U.AccessLevel),'NULL') AS 'AccessLevel', '0|accessLevel|'+ CONVERT(VARCHAR,@accessLevel) AS 'ErrId'
					FROM dbo.tblArchivedUser U WHERE U.UserId = @userId
					FOR XML RAW )+'</list>'
				END
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName',@date AS 'RegDate', '0' AS 'AccessLevel', '400|2656 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2656)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END
			END
			/* Summary:If  orgid Passed then to do the following step */
			ELSE IF(@orgId! = 0)
			BEGIN
			 /* Summary:Raise an Error Message,If orgid is passed, matching tblArchivedUser record is not found */
				IF EXISTS(SELECT 1 FROM dbo.tblArchivedUser WHERE OrgId = @orgId)
				BEGIN
				    SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),UserId)FROM dbo.tblArchivedUser U WHERE U.OrgId = @orgId
					SELECT '<list>'+(SELECT ISNULL(U.UserId,'NULL')  AS 'UserId', ISNULL(U.FirstName,'NULL') AS 'FirstName', ISNULL(U.LastName,'NULL')  AS 'LastName',ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',ISNULL(CONVERT(VARCHAR,U.AccessLevel),'NULL') AS 'AccessLevel', '0|accessLevel|'+ CONVERT(VARCHAR,@accessLevel) AS 'ErrId'
					FROM dbo.tblArchivedUser U WHERE U.OrgId = @orgId
					FOR XML RAW )+'</list>'
				END
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName',@date AS 'RegDate', '0' AS 'AccessLevel', '400|2655 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2655)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END
			END
		END
	END
	ELSE
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName',@date AS 'RegDate', '0' AS 'AccessLevel', '401|2651 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2651)+ CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
		EXEC upi_SystemEvents 'ArchivedUser',2651,3,@accessLevel
		RETURN;
	END
	UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
	EXEC upi_UserActivity @UserId,@date,3,@recorded,15,'Retrieve'
END
--[ups_User] 'A1A2A3A4A5A6A7A8','B1AB6CCC2CC4D7B02C73B34A30160B97',NULL,1
--[ups_User] 'A1A2A3A4A5A6A7A8','B1AB6CCC2CC4D7B02C73B34A30160B97','SPU01',NULL
--[ups_User] 'A1A2A3A4A5A6A7A8','B1AB6CCC2CC4D7B02C73B34A30160B97',NULL,NULL


GO
/****** Object:  StoredProcedure [dbo].[ups_BatchDispatcher]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- Author:		Dineshkumar G
-- Create date: 04.07.2013
-- Routine:		BatchDispatcher
-- Method:		Internal Service Routine
-- Description:	routine sends an HTTP POST request to ScanBatches[forwardURL]
-- ============================================================================
CREATE PROCEDURE [dbo].[ups_BatchDispatcher] 

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @accessLevel	AS INT
	DECLARE @IsSessionExist AS INT 
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @Time           AS Varchar(50)
	DECLARE @Minute			AS Varchar(2)
	
	SET @date = SYSDATETIMEOFFSET()
	SET @Time=(Select(Ltrim(Rtrim(CONVERT (time, SYSDATETIMEOFFSET())))))
    SET @Minute=(SELECT SUBSTRING(@Time,4,CHARINDEX(':',@Time)-1))
    --SET @Minute='00'
    IF(@Minute='00')
    BEGIN
		exec up_CheckAndDeleteExpiredSessionKey
    END

	
	IF EXISTS(SELECT 1 FROM dbo.tblScanBatches WHERE DeliveryTime< = @date)
	BEGIN
		SELECT '<list>'+(
		SELECT ISNULL(S.IntSerial,'NULL') AS 'IntSerial', ISNULL(S.OrgName,'NULL') AS 'OrgName',ISNULL(CONVERT(CHAR(33),S.DeliveryTime, 126),'1/1/1900 11:11:11AM +05:30') AS 'DeliveryTime',ISNULL(S.ForwardURL,'NULL') AS 'ForwardURL', ISNULL(S.UnitSuite,'NULL') AS 'UnitSuite', ISNULL(S.Street,'NULL') AS 'Street',
		ISNULL(S.City,'NULL') AS 'City',ISNULL(S.State,'NULL') AS 'State',ISNULL(S.Country,'NULL') AS 'Country',ISNULL(S.PostalCode,'NULL') AS 'PostalCode',ISNULL(S.LocType,'NULL') AS 'LocType',ISNULL(S.LocSubType,'NULL') AS 'LocSubType', ISNULL(S.IntLocDesc,'NULL') AS 'IntLocDesc',
		ISNULL(S.ScanData,'NULL') AS 'ScanData',ISNULL(S.Id,'0') AS 'Id','0' AS 'ErrId'
		FROM dbo.tblScanBatches S WHERE DeliveryTime< = @date
		FOR XML RAW )+'</list>'
	END
	ELSE
	BEGIN
		SELECT '<list>'+(
		SELECT '0' AS 'IntSerial', '0' AS 'OrgName','0' AS 'DeliveryTime','0' AS 'ForwardURL', '0' AS 'UnitSuite', '0' AS 'Street',
		'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType', '0' AS 'IntLocDesc',
		'0' AS 'ScanData','0' AS 'Id','400' AS 'ErrId'
		FOR XML RAW )+'</list>'
	END	
END





GO
/****** Object:  StoredProcedure [dbo].[ups_BatchDispatcherEvents]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================
-- Author:		iHorse
-- Create date: 04.07.2013
-- Routine:		BatchDispatcher
-- Method:		Internal Service Routine
-- Description:	routine sends an HTTP POST request to ScanBatches[forwardURL]
-- =======================================================================================
CREATE PROCEDURE [dbo].[ups_BatchDispatcherEvents] 
	
	@response	AS VARCHAR(50),
	@Id			AS INT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @eventData AS VARCHAR(100)
	SET @eventData = 'Routine=DeviceScan'
	
	IF(@response='200 Ok' OR @response='OK')
	BEGIN
		DELETE FROM dbo.tblScanBatches WHERE Id=@Id
		EXEC upi_SystemEvents 'BatchDispatcher',3101,1,'200 OK'
	END
	ELSE
	BEGIN
		EXEC upi_SystemEvents 'BatchDispatcher',3102,1,@response
	END
END
--[up_BatchDispatcher]


GO
/****** Object:  StoredProcedure [dbo].[ups_Content]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- Author:		Prakash G
-- Create date: 05.6.2013
-- Routine:		Content
-- Method:		GET
-- Description:	returns one or more Content records
-- ============================================================================
CREATE PROCEDURE [dbo].[ups_Content] 

	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgId				AS INT,
	@code				AS VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
    -- 401 - Unauthorized
    -- 200 - Success
	    
	-- Local variables descriptions
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @sessionOrgID used to store the session OrgID
	-- @recorded used to store the current activity ID.
	
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE @sessionOrgID	AS INT
	DECLARE	@recorded		AS VARCHAR(100)
	
	SET @date			 = SYSDATETIMEOFFSET();
	SET @UserId			 = (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @accessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE @sessionKey = sessionKey)
	SET @sessionOrgID	 = (SELECT orgid FROM dbo.tblsession WHERE sessionKey = @sessionKey  )
	IF(ISNULL(@orgId,0) = 0)	SET @orgId = 0
	IF(ISNULL(@code,'') = '')	SET @code = ''
	
	/* Summary: Check the OrgId Passed or Not */
	IF(@orgId <> 0)
	BEGIN
		/* Summary:Raise an Error Message.If orgId parameter passed and user = OrgAdmin or OrgUser */
		IF(@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8)
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'Code','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer','0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' as 'DESCRIPTION','0' AS 'UnitMeasure','0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2','400|2752 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode = 2752) AS 'ErrId' FOR XML RAW )+'</list>'
		    RETURN;
		END
	END
	
	/*  Summary:Raise an Error Message. If orgId is not passed and Session[accessLevel] is either SysAdminRW/RO or  VarAdminRW/RO */
	IF(@orgId = 0)
	BEGIN
    	IF(@accessLevel = 1 OR @accessLevel = 2 OR @accessLevel = 3 OR @accessLevel = 4)
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'Code','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer','0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' as 'DESCRIPTION','0' AS 'UnitMeasure','0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2','400|2751 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode = 2751) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8)
		BEGIN
		   SET @orgId = @sessionOrgID;
		END
	END
	
	/* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */
	IF NOT EXISTS(SELECT OrgId FROM dbo.tblOrganization WHERE OrgId = @orgId)
	BEGIN
		 SELECT '<list>'+(SELECT '0' AS 'Code','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer','0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' as 'DESCRIPTION','0' AS 'UnitMeasure','0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2','400|2753 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode = 2753)+ CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
		 RETURN;
	END
		
	/* Summary: If the Organization record is found, check if the user is authorized to make this request */
			/*  Summary: If accessLevel is SysAdminRW/RO */
			/* Summary: If accessLevel is VarAdminRW/RO, then check if Session[OrgId] is the owner of organization[OrgId] */
			/* Summary: If accessLevel is OrgAdminRW/RO or OrgUserRW/RO then check if Session[OrgId] is the same as organization[OrgId] */	
				
	IF((@accessLevel = 1 OR @accessLevel = 2) OR ((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId = @orgId))) OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8 ) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgID = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId = @orgId))))
		BEGIN
			/*Summary:Raise an error message (400).If a matching Content record is not found */
			IF(@code <>'')
			BEGIN
				/* Summary: If content code  already Exist  in content data store then do the following */
				IF(EXISTS(SELECT CODE FROM dbo.tblcontent WHERE CODE = @code and orgid = @orgId ))
				BEGIN
					SELECT '<list>'+( SELECT ISNULL(C.Code,'NULL') AS 'Code',ISNULL(C.Category,'NULL') AS 'Category',ISNULL(C.Model,'NULL') AS 'Model',ISNULL(C.Manufacturer,'NULL') AS 'Manufacturer',ISNULL(C.PartNumber,'NULL') AS 'PartNumber',ISNULL(C.ProductLine,'NULL') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'NULL') AS 'ManufacturerSKU',ISNULL(C.DESCRIPTION,'NULL') as 'DESCRIPTION', ISNULL(C.UnitMeasure,'NULL') AS 'UnitMeasure',ISNULL(CONVERT(VARCHAR,C.UnitPrice),'NULL') AS 'UnitPrice',ISNULL(C.Misc1,'NULL') AS 'Misc1',ISNULL(C.Misc2,'NULL') AS 'Misc2','0|accesslevel|'+CONVERT(VARCHAR,@accessLevel) AS 'ErrId' FROM dbo.tblContent C WHERE C.Code = @code AND C.OrgId = @orgId FOR XML RAW )+'</list>'
					SELECT @recorded =  COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),Id)FROM dbo.tblContent c WHERE c.Code = @code AND c.OrgId = @orgId
					UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
					EXEC upi_UserActivity @UserId,@date,3,@recorded,17,'Retrieve'
					RETURN;
				END 
				/*Summary:Raise an error message (400).If a matching Content code and orgid is not found in content */
				ELSE
				BEGIN
					SELECT '<list>'+(SELECT '0' AS 'Code','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer','0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' as 'DESCRIPTION','0' AS 'UnitMeasure','0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2','400|2754 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode = 2754)+CONVERT(VARCHAR,@code) AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END 
			END
			/* Summary: If content orgid  already Exist in content data store then do the following */
			ELSE IF (EXISTS(SELECT CODE FROM dbo.tblcontent WHERE orgid = @orgId))
			BEGIN
				SELECT '<list>'+(SELECT ISNULL(C.Code,'NULL') AS 'Code',ISNULL(C.Category,'NULL') AS 'Category',ISNULL(C.Model,'NULL') AS 'Model',ISNULL(C.Manufacturer,'NULL') AS 'Manufacturer',ISNULL(C.PartNumber,'NULL') AS 'PartNumber',ISNULL(C.ProductLine,'NULL') AS 'ProductLine',ISNULL(C.ManufacturerSKU,'NULL') AS 'ManufacturerSKU',ISNULL(C.DESCRIPTION,'NULL') as 'DESCRIPTION', ISNULL(C.UnitMeasure,'NULL') AS 'UnitMeasure',ISNULL(CONVERT(VARCHAR,C.UnitPrice),'NULL') AS 'UnitPrice',ISNULL(C.Misc1,'NULL') AS 'Misc1',ISNULL(C.Misc2,'NULL') AS 'Misc2','0|accesslevel|'+CONVERT(VARCHAR,@accessLevel) AS 'ErrId' FROM dbo.tblContent C WHERE C.OrgId = @orgId FOR XML RAW )+'</list>'
				SELECT @recorded =  COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),Id)FROM dbo.tblContent c WHERE c.OrgId = @orgId
				UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
				EXEC upi_UserActivity @UserId,@date,3,@recorded,17,'Retrieve'
				RETURN;
			END
			/*Summary:Raise an error message (400).If a matching Content orgid is not found in content Data store*/
			ELSE
			BEGIN
				SELECT '<list>'+(SELECT '0' AS 'Code','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer','0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' as 'DESCRIPTION','0' AS 'UnitMeasure','0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2','400|2755 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode = 2755)+CONVERT(VARCHAR,@orgid) AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
			END
		END
		/* Summary: Raise an Error Message.User not within scope*/
		ELSE
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'Code','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer','0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' as 'DESCRIPTION','0' AS 'UnitMeasure','0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2','400|2756 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog where ErrorCode = 2756)+CONVERT(VARCHAR,isnull(@accessLevel,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			EXEC upi_SystemEvents 'Content',2756,3,@accessLevel
			 RETURN;
		END
	END
--exec [ups_Content] '4A79DB236006635250C7470729F1BFA30DE691D7','1234567891234567891234567891234567891234',10,'[{"Code":""}]'
	

GO
/****** Object:  StoredProcedure [dbo].[ups_deviceBackupJsonData]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- Author:		Dineshkumar G
-- Create date: 04.07.2013
-- Routine:		DeviceBackup
-- Method:		Internal Service Routine
-- ============================================================================
Create PROCEDURE [dbo].[ups_deviceBackupJsonData] 
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblTempdevicescan WHERE status = 1)
	BEGIN
		SELECT '<list>'+(
		SELECT TOP 1 ISNULL(a,'NULL') AS 'a', ISNULL(i,'NULL') AS 'i',ISNULL(b,'NULL') AS 'b',ISNULL(status,'NULL') AS 'workRoleStatus',id as 'id','0' AS 'ErrId'
		FROM dbo.tblTempdevicescan WHERE status = 1
		FOR XML RAW )+'</list>'
	END
	ELSE
	BEGIN
		SELECT '<list>'+(
		SELECT '0' AS 'a', '0' AS 'i','0' AS 'b','0' AS 'workRoleStatus','0' as 'id','400' AS 'ErrId'
		FOR XML RAW )+'</list>'
	END	
END

GO
/****** Object:  StoredProcedure [dbo].[ups_DeviceScan]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===================================================
-- Author:		Indhumathi T
-- Create date: 27.05.2013
-- Routine:		DeviceScan
-- Method:		Get
-- Description:	Returns one or more DeviceScan records
-- ====================================================
CREATE PROCEDURE [dbo].[ups_DeviceScan] 

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@intSerial		AS VARCHAR(12),
	@startDate		AS DATETIMEOFFSET(7) = NULL,
	@stopDate		AS DATETIMEOFFSET(7) = NULL,
	@orgId			AS INT,
	@locId			AS INT
		
AS
BEGIN


	SET NOCOUNT ON;

	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date AND time FROM the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- DNF  - Should not return the fields cellPhone AND metaData
    -- RENF - Should not return the fields callHomeRedemptionData
    -- CNF  - Should not return the fields category, model, manufacturer, partNumber, productLine, manufacturerSKU, description, unitMeasure, unitPrice, misc1 AND misc2
       
	   --SET @callHomeData='0'
				--			IF(@scanData like '%*CH*%')
				--			BEGIN 
				--	
				--				SET @callHomeData=(SELECT ISNULL(CONVERT(VARCHAR(500),CallHomeData),'NULL')+'|'+ CONVERT(VARCHAR(100),@Key)+'|'+CONVERT(VARCHAR(100),SYSDATETIMEOFFSET())+'|'+ISNULL(CONVERT(VARCHAR(100),CallHomeURL),'NULL') FROM dbo.tblDynamicCode WHERE DynCID =@dyncid)
				--			END
	                           
	IF(@startDate = '1/1/1900 11:11:11AM +05:30')	SET @startDate = NULL
	IF(@stopDate  = '1/1/1900 11:11:11AM +05:30')	SET @stopDate = NULL
	IF(@startDate = '')	SET @startDate = NULL
	IF(@stopDate  = '')	SET @stopDate = NULL
	DECLARE @ReturnResult		AS VARCHAR(MAX)
	DECLARE @UserId				AS VARCHAR(5)
	DECLARE @date				AS DATETIMEOFFSET(7)
	DECLARE @accessLevel		AS INT
	DECLARE @Key				AS VARCHAR(12)
	Declare @scanData			AS VARCHAR(MAX)
	DECLARE	@recorded			AS VARCHAR(50)
	DECLARE @timestamp			AS DATETIMEOFFSET(7)
	DECLARE @dyncid				AS VARCHAR(4)
	DECLARE @redmptiondata		AS VARCHAR(50)
	DECLARE @callHomeData		AS VARCHAR(100)
	DECLARE @deviceScan			AS NVARCHAR(MAX)
	DECLARE @level				AS VARCHAR(50)
	DECLARE @errCode			AS INT
	DECLARE @tempOrgId			AS INT

	SET @deviceScan		= ''
	SET @ReturnResult	= '';
	SET @date			= SYSDATETIMEOFFSET();
	SET @UserId			= (SELECT userId FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	
	IF(ISNULL(@intSerial,'')='') SET @intSerial = ''
	IF(ISNULL(@orgId,0)=0)	SET @orgId = 0
	IF(ISNULL(@locId,0)=0)	SET @locId = 0
	
	CREATE TABLE #DeviceScan ([IntSerial] [VARCHAR](12) NULL, [ScanData] [VARCHAR](MAX) NULL,[ScanTimestamp] [VARCHAR](MAX) NULL, id INT IDENTITY(1,1) NOT NULL)


	/* Summary: Raise an error message if an access level field is OrgAdminRW/RO  or OrgUserRW/RO
		and also the fields @intSerial,@startDate,@stopDate AND @locId all are not passed.  */
	IF(@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8)
	BEGIN
		IF(@intSerial = '' AND ISNULL(@startDate,'') = '' AND ISNULL(@stopDate,'') = '' AND @locId = 0)
		BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
			'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
			'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
			'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
			'400|2212 '+(SELECT DESCRIPTION +'|' + FieldName  FROM dbo.tblErrorLog WHERE ErrorCode=2212)  AS 'ErrId','0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
			FOR XML RAW )+'</list>'
			RETURN;
		END
	END
	ELSE
	BEGIN
		/* Summary: Raise an error message if an access level field is neither OrgAdminRW/RO nor OrgUserRW/RO
		and also the fields @intSerial,@startDate,@stopDate,@orgId AND @locId all are not passed.  */
		IF(@intSerial = '' AND ISNULL(@startDate,'') = '' AND ISNULL(@stopDate,'') = '' AND @orgId = 0 AND @locId = 0)
		BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
			'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
			'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
			'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
			'400|2213 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=2213)  AS 'ErrId','0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
			FOR XML RAW )+'</list>'
			RETURN;
		END
	END

	/*Summary: Check if @orgid is passed or not */
	IF(ISNULL(@orgId,0) != 0)
	BEGIN
			SET @tempOrgId=@orgId;
		IF NOT EXISTS(SELECT 1 FROM dbo.tblOrganization WITH(NOLOCK) WHERE OrgId=@orgId)
		BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
			'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
			'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
			'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
			'400|2205 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog  WITH(NOLOCK) WHERE ErrorCode=2205) + CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId'
			,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
			FOR XML RAW )+'</list>'
			RETURN;
		END
		/* Summary: Raise an error message if an access level field is OrgAdminRW/RO  or OrgUserRW/RO */
		IF(@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8)
		BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
			'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
			'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
			'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
			'400|2204 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2204) + CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId'
			,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
			FOR XML RAW )+'</list>'
			RETURN;
		END
		/* Summary: Raise an error message if intSerial or locId is passed or not */
		IF(@intSerial != '' OR ISNULL(@locId,0) != 0)
		BEGIN
			IF(@intSerial !='')
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
				'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
				'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
				'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
				'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
				'400|2206 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2206) + CONVERT(VARCHAR,ISNULL(@intSerial,'0')) AS 'ErrId'
				,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
				FOR XML RAW )+'</list>'
				RETURN;
			END
			ELSE IF(ISNULL(@locId,0) != 0)
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
				'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
				'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
				'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
				'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
				'400|2207 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2207) + CONVERT(VARCHAR,ISNULL(@locId,'0')) AS 'ErrId'
				,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
				FOR XML RAW )+'</list>'
				RETURN;
			END
		END
	END
	IF(ISNULL(@locId,0) != 0)
	BEGIN
		SELECT @tempOrgId =  OrgId FROM dbo.tblLocation WHERE LocId = @locId
		IF NOT EXISTS(SELECT 1 FROM dbo.tblLocation WHERE LocId=@locId)
		BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
			'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
			'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
			'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
			'400|2208 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2208) + CONVERT(VARCHAR,ISNULL(@locId,'0')) AS 'ErrId'
			,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
			FOR XML RAW )+'</list>'
			RETURN;
		END
		/*Summary: Raise an error message if @orgId or @intSerial is passed  */
		IF((ISNULL(@orgId,0) != 0) OR (ISNULL(@intSerial,'') != ''))
		BEGIN
			IF((ISNULL(@orgId,0) != 0))
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
				'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
				'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
				'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
				'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
				'400|2209 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2209) + CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId'
				,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
				FOR XML RAW )+'</list>'
				RETURN;
			END
			ELSE IF(ISNULL(@intSerial,'') != '')
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
				'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
				'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
				'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
				'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
				'400|2210 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2210) + CONVERT(VARCHAR,ISNULL(@intSerial,'0')) AS 'ErrId'
				,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
				FOR XML RAW )+'</list>'
				RETURN;
			END
		END
	END
		IF(ISNULL(@intSerial,'') != '')
	BEGIN
		SELECT @tempOrgId =  OrgId FROM dbo.tblInterceptor WHERE IntSerial = @intSerial
		IF NOT EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial=@intSerial)
		BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
			'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
			'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
			'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
			'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
			'400|2216 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2216) + CONVERT(VARCHAR,ISNULL(@locId,'0')) AS 'ErrId'
			,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
			FOR XML RAW )+'</list>'
			RETURN;
		END
		/* Summary: Raise an error message if orgId or locId is passed */
		IF(ISNULL(@orgId,0) != 0 OR ISNULL(@locId,0) != 0)
		BEGIN
			IF(ISNULL(@orgId,0) != 0)
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
				'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
				'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
				'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
				'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
				'400|2202 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog  WITH(NOLOCK) WHERE ErrorCode=2202)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId'
				,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
				FOR XML RAW )+'</list>'
				RETURN;
			END
			ELSE IF(ISNULL(@locId,0) != 0)
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
				'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
				'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
				'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
				'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
				'400|2215 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2215) + CONVERT(VARCHAR,ISNULL(@locId,'0')) AS 'ErrId'
				,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
				FOR XML RAW )+'</list>'
				RETURN;
			END
		END
	END
	IF(@orgId=0 AND @locId=0 AND @intSerial='')
	BEGIN
	SELECT @tempOrgId = OrgId FROM dbo.tblSession WHERE SessionKey = @sessionKey

	END
			--IF(ISNULL(@orgId,0) != 0 OR ISNULL(@locId,0) != 0)
			--BEGIN
			--	SELECT @tempOrgId =  OrgId FROM dbo.tblInterceptor WITH(NOLOCK) WHERE IntSerial = @intSerial
			--END
			--ELSE
			--BEGIN
			--	SELECT @tempOrgId = OrgId FROM dbo.tblSession WHERE SessionKey = @sessionKey
			--END
		/*Summary: Check if passed @orgid have a match in organization table or not */
	--@tempval = @sessOrg = @IntOrgId
	

	--IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE OrgId=@tempOrgId)
	--	BEGIN
			IF((@accessLevel = 1 OR @accessLevel = 2) OR
			((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O WITH(NOLOCK) INNER JOIN dbo.tblSession S WITH(NOLOCK) ON O.Owner = S.OrgId WHERE S.SessionKey = @sessionKey))) OR
			(((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND ( EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O WITH(NOLOCK) INNER JOIN dbo.tblSession S WITH(NOLOCK) ON S.OrgId = @tempOrgId WHERE S.SessionKey = @sessionKey AND O.OrgId = @tempOrgId )))))
			BEGIN
				DECLARE @intStartRow int
				DECLARE @intentRow int
				DECLARE @intpageSize int =1000
				DECLARE @pageNumber int =0

				SET  @intStartRow =  (@pageNumber) * @intpageSize+1
				SELECT '<list>'+(
				SELECT * FROM
				(
					SELECT 
						ISNULL(NULLIF(I.IntSerial,''),'None') AS 'IntSerial',
						ISNULL(NULLIF(I.IntLocDesc,''),'None') AS 'IntLocDesc', 
						ISNULL(NULLIF(O.OrgName,''),'None') AS 'OrgName', 
						ISNULL(NULLIF(L.UnitSuite,''),'None') AS 'UnitSuite', 
						ISNULL(NULLIF(L.Street,''),'None') AS 'Street',
						ISNULL(NULLIF(L.City,''),'None') AS 'City',
						ISNULL(NULLIF(L.State,''),'None') AS 'State',
						ISNULL(NULLIF(L.Country,''),'None') AS 'Country',
						ISNULL(NULLIF(L.PostalCode,''),'None') AS 'PostalCode',
						ISNULL(NULLIF(L.LocType,''),'None') AS 'LocType',
						ISNULL(NULLIF(L.LocSubType,''),'None') AS 'LocSubType',
						ISNULL(NULLIF(CONVERT(CHAR(33),D.ScanDate, 126),''),'1/1/1900 11:11:11AM +05:30') AS 'ScanDate', 
						ISNULL(NULLIF( ISNULL( RedemptionData ,D.ScanData) ,''),'None') AS 'Code',
						CASE WHEN  DC.DynCID IS NOT NULL  THEN  isnull(CellPhone,'None')  ELSE isnull(CellPhone, 'None' ) END as 'CellPhone' , 
						CASE WHEN  DC.DynCID IS NOT NULL  THEN  isnull(MetaData,'None')  ELSE isnull(MetaData, 'None' ) END as 'MetaData' , 
						CASE WHEN (D.scanData like '%*CH*%') THEN 
						ISNULL(D.CallHomeRedmptionData,'None') 
						ELSE 'None' END AS  'callHomeRedemptionData',
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(Category,'None')  ELSE isnull(Category, 'None' ) END as 'Category' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(Model,'None')  ELSE isnull(Model, 'None' ) END as 'Model' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(Manufacturer,'None')  ELSE isnull(Manufacturer, 'None' ) END as 'Manufacturer' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(PartNumber,'None')  ELSE isnull(PartNumber, 'None' ) END as 'PartNumber' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(ProductLine,'None')  ELSE isnull(ProductLine, 'None' ) END as 'ProductLine' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(ManufacturerSKU,'None')  ELSE isnull(ManufacturerSKU, 'None' ) END as 'ManufacturerSKU' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(Description,'None')  ELSE isnull(Description, 'None' ) END as 'Description' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(UnitMeasure,'None')  ELSE isnull(UnitMeasure, 'None' ) END as 'UnitMeasure' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(CONVERT(VARCHAR,UnitPrice),'NONE')  ELSE isnull(CONVERT(VARCHAR,UnitPrice), 'None' ) END as 'UnitPrice' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(Misc1,'None')  ELSE isnull(Misc1, 'None' ) END as 'Misc1' , 
						CASE WHEN  C.Id IS NOT NULL  THEN  isnull(Misc2,'None')  ELSE isnull(Misc2, 'None' ) END as 'Misc2' ,
						0 as 'ErrId',
						D.ID as 'id',
						CASE WHEN  C.Id IS NULL THEN '|CNF' ELSE '' END +
						CASE WHEN DC.DynCID IS NULL THEN '|DNF' ELSE '' END +
						CASE WHEN (D.scanData like '%*CH*%')THEN '' ELSE '|RENF' END  as flag
						
					FROM 
					dbo.tblDeviceScan D 
					INNER JOIN dbo.tblInterceptor I  on  D.IntSerial=I.IntSerial
							  AND   D.IntSerial = CASE WHEN @intSerial <> ''  THEN  @intSerial   ELSE D.IntSerial   END
							  AND   D.ScanDate <= CASE WHEN @stopDate  IS NOT NULL THEN  @stopDate    ELSE D.ScanDate    END
							  AND   D.ScanDate >= CASE WHEN @startDate IS NOT NULL THEN  @startDate   ELSE D.ScanDate    END
					INNER JOIN dbo.tblOrganization o on  I.OrgId=O.OrgId
							  AND 	 O.OrgId = CASE WHEN @orgId <> 0 THEN  @orgId  ELSE  O.OrgId  END
					INNER JOIN dbo.tblLocation L  on L.LocId=I.LocID 
							  AND 	 L.LocId = CASE WHEN @locId <> 0 THEN  @locId  ELSE  L.LocId  END
					LEFT  JOIN dbo.tblDynamicCode DC on DC.DynCID=
							CASE WHEN SCANDATA LIKE  '~%/%' THEN  CASE WHEN  ISNUMERIC ( SUBSTRING(SCANDATA,2,CHARINDEX('/',SCANDATA)-2) )  =1  THEN  SUBSTRING(SCANDATA,2,CHARINDEX('/',SCANDATA)-2) ELSE NULL END ELSE NULL END
							--CASE WHEN (ScanData like '%~%' AND ScanData not like '%deleteitem/prev%' AND ScanData not like '%deleteitem/next%' AND ScanData  not like '%returnitem/pass%' AND ScanData not like '%returnitem/nopass%') THEN SUBSTRING(ScanData,CHARINDEX('~',ScanData)+1,CHARINDEX('/',ScanData)-2) ELSE NULL END
					LEFT  JOIN dbo.tblContent C  on C.Code = ISNULL( RedemptionData ,D.ScanData) AND C.OrgId =  O.OrgId
				) a,
				(
					SELECT 
					  D.ID AS 'colid',
					  ROW_NUMBER() over (order by D.IntSerial ,d.id desc) as  row 
					FROM 
					dbo.tblDeviceScan D 
					INNER JOIN dbo.tblInterceptor I  on  D.IntSerial=I.IntSerial
							  AND   D.IntSerial = CASE WHEN @intSerial <> '' THEN  @intSerial   ELSE D.IntSerial   END
							  AND   D.ScanDate <= CASE WHEN @stopDate  IS NOT NULL THEN  @stopDate    ELSE D.ScanDate    END
							  AND   D.ScanDate >= CASE WHEN @startDate IS NOT NULL THEN  @startDate   ELSE D.ScanDate    END
					INNER JOIN dbo.tblOrganization o on  I.OrgId=O.OrgId
							  AND 	 O.OrgId = CASE WHEN @orgId <> 0  THEN  @orgId  ELSE  O.OrgId  END
					INNER JOIN dbo.tblLocation L  on L.LocId=I.LocID 
							  AND 	 L.LocId = CASE WHEN @locId <> 0  THEN  @locId  ELSE  L.LocId  END 
				)b
				WHERE 
					a.id=b.colid AND
					b.row>= @intStartRow  AND 
					b.row< = @intStartRow +@intpageSize-1 
					FOR XML RAW )+'</list>'



										
		END
			ELSE
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
				'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
				'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
				'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
				'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2',
				'401|2211 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2211) + CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId'
				,'0' AS 'id','0' AS flag,'0' AS 'colid','0' AS 'row'
			
				FOR XML RAW )+'</list>'
				EXEC upi_SystemEvents 'DeviceScan',2211,3,@accessLevel
				RETURN;
			END
		  END
		--ELSE
		--BEGIN
		--		SELECT '<list>'+(
		--		SELECT '0' AS 'IntSerial', '0' AS 'IntLocDesc', '0' AS 'OrgName', '0' AS 'UnitSuite', '0' AS 'Street',
		--		'0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'LocType','0' AS 'LocSubType',
		--		'1/1/1900 11:11:11AM +05:30' AS 'ScanDate', '0' AS 'code','0' AS 'CellPhone', '0' AS 'MetaData','0' AS 'callHomeRedemptionData','0' AS 'Category','0' AS 'Model','0' AS 'Manufacturer',
		--		'0' AS 'PartNumber','0' AS 'ProductLine','0' AS 'ManufacturerSKU','0' AS 'DESCRIPTION',
		--		'0' AS 'UnitMeasure', '0' AS 'UnitPrice','0' AS 'Misc1','0' AS 'Misc2','0' AS 'Id',
		--		'400|2222 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2222) + CONVERT(VARCHAR,ISNULL(@intSerial,'0')) AS 'ErrId'
		--		FOR XML RAW )+'</list>'
		--END
		
		
	
--END

--[ups_DeviceScan] '4A79DB236006635250C7470729F1BFA30DE691D7','768FDE5D5AC6876C9A8E08100994C5AD65AEB9E4','INT123456123','1970-01-01 07:50:57.0000000 +05:30','1970-01-01 07:50:57.0000000 +05:30','',''
--[ups_DeviceScan1] '4A79DB236006635250C7470729F1BFA30DE691D7','768FDE5D5AC6876C9A8E08100994C5AD65AEB9E4','qweewertrtg','','','',''
--[ups_DeviceScan] 'AB8D7AA5DEC91B90F85158CC223916E7C3DEAD52','FA5FF218F822B91167EEAB8F963D5DE59DCE504B','INT2222222AB','','','',''



GO
/****** Object:  StoredProcedure [dbo].[ups_DeviceSetting]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================================================================
-- Author:		iHorse
-- Create date: 30.05.2013
-- Routine:		DeviceSetting
-- Method:		GET
-- DESCRIPTION:	handles HTTP requests from Interceptor devices that are requesting initial configuration settings
-- Modified By: Ganesh R
-- Modified Date: 12.08-2013
-- ==================================================================================================================
CREATE PROCEDURE [dbo].[ups_DeviceSetting] 
	
	@a	AS VARCHAR(50),
	@i  AS VARCHAR(12)
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @eventData used to store event data description
	
	DECLARE @eventData AS VARCHAR(MAX)
	SET @eventData = 'Routine = DeviceSetting; Event = POST' + '; a = ' + Convert(VARCHAR(32), @a) + '; Intserial = '+ Convert(VARCHAR(12), @i)
	
	/* Summary: If any of the input fields are not passed, return a HTTP response “400 Bad Request”. */
	IF((ISNULL(@a,'') = '') OR (ISNULL(@i,'') = ''))
	BEGIN
		IF((ISNULL(@a,'') = '') AND (ISNULL(@i,'') = ''))
		BEGIN
			SELECT '<list>'+ (SELECT '0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'RequestTimeoutValue','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'Security',
			'0' AS 'ErrorLog','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt',SYSDATETIMEOFFSET() AS 'cTime','400' AS 'ErrId' FOR XML RAW )+'</list>'	
			EXEC upi_SystemEvents 'DeviceSetting',2356,3,''
			RETURN;
	    END
		ELSE IF(ISNULL(@a,'') = '')
		BEGIN
			SELECT '<list>'+ (SELECT '0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'RequestTimeoutValue','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'Security',
			'0' AS 'ErrorLog','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt',SYSDATETIMEOFFSET() AS 'cTime','400' AS 'ErrId' FOR XML RAW )+'</list>'	
			EXEC upi_SystemEvents 'DeviceSetting',2351,3,''
			RETURN;
		END
		ELSE IF(ISNULL(@i,'') = '')
		BEGIN
			SELECT '<list>'+ (SELECT '0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'RequestTimeoutValue','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'Security',
			'0' AS 'ErrorLog','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt',SYSDATETIMEOFFSET() AS 'cTime','400' AS 'ErrId' FOR XML RAW )+'</list>'	
			EXEC upi_SystemEvents 'DeviceSetting',2353,3,''
			RETURN;
		END
	END
	
	/* Summary :Use the passed i to search for the InterceptorID record. If record not found, return a HTTP response “400 Bad Request”. */
	IF(NOT EXISTS(SELECT 1 FROM dbo.tblInterceptorID WHERE IntSerial = @i))
	BEGIN
		SELECT '<list>'+ (SELECT '0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'RequestTimeoutValue','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'Security',
		'0' AS 'ErrorLog','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt',SYSDATETIMEOFFSET() AS 'cTime','400' AS 'ErrId' FOR XML RAW )+'</list>'
		EXEC upi_SystemEvents 'DeviceSetting',2354,3,@i
		RETURN;
	END
	
	/* Summary:Create an MD5 hexdigest of InterceptorID[embeddedID]. If hexdigest does not match passed a, return a HTTP response “400 Bad Request”. */
	IF(@a <> (SELECT top 1 CONVERT(VARCHAR(40),HashBytes('SHA1', EmbeddedId),2) FROM dbo.tblInterceptorID WHERE IntSerial = @i))
	BEGIN
		  SELECT '<list>'+ (SELECT '0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'RequestTimeoutValue','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'Security',
		 '0' AS 'ErrorLog','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt',SYSDATETIMEOFFSET() AS 'cTime','400' AS 'ErrId' FOR XML RAW )+'</list>'
		 EXEC upi_SystemEvents 'DeviceSetting',2352,3,@a
		 RETURN;
	END
	
	/* Summary:Use passed i to get Interceptor record.If Interceptor[deviceStatus] is not “active”, return “400 Bad Request */
	IF(EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial = @i))
	BEGIN
		IF(1<>(SELECT top 1 DeviceStatus FROM dbo.tblInterceptor WHERE IntSerial = @i))
		BEGIN
			SELECT '<list>'+ (SELECT '0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'RequestTimeoutValue','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'Security',
			'0' AS 'ErrorLog','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt',SYSDATETIMEOFFSET() AS 'cTime','400' AS 'ErrId' FOR XML RAW )+'</list>'
			EXEC upi_SystemEvents 'DeviceSetting',2355,3,@i
			RETURN;
		END
	END
	ELSE
	BEGIN
		 SELECT '<list>'+ (SELECT '0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'RequestTimeoutValue','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'Security',
		 '0' AS 'ErrorLog','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt',SYSDATETIMEOFFSET() AS 'cTime','400' AS 'ErrId' FOR XML RAW )+'</list>'
		 EXEC upi_SystemEvents 'DeviceSetting',2357,3,@i
	     RETURN;
	END
	
	EXEC upi_SystemEvents 'DeviceSetting',0,1,@eventData
	SELECT '<list>'+ (SELECT ISNULL(t.startURL,'NULL') AS 'startURL',ISNULL(t.ReportURL,'NULL') AS 'ReportURL',ISNULL(t.ScanURL,'NULL') AS 'ScanURL',ISNULL(t.BkupURL,'NULL')AS 'BkupURL',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.RequestTimeoutValue),'NULL') AS 'RequestTimeoutValue',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL') AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.[Security]),'0') AS 'Security',
	ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(t.WpaPSK,'NULL') AS 'WpaPSK',ISNULL(t.SSId,'NULL') AS 'SSId',ISNULL(t.CmdURL,'NULL') AS 'CmdURL',ISNULL(CONVERT(VARCHAR,t.CmdChkInt),'NULL') AS 'CmdChkInt',SYSDATETIMEOFFSET() AS 'cTime','0' AS 'ErrId' FROM dbo.tblinterceptor t WHERE t.IntSerial = @i FOR XML RAW )+'</list>'		
END
--exec [ups_DeviceSetting] 'A1E5F316FDAE2CF45B2E586FFE0D656E7E4980E4','987654321112'


GO
/****** Object:  StoredProcedure [dbo].[ups_DeviceStatus]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================================
-- Author:		Dineshkumar G
-- Create date: 30.05.2013
-- Routine:		DeviceStatus
-- Method:		GET
-- DESCRIPTION:	Handles HTTP requests from Interceptor devices that are requesting initial configuration settings
-- Modified By: Prakash G
-- ===============================================================================================================

--exec [ups_DeviceStatus] 'AB8D7AA5DEC91B90F85158CC223916E7C3DEAD52','2151405C0133717A2654945B06708497D27AFF95','INT252425242'
CREATE PROCEDURE [dbo].[ups_DeviceStatus]
 
	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@intSerial		AS VARCHAR(12)
AS
BEGIN

	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 201 - Created
	-- 200 - Success
	
	-- Local variables descriptions
	-- @date used to store the current date and time from the SQL Server
	-- @UserId used to store userId value	
	-- @accessLevel used to store AccessLevel value
	-- @recorded used to stroe the current actvity
	-- @Orgid used to store the organization ID
	-- @getstatus used to store the Interceptor status
	
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @Orgid			AS INT
	DECLARE @accesslevel	AS INT
	DECLARE @getstatus		AS VARCHAR(10)
	DECLARE @UserId			AS VARCHAR(5)
	
	SET @date	= SYSDATETIMEOFFSET();
	SET @UserId	= (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	
	/* Summary:Check if intSerial is passed. Not passed Return 400 bad request*/
	IF(ISNULL(@intSerial,'') = '')
		BEGIN
			SELECT '<list>'+ (SELECT '0' AS 'IntSerial','1/1/1900 11:11:11AM +05:30' AS 'LogDate','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'Security',
			'0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt','0' AS 'RevId',
			'400|2402 '+(select DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=2402) AS 'ErrId' FOR XML RAW )+'</list>'
			EXEC upi_SystemEvents 'DeviceStatus',2402,3,''
			RETURN;
		END
	ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial=@intSerial)
			BEGIN
					SET @Orgid=(SELECT OrgId FROM dbo.tblInterceptor WHERE IntSerial=@intSerial)
					SET @accesslevel=(SELECT AccessLevel FROM dbo.tblSession WHERE SessionKey=@sessionKey)
					IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE OrgId=@Orgid)
						BEGIN
						    IF(@accesslevel=1 OR @accesslevel=2)
						    BEGIN
								SET @getstatus='Access'
						    END
							ELSE IF(@accesslevel=3 OR @accesslevel=4)
							BEGIN
								IF EXISTS(SELECT 1 FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId WHERE S.SessionKey = @sessionKey AND O.OrgId = @Orgid)
								BEGIN
									SET @getstatus='Access'
								END
								ELSE
								BEGIN
									SELECT '<list>'+ (SELECT '0' AS 'IntSerial','1/1/1900 11:11:11AM +05:30' AS 'LogDate','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'Security',
									'0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt','0' AS 'RevId',
									'401|2404 '+(select DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=2404)AS 'ErrId' FOR XML RAW )+'</list>'
									EXEC upi_SystemEvents 'DeviceStatus',2404,3,@Orgid
								END
							END
							ELSE IF(@accesslevel=5 OR @accesslevel=6 OR @accesslevel=7 OR @accesslevel=8)
							BEGIN
								IF EXISTS(SELECT 1 FROM dbo.tblOrganization O INNER JOIN tblSession S ON S.OrgId =@Orgid  WHERE S.SessionKey = @sessionKey)
								BEGIN
									SET @getstatus='Access'
								END
								ELSE
								BEGIN
									SELECT '<list>'+ (SELECT '0' AS 'IntSerial','1/1/1900 11:11:11AM +05:30' AS 'LogDate','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'Security',
									'0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt','0' AS 'RevId',
									'401|2404 '+(select DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=2404) AS 'ErrId' FOR XML RAW )+'</list>'
									EXEC upi_SystemEvents 'DeviceStatus',2404,3,@Orgid
								END
							END
						END
					ELSE
					BEGIN
						SELECT '<list>'+ (SELECT '0' AS 'IntSerial','1/1/1900 11:11:11AM +05:30' AS 'LogDate','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'Security',
						'0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt','0' AS 'RevId','400' AS 'ErrId'  FOR XML RAW )+'</list>'
						RETURN;
					END
				END
			ELSE
			BEGIN
				SELECT '<list>'+ (SELECT '0' AS 'IntSerial','1/1/1900 11:11:11AM +05:30' AS 'LogDate','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'Security',
				'0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt','0' AS 'RevId',
				'400|2403 '+(select DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=2403) AS 'ErrId' FOR XML RAW )+'</list>'
				EXEC upi_SystemEvents 'DeviceStatus',2404,3,@Orgid
				RETURN;
			END
		END
		IF(@getstatus='Access')
		BEGIN
			IF EXISTS(SELECT 1 FROM dbo.tblDeviceStatus WHERE IntSerial=@intSerial)
			BEGIN
				IF(@accesslevel=1 OR @accesslevel=2)
				BEGIN
					SELECT '<list>'+ (SELECT TOP 1 ISNULL(t.IntSerial,'NULL') AS 'IntSerial',ISNULL(t.LogDate,'1/1/1900 11:11:11AM +05:30') AS 'LogDate',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'0') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL') AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(t.ErrorLog,'NULL') AS 'ErrorLog',ISNULL(t.startURL,'NULL') AS 'startURL',ISNULL(t.ReportURL,'NULL') AS 'ReportURL',ISNULL(t.ScanURL,'NULL') AS 'ScanURL',ISNULL(t.BkupURL,'NULL') AS 'BkupURL',ISNULL(CONVERT(VARCHAR,t.RequestTimeoutValue),'NULL') AS 'RequestTimeoutValue',ISNULL(CONVERT(VARCHAR,t.[Security]),'NULL') AS 'Security',
					ISNULL(t.WpaPSK,'NULL') AS 'WpaPSK',ISNULL(t.SSId,'NULL') AS 'SSId',isnull(t.CmdURL,'NULL') AS 'CmdURL',isnull(CONVERT(VARCHAR,t.CmdChkInt),'0') AS 'CmdChkInt',isnull(t.RevId,'NULL') AS 'RevId','0|accesslevel|'+convert(varchar,@accesslevel) AS 'ErrId' FROM dbo.tblDeviceStatus t WHERE t.IntSerial=@intSerial ORDER BY t.LogDate desc FOR XML RAW )+'</list>'
				END
				ELSE
				BEGIN
					SELECT '<list>'+ (SELECT TOP 1 ISNULL(t.IntSerial,'NULL') AS 'IntSerial',ISNULL(t.LogDate,'1/1/1900 11:11:11AM +05:30') AS 'LogDate',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'0') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL') AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'Security',
					'0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt','0' AS 'RevId','0|accesslevel|'+convert(varchar,@accesslevel) AS 'ErrId' FROM dbo.tblDeviceStatus t WHERE t.IntSerial=@intSerial ORDER BY t.LogDate desc FOR XML RAW )+'</list>'
				END	
			END
			ELSE
			BEGIN
				 SELECT '<list>'+ (SELECT '0' AS 'IntSerial','1/1/1900 11:11:11AM +05:30' AS 'LogDate','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'Security',
				'0' AS 'WpaPSK','0' AS 'SSId','0' AS 'CmdURL','0' AS 'CmdChkInt','0' AS 'RevId',
				'400|2405 '+(select DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=2405) AS 'ErrId' FOR XML RAW )+'</list>'
			END
		END
		UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
		EXEC upi_UserActivity @UserId,@date,0,@applicationKey,1,'Activity data'
END


GO
/****** Object:  StoredProcedure [dbo].[ups_DynamicCode]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ups_DynamicCode]

	@sessionKey			AS VARCHAR(40),
	@cellPhone			AS VARCHAR(64),
	@orgId				AS INT,
	@userId				AS VARCHAR(5),
	@requestStartDate	AS DATETIMEOFFSET(7) = NULL,
	@requestEndDate		AS DATETIMEOFFSET(7) = NULL
	
--ups_DynamicCode '6B05DB6DC930458646C3F560481C38E61E233D44','',0,'','2013-07-31 18:07:19.6332237+05:30','2013-07-31 18:07:19.6332237+05:30'
--ups_DynamicCode '6B05DB6DC930458646C3F560481C38E61E233D42','5676588123',0,'','1/1/1900 11:11:11AM +05:30','1/1/1900 11:11:11AM +05:30'
--[ups_DynamicCode] '6B05DB6DC930458646C3F560481C38E61E233D45','','','','1/1/2000 11:11:11.6332237 +05:30','1/1/2000 11:11:11.6332237 +05:30'
AS
BEGIN
	SET NOCOUNT ON;

--	SELECT     dbo.tblDynamicCode.UserId, dbo.tblDynamicCode.RequestDate, dbo.tblDynamicCode.CellPhone, dbo.tblDynamicCode.CallHomeData, 
--                      dbo.tblDynamicCode.CallHomeURL, dbo.tblDynamicCode.CallHomeTimeoutValue, dbo.tblDynamicCode.RedemptionData, dbo.tblDynamicCode.MetaData, 
--                      dbo.tblUser.OrgId
--FROM         dbo.tblUser INNER JOIN
--                      dbo.tblDynamicCode ON dbo.tblUser.UserId = dbo.tblDynamicCode.UserId
--WHERE     (dbo.tblUser.OrgId = '3')
	
	DECLARE @accessLevel	AS INT
	DECLARE @deviceScan		AS NVARCHAR(MAX)
	DECLARE @errCode			AS INT
	DECLARE @errValue		AS NVARCHAR(100)
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	SET @errValue=''
	SET @errCode=''
	IF(@requestStartDate = '1/1/1900 11:11:11AM +05:30')SET @requestStartDate = NULL
	IF(@requestEndDate  = '1/1/1900 11:11:11AM +05:30')	SET @requestEndDate = NULL
	
	IF(@cellPhone IS NULL OR @cellPhone ='') SET @cellPhone=''
	IF(@orgId IS NULL) SET @orgId=0
	IF(@userId IS NULL OR @userId ='') SET @userId=''
	
	CREATE TABLE #DeviceScan ([UserId] [VARCHAR](5) NULL, [RequestDate] [datetimeoffset](7) NULL,[CellPhone] varchar(64) NULL,
	[CallHomeData] varchar(64) NULL,[CallHomeURL] varchar(256) NULL,[CallHomeTimeoutValue] int NULL,
	[RedemptionData] varchar(63) NULL,[MetaData] [VARCHAR](MAX) NULL, id INT IDENTITY(1,1) NOT NULL)

	/*Summary: cellPhone and other parameters passed */
	IF(@cellPhone = '' AND @orgId = 0 AND @userId = '' AND @requestStartDate IS NULL AND @requestEndDate IS NULL)
	BEGIN
		SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
		'0' AS 'MetaData','400|2196 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=2196)  AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	ELSE
	IF(@cellPhone != '') 
	BEGIN
	  IF(@orgId = 0 AND @userId = '' AND @requestStartDate IS NULL AND @requestEndDate IS NULL)
	  BEGIN
	    IF(Exists(SELECT 1 FROM dbo.tblDynamicCode DC WHERE DC.CellPhone = @cellPhone))
	    BEGIN
		SELECT '<list>'+(
		SELECT ISNULL(D.UserId,'NULL') AS 'UserId',ISNULL(CONVERT(CHAR(33),D.RequestDate,126),'1/1/1900 11:11:11AM +05:30') AS 'RequestDate',ISNULL(D.CellPhone,'NULL') AS 'CellPhone',ISNULL(D.CallHomeData,'NULL') AS 'CallHomeData',
				ISNULL(D.CallHomeURL,'NULL') AS 'CallHomeURL',ISNULL(D.CallHomeTimeoutValue,'0') AS 'CallHomeTimeoutValue',ISNULL(D.RedemptionData,'NULL') AS 'RedemptionData',
				ISNULL(D.MetaData,'NULL') AS 'MetaData','0'  AS 'ErrId'
		--SELECT DC.UserId AS 'UserId',DC.RequestDate AS 'RequestDate',DC.CellPhone AS 'CellPhone',DC.CallHomeData AS 'CallHomeData',
		--DC.CallHomeURL AS 'CallHomeURL',DC.CallHomeTimeoutValue AS 'CallHomeTimeoutValue',DC.RedemptionData AS 'RedemptionData',
		--DC.MetaData AS 'MetaData','0'  AS 'ErrId'
		FROM dbo.tblDynamicCode D WHERE D.CellPhone = @cellPhone
		FOR XML RAW )+'</list>'
		RETURN;
		END
		ELSE
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2179 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=2179)+ CONVERT(VARCHAR,ISNULL(@cellPhone,'0'))  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   END
	   ELSE
	   IF(@orgId != 0 AND @userId != '' AND @requestStartDate IS NOT NULL AND @requestEndDate IS NOT NULL)
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2178 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=2178)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+ CONVERT(VARCHAR,ISNULL(@userId,'0'))+','+ ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')+','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
	   END
	   ELSE IF(@orgId != 0 AND @userId != '' AND @requestStartDate IS NOT NULL) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2192 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2192)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) +','+ CONVERT(VARCHAR,ISNULL(@userId,'0'))+','+ ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@orgId != 0 AND @userId != '' AND @requestEndDate IS NOT NULL ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2193 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2193)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) +','+ CONVERT(VARCHAR,ISNULL(@userId,'0'))+','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
	   END
	   ELSE IF(@orgId != 0 AND @requestStartDate IS NOT NULL AND @requestEndDate IS NOT NULL )
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2194 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2194)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) +','+ ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')+','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@userId != '' AND @requestStartDate IS NOT NULL AND @requestEndDate IS NOT NULL) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2195 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2195)+ CONVERT(VARCHAR,ISNULL(@userId,'0')) +','+ ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')+','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@userId != '' AND @orgId != '0'  ) 
	   BEGIN
	
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2186 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2186)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) +','+ CONVERT(VARCHAR,ISNULL(@userId,'0'))  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@userId != '' AND @requestStartDate IS NOT NULL  ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2189 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2189)+ CONVERT(VARCHAR,ISNULL(@userId,'0')) +','+ ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	  ELSE IF(@userId != '' AND @requestEndDate IS NOT NULL ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2190 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2190)+ CONVERT(VARCHAR,ISNULL(@userId,'0')) +','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@orgId != 0 AND @requestStartDate IS NOT NULL  ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2187 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode=2187)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) +','+ ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@orgId != 0 AND @requestEndDate IS NOT NULL  ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2188 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2188)+ CONVERT(VARCHAR,ISNULL(@orgId,'0')) +','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@requestStartDate IS NOT NULL AND @requestEndDate IS NOT NULL   ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2191 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2191)+ ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30') +','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@orgId != 0 ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2182 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode=2182)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@userId != '' ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2183 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2183) + CONVERT(VARCHAR,ISNULL(@userId,'0'))  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@requestStartDate IS NOT NULL  ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2184 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode=2184)+ ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	   ELSE IF(@requestEndDate IS NOT NULL ) 
	   BEGIN
			SELECT '<list>'+(SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData','0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2185 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode=2185) + ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')  AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		
	END
	ELSE IF(@accessLevel = 1 OR @accessLevel = 2 OR @accessLevel = 3 OR @accessLevel = 4)
	BEGIN
		IF(@orgId != 0 AND @userId != '' )
	    BEGIN
		SELECT '<list>'+(
			SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
			'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData','400|2177 '+(SELECT DESCRIPTION +'|' + FieldName +'->'  FROM dbo.tblErrorLog WHERE ErrorCode=2177) + CONVERT(VARCHAR,ISNULL(@orgId,'0')) +','+ CONVERT(VARCHAR,ISNULL(@userId,'0'))  AS 'ErrId'
			FOR XML RAW )+'</list>'
		RETURN;
		END
	END
	--/*Summary: cellPhone only passed */
	--IF(@cellPhone != '' AND (@orgId = 0 OR @userId = '' OR @requestStartDate IS NULL OR @requestEndDate IS NULL))
	--BEGIN
	--	SELECT '<list>'+(
	--		SELECT DC.UserId AS 'UserId',DC.RequestDate AS 'RequestDate',DC.CellPhone AS 'CellPhone',DC.CallHomeData AS 'CallHomeData',
	--		DC.CallHomeURL AS 'CallHomeURL',DC.CallHomeTimeoutValue AS 'CallHomeTimeoutValue',DC.RedemptionData AS 'RedemptionData',
	--		DC.MetaData AS 'MetaData','0'  AS 'ErrId'
	--		FROM dbo.tblDynamicCode DC WHERE DC.CellPhone = @cellPhone
	--	FOR XML RAW )+'</list>'
	--	RETURN;
	--END
	
	IF(@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8)
	BEGIN
		IF(@orgId != 0)
		BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
			'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData',
			'400|2174 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2174) + CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId'
			FOR XML RAW )+'</list>'
			RETURN;
		END
		--ELSE IF (@orgId = 0)
		--BEGIN
		--	SET @orgId = (SELECT S.OrgId FROM tblSession S WHERE S.SessionKey = @sessionKey)
		--END
	END
		
	/*Summary: Check if @orgid is passed or not */
	IF(@orgId != 0 AND @userId = '')
	BEGIN
		--IF(@userId != '')
		--BEGIN
		--	SELECT '<list>'+(
		--	SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
		--	'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
		--	'0' AS 'MetaData',
		--	'400|2204 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2204) + CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId'
		--	FOR XML RAW )+'</list>'
		--	RETURN;
		--END
		--ELSE
		--BEGIN
		/*Summary: Check if passed @orgid have a match in organization table or not */
		IF EXISTS(SELECT 1 FROM dbo.tblOrganization WITH(NOLOCK) WHERE OrgId=@orgId)
		BEGIN
	--ups_DynamicCode '6B05DB6DC930458646C3F560481C38E61E233789',null,5,null,'1/1/1900 11:11:11AM +05:30','1/1/1900 11:11:11AM +05:30'
	
			IF((@accessLevel = 1 OR @accessLevel = 2) OR
			((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O WITH(NOLOCK) INNER JOIN dbo.tblSession S  WITH(NOLOCK) ON O.Owner = S.OrgId WHERE S.SessionKey = @sessionKey AND O.OrgId = @orgId ))) OR
			(((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND ( EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O WITH(NOLOCK) INNER JOIN dbo.tblSession S WITH(NOLOCK) ON S.OrgId = @orgId WHERE S.SessionKey = @sessionKey AND O.OrgId = @orgId )))))
			BEGIN
				IF(@accessLevel = 3 OR @accessLevel = 4)
				BEGIN
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate AND @requestEndDate */
				SET	@deviceScan= 'SELECT DC.UserId,DC.RequestDate,DC.CellPhone,DC.CallHomeData,DC.CallHomeURL,DC.CallHomeTimeoutValue,DC.RedemptionData,DC.MetaData FROM dbo.tblDynamicCode DC WITH(NOLOCK) 
				JOIN dbo.tblUser U WITH(NOLOCK) ON DC.UserId=U.UserId JOIN dbo.tblOrganization O ON 
				O.OrgId=U.OrgId INNER JOIN dbo.tblSession S ON O.Owner = S.OrgId  WHERE 1=1 AND O.OrgId = '''+
				CONVERT(VARCHAR,@orgId)+''' AND S.SessionKey = '''+@sessionKey+''''
				
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate AND @requestEndDate */
				IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') != '')
					SET	@deviceScan=@deviceScan + 'AND DC.RequestDate between '''+ CONVERT(CHAR(33),@requestStartDate,126) +''' AND '''+ CONVERT(CHAR(33),@requestEndDate,126)+''''
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate only */
				ELSE IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') = '')
					SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate >= '''+  CONVERT(CHAR(33),@requestStartDate,126) +''''
				/* Summary: Filter the DeviceScan[scanDate] record using @requestEndDate only */
				ELSE IF(ISNULL(@requestStartDate,'') = '' AND ISNULL(@requestEndDate,'') != '')
					SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate <= '''+ CONVERT(CHAR(33),@requestEndDate,126) +''''
				/* Summary: Retrieve all DeviceScan[scanDate] record using @orgId */
				END
				ELSE
				BEGIN
				SET	@deviceScan= 'SELECT DC.UserId,DC.RequestDate,DC.CellPhone,DC.CallHomeData,DC.CallHomeURL,DC.CallHomeTimeoutValue,DC.RedemptionData,
				DC.MetaData FROM dbo.tblDynamicCode DC WITH(NOLOCK) JOIN dbo.tblUser U WITH(NOLOCK) ON DC.UserId=U.UserId 
				WHERE 1=1 AND U.OrgId = '''+CONVERT(VARCHAR,@orgId)+'''' 
				
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate AND @requestEndDate */
				IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') != '')
					SET	@deviceScan=@deviceScan + 'AND DC.RequestDate between '''+CONVERT(CHAR(33),@requestStartDate,126) +''' AND '''+ CONVERT(CHAR(33),@requestEndDate,126)+''''
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate only */
				ELSE IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') = '')
					SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate >= '''+ CONVERT(CHAR(33),@requestStartDate,126)+''''
				/* Summary: Filter the DeviceScan[scanDate] record using @requestEndDate only */
				ELSE IF(ISNULL(@requestStartDate,'') = '' AND ISNULL(@requestEndDate,'') != '')
					SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate <= '''+ CONVERT(CHAR(33),@requestEndDate,126) +''''
				/* Summary: Retrieve all DeviceScan[scanDate] record using @orgId */
				END
				
				
					
				INSERT INTO #DeviceScan EXEC Sp_executeSQL @deviceScan
				IF(Exists(Select 1 From #DeviceScan))
				BEGIN
				SELECT '<list>'+(
				
					SELECT ISNULL(D.UserId,'NULL') AS 'UserId',ISNULL(CONVERT(CHAR(33),D.RequestDate,126),'1/1/1900 11:11:11AM +05:30') AS 'RequestDate',ISNULL(D.CellPhone,'NULL') AS 'CellPhone',ISNULL(D.CallHomeData,'NULL') AS 'CallHomeData',
				    ISNULL(D.CallHomeURL,'NULL') AS 'CallHomeURL',ISNULL(D.CallHomeTimeoutValue,'0') AS 'CallHomeTimeoutValue',ISNULL(D.RedemptionData,'NULL') AS 'RedemptionData',
				     ISNULL(D.MetaData,'NULL') AS 'MetaData','0'  AS 'ErrId'
					--SELECT D.UserId AS 'UserId',D.RequestDate AS 'RequestDate',D.CellPhone AS 'CellPhone',D.CallHomeData AS 'CallHomeData',
					--D.CallHomeURL AS 'CallHomeURL',D.CallHomeTimeoutValue AS 'CallHomeTimeoutValue',D.RedemptionData AS 'RedemptionData',
					--D.MetaData AS 'MetaData','0'  AS 'ErrId'
					FROM #DeviceScan D
				FOR XML RAW )+'</list>'
				RETURN;
				END
				ELSE
				BEGIN
					SET @errValue='';
					IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') != '')
					BEGIN
					SET @errCode=2199
					SET @errValue= @errValue + ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30') +','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')
					END
				    ELSE IF(ISNULL(@requestStartDate,'') = '' AND ISNULL(@requestEndDate,'') != '')
				    BEGIN
				    SET @errCode=2198
				       SET @errValue= @errValue + ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')
				    END
					ELSE IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') = '') 
					BEGIN
					SET @errCode=2197
					SET @errValue= @errValue +  ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')
					END
					ELSE 
					BEGIN
					SET @errCode=2180
					SET @errValue= @errValue + CONVERT(VARCHAR,ISNULL(@orgId,'NULL')) 
					END
					SELECT '<list>'+(
					SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
					'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData','0' AS 'MetaData',
				    '400|' +CONVERT(VARCHAR,@errCode)+' '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=@errCode)+ @errValue  AS 'ErrId'
					FOR XML RAW )+'</list>'
					RETURN;
				END
			END
			ELSE
			BEGIN
				SELECT '<list>'+(
			SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
			'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData',
			'401|2174 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2174) + CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId'
			FOR XML RAW )+'</list>'
			RETURN;
			END
		END
		ELSE
			BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
			'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData',
			'400|2175'+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2175) + CONVERT(VARCHAR,ISNULL(@orgId,'0')) AS 'ErrId'
			FOR XML RAW )+'</list>'
			RETURN;
			END

	END
	
	/*Summary: Check if @userId is passed or not*/
	IF(@userId != '')
	BEGIN
		--IF(@orgId != 0)
		--BEGIN
		--	SELECT '<list>'+(
		--	SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
		--	'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
		--	'0' AS 'MetaData',
		--	'400|2177 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2177) + CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@userId,'0')) AS 'ErrId'
		--	FOR XML RAW )+'</list>'
		--	RETURN;
		--END
		--ELSE
		--BEGIN
		/*Summary: Check if passed @userId have a match in organization table or not */
		IF EXISTS(SELECT 1 FROM dbo.tblDynamicCode WITH(NOLOCK) WHERE UserId=@userId)
		BEGIN
			SET	@deviceScan= 'SELECT DC.UserId,DC.RequestDate,DC.CellPhone,DC.CallHomeData,DC.CallHomeURL,DC.CallHomeTimeoutValue,DC.RedemptionData,
			DC.MetaData FROM dbo.tblDynamicCode DC WITH(NOLOCK)
			WHERE 1=1 AND DC.UserId = '''+CONVERT(VARCHAR,@userId)+'''' 
				
			/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate AND @requestEndDate */
			IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') != '')
				SET	@deviceScan=@deviceScan + 'AND DC.RequestDate between '''+CONVERT(CHAR(33),@requestStartDate,126) +''' AND '''+ CONVERT(CHAR(33),@requestEndDate,126)+''''
			/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate only */
			ELSE IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') = '')
				SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate >= '''+ CONVERT(CHAR(33),@requestStartDate,126)+''''
			/* Summary: Filter the DeviceScan[scanDate] record using @requestEndDate only */
			ELSE IF(ISNULL(@requestStartDate,'') = '' AND ISNULL(@requestEndDate,'') != '')
				SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate <= '''+ CONVERT(CHAR(33),@requestEndDate,126) +''''
			/* Summary: Retrieve all DeviceScan[scanDate] record using @orgId */
			
			
				
			INSERT INTO #DeviceScan EXEC Sp_executeSQL @deviceScan
			IF(Exists(Select 1 From #DeviceScan))
			BEGIN
			SELECT '<list>'+(
				SELECT ISNULL(D.UserId,'NULL') AS 'UserId',ISNULL(CONVERT(CHAR(33),D.RequestDate,126),'1/1/1900 11:11:11AM +05:30') AS 'RequestDate',ISNULL(D.CellPhone,'NULL') AS 'CellPhone',ISNULL(D.CallHomeData,'NULL') AS 'CallHomeData',
				ISNULL(D.CallHomeURL,'NULL') AS 'CallHomeURL',ISNULL(D.CallHomeTimeoutValue,'0') AS 'CallHomeTimeoutValue',ISNULL(D.RedemptionData,'NULL') AS 'RedemptionData',
				ISNULL(D.MetaData,'NULL') AS 'MetaData','0'  AS 'ErrId'
				FROM #DeviceScan D
			    FOR XML RAW )+'</list>'
			    RETURN;
			END
			ELSE
			BEGIN
					SET @errValue=''
					IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') != '')	
					BEGIN
					 SET @errCode=2199
					 SET @errValue= @errValue + ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30') +','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')
					END
				    ELSE IF(ISNULL(@requestStartDate,'') = '' AND ISNULL(@requestEndDate,'') != '')
				    BEGIN
				    SET @errCode=2198
				    SET @errValue= @errValue + ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')
				    END
					ELSE IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') = '')
					BEGIN
					 SET @errCode=2197
					 SET @errValue= @errValue + ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')
					END 
					ELSE  
					BEGIN
					 SET @errCode=2181
					 SET @errValue= @errValue + CONVERT(VARCHAR,ISNULL(@userId,'NULL')) 
					END 
					
				    SELECT '<list>'+(
					SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
					'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData','0' AS 'MetaData',
				    '400|' +CONVERT(VARCHAR,@errCode)+' '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=@errCode)  AS 'ErrId'
					FOR XML RAW )+'</list>'
					RETURN;
			END
		END
		ELSE
		BEGIN
		    SELECT '<list>'+(
			SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
			'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData',
			'400|2181 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2181) + CONVERT(VARCHAR,ISNULL(@userId,'0')) AS 'ErrId'
			FOR XML RAW )+'</list>'
			RETURN;
		END	
		END
	
	
	IF(@userId = '' AND @orgId = 0)
	BEGIN
		DECLARE @sessOrg AS INT;
		SELECT @sessOrg = OrgId FROM dbo.tblSession WHERE SessionKey = @sessionKey
	
		/*Summary: Check if passed @userId have a match in organization table or not */
		IF EXISTS(SELECT 1 FROM dbo.tblOrganization WITH(NOLOCK) WHERE OrgId=@sessOrg)
		BEGIN
			IF((@accessLevel = 1 OR @accessLevel = 2) OR
			((@accessLevel = 3 OR @accessLevel = 4) AND (EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O WITH(NOLOCK) INNER JOIN dbo.tblSession S  WITH(NOLOCK) ON O.Owner = S.OrgId WHERE S.SessionKey = @sessionKey AND S.OrgId = @sessOrg ))) OR
			(((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND ( EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O WITH(NOLOCK) INNER JOIN dbo.tblSession S WITH(NOLOCK) ON S.OrgId = @sessOrg WHERE S.SessionKey = @sessionKey AND O.OrgId = @sessOrg )))))
			BEGIN
				IF(@accessLevel = 3 OR @accessLevel = 4)
				BEGIN
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate AND @requestEndDate */
				
				SET	@deviceScan= 'SELECT DC.UserId,DC.RequestDate,DC.CellPhone,DC.CallHomeData,DC.CallHomeURL,DC.CallHomeTimeoutValue,DC.RedemptionData,DC.MetaData FROM dbo.tblDynamicCode DC WITH(NOLOCK) 
				JOIN dbo.tblUser U WITH(NOLOCK) ON DC.UserId=U.UserId JOIN dbo.tblOrganization O ON 
				O.OrgId=U.OrgId INNER JOIN dbo.tblSession S ON O.Owner = S.OrgId  WHERE 1=1 AND O.OrgId = '''+
				CONVERT(VARCHAR,@sessOrg)+''' AND S.SessionKey = '''+@sessionKey+''''
				
				--SET @deviceScan= 'SELECT DC.IntSerial,DC.ScanData,DC.ScanDate FROM dbo.tblInterceptor I WITH(NOLOCK) JOIN dbo.tblDeviceScan D WITH(NOLOCK) ON DC.IntSerial=I.IntSerial JOIN dbo.tblOrganization O ON O.OrgId=I.OrgId INNER JOIN dbo.tblSession S ON O.Owner = S.OrgId  WHERE 1=1 AND I.OrgId = '''+CONVERT(VARCHAR,@sessOrg)+''' AND S.SessionKey = '''+@sessionKey+''''
				IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') != '')
					SET	@deviceScan=@deviceScan + 'AND DC.RequestDate between '''+ CONVERT(CHAR(33),@requestStartDate,126) +''' AND '''+ CONVERT(CHAR(33),@requestEndDate,126)+''''
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate only */
				ELSE IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') = '')
					SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate >= '''+  CONVERT(CHAR(33),@requestStartDate,126) +''''
				/* Summary: Filter the DeviceScan[scanDate] record using @requestEndDate only */
				ELSE IF(ISNULL(@requestStartDate,'') = '' AND ISNULL(@requestEndDate,'') != '')
					SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate <= '''+ CONVERT(CHAR(33),@requestEndDate,126) +''''
				/* Summary: Retrieve all DeviceScan[scanDate] record using @sessOrg */
				END
				ELSE
				BEGIN
				SET	@deviceScan= 'SELECT DC.UserId,DC.RequestDate,DC.CellPhone,DC.CallHomeData,DC.CallHomeURL,DC.CallHomeTimeoutValue,DC.RedemptionData,
				DC.MetaData FROM dbo.tblDynamicCode DC WITH(NOLOCK) JOIN dbo.tblUser U WITH(NOLOCK) ON DC.UserId=U.UserId 
				WHERE 1=1 AND U.OrgId = '''+CONVERT(VARCHAR,@sessOrg)+'''' 
				
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate AND @requestEndDate */
				IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') != '')
					SET	@deviceScan=@deviceScan + 'AND DC.RequestDate between '''+CONVERT(CHAR(33),@requestStartDate,126) +''' AND '''+ CONVERT(CHAR(33),@requestEndDate,126)+''''
				/* Summary: Filter the DeviceScan[scanDate] record using @requestStartDate only */
				ELSE IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') = '')
					SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate >= '''+ CONVERT(CHAR(33),@requestStartDate,126)+''''
				/* Summary: Filter the DeviceScan[scanDate] record using @requestEndDate only */
				ELSE IF(ISNULL(@requestStartDate,'') = '' AND ISNULL(@requestEndDate,'') != '')
					SET	@deviceScan=@deviceScan+ ' AND DC.RequestDate <= '''+ CONVERT(CHAR(33),@requestEndDate,126) +''''
				/* Summary: Retrieve all DeviceScan[scanDate] record using @sessOrg */
				END
				--print @deviceScan
				
					
				INSERT INTO #DeviceScan EXEC Sp_executeSQL @deviceScan
				--select * from #DeviceScan
				IF(Exists(Select 1 From #DeviceScan))
			    BEGIN
				   SELECT '<list>'+(
					SELECT ISNULL(D.UserId,'NULL') AS 'UserId',ISNULL(CONVERT(CHAR(33),D.RequestDate,126),'1/1/1900 11:11:11AM +05:30') AS 'RequestDate',ISNULL(D.CellPhone,'NULL') AS 'CellPhone',ISNULL(D.CallHomeData,'NULL') AS 'CallHomeData',
			     	ISNULL(D.CallHomeURL,'NULL') AS 'CallHomeURL',ISNULL(D.CallHomeTimeoutValue,'0') AS 'CallHomeTimeoutValue',ISNULL(D.RedemptionData,'NULL') AS 'RedemptionData',
				   ISNULL(D.MetaData,'NULL') AS 'MetaData','0'  AS 'ErrId'
					--SELECT D.UserId AS 'UserId',D.RequestDate AS 'RequestDate',D.CellPhone AS 'CellPhone',D.CallHomeData AS 'CallHomeData',
					--D.CallHomeURL AS 'CallHomeURL',D.CallHomeTimeoutValue AS 'CallHomeTimeoutValue',D.RedemptionData AS 'RedemptionData',
					--D.MetaData AS 'MetaData','0'  AS 'ErrId'
					FROM #DeviceScan D
				   FOR XML RAW )+'</list>'
				   RETURN;
				END
				ELSE
				BEGIN
					SET @errValue=''
					IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') != '')	
					BEGIN
					SET @errCode=2199
					SET @errValue= @errValue + ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30') +','+ ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30')
					END
				    ELSE IF(ISNULL(@requestStartDate,'') = '' AND ISNULL(@requestEndDate,'') != '')
				    BEGIN
				     SET @errCode=2198
				     SET @errValue= @errValue + ISNULL(CONVERT(CHAR(33),@requestEndDate,126),'1/1/1900 11:11:11AM +05:30') 
				    END
					ELSE IF(ISNULL(@requestStartDate,'') != '' AND ISNULL(@requestEndDate,'') = '') 
					BEGIN
					SET @errCode=2197
					SET @errValue= @errValue + ISNULL(CONVERT(CHAR(33),@requestStartDate,126),'1/1/1900 11:11:11AM +05:30')
					END
					ELSE   
					BEGIN
					SET @errCode=2180
					SET @errValue= @errValue + CONVERT(VARCHAR,ISNULL(@sessOrg,'NULL')) 
					END
						
					SELECT '<list>'+(
					SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
					'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData','0' AS 'MetaData',
				    '400|' +CONVERT(VARCHAR,@errCode)+' '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=@errCode) + @errValue AS 'ErrId'
					FOR XML RAW )+'</list>'
					RETURN;
				END   
			END
			ELSE
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
				'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'ptiRedemonData',
				'0' AS 'MetaData',
				'401|2174'+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2174) + CONVERT(VARCHAR,ISNULL(@accessLevel ,'0')) AS 'ErrId'
				FOR XML RAW )+'</list>'
				RETURN;
			END
		END
		ELSE
		BEGIN
			SELECT '<list>'+(
			SELECT '0' AS 'UserId','1/1/1900 11:11:11AM +05:30' AS 'RequestDate','0' AS 'CellPhone','0' AS 'CallHomeData',
			'0' AS 'CallHomeURL','0' AS 'CallHomeTimeoutValue','0' AS 'RedemptionData',
			'0' AS 'MetaData',
			'400|2175'+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WITH(NOLOCK) WHERE ErrorCode=2175) + CONVERT(VARCHAR,ISNULL(@sessOrg,'0')) AS 'ErrId'
			FOR XML RAW )+'</list>'
			RETURN;
		END
	END
END
--ups_DynamicCode '6B05DB6DC930458646C3F560481C38E61E233D47',null,NULL,null,'2013-07-30 16:26:32.4985603 +05:30','2013-07-30 16:26:32.4985603 +05:30'

GO
/****** Object:  StoredProcedure [dbo].[ups_ICmd]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================
-- Author:		Dineshkumar G	
-- Create date: 12.07.2013
-- Routine:		ICmd
-- Method:		Get
-- DESCRIPTION:	handles HTTP requests from Interceptor devices that checking for
-- commands issued by the API (commands stored in CmdQueue)
-- =======================================================================================
CREATE PROCEDURE [dbo].[ups_ICmd]

	@i AS VARCHAR(12)
	
AS
BEGIN
	SET NOCOUNT ON;
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	
	DECLARE @ReturnResult AS INT
	/* Summary:Raise an Error Message,If intSerial is not passed */
	IF(ISNULL(@i,'')='')
	BEGIN
		SET @ReturnResult = 400 SELECT @ReturnResult AS Returnvalue
	    EXEC upi_SystemEvents 'ICmd',2901,3,''
		RETURN;	
	END	
	/* Summary:Raise an Error Message,If intSerial is passed, matching tblCmdQueue record is not found */
	ELSE IF NOT EXISTS(SELECT IntSerial FROM dbo.tblInterceptor WHERE IntSerial=@i)
	BEGIN
		SET @ReturnResult = 400 SELECT @ReturnResult AS Returnvalue
	    EXEC upi_SystemEvents 'ICmd',2902,3,@i
		RETURN;	
	END
	 
	IF EXISTS(SELECT 1 FROM dbo.tblCmdQueue WHERE IntSerial=@i)
	BEGIN
		SET @ReturnResult =(SELECT top 1 Cmd FROM dbo.tblCmdQueue WHERE IntSerial=@i)
		SELECT @ReturnResult AS Returnvalue
		DELETE FROM dbo.tblCmdQueue WHERE IntSerial=@i
		EXEC upi_SystemEvents 'ICmd',0,1,@ReturnResult
		RETURN;	
	END
	ELSE
	BEGIN
		SET @ReturnResult =0 SELECT @ReturnResult AS Returnvalue
		EXEC upi_SystemEvents 'ICmd',0,1,@i
		RETURN;	
	END

	
END
--[ups_ICmd] A1


GO
/****** Object:  StoredProcedure [dbo].[ups_Interceptor]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prakash G
-- Create date: 24.05.2013
-- Routine:		Interceptor
-- Method:		GET
-- Description:	Retrieve Interceptor records

-- 2015-07-03 Kludge support for VarAdminRW access to same fields as admin RW. VERY KLUDGY. Meant as a stop gap.
-- =============================================
CREATE PROCEDURE [dbo].[ups_Interceptor]

	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgId				AS INT,	
	@locId				AS INT,	
	@intID				AS INT,	
	@intSerial			AS VARCHAR(12)
	
	AS
	BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @recorded used to get current activity id.
		
	DECLARE @ReturnResult	AS VARCHAR(100)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @date			AS DATETIMEOFFSET(7)
	DECLARE @accessLevel	AS INT
	DECLARE	@recorded		AS VARCHAR(50)
	
	SET @date			= SYSDATETIMEOFFSET();
	SET @UserId			= (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	SET @accessLevel	= (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	
	IF(ISNULL(@orgId,0)=0)SET @orgId = 0
	IF(ISNULL(@locId,0)=0)SET @locId = 0
	IF(ISNULL(@intID,0)=0)SET @intID = 0
	IF(ISNULL(@intSerial,'')='')SET @intSerial = ''
 
		/* Summary: Check whether locid,intID,intSerail are passed or not */
		IF(@locId=0 AND @intID = 0 AND @intSerial='')  
		BEGIN
				/* Summary: Check whether orgId = -1. If it is true select all Interceptor record from Interceptor table */
				IF(@orgId = -1)
				BEGIN
					IF(@accessLevel = 1 or @accessLevel = 2)
					BEGIN
						SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId)FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial JOIN dbo.tblOrganization O on t.OrgId=O.OrgId JOIN dbo.tblLocation L on t.OrgId=L.OrgId AND t.LocId=l.LocId WHERE t.orgid=@orgid
						SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
						ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
						ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc',ISNULL(CONVERT(VARCHAR,t.[Security]),'NULL') AS 'Security',ISNULL(i.embeddedID,'NULL') AS 'embeddedID',ISNULL(t.startURL,'NULL') AS 'startURL',ISNULL(t.ReportURL,'NULL') AS 'ReportURL',ISNULL(t.ScanURL,'NULL') AS 'ScanURL',ISNULL(t.BkupURL,'NULL') AS 'BkupURL',ISNULL(CONVERT(VARCHAR,t.RequestTimeoutValue),'NULL') AS 'RequestTimeoutValue',ISNULL(t.WpaPSK,'NULL') AS 'WpaPSK',ISNULL(t.SSId,'NULL') AS 'SSId',ISNULL(CONVERT(VARCHAR,t.MaxBatchWaitTime),'NULL') AS 'MaxBatchWaitTime',ISNULL(CONVERT(VARCHAR,t.cmdChkInt),'NULL') AS 'cmdChkInt','0|accesslevel|'+ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' 
						FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial
						JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
						JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
						FOR XML RAW )+'</list>'	
						RETURN;
					END
				END
				/* Summary: Check whether orgId is passed or not */
				IF(@orgId <> 0)
			  	BEGIN
			  	/* Summary:If orgId passed use it to get Organization record */
			  	  IF EXISTS(SELECT 1 FROM dbo.[tblorganization] WITH (NOLOCK) WHERE orgid=@orgId )
					BEGIN
					/* Summary: use the orgId to find matching Interceptor records */
					   IF EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WITH (NOLOCK) WHERE orgid=@orgId )
							BEGIN
								/*Summary:Check if the user is authorized to make this request. */
						         /*Summary: If the accessLevel is SysAdminRW, then the following fields are returned */
						        --exec ups_Interceptor '4A79DB236006635250C7470729F1BFA30DE691D7','6B05DB6DC930458646C3F560481C38E61E233D47',-1,0,0,'' 
						       	IF(@accessLevel = 1 OR ((@accessLevel = 3 ) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))))
									BEGIN
									    SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId)FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial JOIN dbo.tblOrganization O on t.OrgId=O.OrgId JOIN dbo.tblLocation L on t.OrgId=L.OrgId AND t.LocId=l.LocId WHERE t.orgid=@orgid
										SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
										ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
										ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc',ISNULL(CONVERT(VARCHAR,t.[Security]),'NULL') AS 'Security',ISNULL(i.embeddedID,'NULL') AS 'embeddedID',ISNULL(t.startURL,'NULL') AS 'startURL',ISNULL(t.ReportURL,'NULL') AS 'ReportURL',ISNULL(t.ScanURL,'NULL') AS 'ScanURL',ISNULL(t.BkupURL,'NULL') AS 'BkupURL',ISNULL(CONVERT(VARCHAR,t.RequestTimeoutValue),'NULL') AS 'RequestTimeoutValue',ISNULL(t.WpaPSK,'NULL') AS 'WpaPSK',ISNULL(t.SSId,'NULL') AS 'SSId',ISNULL(CONVERT(VARCHAR,t.MaxBatchWaitTime),'NULL') AS 'MaxBatchWaitTime',ISNULL(CONVERT(VARCHAR,t.cmdChkInt),'NULL') AS 'cmdChkInt','0|accesslevel|1' AS 'ErrId' FROM dbo.tblinterceptor t 
										INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial
										JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
										JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
										 WHERE t.orgid=@orgid FOR XML RAW )+'</list>'		
										UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
										EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
										RETURN;
									 END
								ELSE
								/* Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of Location[OrgId]*/
								/* Summary: If accessLevel is OrgAdminRW or OrgUserRW, then check if Session[OrgId] is the same asLocation[OrgId]*/
								IF((@accessLevel = 2 ) OR (( @accessLevel = 4) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.owner = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))) OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT o.orgId FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey and o.orgId=@orgId))))
									BEGIN
										 SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId)FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial JOIN dbo.tblOrganization O on t.OrgId=O.OrgId JOIN dbo.tblLocation L on t.OrgId=L.OrgId AND t.LocId=l.LocId WHERE t.orgid=@orgid
										 SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
										 ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
										 ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','0|accesslevel|'+ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' FROM dbo.tblinterceptor t 
										 INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial
										 JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
										 JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
										 WHERE t.orgid=@orgid FOR XML RAW )+'</list>'	
										 UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
										 EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
										 RETURN;
									END
								ELSE
								/* Summary:Raise an Error Message. If user is not within scope*/	
									BEGIN
										SELECT '<list>'+ (SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat', '0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','401|1703 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1703) + CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
										EXEC upi_SystemEvents 'Interceptor',1703,3,@accessLevel
										RETURN;
									END
							  END
							  /* Summary:Raise an Error Message, If Interceptor record is not found for the given orgdid in the Interceptor table */
							 ELSE
						     BEGIN
								 SELECT '<list>'+ (SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','ErrorLog' AS '0','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1708 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1708)+CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
								 RETURN;
							END	
						END 
						/* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */	
						ELSE
						BEGIN
						    SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1709 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1709)+CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
							EXEC upi_SystemEvents 'Interceptor',1709,3,@orgId
							RETURN;
						END
					END
					 /* Summary:Raise an Error Message.If none of field Passed */
					ELSE
					BEGIN 
					      SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1702 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=1702) AS 'ErrId' FOR XML RAW )+'</list>'
						  RETURN;
				    END
		END
		/* Summary:If locId is passed, search for the Location record */
		ELSE IF(@orgId = 0 AND  @intID= 0 AND @intSerial ='' )
		BEGIN
			IF(@locId <> 0)
				BEGIN
					/* Summary:if locid  use it to get all matching Location records */
					IF EXISTS(SELECT 1 FROM dbo.[tblLocation] WITH (NOLOCK) WHERE locId = @locId )
			    	BEGIN
						/* Summary:if locid  use it to get all matching Interceptor records*/
						IF EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WITH (NOLOCK) WHERE locId=@locId )
						BEGIN
								/* Summary :Check if the user is authorized to make this request.
								Summary :If the accessLevel is SysAdminRW, then the following fields are returned */
								IF(@accessLevel = 1)
								BEGIN
									SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId)FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial JOIN dbo.tblOrganization O on t.OrgId=O.OrgId JOIN dbo.tblLocation L on t.OrgId=L.OrgId AND t.LocId=l.LocId WHERE t.locId=@locId
									SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
									ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
									ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc',ISNULL(CONVERT(VARCHAR,t.[Security]),'NULL') AS 'Security',ISNULL(i.embeddedID,'NULL') AS 'embeddedID',ISNULL(t.startURL,'NULL') AS 'startURL',ISNULL(t.ReportURL,'NULL') AS 'ReportURL',ISNULL(t.ScanURL,'NULL') AS 'ScanURL',ISNULL(t.BkupURL,'NULL') AS 'BkupURL',ISNULL(CONVERT(VARCHAR,t.RequestTimeoutValue),'NULL') AS 'RequestTimeoutValue',ISNULL(t.WpaPSK,'NULL') AS 'WpaPSK',ISNULL(t.SSId,'NULL') AS 'SSId',ISNULL(CONVERT(VARCHAR,t.MaxBatchWaitTime),'NULL') AS 'MaxBatchWaitTime',ISNULL(CONVERT(VARCHAR,t.cmdChkInt),'NULL') AS 'cmdChkInt','0|accesslevel|'+ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' FROM dbo.tblinterceptor t 
									INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial 
									JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
									JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
									WHERE t.locId=@locId FOR XML RAW )+'</list>'			
								 						           
									UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
									EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
									RETURN;
								END
						    ELSE
						    /* Summary :If the accessLevel is SysAdminRO, then the following fields are returned */
						    IF(@accessLevel = 2 ) 
								BEGIN
									SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId)FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial JOIN dbo.tblOrganization O on t.OrgId=O.OrgId JOIN dbo.tblLocation L on t.OrgId=L.OrgId AND t.LocId=l.LocId WHERE t.locId=@locId 
									SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
									ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
									ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','0|accesslevel|'+ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' FROM dbo.tblinterceptor t 
									JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
									JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
									INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial 
									WHERE t.locId=@locId FOR XML RAW )+'</list>'	
								
									UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
									EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
									RETURN;
								END
							ELSE
							/* Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of Location[OrgId] then the following fields are returned */
							 
							IF((@accessLevel = 3 ) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid =@locId  and s.sessionkey=@sessionKey))) 
							BEGIN
								SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId)FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial JOIN dbo.tblOrganization O on t.OrgId=O.OrgId JOIN dbo.tblLocation L on t.OrgId=L.OrgId AND t.LocId=l.LocId WHERE t.locId=@locId and t.Orgid=(SELECT TOP 1 O.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid =@locId  and s.sessionkey=@sessionKey)
									SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
									ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
									ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc',ISNULL(CONVERT(VARCHAR,t.[Security]),'NULL') AS 'Security',ISNULL(i.embeddedID,'NULL') AS 'embeddedID',ISNULL(t.startURL,'NULL') AS 'startURL',ISNULL(t.ReportURL,'NULL') AS 'ReportURL',ISNULL(t.ScanURL,'NULL') AS 'ScanURL',ISNULL(t.BkupURL,'NULL') AS 'BkupURL',ISNULL(CONVERT(VARCHAR,t.RequestTimeoutValue),'NULL') AS 'RequestTimeoutValue',ISNULL(t.WpaPSK,'NULL') AS 'WpaPSK',ISNULL(t.SSId,'NULL') AS 'SSId',ISNULL(CONVERT(VARCHAR,t.MaxBatchWaitTime),'NULL') AS 'MaxBatchWaitTime',ISNULL(CONVERT(VARCHAR,t.cmdChkInt),'NULL') AS 'cmdChkInt','0|accesslevel|1' AS 'ErrId' FROM dbo.tblinterceptor t 
								JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
								JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
								INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial 
								WHERE t.locId=@locId and t.Orgid=(SELECT TOP 1 O.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid =@locId  and s.sessionkey=@sessionKey) FOR XML RAW )+'</list>'	
								
								UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
								EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
							END
							IF((@accessLevel = 4) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid =@locId  and s.sessionkey=@sessionKey))) 
							BEGIN
								SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId)FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial JOIN dbo.tblOrganization O on t.OrgId=O.OrgId JOIN dbo.tblLocation L on t.OrgId=L.OrgId AND t.LocId=l.LocId WHERE t.locId=@locId and t.Orgid=(SELECT TOP 1 O.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid =@locId  and s.sessionkey=@sessionKey)

								SELECT '<list>'+ (SELECT t.IntId AS 'IntId',t.IntSerial AS 'IntSerial',
								ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
								ISNULL(t.ForwardURL,'0') AS 'ForwardURL',ISNULL(t.DeviceStatus,'0') AS 'DeviceStatus',ISNULL(t.Capture,'0') AS 'Capture',ISNULL(t.CaptureMode,'0') AS 'CaptureMode',ISNULL(t.CallHomeTimeoutMode,'0') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'0')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'0') AS 'DynCodeFormat',ISNULL(t.ErrorLog,'0') AS 'ErrorLog',ISNULL(t.ForwardType,'0') AS 'ForwardType',ISNULL(t.IntLocDesc,'0') AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','0|accesslevel|'+ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' FROM dbo.tblinterceptor t 
								JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
								JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
								INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial 
								WHERE t.locId=@locId and t.Orgid=(SELECT TOP 1 O.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid =@locId  and s.sessionkey=@sessionKey) FOR XML RAW )+'</list>'	
								
								UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
								EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
							END
							
							/* Summary: If accessLevel is OrgAdminRW or OrgUserRW, then check if Session[OrgId] is the same asLocation[OrgId] then the following fields are returned */
							ELSE IF((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND( EXISTS(SELECT l.orgId FROM dbo.[tblLocation] l INNER JOIN [tblSession] S on l.orgId =S.orgID INNER JOIN [tblOrganization] O ON l.orgId=O.orgId  WHERE S.sessionKey = @sessionKey and l.LocId=@LocId)))
							BEGIN
							     SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId)FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial JOIN dbo.tblOrganization O on t.OrgId=O.OrgId JOIN dbo.tblLocation L on t.OrgId=L.OrgId AND t.LocId=l.LocId WHERE t.locId=@locId and t.Orgid=(SELECT l.orgId FROM dbo.[tblLocation] l INNER JOIN [tblSession] S on l.orgId =S.orgID INNER JOIN [tblOrganization] O ON l.orgId=O.orgId  WHERE S.sessionKey = @sessionKey and l.LocId=@LocId)
								
								 SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
								 ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
								 ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','0|accesslevel|'+ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' FROM dbo.tblinterceptor t
								 JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
								 JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
								 INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial WHERE t.locId=@locId and t.Orgid=(SELECT l.orgId FROM dbo.[tblLocation] l INNER JOIN [tblSession] S on l.orgId =S.orgID INNER JOIN [tblOrganization] O ON l.orgId=O.orgId  WHERE S.sessionKey = @sessionKey and l.LocId=@LocId) FOR XML RAW )+'</list>'	
								
								 UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
								 EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
							END
							/* Summary:Raise an Error Message. If user is not within scope*/	
							ELSE
						    BEGIN
								SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','401|1703 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1703) + CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
								EXEC upi_SystemEvents 'Interceptor',1703,3,@accessLevel
								RETURN;
							END	
					END 
					
					/* Summary:Raise an Error Message, If Interceptor record is not found for the given Locid in the Interceptor table */
					ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1707 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1707)+CONVERT(VARCHAR,@locId) AS 'ErrId' FOR XML RAW )+'</list>'
						RETURN;
					END
					END	
			    	/* Summary: Raise an error message (400). If Location record is not found for the given Locid in the Location table. */	   
					ELSE
					BEGIN
				        SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1707 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1707)+CONVERT(VARCHAR,@locId) AS 'ErrId' FOR XML RAW )+'</list>'
						RETURN;
					END	
				END	
				/* Summary:Raise an Error Message.If none of field Passed */
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1702 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1702) AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END	
			END 
			/* Summary:if intID,intSerial  passed, search for the particular Interceptor record only */
			ELSE IF(@locId=0 AND @orgId = 0 )
			BEGIN
				IF(@intID <> 0 AND @intSerial <>'') 
				BEGIN	
					SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1719 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=1719) AS 'ErrId' FOR XML RAW )+'</list>'   
					RETURN;
				END
				ELSE
				IF(@intID <> 0 AND @intSerial='') 
				BEGIN
				/* Summary:if intID  use it to get  matching Interceptor record */
				IF (EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WITH (NOLOCK) WHERE intID=@intID))
		        BEGIN
		        /*Summary:If a matching Interceptorrecord  is found, use Interceptor[orgID] to check scope of user*/
		        /*Summary :If the accessLevel is SysAdminRW, then the following fields are returned*/
				IF(@accessLevel = 1 OR ((@accessLevel = 3) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId INNER JOIN tblinterceptor AS t  ON t.orgid=O.OrgId WHERE  s.sessionkey=@sessionKey AND t.intID=@intID  ))))
					BEGIN
								SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
								ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
								ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc',ISNULL(CONVERT(VARCHAR,t.[Security]),'NULL') AS 'Security',ISNULL(i.embeddedID,'NULL') AS 'embeddedID',ISNULL(t.startURL,'NULL') AS 'startURL',ISNULL(t.ReportURL,'NULL') AS 'ReportURL',ISNULL(t.ScanURL,'NULL') AS 'ScanURL',ISNULL(t.BkupURL,'NULL') AS 'BkupURL',ISNULL(CONVERT(VARCHAR,t.RequestTimeoutValue),'NULL') AS 'RequestTimeoutValue',ISNULL(t.WpaPSK,'NULL') AS 'WpaPSK',ISNULL(t.SSId,'NULL') AS 'SSId',ISNULL(CONVERT(VARCHAR,t.MaxBatchWaitTime),'NULL') AS 'MaxBatchWaitTime',ISNULL(CONVERT(VARCHAR,t.cmdChkInt),'NULL') AS 'cmdChkInt','0|accesslevel|1' AS 'ErrId' 
								FROM dbo.tblinterceptor t 
								JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
								JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
								INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial WHERE t.intID=@intID  FOR XML RAW )+'</list>'		
								
								UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
								EXEC upi_UserActivity @UserId,@date,3,@intID,4,'Retrieve'
								RETURN;
							END
						    ELSE
								/* Summary :If the accessLevel is SysAdminRO,VarAdminRW/RO,OrgAdminRO/RW,OrgUserRW/RO and check the Scope of the user then the following fields are returned*/
								IF((@accessLevel = 2 ) OR ((@accessLevel = 4) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId INNER JOIN tblinterceptor AS t  ON t.orgid=O.OrgId WHERE  s.sessionkey=@sessionKey AND t.intID=@intID  ))) OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT t.orgId FROM dbo.[tblinterceptor] t INNER JOIN [tblSession] S on t.orgId = S.orgID WHERE S.sessionKey = @sessionKey AND t.intID=@intID  ))))
								BEGIN
									SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','0|accesslevel|'+ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' FROM dbo.tblinterceptor t JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
									JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial WHERE t.intID=@intID  FOR XML RAW )+'</list>'	 
									
									UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
									EXEC upi_UserActivity @UserId,@date,3,@intID,4,'Retrieve'
									RETURN;
								END
								/* Summary:Raise an Error Message. If user is not within scope*/	 
								ELSE
								BEGIN
									SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','401|1703 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1703)+''+ CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
									EXEC upi_SystemEvents 'Interceptor',1703,3,@accessLevel
									RETURN;
								END	
		      		END
		      		/* Summary:Raise an Error Message, If Interceptor record is not found for the given Intid in the Interceptor table */
		      		ELSE
					BEGIN
						SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1705 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1705)+''+ CONVERT(VARCHAR,ISNULL(@intID,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
						RETURN;
					END
				END	  
				ELSE
		        IF(@intSerial<>'' AND @intID = 0)
		        BEGIN
				/* Summary:if intSerial  use it to get  matching Interceptor record */
		        IF (EXISTS(SELECT 1 FROM dbo.[tblInterceptor] WITH (NOLOCK) WHERE intSerial=@intSerial))
		        BEGIN
					/* Summary:If a matching Interceptorrecord  is found, use Interceptor[orgID] to check scope of user */
					/* Summary :If the accessLevel is SysAdminRW or VarAdminRW that owns the org that owns the interceptor, then the following fields are returned */
					IF(@accessLevel = 1 OR ((@accessLevel = 3 ) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId INNER JOIN tblinterceptor AS t  ON t.orgid=O.OrgId WHERE  s.sessionkey=@sessionKey AND t.intSerial=@intSerial ))) )
						BEGIN
							SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),IntId) FROM dbo.tblinterceptor t INNER JOIN tblinterceptorId i on t.intSerial=i.intSerial WHERE t.intSerial=@intSerial
							SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc',ISNULL(CONVERT(VARCHAR,t.[Security]),'NULL') AS 'Security',ISNULL(i.embeddedID,'NULL') AS 'embeddedID',ISNULL(t.startURL,'NULL') AS 'startURL',ISNULL(t.ReportURL,'NULL') AS 'ReportURL',ISNULL(t.ScanURL,'NULL') AS 'ScanURL',ISNULL(t.BkupURL,'NULL') AS 'BkupURL',ISNULL(CONVERT(VARCHAR,t.RequestTimeoutValue),'NULL') AS 'RequestTimeoutValue',ISNULL(t.WpaPSK,'NULL') AS 'WpaPSK',ISNULL(t.SSId,'NULL') AS 'SSId',ISNULL(CONVERT(VARCHAR,t.MaxBatchWaitTime),'NULL') AS 'MaxBatchWaitTime',ISNULL(CONVERT(VARCHAR,t.cmdChkInt),'NULL') AS 'cmdChkInt','0|accesslevel|1' AS 'ErrId' FROM dbo.tblinterceptor t  JOIN dbo.tblOrganization O on t.OrgId=O.OrgId
							JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial WHERE t.intSerial=@intSerial FOR XML RAW  )+'</list>'		
							UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
							EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
							RETURN;
						END
						ELSE
							/*  Summary :If the accessLevel is SysAdminRO,VarAdminRW/RO,OrgAdminRO/RW,OrgUserRW/RO and check the Scope of the user then the following fields are returned */
						    IF((@accessLevel = 2 ) OR (( @accessLevel = 4) AND (EXISTS(SELECT o.orgid FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId INNER JOIN tblinterceptor AS t  ON t.orgid=O.OrgId WHERE  s.sessionkey=@sessionKey AND t.intSerial=@intSerial ))) OR ((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND (EXISTS(SELECT t.orgId FROM dbo.[tblinterceptor] t INNER JOIN [tblSession] S on t.orgId = S.orgID  WHERE S.sessionKey = @sessionKey AND  t.intSerial=@intSerial ))))
							BEGIN
								SELECT '<list>'+ (SELECT ISNULL(CONVERT(VARCHAR,t.IntId),'NULL') AS 'IntId',ISNULL(t.IntSerial,'NULL') AS 'IntSerial',
								ISNULL(CONVERT(VARCHAR,O.OrgId),'NULL') AS 'OrgId',ISNULL(CONVERT(VARCHAR,t.LocId),'NULL') AS 'LocId',
								ISNULL(t.ForwardURL,'NULL') AS 'ForwardURL',ISNULL(CONVERT(VARCHAR,t.DeviceStatus),'NULL') AS 'DeviceStatus',ISNULL(CONVERT(VARCHAR,t.Capture),'NULL') AS 'Capture',ISNULL(CONVERT(VARCHAR,t.CaptureMode),'NULL') AS 'CaptureMode',ISNULL(CONVERT(VARCHAR,t.CallHomeTimeoutMode),'NULL') AS 'CallHomeTimeoutMode',ISNULL(t.CallHomeTimeoutData,'NULL')  AS 'CallHomeTimeoutData',ISNULL(t.DynCodeFormat,'NULL') AS 'DynCodeFormat',ISNULL(CONVERT(VARCHAR,t.ErrorLog),'NULL') AS 'ErrorLog',ISNULL(CONVERT(VARCHAR,t.ForwardType),'NULL') AS 'ForwardType',ISNULL(t.IntLocDesc,'NULL') AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','0|accesslevel|'+ISNULL(CONVERT(VARCHAR,@accessLevel),'') AS 'ErrId' FROM dbo.tblinterceptor t
							    JOIN dbo.tblOrganization O ON t.OrgId=O.OrgId
							    JOIN dbo.tblLocation L ON t.OrgId=L.OrgId AND t.LocId=l.LocId
							    INNER JOIN tblinterceptorId i ON t.intSerial=i.intSerial WHERE t.intSerial=@intSerial  FOR XML RAW )+'</list>'	
								
								UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
								EXEC upi_UserActivity @UserId,@date,3,@recorded,4,'Retrieve'
								RETURN;
							END
							/* Summary:Raise an Error Message. If user is not within scope*/	
						    ELSE
						    BEGIN
								SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','401|1703 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1703)+''+ CONVERT(VARCHAR,ISNULL(@accessLevel,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
								EXEC upi_SystemEvents 'Interceptor',1703,3,@accessLevel
								RETURN;
							END	
		           		END
		           		/* Summary:Raise an Error Message, If Interceptor record is not found for the given Intserial in the Interceptor table */
						ELSE
						BEGIN
							SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1704 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1704)+''+ CONVERT(VARCHAR,ISNULL(@intSerial,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
							RETURN;
						END
				END
				/* Summary:Raise an Error Message.If none of field Passed */
		        ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1702 '+(select Description +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode=1702) AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END
		END 
		/* Summary:Raise an Error Message.If more than one of orgId, locId, intId or intSerial are passed */
		ELSE
		BEGIN
		IF(@intId != 0 AND @intSerial != '' AND @orgId != 0 AND @locId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1710 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1710)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intID,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intSerial,'')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intId != 0 AND @intSerial != '' AND @orgId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1713 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1713)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intID,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intId != 0 AND @intSerial != '' AND @locId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1712 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1712)+ CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intID,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intId != 0 AND @orgId != '' AND @locId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1701 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1701)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intID,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intSerial != '' AND @orgId != '' AND @locId != 0 )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1711 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1711)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+ CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@orgId != 0 AND @locId != 0  )
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1714 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1714)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@locId,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@orgId != 0 AND @intSerial != '')
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1716 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1716)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@orgId != 0 AND @intId != 0)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1715 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1715)+ CONVERT(VARCHAR,ISNULL(@orgId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intID,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@locId != 0 AND @intSerial != '')
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1718 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1718)+ CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@locId != 0 AND @intId != 0)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1717 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1717)+ CONVERT(VARCHAR,ISNULL(@locId,'0'))+','+CONVERT(VARCHAR,ISNULL(@intID,'0')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF(@intSerial != '' AND @intId != 0)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'IntId','0' AS 'IntSerial','0' AS 'OrgId','0' AS 'LocId','0' AS 'ForwardURL','0' AS 'DeviceStatus','0' AS 'Capture','0' AS 'CaptureMode','0' AS 'CallHomeTimeoutMode','0' AS 'CallHomeTimeoutData','0' AS 'DynCodeFormat','0' AS 'ErrorLog','0' AS 'ForwardType','0' AS 'IntLocDesc','0' AS 'Security','0' AS 'embeddedID','0' AS 'startURL','0' AS 'ReportURL','0' AS 'ScanURL','0' AS 'BkupURL','0' AS 'RequestTimeoutValue','0' AS 'WpaPSK','0' AS 'SSId','0' AS 'MaxBatchWaitTime','0' AS 'cmdChkInt','400|1719 '+(select Description +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode=1719)+ CONVERT(VARCHAR,ISNULL(@intID,'0'))+','+CONVERT(VARCHAR,ISNULL(@intSerial,' ')) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	END
END
--exec ups_Interceptor '4A79DB236006635250C7470729F1BFA30DE691D7','6B05DB6DC930458646C3F560481C38E61E233D47',0,0,0,'111111qqqqqq'

GO
/****** Object:  StoredProcedure [dbo].[ups_InterceptorStatus]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================================
-- Author:				iHorse and iHorse 
-- Create date:			18.06.2013
-- Routine:				InterceptorReboot and InterceptorUpdate 
-- Method:				POST
-- Modified By:         iHorse
-- Reboot DESCRIPTION:	Sends a command to the Interceptor causing it to cycle it’s power 
--						(device powers down and back up). Note: this causes the Interceptor to go
--						through its normal start up procedure (Interceptor makes an HTTP call to
--						startURL, gets content for its configurable settings fields, then sends a
--						status report to reportURL)
-- Update DESCRIPTION:	sends a command to the Interceptor causing it to make an HTTP request
--						to startURL to get the content for its configurable settings fields 
--						(the Interceptor firmware updates its configurable settings fields using 
--						data returned by the HTTP request).
-- ===================================================================================================
CREATE PROCEDURE [dbo].[ups_InterceptorStatus] 

     @applicationKey	AS VARCHAR(40),
	 @sessionKey		AS VARCHAR(40),
	 @intSerial			AS VARCHAR(12),
	 @intId				AS INT
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output descriptions
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables descriptions
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time from the SQL Server
	-- @accessLevel used to store AccessLevel value
	
	DECLARE @ReturnResult		AS VARCHAR(MAX)
	DECLARE @UserId				AS VARCHAR(5)
	DECLARE @date				AS DATETIMEOFFSET(7)
	DECLARE @accessLevel		AS INT
	DECLARE @errorReturn		AS VARCHAR(1000)
	DECLARE @unauthorizedError	AS VARCHAR(1000)
	
	SET @date				 = SYSDATETIMEOFFSET();
	SET @UserId				 = (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	SET @accessLevel		 = (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	SET @errorReturn		 = '400'
	SET @unauthorizedError	 = '401'
	
	/* Summary: Raise an error message if both intId and intSerial are not passed */
	IF(ISNULL(@intId,0) = 0 AND ISNULL(@intSerial,'') = '')
	BEGIN
		SET	@errorReturn = @errorReturn+'|'+'2103 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2103)
		SELECT @errorReturn AS 'ReturnValue'	
		RETURN;
	END
	ELSE
	/* Summary: Raise an error message if both intId and intSerial are passed */
	IF(ISNULL(@intId,0) ! = 0 AND ISNULL(@intSerial,'') ! = '')
	BEGIN
		SET	@errorReturn = @errorReturn+'|'+'2102 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2102)
		SELECT @errorReturn AS 'ReturnValue'	
		RETURN;
	END
	ELSE
	IF(ISNULL(@intId,0) ! = 0 OR ISNULL(@intSerial,'') ! = '')
	BEGIN
		/*Summay: Use the intId or intSerial passed to search for the Interceptor record. */
		IF EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE (IntId = @intId OR IntSerial = @intSerial))
		BEGIN
			/*Summary: Search for the Organization record using orgId */
			IF EXISTS (SELECT 1 FROM dbo.tblOrganization O JOIN tblInterceptor I ON O.OrgId = I.OrgId WHERE (I.IntId = @intId OR I.IntSerial = @intSerial) AND O.OrgId = I.OrgId)
			BEGIN
				/*Summary: Check if access level is SysAdminRW / 
				If access level is VarAdminRW and if Organization[owner] matches Session[orgId] / 
				If access level is OrgAdminRW or OrgUserRW and if Session[orgId] is the same as the orgId.*/
				IF((@accessLevel = 1 OR @accessLevel = 2) OR
				((@accessLevel = 3 OR @accessLevel = 4) AND EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.Owner = S.OrgId JOIN tblInterceptor I ON I.orgId = O.orgId WHERE S.SessionKey = @sessionKey AND O.Owner = S.OrgId AND (I.IntId = @intId OR I.intserial = @intSerial))) OR
				((@accessLevel = 5 OR @accessLevel = 6 OR @accessLevel = 7 OR @accessLevel = 8) AND EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.OrgId = S.OrgId JOIN tblInterceptor I ON I.orgId = O.orgId WHERE S.SessionKey = @sessionKey AND O.OrgId = S.OrgId AND (I.IntId = @intId OR I.intserial = @intSerial))))
				BEGIN
					/*Summary: Issue an HTTP GET command to the Interceptor using IP address and port number from DeviceStatus[publicIP] and DeviceStatus[port] 
					with the following URL parameters:“reboot = 1” “a = <authentication string>”, WHERE <authentication string> is a 32 character 
					MD5 hexdigest of InterceptorID[embeddedID] */
					
					IF(ISNULL(@intSerial,'') = '') SELECT @intSerial = tblInterceptor.IntSerial FROM dbo.tblInterceptor WHERE tblInterceptor.IntId = @intId
					
					/*Summary: Delete From CmdQueue Data store*/
					IF EXISTS(SELECT 1 FROM dbo.tblCmdQueue WHERE IntSerial = @intSerial)
					BEGIN
						DELETE FROM dbo.tblCmdQueue WHERE IntSerial = @intSerial
					END
					INSERT INTO tblCmdQueue (IntSerial, Cmd, CmdTime) VALUES (@intSerial,3, SYSDATETIMEOFFSET())
					SET @ReturnResult = '200' SELECT @ReturnResult AS ReturnData
					EXEC upi_UserActivity @UserId,@date,3,@intSerial,0,'Retrieve'
					UPDATE [tblSession] SET lastActivity = @date WHERE sessionKey = @sessionKey
				END
				ELSE
				BEGIN
					SET	@unauthorizedError = @unauthorizedError+'|'+'2104 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 2104)
					SELECT @unauthorizedError AS 'ReturnValue'
					EXEC upi_SystemEvents 'InterceptorStatus',2104,3,@accessLevel	
					RETURN;
				END
			END
			ELSE
			BEGIN
				SET @ReturnResult = '400' SELECT @ReturnResult AS ReturnData
			END
		END
		ELSE
		BEGIN
			IF (NOT EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntId = @intId) AND @intId <> 0)
				SET	@errorReturn = @errorReturn+'|'+'2105 '+(SELECT DESCRIPTION +' |' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2105)+CONVERT(VARCHAR,@intId)	
			ELSE IF (NOT EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial = @intSerial)AND @intSerial <> '')
				SET	@errorReturn = @errorReturn+'|'+'2106 '+(SELECT DESCRIPTION +' |' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 2106)+CONVERT(VARCHAR,@intSerial)
			
			SELECT @errorReturn AS 'ReturnValue'
			RETURN;
		END
	END
END


GO
/****** Object:  StoredProcedure [dbo].[ups_Location]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- Author:		Indhumathi T and Prakash G
-- Create date: 15.05.2013
-- Routine:		Location
-- Method:		Get
-- Description:	Returns one or more Location records
-- ============================================================
CREATE PROCEDURE [dbo].[ups_Location]

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@orgId			AS INT,
	@locId			AS INT,
	@latitude		AS NUMERIC(18, 15),
	@longitude		AS NUMERIC(18, 15),
	@maxDistance	AS VARCHAR(100),
	@locType		AS VARCHAR(100),
	@locSubType		AS VARCHAR(100),
	@locDesc		AS VARCHAR(100),
	@maxRecords		AS INT
--[ups_Location] '4A79DB236006635250C7470729F1BFA30DE691D7','DBAD4A4E4BCB60BBDD11B1A7D9F42BFFFD9C33F7',0,0,0.63990,null,null,null,null,null,234253547		
--[ups_Location] '4A79DB236006635250C7470729F1BFA30DE691D7','6B05DB6DC930458646C3F560481C38E61E233D55',0,45,'0.0','0.0',null,'','','',0	
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Output DESCRIPTIONS
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables DESCRIPTIONS
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @Date used to store the current date and time from the SQL Server
	-- @AccessLevel used to store AccessLevel value
	-- @Key used to cursor
	-- @TarLat used to store the Latitude Value
	-- @TarLong used to store the Longtiutde Value
	-- @Target used to store geography target Value
	-- @Source used to store geography Source Value
	-- @Distance used to store distance between @target and @source Value
	-- @LocRecords used to store the string in Query
	-- @Recordcount used to store the top records value
	-- @ForUA used to store the string in Query
	-- @Recorded used to store current activity id
	
	SET ARITHABORT ON
	
	DECLARE @ReturnResult	AS	VARCHAR(MAX)
	DECLARE @UserId			AS	VARCHAR(5)
	DECLARE @Date			AS	DATETIMEOFFSET(7)
	DECLARE @AccessLevel	AS	INT
	DECLARE @Key			AS	INT
	DECLARE @Count			AS	INT
	DECLARE @Source			AS	GEOGRAPHY 
	DECLARE @Target			AS	GEOGRAPHY 
	DECLARE @TarLat			AS	NUMERIC(18, 15)
	DECLARE @TarLong		AS	NUMERIC(18, 15)
    DECLARE @Distance		AS	NUMERIC(18, 9)
    DECLARE @LocRecords		AS	NVARCHAR(MAX)
    DECLARE @Recordcount	AS	VARCHAR(MAX)
    DECLARE @Recorded		AS	VARCHAR(MAX)
	DECLARE @ForUA			AS	VARCHAR(MAX)
	DECLARE @SessionOrg     AS INT
    
	CREATE TABLE #pickedLocation ([locationId] [int] NULL, [distance] [NUMERIC](20, 15) NULL)
	CREATE TABLE #tmpUA (Locid INT)
	
	SET @Date			 = SYSDATETIMEOFFSET();
	SET @UserId			 = (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
	SET @AccessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WHERE sessionKey = @sessionKey )
	SET @ForUA			 = '';
	
	IF(ISNULL(@orgId,0) = 0)			SET @orgId = 0
	IF(ISNULL(@locId,0) = 0)			SET @locId = 0
	IF(ISNULL(@locType,'') = '')		SET @locType = ''
	IF(ISNULL(@latitude,0) = 0)			SET @latitude = 0
	IF(ISNULL(@longitude,0) = 0)		SET @longitude = 0
	IF(ISNULL(@locSubType,'') = '')		SET @locSubType = ''
	IF(ISNULL(@locDesc,'') = '')		SET @locDesc = ''
	IF(ISNULL(@maxRecords,0) = 0)		SET @maxRecords = 0
	
	IF(@maxRecords = 0)	SET @Recordcount = ''
	ELSE SET @Recordcount = 'TOP ' + '' + CONVERT(VARCHAR,@maxRecords)
	
	IF(@orgId ! = 0)
	BEGIN
		/* Summary: Raise an error message if orgid is passed and an access level field is OrgUserRW/RO or OrgAdminRW/RO in the Session data store */
		IF(@AccessLevel = 5 OR @AccessLevel = 6 OR @AccessLevel = 7 OR @AccessLevel = 8)
		BEGIN
			SELECT '<list>'+(SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','401|1508 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1508)+CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
			EXEC upi_SystemEvents 'Location',1508,3,@accessLevel
			RETURN;
		END
	END
	
	IF(@locId ! = 0)
		BEGIN
			/* Summary: Raise an error message if Location id is passed and any other optional parameters has been passed */
			IF(@orgId! = 0 OR @latitude ! = 0 OR @longitude! = 0 OR (@maxDistance is not null ) OR @locType ! = '' OR @locSubType! = '' OR @locDesc! = ''  OR @maxRecords! = 0)
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1522 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1522) AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
			END
		END
		
	IF(@latitude <> 0)
		BEGIN
			/* Summary: Raise an error message if Latitude is passed and Longitude is not passed */
			IF(isnull(@longitude,'0') = 0)
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1523 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1523) AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
			END
	END
	
	IF(@longitude <> 0)
		BEGIN
			/* Summary: Raise an error message if Longitude is passed and Latitude is not passed */
			IF(@latitude = 0)
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1524 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1524) AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
			END
	END
	
	IF(@maxDistance is not null)
		BEGIN
			/* Summary: Raise an error message if maxDistance is passed but latitudeand and longitude both are not passed */
			IF(isnull(@latitude,'0') = 0 AND isnull(@longitude,'0') = 0)
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1518 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1518) AS 'ErrId' FOR XML RAW )+'</list>'
				RETURN;
			END
	END
	/*Summary:If Latitude and Longitude Passed then to do the following step*/
	IF(@latitude ! = 0 AND @longitude ! = 0)  
	BEGIN
	    /* Summary: if latitude/longitude passed, but not maxDistance, then assume maxDistance to be 50,000 metres */
		IF(@maxDistance IS NULL) SET @maxDistance = 50000
		 /*Summary:If Accesslevel field is SysAdminRW,SysAdminRO(1,2) and orgid is passed then to do the following step */
		 	IF((@AccessLevel = 1 OR @AccessLevel = 2) AND @orgId ! = 0)
		 	BEGIN
		 		/*Summary:Here Cursor used for insert the distance,locid in temp table */
				DECLARE KEY_Cursor CURSOR FOR SELECT LocId FROM dbo.tblLocation L INNER JOIN tblOrganization o ON o.OrgId = L.OrgId WHERE L.OrgId = @orgId ---JOIN tblSession S ON S.OrgId = L.OrgId WHERE  S.SessionKey = @sessionKey
				OPEN KEY_Cursor; 
				FETCH NEXT FROM KEY_Cursor INTO @Key;
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					SELECT @TarLat = ISNULL(Latitude,0) FROM dbo.tblLocation WHERE LocId = @Key
					SELECT @TarLong = ISNULL(Longitude,0) FROM dbo.tblLocation WHERE LocId = @Key
				
					--SELECT @TarLat = Latitude FROM dbo.tblLocation WHERE LocId = @Key
					--SELECT @TarLong = Longitude FROM dbo.tblLocation WHERE LocId = @Key
					SET @Source = GEOGRAPHY::Point(@latitude,@longitude, 4326)
					SET @Target = GEOGRAPHY::Point(@TarLat,@TarLong, 4326)
					--Distance in Meter
					SELECT @Distance = CONVERT(NUMERIC(18,9),(@Source.STDistance(@Target)))
					SET @maxDistance = CONVERT(NUMERIC(18,9),@maxDistance)
				
					IF(ISNULL(@Distance,0) < = @maxDistance) 
					BEGIN
						IF NOT EXISTS(SELECT locationId FROM #pickedLocation WHERE locationId = @Key)
						INSERT INTO #pickedLocation SELECT DISTINCT(LocId),@Distance FROM dbo.tblLocation WHERE LocId = @Key
					END
				FETCH NEXT FROM KEY_Cursor INTO @Key;
				END;
				CLOSE KEY_Cursor;
				DEALLOCATE KEY_Cursor;
			END
			/*Summary:If Accesslevel field is VarAdminRW/RO and orgid is passed  then to do the following step */
			ELSE IF((@AccessLevel = 3 OR @AccessLevel = 4 )AND @orgId ! = 0)
			BEGIN
			/*Summary:Here Cursor used for insert the distance,locid in temp table */
				DECLARE KEY_Cursor CURSOR FOR SELECT LocId FROM dbo.tblLocation L  WHERE  L.OrgId IN(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE S.SessionKey = @sessionKey and O.OrgId = @orgid ) ---JOIN tblSession S ON S.OrgId = L.OrgId WHERE  S.SessionKey = @sessionKey
				OPEN KEY_Cursor; 
				FETCH NEXT FROM KEY_Cursor INTO @Key;
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					SELECT @TarLat = ISNULL(Latitude,0) FROM dbo.tblLocation WHERE LocId = @Key
					SELECT @TarLong = ISNULL(Longitude,0) FROM dbo.tblLocation WHERE LocId = @Key
							
					SET @Source = GEOGRAPHY::Point(@latitude,@longitude, 4326)
					SET @Target = GEOGRAPHY::Point(@TarLat,@TarLong, 4326)
					--Distance in Meter
					SELECT @Distance = CONVERT(NUMERIC(18,9),(@Source.STDistance(@Target)))
					SET @maxDistance = CONVERT(NUMERIC(18,9),@maxDistance)
					IF(ISNULL(@Distance,0) < = @maxDistance) 
					BEGIN
						IF NOT EXISTS(SELECT locationId FROM #pickedLocation WHERE locationId = @Key)
						INSERT INTO #pickedLocation SELECT DISTINCT(LocId),@Distance FROM dbo.tblLocation WHERE LocId = @Key
					END
					FETCH NEXT FROM KEY_Cursor INTO @Key;
				END;
				CLOSE KEY_Cursor;
				DEALLOCATE KEY_Cursor;
		    END
		    /*Summary:If Accesslevel field is OrgAdminRW/RO,OrgUserRW/RO and orgid not passed  then to do the following step */
		    ELSE IF((@AccessLevel = 5 OR @AccessLevel = 6 OR @AccessLevel = 7 OR @AccessLevel = 8) AND @orgId = 0)
		    BEGIN
				/*Summary:Here Cursor used for insert the distance,locid in temp table */
		 		DECLARE KEY_Cursor CURSOR FOR SELECT LocId FROM dbo.tblLocation L INNER JOIN tblOrganization o ON o.OrgId = L.OrgId WHERE  L.OrgId = (SELECT OrgId FROM dbo.tblSession s WHERE SessionKey = @sessionKey)
				OPEN KEY_Cursor; 
				FETCH NEXT FROM KEY_Cursor INTO @Key;
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					SELECT @TarLat = ISNULL(Latitude,0) FROM dbo.tblLocation WHERE LocId = @Key
					SELECT @TarLong = ISNULL(Longitude,0) FROM dbo.tblLocation WHERE LocId = @Key
							
					SET @Source = GEOGRAPHY::Point(@latitude,@longitude, 4326)
					SET @Target = GEOGRAPHY::Point(@TarLat,@TarLong, 4326)
					--Distance in Meter
					SELECT @Distance = CONVERT(NUMERIC(18,9),(@Source.STDistance(@Target)))
					SET @maxDistance = CONVERT(NUMERIC(18,9),@maxDistance)
					IF(ISNULL(@Distance,0) < = @maxDistance) 
					BEGIN
						IF NOT EXISTS(SELECT locationId FROM #pickedLocation WHERE locationId = @Key)
						INSERT INTO #pickedLocation SELECT DISTINCT(LocId),@Distance FROM dbo.tblLocation WHERE LocId = @Key
					END
					FETCH NEXT FROM KEY_Cursor INTO @Key;
				END;
				CLOSE KEY_Cursor;
				DEALLOCATE KEY_Cursor;
		    END
		    /*Summary:If Accesslevel field is SysAdminRW,SysAdminRO(1,2) and orgid is not passed then to do the following step */
		    ELSE IF((@AccessLevel = 1 OR @AccessLevel = 2) AND @orgId = 0)
		    BEGIN
				   /*Summary:Here Cursor used for insert the distance,locid in temp table */
		 		DECLARE KEY_Cursor CURSOR FOR SELECT LocId FROM dbo.tblLocation L INNER JOIN tblOrganization o ON o.OrgId = L.OrgId
				OPEN KEY_Cursor; 
				FETCH NEXT FROM KEY_Cursor INTO @Key;
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					SELECT @TarLat = ISNULL(Latitude,0) FROM dbo.tblLocation WHERE LocId = @Key
					SELECT @TarLong = ISNULL(Longitude,0) FROM dbo.tblLocation WHERE LocId = @Key
					SET @Source = GEOGRAPHY::Point(@latitude,@longitude, 4326)
					SET @Target = GEOGRAPHY::Point(@TarLat,@TarLong, 4326)
				
					--Distance in Meter
					SELECT @Distance = CONVERT(NUMERIC(18,9),(@Source.STDistance(@Target)))
					SET @maxDistance = CONVERT(NUMERIC(18,9),@maxDistance)
				
					IF(ISNULL(@Distance,0) < = @maxDistance)
					BEGIN
						IF NOT EXISTS(SELECT locationId FROM #pickedLocation WHERE locationId = @Key)
						INSERT INTO #pickedLocation SELECT DISTINCT(LocId),@Distance FROM dbo.tblLocation WHERE LocId = @Key
					END
					FETCH NEXT FROM KEY_Cursor INTO @Key;
				END;
				CLOSE KEY_Cursor;
				DEALLOCATE KEY_Cursor;
		    END
		   	/*Summary:If Accesslevel field is VarAdminRW/RO and orgid is not passed  then to do the following step */
		    ELSE IF((@AccessLevel = 3 OR @AccessLevel = 4) AND @orgId = 0)
		    BEGIN
		    	/*Summary:Here Cursor used for insert the distance,locid in temp table */
				DECLARE KEY_Cursor CURSOR FOR SELECT LocId FROM dbo.tblLocation L INNER JOIN tblOrganization o ON o.OrgId = L.OrgId WHERE O.OrgId in (SELECT so.OrgId FROM dbo.tblOrganization so WHERE so.Owner = (SELECT S.OrgId FROM dbo.tblSession S WHERE S.SessionKey = @sessionKey))  --WHERE  L.OrgId = (SELECT OrgId FROM dbo.tblSession s WHERE SessionKey = @sessionKey)
				OPEN KEY_Cursor; 
				FETCH NEXT FROM KEY_Cursor INTO @Key;
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					SELECT @TarLat = ISNULL(Latitude,0) FROM dbo.tblLocation WHERE LocId = @Key
					SELECT @TarLong = ISNULL(Longitude,0) FROM dbo.tblLocation WHERE LocId = @Key
							
					SET @Source = GEOGRAPHY::Point(@latitude,@longitude, 4326)
					SET @Target = GEOGRAPHY::Point(@TarLat,@TarLong, 4326)
					--Distance in Meter
					SELECT @Distance = CONVERT(NUMERIC(18,9),(@Source.STDistance(@Target)))
					SET @maxDistance = CONVERT(NUMERIC(18,9),@maxDistance)
					IF(ISNULL(@Distance,0) < = @maxDistance) 
					BEGIN
						IF NOT EXISTS(SELECT locationId FROM #pickedLocation WHERE locationId = @Key)
						INSERT INTO #pickedLocation SELECT DISTINCT(LocId),@Distance FROM dbo.tblLocation WHERE LocId = @Key
					END
					FETCH NEXT FROM KEY_Cursor INTO @Key;
				END;
				CLOSE KEY_Cursor;
				DEALLOCATE KEY_Cursor;
		    END
	END	
	
	/* Summary: If Organization id is passed */
	IF(@orgId ! = 0)
	BEGIN
	   /* Summary: Raise an error message ,if  Location id is passed when Orgid is Passed  */
	   IF(@locId ! = 0)
	   BEGIN
			SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','' AS 'Latitude','' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1522 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1522) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE IF NOT EXISTS(SELECT OrgId FROM dbo.tblOrganization WHERE OrgId= @orgId )
	    BEGIN
	        SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1501 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1501)+CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
	    END
	    ELSE
	    /* Summary:Raise an Error Message,If orgid is passed, matching Location record is not found */
	    IF NOT EXISTS(SELECT L.OrgId FROM dbo.tblOrganization o inner JOIN tblLocation l on o.OrgId = l.OrgId  WHERE l.OrgId = @orgId)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1527 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1527)+CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE 
		BEGIN
		
			/* Summary: If accessLevel is SysAdminRW/RO */
			/* Summary: If accessLevel is VarAdminRW/RO then check if Session[OrgId] is the owner of Location[OrgId] */
			/* Summary: If accessLevel is OrgAdminRW/RO or OrgUserRW/RO, then check if Session[OrgId] is the same as Location[OrgId] */
			IF((@AccessLevel = 1 OR @AccessLevel = 2) 
				OR ((@AccessLevel = 3 OR @AccessLevel = 4) AND 
				EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE S.SessionKey = @sessionKey and O.OrgId = @orgid ))
				OR ((@AccessLevel = 5 OR @AccessLevel = 6 OR @AccessLevel = 7 OR @AccessLevel = 8) AND
				EXISTS (SELECT S.OrgId FROM dbo.tblSession S INNER JOIN tblLocation L ON S.OrgId = L.OrgId WHERE S.SessionKey = @sessionKey AND  L.OrgId = @orgid )))
				BEGIN
				SET @LocRecords = 'SELECT ''<list>''+(' 
				/*Summary:If Latitude and Longitude Passed then add the following query*/
				IF(@latitude <> 0 AND @longitude <> 0 )
				BEGIN
					SET @ForUA = @ForUA+ 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN #pickedLocation PL ON L.LocId = PL.locationId JOIN tblOrganization O ON L.OrgId = O.OrgId  WHERE 1 = 1 AND  L.OrgId = '+ CONVERT(VARCHAR,@orgId)+''
					SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +' ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+''' AS ''ErrId'' FROM dbo.tblLocation L INNER JOIN #pickedLocation PL ON L.LocId = PL.locationId JOIN tblOrganization O ON L.OrgId = O.OrgId  WHERE 1 = 1 AND  L.OrgId = '+CONVERT(VARCHAR,@orgId)+'  '
				END
				/*Summary:If Latitude and Longitude Not Passed then add the following query*/
				ELSE
				BEGIN
					SET @ForUA = @ForUA + 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId  WHERE 1 = 1 AND L.OrgId = '+CONVERT(VARCHAR,@orgId)+''
					SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +' ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+'''  AS ErrId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId  WHERE 1 = 1 AND L.OrgId = '+CONVERT(VARCHAR,@orgId)+''
				END
				/*Summary:If Location type is Passed then add the following query*/
				IF(@locType	<> '')
				BEGIN
					SET @ForUA = @ForUA + 'and locType = '''+ @locType + ''''
					SET @LocRecords = @LocRecords + 'and locType = '''+ @locType + ''''
				END
				/*Summary:If Location Subtype is Passed then add the following query*/
				IF(@locSubType <> '' )	
				BEGIN
					SET @ForUA = @ForUA + ' and locSubType = '''+ @locSubType +''''
					SET @LocRecords  = @LocRecords + ' and locSubType = '''+ @locSubType +''''
				END
				/*Summary:If Location Description is Passed then add the following query*/
				IF(@locDesc <> '' )	
				BEGIN
					SET @ForUA = @ForUA + ' and locDesc like ''%'+RTRIM(LTRIM(CONVERT(VARCHAR, @locDesc)))+'%'''
					SET @LocRecords = @LocRecords + ' and locDesc like ''%'+RTRIM(LTRIM(CONVERT(VARCHAR, @locDesc)))+'%'''
				END
				/*Summary:Check  @Recordcount is not NULL*/
				IF (@Recordcount <> '')
				BEGIN
				/*Summary:Here fliter the records based on Distance*/
				IF(@latitude <> 0 AND @longitude <> 0 )
				BEGIN
					SET @ForUA = @ForUA + 'ORDER BY PL.distance ASC'
					SET @LocRecords = @LocRecords + 'ORDER BY PL.distance ASC FOR XML RAW )+''</list>'''
				END
				/*Summary:Here fliter the records based on LocID*/
				ELSE
				BEGIN
					SET @ForUA = @ForUA  + 'ORDER BY L.locid DESC '
					SET @LocRecords = @LocRecords + 'ORDER BY L.locid DESC FOR XML RAW )+''</list>'''
				END
				END
				ELSE 
				BEGIN
					SET @LocRecords = @LocRecords + 'FOR XML RAW )+''</list>'''
				END
				
				INSERT INTO #tmpUA EXEC (@ForUA)
				SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),LocId) FROM #tmpUA
				If(@recorded ! = '')
				BEGIN
					EXEC Sp_executeSQL @LocRecords
					UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
					EXEC upi_UserActivity @UserId,@Date,3,@recorded,2,'Retrieve'
					RETURN;
				END
				ELSE
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1526 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1526) AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END
				END
				ELSE	
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','401|1510 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1510)+CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
					EXEC upi_SystemEvents 'Location',1510,3,@orgId
					RETURN;
				END
		END
	END
	
	/* Summary: If location id is passed */
	IF(@locId ! = 0 )
	BEGIN
	IF(@orgId  = 0 AND @latitude  = 0 AND @longitude  = 0 AND (@maxDistance is null ) AND @locType  = '' AND @locSubType  = '' AND @locDesc  = ''  AND @maxRecords = 0)
	BEGIN
	    /* Summary:Raise an Error Message,If locId is passed, matching Location record is not found */
		IF NOT EXISTS(SELECT L.OrgId FROM dbo.tblOrganization o inner JOIN tblLocation l on o.OrgId = l.OrgId  WHERE l.locId = @locId)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1512 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1512) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE 
		BEGIN
			/* Summary: If accessLevel is SysAdminRW/RO */
			/* Summary: If accessLevel is VarAdminRW/RO then check if Session[OrgId] is the owner of Location[OrgId] */
			/* Summary: If accessLevel is OrgAdminRW/RO or OrgUserRW/RO, then check if Session[OrgId] is the same as Location[OrgId] */
			IF((@AccessLevel = 1 OR @AccessLevel = 2) 
				OR ((@AccessLevel = 3 OR @AccessLevel = 4) AND 
				EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE S.SessionKey = @sessionKey and L.locId = @locId ))
				OR ((@AccessLevel = 5 OR @AccessLevel = 6 OR @AccessLevel = 7 OR @AccessLevel = 8) AND
				EXISTS (SELECT S.OrgId FROM dbo.tblSession S INNER JOIN tblLocation L ON S.OrgId = L.OrgId WHERE S.SessionKey = @sessionKey and L.locId = @locId)))
				BEGIN
					SET @LocRecords = 'SELECT ''<list>''+(' 
					SET @ForUA = @ForUA+ 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId  WHERE 1 = 1 AND L.locId = '+CONVERT(VARCHAR,@locId)+''
					SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +' ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+'''  AS ErrId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId  WHERE 1 = 1 AND L.locId = '+CONVERT(VARCHAR,@locId)+''
					/*Summary:Check  @Recordcount is not NULL*/
					IF (@Recordcount <> '')
					BEGIN
						SET @ForUA = @ForUA + 'ORDER BY L.locid DESC'
						SET @LocRecords = @LocRecords + 'ORDER BY L.locid DESC FOR XML RAW )+''</list>'''
					END
					ELSE SET @LocRecords = @LocRecords + 'FOR XML RAW )+''</list>'''
					
					INSERT INTO #tmpUA EXEC (@ForUA)
					SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),LocId) FROM #tmpUA
				    IF(@recorded ! = '')
				    BEGIN
						EXEC Sp_executeSQL @LocRecords
						UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
						EXEC upi_UserActivity @UserId,@Date,3,@recorded,2,'Retrieve'
						RETURN;
					END
				    ELSE
				    BEGIN
						SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1526 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1526) AS 'ErrId' FOR XML RAW )+'</list>'
				 		RETURN;
					END
				END
				ELSE	
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','401|1513 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1513)+CONVERT(VARCHAR,@locId) AS 'ErrId' FOR XML RAW )+'</list>'
					EXEC upi_SystemEvents 'Location',1513,3,@locId
					RETURN;
				END
		END	
	END
	END	
	
	IF(@orgId  = 0 AND @locId = 0)
	BEGIN
	/* Summary:Raise an Error Message,matching Location record is not found */
	SET @SessionOrg	 = (SELECT orgid FROM dbo.[tblSession] WHERE sessionKey = @sessionKey )
	 IF NOT EXISTS(SELECT L.OrgId FROM dbo.tblOrganization o inner JOIN tblLocation l on o.OrgId = l.OrgId )  -- WHERE l.OrgId = (SELECT OrgId FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1501 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1501) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		ELSE 
		BEGIN
		--[ups_Location] '4A79DB236006635250C7470729F1BFA30DE691D7','6B05DB6DC930458646C3F560481C38E61E233D55',0,0,'0.0','0.0',null,'','','',0	
		--select @AccessLevel
			/* Summary: If accessLevel is SysAdminRW/RO */
			IF(@AccessLevel = 1 OR @AccessLevel = 2) 
				BEGIN
					SET @LocRecords = 'SELECT ''<list>''+(' 
					/*Summary:If Latitude and Longitude Passed then add the following query*/
					IF(@latitude <> 0 AND @longitude <> 0 )
					BEGIN
						SET @ForUA = @ForUA+ 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN #pickedLocation PL ON L.LocId = PL.locationId JOIN tblOrganization O ON L.OrgId = O.OrgId WHERE 1 = 1'  
						SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +'  ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+'''  AS ErrId FROM dbo.tblLocation L INNER JOIN #pickedLocation PL ON L.LocId = PL.locationId JOIN tblOrganization O ON L.OrgId = O.OrgId WHERE 1 = 1'  
					END
					/*Summary:If Latitude and Longitude Not Passed then add the following query*/
					ELSE
					BEGIN
						SET @ForUA = @ForUA+ 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId WHERE 1 = 1 '
						SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +'ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+'''  AS ErrId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId WHERE 1 = 1 '
					END
				END	
				ELSE
				/* Summary: If accessLevel is VarAdminRW/RO the n check if Session[OrgId] is the owner of Location[OrgId] */
				IF((@AccessLevel = 3 OR @AccessLevel = 4) AND 
				EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE S.SessionKey = @sessionKey ))
				BEGIN
					SET @LocRecords = 'SELECT ''<list>''+(' 
					/*Summary:If Latitude and Longitude Passed then add the following query*/
					IF(@latitude <> 0 AND @longitude <> 0 )
					BEGIN
						SET @ForUA = @ForUA+ 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN #pickedLocation PL ON L.LocId = PL.locationId JOIN tblOrganization O ON L.OrgId = O.OrgId WHERE O.OrgId in (SELECT O.OrgId FROM dbo.tblOrganization O WHERE O.Owner = (SELECT S.OrgId FROM dbo.tblSession S WHERE S.SessionKey = '''+ @sessionKey + ''')) '  
						SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +' ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+'''  AS ErrId FROM dbo.tblLocation L INNER JOIN #pickedLocation PL ON L.LocId = PL.locationId JOIN tblOrganization O ON L.OrgId = O.OrgId WHERE O.OrgId in (SELECT O.OrgId FROM dbo.tblOrganization O WHERE O.Owner = (SELECT S.OrgId FROM dbo.tblSession S WHERE S.SessionKey = '''+ @sessionKey + ''')) '  
					END
					/*Summary:If Latitude and Longitude Not Passed then add the following query*/
					ELSE
					BEGIN
						SET @ForUA = @ForUA+ 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId WHERE O.OrgId in (SELECT O.OrgId FROM dbo.tblOrganization O WHERE O.Owner = (SELECT S.OrgId FROM dbo.tblSession S WHERE S.SessionKey = '''+ @sessionKey + ''')) '
						SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +' ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+'''  AS ErrId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId WHERE O.OrgId in (SELECT O.OrgId FROM dbo.tblOrganization O WHERE O.Owner = (SELECT S.OrgId FROM dbo.tblSession S WHERE S.SessionKey = '''+ @sessionKey + ''')) '
					END
				END
				/* Summary: If accessLevel is OrgAdminRW/RO or OrgUserRW/RO, then check if Session[OrgId] is the same as Location[OrgId] */
				ELSE IF(@AccessLevel = 5 OR @AccessLevel = 6 OR @AccessLevel = 7 OR @AccessLevel = 8) 
				BEGIN
					IF(NOT EXISTS(SELECT OrgId FROM dbo.tblOrganization Where Orgid=@SessionOrg))
				    BEGIN
						SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1501 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1501)+ CONVERT(VARCHAR,@SessionOrg) AS 'ErrId' FOR XML RAW )+'</list>'
					    EXEC upi_SystemEvents 'Location',1501,3,@accessLevel
					    RETURN;
				    END
				    ELSE IF(NOT EXISTS(SELECT Locid FROM dbo.tblLocation Where Orgid=@SessionOrg)) 
				    BEGIN
						SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1527 '+(SELECT DESCRIPTION +'|' + FieldName +'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1527)+ CONVERT(VARCHAR,@SessionOrg) AS 'ErrId' FOR XML RAW )+'</list>'
					    EXEC upi_SystemEvents 'Location',1527,3,@accessLevel
					    RETURN;
				    END
				    ELSE IF(NOT EXISTS(SELECT O.OrgId FROM dbo.tblOrganization o inner JOIN tblLocation l on o.OrgId = l.OrgId  INNER JOIN  dbo.tblSession S ON S.OrgId = L.OrgId WHERE S.SessionKey = @sessionKey and O.orgid=@SessionOrg) )
				    BEGIN
						SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','401|1525 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1525) AS 'ErrId' FOR XML RAW )+'</list>'
						EXEC upi_SystemEvents 'Location',1525,3,@accessLevel
						RETURN;
					END
					ELSE
					BEGIN
					  SET @LocRecords = 'SELECT ''<list>''+(' 
					  /*Summary:If Latitude and Longitude Passed then add the following query*/
					   IF(@latitude <> 0 AND @longitude <> 0 )
						BEGIN
						SET @ForUA = @ForUA+ 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN #pickedLocation PL ON L.LocId = PL.locationId JOIN tblOrganization O ON L.OrgId = O.OrgId WHERE O.OrgId = (SELECT TOP 1 S.OrgId FROM dbo.tblSession S INNER JOIN tblLocation L ON S.OrgId = L.OrgId WHERE S.SessionKey = '''+ @sessionKey + ''')'  
						SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +' ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+'''  AS ErrId FROM dbo.tblLocation L INNER JOIN #pickedLocation PL ON L.LocId = PL.locationId JOIN tblOrganization O ON L.OrgId = O.OrgId WHERE O.OrgId = (SELECT TOP 1 S.OrgId FROM dbo.tblSession S INNER JOIN tblLocation L ON S.OrgId = L.OrgId WHERE S.SessionKey = '''+ @sessionKey + ''') '  
						END
						/*Summary:If Latitude and Longitude Not Passed then add the following query*/
						ELSE
						BEGIN
						SET @ForUA = @ForUA+ 'SELECT '+ @Recordcount +' ISNULL(L.LocId,0) AS LocId FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId WHERE O.OrgId = (SELECT TOP 1 S.OrgId FROM dbo.tblSession S INNER JOIN tblLocation L ON S.OrgId = L.OrgId WHERE S.SessionKey = '''+ @sessionKey + ''')'
						SET @LocRecords = @LocRecords + 'SELECT  '+ @Recordcount +' ISNULL(L.LocId,''NULL'') AS LocId,ISNULL(CONVERT(VARCHAR,O.OrgId),''NULL'') AS OrgId,ISNULL(L.UnitSuite,''NULL'') AS UnitSuite,ISNULL(L.Street,''NULL'') AS Street,ISNULL(L.City,''NULL'') AS City,ISNULL(L.State,''NULL'') AS State,ISNULL(L.Country,''NULL'') AS Country,ISNULL(L.PostalCode,''NULL'') AS PostalCode,ISNULL(CONVERT(VARCHAR,L.Latitude),''NULL'') AS Latitude,ISNULL(CONVERT(VARCHAR,L.Longitude),''NULL'') AS Longitude,ISNULL(L.LocType,''NULL'') AS LocType,ISNULL(L.LocSubType,''NULL'') AS LocSubType,ISNULL(L.LocDesc,''NULL'') AS LocDesc,''0|accesslevel|'+Convert(NVarchar,@AccessLevel)+'''  AS ErrId  FROM dbo.tblLocation L INNER JOIN  tblOrganization O ON L.OrgId = O.OrgId WHERE O.OrgId = (SELECT TOP 1 S.OrgId FROM dbo.tblSession S INNER JOIN tblLocation L ON S.OrgId = L.OrgId WHERE S.SessionKey = '''+ @sessionKey + ''') '
						END
					END--Orgid check	
				END
				ELSE	
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','401|1525 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1525) AS 'ErrId' FOR XML RAW )+'</list>'
					EXEC upi_SystemEvents 'Location',1525,3,@accessLevel
					RETURN;
				END
				/*Summary:If Location type is Passed then add the following query*/		
				IF(@locType	<> '')
				BEGIN
					SET @ForUA = @ForUA + 'and locType = '''+ @locType + ''''
					SET @LocRecords = @LocRecords + 'and locType = '''+ @locType + ''''
				END
				/*Summary:If Location Subtype is Passed then add the following query*/
				IF(@locSubType <> '' )	
				BEGIN
					SET @ForUA = @ForUA + ' and locSubType = '''+ @locSubType +''''
					SET @LocRecords  = @LocRecords + ' and locSubType = '''+ @locSubType +''''
				END
				/*Summary:If Location Description is Passed then add the following query*/
				IF(@locDesc <> '' )	
				BEGIN
					SET @ForUA = @ForUA  + ' and locDesc like ''%'+RTRIM(LTRIM(CONVERT(VARCHAR,@locDesc,100)))+'%'''
					SET @LocRecords = @LocRecords + ' and locDesc like ''%'+RTRIM(LTRIM(CONVERT(VARCHAR,@locDesc,100)))+'%'''
				END
				/*Summary:Check  @Recordcount is not NULL*/
				IF (@Recordcount <> '')
				BEGIN
					/*Summary:Here fliter the records based on Distance*/
					IF(@latitude <> 0 AND @longitude <> 0 )
					BEGIN
						SET @ForUA = @ForUA + 'ORDER BY PL.distance ASC'
					    SET @LocRecords = @LocRecords + 'ORDER BY PL.distance ASC FOR XML RAW )+''</list>'''
					END
					/*Summary:Here fliter the records based on LocID*/
					ELSE
					BEGIN
						SET @ForUA = @ForUA  + 'ORDER BY L.locid DESC '
						SET @LocRecords = @LocRecords + 'ORDER BY L.locid DESC FOR XML RAW )+''</list>'''
					END
				END
				ELSE SET @LocRecords = @LocRecords + 'FOR XML RAW )+''</list>'''
				INSERT INTO #tmpUA EXEC (@ForUA)
				SELECT @recorded = COALESCE(@recorded+',' , '') + CONVERT(VARCHAR(50),LocId) FROM #tmpUA
				IF(@recorded ! = '')
				BEGIN
					EXEC Sp_executeSQL @LocRecords
					UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
					EXEC upi_UserActivity @UserId,@Date,3,@recorded,2,'Retrieve'
					RETURN;
				END
				ELSE
					BEGIN
				 	SELECT '<list>'+( SELECT '0' AS 'LocId','0' AS 'OrgId','0' AS 'UnitSuite','0' AS 'Street','0' AS 'City','0' AS 'State','0' AS 'Country','0' AS 'PostalCode','0' AS 'Latitude','0' AS 'Longitude','0' AS 'LocType','0' AS 'LocSubType','0' AS 'LocDesc','400|1526 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1526) AS 'ErrId' FOR XML RAW )+'</list>'
					RETURN;
				END
			END	
		END
END	
--EXEC [ups_Location] '4A79DB236006635250C7470729F1BFA30DE691D7','123456789',0,0,null,null,0,null,null,null,3
--[ups_Location] 'A1A2A3A4A5A6A7A8','6B05DB6DC930458646C3F560481C38E61E233D47',0,0,'41.666758000000000','-70.000000000000000',0,'','','',0
--[ups_Location] '4A79DB236006635250C7470729F1BFA30DE691D7','6B05DB6DC930458646C3F560481C38E61E233D47',0,0,'0.0','0.0',50,'','','',0

GO
/****** Object:  StoredProcedure [dbo].[ups_Organization]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- Author:		iHorse
-- Create date: 27.04.2013
-- Routine:		Organization
-- Method:		Get
-- DESCRIPTION:	Returns one or more Organization records
-- ============================================================
CREATE PROCEDURE [dbo].[ups_Organization]

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@orgId			AS INT
		
AS
BEGIN
--[ups_Organization] '4A79DB236006635250C7470729F1BFA30DE691D7','EF74564BD7988BBA6B04BAB6AD52776E1E4D27D5',4
	SET NOCOUNT ON;
	
	-- Output DESCRIPTIONs
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables DESCRIPTIONs
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @Date used to store the current date and time from the SQL Server
	-- @AccessLevel used to store AccessLevel value
	-- @Recorded used to store current activity id
	-- @OrgId = -1 refers to OrgId = *
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @Date			AS DATETIMEOFFSET(7)
	DECLARE @AccessLevel	AS INT
	DECLARE	@Recorded		AS VARCHAR(50)
 
	DECLARE @SysAdminRW		AS INT = 1
	DECLARE @SysAdminRO		AS INT = 2
	DECLARE @VarAdminRW		AS INT = 3
	DECLARE @VarAdminRO		AS INT = 4
	DECLARE @OrgAdminRW		AS INT = 5
	DECLARE @OrgAdminRO		AS INT = 6
	DECLARE @OrgUserRW		AS INT = 7
	DECLARE @OrgUserRO		AS INT = 8
	
	SET @Date			 = SYSDATETIMEOFFSET();
	SET @UserId			 = (SELECT userId FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)
	SET @AccessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	
	/* Summary:Set orgId to zero if orgId is null or empty */
	IF(ISNULL(@orgId,'') = '') SET @orgId = 0;
	
	/* Summary:Check if orgId is not null or empty */
	IF(@orgId <> 0)
	BEGIN
		/* Summary:Raise an error message if orgId is passed and an access level is OrgUserRW/RO or OrgAdminRW/RO */
		IF(@AccessLevel = 5 OR @AccessLevel = 6 OR @AccessLevel = 7 OR @AccessLevel = 8)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress', '0' AS 'Owner', '400|1301 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1301)+CONVERT(varchar,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
		/* Summary: Check if the accessLevel is SysAdminRW/RO or not*/
		IF(@AccessLevel = 1 OR @AccessLevel = 2)
		BEGIN
			/* Summary:Retrieve all the organization records If the passed orgId is -1 (i.e) orgId is “*” */
			IF(@orgId = -1)
			BEGIN
				SELECT '<list>'+(
				SELECT ISNULL(O.Orgid,'NULL') AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName',ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',
				isnull(CONVERT(varchar,owner),'NULL') As Owner,'0|accessLevel|'+CONVERT(varchar,1) AS 'ErrId'
				FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.[owner] > = S.orgID WHERE S.sessionKey = @sessionKey
				FOR XML RAW )+'</list>'
				SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),OrgId)FROM dbo.tblOrganization
				UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
				EXEC upi_UserActivity @UserId,@Date,3,@Recorded,1,'Retrieve'
				RETURN;
			END
			ELSE
			BEGIN
				/* Summary: For SysAdminRW/RO access level, If the passed orgId is not -1 ((ie) not “*”) then retrieve all organization records 
					based on passed orgId else return an error string '401' */
				IF EXISTS (SELECT 1 FROM dbo.tblOrganization O WHERE O.OrgId = @orgId )
				BEGIN
					SELECT '<list>'+(
					SELECT ISNULL(O.Orgid,'NULL') AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName',ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',
					isnull(CONVERT(varchar,owner),'NULL') As Owner,
					'0|accessLevel|'+CONVERT(varchar,@AccessLevel) AS 'ErrId'
					FROM dbo.tblOrganization O WHERE O.OrgId = @orgId
					FOR XML RAW )+'</list>'
					SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId)FROM dbo.tblOrganization O WHERE O.OrgId = @orgId
					UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
					EXEC upi_UserActivity @UserId,@Date,3,@Recorded,1,'Retrieve'
					RETURN;
				END
				ELSE
				/* Summary: Raise an error message if there is no match in Organization Data Store */
				BEGIN
					SELECT '<list>'+(
					SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress',
					'0' AS 'Owner', '400|1304 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1304)+CONVERT(varchar,@orgId) AS 'ErrId'
					FOR XML RAW )+'</list>'
					RETURN;
				END
			END
		END
		
		/* Summary: Check if the accessLevel is VarAdminRW/RO or not*/
		IF(@AccessLevel = 3 OR @AccessLevel = 4)
		BEGIN
			/* Summary:Retrieve all the organization records from VarAdminRW/RO If the passed orgId is -1 (i.e) orgId is “*” */
			IF(@orgId = -1)
			BEGIN
				SELECT '<list>'+(
				SELECT ISNULL(O.Orgid,'NULL') AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName',ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',
				isnull(CONVERT(varchar,owner),'NULL') As Owner,
				'0|accessLevel|'+CONVERT(varchar,@AccessLevel) AS 'ErrId'
				FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.[owner] = S.orgID WHERE S.sessionKey = @sessionKey
				FOR XML RAW )+'</list>'
				SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId)FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.[owner] = S.orgID WHERE S.sessionKey = @sessionKey
				UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
				EXEC upi_UserActivity @UserId,@Date,3,@Recorded,1,'Retrieve'
				RETURN;
			END
			ELSE
			BEGIN
			/* Summary: Check passed OrgId is in Organization data store or not */
			IF EXISTS (SELECT 1 FROM dbo.tblOrganization O WHERE O.OrgId = @orgId )
			BEGIN
				/* Summary: For VarAdminRW/RO access level, If the passed orgId is not -1 ((ie) not “*”) then check Organization[Owner] against Session[OrgId]
					If the values match, then retrieve all the organization records owned by Session[OrgID] else return a error string '401' */		
				IF((SELECT COUNT (O.owner) FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.Owner = S.orgID WHERE S.sessionKey = @sessionKey and O.OrgId = @orgId) = 0)
				BEGIN
					SELECT '<list>'+( SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress', '0' AS 'Owner', '401|1305 '+(SELECT DESCRIPTION +'|' + FieldName+'->'  FROM dbo.tblErrorLog WHERE ErrorCode = 1305)+CONVERT(varchar,@AccessLevel) AS 'ErrId' FOR XML RAW )+'</list>'
					EXEC upi_SystemEvents 'Organization',1305,3,@AccessLevel
					RETURN; 
				END
				ELSE
				BEGIN
					SELECT '<list>'+(
					SELECT ISNULL(O.Orgid,'NULL') AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName',ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',
					isnull(CONVERT(varchar,owner),'NULL') As Owner,
					'0|accessLevel|'+CONVERT(varchar,@AccessLevel) AS 'ErrId'
					FROM dbo.tblOrganization O WHERE O.OrgId = @orgId
					FOR XML RAW )+'</list>'
					SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId)FROM dbo.tblOrganization O WHERE O.OrgId = @orgId
					UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
					EXEC upi_UserActivity @UserId,@Date,3,@Recorded,1,'Retrieve'
					RETURN;
				END
			END
			/* Summary: Raise an error message if there is no match in Organization Data Store */
			BEGIN
				SELECT '<list>'+(
				SELECT '0' AS 'Orgid', '0' AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress',
				'0' AS 'Owner', '400|1304 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1304)+CONVERT(varchar,@orgId) AS 'ErrId'
				FOR XML RAW )+'</list>'
				RETURN;
			END
			END
		END
	END	
	ELSE
	BEGIN
		/* Summary: Check if the accessLevel is SysAdminRW/RO or not and retrieve organization records based on sesssion orgId*/
		IF(@AccessLevel = 1 OR @AccessLevel = 2)
		BEGIN
			SELECT '<list>'+(
			SELECT ISNULL(O.Orgid,'NULL') AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName',ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',
			isnull(CONVERT(varchar,owner),'NULL') As Owner,
			'0|accessLevel|'+CONVERT(varchar,@AccessLevel) AS 'ErrId'
			FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey
			FOR XML RAW )+'</list>'
			SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId)FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey
			UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @UserId,@Date,3,@Recorded,1,'Retrieve'
			RETURN;
		END
		/* Summary: Check if the accessLevel is VarAdminRW/RO or not and retrieve organization records based on sesssion orgId*/
		ELSE IF(@AccessLevel = 3 OR @AccessLevel = 4)
		BEGIN
			SELECT '<list>'+(
			SELECT ISNULL(O.Orgid,'NULL') AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName',ISNULL(O.ApplicationKey,'NULL') AS 'ApplicationKey', ISNULL(O.IpAddress,'NULL') AS 'IpAddress',
			isnull(CONVERT(varchar,owner),'NULL') As Owner,
			'0|accessLevel|'+CONVERT(varchar,@AccessLevel) AS 'ErrId'
			FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey
			FOR XML RAW )+'</list>'
			SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId)FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey
			UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @UserId,@Date,3,@Recorded,1,'Retrieve'
			RETURN;
		END	
		/* Summary: Check if the accessLevel is OrgAdminRW/RO/UserAdminRW/RO or not and retrieve organization records based on sesssion orgId*/
		ELSE IF(@AccessLevel = 5 OR @AccessLevel = 6 OR @AccessLevel = 7 OR  @AccessLevel = 8)
		BEGIN
			SELECT '<list>'+(
			SELECT ISNULL(O.Orgid,'NULL') AS 'Orgid', ISNULL(O.OrgName,'NULL') AS 'OrgName', '0' AS 'ApplicationKey', '0' AS 'IpAddress','0' AS 'Owner',
			'0|accessLevel|'+CONVERT(varchar,@AccessLevel) AS 'ErrId'
			FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey
			FOR XML RAW )+'</list>'
			SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),O.OrgId)FROM dbo.tblOrganization O INNER JOIN [tblSession] S on O.orgId = S.orgID WHERE S.sessionKey = @sessionKey
			UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @UserId,@Date,3,@Recorded,1,'Retrieve'
			RETURN;
		END
	END
END
--[ups_Organization] 'A1A2A3A4A5A6A7A8','265FC282FDA2E1431C2366069B546123',2


GO
/****** Object:  StoredProcedure [dbo].[ups_User]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- Author:		Indhumathi T	
-- Create date: 03.05.2013
-- Routine:		User
-- Method:		Get
-- Description:	Returns one or more User records
-- ============================================================
CREATE PROCEDURE [dbo].[ups_User]

	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@userId			AS VARCHAR(5),
	@orgId			AS INT
	
AS
BEGIN

	SET NOCOUNT ON;
	-- Output DESCRIPTIONs
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables DESCRIPTIONs
	-- @ReturnResult used to return results
	-- @Date used to store the current date and time FROM the SQL Server
	-- @AccessLevel used to store AccessLevel value
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @Date			AS DATETIMEOFFSET(7)
	DECLARE @AccessLevel	AS INT
	DECLARE @LIUserID		AS VARCHAR(5)
	DECLARE	@Recorded		AS VARCHAR(50)
	
	SET @LIUserID		 = (SELECT UserId FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	SET @Date			 = SYSDATETIMEOFFSET();
	SET @AccessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WHERE @sessionKey = sessionKey)
	
	/* Summary:Set orgId to zero if orgId is null or empty */
	IF(ISNULL(@orgId,'') = '') SET @orgId = 0;
	
	IF(@orgId <> 0 AND (@userId <>'' AND @userId IS NOT NULL))
	BEGIN
		SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName', '0' AS 'RegDate', '0' AS 'AccessLevel', '400|1112 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1112) AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	
	IF((@orgId <>0 OR (@userId <>'' AND @userId IS NOT NULL)) AND (@AccessLevel = 7 OR @AccessLevel = 8))
	BEGIN
		IF(@orgId <>0)
		SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '400|1118 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1118) AS 'ErrId' FOR XML RAW )+'</list>'
		ELSE IF(@userId <>'' AND @userId IS NOT NULL)
		SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '400|1117 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1117) AS 'ErrId' FOR XML RAW )+'</list>'
		RETURN;
	END
	
	IF(@orgId <> 0)
	BEGIN
		IF (NOT EXISTS (SELECT OrgId FROM dbo.[tblSession] WHERE OrgId = @orgId AND @sessionKey = sessionKey) AND (@AccessLevel = 5 OR @AccessLevel = 6))
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName', '0' AS 'RegDate', '0' AS 'AccessLevel', '400|1116 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1114)+CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
	END
	
	IF(@orgId <> 0)
	BEGIN
    IF EXISTS (SELECT 1 FROM dbo.tblOrganization WHERE Orgid = @orgId)
    BEGIN
		IF((@AccessLevel = 1 OR @AccessLevel = 2) 
		OR ((@AccessLevel = 3 OR @AccessLevel = 4) AND
		EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId WHERE S.SessionKey = @sessionKey AND O.OrgId = @orgId ))
		OR ((@AccessLevel = 5 OR @AccessLevel = 6)))
		BEGIN
			IF(@AccessLevel = 1 OR @AccessLevel = 2  or @AccessLevel = 5 OR @AccessLevel = 6)
			BEGIN
				SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'NULL')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
				FROM dbo.tblUser U WHERE U.OrgId = @orgId 
				FOR XML RAW )+'</list>'
				SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),U.UserId)FROM dbo.tblUser U WHERE U.OrgId = @orgId 
			END
			ELSE IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE Owner <> @orgId)
			BEGIN
			SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
				FROM dbo.[tblUser] U WHERE U.OrgId = @orgId AND U.AccessLevel > = @AccessLevel
				FOR XML RAW )+'</list>'
				SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),U.UserId)FROM dbo.[tblUser] U WHERE U.OrgId = @orgId AND U.AccessLevel > = @AccessLevel
			END
			ELSE
			BEGIN
			SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
				FROM dbo.[tblUser] U WHERE U.AccessLevel > = @AccessLevel AND U.OrgId IN (SELECT [OrgId] FROM dbo.[tblOrganization] O WHERE O.Owner IN (@orgId))
				FOR XML RAW )+'</list>'
				SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),U.UserId)FROM dbo.[tblUser] U WHERE U.AccessLevel > = @AccessLevel AND U.OrgId IN (SELECT [OrgId] FROM dbo.[tblOrganization] O WHERE O.Owner IN (@orgId))
			END
			UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @LIUserID,@Date,3,@Recorded,3,'Retrieve'
			RETURN;
        END
        ELSE
		IF(@AccessLevel = 3 OR @AccessLevel = 4)
		BEGIN
			SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate','0' AS 'AccessLevel', '401|1115 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1115)+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId' FOR XML RAW )+'</list>'
			RETURN;
		END
    END
    ELSE
    BEGIN
        SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '400|1114 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1114)+CONVERT(VARCHAR,@orgId) AS 'ErrId' FOR XML RAW )+'</list>'
        EXEC upi_SystemEvents 'User',1114,3,@orgId
		RETURN;
	END
	END	
	/*Summary: If user id passed */
	IF(ISNULL(@userId,'') ! = '' )
	BEGIN
	IF EXISTS (SELECT 1 FROM dbo.tblUser WHERE UserId = @userId)
	BEGIN
		IF((@AccessLevel = 1 OR @AccessLevel = 2) 
		OR ((@AccessLevel = 3 OR @AccessLevel = 4) AND 
		EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblUser U ON O.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey and U.UserId = @userId ))
		OR ((@AccessLevel = 3 OR @AccessLevel = 4) AND
		NOT EXISTS(SELECT O.OrgId FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblUser U ON O.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey and U.UserId = @userId ) AND
		(EXISTS (SELECT S.OrgId FROM dbo.tblSession S JOIN tblUser U ON U.OrgId = S.OrgId  WHERE U.UserId = @userId AND S.SessionKey = @sessionKey ))) OR
		((@AccessLevel = 5 OR @AccessLevel = 6) AND (EXISTS (SELECT S.OrgId FROM dbo.tblSession S JOIN tblUser U ON U.OrgId = S.OrgId  WHERE U.UserId = @userId and S.SessionKey = @sessionKey ))))
		BEGIN
			IF(@AccessLevel = 1 OR @AccessLevel = 2)
			BEGIN
				SELECT '<list>'+(SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
				FROM dbo.tblUser U WHERE U.UserId = @userId
				FOR XML RAW )+'</list>'
				SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),U.UserId) FROM dbo.tblUser U WHERE U.UserId = @userId
			END
			ELSE
			BEGIN
				SELECT '<list>'+(SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
				FROM dbo.tblUser U WHERE U.UserId = @userId 
				FOR XML RAW )+'</list>'
				SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),U.UserId) FROM dbo.tblUser U WHERE U.UserId = @userId
			END
			UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @LIUserID,@Date,3,@Recorded,3,'Retrieve'
			RETURN;
		END
		ELSE
        BEGIN
			IF(@AccessLevel = 3 OR @AccessLevel = 4 OR @AccessLevel = 5 OR @AccessLevel = 6) 
			BEGIN
				SELECT '<list>'+( SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '401|1115 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1115)+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId' FOR XML RAW )+'</list>'
				EXEC upi_SystemEvents 'User',1115,3,@AccessLevel
				RETURN;
            END
        END
	END
	ELSE
    BEGIN
        SELECT '<list>'+(SELECT '0' AS 'UserId', '0' AS 'FirstName', '0' AS 'LastName','0' AS 'RegDate', '0' AS 'AccessLevel', '400|1106 '+(SELECT DESCRIPTION +'|' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1106)+CONVERT(VARCHAR,@userId) AS 'ErrId' FOR XML RAW )+'</list>'
       RETURN;
	END
	END
	/*Summary: If both are not passed */

	IF(@orgId = 0 AND (@userId = '' OR @userId IS NULL))
	BEGIN
		DECLARE @smporgId AS INT
		SET @smporgId = (SELECT s.OrgId FROM dbo.tblSession S WHERE s.SessionKey = @sessionKey)
		IF(@AccessLevel = 1 OR @AccessLevel = 2)
		BEGIN
			SELECT '<list>'+(
			SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
			FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
			FOR XML RAW )+'</list>'
		 
			SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),U.UserId)FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
			UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @LIUserID,@Date,3,@Recorded,3,'Retrieve'
			RETURN;
		END
		ELSE IF(@AccessLevel = 3 OR @AccessLevel = 4)
		BEGIN
			IF(@AccessLevel = 3)
			BEGIN
			--changed for dashboard team
				SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
				--FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
				--AND U.AccessLevel >= @AccessLevel AND U.OrgId=@smporgId
				FROM dbo.[tblUser] U WHERE U.AccessLevel > = @AccessLevel 
				AND (U.OrgId IN (SELECT [OrgId] FROM dbo.[tblOrganization] O WHERE O.Owner IN (@smporgId)) or U.OrgId IN (@smporgId))
				FOR XML RAW )+'</list>'
			END
			ELSE IF(@AccessLevel = 4)
			BEGIN
				SELECT '<list>'+(
				SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', ISNULL(CONVERT(CHAR(33),U.RegDate, 126),'1/1/1900 11:11:11AM +05:30') AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
				--FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
				--AND U.AccessLevel >= @AccessLevel AND U.OrgId=@smporgId
				FROM dbo.[tblUser] U WHERE (U.AccessLevel > = @AccessLevel OR U.AccessLevel=3)
				AND (U.OrgId IN (SELECT [OrgId] FROM dbo.[tblOrganization] O WHERE O.Owner IN (@smporgId)) or U.OrgId IN (@smporgId))
				FOR XML RAW )+'</list>'
			END
			SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),U.UserId)FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
			UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @LIUserID,@Date,3,@Recorded,3,'Retrieve'
			RETURN;
		END
		ELSE IF (@AccessLevel = 5 OR @AccessLevel = 6 OR @AccessLevel = 7 OR @AccessLevel = 8) 
		BEGIN
			SELECT '<list>'+(
			SELECT (ISNULL(U.UserId,'')) AS 'UserId', (ISNULL(U.FirstName,'')) AS 'FirstName', (ISNULL(U.LastName,''))  AS 'LastName', '0' AS 'RegDate',(ISNULL(U.AccessLevel,'')) AS 'AccessLevel', '0|accessLevel|'+CONVERT(VARCHAR,@AccessLevel) AS 'ErrId'
			FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
			FOR XML RAW )+'</list>'
		 
			SELECT @Recorded = COALESCE(@Recorded+',' , '') + CONVERT(VARCHAR(50),U.UserId)FROM dbo.[tblUser] U JOIN [tblSession] S ON U.userId = S.userId AND S.sessionKey = @sessionKey 
			UPDATE [tblSession] SET lastActivity = @Date WHERE sessionKey = @sessionKey
			EXEC upi_UserActivity @LIUserID,@Date,3,@Recorded,3,'Retrieve'
			RETURN;
		END
	END
END
--[ups_User] 'CC7BA44DCB80FD96E61643070632BF0071067ACD','6533DB39D243FF56FD6CC6FA563D0856A6316B79','',0
--[ups_User] '8539465B4B77D88914EA1B6EC8416CACD2D6E50B','737AD59F7A4B17C0C9E75906A1E9B76FC76B6AAD','',1

GO
/****** Object:  StoredProcedure [dbo].[upu_Interceptor]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- Author:		Dineshkumar G
-- Create date: 25.05.2013
-- Routine:		Interceptor
-- Method:		PUT
-- Description:	Update an Interceptor record
-- ============================================================
CREATE PROCEDURE [dbo].[upu_Interceptor] 
	
	@applicationKey			AS VARCHAR(40),
	@sessionKey				AS VARCHAR(40),
	@intId					AS INT,
	@intSerial				AS VARCHAR(12),
	@locId					AS INT,
	@forwardURL				AS VARCHAR(100),
	@deviceStatus			AS INT,
	@capture				AS INT,
	@captureMode			AS INT,
	@errorLog				AS BIT,
	@forwardType			AS INT,
	@intLocDesc				AS VARCHAR(100),
	@startURL				AS VARCHAR(100),
	@reportURL				AS VARCHAR(100),
	@scanURL				AS VARCHAR(100),
	@bkupURL				AS VARCHAR(100),
	@CmdURL					AS VARCHAR(100),
	@requestTimeoutValue	AS INT,
	@security				AS INT,
	@wpaPSK					AS VARCHAR(64),
	@ssid					AS VARCHAR(40),
	@maxBatchWaitTime		AS INT,
	@changeAutoforward		AS INT,
	@CmdChkInt				AS INT,
	@callHomeTimeoutMode    AS INT,
	@callHomeTimeoutData	AS VARCHAR(50),
	@dynCodeFormat			AS VARCHAR(5550) 
AS
BEGIN
	SET NOCOUNT ON;
	
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 201 - Created
	    
	-- Local variables DESCRIPTIONs
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @date used to store the current date and time FROM the SQL Server
	-- @accessLevel used to store AccessLevel value
	-- @sessionOrgID used to store the session OrgID
	
	DECLARE @ReturnResult		AS VARCHAR(MAX)
	DECLARE @UserId				AS VARCHAR(5)
	DECLARE @date				AS DATETIME
	DECLARE @accessLevel		AS INT
	DECLARE @updatestatus		AS VARCHAR(100)
	DECLARE @errorReturn		AS VARCHAR(1000)
	DECLARE @unauthorizedError	AS VARCHAR(1000)
	
	SET @date				 = SYSDATETIMEOFFSET();
	SET @UserId				 = (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @accessLevel		 = (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @errorReturn		 = '400'
	SET @unauthorizedError	 = '401'
	
	IF(@locId = 0) SET @locId = NULL
	IF (@changeAutoforward = 1)
	BEGIN
		IF (ISNULL(@intSerial,'') ! = '')
		BEGIN
			UPDATE tblInterceptor SET ForwardURL = @forwardURL WHERE IntSerial = @intSerial
			SET	@ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
			RETURN;
		END
		ELSE
		BEGIN
			SET	@ReturnResult = '400' SELECT @ReturnResult AS Returnvalue1
			EXEC upi_SystemEvents 'Interceptor',1804,3,''
			RETURN;
		END
	END
	IF(@accesslevel <>1 AND @accesslevel <>3 AND @accesslevel <>5 AND @accesslevel <>7 AND (ISNULL(@accesslevel,'') ! = ''))
		BEGIN
			SET	@ReturnResult = '401' SELECT @ReturnResult AS Returnvalue3
			EXEC upi_SystemEvents 'Interceptor',1802,3,@accessLevel
			RETURN;
		END
	
	/* Summary: Raise an error message if both intId and intSerial are not passed */
	IF(ISNULL(@intId,0) = 0 AND ISNULL(@intSerial,'') = '')
		BEGIN
			SET	@errorReturn = @errorReturn+'|'+'1804 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1804)	
			SELECT @errorReturn AS 'ReturnValue'
			RETURN; 
		END
		
	/* Summary: Raise an error message if both intId and intSerial are passed */
	ELSE IF(ISNULL(@intId,0) ! = 0 AND ISNULL(@intSerial,'') ! = '')
		BEGIN
			SET	@errorReturn = @errorReturn+'|'+'1803 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1803)	
			SELECT @errorReturn AS 'ReturnValue'
			RETURN; 
		END
		
	/*Summay: Use the intId or intSerial passed to search for the Interceptor record. */
	ELSE IF(ISNULL(@intId,0) ! = 0 OR ISNULL(@intSerial,'') ! = '')
		BEGIN
			/*Summary: Search for the Organization record using orgId */
			IF EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntId = @intId OR IntSerial = @intSerial)
				BEGIN
					/*Summary: Checking if accessLevel is SysAdminRW or 
					If Session[OrgId] matches Organization[owner] when accesslevel is VarAdminRW or
					If Session[OrgId] is the same as Organization[orgId] when accesslevel is either OrgAdminRW or OrgUserRW*/
					IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE OrgId = (SELECT OrgId FROM dbo.tblInterceptor WHERE IntId = @intId OR IntSerial = @intSerial))
						BEGIN
							IF((@accessLevel = 1) OR 
							((@accessLevel = 3) AND (EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblInterceptor I ON I.OrgId = O.OrgId WHERE S.SessionKey = @sessionKey AND (I.IntId = @intId OR I.IntSerial = @intSerial)))) OR
							((@accessLevel = 5 OR @accessLevel = 7 ) AND (EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.OrgId = S.OrgId INNER JOIN tblInterceptor I ON I.OrgId = O.OrgId WHERE S.SessionKey = @sessionKey AND (I.IntId = @intId OR I.IntSerial = @intSerial)))))
							BEGIN
								SET @updatestatus = 'Proceed'
							END
							ELSE
							BEGIN
								SET	@unauthorizedError = @unauthorizedError+'|'+'1805 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1805)	
								SELECT @unauthorizedError AS 'ReturnValue'
								EXEC upi_SystemEvents 'Interceptor',1805,3,@accessLevel
								RETURN;
							END
						END
						ELSE
						BEGIN
							SET	@ReturnResult = '400' SELECT @ReturnResult AS Returnvalue2
							RETURN;
						END
				END
				ELSE
				BEGIN
					IF (NOT EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntId = @intId) AND @intId <> 0)
						SET	@errorReturn = @errorReturn+'|'+'1806 '+(SELECT DESCRIPTION +' |' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1806)+CONVERT(VARCHAR,@intId)	
					ELSE IF (NOT EXISTS(SELECT 1 FROM dbo.tblInterceptor WHERE IntSerial = @intSerial)AND @intSerial <> '')
						SET	@errorReturn = @errorReturn+'|'+'1808 '+(SELECT DESCRIPTION +' |' + FieldName+'->' FROM dbo.tblErrorLog WHERE ErrorCode = 1808)+CONVERT(VARCHAR,@intSerial)
					
					SELECT @errorReturn AS 'ReturnValue'
					RETURN;
				END
			IF(@accesslevel = 1 or @accesslevel = 3)
			BEGIN
				IF(ISNULL(@locId,'') = '' AND ISNULL(@forwardURL,'') = '' AND @deviceStatus IS NULL AND @capture IS NULL
				AND @captureMode IS NULL AND @errorLog IS NULL AND @forwardType IS NULL AND ISNULL(@forwardURL,'') = '' 
				AND ISNULL(@startURL,'') = '' AND ISNULL(@reportURL,'') = '' AND ISNULL(@scanURL,'') = '' AND ISNULL(@bkupURL,'') = '' AND ISNULL(@CmdURL,'') = ''
				AND @requestTimeoutValue IS NULL AND @security IS NULL AND ISNULL(@wpaPSK,'') = '' AND ISNULL(@ssid,'') = '' AND @maxBatchWaitTime IS NULL AND @CmdChkInt IS NULL  AND @callHomeTimeoutMode IS NULL
			   AND ISNULL(@callHomeTimeoutData,'') = '' AND  ISNULL(@dynCodeFormat,'') = '')
				BEGIN
					SET	@errorReturn = @errorReturn+'|'+'1810 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1810)	
				END
			END	
			ELSE
			BEGIN
				IF(ISNULL(@locId,'') = '' AND ISNULL(@forwardURL,'') = '' AND @deviceStatus IS NULL AND @capture IS NULL 
				AND @captureMode IS NULL AND @errorLog IS NULL AND @forwardType IS NULL)
				BEGIN
					SET	@errorReturn = @errorReturn+'|'+'1813 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1813)	
				END
				IF(ISNULL(@startURL,'')! = '' OR ISNULL(@reportURL,'')! = '' OR ISNULL(@scanURL,'')! = '' OR ISNULL(@bkupURL,'')! = '' OR ISNULL(@CmdURL,'')! = ''
				AND @requestTimeoutValue IS NOT NULL OR @security IS NOT NULL OR ISNULL(@wpaPSK,'')! = '' OR ISNULL(@ssid,'')! = '' OR @maxBatchWaitTime IS NOT NULL OR @CmdChkInt IS NOT NULL)
				BEGIN
					SET	@errorReturn = @errorReturn+'|'+'1815 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1815)	
				END
			END
			/*Summary: Search for the Location record using locId */
			IF(ISNULL(@locId,'') ! = '')
				BEGIN
					IF EXISTS(SELECT 1 FROM dbo.tblLocation WHERE LocId = @locId)
						BEGIN
							IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE OrgId = (SELECT OrgId FROM dbo.tblLocation WHERE LocId = @locId))
								BEGIN
									IF((@accessLevel = 1) OR 
									((@accessLevel = 3) AND (EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON L.OrgId = O.OrgId WHERE S.SessionKey = @sessionKey AND L.LocId = @locId))) OR
									((@accessLevel = 5 OR @accessLevel = 7 ) AND (EXISTS (SELECT O.OrgId FROM dbo.tblOrganization O JOIN tblSession S ON O.OrgId = S.OrgId INNER JOIN tblLocation L ON L.OrgId = O.OrgId WHERE S.SessionKey = @sessionKey AND L.LocId = @locId))))
									BEGIN
										SET @updatestatus = 'Proceed'
									END
									ELSE
									BEGIN
										SET	@unauthorizedError = @unauthorizedError+'|'+'1809 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1809)	
										SELECT @unauthorizedError AS 'ReturnValue'
										EXEC upi_SystemEvents 'Location',1809,3,@locId
										RETURN;
									END
								END
							ELSE
							BEGIN
								SET	@ReturnResult = '400' SELECT @ReturnResult AS Returnvalue1
								RETURN;
							END
						END
					ELSE
						BEGIN
							SET	@errorReturn = @errorReturn+'|'+'1807 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1807)	
							SELECT @errorReturn AS 'ReturnValue'
							RETURN;
						END
				END 
		END	
		/*Summary: Update the Interceptor record using the passed values */
		IF(@errorReturn LIKE '%|%')
			 BEGIN
				SELECT @errorReturn AS ReturnData
				RETURN;
			 END
		ELSE IF(@updatestatus = 'Proceed')	
			BEGIN
				IF(@accessLevel = 1 or @accesslevel = 3)
					BEGIN		
						--COALESCE(NULLIF(@locId,''), LocId)
						UPDATE tblInterceptor SET LocId = COALESCE(NULLIF(@locId,''), LocId), 
						forwardURL = COALESCE(@forwardURL,forwardURL), DeviceStatus = COALESCE(@deviceStatus,DeviceStatus),Capture = COALESCE(@capture,Capture), 
					    CaptureMode = COALESCE(@captureMode,CaptureMode),ErrorLog = COALESCE(@errorLog,ErrorLog),ForwardType = COALESCE(@forwardType,ForwardType),
					    IntLocDesc = COALESCE(@intLocDesc,IntLocDesc), MaxBatchWaitTime = COALESCE(@maxBatchWaitTime,MaxBatchWaitTime), StartURL = COALESCE(@startURL,StartURL), 
					    ReportURL = COALESCE(@reportURL,ReportURL),ScanURL = COALESCE(@scanURL,ScanURL), BkupURL = COALESCE(@bkupURL,BkupURL), CmdURL = COALESCE(@CmdURL,CmdURL),RequestTimeoutValue = COALESCE(@requestTimeoutValue,RequestTimeoutValue),
						[Security] = COALESCE(@security,[Security]), WpaPSK = COALESCE(@wpaPSK,WpaPSK), SSId = COALESCE(@ssid,SSId),CmdChkInt = COALESCE(@CmdChkInt,CmdChkInt), CallHomeTimeoutMode = COALESCE(@CallHomeTimeoutMode,CallHomeTimeoutMode),
						CallHomeTimeoutData = COALESCE(@CallHomeTimeoutData,CallHomeTimeoutData), DynCodeFormat = COALESCE(@DynCodeFormat,DynCodeFormat)
						WHERE IntId = @intId OR IntSerial = @intSerial
						
						UPDATE tblInterceptor SET MaxBatchWaitTime = NULL WHERE (IntId = @intId OR IntSerial = @intSerial) AND MaxBatchWaitTime='999999' 
						UPDATE tblInterceptor SET CmdChkInt = NULL WHERE (IntId = @intId OR IntSerial = @intSerial) AND CmdChkInt='999999' 
						UPDATE tblInterceptor SET RequestTimeoutValue = NULL WHERE (IntId = @intId OR IntSerial = @intSerial) AND RequestTimeoutValue='999999' 
					END
				ELSE
					BEGIN
					    UPDATE tblInterceptor SET LocId = COALESCE(NULLIF(@locId,''), LocId), 
						forwardURL = COALESCE(@forwardURL,forwardURL), DeviceStatus = COALESCE(@deviceStatus,DeviceStatus),Capture = COALESCE(@capture,Capture), 
					    CaptureMode = COALESCE(@captureMode,CaptureMode),ErrorLog = COALESCE(@errorLog,ErrorLog),ForwardType = COALESCE(@forwardType,ForwardType),
					    IntLocDesc = COALESCE(@intLocDesc,IntLocDesc), MaxBatchWaitTime = COALESCE(@maxBatchWaitTime,MaxBatchWaitTime) WHERE IntId = @intId OR IntSerial = @intSerial
					    
					    UPDATE tblInterceptor SET MaxBatchWaitTime = NULL WHERE (IntId = @intId OR IntSerial = @intSerial) AND MaxBatchWaitTime='999999' 
					END
				UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
				EXEC upi_UserActivity @UserId,@date,0,@applicationKey,1,'Interceptor'
				SET	@ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
			END
END

--exec [upu_Interceptor] 'D2697032FABBD46F4FB501CAE13FBFA009D791D7','FC11A70B5D38F80BE1994B856B54C91F4D94DF20','','1234567890AB',NULL,Forwardurl,NULL,NULL,NULL,NULL,NULL,NULL,'starturl',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
--exec [upi_Interceptor] 'applicatiokey','sessionkey','intserial',locid,orgid
--exec [upu_Interceptor] 'A1A2A3A4A5A6A7A8','017D454CDE35FABC1821C927669A15C28A09BB7B','62','',0,url,2,0,0,NULL,0,null,NULL,NULL,NULL,NULL,0,0,NULL,NULL,0,0,0
--exec [upu_Interceptor] '3053FFA62F1E7B2E995C310296D50091ABF17B3E','FAB38949C5E271DDC7AD1EE9B4D21A34A6D41C20',NULL,12,3,'test',1,0,1,0,0,vvpnagar,'test',test,test,test,1,1,0,0,1,30,1
--exec [upu_Interceptor] '1A5C4A06A04960E63C4E8E6E4EE0EE14A437986F','96E2F8CE07BE1D5D345C026C0A15AFDC19B78049',10,NULL,NULL,'http://localhost:2285/',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL


GO
/****** Object:  StoredProcedure [dbo].[upu_Location]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- Author:		Prakash G
-- Create date: 21.05.2013
-- Routine:		Location
-- Method:		Put
-- Description:	Updates an existing Location record
-- ============================================================
CREATE PROCEDURE [dbo].[upu_Location] 
	
	@applicationKey AS VARCHAR(40),
	@sessionKey		AS VARCHAR(40),
	@locId			AS INT,
	@unitSuite		AS VARCHAR(15),
	@street	        AS NVARCHAR(200),   
	@city	        AS NVARCHAR(50),
	@state			AS NVARCHAR(100),
	@country		AS VARCHAR(50),
	@postalCode	    AS VARCHAR(10),
	@locType	    AS VARCHAR(50),
	@locSubType	    AS VARCHAR(50),
	@locDesc	    AS VARCHAR(50),
	@latitude       AS NUMERIC(18,10),
	@Longitude      AS NUMERIC(18,10)
	
	AS
	BEGIN
	 SET NOCOUNT ON;
	 
	-- Output DESCRIPTIONs
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	    
	-- Local variables DESCRIPTIONs
	-- @ReturnResult used to return results
	-- @UserId used to store userId value	
	-- @Date used to store the current date and time FROM the SQL Server
	-- @AccessLevel used to store AccessLevel value
	-- @ErrorReturn used to store the error message
	
	DECLARE @ReturnResult	AS VARCHAR(MAX)
	DECLARE @UserId			AS VARCHAR(5)
	DECLARE @Date			AS datetimeoffset(7)
	DECLARE @AccessLevel	AS INT
	DECLARE @ErrorReturn	AS VARCHAR(MAX)
	
	SET @ErrorReturn	 = '400'
	SET @Date			 = SYSDATETIMEOFFSET();
	SET @UserId			 = (SELECT userId FROM dbo.[tblSession] WITH (NOLOCK) WHERE sessionKey = @sessionKey)
	SET @AccessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WITH (NOLOCK) WHERE @sessionKey = sessionKey)
	
	/* Summary:Set locId to zero if locId is null or empty */
	IF(ISNULL(@locId,'') = '') SET @locId = 0;
	
	/* Summary : if Session[accessLevel] = SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW  then do the following */
    IF(@AccessLevel = 1 or @AccessLevel = 3 or @AccessLevel = 5 or @AccessLevel = 7)
    BEGIN
    
	/*Summary:Raise an Error Message.If a matching Locid is not Passed*/
    IF(@locId = 0)
    BEGIN
        SET	@ErrorReturn = @ErrorReturn+'|1602 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1602)
    END
    
    /* Summary: Raise an error message . If Location record is not found for the given Location in the Location table. */
    ELSE IF(NOT EXISTS(SELECT LocId FROM dbo.[tblLocation] WITH (NOLOCK) WHERE LocId = @locId))
    BEGIN
		SET	@ErrorReturn = @ErrorReturn+'|1606 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1606)+'->'+CONVERT(VARCHAR,@Locid)
    END
    
    /* Summary: Raise an error message .if at least one optional field not passed */
    IF(ISNULL(@unitSuite,'') = '' AND ISNULL(@street,'') = '' AND ISNULL(@city,'') = '' AND ISNULL(@state,'') = '' AND ISNULL(@country,'') = ''AND ISNULL(@postalCode,'') = ''
    AND ISNULL(@locType,'') = '' AND ISNULL(@locSubType,'') = '' AND ISNULL(@locDesc,'') = '' AND ISNULL(@latitude,'') = '' AND ISNULL(@Longitude,'') = '')
    BEGIN
        SET	@ErrorReturn = @ErrorReturn+'|1607 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1607)
    END
    
    /* Summary: Raise an error message (400).If any errors set in errors return field */
    IF(@ErrorReturn LIKE '%|%')
	BEGIN
		SELECT @ErrorReturn AS ReturnData
		RETURN;
	END
   
    /* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */
	ELSE
	IF EXISTS(SELECT 1 FROM dbo.[tblLocation] WITH (NOLOCK) JOIN tblOrganization WITH (NOLOCK) ON [tblOrganization].orgID = [tblLocation].orgID WHERE LocId = @locId)
		BEGIN
			/* Summary: If the Organization record is found, check if the user is authorized to make this request */
			/*  Summary: If accessLevel is SysAdminRW */
			IF(@AccessLevel = 1)
				BEGIN
				   	UPDATE [tblLocation] set [UnitSuite] =@unitSuite,[Street] = COALESCE(NULLIF(@street,''),[Street]),[City] = COALESCE(NULLIF(@city,''),[City]),
					[State] = COALESCE(NULLIF(@state,''),[State]),[Country] = COALESCE(NULLIF(@country,''),[Country]),[PostalCode] = COALESCE(NULLIF(@postalCode,''),[PostalCode]),
					[LocType] = @locType,
					[LocSubType] = @locSubType,[LocDesc] = @locDesc,Latitude = COALESCE(@latitude,Latitude),Longitude = COALESCE(@longitude,Longitude)
					WHERE [LocId] = @locId
					UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
					EXEC upi_UserActivity @UserId,@Date,2,@locId,3,'PUT'
					SET @ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
					RETURN;
				END
			/*  Summary: If accessLevel is VarAdminRW, then check if Session[OrgId] is the owner of Location[OrgId] other wise 401  */
			ELSE IF(@AccessLevel = 3)
				BEGIN
					IF EXISTS(SELECT 1 FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId INNER JOIN tblLocation L ON O.OrgId = L.OrgId WHERE L.locid  = @locId  and s.sessionkey = @sessionKey)
				    BEGIN
				       	UPDATE [tblLocation] set [UnitSuite] = @unitSuite,[Street] = COALESCE(NULLIF(@street,''),[Street]),[City] = COALESCE(NULLIF(@city,''),[City]),
						[State] = COALESCE(NULLIF(@state,''),[State]),[Country] = COALESCE(NULLIF(@country,''),[Country]),[PostalCode] = COALESCE(NULLIF(@postalCode,''),[PostalCode]),
						[LocType] = @locType,
						[LocSubType] = @locSubType,[LocDesc] = @locDesc,Latitude = COALESCE(@latitude,Latitude),Longitude = COALESCE(@longitude,Longitude)
						WHERE [LocId] = @locId
						UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
						EXEC upi_UserActivity @UserId,@Date,2,@locId,3,'PUT'
					    SET @ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
						RETURN;
					END
					ELSE
					BEGIN
					    SET @returnResult = '401|1601 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1601)+'->'+CONVERT(VARCHAR,@AccessLevel)
						SELECT @returnResult AS Returnvalue
						EXEC upi_SystemEvents 'Location',1601,3,@AccessLevel
						RETURN;
					END
				END
			/* Summary: If accessLevel is OrgAdminRW or OrgUserRW, then check if Session[OrgId] is the same asLocation[OrgId]  */
			ELSE IF(@AccessLevel = 5 OR @AccessLevel = 7)
				BEGIN
				 	IF EXISTS(SELECT 1 FROM dbo.[tblLocation] JOIN [tblSession] ON tblLocation.OrgId = tblSession.orgid  WHERE  locId = @locId AND sessionKey = @sessionKey )
						BEGIN 
						   	UPDATE [tblLocation] set [UnitSuite] = @unitSuite,[Street] = COALESCE(NULLIF(@street,''),[Street]),[City] = COALESCE(NULLIF(@city,''),[City]),
							[State] = COALESCE(NULLIF(@state,''),[State]),[Country] = COALESCE(NULLIF(@country,''),[Country]),[PostalCode] = COALESCE(NULLIF(@postalCode,''),[PostalCode]),
							[LocType] = @locType,
							[LocSubType] = @locSubType,[LocDesc] = @locDesc,Latitude = COALESCE(@latitude,Latitude),Longitude = COALESCE(@longitude,Longitude)
							WHERE [LocId] = @locId
							UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
							EXEC upi_UserActivity @UserId,@Date,2,@locId,3,'PUT'
							SET @ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
							RETURN;
			    		END
			    	/* Summary:Raise an error Message,If user is not scope with organization */
					ELSE
						BEGIN
						   SET @returnResult = '401|1601 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1601)+'->'+CONVERT(VARCHAR,@AccessLevel)
						   SELECT @returnResult AS Returnvalue
						   EXEC upi_SystemEvents 'Location',1601,3,@AccessLevel
						   RETURN;
						END
				END
		END
		/* Summary: Raise an error message (400). If Organization record is not found for the given Organization in the Organization table. */	    
		ELSE
		BEGIN
			SET @returnResult = '400|1605 '+(SELECT DESCRIPTION +'|' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1605)+'->'+CONVERT(VARCHAR,@Locid)
			SELECT @returnResult AS Returnvalue
			EXEC upi_SystemEvents 'Location',1605,3,@Locid
			RETURN;
		   END
		END
	/*Summary:Raise an Error Message (401).if Session[accessLevel] ! = SysAdminRW or VarAdminRW or OrgAdminRW or OrgUserRW */
	ELSE
	BEGIN
		SET @returnResult = '401|1601 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1601)+CONVERT(VARCHAR,isnull(@AccessLevel,'0'))
		SELECT @returnResult AS Returnvalue
		EXEC upi_SystemEvents 'Location',1601,3,@AccessLevel
		RETURN;
	END
END
--exec '@applicationKey','@sessionKey',@locId,'@unitSuite','@street','@city','@state','@country','@postalCode','@locType','@locSubType','@locDesc'
--exec [upu_Location] 'AB8D7AA5DEC91B90F85158CC223916E7C3DEAD52','EC5796342DA4C46015A23804877C6729A46B6369','1','','','','','','','','','','52.650616000000000','-113.663838000000000'


GO
/****** Object:  StoredProcedure [dbo].[upu_Organization]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author:		Dinesh
-- Create date: 26.4.2013
-- Routine:		Organization
-- Method:		PUT
-- Description:	Update Organization Records
--(Need Front end check Follow)Not Done check at least one optional field supplied,correct data formatting
-- ==============================================================================================================
CREATE PROCEDURE [dbo].[upu_Organization]
	
	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@orgId				AS INT,
	@orgName			AS NVARCHAR(100),
	@ipAddress			AS VARCHAR(15),
	@applicationKeyOrg	AS VARCHAR(40)
	
AS
BEGIN

	-- Output DESCRIPTIONs
	-- 400 - Bad Request
	-- 401 - Unauthorized
	-- 200 - Success
	
	-- Local variables DESCRIPTIONs
	-- @ReturnResult used to return results
	-- @errorReturn used to set Error returns
	-- @accessLevel used to store AccessLevel value
	-- @UserId used to get userid FROM user
	-- @IsExist used to find record already exist
	-- @date used to store the current date and time FROM the SQL Server
	
	 SET NOCOUNT ON;
	 DECLARE @ReturnResult		AS VARCHAR(MAX)
	 DECLARE @UserId			AS VARCHAR(5)
	 DECLARE @date				AS DATETIMEOFFSET(7)
	 DECLARE @IsExist			AS INT
	 DECLARE @accesslevel		AS INT
	 DECLARE @eventData			AS VARCHAR(1000)
	 DECLARE @md5ApplicationKey AS VARCHAR(40)
	 DECLARE @errorReturn		AS VARCHAR(1000)
	 
	 SET @date			 = SYSDATETIMEOFFSET()
	 SET @UserId		 = (SELECT userId FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)
	 SET @accessLevel	 = (SELECT accessLevel FROM dbo.[tblSession] WHERE sessionKey = @sessionKey)
	 SET @errorReturn	 = '400'
	 
	  /* if Session[accessLevel] ! = SysAdminRW or VarAdminRW then return HTTP code “401 Unauthorized */
	 IF(@accesslevel <>1 AND @accesslevel <>3)
		BEGIN
			SET	@ReturnResult = '401' SELECT @ReturnResult AS Returnvalue
			EXEC upi_SystemEvents 'Organization',1402,3,@accessLevel
			RETURN;
		END
		
	 /*Use the passed OrgId to search the Organization record*/
	 SET @IsExist = (SELECT COUNT(*) FROM dbo.tblOrganization WHERE orgID = @orgId)	
	 	IF(@IsExist = 0)
			BEGIN
				SET	@ReturnResult = @errorReturn+'|1404 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1404)+'->'+CONVERT(VARCHAR,@orgId)		
				SELECT @ReturnResult AS Returnvalue	
				EXEC upi_SystemEvents 'Organization',1404,3,@orgId
				RETURN; 
			END
			
	 /* check Mandatory fields are supplied */
	 IF(@orgId = '' OR @orgId IS NULL)
		BEGIN
			SET	@ReturnResult = @errorReturn+'|1403 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1403)	
			SELECT @ReturnResult AS Returnvalue				
			EXEC upi_SystemEvents 'Organization',1403,3,''
			RETURN; 
		END
	
	/* If applicationKey or ipAddress passed and Session[accessLevel] ! = SysAdminRW then 
	   add error message to errors return field*/
	 IF((@applicationKeyOrg IS NOT NULL and @applicationKeyOrg <>'') or (@ipAddress IS NOT NULL and @ipAddress<>''))
		BEGIN
			IF(@accessLevel = 3)
				BEGIN
					SET	@errorReturn = @errorReturn+'|1405 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1405)
				END
		END
	
	/* if applicationKeyOrg is passed and it is empty, thenOrganization[applicationKey] = MD5 hexdigest of orgId
	   if applicationKeyOrg is passed and it is not empty, thenOrganization[applicationKey] = applicationKeyOrg
	*/
	IF(@applicationKeyOrg = '' )
		BEGIN
			SET @md5ApplicationKey = (SELECT orgID FROM dbo.tblOrganization WHERE orgID = @orgId)
			SET @md5ApplicationKey = (SELECT CONVERT(VARCHAR(40),HashBytes('SHA1', @md5ApplicationKey),2))
		END
	ELSE
		BEGIN
			SET @md5ApplicationKey = (SELECT CONVERT(VARCHAR(40),HashBytes('SHA1', @applicationKeyOrg),2))
		END
	
	/* Using the passed orgID, check Organization[Owner] against Session[OrgId] If values Match Update Organization
	   Values Not Match check passedorgID against Session[OrgId]
	   otherwise Return Eroor:401 Unauthorized*/
	   
	  IF(@accessLevel = 1)
		BEGIN
			IF(ISNULL(@orgName,'') = '' AND ISNULL(@ipAddress,'') = '' AND ISNULL(@applicationKeyOrg,'') = '')
			BEGIN
				SET	@errorReturn = @errorReturn+'|1407 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1407)
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE ApplicationKey = @applicationKeyOrg AND OrgId = @orgId)
				BEGIN
					SET @md5ApplicationKey = NULL
				END
			    IF EXISTS(SELECT 1 FROM dbo.tblOrganization WHERE ApplicationKey = @md5ApplicationKey AND OrgId<>@orgId)
				BEGIN
					SET	@errorReturn = @errorReturn+'|1408 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1408)
					SELECT @errorReturn AS ReturnData
					RETURN;
				END
				UPDATE tblOrganization SET orgName = COALESCE(NULLIF(@orgName,''), orgName),
				applicationKey = COALESCE(@md5ApplicationKey,applicationKey),
				ipAddress = COALESCE(@ipAddress,ipAddress) WHERE orgID = @orgId
			END
		END
	  IF(@accessLevel = 3)
		BEGIN
			IF(ISNULL(@orgName,'') = '')
			BEGIN
				SET	@errorReturn = @errorReturn+'|1406 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1406)
			END
			ELSE IF EXISTS (SELECT 1 FROM dbo.tblOrganization O INNER JOIN tblSession S ON O.Owner = S.OrgId WHERE S.SessionKey = @sessionKey AND O.OrgId = @orgId)
			BEGIN
				UPDATE tblOrganization SET orgName =COALESCE(NULLIF(@orgName,''), orgName) WHERE orgID = @orgId
			END
			ELSE
			BEGIN
				SET	@ReturnResult = '401'+'|1402 '+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1402)
				SELECT @ReturnResult AS Returnvalue
				EXEC upi_SystemEvents 'Organization',1402,3,@accessLevel
				RETURN;
			END
		END
	
	IF(@errorReturn LIKE '%|%')
	BEGIN
		SELECT @errorReturn AS ReturnData
		RETURN;
	END
	
	UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
	EXEC upi_UserActivity @UserId,@date,2,@orgId,1,'Update'
	SET @ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
	 
END
--[upu_Organization] '7D7530A2E5C5D2F4E0E53684FCA7D521','6B05DB6DC930458646C3F560481C38E61E233D44',1,'Cozumo','192.168.1.13','4A79DB236006635250C7470729F1BFA30DE691D7'


GO
/****** Object:  StoredProcedure [dbo].[upu_User]    Script Date: 2015-07-08 11:47:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		DineshCozumoTestDB
-- Create date: 15.5.2013
-- Routine:		User
-- Method:		PUT
-- Description:	updates a User record
-- ==============================================
CREATE PROCEDURE [dbo].[upu_User]

	@applicationKey		AS VARCHAR(40),
	@sessionKey			AS VARCHAR(40),
	@userId				AS VARCHAR(5),
	@firstName			AS NVARCHAR(50),
	@lastName			AS NVARCHAR(50),
	@password			AS VARCHAR(40)

AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @accessLevel		AS INT
    DECLARE @returnResult		AS VARCHAR(20)
    DECLARE @date				As DATETIMEOFFSET(7)
    DECLARE @LIUserID			AS VARCHAR(5)
    DECLARE @errorReturn		AS VARCHAR(1000)
    DECLARE @unauthorizedReturn AS VARCHAR(1000)
	
	SET @LIUserID			 = (SELECT UserId FROM dbo.tblSession WHERE SessionKey = @sessionKey)
	SET @errorReturn		 = '400'
	SET @unauthorizedReturn	 = '401'
	SET @date				 = SYSDATETIMEOFFSET()
   
    /*Summary: Check if at least one of the optional fields has been passed */
    IF(ISNULL(@firstName,'') = '' AND ISNULL(@lastName,'') = '' AND ISNULL(@password,'') = '')
    BEGIN
		SET	@errorReturn = @errorReturn+'|'+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1208)
    END
    
    IF(@password IS NOT NULL AND @password <> '')
	BEGIN
		SET @password = (SELECT CONVERT(VARCHAR(40),HashBytes('SHA1', @password),2))
    END
    ELSE
    BEGIN
		SET @password = (SELECT [Password] FROM dbo.tblUser WHERE UserId = @userId)
    END
 
	IF(@userId IS NOT NULL AND @userId <> '')
	BEGIN
		SET @accessLevel = (SELECT accessLevel FROM dbo.[tblSession] WHERE SessionKey = @sessionKey)
		SET @accessLevel = (SELECT CASE WHEN @accessLevel IS NULL THEN 0 ELSE @accessLevel END)
		
		IF(@accessLevel<>1 AND @accessLevel<>3 AND @accessLevel<>5)
		BEGIN
			SET	@errorReturn = @errorReturn+'|'+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1210)
			SELECT @errorReturn AS ReturnData
			RETURN;
		END
		IF(@errorReturn LIKE '%|%')
		BEGIN
			SELECT @errorReturn AS ReturnData
			RETURN;
		END
		IF(@accessLevel = 1 OR @accessLevel = 3 OR @accessLevel = 5)
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.tblUser WHERE UserId = @userId)
			BEGIN
				IF(@accessLevel = 1)
				BEGIN
					UPDATE dbo.tblUser SET FirstName = COALESCE(NULLIF(@firstName,''), FirstName),
					LastName = COALESCE(NULLIF(@lastName,''), LastName),[Password] = COALESCE(NULLIF(@password,''), [Password])
					WHERE UserId = @userId	
				END
				ELSE IF(@accessLevel = 3)
				BEGIN
					IF EXISTS(SELECT 1 FROM dbo.tblOrganization O INNER JOIN dbo.tblSession S ON O.Owner = S.OrgId INNER JOIN dbo.tblUser U ON O.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey and U.UserId = @userId )
					BEGIN
						
						UPDATE dbo.tblUser SET FirstName = COALESCE(NULLIF(@firstName,''), FirstName),
						LastName = COALESCE(NULLIF(@lastName,''), LastName),[Password] = COALESCE(NULLIF(@password,''), [Password])
						WHERE UserId = @userId									
					END
					ELSE IF EXISTS(SELECT 1 FROM dbo.tblSession S INNER JOIN dbo.tblUser U ON S.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey AND @userId = U.UserId)
					BEGIN
						UPDATE dbo.tblUser SET FirstName = COALESCE(NULLIF(@firstName,''), FirstName),
						LastName = COALESCE(NULLIF(@lastName,''), LastName),[Password] = COALESCE(NULLIF(@password,''), [Password])
						WHERE UserId = @userId									
					END
					ELSE
					BEGIN
						SET	@unauthorizedReturn = @unauthorizedReturn+'|'+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1216)
						SELECT @unauthorizedReturn
						EXEC upi_SystemEvents 'Location',1216,3,@userId
						RETURN;
					END
				END
				ELSE IF(@accessLevel = 5)
				BEGIN
					IF EXISTS(SELECT 1 FROM dbo.tblSession S INNER JOIN dbo.tblUser U ON S.OrgId = U.OrgId WHERE S.SessionKey = @sessionKey AND @userId = U.UserId)
					BEGIN
						UPDATE dbo.tblUser SET FirstName = COALESCE(NULLIF(@firstName,''), FirstName),
						LastName = COALESCE(NULLIF(@lastName,''), LastName),[Password] = COALESCE(NULLIF(@password,''), [Password])
						WHERE UserId = @userId	
					END
					ELSE
					BEGIN
						SET	@unauthorizedReturn = @unauthorizedReturn+'|'+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1216)
						SELECT @unauthorizedReturn
						EXEC upi_SystemEvents 'Location',1216,3,@userId
						RETURN;
					END
				END
			END
			ELSE
			BEGIN
				SET	@errorReturn = @errorReturn+'|'+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1215)
				SELECT @errorReturn AS ReturnData
				RETURN;
			END
		END	
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT 1 FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
		BEGIN
			SET @UserId = (SELECT userId FROM dbo.[tblSession] WHERE  sessionKey = @sessionKey)
			UPDATE dbo.tblUser SET FirstName = COALESCE(NULLIF(@firstName,''), FirstName),
			LastName = COALESCE(NULLIF(@lastName,''), LastName),[Password] = COALESCE(NULLIF(@password,''), [Password])
			WHERE UserId = @userId	
		END
		ELSE
		BEGIN
			SET	@errorReturn = @errorReturn+'|'+(SELECT DESCRIPTION +' |' + FieldName FROM dbo.tblErrorLog WHERE ErrorCode = 1218)
			SELECT @errorReturn
			RETURN;
		END
	END
	IF(@errorReturn LIKE '%|%')
	BEGIN
		SELECT @errorReturn AS ReturnData
		RETURN;
	END	
	ELSE
	BEGIN
		UPDATE [tblSession] SET lastActivity = SYSDATETIMEOFFSET() WHERE sessionKey = @sessionKey
		EXEC upi_UserActivity @UserId,@date,2,@UserId,3,'Update'
		SET @ReturnResult = '200' SELECT @ReturnResult AS Returnvalue
	END
END
--[upu_User] '7C4A8D09CA3762AF61E59520943DC26494F8941B','BCE6EC313C8F70F2DC52F21A30AF3856761DF999','001RW','Arcras','Six','Welcome123*'


GO
