USE [Takamul]
GO
/****** Object:  UserDefinedFunction [dbo].[fnCheckUserStatus]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 02-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get TRM Report Number
-- =============================================
CREATE FUNCTION [dbo].[fnCheckUserStatus]
(
    @Pin_UserId int
)
RETURNS int -- Return Error
AS
BEGIN
    Declare @v_Count int = 0;
    Declare @v_TicketSubmissionIntervalDays int = 0;
    Declare @v_Error int = 1;

	-- Check Application Expired Status
	SELECT 
		@v_Count = COUNT(*) 
	FROM    
		USERS U
	INNER JOIN APPLICATIONS A ON A.ID = U.APPLICATION_ID
	WHERE U.ID = @Pin_UserId AND A.APPLICATION_EXPIRY_DATE > GETDATE();
	
	IF @v_Count < 1
	BEGIN
		SET @v_Error = -5; -- Application Expired
		RETURN @v_Error;
	END   
	
	-- Check OTP Validated Status
	SELECT 
		@v_Count = COUNT(CASE UD.IS_OTP_VALIDATED when 0 then 1 else null end) 
	FROM    
		USER_DETAILS UD
	WHERE USER_ID = @Pin_UserId;
	
	IF @v_Count > 0
	BEGIN
		SET @v_Error = -6; -- OTP not verified
		RETURN @v_Error;
	END   

	-- Check User Blocked Status
	SELECT 
		@v_Count = COUNT(CASE U.IS_BLOCKED when 1 then 1 else null end) 
	FROM    
		USERS U
	WHERE ID = @Pin_UserId;
	
	IF @v_Count > 0
	BEGIN
		SET @v_Error = -7; -- User is blocked
		RETURN @v_Error;
	END   

	-- Check Ticket Restriction Status
	SELECT 
		@v_Count = COUNT(CASE UD.IS_TICKET_SUBMISSION_RESTRICTED when 1 then 1 else null end) 
	FROM    
		USER_DETAILS UD
	WHERE UD.USER_ID = @Pin_UserId;
	
	IF @v_Count > 0
	BEGIN
		SET @v_Error = -8; -- Ticket Restriction Status
		RETURN @v_Error;
	END   

	-- Check Ticket Submission Interval Days Status
	SELECT 
		@v_Count = DATEDIFF(day,COALESCE(UD.LAST_TICKET_SUBMISSION_DATE,GETDATE()),GETDATE()),
		@v_TicketSubmissionIntervalDays = UD.TICKET_SUBMISSION_INTERVAL_DAYS
	FROM    
		USER_DETAILS UD
	INNER JOIN USERS U ON U.ID = UD.USER_ID
	WHERE UD.USER_ID = @Pin_UserId;
	
	IF @v_TicketSubmissionIntervalDays > 0 AND @v_Count >= @v_TicketSubmissionIntervalDays
	BEGIN
		SET @v_Error = -9; -- Ticket Submission Interval Days Status
		RETURN @v_Error;
	END   

    RETURN  @v_Error

END

GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split](@String varchar(MAX), @Delimiter char(1))       
    returns @temptable TABLE (items varchar(MAX))       
    as       
    begin      
        declare @idx int       
        declare @slice varchar(8000)       

        select @idx = 1       
            if len(@String)<1 or @String is null  return       

        while @idx!= 0       
        begin       
            set @idx = charindex(@Delimiter,@String)       
            if @idx!=0       
                set @slice = left(@String,@idx - 1)       
            else       
                set @slice = @String       

            if(len(@slice)>0)  
                insert into @temptable(Items) values(@slice)       

            set @String = right(@String,len(@String) - @idx)       
            if len(@String) = 0 break       
        end   
    return 
    end;

GO
/****** Object:  Table [dbo].[APPLICATION_CHANGE_LOGS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APPLICATION_CHANGE_LOGS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[LOG_COMMENT] [varchar](max) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_APPLICATION_CHANGE_LOGS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[APPLICATION_ENTITIES]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APPLICATION_ENTITIES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ENTITY_NAME] [varchar](50) NULL,
	[ENTITY_CONTROLLER] [nchar](50) NULL,
 CONSTRAINT [PK_APPLICATION_ENTITIES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[APPLICATION_INFO]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[APPLICATION_INFO](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[TITLE] [nvarchar](100) NULL,
	[DESCRIPTION] [nvarchar](max) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_APPLICATION_INFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[APPLICATION_MASTER_SETTINGS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APPLICATION_MASTER_SETTINGS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SETTINGS_NAME] [varchar](50) NULL,
 CONSTRAINT [PK_APPLICATION_MASTER_SETTINGS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[APPLICATION_PRIVILLAGES]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[APPLICATION_PRIVILLAGES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[USER_ID] [int] NULL,
	[APPLICATION_ENTITY_ID] [int] NULL,
	[IS_ADD_PERMISSION] [bit] NULL,
	[IS_EDIT_PERMISSION] [bit] NULL,
	[IS_DELETE_PERMISSION] [bit] NULL,
	[IS_VIEW_PERMISSION] [bit] NULL,
	[IS_REPORT_VIEW_PERMISSION] [bit] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_ROLE_PRIVILLAGES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[APPLICATION_SETTINGS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[APPLICATION_SETTINGS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[APPLICATION_MASTER_SETTING_ID] [int] NULL,
	[SETTINGS_VALUE] [nvarchar](500) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[APPLICATION_USERS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[APPLICATION_USERS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[USER_ID] [int] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_APPLICATION_USERS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[APPLICATIONS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APPLICATIONS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_NAME] [nvarchar](200) NULL,
	[APPLICATION_LOGO_PATH] [varchar](300) NULL,
	[DEFAULT_THEME_COLOR] [varchar](50) NULL,
	[APPLICATION_EXPIRY_DATE] [smalldatetime] NULL,
	[APPLICATION_TOKEN] [varchar](50) NULL,
	[IS_ACTIVE] [bit] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_APPLICATIONS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AREA_MASTER]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AREA_MASTER](
	[ID] [int] NULL,
	[AREA_CODE] [varchar](50) NULL,
	[AREA_DESC_ARB] [nvarchar](100) NULL,
	[AREA_DESC_ENG] [nvarchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DB_LOGS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DB_LOGS](
	[ERROR_ID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[SP_NAME] [nvarchar](500) NULL,
	[ERROR_DESC] [nvarchar](max) NULL,
	[CREATED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_DB_Logs] PRIMARY KEY CLUSTERED 
(
	[ERROR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ELMAH_Error](
	[ErrorId] [uniqueidentifier] NOT NULL,
	[Application] [nvarchar](60) NOT NULL,
	[Host] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Source] [nvarchar](60) NOT NULL,
	[Message] [nvarchar](500) NOT NULL,
	[User] [nvarchar](50) NOT NULL,
	[StatusCode] [int] NOT NULL,
	[TimeUtc] [datetime] NOT NULL,
	[Sequence] [int] IDENTITY(1,1) NOT NULL,
	[AllXml] [ntext] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EVENTS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENTS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[EVENT_NAME] [nvarchar](300) NULL,
	[EVENT_DESCRIPTION] [nvarchar](1000) NULL,
	[EVENT_DATE] [smalldatetime] NULL,
	[EVENT_LOCATION_NAME] [nvarchar](100) NULL,
	[EVENT_LATITUDE] [varchar](50) NULL,
	[EVENT_LONGITUDE] [varchar](50) NULL,
	[IS_ACTIVE] [bit] NULL,
	[IS_NOTIFY_USER] [bit] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
	[EVENT_IMG_FILE_PATH] [varchar](500) NULL,
	[LANGUAGE_ID] [int] NULL,
 CONSTRAINT [PK_EVENTS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LANGUAGES]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LANGUAGES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LANGUAGE_NAME] [varchar](50) NULL,
 CONSTRAINT [PK_LANGUAGES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MEMBER_INFO]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MEMBER_INFO](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[MEMBER_INFO_TITLE] [nvarchar](50) NULL,
	[MEMBER_INFO_DESCRIPTION] [nvarchar](2000) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
	[LANGUAGE_ID] [int] NULL,
 CONSTRAINT [PK_MEMBER_INFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NEWS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NEWS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[NEWS_TITLE] [nvarchar](300) NULL,
	[NEWS_IMG_FILE_PATH] [varchar](500) NULL,
	[NEWS_CONTENT] [nvarchar](max) NULL,
	[IS_NOTIFY_USER] [bit] NULL,
	[IS_ACTIVE] [bit] NULL,
	[PUBLISHED_DATE] [smalldatetime] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
	[LANGUAGE_ID] [int] NULL,
 CONSTRAINT [PK_NEWS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NOTIFICATION_LOGS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NOTIFICATION_LOGS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[NOTIFICATION_TYPE] [varchar](50) NULL,
	[REQUEST_JSON] [nvarchar](4000) NULL,
	[RESPONSE_MESSAGE] [varchar](5000) NULL,
	[IS_SENT_NOTIFICATION] [bit] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_NOTIFICATION_LOGS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TICKET_CHAT_DETAILS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TICKET_CHAT_DETAILS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TICKET_ID] [int] NOT NULL,
	[REPLY_MESSAGE] [nvarchar](max) NULL,
	[REPLIED_DATE] [smalldatetime] NULL,
	[REPLY_FILE_PATH] [varchar](500) NULL,
	[TICKET_PARTICIPANT_ID] [int] NULL,
	[TICKET_CHAT_TYPE_ID] [int] NULL CONSTRAINT [DF_TICKET_CHAT_DETAILS_TICKET_CHAT_TYPE_ID]  DEFAULT ((1)),
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_TICKET_CHAT_DETAILS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TICKET_CHAT_TYPES]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TICKET_CHAT_TYPES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CHAT_TYPE] [varchar](50) NULL,
 CONSTRAINT [PK_TICKET_CHAT_TYPES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TICKET_PARTICIPANTS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TICKET_PARTICIPANTS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TICKET_ID] [int] NULL,
	[USER_ID] [int] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_TICKET_PARTICIPANTS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TICKET_STATUS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TICKET_STATUS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[STATUS_NAME] [varchar](50) NULL,
 CONSTRAINT [PK_TICKET_STATUS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TICKETS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TICKETS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[TICKET_NAME] [nvarchar](300) NULL,
	[TICKET_DESCRIPTION] [nvarchar](1000) NULL,
	[DEFAULT_IMAGE] [varchar](500) NULL,
	[IS_ACTIVE] [bit] NULL,
	[TICKET_STATUS_ID] [int] NULL,
	[TICKET_STATUS_REMARK] [varchar](1000) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
	[TICKET_CODE] [varchar](10) NULL,
	[TICKET_OWNER_USER_ID] [int] NULL,
	[TICKET_CREATED_PLATFORM] [int] NULL CONSTRAINT [DF_TICKETS_TICKET_CREATED_PLATFORM]  DEFAULT ((1)),
 CONSTRAINT [PK_ISSUES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USER_DETAILS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[USER_DETAILS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[USER_ID] [int] NULL,
	[FULL_NAME] [nvarchar](100) NULL,
	[CIVIL_ID] [varchar](50) NULL,
	[ADDRESS] [nvarchar](300) NULL,
	[AREA_ID] [int] NULL,
	[WILAYAT_ID] [int] NULL,
	[VILLAGE_ID] [int] NULL,
	[OTP_NUMBER] [int] NULL,
	[IS_OTP_VALIDATED] [bit] NULL CONSTRAINT [DF_USER_DETAILS_IS_OTP_VALIDATED]  DEFAULT ((0)),
	[SMS_SENT_STATUS] [bit] NULL,
	[SMS_SENT_TRANSACTION_DATE] [smalldatetime] NULL,
	[LAST_LOGGED_IN_DATE] [smalldatetime] NULL,
	[IS_TICKET_SUBMISSION_RESTRICTED] [bit] NULL,
	[TICKET_SUBMISSION_INTERVAL_DAYS] [int] NULL CONSTRAINT [DF_USER_DETAILS_TICKET_SUBMISSION_INTERVAL_DAYS]  DEFAULT ((0)),
	[NO_OF_TIMES_OTP_SEND] [int] NULL,
	[DEVICE_ID] [nvarchar](max) NULL,
	[PREFERED_LANGUAGE_ID] [int] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
	[LAST_TICKET_SUBMISSION_DATE] [datetime] NULL,
 CONSTRAINT [PK_USER_DETAILS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USER_TYPES]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[USER_TYPES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TYPE] [varchar](50) NULL,
 CONSTRAINT [PK_USER_TYPES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USERS]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[USERS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[USER_NAME] [varchar](50) NULL,
	[PASSWORD] [varchar](50) NULL,
	[USER_TYPE_ID] [int] NULL,
	[PHONE_NUMBER] [varchar](50) NULL,
	[EMAIL] [varchar](50) NULL,
	[APPLICATION_ID] [int] NULL,
	[IS_ACTIVE] [bit] NULL CONSTRAINT [DF_USERS_IS_ACTIVE]  DEFAULT ((1)),
	[IS_BLOCKED] [bit] NULL CONSTRAINT [DF_USERS_IS_BLOCKED]  DEFAULT ((0)),
	[BLOCKED_REMARKS] [varchar](1000) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_USERS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VILLAGE_MASTER]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VILLAGE_MASTER](
	[ID] [int] NULL,
	[AREA_CODE] [varchar](50) NULL,
	[WILAYAT_CODE] [varchar](50) NULL,
	[VILLAGE_CODE] [varchar](50) NULL,
	[VILLAGE_DESC_ARB] [nvarchar](100) NULL,
	[VILLAGE_DESC_ENG] [nvarchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WILAYAT_MASTER]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WILAYAT_MASTER](
	[ID] [int] NULL,
	[AREA_CODE] [varchar](50) NULL,
	[AREA_MASTER_ID] [varchar](50) NULL,
	[WILAYAT_CODE] [varchar](50) NULL,
	[WILAYAT_DESC_ARB] [nvarchar](100) NULL,
	[WILAYAT_DESC_ENG] [nvarchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[APPLICATION_INFO] ON 

GO
INSERT [dbo].[APPLICATION_INFO] ([ID], [APPLICATION_ID], [TITLE], [DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (5, 1, N'What is Lorem Ipsum?', N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1068, CAST(N'2017-09-23 13:06:00' AS SmallDateTime), -99, CAST(N'2017-09-24 20:17:00' AS SmallDateTime))
GO
INSERT [dbo].[APPLICATION_INFO] ([ID], [APPLICATION_ID], [TITLE], [DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (6, 1, N'What is Lorem Ipsum?', N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1068, CAST(N'2017-09-23 13:06:00' AS SmallDateTime), -99, CAST(N'2017-09-24 20:17:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[APPLICATION_INFO] OFF
GO
SET IDENTITY_INSERT [dbo].[APPLICATION_MASTER_SETTINGS] ON 

GO
INSERT [dbo].[APPLICATION_MASTER_SETTINGS] ([ID], [SETTINGS_NAME]) VALUES (1, N'PlayStoreURL')
GO
INSERT [dbo].[APPLICATION_MASTER_SETTINGS] ([ID], [SETTINGS_NAME]) VALUES (2, N'AppleStoreURL')
GO
INSERT [dbo].[APPLICATION_MASTER_SETTINGS] ([ID], [SETTINGS_NAME]) VALUES (3, N'WebStoreURL')
GO
SET IDENTITY_INSERT [dbo].[APPLICATION_MASTER_SETTINGS] OFF
GO
SET IDENTITY_INSERT [dbo].[APPLICATION_SETTINGS] ON 

GO
INSERT [dbo].[APPLICATION_SETTINGS] ([ID], [APPLICATION_ID], [APPLICATION_MASTER_SETTING_ID], [SETTINGS_VALUE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, 1, 1, N'Coming Soon', NULL, NULL, 1068, CAST(N'2017-09-24 20:14:00' AS SmallDateTime))
GO
INSERT [dbo].[APPLICATION_SETTINGS] ([ID], [APPLICATION_ID], [APPLICATION_MASTER_SETTING_ID], [SETTINGS_VALUE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, 1, 2, N'Coming Soon', NULL, NULL, 1068, CAST(N'2017-09-24 20:14:00' AS SmallDateTime))
GO
INSERT [dbo].[APPLICATION_SETTINGS] ([ID], [APPLICATION_ID], [APPLICATION_MASTER_SETTING_ID], [SETTINGS_VALUE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (3, 1, 3, N'http://fileserver.sawa.work/Downloads/apk/1/AlJardani.0.0.1.apk', NULL, NULL, 1068, CAST(N'2017-09-24 20:13:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[APPLICATION_SETTINGS] OFF
GO
SET IDENTITY_INSERT [dbo].[APPLICATIONS] ON 

GO
INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO_PATH], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, N'Al.Jardani', N'1/20170924204027416.png', NULL, CAST(N'2018-07-14 00:00:00' AS SmallDateTime), NULL, 1, 1, CAST(N'2017-07-14 00:34:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 20:40:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[APPLICATIONS] OFF
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (1, N'1', N'محافظة مسقط', N'Muscat')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (6, N'2', N'محافظة شمال الباطنة ', N'North Batinah')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (3, N'3', N'محافظة مسندم', N'Musandam')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (10, N'4', N'محافظة الظاهـرة', N'Al-Dhahirah')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (5, N'5', N'محافظة الداخلية', N'Al-Dakhiliyah')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (8, N'6', N'محافظة جنوب الشرقية', N'South Al-Sharqiya')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (11, N'7', N'محافظة الوسطى', N'Al-Wusta''a')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (2, N'8', N'محافظة ظفـار', N'Dhofar')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (7, N'10', N'محافظة جنوب الباطنة ', N'South Batinah')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (4, N'9', N'محافظة البريمي', N'Al-Buraimi')
GO
INSERT [dbo].[AREA_MASTER] ([ID], [AREA_CODE], [AREA_DESC_ARB], [AREA_DESC_ENG]) VALUES (9, N'11', N'محافظة شمال الشرقية', N'North Al-Sharqiya')
GO
SET IDENTITY_INSERT [dbo].[ELMAH_Error] ON 

GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'3eaa6857-ffff-4367-af12-3c174c2e54a0', N'Takamul.WEB', N'NANOCOMPLEX', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-09-30 14:39:58.690' AS DateTime), 37, N'<error
  host="NANOCOMPLEX"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification() in G:\GitHub\Takamul\Takamul.Portal\Helpers\PushNotification.cs:line 159"
  user="admin"
  time="2017-09-30T14:39:58.6904545Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'6f6e9706-cb5b-4110-87dd-1fc02306285b', N'Takamul.WEB', N'NANOCOMPLEX', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-09-30 15:16:41.410' AS DateTime), 40, N'<error
  host="NANOCOMPLEX"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification() in G:\GitHub\Takamul\Takamul.Portal\Helpers\PushNotification.cs:line 159"
  user="admin"
  time="2017-09-30T15:16:41.4115714Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'82f6197d-0101-4b0c-a3d8-860c25b13786', N'Takamul.WEB', N'NANOCOMPLEX', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-09-30 15:08:15.143' AS DateTime), 38, N'<error
  host="NANOCOMPLEX"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification() in G:\GitHub\Takamul\Takamul.Portal\Helpers\PushNotification.cs:line 159"
  user="admin"
  time="2017-09-30T15:08:15.1420470Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'872a3f47-b808-45fa-bb04-e8b083115e13', N'Takamul.WEB', N'NANOCOMPLEX', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-09-30 15:10:31.067' AS DateTime), 39, N'<error
  host="NANOCOMPLEX"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification() in G:\GitHub\Takamul\Takamul.Portal\Helpers\PushNotification.cs:line 159"
  user="admin"
  time="2017-09-30T15:10:31.0660644Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'95d43593-657d-4189-ab6f-87c5cc441ae2', N'Takamul.WEB', N'NANOCOMPLEX', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-09-30 16:18:37.867' AS DateTime), 41, N'<error
  host="NANOCOMPLEX"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification() in G:\GitHub\Takamul\Takamul.Portal\Helpers\PushNotification.cs:line 161"
  user="admin"
  time="2017-09-30T16:18:37.8674225Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'0af407e6-071d-4bca-afd6-5ce5d606e96d', N'Takamul.WEB', N'NANOCOMPLEX', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-09-30 16:19:47.153' AS DateTime), 42, N'<error
  host="NANOCOMPLEX"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification() in G:\GitHub\Takamul\Takamul.Portal\Helpers\PushNotification.cs:line 161"
  user="admin"
  time="2017-09-30T16:19:47.1524450Z" />')
GO
SET IDENTITY_INSERT [dbo].[ELMAH_Error] OFF
GO
SET IDENTITY_INSERT [dbo].[EVENTS] ON 

GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2030, 1, N'Mass Flood', N'Mass flood after rain', CAST(N'2017-09-22 21:31:00' AS SmallDateTime), N'Mascot beach', N'23.5943', N'58.5418', 1, 0, 1068, CAST(N'2017-09-22 21:35:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170922213434982.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2031, 1, N'Muharram', N'Islamic first day ', CAST(N'2017-09-22 21:31:00' AS SmallDateTime), N'Ruwi', N'23.5943', N'58.5418', 1, 0, 1068, CAST(N'2017-09-22 21:44:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170922214410091.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2032, 1, N'National Day Celebration', N'Oman observe its national day celebration on 18th of Nov', CAST(N'2017-09-22 22:32:00' AS SmallDateTime), N'Seeb Hote;', N'23.6272', N'58.1665', 1, 0, 1068, CAST(N'2017-09-22 22:34:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170922223334454.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2033, 1, N'محاضرة دينية', N'تقام محاضرة دينية بمناسبة الهجرة النبوية ', CAST(N'2017-09-23 17:00:00' AS SmallDateTime), N'مسجد العقبة ، عرقي ', N'23.2202', N'58.7066', 1, 0, 1068, CAST(N'2017-09-22 23:32:00' AS SmallDateTime), NULL, NULL, NULL, 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2034, 1, N'عقد قران', N'تقام في سبلة الجرادنة بصياء الحدرية يوم الجمعة تاريخ 24/09/2017 بعد صلاة المغرب عقد قران جماعي للاخوة 
1- فلان الفلاني 
2- فلان الفلاني 
3- فلان الفلاني 
4- فلان الفلاني 

حضوركم و مشاركتكم ...........
', CAST(N'2017-09-24 00:19:00' AS SmallDateTime), N'سبلة الجرادنة ', N'23.2144', N'58.6883', 1, 0, 1068, CAST(N'2017-09-24 22:17:00' AS SmallDateTime), NULL, NULL, NULL, 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2035, 1, N'عيد ميلاد ', N'ادعوكم 🌈🌟إلى عيد ميلاد  (حول حول) ابني حمد🎖 بمشيئة الله تعالى/ يوم الجمعه تاريخ🎉
29/9/2017في مجلس دار المناسبات العقبة مع تناول 🌈 وجبة العشاء بعد صلاة المغرب 💐🎂🎂🌈احمد ناصر حمد الجرداني', CAST(N'2017-09-29 19:00:00' AS SmallDateTime), N'دار المناسبات', N'23.5939', N'58.4534', 1, 0, 1068, CAST(N'2017-09-26 08:59:00' AS SmallDateTime), NULL, NULL, NULL, 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2036, 1, N'test', N'test', CAST(N'2017-09-26 16:46:00' AS SmallDateTime), N'asdfasdfasdf', N'23.5212', N'58.4905', 1, 1, 1068, CAST(N'2017-09-26 16:47:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170926164710456.png', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2037, 1, N'test notify', N'test notify desc', CAST(N'2017-09-26 17:11:00' AS SmallDateTime), N'test test notify', N'23.5369', N'58.4480', 1, 1, 1068, CAST(N'2017-09-26 17:12:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170926171153763.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2038, 1, N'test notify 1', N'test notify 1 desc', CAST(N'2017-09-26 17:11:00' AS SmallDateTime), N'test ', N'23.5342', N'58.4466', 1, 1, 1068, CAST(N'2017-09-26 17:14:00' AS SmallDateTime), NULL, NULL, NULL, 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2039, 1, N'test notify 2', N'test notify 2 fdesc', CAST(N'2017-09-26 17:14:00' AS SmallDateTime), N'est', N'23.6175', N'58.5015', 1, 1, 1068, CAST(N'2017-09-26 17:15:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170926171453401.jpeg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2040, 1, N'تجربة', N'تجربة', CAST(N'2017-09-29 01:36:00' AS SmallDateTime), N'صياء', N'23.2170', N'58.6897', 1, 0, 1118, CAST(N'2017-09-29 01:38:00' AS SmallDateTime), NULL, NULL, NULL, 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2041, 1, N'tes sdf', N'asdfasfdasdfasdf', CAST(N'2017-09-29 17:25:00' AS SmallDateTime), N'asdfafadsf', N'23.5539', N'58.4775', 1, 1, 1068, CAST(N'2017-09-29 17:26:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170929172551889.jpeg', 2)
GO
SET IDENTITY_INSERT [dbo].[EVENTS] OFF
GO
SET IDENTITY_INSERT [dbo].[LANGUAGES] ON 

GO
INSERT [dbo].[LANGUAGES] ([ID], [LANGUAGE_NAME]) VALUES (1, N'Arabic')
GO
INSERT [dbo].[LANGUAGES] ([ID], [LANGUAGE_NAME]) VALUES (2, N'English')
GO
SET IDENTITY_INSERT [dbo].[LANGUAGES] OFF
GO
SET IDENTITY_INSERT [dbo].[MEMBER_INFO] ON 

GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1012, 1, N'الجرداني ', N'تجربة', 1068, CAST(N'2017-09-24 21:23:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1013, 1, N'صياء', N'تجربة', 1068, CAST(N'2017-09-24 21:24:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1014, 1, N'عرقي', N'تجربة', 1068, CAST(N'2017-09-24 21:24:00' AS SmallDateTime), NULL, NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[MEMBER_INFO] OFF
GO
SET IDENTITY_INSERT [dbo].[NEWS] ON 

GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3125, 1, N'تجربة ', N'1/News/20170922132100653.jpg', N'هذا الخبر للتجربة فقط 
افتتاح جامع زنجبار', 1, 1, CAST(N'2017-09-22 13:19:00' AS SmallDateTime), 1068, CAST(N'2017-09-22 13:21:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3129, 1, N'KSA National Day', N'1/News/20170922213003986.jpg', N'KSA celebrates its national day ', 1, 1, CAST(N'2017-09-24 17:01:00' AS SmallDateTime), 1068, CAST(N'2017-09-22 21:30:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3130, 1, N' iPhone 8 isn’t the handset you’re really looking for?', N'1/News/20170922223857379.png', N'The iPhone 8 has buyer’s remorse written all over it.
That’s not because it’s a bad phone. Quite the contrary. It’s the best iPhone Apple has even made, but that’s a title it will only hold until the Apple X launches on November 3', 1, 1, CAST(N'2017-09-22 22:36:00' AS SmallDateTime), 1068, CAST(N'2017-09-22 22:39:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3131, 1, N' Preacher suspended for denigrating women', N'1/News/20170922223957649.jpg', N'Manama: The Emir of Asir in southern Saudi Arabia, Prince Faisal Bin Khalid Bin Abdul Aziz, has suspended a religious preacher from leading prayers and giving Friday sermons and lectures after he claimed that women were only slightly capable of thinking.
A spokesperson for the Emir said that Prince Faisal took the decision in response to angry reactions on social media following the lecture by Saad Al Hajari.', 1, 1, CAST(N'2017-09-22 22:39:00' AS SmallDateTime), 1068, CAST(N'2017-09-22 22:40:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3132, 1, N'تطبيق الجرداني ', N'1/News/20170922233603295.jpg', N'جاري فحص التطبيق ', 1, 1, CAST(N'2017-09-22 23:34:00' AS SmallDateTime), 1068, CAST(N'2017-09-22 23:36:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3134, 1, N'يمكن تنزيل التطبيق', N'1/News/20170924204459297.jpg', N'يمكنك الان من تنزيل التطبيق التجريبي من الموقع ', 1, 1, CAST(N'2017-09-24 20:43:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 20:45:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3135, 1, N'تجربة الاشعارات', N'1/News/20170924210920776.jpg', N'هل الاشعارات تعمل بشكل صحيح ؟

', 1, 1, CAST(N'2017-09-24 21:08:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 21:09:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3136, 1, N'تجربة الاشعارات ', N'1/News/20170924211601113.jpg', N'خبر فقط لتجربة الاشعارات هل تعمل بشكل جيد ؟', 1, 1, CAST(N'2017-09-24 21:11:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 21:16:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3137, 1, N'هاني الجرداني يشارك في فحص التطبيق', N'1/News/20170924211940006.jpg', N'يقوم الحاج هاني بن احمد الجرداني مشكورا مشاركة ادارة التطبيق في فحص مكونات ومحتويات تطبيق الجرداني ', 1, 1, CAST(N'2017-09-24 21:17:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 21:20:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3138, 1, N'انقطاع الكهرباء', N'1/News/20170925163703637.jpg', N'اعلنت شركة الكهرباء عن قطع التيار الكهربائي يوم الخميس 25/9 من الساعة الثامنة صباحا إلى الساعة الواحدة ظهرا ، يشمل هذا الانقطاع قريتي صياء و عرقي 

يرجى اخذ جميع الاحطياطات الأزمة

', 1, 1, CAST(N'2017-09-25 16:31:00' AS SmallDateTime), 1068, CAST(N'2017-09-25 16:37:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3139, 1, N'What is Lorem Ipsum?', N'1/News/20170925232545797.png', N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 1, CAST(N'2017-09-25 23:25:00' AS SmallDateTime), 1068, CAST(N'2017-09-25 23:26:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3143, 1, N'تجربة الصور الصغيرة هل تضهر في التطبيق ؟', N'1/News/20170926102904245.jpg', N'ادعوكم 🌈🌟إلى عيد ميلاد  (حول حول) ابني حمد🎖 بمشيئة الله تعالى/ يوم الجمعه تاريخ🎉
29/9/2017في مجلس دار المناسبات العقبة مع تناول 🌈 وجبة العشاء بعد صلاة المغرب 💐🎂🎂🌈احمد ناصر حمد الجرداني
', 1, 1, CAST(N'2017-09-26 10:25:00' AS SmallDateTime), 1068, CAST(N'2017-09-26 10:29:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3144, 1, N'السيد احمد البوسعيدي يشارك فريق العمل ', N'1/News/20170926164613702.jpg', N'يقوم السيد احمد البوسعيدي في مشاركة فريق العمل فحص وتجربة جميع محتويات تطبيق الجرداني ، نتقدم بالشكر الجزيل على ما يبذلة السيد احمد من دعم لفريق العمل ومشاركتة في التجربة 



', 1, 1, CAST(N'2017-09-26 16:43:00' AS SmallDateTime), 1068, CAST(N'2017-09-26 16:46:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3145, 1, N'مسجد صياء الحدرية الجديد ', N'1/News/20170928213653549.jpg', N'الحمد لله تمت الموافقة من الجهات المختصة لاصدار ملكية الأرض المخصصة للمسجد الواقعة جنب سبلة الجرادنة .', 1, 1, CAST(N'2017-09-28 21:33:00' AS SmallDateTime), 1118, CAST(N'2017-09-28 21:37:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3146, 1, N'test 123', N'1/News/20170929172316658.jpg', N'test  1212', 1, 1, CAST(N'2017-09-29 17:23:00' AS SmallDateTime), 1068, CAST(N'2017-09-29 17:23:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3147, 1, N'test 111', N'1/News/20170929172500810.jpg', N'test 111 desc', 1, 1, CAST(N'2017-09-29 17:24:00' AS SmallDateTime), 1068, CAST(N'2017-09-29 17:25:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3148, 1, N'tasdfasdf', N'1/News/20170929172803302.png', N'aafasdfasdf', 1, 1, CAST(N'2017-09-29 17:27:00' AS SmallDateTime), 1068, CAST(N'2017-09-29 17:28:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3149, 1, N'asdfasdfas', N'1/News/20170929172917177.jpg', N'dfasdfasdfasdf', 1, 1, CAST(N'2017-09-29 17:29:00' AS SmallDateTime), 1068, CAST(N'2017-09-29 17:29:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3150, 1, N'tes asdfasdfasdfas', N'1/News/20170929173203118.png', N'dfadsf', 1, 1, CAST(N'2017-09-29 17:31:00' AS SmallDateTime), 1068, CAST(N'2017-09-29 17:32:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3151, 1, N'Where can I get some?', N'1/News/20170930183952813.jpg', N'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don''t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn''t anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.', 1, 1, CAST(N'2017-09-30 18:39:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 18:40:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3152, 1, N'The standard chunk of ', N'1/News/20170930190742394.jpg', N'The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.', 1, 1, CAST(N'2017-09-30 19:07:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:08:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3153, 1, N'The standard chunk of Lorem Ipsum used since', N'1/News/20170930190929439.jpeg', N'The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.', 1, 1, CAST(N'2017-09-30 19:09:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:09:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3154, 1, N'Where can I get some?', N'1/News/20170930191302964.jpg', N'here are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don''t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn''t anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.', 1, 1, CAST(N'2017-09-30 19:12:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:13:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3155, 1, N'Where can I get some?', N'1/News/20170930191532610.jpeg', N'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don''t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn''t anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.', 0, 0, CAST(N'2017-09-30 19:12:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:16:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3156, 1, N'Why do we use it?', N'1/News/20170930191621549.jpg', N'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using ''Content here, content here'', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for ''lorem ipsum'' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).', 1, 1, CAST(N'2017-09-30 19:15:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:16:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3157, 1, N'What is Lorem Ipsum?', N'1/News/20170930191940750.png', N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 1, CAST(N'2017-09-30 19:19:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:20:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3158, 1, N'What is Lorem Ipsum?', N'1/News/20170930192109333.png', N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 1, CAST(N'2017-09-30 19:19:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:21:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3159, 1, N'Where does it come from?', N'1/News/20170930192548407.jpg', N'and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.', 1, 1, CAST(N'2017-09-30 19:25:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:26:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3160, 1, N'ما فائدته ؟', N'1/News/20170930193110708.png', N'هناك حقيقة مثبتة منذ زمن طويل وهي أن المحتوى المقروء لصفحة ما سيلهي القارئ عن التركيز على الشكل الخارجي للنص أو شكل توضع الفقرات في الصفحة التي يقرأها. ولذلك يتم استخدام طريقة لوريم إيبسوم لأنها تعطي توزيعاَ طبيعياَ -إلى حد ما- للأحرف عوضاً عن استخدام "هنا يوجد محتوى نصي، هنا يوجد محتوى نصي" فتجعلها تبدو (أي الأحرف) وكأنها نص مقروء. العديد من برامح النشر المكتبي وبرامح تحرير صفحات الويب تستخدم لوريم إيبسوم بشكل إفتراضي كنموذج عن النص، وإذا قمت بإدخال "lorem ipsum" في أي محرك بحث ستظهر العديد من المواقع الحديثة العهد في نتائج البحث. على مدى السنين ظهرت نسخ جديدة ومختلفة من نص لوريم إيبسوم، أحياناً عن طريق الصدفة، وأحياناً عن عمد كإدخال بعض العبارات الفكاهية إليها.', 1, 1, CAST(N'2017-09-30 19:30:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 19:31:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3161, 1, N'Why do we use it?', N'1/News/20170930201428184.jpg', N'g it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for ''lorem ipsum'' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).', 1, 1, CAST(N'2017-09-30 20:13:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:14:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3162, 1, N'pose injected', N'1/News/20170930201531655.jpg', N'g it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for ''lorem ipsum'' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).', 1, 1, CAST(N'2017-09-30 20:13:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:16:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3163, 1, N'included_segments', N'1/News/20170930201726168.jpg', N'The segment names you want to target. Users in these segments will receive a notification. This targeting parameter is only compatible with excluded_segments.', 0, 1, CAST(N'2017-09-30 20:17:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:17:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3164, 1, N'can I get some?', N'1/News/20170930201828907.jpg', N'many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don''t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn''t anything em', 1, 1, CAST(N'2017-09-30 20:17:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:18:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3165, 1, N'enerator on', N'1/News/20170930201917064.jpg', N'many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don''t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn''t anything em', 1, 1, CAST(N'2017-09-30 20:18:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:19:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3166, 1, N'Where can I get some?', N'1/News/20170930202228308.png', N're many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don''t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn''t anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It us', 1, 1, CAST(N'2017-09-30 20:22:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:22:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3167, 1, N'Where does', N'1/News/20170930202323938.jpg', N'ver 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.', 1, 1, CAST(N'2017-09-30 20:23:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:23:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3168, 1, N'n hac habitasse platea dictumst', N'1/News/20170930203906623.jpg', N'In hac habitasse platea dictumst. Vivamus eget nulla eu dolor eleifend mattis consectetur sed neque. Proin quis diam quam. Donec cursus tincidunt consectetur. Maecenas pharetra enim ut metus facilisis tincidunt. Integer non urna ac tellus viverra egestas ut sit amet nisi. Aliquam enim lorem, facilisis vitae leo id, iaculis vestibulum purus. Vivamus egestas condimentum euismod.', 1, 1, CAST(N'2017-09-30 20:38:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:39:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3169, 1, N'أين أجده ؟', N'1/News/20170930204719990.jpg', N'نالك العديد من الأنواع المتوفرة لنصوص لوريم إيبسوم، ولكن الغالبية تم تعديلها بشكل ما عبر إدخال بعض النوادر أو الكلمات العشوائية إلى النص. إن كنت تريد أن تستخدم نص لوريم إيبسوم ما، عليك أن تتحقق أولاً أن ليس هناك أي كلمات أو عبارات محرجة أو غير لائقة مخبأة في هذا النص. بينما تعمل جميع مولّدات نصوص لوريم إيبسوم على الإنترنت على إعادة تكرار مقاطع من نص لوريم إيبسوم نفسه عدة مرات بما تتطلبه الحاجة، يقوم مولّدنا هذا باستخدام كلمات من قاموس يحوي على أكثر من 200 كلمة لا تينية، مضاف إليها مجموعة من الجمل النموذجية، لتكوين نص لوريم إيبسوم ذو شكل منطقي قريب إلى النص الحقيقي. وبالتالي يكون النص الناتح خالي من التكرار، أو أي كلمات أو عبارات غير لائقة أو ما شابه. وهذا ما يجعله أول مولّد نص لوريم إيبسوم حقيقي على الإنترنت.', 1, 1, CAST(N'2017-09-30 20:46:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:47:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3170, 1, N'ما أصله ؟', N'1/News/20170930205208974.png', N'خلافاَ للإعتقاد السائد فإن لوريم إيبسوم ليس نصاَ عشوائياً، بل إن له جذور في الأدب اللاتيني الكلاسيكي منذ العام 45 قبل الميلاد، مما يجعله أكثر من 2000 عام في القدم. قام البروفيسور "ريتشارد ماك لينتوك" (Richard McClintock) وهو بروفيسور اللغة اللاتينية في جامعة هامبدن-سيدني في فيرجينيا بالبحث عن أصول كلمة لاتينية غامضة في نص لوريم إيبسوم وهي "consectetur"، وخلال تتبعه لهذه الكلمة في الأدب اللاتيني اكتشف المصدر الغير قابل للشك. فلقد اتضح أن كلمات نص لوريم إيبسوم تأتي من الأقسام 1.10.32 و 1.10.33 من كتاب "حول أقاصي الخير والشر" (de Finibus Bonorum et Malorum) للمفكر شيشيرون (Cicero) والذي كتبه في عام 45 قبل الميلاد. هذا', 1, 1, CAST(N'2017-09-30 20:51:00' AS SmallDateTime), 1068, CAST(N'2017-09-30 20:52:00' AS SmallDateTime), NULL, NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[NEWS] OFF
GO
SET IDENTITY_INSERT [dbo].[NOTIFICATION_LOGS] ON 

GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (10, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"asdfasdfas"},"contents":{"en":"dfasdfasdfasdf..."},"data":{"NewsID":"3149","LanguageID":2},"included_segments":["All"]}', N'{"id":"88ac44c9-090a-4327-8973-13236daa8bf9","recipients":10}', 1, CAST(N'2017-09-29 17:29:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (11, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"tes asdfasdfasdfas"},"contents":{"en":"dfadsf..."},"data":{"NewsID":"3150","LanguageID":2},"included_segments":["All"]}', N'{"id":"aa240cfe-b855-457b-9a41-e5c688549d30","recipients":10}', 1, CAST(N'2017-09-29 17:32:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (12, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Where can I get some?"},"contents":{"en":"There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomi..."},"data":{"News":"News","NewsID":"3151","LanguageID":2},"include_player_ids":["","","","","","",""]}', NULL, 0, CAST(N'2017-09-30 18:40:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (13, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"The standard chunk of "},"contents":{"en":"The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from \"de Finibus Bonorum..."},"data":{"News":"News","NewsID":"3152","LanguageID":2},"include_player_ids":["","","","","","",""]}', NULL, 0, CAST(N'2017-09-30 19:08:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (14, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"The standard chunk of Lorem Ipsum used since"},"contents":{"en":"The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from \"de Finibus Bonorum..."},"data":{"News":"News","NewsID":"3153","LanguageID":2},"include_player_ids":["","","","","","",""]}', NULL, 0, CAST(N'2017-09-30 19:11:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (15, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Where can I get some?"},"contents":{"en":"here are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomis..."},"data":{"News":"News","NewsID":"3154","LanguageID":2},"included_segments":["All"]}', N'{"id":"ddf8d046-5c2a-418b-b2a9-e932396dc0b5","recipients":10}', 1, CAST(N'2017-09-30 19:15:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (16, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Why do we use it?"},"contents":{"en":"It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem ..."},"data":{"News":"News","NewsID":"3156","LanguageID":2},"include_player_ids":["test","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96","4343","4343","4343"]}', NULL, 0, CAST(N'2017-09-30 19:17:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (17, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Where does it come from?"},"contents":{"en":"and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.3..."},"data":{"News":"News","NewsID":"3159","LanguageID":2},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96"]}', N'{"id":"93ac7ae8-7e88-47f4-af8c-c5a543c64dcd","recipients":3}', 1, CAST(N'2017-09-30 19:26:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (18, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"?? ?????? ?","ar":"?? ?????? ?"},"contents":{"en":"???? ????? ????? ??? ??? ???? ??? ?? ??????? ??????? ????? ?? ????? ?????? ?? ??????? ??? ????? ??????? ???? ?? ??? ???? ??????? ?? ?????? ???? ??????...","ar":"???? ????? ????? ??? ??? ???? ??? ?? ??????? ??????? ????? ?? ????? ?????? ?? ??????? ??? ????? ??????? ???? ?? ??? ???? ??????? ?? ?????? ???? ??????..."},"data":{"News":"News","NewsID":"3160","LanguageID":1},"include_player_ids":["63da17fa-bb30-42af-bb9c-c46207e3de8e","305806c7-82b8-4916-bf0f-3b63d9e88cd3","7d7715a6-d3a5-4ba9-830c-e9478ef3672e","305806c7-82b8-4916-bf0f-3b63d9e88cd3","305806c7-82b8-4916-bf0f-3b63d9e88cd3","305806c7-82b8-4916-bf0f-3b63d9e88cd3"]}', N'{"id":"c4588e55-f942-4f6e-9bb3-e053e4a6c08e","recipients":3}', 1, CAST(N'2017-09-30 19:32:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (19, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Why do we use it?"},"contents":{"en":"g it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search f..."},"data":{"News":"News","NewsID":"3161","LanguageID":2},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96"]}', N'{"id":"3a67441b-1f2b-417f-b35e-474970f35152","recipients":3}', 1, CAST(N'2017-09-30 20:15:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (20, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"pose injected"},"contents":{"en":"g it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search f..."},"data":{"News":"News","NewsID":"3162","LanguageID":2},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96"]}', N'{"id":"94009ae1-293d-44a5-aecc-3b613076a20f","recipients":3}', 1, CAST(N'2017-09-30 20:16:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (21, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"can I get some?"},"contents":{"en":"many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words ..."},"data":{"News":"News","NewsID":"3164","LanguageID":2},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96"],"excluded_segments":["Active Users"]}', NULL, 0, CAST(N'2017-09-30 20:19:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (22, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"enerator on"},"contents":{"en":"many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words ..."},"data":{"News":"News","NewsID":"3165","LanguageID":2},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96"],"excluded_segments":["Active Users"]}', NULL, 0, CAST(N'2017-09-30 20:20:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (23, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Where can I get some?"},"contents":{"en":"re many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised wor..."},"data":{"News":"News","NewsID":"3166","LanguageID":2},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96"]}', N'{"id":"8980ad25-b9cf-4497-818a-1e2b36b5efbd","recipients":3}', 1, CAST(N'2017-09-30 20:23:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (24, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Where does"},"contents":{"en":"ver 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consec..."},"data":{"News":"News","NewsID":"3167","LanguageID":2},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96"]}', N'{"id":"5baf9086-a1f0-4468-bd2f-93d64f39f989","recipients":3}', 1, CAST(N'2017-09-30 20:24:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (25, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"n hac habitasse platea dictumst"},"contents":{"en":"In hac habitasse platea dictumst. Vivamus eget nulla eu dolor eleifend mattis consectetur sed neque. Proin quis diam quam. Donec cursus tincidunt cons..."},"data":{"News":"News","NewsID":"3168","LanguageID":2},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","1d0fc64b-ca45-471b-a8fd-086b4317c4fb","a645550a-efc8-490d-83ad-96ea3c264d96"]}', N'{"id":"bf2131f0-99ed-49a7-9cd9-16bfe9fc5f6f","recipients":3}', 1, CAST(N'2017-09-30 20:39:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (26, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"??? ???? ?","ar":"??? ???? ?"},"contents":{"en":"???? ?????? ?? ??????? ???????? ????? ????? ??????? ???? ???????? ?? ??????? ???? ?? ??? ????? ??? ??????? ?? ??????? ????????? ??? ????. ?? ??? ???? ...","ar":"???? ?????? ?? ??????? ???????? ????? ????? ??????? ???? ???????? ?? ??????? ???? ?? ??? ????? ??? ??????? ?? ??????? ????????? ??? ????. ?? ??? ???? ..."},"data":{"News":"News","NewsID":"3169","LanguageID":1},"include_player_ids":["63da17fa-bb30-42af-bb9c-c46207e3de8e","305806c7-82b8-4916-bf0f-3b63d9e88cd3","7d7715a6-d3a5-4ba9-830c-e9478ef3672e","305806c7-82b8-4916-bf0f-3b63d9e88cd3","305806c7-82b8-4916-bf0f-3b63d9e88cd3","305806c7-82b8-4916-bf0f-3b63d9e88cd3"]}', N'{"id":"fa9a4b31-32f2-420f-82e7-d2d16f8f246d","recipients":3}', 1, CAST(N'2017-09-30 20:47:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (27, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"ما أصله ؟","ar":"ما أصله ؟"},"contents":{"en":"خلافاَ للإعتقاد السائد فإن لوريم إيبسوم ليس نصاَ عشوائياً، بل إن له جذور في الأدب اللاتيني الكلاسيكي منذ العام 45 قبل الميلاد، مما يجعله أكثر من 2000 ...","ar":"خلافاَ للإعتقاد السائد فإن لوريم إيبسوم ليس نصاَ عشوائياً، بل إن له جذور في الأدب اللاتيني الكلاسيكي منذ العام 45 قبل الميلاد، مما يجعله أكثر من 2000 ..."},"data":{"News":"News","NewsID":"3170","LanguageID":1},"include_player_ids":["63da17fa-bb30-42af-bb9c-c46207e3de8e","305806c7-82b8-4916-bf0f-3b63d9e88cd3","7d7715a6-d3a5-4ba9-830c-e9478ef3672e","305806c7-82b8-4916-bf0f-3b63d9e88cd3","305806c7-82b8-4916-bf0f-3b63d9e88cd3","305806c7-82b8-4916-bf0f-3b63d9e88cd3"]}', N'{"id":"aedf29ec-9208-48bd-8b03-4897c2b305a8","recipients":3}', 1, CAST(N'2017-09-30 20:52:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (28, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Test 1234"},"contents":{"en":"Admin : 34443"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":3182,"TicketChatID":-99,"ReplyMsg":"34443","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["a645550a-efc8-490d-83ad-96ea3c264d96"]}', N'{"id":"532487b4-f40b-4e2d-b3c4-a41bbcb67766","recipients":1}', 1, CAST(N'2017-09-30 20:53:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[NOTIFICATION_LOGS] OFF
GO
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_DETAILS] ON 

GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3704, 3136, N'Hai', CAST(N'2017-09-22 11:12:00' AS SmallDateTime), NULL, 3197, 1, NULL, CAST(N'2017-09-22 11:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3705, 3136, N'Hai', CAST(N'2017-09-22 11:12:00' AS SmallDateTime), NULL, 3197, 1, NULL, CAST(N'2017-09-22 11:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3706, 3136, N'klkl', CAST(N'2017-09-22 11:13:00' AS SmallDateTime), NULL, 3198, 1, NULL, CAST(N'2017-09-22 11:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3707, 3138, N'تجربة ', CAST(N'2017-09-22 13:24:00' AS SmallDateTime), NULL, 3200, 1, NULL, CAST(N'2017-09-22 13:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3708, 3138, N'شكرا على المشاركة ', CAST(N'2017-09-22 13:25:00' AS SmallDateTime), NULL, 3201, 1, NULL, CAST(N'2017-09-22 13:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3709, 3138, N'العفو 
شكرا لكم على اهتمامكم ', CAST(N'2017-09-22 13:26:00' AS SmallDateTime), NULL, 3200, 1, NULL, CAST(N'2017-09-22 13:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3710, 3139, N'dfadfasdf', CAST(N'2017-09-22 20:07:00' AS SmallDateTime), NULL, 3203, 1, NULL, CAST(N'2017-09-22 20:07:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3711, 3139, N'Hii', CAST(N'2017-09-22 20:08:00' AS SmallDateTime), NULL, 3202, 1, NULL, CAST(N'2017-09-22 20:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3712, 3139, N'Hi', CAST(N'2017-09-22 20:08:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3713, 3139, N'How are you', CAST(N'2017-09-22 20:08:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3714, 3139, N'Not fine', CAST(N'2017-09-22 20:08:00' AS SmallDateTime), NULL, 3202, 1, NULL, CAST(N'2017-09-22 20:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3715, 3139, N'Wooow', CAST(N'2017-09-22 20:08:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3716, 3139, N'Twing', CAST(N'2017-09-22 20:09:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3717, 3139, N'Halooo', CAST(N'2017-09-22 20:09:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3718, 3139, N'How are you', CAST(N'2017-09-22 20:09:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3719, 3139, N'Thank u', CAST(N'2017-09-22 20:09:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3720, 3139, N'Ya dear', CAST(N'2017-09-22 20:10:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:10:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3721, 3139, N'What''s up', CAST(N'2017-09-22 20:10:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:10:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3722, 3139, N'Nothing special', CAST(N'2017-09-22 20:10:00' AS SmallDateTime), NULL, 3204, 1, NULL, CAST(N'2017-09-22 20:10:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3723, 3139, N'Is it', CAST(N'2017-09-22 20:10:00' AS SmallDateTime), NULL, 3202, 1, NULL, CAST(N'2017-09-22 20:10:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3724, 3139, N'', CAST(N'2017-09-22 20:12:00' AS SmallDateTime), N'1/3139/20170922201228024.jpeg', 3203, 4, NULL, CAST(N'2017-09-22 20:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3725, 3138, N'123', CAST(N'2017-09-22 23:00:00' AS SmallDateTime), NULL, 3201, 1, NULL, CAST(N'2017-09-22 23:00:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3726, 3138, N' 456', CAST(N'2017-09-22 23:00:00' AS SmallDateTime), NULL, 3200, 1, NULL, CAST(N'2017-09-22 23:00:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3727, 3144, N'Hi', CAST(N'2017-09-22 23:32:00' AS SmallDateTime), NULL, 3209, 1, NULL, CAST(N'2017-09-22 23:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3728, 3144, N'This is description about pipe', CAST(N'2017-09-22 23:32:00' AS SmallDateTime), NULL, 3209, 1, NULL, CAST(N'2017-09-22 23:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3729, 3144, N'', CAST(N'2017-09-22 23:33:00' AS SmallDateTime), N'1/3144/20170922233234525.jpg', 3209, 3, NULL, CAST(N'2017-09-22 23:33:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3730, 3144, N'jio', CAST(N'2017-09-23 00:17:00' AS SmallDateTime), NULL, 3225, 1, NULL, CAST(N'2017-09-23 00:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3731, 3144, N'Hello pach', CAST(N'2017-09-23 00:17:00' AS SmallDateTime), NULL, 3225, 1, NULL, CAST(N'2017-09-23 00:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3732, 3144, N'Hi admin ', CAST(N'2017-09-23 00:17:00' AS SmallDateTime), NULL, 3209, 1, NULL, CAST(N'2017-09-23 00:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3733, 3144, N'jio', CAST(N'2017-09-23 00:18:00' AS SmallDateTime), NULL, 3225, 1, NULL, CAST(N'2017-09-23 00:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3734, 3144, N'This is like deorisa', CAST(N'2017-09-23 00:18:00' AS SmallDateTime), NULL, 3209, 1, NULL, CAST(N'2017-09-23 00:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3735, 3144, N'Yee', CAST(N'2017-09-23 00:18:00' AS SmallDateTime), NULL, 3209, 1, NULL, CAST(N'2017-09-23 00:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3736, 3144, N'kilo', CAST(N'2017-09-23 00:18:00' AS SmallDateTime), NULL, 3225, 1, NULL, CAST(N'2017-09-23 00:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3737, 3144, N'Ur welcome', CAST(N'2017-09-23 00:20:00' AS SmallDateTime), NULL, 3209, 1, NULL, CAST(N'2017-09-23 00:20:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3738, 3144, N'popo', CAST(N'2017-09-23 00:20:00' AS SmallDateTime), NULL, 3225, 1, NULL, CAST(N'2017-09-23 00:20:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3739, 3160, N'Hi', CAST(N'2017-09-23 00:21:00' AS SmallDateTime), NULL, 3226, 1, NULL, CAST(N'2017-09-23 00:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3740, 3160, N'pop', CAST(N'2017-09-23 00:22:00' AS SmallDateTime), NULL, 3228, 1, NULL, CAST(N'2017-09-23 00:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3741, 3160, N'Yes admin ', CAST(N'2017-09-23 00:22:00' AS SmallDateTime), NULL, 3226, 1, NULL, CAST(N'2017-09-23 00:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3742, 3160, N'popo ', CAST(N'2017-09-23 00:22:00' AS SmallDateTime), NULL, 3228, 1, NULL, CAST(N'2017-09-23 00:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3743, 3162, N'Hello', CAST(N'2017-09-23 00:25:00' AS SmallDateTime), NULL, 3229, 1, NULL, CAST(N'2017-09-23 00:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3744, 3162, N'REACT', CAST(N'2017-09-23 00:26:00' AS SmallDateTime), NULL, 3229, 1, NULL, CAST(N'2017-09-23 00:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3745, 3162, N'pop', CAST(N'2017-09-23 00:26:00' AS SmallDateTime), NULL, 3230, 1, NULL, CAST(N'2017-09-23 00:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3746, 3162, N'pouiuo', CAST(N'2017-09-23 00:26:00' AS SmallDateTime), NULL, 3230, 1, NULL, CAST(N'2017-09-23 00:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3747, 3162, N'Tyu', CAST(N'2017-09-23 00:26:00' AS SmallDateTime), NULL, 3229, 1, NULL, CAST(N'2017-09-23 00:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3748, 3162, N'kilo', CAST(N'2017-09-23 00:26:00' AS SmallDateTime), NULL, 3230, 1, NULL, CAST(N'2017-09-23 00:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3749, 3162, N'', CAST(N'2017-09-23 00:27:00' AS SmallDateTime), N'1/3162/20170923002643523.png', 3230, 2, NULL, CAST(N'2017-09-23 00:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3750, 3171, N'Hi', CAST(N'2017-09-23 11:03:00' AS SmallDateTime), NULL, 3239, 1, NULL, CAST(N'2017-09-23 11:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3751, 3171, N'', CAST(N'2017-09-23 11:05:00' AS SmallDateTime), N'1/3171/20170923110435834.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:05:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3752, 3171, N'', CAST(N'2017-09-23 11:08:00' AS SmallDateTime), N'1/3171/20170923110738111.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3753, 3171, N'', CAST(N'2017-09-23 11:49:00' AS SmallDateTime), N'1/3171/20170923114832151.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3754, 3171, N'', CAST(N'2017-09-23 11:49:00' AS SmallDateTime), N'1/3171/20170923114847247.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3755, 3171, N'', CAST(N'2017-09-23 11:49:00' AS SmallDateTime), N'1/3171/20170923114859505.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3756, 3171, N'', CAST(N'2017-09-23 11:49:00' AS SmallDateTime), N'1/3171/20170923114913266.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3757, 3171, N'', CAST(N'2017-09-23 11:49:00' AS SmallDateTime), N'1/3171/20170923114922896.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3758, 3171, N'', CAST(N'2017-09-23 11:50:00' AS SmallDateTime), N'1/3171/20170923114932406.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:50:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3759, 3171, N'', CAST(N'2017-09-23 11:50:00' AS SmallDateTime), N'1/3171/20170923114944966.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:50:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3760, 3171, N'', CAST(N'2017-09-23 11:54:00' AS SmallDateTime), N'1/3171/20170923115414423.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:54:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3761, 3171, N'Hi', CAST(N'2017-09-23 11:54:00' AS SmallDateTime), NULL, 3239, 1, NULL, CAST(N'2017-09-23 11:54:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3762, 3171, N'', CAST(N'2017-09-23 11:54:00' AS SmallDateTime), N'1/3171/20170923115426725.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:54:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3763, 3171, N'', CAST(N'2017-09-23 11:55:00' AS SmallDateTime), N'1/3171/20170923115444300.jpg', 3239, 3, NULL, CAST(N'2017-09-23 11:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3764, 3171, N'', CAST(N'2017-09-23 12:07:00' AS SmallDateTime), N'1/3171/20170923120647627.jpg', 3239, 3, NULL, CAST(N'2017-09-23 12:07:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3765, 3171, N'', CAST(N'2017-09-23 12:08:00' AS SmallDateTime), N'1/3171/20170923120757816.jpg', 3239, 3, NULL, CAST(N'2017-09-23 12:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3766, 3171, N'', CAST(N'2017-09-23 12:19:00' AS SmallDateTime), N'1/3171/20170923121921391.jpg', 3239, 3, NULL, CAST(N'2017-09-23 12:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3767, 3171, N'', CAST(N'2017-09-23 12:21:00' AS SmallDateTime), N'1/3171/20170923122039905.jpg', 3239, 3, NULL, CAST(N'2017-09-23 12:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3768, 3171, N'', CAST(N'2017-09-23 12:24:00' AS SmallDateTime), N'1/3171/20170923122334917.jpg', 3239, 3, NULL, CAST(N'2017-09-23 12:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3769, 3171, N'', CAST(N'2017-09-23 12:26:00' AS SmallDateTime), N'1/3171/20170923122551525.jpg', 3239, 3, NULL, CAST(N'2017-09-23 12:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3770, 3174, N'', CAST(N'2017-09-23 14:56:00' AS SmallDateTime), N'1/3174/20170923145614103.png', 3242, 2, NULL, CAST(N'2017-09-23 14:56:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3771, 3174, N'', CAST(N'2017-09-23 19:22:00' AS SmallDateTime), N'1/3174/20170923192206861.png', 3242, 2, NULL, CAST(N'2017-09-23 19:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3772, 3174, N'', CAST(N'2017-09-23 19:22:00' AS SmallDateTime), N'1/3174/20170923192207115.png', 3242, 2, NULL, CAST(N'2017-09-23 19:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3773, 3174, N'', CAST(N'2017-09-23 19:22:00' AS SmallDateTime), N'1/3174/20170923192221177.png', 3242, 2, NULL, CAST(N'2017-09-23 19:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3774, 3177, N'Nzbd', CAST(N'2017-09-24 16:15:00' AS SmallDateTime), NULL, 3245, 1, NULL, CAST(N'2017-09-24 16:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3775, 3177, N'Zjxbd', CAST(N'2017-09-24 16:15:00' AS SmallDateTime), NULL, 3245, 1, NULL, CAST(N'2017-09-24 16:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3776, 3177, N'', CAST(N'2017-09-24 16:15:00' AS SmallDateTime), N'1/3177/20170924161503928.jpg', 3245, 3, NULL, CAST(N'2017-09-24 16:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3777, 3177, N'', CAST(N'2017-09-24 16:15:00' AS SmallDateTime), N'1/3177/20170924161509519.jpg', 3245, 3, NULL, CAST(N'2017-09-24 16:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3778, 3178, N'شكرا على المشاركة في فحص التطبيق ', CAST(N'2017-09-24 20:51:00' AS SmallDateTime), NULL, 3247, 1, NULL, CAST(N'2017-09-24 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3779, 3178, N'شكرا على المشاركة في فحص التطبيق ', CAST(N'2017-09-24 20:51:00' AS SmallDateTime), NULL, 3247, 1, NULL, CAST(N'2017-09-24 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3780, 3178, N'ايوا ', CAST(N'2017-09-24 20:52:00' AS SmallDateTime), NULL, 3246, 1, NULL, CAST(N'2017-09-24 20:52:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3781, 3178, N'هل وصلك اشعار ؟', CAST(N'2017-09-24 20:54:00' AS SmallDateTime), NULL, 3247, 1, NULL, CAST(N'2017-09-24 20:54:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3782, 3178, N'لا ', CAST(N'2017-09-24 20:57:00' AS SmallDateTime), NULL, 3246, 1, NULL, CAST(N'2017-09-24 20:57:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3783, 3178, N'هلا الان اجرب من تلفوني ', CAST(N'2017-09-24 20:57:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 20:57:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3784, 3178, N'تم اضافة خالد لنقاش في هذا الموضوع ', CAST(N'2017-09-24 20:58:00' AS SmallDateTime), NULL, 3247, 1, NULL, CAST(N'2017-09-24 20:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3785, 3178, N'وصل ', CAST(N'2017-09-24 20:58:00' AS SmallDateTime), NULL, 3246, 1, NULL, CAST(N'2017-09-24 20:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3786, 3178, N'الامور طيبه ', CAST(N'2017-09-24 20:58:00' AS SmallDateTime), NULL, 3246, 1, NULL, CAST(N'2017-09-24 20:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3787, 3178, N'نتمنى المشاركه الفعاله من الجميع ', CAST(N'2017-09-24 21:01:00' AS SmallDateTime), NULL, 3246, 1, NULL, CAST(N'2017-09-24 21:01:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3788, 3178, N'نتمنى المشاركه الفعاله من الجميع ', CAST(N'2017-09-24 21:03:00' AS SmallDateTime), NULL, 3246, 1, NULL, CAST(N'2017-09-24 21:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3789, 3178, N'للاسف ما وصل اشعار يحتاج إلى تعديل هذه الجزئية ', CAST(N'2017-09-24 21:03:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3790, 3178, N'تجربة', CAST(N'2017-09-24 21:05:00' AS SmallDateTime), NULL, 3247, 1, NULL, CAST(N'2017-09-24 21:05:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3791, 3178, N'شو رايك في التطبيق ؟', CAST(N'2017-09-24 21:08:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3792, 3178, N'هاني هل موجود ؟', CAST(N'2017-09-24 21:17:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3793, 3178, N'موجود بس ما يوصلني اشعار الى لما افتح التطبيق وادخل المناقشه ', CAST(N'2017-09-24 21:28:00' AS SmallDateTime), NULL, 3246, 1, NULL, CAST(N'2017-09-24 21:28:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3794, 3178, N'Hi brother Arshad', CAST(N'2017-09-24 21:29:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3795, 3178, N'I add you to this ticket chat', CAST(N'2017-09-24 21:29:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3796, 3178, N'Hi', CAST(N'2017-09-24 21:31:00' AS SmallDateTime), NULL, 3249, 1, NULL, CAST(N'2017-09-24 21:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3797, 3178, N'Hi ', CAST(N'2017-09-24 21:31:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3798, 3178, N'Hope Ur getting my messages', CAST(N'2017-09-24 21:31:00' AS SmallDateTime), NULL, 3249, 1, NULL, CAST(N'2017-09-24 21:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3799, 3178, N'YES it''s OK but no push notifications', CAST(N'2017-09-24 21:32:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3800, 3178, N'News notifications are getting', CAST(N'2017-09-24 21:32:00' AS SmallDateTime), NULL, 3249, 1, NULL, CAST(N'2017-09-24 21:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3801, 3178, N'I will check tomorrow ', CAST(N'2017-09-24 21:33:00' AS SmallDateTime), NULL, 3249, 1, NULL, CAST(N'2017-09-24 21:33:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3802, 3178, N'yes news is ok 
', CAST(N'2017-09-24 21:33:00' AS SmallDateTime), NULL, 3247, 1, NULL, CAST(N'2017-09-24 21:33:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3803, 3178, N'event is no notifications 
', CAST(N'2017-09-24 21:33:00' AS SmallDateTime), NULL, 3247, 1, NULL, CAST(N'2017-09-24 21:33:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3804, 3178, N'I will call the SMS tomorrow and ask about it', CAST(N'2017-09-24 21:35:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3805, 3178, N'Event also I will check ', CAST(N'2017-09-24 21:35:00' AS SmallDateTime), NULL, 3249, 1, NULL, CAST(N'2017-09-24 21:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3806, 3178, N'OK thanks', CAST(N'2017-09-24 21:35:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3807, 3178, N'Please let me know the SMS issue', CAST(N'2017-09-24 21:35:00' AS SmallDateTime), NULL, 3249, 1, NULL, CAST(N'2017-09-24 21:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3808, 3178, N'Our side it is sending', CAST(N'2017-09-24 21:35:00' AS SmallDateTime), NULL, 3249, 1, NULL, CAST(N'2017-09-24 21:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3809, 3178, N'OK I will', CAST(N'2017-09-24 21:36:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:36:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3810, 3178, N'Other everything is ok ?', CAST(N'2017-09-24 21:36:00' AS SmallDateTime), NULL, 3249, 1, NULL, CAST(N'2017-09-24 21:36:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3811, 3178, N'In the chat when I type in English it''s not Chang left to right', CAST(N'2017-09-24 21:37:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:37:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3812, 3178, N'It''s from the App setting I change it now OK ', CAST(N'2017-09-24 21:38:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:38:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3813, 3178, N'OK will close this ticket now ', CAST(N'2017-09-24 21:38:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:38:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3814, 3178, N'Thank you all ', CAST(N'2017-09-24 21:39:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-24 21:39:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3815, 3179, N'Dum Dum', CAST(N'2017-09-25 07:18:00' AS SmallDateTime), NULL, 3250, 1, NULL, CAST(N'2017-09-25 07:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3816, 3179, N'Hi brother', CAST(N'2017-09-25 16:30:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-25 16:30:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3817, 3175, N'12', CAST(N'2017-09-25 22:10:00' AS SmallDateTime), NULL, 3252, 1, NULL, CAST(N'2017-09-25 22:10:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3818, 3178, N'هلا هاني ', CAST(N'2017-09-25 22:12:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-25 22:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3819, 3178, N'هل توصلك اشعارات ؟', CAST(N'2017-09-25 22:13:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-25 22:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3820, 3175, N'34', CAST(N'2017-09-25 22:15:00' AS SmallDateTime), NULL, 3252, 1, NULL, CAST(N'2017-09-25 22:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3821, 3175, N'59', CAST(N'2017-09-25 22:15:00' AS SmallDateTime), NULL, 3243, 1, NULL, CAST(N'2017-09-25 22:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3822, 3178, N'تجربة الاشعارات هل توصل ؟', CAST(N'2017-09-25 22:16:00' AS SmallDateTime), NULL, 3247, 1, NULL, CAST(N'2017-09-25 22:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3823, 3180, N'شكرا لمشاركتك في التجربة ', CAST(N'2017-09-25 22:21:00' AS SmallDateTime), NULL, 3254, 1, NULL, CAST(N'2017-09-25 22:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3824, 3180, N'', CAST(N'2017-09-25 22:21:00' AS SmallDateTime), N'1/3180/20170925222126473.jpg', 3253, 3, NULL, CAST(N'2017-09-25 22:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3825, 3180, N'رسلت صوره تجربه ', CAST(N'2017-09-25 22:22:00' AS SmallDateTime), NULL, 3253, 1, NULL, CAST(N'2017-09-25 22:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3826, 3180, N'هل يوصلك اشعار ', CAST(N'2017-09-25 22:23:00' AS SmallDateTime), NULL, 3254, 1, NULL, CAST(N'2017-09-25 22:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3827, 3180, N'لا ', CAST(N'2017-09-25 22:24:00' AS SmallDateTime), NULL, 3253, 1, NULL, CAST(N'2017-09-25 22:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3828, 3180, N'اشعار رساله في فالموضوع ما يوصل ', CAST(N'2017-09-25 22:24:00' AS SmallDateTime), NULL, 3253, 1, NULL, CAST(N'2017-09-25 22:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3829, 3180, N'هلا ', CAST(N'2017-09-25 22:34:00' AS SmallDateTime), NULL, 3254, 1, NULL, CAST(N'2017-09-25 22:34:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3830, 3180, N'هل توصلك ', CAST(N'2017-09-25 22:35:00' AS SmallDateTime), NULL, 3254, 1, NULL, CAST(N'2017-09-25 22:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3831, 3180, N'بعده ما وصلني شي ', CAST(N'2017-09-25 22:43:00' AS SmallDateTime), NULL, 3253, 1, NULL, CAST(N'2017-09-25 22:43:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3832, 3181, N'مرحبا بكم اخي احمد ', CAST(N'2017-09-25 23:27:00' AS SmallDateTime), NULL, 3256, 1, NULL, CAST(N'2017-09-25 23:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3833, 3181, N'اهلا', CAST(N'2017-09-25 23:29:00' AS SmallDateTime), NULL, 3255, 1, NULL, CAST(N'2017-09-25 23:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3834, 3181, N'مرحبا ', CAST(N'2017-09-25 23:30:00' AS SmallDateTime), NULL, 3256, 1, NULL, CAST(N'2017-09-25 23:30:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3835, 3181, N'هلا احمد ', CAST(N'2017-09-25 23:31:00' AS SmallDateTime), NULL, 3257, 1, NULL, CAST(N'2017-09-25 23:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3836, 3181, N'تجربه هل من جديد ', CAST(N'2017-09-26 16:25:00' AS SmallDateTime), NULL, 3257, 1, NULL, CAST(N'2017-09-26 16:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3837, 3178, N'تجربة هل من جديد ', CAST(N'2017-09-26 16:26:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-26 16:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3838, 3138, N'تجربة ', CAST(N'2017-09-26 16:26:00' AS SmallDateTime), NULL, 3200, 1, NULL, CAST(N'2017-09-26 16:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3839, 3180, N'تجربة هل يوصل اشعار ؟', CAST(N'2017-09-26 16:28:00' AS SmallDateTime), NULL, 3254, 1, NULL, CAST(N'2017-09-26 16:28:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3840, 3181, N'هل يوصل اشعار ؟', CAST(N'2017-09-26 16:28:00' AS SmallDateTime), NULL, 3256, 1, NULL, CAST(N'2017-09-26 16:28:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3841, 3180, N'واخيرا وصل ', CAST(N'2017-09-26 16:29:00' AS SmallDateTime), NULL, 3253, 1, NULL, CAST(N'2017-09-26 16:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3842, 3180, N'كيف عندك ؟', CAST(N'2017-09-26 16:29:00' AS SmallDateTime), NULL, 3253, 1, NULL, CAST(N'2017-09-26 16:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3843, 3181, N'وصل واحد اليوم مال حول حول', CAST(N'2017-09-26 16:29:00' AS SmallDateTime), NULL, 3255, 1, NULL, CAST(N'2017-09-26 16:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3844, 3175, N'هل يوصل اشعار ؟', CAST(N'2017-09-26 16:29:00' AS SmallDateTime), NULL, 3252, 1, NULL, CAST(N'2017-09-26 16:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3845, 3181, N'للمحادثات ؟', CAST(N'2017-09-26 16:31:00' AS SmallDateTime), NULL, 3257, 1, NULL, CAST(N'2017-09-26 16:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3846, 3181, N'اها اذاك خبر ', CAST(N'2017-09-26 16:32:00' AS SmallDateTime), NULL, 3257, 1, NULL, CAST(N'2017-09-26 16:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3847, 3181, N'بتشارك ان شاء الله دامك استلمت الدعوة ', CAST(N'2017-09-26 16:32:00' AS SmallDateTime), NULL, 3257, 1, NULL, CAST(N'2017-09-26 16:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3848, 3181, N'شكرا لمشاركتك في فحص التطبيق اخي احمد دائما تاعبينك معنا ', CAST(N'2017-09-26 16:34:00' AS SmallDateTime), NULL, 3256, 1, NULL, CAST(N'2017-09-26 16:34:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3849, 3181, N'', CAST(N'2017-09-26 16:35:00' AS SmallDateTime), N'1/3181/20170926163433558.jpg', 3256, 3, NULL, CAST(N'2017-09-26 16:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3850, 3181, N'من قلت الاسامي شوف اسمه التجاري ', CAST(N'2017-09-26 16:35:00' AS SmallDateTime), NULL, 3256, 1, NULL, CAST(N'2017-09-26 16:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3851, 3181, N'شكلة في الإمارات يبين من رقم التلفونات ', CAST(N'2017-09-26 16:36:00' AS SmallDateTime), NULL, 3257, 1, NULL, CAST(N'2017-09-26 16:36:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3852, 3175, N'هل من جديد ؟', CAST(N'2017-09-26 17:26:00' AS SmallDateTime), NULL, 3243, 1, NULL, CAST(N'2017-09-26 17:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3853, 3178, N'تجربة ', CAST(N'2017-09-26 17:57:00' AS SmallDateTime), NULL, 3248, 1, NULL, CAST(N'2017-09-26 17:57:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3854, 3181, N'تجربة ', CAST(N'2017-09-26 17:58:00' AS SmallDateTime), NULL, 3256, 1, NULL, CAST(N'2017-09-26 17:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3855, 3175, N'تجربة جديدة', CAST(N'2017-09-26 17:58:00' AS SmallDateTime), NULL, 3252, 1, NULL, CAST(N'2017-09-26 17:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3856, 3181, N'وصل', CAST(N'2017-09-26 17:59:00' AS SmallDateTime), NULL, 3255, 1, NULL, CAST(N'2017-09-26 17:59:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3857, 3175, N'



















.', CAST(N'2017-09-26 18:00:00' AS SmallDateTime), NULL, 3243, 1, NULL, CAST(N'2017-09-26 18:00:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3858, 3181, N'من الادمن يوصل ، بس لما انا اكتب ما يوصل صح ؟', CAST(N'2017-09-26 18:02:00' AS SmallDateTime), NULL, 3256, 1, NULL, CAST(N'2017-09-26 18:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3859, 3180, N'من الادمن يوصل بس بعدة باقي اذا محادثة مشتركة بين اكثر من شخص ما يوصل ', CAST(N'2017-09-26 18:03:00' AS SmallDateTime), NULL, 3254, 1, NULL, CAST(N'2017-09-26 18:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3860, 3181, N'لما انا ارسل هل يوصل ؟', CAST(N'2017-09-26 18:05:00' AS SmallDateTime), NULL, 3257, 1, NULL, CAST(N'2017-09-26 18:05:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3861, 3175, N'hi ', CAST(N'2017-09-26 21:05:00' AS SmallDateTime), NULL, 3258, 1, NULL, CAST(N'2017-09-26 21:05:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3862, 3181, N'وصل تست كونتينت', CAST(N'2017-09-26 21:59:00' AS SmallDateTime), NULL, 3255, 1, NULL, CAST(N'2017-09-26 21:59:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3863, 3181, N'وصلت عدة اشعارات تجارب', CAST(N'2017-09-27 11:58:00' AS SmallDateTime), NULL, 3255, 1, NULL, CAST(N'2017-09-27 11:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3864, 3179, N'test 1', CAST(N'2017-09-27 20:03:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 20:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3865, 3179, N'test 2', CAST(N'2017-09-27 20:04:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 20:04:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3866, 3179, N'test 3', CAST(N'2017-09-27 20:57:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 20:57:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3867, 3179, N'test 4', CAST(N'2017-09-27 21:47:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 21:47:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3868, 3179, N'test 5', CAST(N'2017-09-27 22:01:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 22:01:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3869, 3179, N'test 6', CAST(N'2017-09-27 22:02:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 22:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3870, 3179, N'test 7', CAST(N'2017-09-27 22:04:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 22:04:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3871, 3179, N'test 8', CAST(N'2017-09-27 22:11:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 22:11:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3872, 3179, N'test 9', CAST(N'2017-09-27 22:11:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 22:11:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3873, 3179, N'test 10', CAST(N'2017-09-27 22:13:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 22:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3874, 3179, N'test 11', CAST(N'2017-09-27 22:17:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-27 22:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3875, 3179, N'', CAST(N'2017-09-27 22:18:00' AS SmallDateTime), N'1/3179/20170927221800670.png', 3251, 2, NULL, CAST(N'2017-09-27 22:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3876, 3179, N'', CAST(N'2017-09-27 22:18:00' AS SmallDateTime), N'1/3179/20170927221815470.png', 3251, 2, NULL, CAST(N'2017-09-27 22:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3877, 3179, N'', CAST(N'2017-09-27 22:19:00' AS SmallDateTime), N'1/3179/20170927221837971.png', 3251, 2, NULL, CAST(N'2017-09-27 22:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3878, 3179, N'test 12', CAST(N'2017-09-29 11:24:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-29 11:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3879, 3179, N'test 13', CAST(N'2017-09-29 11:26:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-29 11:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3880, 3179, N'test 14', CAST(N'2017-09-29 11:32:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-29 11:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3881, 3179, N'TEST 15', CAST(N'2017-09-29 11:35:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-29 11:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3882, 3179, N'TEST 16', CAST(N'2017-09-29 11:37:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-29 11:37:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3883, 3179, N'TEST 17', CAST(N'2017-09-29 11:40:00' AS SmallDateTime), NULL, 3251, 1, NULL, CAST(N'2017-09-29 11:40:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3884, 3182, N'Hai', CAST(N'2017-09-30 20:51:00' AS SmallDateTime), NULL, 3259, 1, NULL, CAST(N'2017-09-30 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3885, 3182, N'Hai', CAST(N'2017-09-30 20:51:00' AS SmallDateTime), NULL, 3259, 1, NULL, CAST(N'2017-09-30 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3886, 3182, N'Haaaa', CAST(N'2017-09-30 20:51:00' AS SmallDateTime), NULL, 3259, 1, NULL, CAST(N'2017-09-30 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3887, 3182, N'34443', CAST(N'2017-09-30 20:53:00' AS SmallDateTime), NULL, 3260, 1, NULL, CAST(N'2017-09-30 20:53:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_DETAILS] OFF
GO
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_TYPES] ON 

GO
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (1, N'text')
GO
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (2, N'png')
GO
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (3, N'jpg')
GO
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (4, N'jpeg')
GO
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (5, N'doc')
GO
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (6, N'docx')
GO
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (7, N'pdf')
GO
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_TYPES] OFF
GO
SET IDENTITY_INSERT [dbo].[TICKET_PARTICIPANTS] ON 

GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3197, 3136, 1104, 1104, CAST(N'2017-09-22 11:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3198, 3136, 1068, 1068, CAST(N'2017-09-22 11:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3199, 3137, 1070, 1070, CAST(N'2017-09-22 11:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3200, 3138, 1105, 1105, CAST(N'2017-09-22 13:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3201, 3138, 1068, 1068, CAST(N'2017-09-22 13:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3202, 3139, 1107, 1107, CAST(N'2017-09-22 20:07:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3203, 3139, 1068, 1068, CAST(N'2017-09-22 20:07:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3204, 3139, 1104, 1068, CAST(N'2017-09-22 20:07:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3205, 3140, 1108, 1108, CAST(N'2017-09-22 22:56:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3206, 3141, 1108, 1108, CAST(N'2017-09-22 23:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3207, 3142, 1108, 1108, CAST(N'2017-09-22 23:04:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3208, 3143, 1108, 1108, CAST(N'2017-09-22 23:04:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3209, 3144, 1108, 1108, CAST(N'2017-09-22 23:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3210, 3145, 1104, 1104, CAST(N'2017-09-22 23:41:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3211, 3146, 1104, 1104, CAST(N'2017-09-22 23:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3212, 3147, 1104, 1104, CAST(N'2017-09-22 23:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3213, 3148, 1104, 1104, CAST(N'2017-09-22 23:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3214, 3149, 1104, 1104, CAST(N'2017-09-22 23:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3215, 3150, 1104, 1104, CAST(N'2017-09-22 23:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3216, 3151, 1104, 1104, CAST(N'2017-09-22 23:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3217, 3152, 1104, 1104, CAST(N'2017-09-22 23:52:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3218, 3153, 1104, 1104, CAST(N'2017-09-22 23:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3219, 3154, 1104, 1104, CAST(N'2017-09-23 00:00:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3220, 3155, 1104, 1104, CAST(N'2017-09-23 00:01:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3221, 3156, 1104, 1104, CAST(N'2017-09-23 00:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3222, 3157, 1104, 1104, CAST(N'2017-09-23 00:05:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3223, 3158, 1104, 1104, CAST(N'2017-09-23 00:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3224, 3159, 1104, 1104, CAST(N'2017-09-23 00:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3225, 3144, 1068, 1068, CAST(N'2017-09-23 00:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3226, 3160, 1108, 1108, CAST(N'2017-09-23 00:20:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3227, 3161, 1108, 1108, CAST(N'2017-09-23 00:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3228, 3160, 1068, 1068, CAST(N'2017-09-23 00:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3229, 3162, 1108, 1068, CAST(N'2017-09-23 00:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3230, 3162, 1068, 1068, CAST(N'2017-09-23 00:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3231, 3163, 1108, 1108, CAST(N'2017-09-23 00:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3232, 3164, 1108, 1108, CAST(N'2017-09-23 00:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3233, 3165, 1108, 1108, CAST(N'2017-09-23 00:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3234, 3166, 1108, 1108, CAST(N'2017-09-23 00:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3235, 3167, 1108, 1108, CAST(N'2017-09-23 00:30:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3236, 3168, 1104, 1104, CAST(N'2017-09-23 00:37:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3237, 3169, 1104, 1104, CAST(N'2017-09-23 00:44:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3238, 3170, 1104, 1104, CAST(N'2017-09-23 10:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3239, 3171, 1104, 1104, CAST(N'2017-09-23 11:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3240, 3172, 1104, 1104, CAST(N'2017-09-23 11:06:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3241, 3173, 1104, 1104, CAST(N'2017-09-23 12:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3242, 3174, 1110, 1110, CAST(N'2017-09-23 14:52:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3243, 3175, 1105, 1105, CAST(N'2017-09-23 23:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3244, 3176, 1104, 1104, CAST(N'2017-09-24 16:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3245, 3177, 1104, 1104, CAST(N'2017-09-24 16:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3246, 3178, 1115, 1115, CAST(N'2017-09-24 20:50:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3247, 3178, 1068, 1068, CAST(N'2017-09-24 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3248, 3178, 1105, 1068, CAST(N'2017-09-24 20:56:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3250, 3179, 1104, 1104, CAST(N'2017-09-25 07:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3251, 3179, 1068, 1068, CAST(N'2017-09-25 16:30:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3252, 3175, 1068, 1068, CAST(N'2017-09-25 22:10:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3253, 3180, 1115, 1115, CAST(N'2017-09-25 22:20:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3254, 3180, 1068, 1068, CAST(N'2017-09-25 22:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3255, 3181, 1117, 1117, CAST(N'2017-09-25 23:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3256, 3181, 1068, 1068, CAST(N'2017-09-25 23:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3257, 3181, 1105, 1068, CAST(N'2017-09-25 23:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3258, 3175, 1118, 1118, CAST(N'2017-09-26 21:05:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3259, 3182, 1104, 1104, CAST(N'2017-09-30 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3260, 3182, 1068, 1068, CAST(N'2017-09-30 20:53:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[TICKET_PARTICIPANTS] OFF
GO
SET IDENTITY_INSERT [dbo].[TICKET_STATUS] ON 

GO
INSERT [dbo].[TICKET_STATUS] ([ID], [STATUS_NAME]) VALUES (1, N'Open')
GO
INSERT [dbo].[TICKET_STATUS] ([ID], [STATUS_NAME]) VALUES (2, N'Closed')
GO
INSERT [dbo].[TICKET_STATUS] ([ID], [STATUS_NAME]) VALUES (3, N'Rejected')
GO
INSERT [dbo].[TICKET_STATUS] ([ID], [STATUS_NAME]) VALUES (4, N'Deleted')
GO
SET IDENTITY_INSERT [dbo].[TICKET_STATUS] OFF
GO
SET IDENTITY_INSERT [dbo].[TICKETS] ON 

GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3136, 1, N'Hai', N'Jsbsbs', NULL, 1, 4, NULL, 1104, CAST(N'2017-09-22 11:12:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:13:00' AS SmallDateTime), N'1vWDCD8C', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3137, 1, N'Hfg', N'Bvv', NULL, 1, 1, NULL, 1070, CAST(N'2017-09-22 11:46:00' AS SmallDateTime), NULL, NULL, N'0uU2DD91', 1070, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3138, 1, N'Test', N'Test', NULL, 1, 1, NULL, 1105, CAST(N'2017-09-22 13:16:00' AS SmallDateTime), NULL, NULL, N'3uC1450A', 1105, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3139, 1, N'Hai', N'Hdh', NULL, 1, 4, NULL, 1107, CAST(N'2017-09-22 20:07:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:13:00' AS SmallDateTime), N'5pPE8215', 1107, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3144, 1, N'Water pipe leakage', N'WAter pipe near mutrah leaking', N'1/3144/20170922230755072.jpg', 1, 1, NULL, 1108, CAST(N'2017-09-22 23:08:00' AS SmallDateTime), NULL, NULL, N'5nC315B8', 1108, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3158, 1, N'test 4 :: image upload test through api', N'sample string 5', N'1/3158/20170923001318423.png', 1, 4, NULL, 1104, CAST(N'2017-09-23 00:13:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:13:00' AS SmallDateTime), N'1iOE78BA', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3159, 1, N'test 4 :: image upload test through api', N'sample string 5', N'1/3159/20170923001642742.png', 1, 4, NULL, 1104, CAST(N'2017-09-23 00:17:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:12:00' AS SmallDateTime), N'9qP4FCCD', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3160, 1, N'Ritz', N'Maruthi Suzuki Ritz', NULL, 1, 2, NULL, 1108, CAST(N'2017-09-23 00:20:00' AS SmallDateTime), 1108, CAST(N'2017-09-23 00:22:00' AS SmallDateTime), N'0lDA5740', 1108, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3161, 1, N'Yout', N'Yours ', N'1/3161/20170923002045295.jpg', 1, 4, NULL, 1108, CAST(N'2017-09-23 00:21:00' AS SmallDateTime), 1108, CAST(N'2017-09-23 00:21:00' AS SmallDateTime), N'6wQ0AB62', 1108, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3162, 1, N'foo test ', N'test ', N'1/3162/20170923002401553.jpg', 1, 1, NULL, 1068, CAST(N'2017-09-23 00:24:00' AS SmallDateTime), NULL, NULL, N'9lCB4051', 1108, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3163, 1, N'Dizooz', N'Nfjdkdkdmd', NULL, 1, 1, NULL, 1108, CAST(N'2017-09-23 00:29:00' AS SmallDateTime), NULL, NULL, N'9yT7B734', 1108, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3164, 1, N'Iop iop', N'Hciddkdkkdlelel', NULL, 1, 1, NULL, 1108, CAST(N'2017-09-23 00:29:00' AS SmallDateTime), NULL, NULL, N'3lAA8DF0', 1108, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3165, 1, N'Mandrid ', N'PT usha', NULL, 1, 1, NULL, 1108, CAST(N'2017-09-23 00:29:00' AS SmallDateTime), NULL, NULL, N'4dP016A5', 1108, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3166, 1, N'LG servhce ', N'Ykxnkdxk jdbdkdkdk jfndm', NULL, 1, 1, NULL, 1108, CAST(N'2017-09-23 00:29:00' AS SmallDateTime), NULL, NULL, N'8xCFCF89', 1108, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3167, 1, N'ManavikS', N'Jddkxkx', NULL, 1, 1, NULL, 1108, CAST(N'2017-09-23 00:30:00' AS SmallDateTime), NULL, NULL, N'2vB925E9', 1108, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3168, 1, N'test 4 :: image upload test through api', N'sample string 5', N'1/3168/20170923003722764.png', 1, 4, NULL, 1104, CAST(N'2017-09-23 00:37:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:12:00' AS SmallDateTime), N'4lG8BCD0', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3169, 1, N'test 4 :: image upload test through api', N'sample string 5', N'1/3169/20170923004338149.png', 1, 4, NULL, 1104, CAST(N'2017-09-23 00:44:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:12:00' AS SmallDateTime), N'3mB8C792', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3170, 1, N'test 4 :: image upload test through api', N'sample string 5', N'1/3170/20170923104825667.png', 1, 4, NULL, 1104, CAST(N'2017-09-23 10:48:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:12:00' AS SmallDateTime), N'8gGBEFB3', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3171, 1, N'test 4 :: image upload test through api', N'sample string 5', N'1/3171/20170923110154968.png', 1, 4, NULL, 1104, CAST(N'2017-09-23 11:02:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:12:00' AS SmallDateTime), N'4vQ4BAE6', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3172, 1, N'test 5 :: image upload test through api', N'sample string 5', N'1/3172/20170923110543270.png', 1, 4, NULL, 1104, CAST(N'2017-09-23 11:06:00' AS SmallDateTime), 1104, CAST(N'2017-09-23 12:19:00' AS SmallDateTime), N'9iN7236B', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3173, 1, N'Nzbs', N'Zbzbd', N'1/3173/20170923122654783.jpg', 1, 4, NULL, 1104, CAST(N'2017-09-23 12:27:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 16:12:00' AS SmallDateTime), N'8hV8400B', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3174, 1, N'Hello', N'Hello desc', N'1/3174/20170923145224407.png', 1, 1, NULL, 1110, CAST(N'2017-09-23 14:52:00' AS SmallDateTime), NULL, NULL, N'5oMBEE51', 1110, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3175, 1, N'مسجد صياء الحدرية ', N'نرغب في الموافقة على اقامة محلات تجارية في ارض المسجد لتكون دخل للمسحد ', NULL, 1, 1, NULL, 1105, CAST(N'2017-09-23 23:02:00' AS SmallDateTime), NULL, NULL, N'4aY7D2CB', 1105, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3176, 1, N'Test', N'Test', NULL, 1, 2, NULL, 1104, CAST(N'2017-09-24 16:13:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 20:47:00' AS SmallDateTime), N'3bA14016', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3177, 1, N'Hh', N'Hhh', N'1/3177/20170924161432885.jpg', 1, 4, NULL, 1104, CAST(N'2017-09-24 16:15:00' AS SmallDateTime), 1104, CAST(N'2017-09-24 20:47:00' AS SmallDateTime), N'9bE2B50C', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3178, 1, N'هجره سيدنا محمد ', N'موضوع النقاش عن الاحداث العامه لهجره سيد الخلق محمد صلى الله عليه وسلم ', NULL, 1, 1, NULL, 1115, CAST(N'2017-09-24 20:50:00' AS SmallDateTime), 1068, CAST(N'2017-09-25 22:11:00' AS SmallDateTime), N'7dXEB12C', 1115, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3179, 1, N'Test', N'Test', N'1/3179/20170925071730045.jpg', 1, 1, NULL, 1104, CAST(N'2017-09-25 07:18:00' AS SmallDateTime), 1068, CAST(N'2017-09-27 20:03:00' AS SmallDateTime), N'1vEC37F3', 1104, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3180, 1, N'عماااان ', N'كيف نحافظ على امن بلادنا عمان ؟', NULL, 1, 1, NULL, 1115, CAST(N'2017-09-25 22:20:00' AS SmallDateTime), NULL, NULL, N'6iX7E958', 1115, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3181, 1, N'السلام عليكم', N'مرحب', NULL, 1, 1, NULL, 1117, CAST(N'2017-09-25 23:25:00' AS SmallDateTime), NULL, NULL, N'4pJDB9B2', 1117, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3182, 1, N'Test 1234', N'Test', NULL, 1, 1, NULL, 1104, CAST(N'2017-09-30 20:51:00' AS SmallDateTime), NULL, NULL, N'1iU1E967', 1104, 1)
GO
SET IDENTITY_INSERT [dbo].[TICKETS] OFF
GO
SET IDENTITY_INSERT [dbo].[USER_DETAILS] ON 

GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1068, 1068, N'Admin', N'89898', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1100, 1100, N'Samh', N'87878', NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1101, 1101, N'samh', NULL, NULL, NULL, NULL, NULL, 77546, 0, 1, CAST(N'2017-09-22 09:17:00' AS SmallDateTime), NULL, NULL, 0, 2, NULL, 2, NULL, CAST(N'2017-09-22 09:17:00' AS SmallDateTime), NULL, CAST(N'2017-09-22 09:17:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1102, 1102, N'samh', NULL, NULL, 1, 1, 1000, 76967, 0, 0, CAST(N'2017-09-22 10:07:00' AS SmallDateTime), NULL, NULL, 0, 2, NULL, 2, NULL, CAST(N'2017-09-22 10:07:00' AS SmallDateTime), NULL, CAST(N'2017-09-22 10:07:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1103, 1103, N'hhhhh', NULL, NULL, 1, 1, 1000, 20856, 0, 1, CAST(N'2017-09-22 10:14:00' AS SmallDateTime), NULL, NULL, 0, 2, NULL, 2, NULL, CAST(N'2017-09-22 10:14:00' AS SmallDateTime), NULL, CAST(N'2017-09-22 10:14:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1104, 1104, N'Arshad', NULL, NULL, NULL, NULL, NULL, 36961, 1, 1, CAST(N'2017-09-22 11:01:00' AS SmallDateTime), NULL, NULL, 0, 3, N'a645550a-efc8-490d-83ad-96ea3c264d96', 2, NULL, CAST(N'2017-09-22 11:01:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 21:31:00' AS SmallDateTime), CAST(N'2017-09-30 20:50:56.833' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1105, 1105, N'خالد ناصر علي الجرداني', N'0', NULL, 1, 6, 1056, 18579, 1, 1, CAST(N'2017-09-22 12:01:00' AS SmallDateTime), NULL, 0, 0, 2, N'305806c7-82b8-4916-bf0f-3b63d9e88cd3', 1, NULL, CAST(N'2017-09-22 12:01:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 21:06:00' AS SmallDateTime), CAST(N'2017-09-23 23:02:04.293' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1108, 1108, N'Samh muscat', NULL, NULL, 1, 3, 1011, 76658, 1, 1, CAST(N'2017-09-22 21:56:00' AS SmallDateTime), NULL, NULL, 0, 2, N'1d0fc64b-ca45-471b-a8fd-086b4317c4fb', 2, NULL, CAST(N'2017-09-22 21:56:00' AS SmallDateTime), NULL, CAST(N'2017-09-22 21:56:00' AS SmallDateTime), CAST(N'2017-09-23 00:29:41.960' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1109, 1109, N'جهاد ', N'0', NULL, 1, 2, 1043, 45984, 0, 1, CAST(N'2017-09-22 23:02:00' AS SmallDateTime), NULL, 0, 0, 2, N'305806c7-82b8-4916-bf0f-3b63d9e88cd3', 1, NULL, CAST(N'2017-09-22 23:02:00' AS SmallDateTime), 1068, CAST(N'2017-09-25 21:49:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1110, 1110, N'Hshshs', NULL, NULL, NULL, NULL, NULL, 68324, 1, 1, CAST(N'2017-09-23 14:44:00' AS SmallDateTime), NULL, NULL, 0, 2, N'4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154', 2, NULL, CAST(N'2017-09-23 14:44:00' AS SmallDateTime), NULL, CAST(N'2017-09-23 14:44:00' AS SmallDateTime), CAST(N'2017-09-23 14:52:24.417' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1111, 1111, N'يحيى الحسني', NULL, NULL, 1, 2, 1035, 10349, 0, 0, CAST(N'2017-09-23 21:19:00' AS SmallDateTime), NULL, NULL, 0, 2, N'305806c7-82b8-4916-bf0f-3b63d9e88cd3', 1, NULL, CAST(N'2017-09-23 21:19:00' AS SmallDateTime), NULL, CAST(N'2017-09-23 21:19:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1114, 1114, N'test', NULL, NULL, NULL, NULL, NULL, 13401, 0, 1, CAST(N'2017-09-24 13:46:00' AS SmallDateTime), NULL, NULL, 0, 2, NULL, 2, NULL, CAST(N'2017-09-24 13:46:00' AS SmallDateTime), NULL, CAST(N'2017-09-24 13:46:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1115, 1115, N'هاني الجرداني ', NULL, NULL, 1, 6, 1056, 24539, 1, 0, CAST(N'2017-09-24 20:42:00' AS SmallDateTime), NULL, NULL, 0, 2, N'7d7715a6-d3a5-4ba9-830c-e9478ef3672e', 1, NULL, CAST(N'2017-09-24 20:42:00' AS SmallDateTime), NULL, CAST(N'2017-09-24 20:42:00' AS SmallDateTime), CAST(N'2017-09-25 22:20:15.680' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1116, 1116, N'جهاد ناصر علي الجرداني', NULL, NULL, 1, 2, 1034, 81253, 0, 1, CAST(N'2017-09-25 21:52:00' AS SmallDateTime), NULL, NULL, 0, 2, N'305806c7-82b8-4916-bf0f-3b63d9e88cd3', 1, NULL, CAST(N'2017-09-25 21:52:00' AS SmallDateTime), NULL, CAST(N'2017-09-25 21:52:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1117, 1117, N'احمد البوسعيدي', NULL, NULL, 1, 2, 1034, 85363, 1, 1, CAST(N'2017-09-25 23:24:00' AS SmallDateTime), NULL, NULL, 0, 2, N'63da17fa-bb30-42af-bb9c-c46207e3de8e', 1, NULL, CAST(N'2017-09-25 23:24:00' AS SmallDateTime), NULL, CAST(N'2017-09-25 23:24:00' AS SmallDateTime), CAST(N'2017-09-25 23:25:24.053' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1118, 1118, N'Khalid Nasser Ali AlJardani', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 1068, CAST(N'2017-09-26 21:03:00' AS SmallDateTime), NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[USER_DETAILS] OFF
GO
SET IDENTITY_INSERT [dbo].[USER_TYPES] ON 

GO
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (1, N'Admin')
GO
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (2, N'Member')
GO
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (3, N'Staff')
GO
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (4, N'MobileUser')
GO
SET IDENTITY_INSERT [dbo].[USER_TYPES] OFF
GO
SET IDENTITY_INSERT [dbo].[USERS] ON 

GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1068, N'admin', N'admin', 1, N'123456', N'admin@takamul.com', NULL, 1, 0, NULL, 1, CAST(N'2017-07-14 00:00:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1100, N'samh', N'samh', 2, N'54474236', N'samh.k2007@gmail.com', 1, 1, 0, NULL, 1, NULL, NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1101, NULL, NULL, 4, N'12345678', N'samh.k2007@mail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-22 09:17:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1102, NULL, NULL, 4, N'9658745', N'samh.k2007@mail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-22 10:07:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1103, NULL, NULL, 4, N'99988888', N'hhh@jjj.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-22 10:14:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1104, NULL, NULL, 4, N'98455049', N'Dff@ddd.com', 1, 1, 0, N'blocked', NULL, CAST(N'2017-09-22 11:01:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 21:31:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1105, NULL, NULL, 4, N'99885080', N'Khalid@sawa.om', 1, 1, 0, NULL, NULL, CAST(N'2017-09-22 12:01:00' AS SmallDateTime), 1068, CAST(N'2017-09-24 21:06:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1108, NULL, NULL, 4, N'93442341', N'Samh@fmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-22 21:56:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1109, NULL, NULL, 4, N'99700666', N'.jJ@j', 1, 1, 0, NULL, NULL, CAST(N'2017-09-22 23:02:00' AS SmallDateTime), 1068, CAST(N'2017-09-25 21:49:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1110, NULL, NULL, 4, N'97646778', N'Hshs@jj.kk', 1, 1, 0, NULL, NULL, CAST(N'2017-09-23 14:44:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1111, NULL, NULL, 4, N'99358114', N'Y@y.y', 1, 1, 0, NULL, NULL, CAST(N'2017-09-23 21:19:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1114, NULL, NULL, 4, N'91534771', N'test@test.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-24 13:46:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1115, NULL, NULL, 4, N'99795221', N'siya18@hotmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-24 20:42:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1116, NULL, NULL, 4, N'99700664', N'J@j.j', 1, 1, 0, NULL, NULL, CAST(N'2017-09-25 21:52:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1117, NULL, NULL, 4, N'95405050', N'Whicrm@gmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-25 23:24:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1118, N'a41zz', N'598873', 3, N'99885080', N'KHALID.JARDANI@GMAIL.COM', 1, 1, 0, NULL, 1068, CAST(N'2017-09-26 21:03:00' AS SmallDateTime), 1068, CAST(N'2017-09-26 21:04:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[USERS] OFF
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (1, N'1', N'1', N'1000', N'مسقط', N'Muscat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (2, N'1', N'1', N'1001', N'البستان', N'Al Bustan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (3, N'1', N'1', N'1002', N'حرامل', N'Haramel')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (4, N'1', N'1', N'1003', N'ينكت', N'Yankit')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (5, N'1', N'1', N'1004', N'الخيران', N'Al Khiran')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (6, N'1', N'1', N'1005', N'السيفة', N'As Sifah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (7, N'1', N'1', N'1006', N'حلة الشيخ', N'Hullat al Sheikh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (8, N'1', N'3', N'1007', N'مطرح', N'Mutrah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (9, N'1', N'3', N'1008', N'مطيرح', N'Mutirah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (10, N'1', N'3', N'1009', N'شطيفي', N'Shatayfi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (11, N'1', N'3', N'1010', N'دارسيت الشرقية', N'Darsit Al sharqiah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (12, N'1', N'3', N'1011', N'القرم', N'Qurum ')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (13, N'1', N'3', N'1012', N'البجرية', N'AL bajrah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (14, N'1', N'5', N'1013', N'الحاجر', N'Al Hajir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (15, N'1', N'3', N'1014', N'الخفيجي', N'Al khafiji')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (16, N'1', N'3', N'1015', N'جحلوت', N'Jahalut')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (17, N'1', N'3', N'1016', N'بعي', N'Baei')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (18, N'1', N'3', N'1017', N'المزرع العلوي', N'Al mazrae Al elwy')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (19, N'1', N'3', N'1018', N'المزرع الحدري', N'Al mazrae Al hadri')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (20, N'1', N'4', N'1019', N'الصاروج', N'Alsarooj')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (21, N'1', N'4', N'1020', N'الخوير', N'Al khawir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (22, N'1', N'4', N'1021', N'الغبرة الشمالية', N'North Alghubra')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (23, N'1', N'4', N'1022', N'محلة النجد', N'Mahallat Al najd')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (24, N'1', N'4', N'1023', N'العذيبة', N'Azaiba')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (25, N'1', N'4', N'1024', N'مسفاة الحدرية', N'Misfah Al Hadriyah ( Ash Sharqiyah)')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (26, N'1', N'4', N'1025', N'الفتح', N'Al fath')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (27, N'1', N'4', N'1026', N'قلهات', N'Qalhat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (28, N'1', N'4', N'1027', N'افلج', N'Aflaj')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (29, N'1', N'4', N'1028', N'غلاء', N'Ghala')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (30, N'1', N'4', N'1029', N'الانصب', N'Alnsab')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (31, N'1', N'4', N'1030', N'صنب', N'Sunub')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (32, N'1', N'4', N'1031', N'فلج الشام', N'Falaj Ash Sham')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (33, N'1', N'4', N'1032', N'العقبية', N'Al Aqbiyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (34, N'1', N'4', N'1033', N'حابل', N'Habil')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (35, N'1', N'2', N'1034', N'الموالح', N'Al mawalih')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (36, N'1', N'2', N'1035', N'حيل العوامر', N'Hyl Al awamir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (37, N'1', N'2', N'1036', N'جبل ال عمير', N'Jabal AL Eumayr')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (38, N'1', N'2', N'1037', N'العاديات', N'Al Adiat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (39, N'1', N'2', N'1038', N'قرحة المنذري', N'Qarhat Al mundhari')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (40, N'1', N'2', N'1039', N'حلة أل يوسف', N'Hilt Aal Yosef - Al Seeb Al Jadidah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (41, N'1', N'2', N'1040', N'قرحه البوسعيد', N'Qarhat Al buaseid')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (42, N'1', N'2', N'1041', N'الغلان', N'Al Glan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (43, N'1', N'2', N'1042', N'المعبيله الجنوبيه', N'South Al Amabilah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (44, N'1', N'2', N'1043', N'الخوض', N'Al Khawd')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (45, N'1', N'6', N'1044', N'قريات', N'Qurayyat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (46, N'1', N'6', N'1045', N'المزارع الظاهر', N'Al mazarie Al dhahir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (47, N'1', N'6', N'1046', N'المزارع الجزير', N'Al mazarie Al jazir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (48, N'1', N'6', N'1047', N'ضباب', N'Dibab')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (49, N'1', N'6', N'1048', N'وادي العربيين', N'Wadi Al Arbiyin')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (50, N'1', N'6', N'1049', N'حيل القواسم', N'Hayl Al Qawasim')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (51, N'1', N'6', N'1050', N'شاد', N'Shad')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (52, N'1', N'6', N'1051', N'سوقه', N'Sawqah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (53, N'1', N'6', N'1052', N'الكريب', N'Al karib')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (54, N'1', N'6', N'1053', N'محياء', N'Mihya')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (55, N'1', N'6', N'1054', N'المسفاه', N'Al Misfah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (56, N'1', N'6', N'1055', N'السواقم', N'As Sawaqim')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (57, N'1', N'6', N'1056', N'صياء', N'Siya')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (58, N'1', N'6', N'1057', N'عرقي', N'Arqi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (59, N'1', N'6', N'1058', N'السمير الغربية', N'As Sumayr')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (60, N'1', N'6', N'1059', N'السمير الشرقية', N'Al samir Al sharqia')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (61, N'1', N'6', N'1060', N'الفياض', N'Al Fayyad')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (62, N'1', N'6', N'1061', N'معول', N'Mawal')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (63, N'1', N'6', N'1062', N'السيفه', N'AL Sifah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (64, N'3', N'1', N'1063', N'خصب', N'Khasab')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (65, N'3', N'1', N'1064', N'بانه', N'Banah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (66, N'3', N'1', N'1065', N'نظيفي', N'Nidhayfi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (67, N'3', N'1', N'1066', N'قداء', N'Qada')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (68, N'3', N'1', N'1067', N'غب علي', N'Ghubb Ali')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (69, N'3', N'1', N'1068', N'البلد', N'Al Balad')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (70, N'3', N'1', N'1069', N'شم', N'Shamm')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (71, N'3', N'1', N'1070', N'سل اعلى', N'Sall Ala')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (72, N'3', N'2', N'1071', N'بخا', N'Bukha')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (73, N'3', N'2', N'1072', N'الجادى', N'Al Jadi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (74, N'3', N'2', N'1073', N'الحل الغربي', N'Hall Al Gharbiyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (75, N'3', N'2', N'1074', N'فضغاء', N'Fadgha')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (76, N'3', N'2', N'1075', N'لو', N'Law')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (77, N'3', N'2', N'1076', N'فوفله', N'Fawafalah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (78, N'3', N'2', N'1077', N'سل اصطام', N'Sal Astam')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (79, N'3', N'2', N'1078', N'تيبات', N'Tibat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (80, N'3', N'2', N'1079', N'القسيدات', N'Alqsadat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (81, N'3', N'2', N'1080', N'القصيده', N'Al qasidah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (82, N'3', N'2', N'1081', N'شحه', N'Shahh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (83, N'3', N'2', N'1082', N'راس  الوح', N'Ras Alwah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (84, N'3', N'3', N'1083', N'قسطينيه', N'Qistinih')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (85, N'3', N'3', N'1084', N'كرشا', N'Krsha')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (86, N'3', N'3', N'1085', N'حفة', N'Haffah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (87, N'3', N'3', N'1086', N'المقطع', N'Al muqattae')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (88, N'3', N'3', N'1087', N'سقطه', N'Saqatah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (89, N'3', N'3', N'1088', N'الشرجة الحلوة', N'Alsharijah Al hulwa')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (90, N'3', N'3', N'1089', N'دينى', N'Dini')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (91, N'3', N'3', N'1090', N'العقبة', N'Al Aqbah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (92, N'3', N'3', N'1091', N'عدس', N'Adas')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (93, N'3', N'3', N'1092', N'بندر القار', N'Bandar Al qar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (94, N'3', N'3', N'1093', N'الوطيه', N'Al Watyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (95, N'3', N'3', N'1094', N'راس المق', N'Ras Al Maqq')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (96, N'3', N'3', N'1095', N'المصلى', N'Al muslaa')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (97, N'3', N'3', N'1096', N'قرن بياض', N'Qarn Bayadh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (98, N'3', N'3', N'1097', N'المصيغرين', N'Ad Dayrhi / Al Musghrayn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (99, N'3', N'3', N'1098', N'بليت', N'Bilayt')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (100, N'3', N'3', N'1099', N'الحوره', N'Al huruh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (101, N'3', N'3', N'1100', N'سبطان', N'Subtan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (102, N'3', N'3', N'1101', N'الحدبه', N'Al hadabuh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (103, N'3', N'3', N'1102', N'العينين', N'Aleaynayn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (104, N'3', N'3', N'1103', N'العقيبة', N'Aleaqiba')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (105, N'3', N'3', N'1104', N'الظاهرة', N'Al dhahira')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (106, N'3', N'3', N'1105', N'قوعت', N'Quat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (107, N'3', N'3', N'1106', N'سلحب', N'Salhab')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (108, N'3', N'3', N'1107', N'الطفة', N'At Taffah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (109, N'3', N'3', N'1108', N'وعب عبده', N'Waab Abdah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (110, N'3', N'3', N'1109', N'بيبره', N'Bibarh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (111, N'3', N'3', N'1110', N'صدقة', N'Sidqah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (112, N'3', N'3', N'1111', N'الدفان', N'Al ddufan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (113, N'3', N'3', N'1112', N'الخطوى', N'Al khutwaa')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (114, N'3', N'3', N'1113', N'الصحصحة', N'Al sahsaha')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (115, N'3', N'3', N'1114', N'عقب  الصخام', N'Eaqib Al sakham')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (116, N'3', N'3', N'1115', N'القسده', N'Al qsaduh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (117, N'3', N'3', N'1116', N'الصبان', N'As Sibban')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (118, N'3', N'3', N'1117', N'سل حمدان', N'Sall Hamdan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (119, N'3', N'3', N'1118', N'الحاسر', N'Al hasir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (120, N'3', N'3', N'1119', N'المحجب', N'Al muhjab')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (121, N'3', N'3', N'1120', N'خرطوم البيح', N'Khartum Al Bih')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (122, N'3', N'3', N'1121', N'الاشكله', N'Al ashklh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (123, N'3', N'3', N'1122', N'الدرع', N'Al ddare')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (124, N'3', N'3', N'1123', N'المسيلف', N'Almcilf')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (125, N'3', N'3', N'1124', N'بين جوارين', N'Bayn Juwarayn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (126, N'3', N'3', N'1125', N'حفل', N'Hafil')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (127, N'3', N'3', N'1126', N'الحرامل', N'Al haramil')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (128, N'3', N'3', N'1127', N'هارك', N'Hark')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (129, N'3', N'3', N'1128', N'القعز', N'Al qaez')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (130, N'3', N'3', N'1129', N'القدقد', N'Al qadqad')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (131, N'3', N'3', N'1130', N'شرية الشوع', N'Shurriat Alsh shawe')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (132, N'2', N'1', N'1131', N'صحار', N'Sohar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (133, N'2', N'1', N'1132', N'الحجره', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (134, N'2', N'1', N'1133', N'الحظيره', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (135, N'2', N'1', N'1134', N'حلة الشوبية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (136, N'2', N'1', N'1135', N'حله كورون', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (137, N'2', N'1', N'1136', N'الزعفران', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (138, N'2', N'1', N'1137', N'العفيفة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (139, N'2', N'1', N'1138', N'الصنقر', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (140, N'2', N'1', N'1139', N'مجيس الشمالية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (141, N'2', N'1', N'1140', N'الخويرية', N'Al Khuwayriyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (142, N'2', N'1', N'1141', N'فلج القبائل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (143, N'2', N'1', N'1142', N'الملتقى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (144, N'2', N'1', N'1143', N'العوهي', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (145, N'2', N'1', N'1144', N'الغشبة', N'Al Ghushbah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (146, N'2', N'1', N'1145', N'الهمبار', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (147, N'2', N'1', N'1146', N'حلة الشيزاو', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (148, N'2', N'1', N'1147', N'حله الصباره', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (149, N'2', N'1', N'1148', N'عوتب', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (150, N'2', N'1', N'1149', N'مجز الكبري', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (151, N'2', N'1', N'1150', N'وادي حيبي', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (152, N'2', N'1', N'1151', N'شام', N'Sham')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (153, N'2', N'1', N'1152', N'ويت', N'Wayt')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (154, N'2', N'1', N'1153', N'الحلاحل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (155, N'2', N'1', N'1154', N'حيل مهنا', N'Hayl Mihanna')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (156, N'2', N'1', N'1155', N'الجعجاع', N'Al Jija')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (157, N'2', N'1', N'1156', N'الحويل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (158, N'2', N'1', N'1157', N'حيل قفصه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (159, N'2', N'1', N'1158', N'الخد', N'Al Khadd')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (160, N'2', N'1', N'1159', N'كتم', N'Katm')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (161, N'2', N'1', N'1160', N'جنح', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (162, N'2', N'1', N'1161', N'الخبيته', N'Al Khabtah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (163, N'2', N'1', N'1162', N'الخبات', N'Al Khabat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (164, N'2', N'1', N'1163', N'قفيص', N'Qufays')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (165, N'2', N'1', N'1164', N'العقير', N'Al Iqayr')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (166, N'2', N'1', N'1165', N'الحيول', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (167, N'2', N'1', N'1166', N'صهبان', N'Sahban')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (168, N'2', N'1', N'1167', N'السهيله', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (169, N'2', N'1', N'1168', N'الفرفار', N'Al Furfar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (170, N'2', N'1', N'1169', N'حنصى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (171, N'2', N'1', N'1170', N'حيل الغوانى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (172, N'2', N'1', N'1171', N'حيل العضاه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (173, N'2', N'1', N'1172', N'حيل المروح', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (174, N'2', N'1', N'1173', N'ولي', N'Willi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (175, N'2', N'1', N'1174', N'وادي العوينة', N'Wadi Al Uwaynah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (176, N'2', N'1', N'1175', N'الخان', N'Al Khan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (177, N'2', N'1', N'1176', N'الرسة', N'Ar Rissah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (178, N'2', N'1', N'1177', N'على', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (179, N'2', N'1', N'1178', N'العميره', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (180, N'2', N'1', N'1179', N'حيل نخل', N'Hayl An Nakhal')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (181, N'2', N'1', N'1180', N'حيل حامية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (182, N'2', N'1', N'1181', N'حيل المشاكم', N'Hayl Al Mashakim')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (183, N'2', N'1', N'1182', N'حيض', N'Hayd')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (184, N'2', N'1', N'1183', N'العبله', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (185, N'10', N'2', N'1184', N'الرستاق', N'Ar Rustaq')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (186, N'10', N'2', N'1185', N'الطيخه', N'At Tikhah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (187, N'10', N'2', N'1186', N'الوشيل', N'Al Wishayl')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (188, N'10', N'2', N'1187', N'جماء', N'Jamma')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (189, N'10', N'2', N'1188', N'الغيل', N'Al Ghayl')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (190, N'10', N'2', N'1189', N'معيدن', N'Muaydin')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (191, N'10', N'2', N'1190', N'المائده', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (192, N'10', N'2', N'1191', N'المريرات', N'Al Murayrat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (193, N'10', N'2', N'1192', N'معول', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (194, N'10', N'12', N'1193', N'الشبيكة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (195, N'10', N'2', N'1194', N'الحزم', N'Al Hazm')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (196, N'10', N'2', N'1195', N'فلج الوسطى', N'Falaj Al Wusta')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (197, N'10', N'2', N'1196', N'دارس', N'Daris')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (198, N'10', N'2', N'1197', N'الحوقين', N'Al Hawqayn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (199, N'10', N'2', N'1198', N'فلج السعيدي', N'Falaj As Siaydi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (200, N'10', N'2', N'1199', N'طوي البدو', N'Tawi Al Badu')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (201, N'10', N'2', N'1200', N'حويل المجاز', N'Huwayl Al Mijaz')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (202, N'10', N'2', N'1201', N'الغروه', N'Al Gharwah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (203, N'10', N'2', N'1202', N'حيل الصلح', N'Hayl As Sulh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (204, N'10', N'2', N'1203', N'القرية', N'Al Qaryah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (205, N'10', N'2', N'1204', N'سيع', N'Saya')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (206, N'10', N'2', N'1205', N'السودي', N'As Sudi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (207, N'10', N'2', N'1206', N'حيل الغافة', N'Hayl Al Ghafah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (208, N'10', N'2', N'1207', N'ديسلى', N'Disli')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (209, N'10', N'2', N'1208', N'الحاجر', N'Al Hajir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (210, N'10', N'2', N'1209', N'الدهاس', N'Ad Dahhas')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (211, N'10', N'2', N'1210', N'المرجي', N'Al Marji')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (212, N'10', N'2', N'1211', N'راب', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (213, N'10', N'2', N'1212', N'المعني', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (214, N'10', N'2', N'1213', N'الرم', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (215, N'10', N'2', N'1214', N'القرطى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (216, N'10', N'2', N'1215', N'الرجلة', N'Ar Rajlah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (217, N'10', N'2', N'1216', N'الطيب', N'At Tayyib')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (218, N'10', N'2', N'1217', N'الظاهر', N'Adh Dhahir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (219, N'10', N'2', N'1218', N'الشريعه', N'Ash Shiriah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (220, N'10', N'2', N'1219', N'الخرصان', N'Al Kharsan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (221, N'10', N'2', N'1220', N'المنازف', N'Al Manazif')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (222, N'10', N'2', N'1221', N'زوله', N'Zawlah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (223, N'10', N'2', N'1222', N'سني', N'Sini')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (224, N'10', N'2', N'1223', N'المقحم', N'Al Maqham')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (225, N'10', N'2', N'1224', N'ضبعة', N'Dabah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (226, N'10', N'2', N'1225', N'الطباقه', N'At Tabaqah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (227, N'10', N'2', N'1226', N'الطويان', N'At Tuwyan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (228, N'10', N'2', N'1227', N'فسح', N'Fasah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (229, N'10', N'2', N'1228', N'المزرع', N'Al Mazra')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (230, N'10', N'2', N'1229', N'الصير', N'As Sayr')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (231, N'10', N'2', N'1230', N'البشوق', N'Al Bashuq')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (232, N'10', N'2', N'1231', N'الودايم', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (233, N'10', N'2', N'1232', N'عين عمق', N'Ayn Umq')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (234, N'10', N'2', N'1233', N'غرامه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (235, N'10', N'2', N'1234', N'وجمة', N'Wijmah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (236, N'10', N'2', N'1235', N'الصفى', N'As Safa')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (237, N'10', N'2', N'1236', N'عضدة', N'Addah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (238, N'10', N'2', N'1237', N'الجفر', N'Al Jifar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (239, N'10', N'2', N'1238', N'حيل مديد', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (240, N'10', N'2', N'1239', N'المنزف', N'Al Manzaf')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (241, N'10', N'2', N'1240', N'الطلحه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (242, N'10', N'2', N'1241', N'لخطيمات', N'Likhtaymat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (243, N'10', N'2', N'1242', N'بلد سيت', N'Balad Sayt')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (244, N'10', N'2', N'1243', N'العير', N'Al Ir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (245, N'2', N'3', N'1244', N'شناص', N'Shinas')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (246, N'2', N'3', N'1245', N'الفرفارة', N'Al Furfarah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (247, N'2', N'3', N'1246', N'طريف  حجي', N'Turayf Hajji')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (248, N'2', N'3', N'1247', N'سور بنى حماد', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (249, N'2', N'3', N'1248', N'سور العبرى الشمالية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (250, N'2', N'3', N'1249', N'سور المزاريع', N'Sur Al Mazari')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (251, N'2', N'3', N'1250', N'ام العنة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (252, N'2', N'3', N'1251', N'الدوانيج', N'Ad Dawanij')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (253, N'2', N'3', N'1252', N'خضراوين', N'Khadrawayn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (254, N'2', N'3', N'1253', N'مرير الدرامكة', N'Mirayr Ad Daramikah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (255, N'2', N'3', N'1254', N'ملاحه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (256, N'2', N'3', N'1255', N'اسود', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (257, N'2', N'3', N'1256', N'عجيب', N'Ajib')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (258, N'2', N'3', N'1257', N'وادى فيض', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (259, N'2', N'3', N'1258', N'الرسة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (260, N'2', N'4', N'1259', N'الجعشمي', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (261, N'2', N'4', N'1260', N'الحد', N'Al Hadd')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (262, N'2', N'4', N'1261', N'غضفان', N'Ghadfan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (263, N'2', N'4', N'1262', N'الزاهية', N'Az Zahyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (264, N'2', N'4', N'1263', N'نبر', N'Nabr')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (265, N'2', N'4', N'1264', N'حله البحر', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (266, N'2', N'4', N'1265', N'حله سالم', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (267, N'2', N'4', N'1266', N'البيضاء', N'Al Bayda')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (268, N'2', N'4', N'1267', N'الزهيمي', N'Az Zihaymi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (269, N'2', N'4', N'1268', N'بات', N'Bat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (270, N'2', N'4', N'1269', N'شية', N'Shiyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (271, N'2', N'5', N'1270', N'سور  الشيادي', N'Sur Ash Shiyadi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (272, N'2', N'5', N'1271', N'الخشدة', N'Al Khashdah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (273, N'2', N'5', N'1272', N'خور الحمام', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (274, N'2', N'5', N'1273', N'مخيليف', N'Mikhaylif')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (275, N'2', N'5', N'1274', N'ديل ال بريك', N'Dil Al Burayk')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (276, N'2', N'5', N'1275', N'حفيت', N'Hafit')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (277, N'2', N'5', N'1276', N'حله البرج', N'Hillat Al Burj')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (278, N'2', N'5', N'1277', N'خور الملح', N'Khawr Al Milh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (279, N'2', N'5', N'1278', N'الروضة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (280, N'2', N'5', N'1279', N'المهاب', N'Al Mahab')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (281, N'2', N'5', N'1280', N'العقير', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (282, N'2', N'5', N'1281', N'حيلشى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (283, N'2', N'5', N'1282', N'لسلات', N'Laslat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (284, N'2', N'5', N'1283', N'الغبرة', N'Al Ghubrah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (285, N'2', N'5', N'1284', N'الفرفار', N'Al Furfar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (286, N'2', N'5', N'1285', N'دقال', N'Diqal')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (287, N'2', N'5', N'1286', N'مطيد', N'Mutayd')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (288, N'2', N'5', N'1287', N'المسن', N'Al Masan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (289, N'2', N'5', N'1288', N'صحيدة', N'Sihaydah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (290, N'2', N'5', N'1289', N'العين', N'Al Ayn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (291, N'2', N'5', N'1290', N'قصى', N'Qissi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (292, N'2', N'6', N'1291', N'الخابورة', N'Al Khaburah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (293, N'2', N'6', N'1292', N'قصبية بني سعيد', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (294, N'2', N'6', N'1293', N'قصبية الحواسنة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (295, N'2', N'6', N'1294', N'قصبية الزعاب', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (296, N'2', N'6', N'1295', N'الرديده', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (297, N'2', N'6', N'1296', N'حلة الخور', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (298, N'2', N'6', N'1297', N'حلة الحصن', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (299, N'2', N'6', N'1298', N'خور الهند', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (300, N'2', N'6', N'1299', N'عباسة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (301, N'2', N'6', N'1300', N'سور الدواحنة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (302, N'2', N'6', N'1301', N'الميحة', N'Al Mayhah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (303, N'2', N'6', N'1302', N'صنعاء بني غافر', N'Sana Bani Ghafir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (304, N'2', N'6', N'1303', N'فلج بني ربيعة', N'Falaj Bani Rabiah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (305, N'2', N'6', N'1304', N'خزام', N'Khuzam')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (306, N'2', N'6', N'1305', N'الفرضة', N'Al Furdah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (307, N'2', N'6', N'1306', N'القويرة', N'Al Quwayrah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (308, N'2', N'6', N'1307', N'حليحل', N'Hilayhil')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (309, N'2', N'6', N'1308', N'غرباء', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (310, N'2', N'6', N'1309', N'البصيرى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (311, N'2', N'6', N'1310', N'القصف', N'Al Qasf')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (312, N'2', N'6', N'1311', N'بديعة', N'Bidayah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (313, N'2', N'6', N'1312', N'مطيد', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (314, N'2', N'6', N'1313', N'شخبوط', N'Shakhbut')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (315, N'2', N'6', N'1314', N'مجزي', N'Majzi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (316, N'2', N'6', N'1315', N'الحريم', N'Al Harim')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (317, N'2', N'6', N'1316', N'حجيجة', N'Hijayjah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (318, N'2', N'6', N'1317', N'حيل بنى كثير', N'Hayl Bani Kathir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (319, N'2', N'6', N'1318', N'الهجاري', N'Al Hijari')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (320, N'2', N'6', N'1319', N'الظيهر', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (321, N'2', N'6', N'1320', N'حيل الرسة', N'Hayl Ar Rissah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (322, N'2', N'6', N'1321', N'جنح', N'Janah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (323, N'2', N'6', N'1322', N'البكس', N'Al Baks')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (324, N'2', N'6', N'1323', N'ماوي', N'Mawi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (325, N'2', N'6', N'1324', N'الخضراء', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (326, N'2', N'7', N'1325', N'الحارة القديمة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (327, N'2', N'7', N'1326', N'القرحه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (328, N'2', N'7', N'1327', N'الرده', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (329, N'2', N'7', N'1328', N'جزماء', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (330, N'2', N'7', N'1329', N'ابو رغوه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (331, N'2', N'7', N'1330', N'الجود', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (332, N'2', N'7', N'1331', N'الصوالح', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (333, N'2', N'7', N'1332', N'سور هيان', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (334, N'2', N'7', N'1333', N'الخضراء - السوق', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (335, N'2', N'7', N'1334', N'قرحه بطى من الخضراء', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (336, N'2', N'7', N'1335', N'العويدات', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (337, N'2', N'7', N'1336', N'البوارح', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (338, N'2', N'7', N'1337', N'قارح بنى خروص', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (339, N'2', N'7', N'1338', N'غليل الهنادين', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (340, N'2', N'7', N'1339', N'الحجيره', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (341, N'2', N'7', N'1340', N'الهندية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (342, N'2', N'7', N'1341', N'قلعة المناوره', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (343, N'2', N'7', N'1342', N'الافراض', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (344, N'2', N'7', N'1343', N'حضيب الخدام', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (345, N'2', N'7', N'1344', N'خبة النوافل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (346, N'2', N'7', N'1345', N'خبة النعامين', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (347, N'2', N'7', N'1346', N'المنفش', N'Al Manfash')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (348, N'2', N'7', N'1347', N'الغريفة', N'Al Ghurayfah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (349, N'2', N'7', N'1348', N'الشاطر', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (350, N'2', N'7', N'1349', N'بطحاء الحرف', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (351, N'2', N'7', N'1350', N'بطحاء العود', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (352, N'2', N'7', N'1351', N'سور ال هلال', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (353, N'2', N'7', N'1352', N'وسطى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (354, N'2', N'7', N'1353', N'العريق', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (355, N'2', N'7', N'1354', N'العابية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (356, N'2', N'7', N'1355', N'المعتمر', N'Al Mutamar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (357, N'2', N'7', N'1356', N'الحضيب', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (358, N'2', N'7', N'1357', N'البداية', N'Al Bidayah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (359, N'2', N'7', N'1358', N'المبرح', N'Al Mabrah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (360, N'2', N'7', N'1359', N'الحلوة', N'Al Hilwah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (361, N'2', N'7', N'1360', N'الودية العالية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (362, N'2', N'7', N'1361', N'بدت', N'Bidit')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (363, N'2', N'7', N'1362', N'الشريشة. النواخذ', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (364, N'2', N'7', N'1363', N'الشريشة الشرقية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (365, N'2', N'7', N'1364', N'البدعة الشرقية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (366, N'2', N'7', N'1365', N'خبة المعاول', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (367, N'10', N'8', N'1366', N'الميسين', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (368, N'10', N'8', N'1367', N'الغبره', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (369, N'10', N'8', N'1368', N'المويبيين', N'Al Muwaybin')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (370, N'10', N'8', N'1369', N'الحيل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (371, N'10', N'8', N'1370', N'امطى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (372, N'10', N'8', N'1371', N'وكان', N'Wukan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (373, N'10', N'8', N'1372', N'الطو', N'At Taww')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (374, N'10', N'8', N'1373', N'بوة', N'Buwah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (375, N'10', N'8', N'1374', N'الواسط', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (376, N'10', N'8', N'1375', N'حبرا', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (377, N'10', N'8', N'1376', N'افي', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (378, N'10', N'8', N'1377', N'الطويه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (379, N'10', N'10', N'1378', N'العوابي', N'Al Awabi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (380, N'10', N'10', N'1379', N'ستال', N'Sital')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (381, N'10', N'10', N'1380', N'شوة', N'Shuh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (382, N'10', N'10', N'1381', N'الهجار', N'Al Hijar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (383, N'10', N'10', N'1382', N'مسفاة الشريقيين', N'Misfat Ash Shirayqiyin')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (384, N'10', N'10', N'1383', N'الهودنية', N'Al Hawdniyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (385, N'10', N'10', N'1384', N'المحصنة', N'Al Mahsanah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (386, N'10', N'10', N'1385', N'العلياء', N'Al Alya')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (387, N'10', N'10', N'1386', N'الهجير', N'Al Hijayr')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (388, N'10', N'10', N'1387', N'حلحل', N'Halhal')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (389, N'10', N'10', N'1388', N'فلج بنى خزير', N'Falaj Bani Khizayr')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (390, N'10', N'11', N'1389', N'المصنعة', N'Al Musanaah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (391, N'10', N'11', N'1390', N'الطريف', N'At Turayf')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (392, N'10', N'11', N'1391', N'الملدة', N'Al Muladdah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (393, N'10', N'11', N'1392', N'ودام الغاف', N'Wudam Al Ghaf')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (394, N'10', N'11', N'1393', N'ودام الساحل', N'Wudam As Sahil')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (395, N'10', N'11', N'1394', N'العويد', N'Al Uwayd')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (396, N'10', N'11', N'1395', N'الشرس', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (397, N'10', N'11', N'1396', N'القريم', N'Al Quraym')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (398, N'10', N'11', N'1397', N'قري', N'Qari')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (399, N'10', N'11', N'1398', N'قرحه الجرجور', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (400, N'10', N'11', N'1399', N'حله ال بريك', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (401, N'10', N'11', N'1400', N'شعيبة', N'Shuaybah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (402, N'10', N'11', N'1401', N'برج ال خميس', N'Burj Al Khamis')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (403, N'10', N'11', N'1402', N'محارة', N'Maharah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (404, N'10', N'11', N'1403', N'خور الملح', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (405, N'10', N'11', N'1404', N'بوعبالي', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (406, N'10', N'12', N'1405', N'محلة الجورجيح', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (407, N'10', N'12', N'1406', N'محلة السور', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (408, N'10', N'12', N'1407', N'محلة الفوارس', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (409, N'10', N'12', N'1408', N'محلة العجم', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (410, N'10', N'12', N'1409', N'محلة الشمامير', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (411, N'10', N'12', N'1410', N'المراغ', N'Al Maragh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (412, N'10', N'12', N'1411', N'الصومحان', N'As Sawmhan')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (413, N'10', N'12', N'1412', N'المذرية', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (414, N'10', N'12', N'1413', N'حرادى الساحل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (415, N'10', N'12', N'1414', N'وادى امون', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (416, N'10', N'12', N'1415', N'حي عاصم', N'Hayy Asim')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (417, N'10', N'12', N'1416', N'الرميس', N'Ar Rumays')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (418, N'10', N'12', N'1417', N'قرحة البلوش', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (419, N'10', N'12', N'1418', N'الثرامد', N'Ath Tharamid')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (420, N'10', N'12', N'1419', N'النعمان', N'An Naman')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (421, N'10', N'12', N'1420', N'الوهرة', N'Al Wahrah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (422, N'10', N'12', N'1421', N'حفرى الجنوب', N'Hafri Al Janubiyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (423, N'10', N'12', N'1422', N'السقسوق', N'As Saqsuq')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (424, N'10', N'12', N'1423', N'سلوى', N'Salwa')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (425, N'10', N'12', N'1424', N'الحضيب', N'Al Hadib')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (426, N'10', N'12', N'1425', N'سوادى الجبل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (427, N'5', N'1', N'1426', N'نزوى', N'Nizwa')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (428, N'5', N'1', N'1427', N'قيوت', N'Qiyut')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (429, N'5', N'1', N'1428', N'فرق', N'Farq')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (430, N'5', N'1', N'1429', N'الجل', N'Al Jall')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (431, N'5', N'1', N'1430', N'الفتحى', N'Al Fathi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (432, N'5', N'1', N'1431', N'المضيبى', N'Al Mudaybi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (433, N'5', N'1', N'1432', N'الواسط', N'Al Wasit')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (434, N'5', N'1', N'1433', N'قاشع', N'Qashae')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (435, N'5', N'1', N'1434', N'معبت', N'Mabat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (436, N'5', N'1', N'1435', N'بنى حبيب', N'Bani Habib')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (437, N'5', N'1', N'1436', N'سيق', N'Sayq')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (438, N'5', N'1', N'1437', N'الشريجة', N'Ash Shirayjah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (439, N'5', N'1', N'1438', N'العين', N'Al Ayn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (440, N'5', N'1', N'1439', N'العباية', N'Al aibayh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (441, N'5', N'1', N'1440', N'المناخر', N'Al Manakhir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (442, N'5', N'1', N'1441', N'طوى سعده', N'Tawi Sadah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (443, N'5', N'1', N'1442', N'المعيدن', N'Almaidn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (444, N'5', N'2', N'1443', N'علاية سمائل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (445, N'5', N'2', N'1444', N'سفالة سمائل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (446, N'5', N'2', N'1445', N'الهوب', N'Al Hawb')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (447, N'5', N'2', N'1446', N'الجيلة', N'Al Jaylah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (448, N'5', N'2', N'1447', N'الدن', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (449, N'5', N'2', N'1448', N'خوبار المجالبة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (450, N'5', N'2', N'1449', N'العوينه', N'Al Uwaynah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (451, N'5', N'2', N'1450', N'هصاص', N'Hassas')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (452, N'5', N'2', N'1451', N'لزغ', N'Lizugh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (453, N'5', N'2', N'1452', N'وادى العجام', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (454, N'5', N'2', N'1453', N'الصميه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (455, N'5', N'2', N'1454', N'الدسر', N'Ad Dasur')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (456, N'5', N'2', N'1455', N'نداب', N'Nidab')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (457, N'5', N'2', N'1456', N'الطويه', N'At Tuwayyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (458, N'5', N'2', N'1457', N'وادى سقط', N'Wadi Suqut')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (459, N'5', N'2', N'1458', N'منال', N'Manal')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (460, N'5', N'2', N'1459', N'وصاد', N'Wusad')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (461, N'5', N'2', N'1460', N'الجناة', N'Al Janah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (462, N'5', N'2', N'1461', N'المحل', N'Al Mahal')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (463, N'5', N'2', N'1462', N'العافية', N'Al Afyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (464, N'5', N'2', N'1463', N'فلج المراغه', N'Falaj Al Maraghah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (465, N'5', N'2', N'1464', N' وادي محرم', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (466, N'5', N'2', N'1465', N'بورى', N'Bawri')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (467, N'5', N'2', N'1466', N'الحله', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (468, N'5', N'3', N'1467', N'بلاد سيت', N'Bilad Sayt')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (469, N'5', N'3', N'1468', N'الغافات', N'Al Ghafat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (470, N'5', N'3', N'1469', N'دن ومعول', N'Dann')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (471, N'5', N'3', N'1470', N'غمر', N'Ghamar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (472, N'5', N'3', N'1471', N'سيفم', N'Sayfam Wa Al Uqayr')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (473, N'5', N'3', N'1472', N'جبرين', N'Jabrin')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (474, N'5', N'3', N'1473', N'المدرى', N'Al Madri')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (475, N'5', N'3', N'1474', N'فل', N'Fall')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (476, N'5', N'3', N'1475', N'المعمور', N'Al Mamur')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (477, N'5', N'3', N'1476', N'الحبى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (478, N'5', N'3', N'1477', N'خميله', N'Khumaylah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (479, N'5', N'3', N'1478', N'قصيبه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (480, N'5', N'3', N'1479', N'الشيكه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (481, N'5', N'3', N'1480', N'عويفية', N'Uwayfiyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (482, N'5', N'3', N'1481', N'الطويين', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (483, N'5', N'4', N'1482', N'ادم', N'Adam')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (484, N'5', N'4', N'1483', N'الصامتى', N'As Samti')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (485, N'5', N'4', N'1484', N'الراكى', N'Ar Raki')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (486, N'5', N'4', N'1485', N'موية الراكى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (487, N'5', N'4', N'1486', N'الغابه', N'Al Ghabah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (488, N'5', N'4', N'1487', N'عفار', N'Afar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (489, N'5', N'4', N'1488', N'جدة الحراسيس', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (490, N'5', N'4', N'1489', N'العجائز', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (491, N'5', N'4', N'1490', N'الغبرة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (492, N'5', N'4', N'1491', N'غارم', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (493, N'5', N'4', N'1492', N'صاى الدقم', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (494, N'5', N'4', N'1493', N'المزيلات', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (495, N'5', N'4', N'1494', N'حليبة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (496, N'5', N'5', N'1495', N'الحمراء', N'Al Hamra')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (497, N'5', N'5', N'1496', N'مسفاه العبريين', N'Misfat Al Abriyin')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (498, N'5', N'5', N'1497', N'ذات خيل', N'Dhat Khayl')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (499, N'5', N'5', N'1498', N'غول', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (500, N'5', N'5', N'1499', N'النخر', N'An Nakhar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (501, N'5', N'5', N'1500', N'الحاجر', N'Al Hajir')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (502, N'5', N'5', N'1501', N'حرمت', N'Hirimt')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (503, N'5', N'5', N'1502', N'الصفنى', N'Safni')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (504, N'5', N'5', N'1503', N'مندع', N'Minda')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (505, N'5', N'5', N'1504', N'الساب', N'As Sab')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (506, N'5', N'5', N'1505', N'مصيره', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (507, N'5', N'5', N'1506', N'المنيبك', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (508, N'5', N'6', N'1507', N'منح', N'Manah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (509, N'5', N'6', N'1508', N'الفيقين', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (510, N'5', N'6', N'1509', N'المعرى', N'Al Mara')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (511, N'5', N'6', N'1510', N'عز', N'Izz')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (512, N'5', N'6', N'1511', N'المحيول', N'Al Mahyul')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (513, N'5', N'7', N'1512', N'اليمن', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (514, N'5', N'7', N'1513', N'حارة الرحى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (515, N'5', N'7', N'1514', N'قاروت السافل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (516, N'5', N'7', N'1515', N'مغيوث', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (517, N'5', N'7', N'1516', N'سوق قديم', N'Suq Qadim')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (518, N'5', N'7', N'1517', N'شافع', N'Shafi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (519, N'5', N'7', N'1518', N'العاقل', N'Al Aqil')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (520, N'5', N'7', N'1519', N'السليمى', N'As Silaymi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (521, N'5', N'7', N'1520', N'الخرماء', N'Al Kharma')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (522, N'5', N'7', N'1521', N'سيماء السفاله', N'Sayma Al Janubiyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (523, N'5', N'7', N'1522', N'وادى الودى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (524, N'5', N'7', N'1523', N'رسيس', N'Ar Risays')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (525, N'5', N'7', N'1524', N'الطيبى', N'At Tayybi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (526, N'5', N'7', N'1525', N'العلم', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (527, N'5', N'8', N'1526', N'الخوبى', N'Al Khubi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (528, N'5', N'8', N'1527', N'قرطاع', N'Al Qurta')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (529, N'5', N'8', N'1528', N'مزرع  بنت سعد', N'Mazraat Bint Saad')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (530, N'5', N'8', N'1529', N'المغره', N'Al Maghrah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (531, N'5', N'8', N'1530', N'العمقات', N'Al Amqat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (532, N'5', N'8', N'1531', N'فنجاء', N'Fanja')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (533, N'5', N'8', N'1532', N'الرسة', N'Ar Rissah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (534, N'5', N'8', N'1533', N'الجفنين', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (535, N'5', N'8', N'1534', N'الفرفاره', N'Al Furfarah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (536, N'5', N'8', N'1535', N'الملتقى الحدرية', N'Al Miltqa  Al Hadriyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (537, N'5', N'8', N'1536', N'الملتقى العلوية', N'Al Miltqa Al Alwiyah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (538, N'5', N'8', N'1537', N'جردمانه', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (539, N'5', N'8', N'1538', N'الحسن', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (540, N'5', N'8', N'1539', N'المزيرعات الثلاثة', N'Al Muzayrat Ath Thalathah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (541, N'5', N'8', N'1540', N'الجيلة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (542, N'5', N'8', N'1541', N'منيثيره', N'Al Minaythirah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (543, N'5', N'8', N'1542', N'نقصى', N'Nuqsi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (544, N'5', N'8', N'1543', N'البديعة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (545, N'5', N'8', N'1544', N'غياضة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (546, N'5', N'8', N'1545', N'مزرع الحويشى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (547, N'4', N'2', N'1546', N'عبرى', N'Ibri')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (548, N'4', N'2', N'1547', N'هجار', N'Hijar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (549, N'4', N'2', N'1548', N'الاخضر', N'Al Akhdar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (550, N'4', N'2', N'1549', N'عسيبق', N'Usaybuq')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (551, N'4', N'2', N'1550', N'الجفرة', N'Al Jifrah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (552, N'4', N'2', N'1551', N'الصبيخى', N'As Subaykhi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (553, N'4', N'2', N'1552', N'المازم', N'Al Mazim')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (554, N'4', N'2', N'1553', N'مشارب', N'Masharib')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (555, N'4', N'2', N'1554', N'القائدى', N'Al Qaidi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (556, N'4', N'2', N'1555', N'ابو سيلة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (557, N'4', N'2', N'1556', N'الخطم', N'Al Khatum')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (558, N'4', N'2', N'1557', N'جفيجف', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (559, N'4', N'2', N'1558', N'قرا', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (560, N'4', N'2', N'1559', N'تنعم', N'Tanam')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (561, N'4', N'2', N'1560', N'العرف', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (562, N'4', N'2', N'1561', N'فيحة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (563, N'4', N'2', N'1562', N'فهود', N'Fuhud')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (564, N'4', N'2', N'1563', N'جاوى', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (565, N'4', N'2', N'1564', N'الصفاء', N'As Safa Wa Al Manarah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (566, N'4', N'2', N'1565', N'الوهرة (غرب)', N'Al Wahrah (West)')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (567, N'4', N'2', N'1566', N'بيل', N'Bayl')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (568, N'4', N'2', N'1567', N'الهجر', N'Al Hajar')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (569, N'4', N'2', N'1568', N'حارة الحواتم', N'Harat Al Hawatim')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (570, N'4', N'2', N'1569', N'العين', N'Al Ayn')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (571, N'4', N'2', N'1570', N'حيل بنى صبح', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (572, N'4', N'2', N'1571', N'الحيل', N'Al Hayl')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (573, N'4', N'2', N'1572', N'الميس', N'Al Mays')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (574, N'4', N'2', N'1573', N'الدن', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (575, N'4', N'2', N'1574', N'الركزة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (576, N'4', N'2', N'1575', N'نادان', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (577, N'4', N'2', N'1576', N'الخابوره', N'Al Khaburah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (578, N'4', N'2', N'1577', N'العبله', N'Al Ablah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (579, N'4', N'2', N'1578', N'عملا', N'Amla')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (580, N'4', N'2', N'1579', N'كباره', N'Kubarah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (581, N'4', N'2', N'1580', N'للقيع', N'Liqayya')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (582, N'4', N'2', N'1581', N'السليف', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (583, N'4', N'2', N'1582', N'خدل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (584, N'4', N'2', N'1583', N'مجزى', N'Majzi')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (585, N'4', N'2', N'1584', N'وادى اللثلى', N'Wadi Al Lithli')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (586, N'4', N'2', N'1585', N'الظاهرة', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (587, N'4', N'2', N'1586', N'هجيرمات', N'Hijayrmat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (588, N'4', N'2', N'1587', N'الهيال', N'Al Hayyal')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (589, N'4', N'2', N'1588', N'الوشل', N'Al Wushal')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (590, N'4', N'2', N'1589', N'كهنات', N'Kahnat')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (591, N'4', N'2', N'1590', N'السدفة', N'As Sidfah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (592, N'4', N'2', N'1591', N'الرحبة', N'Ar Ruhbah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (593, N'4', N'2', N'1592', N'بيح', N'Bayh')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (594, N'4', N'2', N'1593', N'النجيد', N'An Nijayd')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (595, N'4', N'2', N'1594', N'الرسة', N'Ar Rissah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (596, N'4', N'2', N'1595', N'مقر', N'Muqur')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (597, N'4', N'2', N'1596', N'مسكن', N'Miskin')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (598, N'4', N'2', N'1597', N'العيون', N'Uyun')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (599, N'4', N'2', N'1598', N'وادى القبيل', N'Wadi Qabil')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (600, N'4', N'2', N'1599', N'العمقه', N'Al Umqah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (601, N'4', N'2', N'1600', N'المصيره', N'Masirah')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (602, N'4', N'2', N'1601', N'شميت', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (603, N'4', N'2', N'1602', N'حيل', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (604, N'4', N'2', N'1603', N'فلج العالى', N'Falaj Al Ali')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (605, N'4', N'2', N'1604', N'حيل الخدام', N'Hayl Khiddam')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (606, N'4', N'2', N'1605', N'الفالق', N'NULL')
GO
INSERT [dbo].[VILLAGE_MASTER] ([ID], [AREA_CODE], [WILAYAT_CODE], [VILLAGE_CODE], [VILLAGE_DESC_ARB], [VILLAGE_DESC_ENG]) VALUES (607, N'4', N'2', N'1606', N'حيل بشير', N'NULL')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (105, N'1', N'1', N'1', N'مسقط', N'Muscat')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (103, N'1', N'1', N'2', N'السيب', N'Al-Seeb')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (101, N'1', N'1', N'3', N'مــطــرح', N'Muttrah')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (102, N'1', N'1', N'4', N'بــوشــر', N'Bousher')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (104, N'1', N'1', N'5', N'العامرات', N'Al-hajer')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (106, N'1', N'1', N'6', N'قريات', N'Quriyat')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (201, N'2', N'2', N'7', N'صــحـــار', N'Sohar')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (202, N'10', N'2', N'8', N'الرستاق', N'Al-Rustaq')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (203, N'2', N'2', N'9', N'شناص', N'Shinas')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (204, N'2', N'2', N'10', N'لـــوى', N'Liwa')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (205, N'2', N'2', N'11', N'صحم', N'Saham')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (206, N'2', N'2', N'12', N'الــخــابـورة', N'Al-Khabura')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (207, N'2', N'2', N'13', N'الـسـويـــق', N'Al-Suwaiq')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (208, N'10', N'2', N'14', N'نـــخــل', N'Nakhal')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (209, N'10', N'2', N'15', N'وادي المـعـاول', N'Wadi Maawil')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (210, N'10', N'2', N'16', N'الـعــوابـي', N'Al-Awabi')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (211, N'10', N'2', N'17', N'المصنعة', N'Al-Musanna')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (212, N'10', N'2', N'18', N'بـــركـــاء', N'Barka')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (301, N'3', N'3', N'19', N'خصب', N'Khasab')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (302, N'3', N'3', N'20', N'بــخــــا', N'Bukha')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (304, N'3', N'3', N'21', N'مدحا', N'Madha')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (402, N'4', N'4', N'22', N'عــبــري', N'Ibri')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (404, N'4', N'4', N'23', N'يـنــقــل', N'Yanqul')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (501, N'5', N'5', N'24', N'نــــزوى', N'Nizwa')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (502, N'5', N'5', N'25', N'سمائل', N'Sumail')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (503, N'5', N'5', N'26', N'بــهـــلاء', N'Bahla')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (505, N'5', N'5', N'27', N'الحمراء', N'Al-Hamra')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (506, N'5', N'5', N'28', N'منح', N'Manah')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (508, N'5', N'5', N'29', N'بدبد', N'Bid Bid')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (601, N'6', N'6', N'30', N'صور', N'Sur')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (602, N'11', N'6', N'31', N'ابراء', N'Ibra')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (604, N'11', N'6', N'32', N'القابل', N'Al-Qabil')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (605, N'11', N'6', N'33', N'المضيبي', N'Al-Mudhaibi')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (606, N'11', N'6', N'34', N'دمـاء والطائييـن', N'Dima And Tayin')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (607, N'6', N'6', N'35', N'الكـامل والـوافـي', N'Al-Kamil And Al-Wafi')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (608, N'6', N'6', N'36', N'جـعـلان بنى بـوعـلى', N'Jalan Bani Bu Ali')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (609, N'6', N'6', N'37', N'جعـلان بنى بوحسـن', N'Jalan Bani Bu Hassan')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (610, N'11', N'6', N'38', N'وادى بنى خـالـد', N'Wadi Bani Khalid')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (611, N'6', N'6', N'39', N'مصيرة', N'Masirah')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (701, N'7', N'7', N'40', N'هـيـمــاء', N'Haima')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (702, N'7', N'7', N'41', N'مـحــوت', N'Mahoot')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (703, N'7', N'7', N'42', N'الـدقــم', N'Al-Duqm')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (704, N'7', N'7', N'43', N'الجـازر', N'Al_jazer')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (801, N'8', N'8', N'44', N'صــلالـــة', N'Salalah')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (802, N'8', N'8', N'45', N'ثـمـريــت', N'Thumarait')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (803, N'8', N'8', N'46', N'طــاقـــة', N'Taqah')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (804, N'8', N'8', N'47', N'مرباط', N'Mirbat')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (805, N'8', N'8', N'48', N'ســـــدح', N'Sudh')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (806, N'8', N'8', N'49', N'رخــيــوت', N'Rakhyut')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (807, N'8', N'8', N'50', N'ضـلـكــوت', N'Dalqut')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (808, N'8', N'8', N'51', N'مــقــشــن', N'Muqshin')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (809, N'8', N'8', N'52', N'شليم وجزر الحلانيات', N' Shalimealhallaniyahislnd')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (303, N'3', N'3', N'53', N'دبـــــا البـيـعـة', N'Daba Al-Biya')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (405, N'4', N'4', N'54', N'ضنك', N'Dhank')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (504, N'5', N'5', N'55', N'ادم', N'Adam')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (507, N'5', N'5', N'56', N'ازكي', N'Izki')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (603, N'11', N'6', N'57', N'بـــديــة', N'Bidiya')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (810, N'8', N'8', N'58', N'المزيونة', N'AL-MAZYONA')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (901, N'9', N'9', N'59', N'الـبـريـمـي', N'Al-Buraimi')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (902, N'9', N'9', N'60', N'محضة', N'Mahadha')
GO
INSERT [dbo].[WILAYAT_MASTER] ([ID], [AREA_CODE], [AREA_MASTER_ID], [WILAYAT_CODE], [WILAYAT_DESC_ARB], [WILAYAT_DESC_ENG]) VALUES (903, N'9', N'9', N'61', N'السنينة', N'As Sunaynah')
GO
ALTER TABLE [dbo].[APPLICATION_PRIVILLAGES]  WITH CHECK ADD  CONSTRAINT [FK_ROLE_PRIVILLAGES_ROLE_PRIVILLAGES] FOREIGN KEY([APPLICATION_ENTITY_ID])
REFERENCES [dbo].[APPLICATION_ENTITIES] ([ID])
GO
ALTER TABLE [dbo].[APPLICATION_PRIVILLAGES] CHECK CONSTRAINT [FK_ROLE_PRIVILLAGES_ROLE_PRIVILLAGES]
GO
ALTER TABLE [dbo].[APPLICATION_PRIVILLAGES]  WITH CHECK ADD  CONSTRAINT [FK_ROLE_PRIVILLAGES_USERS] FOREIGN KEY([USER_ID])
REFERENCES [dbo].[USERS] ([ID])
GO
ALTER TABLE [dbo].[APPLICATION_PRIVILLAGES] CHECK CONSTRAINT [FK_ROLE_PRIVILLAGES_USERS]
GO
ALTER TABLE [dbo].[MEMBER_INFO]  WITH CHECK ADD  CONSTRAINT [FK_MEMBER_INFO_APPLICATIONS] FOREIGN KEY([APPLICATION_ID])
REFERENCES [dbo].[APPLICATIONS] ([ID])
GO
ALTER TABLE [dbo].[MEMBER_INFO] CHECK CONSTRAINT [FK_MEMBER_INFO_APPLICATIONS]
GO
ALTER TABLE [dbo].[TICKET_CHAT_DETAILS]  WITH CHECK ADD  CONSTRAINT [FK_TICKET_CHAT_DETAILS_TICKETS] FOREIGN KEY([TICKET_ID])
REFERENCES [dbo].[TICKETS] ([ID])
GO
ALTER TABLE [dbo].[TICKET_CHAT_DETAILS] CHECK CONSTRAINT [FK_TICKET_CHAT_DETAILS_TICKETS]
GO
ALTER TABLE [dbo].[USER_DETAILS]  WITH CHECK ADD  CONSTRAINT [FK_USER_DETAILS_USERS] FOREIGN KEY([USER_ID])
REFERENCES [dbo].[USERS] ([ID])
GO
ALTER TABLE [dbo].[USER_DETAILS] CHECK CONSTRAINT [FK_USER_DETAILS_USERS]
GO
/****** Object:  StoredProcedure [dbo].[DeleteTicket]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Samh Khalid
-- Create date	: 18-05-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Resolve a ticket
-- =============================================
CREATE PROCEDURE [dbo].[DeleteTicket]
	-- Add the parameters for the stored procedure here
	@Pin_TicketId			int,
	@Pin_ModifiedBy			int,	 
	@Pout_Error				int output
	
AS
BEGIN TRY
	BEGIN TRANSACTION    -- Start the transaction

	UPDATE TICKETS
	SET
		TICKET_STATUS_ID = 4,		 
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_TicketId;
	
	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH

GO
/****** Object:  StoredProcedure [dbo].[DeleteTicketParticipant]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 16-07-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Delete a ticket participant
-- =============================================
CREATE PROCEDURE [dbo].[DeleteTicketParticipant]
	-- Add the parameters for the stored procedure here
	@Pin_TicketId				int,
	@Pin_TicketParticipantId	int,
	@Pout_Error					int output
	
AS
DECLARE @v_Count		 int = 0;
BEGIN TRY

	-- Check the deleting user is ticket owner
	SELECT @v_Count = COUNT(1)
	FROM TICKETS T
	WHERE ID = @Pin_TicketId AND TICKET_OWNER_USER_ID = (SELECT TP.USER_ID 
														FROM TICKET_PARTICIPANTS TP 
														WHERE TP.ID = @Pin_TicketParticipantId );
	if(@v_Count > 0)
	begin
		set @Pout_Error = -2; -- RelatedRecordFaild
		return;
	end	

	BEGIN TRANSACTION    -- Start the transaction

	DELETE FROM TICKET_PARTICIPANTS
	WHERE 
		ID = @Pin_TicketParticipantId;
	
	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH

GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE[dbo].[ELMAH_GetErrorsXml]  
  
(  
    @Application NVARCHAR(60),  
    @PageIndex INT = 0,  
    @PageSize INT = 15,  
    @TotalCount INT OUTPUT  
  
)  
  
AS  
  
SET NOCOUNT ON  
  
DECLARE @FirstTimeUTC DATETIME  
DECLARE @FirstSequence INT  
DECLARE @StartRow INT  
DECLARE @StartRowIndex INT  
SELECT  
  
@TotalCount = COUNT(1)  
  
FROM  
  
    [ELMAH_Error]  
  
WHERE  
  
    [Application] = @Application  
SET @StartRowIndex = @PageIndex * @PageSize + 1  
IF @StartRowIndex <= @TotalCount  
  
BEGIN  
  
SET ROWCOUNT @StartRowIndex  
  
SELECT  
  
@FirstTimeUTC = [TimeUtc],  
  
    @FirstSequence = [Sequence]  
  
FROM  
  
    [ELMAH_Error]  
  
WHERE  
  
    [Application] = @Application  
  
ORDER BY  
  
    [TimeUtc] DESC,  
    [Sequence] DESC  
  
END  
  
ELSE  
  
BEGIN  
  
SET @PageSize = 0  
  
END  
  
SET ROWCOUNT @PageSize  
  
SELECT  
  
errorId = [ErrorId],  
  
    application = [Application],  
    host = [Host],  
    type = [Type],  
    source = [Source],  
    message = [Message],  
    [user] = [User],  
    statusCode = [StatusCode],  
    time = CONVERT(VARCHAR(50), [TimeUtc], 126) + 'Z'  
  
FROM  
  
    [ELMAH_Error] error  
  
WHERE  
  
    [Application] = @Application  
  
AND  
  
    [TimeUtc] <= @FirstTimeUTC  
  
AND  
  
    [Sequence] <= @FirstSequence  
  
ORDER BY  
  
    [TimeUtc] DESC,  
  
    [Sequence] DESC  
  
FOR  
  
XML AUTO  
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE[dbo].[ELMAH_GetErrorXml]  
  
(  
  
    @Application NVARCHAR(60),  
    @ErrorId UNIQUEIDENTIFIER  
  
)  
  
AS  
  
SET NOCOUNT ON  
SELECT  
  
    [AllXml]  
FROM  
  
    [ELMAH_Error]  
WHERE  
  
    [ErrorId] = @ErrorId  
AND  
    [Application] = @Application  
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE[dbo].[ELMAH_LogError]  
  
(  
  
    @ErrorId UNIQUEIDENTIFIER,    
    @Application NVARCHAR(60),    
    @Host NVARCHAR(30),    
    @Type NVARCHAR(100),  
    @Source NVARCHAR(60),    
    @Message NVARCHAR(500),  
    @User NVARCHAR(50),   
    @AllXml NTEXT,    
    @StatusCode INT,   
    @TimeUtc DATETIME  
  
)  
  
AS  
  
SET NOCOUNT ON  
  
INSERT  
  
INTO  
  
    [ELMAH_Error]
(  
  
    [ErrorId],   
    [Application],   
    [Host],  
    [Type],  
    [Source],  
    [Message],    
    [User],    
    [AllXml],    
    [StatusCode],    
    [TimeUtc]  
  
)  
  
VALUES  
  
    (  
  
    @ErrorId,  
    @Application,    
    @Host,    
    @Type,    
    @Source,   
    @Message,    
    @User,   
    @AllXml,   
    @StatusCode,   
    @TimeUtc  
  
)  
GO
/****** Object:  StoredProcedure [dbo].[GetAllActiveEvents]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetAllActiveEvents]
	@Pin_ApplicationId	INT = NULL,
	@Pin_LanguageId		INT = NULL,
	@Pin_EventId		INT = NULL
AS
BEGIN
	 
	SELECT 
	ID, 
	APPLICATION_ID,
	EVENT_NAME,
	EVENT_DESCRIPTION,
	EVENT_DATE,
	EVENT_LOCATION_NAME,
	EVENT_LATITUDE,
	EVENT_LONGITUDE,
	CREATED_BY,
	CREATED_DATE,
	MODIFIED_BY,
	MODIFIED_DATE,
	IS_ACTIVE,
	IS_NOTIFY_USER,
	EVENT_IMG_FILE_PATH
	FROM dbo.EVENTS  EN
	WHERE 
		( EN.APPLICATION_ID = @Pin_ApplicationId OR @Pin_ApplicationId IS NULL ) AND
		( EN.ID = @Pin_EventId  OR @Pin_EventId IS NULL ) AND
		( EN.LANGUAGE_ID = @Pin_LanguageId )
	ORDER BY EN.ID DESC
	
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllActiveNews]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get all news
-- =============================================
CREATE PROCEDURE [dbo].[GetAllActiveNews]
	@Pin_ApplicationId		int = NULL,
	@Pin_LanguageId			INT,
	@Pin_NewsId				int = NULL
AS
BEGIN
	SELECT 
		N.ID,
		N.APPLICATION_ID,
		N.IS_ACTIVE,
		N.IS_NOTIFY_USER,
		N.NEWS_TITLE,
		N.NEWS_CONTENT,
		N.NEWS_IMG_FILE_PATH,
		N.PUBLISHED_DATE
    FROM 
		 NEWS N
	WHERE
		N.IS_ACTIVE = 1 AND
		( N.ID = @Pin_NewsId  OR @Pin_NewsId IS NULL ) AND
		( N.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL ) AND
		( N.LANGUAGE_ID = @Pin_LanguageId)
	ORDER BY N.ID DESC
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllActiveTickets]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get all tickets
-- =============================================
CREATE PROCEDURE [dbo].[GetAllActiveTickets]
	@Pin_ApplicationId		int = NULL,
	@Pin_TicketId			int = NULL,
	@Pin_UserId				int = NULL
AS
BEGIN
	SELECT 
		T.ID,
		T.APPLICATION_ID,
		T.TICKET_NAME,
		T.TICKET_CODE,
		T.TICKET_STATUS_ID,
		T.DEFAULT_IMAGE,
		T.IS_ACTIVE,
		T.TICKET_DESCRIPTION,
		T.TICKET_STATUS_REMARK,
		TS.STATUS_NAME TICKET_STATUS_NAME,
		T.CREATED_DATE
    FROM 
		 TICKETS T
	INNER JOIN TICKET_PARTICIPANTS TP ON TP.TICKET_ID = T.ID
	INNER JOIN TICKET_STATUS TS ON TS.ID = T.TICKET_STATUS_ID
	WHERE
		T.IS_ACTIVE = 1 AND
		T.TICKET_STATUS_ID != 4 AND -- Not include deleted tickets
		( T.ID = @Pin_TicketId  OR @Pin_TicketId IS NULL ) AND
		( TP.USER_ID = @Pin_UserId  OR @Pin_UserId IS NULL ) AND
		( T.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL )
	GROUP BY
		T.ID,
		T.APPLICATION_ID,
		T.TICKET_NAME,
		T.TICKET_CODE,
		T.TICKET_STATUS_ID,
		T.DEFAULT_IMAGE,
		T.IS_ACTIVE,
		T.TICKET_DESCRIPTION,
		T.TICKET_STATUS_REMARK,
		TS.STATUS_NAME,
		T.CREATED_DATE
	ORDER BY T.ID DESC
END















GO
/****** Object:  StoredProcedure [dbo].[GetAllApplications]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get all applications
-- =============================================
CREATE PROCEDURE [dbo].[GetAllApplications]
	@Pin_ApplicationId		int = null,
	@Pin_ApplicationName	varchar(200) = NULL,
	@Pin_PageNumber			INT = 1,
	@Pin_RowspPage			INT = 10
AS
BEGIN
	SELECT
		TotalCount = COUNT(*) OVER(),
		(
			SELECT UD.FULL_NAME FROM USER_DETAILS UD
			INNER JOIN USERS U ON U.ID = UD.USER_ID
			WHERE U.APPLICATION_ID = A.ID AND U.USER_TYPE_ID = 2 -- Member 
		) MemberName,
		(
			SELECT U.ID FROM USERS U
			WHERE U.APPLICATION_ID = A.ID AND U.USER_TYPE_ID = 2 -- Member 
		) MemberUserID,
		A.ID,
		A.APPLICATION_NAME,
		A.APPLICATION_LOGO_PATH,
		A.APPLICATION_EXPIRY_DATE,
		A.DEFAULT_THEME_COLOR,
		A.IS_ACTIVE,
		A.CREATED_DATE
    FROM 
		 APPLICATIONS A
	WHERE 
		( A.ID = @Pin_ApplicationId or @Pin_ApplicationId is null ) and
		( A.APPLICATION_NAME like '%' + @Pin_ApplicationName + '%'  OR @Pin_ApplicationName IS NULL )
	Group By
		A.ID,
		A.APPLICATION_NAME,
		A.APPLICATION_LOGO_PATH,
		A.APPLICATION_EXPIRY_DATE,
		A.DEFAULT_THEME_COLOR,
		A.IS_ACTIVE,
		A.CREATED_DATE
	ORDER BY A.ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY	
END

















GO
/****** Object:  StoredProcedure [dbo].[GetAllAreas]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllAreas]
	 @Pin_LanguageId int
AS
BEGIN
	 SELECT 
		[AREA_CODE] AREACODE,
		case when @Pin_LanguageId = 1 then AREA_DESC_ARB else ISNULL([AREA_DESC_ENG], [AREA_DESC_ARB])
		end as  AREA_NAME
	 FROM AREA_MASTER
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllMembers]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samh Khalid
-- Create date	: 23-05-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get all members
-- =============================================
CREATE PROCEDURE [dbo].[GetAllMembers]
	@Pin_MemberId		INT = null,
	@Pin_MemberName		VARCHAR(200) = NULL,
	@Pin_PageNumber		INT = 1,
	@Pin_RowspPage		INT = 10
AS
BEGIN
	SELECT
		TotalCount = COUNT(*) OVER(),
			UD.USER_ID,
			UD.FULL_NAME,
			UD.LAST_LOGGED_IN_DATE,
			U.IS_ACTIVE,
			U.PHONE_NUMBER
    FROM 
		USER_DETAILS UD
		INNER JOIN USERS U ON U.ID = UD.USER_ID
		WHERE U.USER_TYPE_ID = 2  
	 AND 
		( UD.USER_ID = @Pin_MemberId or @Pin_MemberId is null ) and
		( UD.FULL_NAME like '%' + @Pin_MemberName + '%'  OR @Pin_MemberName IS NULL )
	Group By
		UD.USER_ID,
			UD.FULL_NAME,
			UD.LAST_LOGGED_IN_DATE ,
			U.IS_ACTIVE ,
			U.PHONE_NUMBER
	ORDER BY UD.USER_ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY	
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllTickets]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get all tickets
-- =============================================
CREATE PROCEDURE [dbo].[GetAllTickets]
	@Pin_ApplicationId			int = NULL,
	@Pin_TicketId				int = NULL,
	@Pin_UserId					int = NULL,
	@Pin_TicketStatusId			int = NULL,
	@Pin_TicketCode				varchar(10) = NULL,
	@Pin_TicketName				varchar(300) = NULL,
	@Pin_PageNumber				INT = 1,
	@Pin_RowspPage				INT = 10
AS
BEGIN
	SELECT 
		TotalCount = COUNT(*) OVER(),
		T.ID,
		T.APPLICATION_ID,
		T.TICKET_CODE,
		T.TICKET_NAME,
		T.TICKET_STATUS_ID,
		T.DEFAULT_IMAGE,
		T.IS_ACTIVE,
		T.TICKET_DESCRIPTION,
		T.TICKET_STATUS_REMARK,
		T.CREATED_BY,
		T.CREATED_DATE,
		TS.STATUS_NAME TICKET_STATUS_NAME,
		T.TICKET_OWNER_USER_ID,
		(
			SELECT UD.FULL_NAME 
			FROM USER_DETAILS UD
			WHERE UD.USER_ID = T.TICKET_OWNER_USER_ID
		) TicketOwnerUserFullName,
		T.TICKET_CREATED_PLATFORM,
		(
			SELECT Count(*)
			FROM TICKET_PARTICIPANTS TP
			WHERE TP.TICKET_ID = T.ID
		) TicketParticipantNos
    FROM 
		 TICKETS T
	left JOIN TICKET_PARTICIPANTS TP ON TP.TICKET_ID = T.ID
	INNER JOIN TICKET_STATUS TS ON TS.ID = T.TICKET_STATUS_ID
	WHERE
		( T.ID = @Pin_TicketId  OR @Pin_TicketId IS NULL ) AND
		( TP.USER_ID = @Pin_UserId  OR @Pin_UserId IS NULL ) AND
		( T.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL ) and
		( T.TICKET_STATUS_ID = @Pin_TicketStatusId  OR @Pin_TicketStatusId IS NULL ) and
		( T.TICKET_CODE = @Pin_TicketCode  OR @Pin_TicketCode IS NULL ) and
		( T.TICKET_NAME like '%' + @Pin_TicketName + '%'  OR @Pin_TicketName IS NULL )
	GROUP BY
		T.ID,
		T.APPLICATION_ID,
		T.TICKET_CODE,
		T.TICKET_NAME,
		T.TICKET_STATUS_ID,
		T.DEFAULT_IMAGE,
		T.IS_ACTIVE,
		T.TICKET_DESCRIPTION,
		T.TICKET_STATUS_REMARK,
		T.CREATED_BY,
		T.CREATED_DATE,
		TS.STATUS_NAME,
		T.TICKET_OWNER_USER_ID,
		T.TICKET_CREATED_PLATFORM
	ORDER BY T.ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllTicketStatusLookup]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Arshad Ashraf
-- Create date: 23-01-2017
-- Description:	Get all ticket status Lookups
-- =============================================
CREATE PROCEDURE [dbo].[GetAllTicketStatusLookup]
AS
BEGIN
	SELECT 
		ID AS ID,
		STATUS_NAME AS Name
	FROM TICKET_STATUS
END


















GO
/****** Object:  StoredProcedure [dbo].[GetAllVillages]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllVillages] 
	@Pin_AreaCode		VARCHAR(50),
	@Pin_WilayatCode	VARCHAR(50),
	@Pin_LanguageId		int
AS
BEGIN
	SELECT 
		VILLAGE_CODE VILLAGECODE,
		case when @Pin_LanguageId = 1 then VILLAGE_DESC_ARB else ISNULL(VILLAGE_DESC_ENG,VILLAGE_DESC_ARB)
		end as  VILLAGENAME
	FROM VILLAGE_MASTER VM
	WHERE VM.AREA_CODE = @Pin_AreaCode and
		  VM.WILAYAT_CODE = @Pin_WilayatCode
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllWilayats]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllWilayats]
	 @Pin_AreaCode		VARCHAR(50),
	 @Pin_LanguageId	int
AS
BEGIN
	 SELECT 
			WILAYAT_CODE WILAYATCODE,
			case when @Pin_LanguageId = 1 then WILAYAT_DESC_ARB else ISNULL(WILAYAT_DESC_ENG,WILAYAT_DESC_ARB)
			end as  WILLAYATNAME
	 FROM WILAYAT_MASTER
	 WHERE AREA_CODE = @Pin_AreaCode
END

GO
/****** Object:  StoredProcedure [dbo].[GetApplicationDetails]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get application details
-- =============================================
CREATE PROCEDURE [dbo].[GetApplicationDetails]
	@Pin_ApplicationId		int = NULL
AS
BEGIN
	SELECT 
		A.ID,
		A.APPLICATION_NAME,
		A.APPLICATION_LOGO_PATH,
		A.APPLICATION_TOKEN,
		A.DEFAULT_THEME_COLOR,
		A.IS_ACTIVE,
		(
			SELECT UD.FULL_NAME FROM USER_DETAILS UD
			INNER JOIN USERS U ON U.ID = UD.USER_ID
			WHERE U.APPLICATION_ID = A.ID AND U.USER_TYPE_ID = 2 -- Member 
		) MemberName,
		A.APPLICATION_EXPIRY_DATE,
		PlayStoreURL = (SELECT SETTINGS_VALUE FROM APPLICATION_SETTINGS S 
						INNER JOIN APPLICATION_MASTER_SETTINGS MS ON MS.ID = S.APPLICATION_MASTER_SETTING_ID
						WHERE S.APPLICATION_ID = A.ID AND MS.[SETTINGS_NAME] = 'PlayStoreURL' ),
		AppleStoreURL = (SELECT SETTINGS_VALUE FROM APPLICATION_SETTINGS S 
						INNER JOIN APPLICATION_MASTER_SETTINGS MS ON MS.ID = S.APPLICATION_MASTER_SETTING_ID
						WHERE S.APPLICATION_ID = A.ID AND MS.[SETTINGS_NAME] = 'AppleStoreURL' )
    FROM 
		 APPLICATIONS A
	WHERE
		( A.ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL )
END

GO
/****** Object:  StoredProcedure [dbo].[GetApplicationInfo]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get application information
-- =============================================
create PROCEDURE [dbo].[GetApplicationInfo]
	@Pin_ApplicationId		int
AS
BEGIN
	SELECT 
		AI.ID,
		AI.APPLICATION_ID,
		AI.TITLE,
		AI.DESCRIPTION,
		AI.CREATED_DATE,
		AI.CREATED_BY
    FROM 
		 APPLICATION_INFO AI
	WHERE
		AI.APPLICATION_ID = @Pin_ApplicationId
END
GO
/****** Object:  StoredProcedure [dbo].[GetApplicationSettings]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get application settings
-- =============================================
CREATE PROCEDURE [dbo].[GetApplicationSettings]
	@Pin_ApplicationId		int
AS
BEGIN
	SELECT 
		S.ID,
		S.APPLICATION_ID,
		S.APPLICATION_MASTER_SETTING_ID,
		S.SETTINGS_VALUE,
		MS.SETTINGS_NAME
    FROM 
		 APPLICATION_SETTINGS S
	INNER JOIN APPLICATION_MASTER_SETTINGS MS ON MS.ID = S.APPLICATION_MASTER_SETTING_ID
	WHERE
		S.APPLICATION_ID = @Pin_ApplicationId
END
GO
/****** Object:  StoredProcedure [dbo].[GetApplicationStatistics]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get all tickets
-- =============================================
CREATE PROCEDURE [dbo].[GetApplicationStatistics]
	@Pin_ApplicationId int
AS
BEGIN
	SELECT
		(
			SELECT COUNT(*) FROM USERS U WHERE U.APPLICATION_ID = A.ID AND U.USER_TYPE_ID = 4 --Mobile user
		)TotalMobileUserCount,
		(
			SELECT COUNT(*) FROM USERS U WHERE U.APPLICATION_ID = A.ID AND U.USER_TYPE_ID = 4 AND U.IS_BLOCKED = 1 -- Mobile blocked user
		)TotalMobileBlockedUserCount,
		(
			SELECT COUNT(*) FROM TICKETS T WHERE T.APPLICATION_ID = A.ID  -- Total ticket count
		)TotalTicketCount,
		(
			SELECT COUNT(*) FROM 
			TICKETS T WHERE T.APPLICATION_ID = A.ID AND T.TICKET_STATUS_ID = 1  -- Total open ticket count
		)TotalTicketOpenCount,
		(
			SELECT COUNT(*) FROM 
			TICKETS T WHERE T.APPLICATION_ID = A.ID AND T.TICKET_STATUS_ID = 2  -- Total closed ticket count
		)TotalTicketClosedCount,
		(
			SELECT COUNT(*) FROM 
			TICKET_CHAT_DETAILS TD
			INNER JOIN TICKETS T ON T.ID = TD.TICKET_ID 
			WHERE T.APPLICATION_ID = A.ID -- Total ticket chat count
		)TotalTicketChatCount,
		(
			SELECT UD.FULL_NAME FROM USER_DETAILS UD
			INNER JOIN USERS U ON U.ID = UD.USER_ID
			WHERE U.APPLICATION_ID = A.ID AND U.USER_TYPE_ID = 2 -- Member 
		) MemberName,
		A.ID,
		A.APPLICATION_NAME,
		A.APPLICATION_LOGO_PATH,
		A.APPLICATION_EXPIRY_DATE,
		A.DEFAULT_THEME_COLOR,
		A.IS_ACTIVE,
		A.CREATED_DATE,
		1 TotalCount 
    FROM 
		 APPLICATIONS A
	WHERE
		 A.ID = @Pin_ApplicationId
	
END

















GO
/****** Object:  StoredProcedure [dbo].[GetApplicationUsers]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get application details
-- =============================================
CREATE PROCEDURE [dbo].[GetApplicationUsers]
	@Pin_ApplicationId		int = NULL,
	@Pin_UserId				int = NULL,
	@Pin_UserType			int = NULL,
	@Pin_UserSearch			varchar(100) = NULL,
	@Pin_PageNumber			INT = 1,
	@Pin_RowspPage			INT = 10
AS
BEGIN
	SELECT 
		TotalCount = COUNT(*) OVER(),
		U.*,
		UD.FULL_NAME,
		UD.ADDRESS,
		UD.CIVIL_ID,
		UD.AREA_ID,
		UD.WILAYAT_ID,
		UD.VILLAGE_ID,
		UD.OTP_NUMBER,
		UD.IS_OTP_VALIDATED,
		UD.SMS_SENT_STATUS,
		UD.LAST_LOGGED_IN_DATE,
		UD.IS_TICKET_SUBMISSION_RESTRICTED,
		UD.TICKET_SUBMISSION_INTERVAL_DAYS,
		UD.NO_OF_TIMES_OTP_SEND,
		UD.LAST_LOGGED_IN_DATE,
		UD.LAST_TICKET_SUBMISSION_DATE,
		UT.TYPE USER_TYPE_NAME,
		AM.AREA_DESC_ARB,
		AM.AREA_DESC_ENG,
		WM.WILAYAT_DESC_ARB,
		WM.WILAYAT_DESC_ENG,
		VM.VILLAGE_DESC_ARB,
		VM.VILLAGE_DESC_ENG,
		A.APPLICATION_NAME,
		UD.SMS_SENT_STATUS,
		UD.SMS_SENT_TRANSACTION_DATE
    FROM 
		 USERS U
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	INNER JOIN USER_TYPES UT ON UT.ID = U.USER_TYPE_ID AND UT.ID != 1 -- Admin Type
	LEFT JOIN AREA_MASTER AM ON AM.ID = UD.AREA_ID
	LEFT   JOIN WILAYAT_MASTER WM ON WM.WILAYAT_CODE = UD.WILAYAT_ID
	LEFT   JOIN VILLAGE_MASTER VM ON VM.VILLAGE_CODE = UD.VILLAGE_ID
	LEFT JOIN APPLICATIONS A ON A.ID = U.APPLICATION_ID
	WHERE
		( U.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL ) and
		( U.ID = @Pin_UserId  OR @Pin_UserId IS NULL ) and
		( U.USER_TYPE_ID = @Pin_UserType  OR @Pin_UserType IS NULL ) and
		( @Pin_UserSearch IS NULL OR ( U.USER_NAME LIKE '%' + @Pin_UserSearch + '%' OR
									 U.PHONE_NUMBER LIKE '%' + @Pin_UserSearch + '%' OR
									 U.EMAIL LIKE '%' + @Pin_UserSearch + '%' OR
									 UD.FULL_NAME LIKE '%' + @Pin_UserSearch + '%'))
	GROUP BY
		U.ID,
		U.USER_NAME,
		U.PASSWORD,
		U.USER_TYPE_ID,
		U.PHONE_NUMBER,
		U.EMAIL,
		U.APPLICATION_ID,
		U.IS_ACTIVE,
		U.IS_BLOCKED,
		U.BLOCKED_REMARKS,
		U.CREATED_BY,
		U.CREATED_DATE,
		U.MODIFIED_BY,
		U.MODIFIED_DATE,
		UD.FULL_NAME,
		UD.ADDRESS,
		UD.CIVIL_ID,
		UD.AREA_ID,
		UD.WILAYAT_ID,
		UD.VILLAGE_ID,
		UD.OTP_NUMBER,
		UD.IS_OTP_VALIDATED,
		UD.SMS_SENT_STATUS,
		UD.LAST_LOGGED_IN_DATE,
		UD.IS_TICKET_SUBMISSION_RESTRICTED,
		UD.TICKET_SUBMISSION_INTERVAL_DAYS,
		UD.NO_OF_TIMES_OTP_SEND,
		UD.LAST_LOGGED_IN_DATE,
		UD.LAST_TICKET_SUBMISSION_DATE,
		UT.TYPE,
		AM.AREA_DESC_ARB,
		AM.AREA_DESC_ENG,
		WM.WILAYAT_DESC_ARB,
		WM.WILAYAT_DESC_ENG,
		VM.VILLAGE_DESC_ARB,
		VM.VILLAGE_DESC_ENG,
		A.APPLICATION_NAME,
		UD.SMS_SENT_STATUS,
		UD.SMS_SENT_TRANSACTION_DATE
	ORDER BY U.ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY
END

GO
/****** Object:  StoredProcedure [dbo].[GetApplicationUsersByUserTypes]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 15-07-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get ticket users
-- =============================================
CREATE PROCEDURE [dbo].[GetApplicationUsersByUserTypes]
	@Pin_ApplicationId		int,
	@Pin_UserTypeIds		varchar(MAX) = NULL
AS
BEGIN
	SELECT DISTINCT 
		U.*,
		UD.FULL_NAME,
		UD.ADDRESS,
		UD.CIVIL_ID,
		UD.AREA_ID,
		UD.WILAYAT_ID,
		UD.VILLAGE_ID,
		UD.OTP_NUMBER,
		UD.IS_OTP_VALIDATED,
		UD.SMS_SENT_STATUS,
		UD.LAST_LOGGED_IN_DATE,
		UD.IS_TICKET_SUBMISSION_RESTRICTED,
		UD.TICKET_SUBMISSION_INTERVAL_DAYS,
		UD.NO_OF_TIMES_OTP_SEND,
		UD.LAST_LOGGED_IN_DATE,
		UD.LAST_TICKET_SUBMISSION_DATE,
		UD.PREFERED_LANGUAGE_ID,
		UD.DEVICE_ID,
		UT.TYPE USER_TYPE_NAME,
		AM.AREA_DESC_ARB,
		AM.AREA_DESC_ENG,
		WM.WILAYAT_DESC_ARB,
		WM.WILAYAT_DESC_ENG,
		VM.VILLAGE_DESC_ARB,
		VM.VILLAGE_DESC_ENG
    FROM 
		 USERS U
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	INNER JOIN USER_TYPES UT ON UT.ID = U.USER_TYPE_ID AND UT.ID != 1 -- Admin Type
	LEFT JOIN AREA_MASTER AM ON AM.ID = UD.AREA_ID
	LEFT JOIN WILAYAT_MASTER WM ON WM.WILAYAT_CODE = UD.WILAYAT_ID
	LEFT JOIN VILLAGE_MASTER VM ON VM.VILLAGE_CODE = UD.VILLAGE_ID
	LEFT JOIN APPLICATIONS A ON A.ID = U.APPLICATION_ID
	WHERE
		( U.APPLICATION_ID = @Pin_ApplicationId ) and
		( U.USER_TYPE_ID IN (select items from Split (@Pin_UserTypeIds, ',') ) OR @Pin_UserTypeIds IS NULL )
	ORDER BY U.ID DESC
END

GO
/****** Object:  StoredProcedure [dbo].[GetEventDetails]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetEventDetails]
	@Pin_EventId	INT = NULL
AS
BEGIN
	 
	SELECT 
	ID, 
	APPLICATION_ID,
	EVENT_NAME,
	EVENT_DESCRIPTION,
	EVENT_DATE,
	EVENT_LOCATION_NAME,
	EVENT_LATITUDE,
	EVENT_LONGITUDE,
	CREATED_BY,
	CREATED_DATE,
	MODIFIED_BY,
	MODIFIED_DATE,
	IS_ACTIVE,
	IS_NOTIFY_USER,
	EVENT_IMG_FILE_PATH
	FROM EVENTS
	where 
		ID = @Pin_EventId

	
END








GO
/****** Object:  StoredProcedure [dbo].[GetEventsByDate]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetEventsByDate] 
	      @Pin_Eventdate DATE,
		  @Pin_ApplicationId INT

AS
BEGIN
SELECT
	[ID]
      ,[APPLICATION_ID]
      ,[EVENT_NAME]
      ,[EVENT_DESCRIPTION]
      ,[EVENT_DATE]
      ,[EVENT_LOCATION_NAME]
      ,[EVENT_LATITUDE]
      ,[EVENT_LONGITUDE]
      ,[IS_ACTIVE],
	  IS_NOTIFY_USER
	  FROM [Takamul].[dbo].[EVENTS]
		WHERE EVENT_DATE=@Pin_Eventdate AND APPLICATION_ID = @Pin_ApplicationId
		ORDER BY EVENT_DATE ASC
END









GO
/****** Object:  StoredProcedure [dbo].[GetMemberInfo]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get mobile application user information
-- =============================================
CREATE PROCEDURE [dbo].[GetMemberInfo]
	@Pin_ApplicationId		int,
	@Pin_LanguageId			int
AS
BEGIN
	SELECT 
		MI.ID,
		MI.APPLICATION_ID,
		MI.MEMBER_INFO_TITLE,
		MI.MEMBER_INFO_DESCRIPTION,
		MI.CREATED_DATE,
		MI.CREATED_BY
    FROM 
		 MEMBER_INFO MI
	WHERE
		MI.APPLICATION_ID = @Pin_ApplicationId and
		MI.LANGUAGE_ID = @Pin_LanguageId
END
GO
/****** Object:  StoredProcedure [dbo].[GetMobileAppUserInfo]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get mobile application user information
-- =============================================
CREATE PROCEDURE [dbo].[GetMobileAppUserInfo]
	@Pin_UserId			int = NULL,
	@Pin_PhoneNumber	varchar(50) = NULL
AS
BEGIN
	SELECT 
		U.ID,
		U.APPLICATION_ID,
		U.PHONE_NUMBER,
		U.EMAIL,
		U.IS_ACTIVE,
		U.IS_BLOCKED,
		U.BLOCKED_REMARKS,
		UD.FULL_NAME,
		UD.CIVIL_ID,
		UD.ADDRESS,
		UD.IS_OTP_VALIDATED,
		UD.SMS_SENT_STATUS,
		UD.IS_TICKET_SUBMISSION_RESTRICTED,
		UD.TICKET_SUBMISSION_INTERVAL_DAYS,
		UD.LAST_TICKET_SUBMISSION_DATE
    FROM 
		 USERS U
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	WHERE
		( U.ID = @Pin_UserId  OR @Pin_UserId IS NULL ) AND
		( U.PHONE_NUMBER = @Pin_PhoneNumber  OR @Pin_PhoneNumber IS NULL )
END







GO
/****** Object:  StoredProcedure [dbo].[GetMoreTicketChats]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get ticket chat details
-- =============================================
CREATE PROCEDURE [dbo].[GetMoreTicketChats]
	@Pin_TicketId				int,
	@Pin_LastTicketChatId		int

AS
BEGIN
	SELECT 
		TCD.ID,
		TCD.TICKET_ID,
		TCD.REPLY_MESSAGE,
		TCD.REPLIED_DATE,
		TCD.REPLY_FILE_PATH,
		TP.USER_ID TICKET_PARTICIPANT_ID,
		TCD.TICKET_CHAT_TYPE_ID,
		TCT.CHAT_TYPE,
		UD.FULL_NAME PARTICIPANT_FULL_NAME,
		T.APPLICATION_ID
    FROM 
		 TICKET_CHAT_DETAILS TCD
	INNER JOIN TICKETS T ON T.ID = TCD.TICKET_ID
	INNER JOIN TICKET_CHAT_TYPES TCT ON TCT.ID = TCD.TICKET_CHAT_TYPE_ID
	INNER JOIN TICKET_PARTICIPANTS TP ON TP.ID = TCD.TICKET_PARTICIPANT_ID
	INNER JOIN USERS U ON U.ID = TP.USER_ID
	left JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	WHERE
		( TCD.TICKET_ID = @Pin_TicketId) AND
		TCD.ID > @Pin_LastTicketChatId
	ORDER BY TCD.ID asc
END

GO
/****** Object:  StoredProcedure [dbo].[GetNewsDetails]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get all news
-- =============================================
create PROCEDURE [dbo].[GetNewsDetails]
	@Pin_NewsId int
AS
BEGIN
	SELECT 
		N.ID,
		N.APPLICATION_ID,
		N.IS_ACTIVE,
		N.IS_NOTIFY_USER,
		N.NEWS_TITLE,
		N.NEWS_CONTENT,
		N.NEWS_IMG_FILE_PATH,
		N.PUBLISHED_DATE
    FROM 
		 NEWS N
	WHERE
		 N.ID = @Pin_NewsId
	ORDER BY N.ID DESC
END
















GO
/****** Object:  StoredProcedure [dbo].[GetTicketChats]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get ticket chat details
-- =============================================
CREATE PROCEDURE [dbo].[GetTicketChats]
	@Pin_TicketId			int
AS
BEGIN
	SELECT 
		TCD.ID,
		TCD.TICKET_ID,
		TCD.REPLY_MESSAGE,
		TCD.REPLIED_DATE,
		TCD.REPLY_FILE_PATH,
		TP.USER_ID TICKET_PARTICIPANT_ID,
		TCD.TICKET_CHAT_TYPE_ID,
		TCT.CHAT_TYPE,
		UD.FULL_NAME PARTICIPANT_FULL_NAME,
		T.APPLICATION_ID
    FROM 
		 TICKET_CHAT_DETAILS TCD
	INNER JOIN TICKETS T ON T.ID = TCD.TICKET_ID
	INNER JOIN TICKET_CHAT_TYPES TCT ON TCT.ID = TCD.TICKET_CHAT_TYPE_ID
	INNER JOIN TICKET_PARTICIPANTS TP ON TP.ID = TCD.TICKET_PARTICIPANT_ID
	INNER JOIN USERS U ON U.ID = TP.USER_ID
	left JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	WHERE
		( TCD.TICKET_ID = @Pin_TicketId  OR @Pin_TicketId IS NULL )
	ORDER BY TCD.ID asc
END

GO
/****** Object:  StoredProcedure [dbo].[GetTicketMObileUserParticipants]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get application details
-- =============================================
CREATE PROCEDURE [dbo].[GetTicketMObileUserParticipants]
	@Pin_TicketId			int,
	@Pin_ExcludedUserId		int = null
AS
BEGIN
	SELECT 
		TP.ID,
		TP.TICKET_ID,
		TP.USER_ID,
		UD.FULL_NAME,
		UD.DEVICE_ID,
		UD.PREFERED_LANGUAGE_ID,
		T.TICKET_NAME
    FROM 
		 TICKET_PARTICIPANTS TP
	INNER JOIN TICKETS T ON T.ID = TP.TICKET_ID
	INNER JOIN USERS U ON U.ID = TP.USER_ID
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	WHERE
		   TP.TICKET_ID = @Pin_TicketId AND U.USER_TYPE_ID = 4  AND
		   U.IS_ACTIVE = 1 AND U.IS_BLOCKED = 0 AND
		  ( @Pin_ExcludedUserId is null OR TP.USER_ID <> @Pin_ExcludedUserId )
	ORDER BY U.ID DESC
END

GO
/****** Object:  StoredProcedure [dbo].[GetTicketParticipants]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get application details
-- =============================================
CREATE PROCEDURE [dbo].[GetTicketParticipants]
	@Pin_TicketId			int = NULL,
	@Pin_PageNumber			INT = 1,
	@Pin_RowspPage			INT = 10
AS
BEGIN
	SELECT 
		TotalCount = COUNT(*) OVER(),
		TP.*,
		UD.FULL_NAME
    FROM 
		 TICKET_PARTICIPANTS TP
	INNER JOIN USERS U ON U.ID = TP.USER_ID
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	WHERE
		( TP.TICKET_ID = @Pin_TicketId  OR @Pin_TicketId IS NULL )
	GROUP BY
		TP.ID,
		TP.TICKET_ID,
		TP.USER_ID,
		UD.FULL_NAME,
		U.ID,
		TP.CREATED_BY,
		TP.CREATED_DATE
	ORDER BY U.ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY
END

GO
/****** Object:  StoredProcedure [dbo].[GetTop5TicketsByStatus]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get all tickets
-- =============================================
CREATE PROCEDURE [dbo].[GetTop5TicketsByStatus]
	@Pin_ApplicationId			int = NULL,
	@Pin_TicketStatusId			int
AS
BEGIN
SELECT TOP 5 
		T.ID,
		T.APPLICATION_ID,
		T.TICKET_CODE,
		T.TICKET_NAME,
		T.TICKET_STATUS_ID,
		T.DEFAULT_IMAGE,
		T.IS_ACTIVE,
		T.TICKET_DESCRIPTION,
		T.TICKET_STATUS_REMARK,
		T.CREATED_BY,
		T.CREATED_DATE,
		TS.STATUS_NAME TICKET_STATUS_NAME,
		(
			SELECT top 1 UD.FULL_NAME FROM TICKET_CHAT_DETAILS TD
			INNER JOIN TICKET_PARTICIPANTS TP ON TP.ID = TD.TICKET_PARTICIPANT_ID --AND TP.TICKET_ID = T.ID
			INNER JOIN USERS U ON U.ID = TP.USER_ID
			INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID			
			--WHERE U.APPLICATION_ID = T.APPLICATION_ID AND U.USER_TYPE_ID = 4 -- Mobile User 
			WHERE TD.TICKET_ID = T.ID AND TD.CREATED_DATE = (SELECT MAX(TDD.CREATED_DATE) FROM TICKET_CHAT_DETAILS TDD WHERE TDD.TICKET_ID = T.ID AND  TDD.TICKET_CHAT_TYPE_ID = 1) -- Text chat 
		) MobileParticipantName,
		(
			SELECT top 1  TD.REPLY_MESSAGE FROM TICKET_CHAT_DETAILS TD
		    WHERE TD.TICKET_ID = T.ID AND TD.CREATED_DATE = (SELECT MAX(TDD.CREATED_DATE) FROM TICKET_CHAT_DETAILS TDD WHERE TDD.TICKET_ID = T.ID AND  TDD.TICKET_CHAT_TYPE_ID = 1) -- Text chat 
		) LastTicketChatMessage,
		(
			SELECT top 1  TD.REPLIED_DATE FROM TICKET_CHAT_DETAILS TD
		    WHERE TD.TICKET_ID = T.ID AND TD.CREATED_DATE = (SELECT MAX(TDD.CREATED_DATE) FROM TICKET_CHAT_DETAILS TDD WHERE TDD.TICKET_ID = T.ID AND  TDD.TICKET_CHAT_TYPE_ID = 1) -- Text chat 
		) LastTicketChatCreatedDate
    FROM 
		 TICKETS T
	INNER JOIN TICKET_STATUS TS ON TS.ID = T.TICKET_STATUS_ID
	WHERE
		( T.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL ) and
		( T.TICKET_STATUS_ID = @Pin_TicketStatusId  OR @Pin_TicketStatusId IS NULL )

	ORDER BY T.ID DESC
	
END

















GO
/****** Object:  StoredProcedure [dbo].[GetUserDetails]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 31-03-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Get application details
-- =============================================
CREATE PROCEDURE [dbo].[GetUserDetails]
	@Pin_UserId				int = NULL,
	@Pin_LanguageId			int = NULL
AS
BEGIN
	SELECT 
		TotalCount = COUNT(*) OVER(),
		U.*,
		UD.FULL_NAME,
		UD.ADDRESS,
		UD.CIVIL_ID,
		UD.AREA_ID,
		UD.WILAYAT_ID,
		UD.VILLAGE_ID,
		UD.OTP_NUMBER,
		UD.IS_OTP_VALIDATED,
		UD.SMS_SENT_STATUS,
		UD.LAST_LOGGED_IN_DATE,
		UD.IS_TICKET_SUBMISSION_RESTRICTED,
		UD.TICKET_SUBMISSION_INTERVAL_DAYS,
		UD.NO_OF_TIMES_OTP_SEND,
		UD.LAST_LOGGED_IN_DATE,
		UD.LAST_TICKET_SUBMISSION_DATE,
		UT.TYPE USER_TYPE_NAME,
		case 
			when @Pin_LanguageId = 1 then AM.AREA_DESC_ARB 
			else ISNULL(AM.AREA_DESC_ENG, AM.AREA_DESC_ARB)
		end as  AREA_NAME,
		case 
			when @Pin_LanguageId = 1 then WM.WILAYAT_DESC_ARB 
			else ISNULL(WM.WILAYAT_DESC_ENG,WM.WILAYAT_DESC_ARB)
		end as  WILLAYAT_NAME,
		case 
			when @Pin_LanguageId = 1 then VM.VILLAGE_DESC_ARB 
			else ISNULL(VM.VILLAGE_DESC_ENG,VM.VILLAGE_DESC_ARB)
		end as  VILLAGE_NAME,
		A.APPLICATION_NAME
    FROM 
		 USERS U
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	INNER JOIN USER_TYPES UT ON UT.ID = U.USER_TYPE_ID AND UT.ID != 1 -- Admin Type
	LEFT JOIN AREA_MASTER AM ON AM.ID = UD.AREA_ID
	LEFT JOIN WILAYAT_MASTER WM ON WM.ID = UD.WILAYAT_ID AND WM.AREA_CODE = AM.AREA_CODE
	LEFT JOIN VILLAGE_MASTER VM ON VM.ID = UD.VILLAGE_ID
	LEFT JOIN APPLICATIONS A ON A.ID = U.APPLICATION_ID
	WHERE 
		U.ID = @Pin_UserId
END















GO
/****** Object:  StoredProcedure [dbo].[Inc_GetAllActiveEvents]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Inc_GetAllActiveEvents]
	@ApplicationID INT,
	@EventID	INT = NULL
AS
BEGIN
	 
	SELECT 
	ID EVENTID, 
	APPLICATION_ID APPLID,
	EVENT_NAME EVENTNAME,
	EVENT_DESCRIPTION EVENTDESCRIPTION,
	EVENT_DATE EVENTDATE,
	EVENT_LOCATION_NAME LOCATIONNAME,
	EVENT_LATITUDE LATITUDE,
	EVENT_LONGITUDE LONGITUDE,
	CREATED_BY CREATEDBY,
	CREATED_DATE CRETEDDATE,
	MODIFIED_BY MODIFIEDBY,
	MODIFIED_DATE MODIFIEDDATE
	FROM dbo.EVENTS  EN
	WHERE EN.APPLICATION_ID = @ApplicationID AND
	( EN.ID = @EventID  OR @EventID IS NULL )

	
END








GO
/****** Object:  StoredProcedure [dbo].[InsertApplication]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert Ticket
-- =============================================
CREATE PROCEDURE [dbo].[InsertApplication]
	-- Add the parameters for the stored procedure here
	@Pin_ApplicationName			varchar(200),
	@Pin_MemberUserID				int,
	@Pin_ApplicationLogoPath		varchar(300),
	@Pin_ApplicationExpiryDate		smalldatetime,
	@Pin_CreatedBy					int,
	@Pout_ApplicationID				int output,
	@Pout_Error						int output
AS
BEGIN
DECLARE @v_ApplicationID		 int;

BEGIN TRY

	BEGIN TRANSACTION    -- Start the transaction	
	--Insert into application table
	INSERT INTO APPLICATIONS
	(
		APPLICATION_NAME,
		APPLICATION_EXPIRY_DATE,
		APPLICATION_LOGO_PATH,
		IS_ACTIVE,
		CREATED_BY,
		CREATED_DATE
	) 
	VALUES
	(
		@Pin_ApplicationName,
		@Pin_ApplicationExpiryDate,
		@Pin_ApplicationLogoPath,
		1, -- Is Active
		@Pin_CreatedBy,
		GETDATE()
	) ;

	-- Select application id
	SELECT @v_ApplicationID = SCOPE_IDENTITY()
	
	-- Create default image file path 
	IF @Pin_ApplicationLogoPath IS NOT NULL
	BEGIN
		UPDATE APPLICATIONS 
		SET APPLICATION_LOGO_PATH = CONCAT(@v_ApplicationID,'/',@Pin_ApplicationLogoPath)
		WHERE ID = @v_ApplicationID;
	END;

	-- Update member application id 
	IF @v_ApplicationID IS NOT NULL
	BEGIN
		UPDATE USERS 
		SET  APPLICATION_ID = @v_ApplicationID
		WHERE ID = @Pin_MemberUserID;
	END;

	set @Pout_Error = 1;
	set @Pout_ApplicationID = @v_ApplicationID;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION

		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
END

GO
/****** Object:  StoredProcedure [dbo].[InsertMobileUser]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert incident declaration
-- =============================================
CREATE PROCEDURE [dbo].[InsertMobileUser]
	-- Add the parameters for the stored procedure here
	@Pin_ApplicationId		int,
	@Pin_UserTypeId			int,
	@Pin_FullName			nvarchar(100),
	@Pin_PhoneNumber		varchar(50),
	@Pin_Email				varchar(50) = null,
	@Pin_CivilID			varchar(50) = null,
	@Pin_Address			varchar(300) = null,
	@Pin_AreaId				int = null,
	@Pin_WilayatId			int = null,
	@Pin_VillageId			int = null,
	@Pin_OTPNumber			int,
	@Pin_DeviceID			varchar(50),
	@Pin_PreferedLanguageID	int,
	@Pout_UserID			int output,
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_UserID		 int;
DECLARE @v_Count		 int;
BEGIN TRY
	SET @v_Count = 0;

	SELECT @v_Count = COUNT(1)
	FROM USERS
	WHERE PHONE_NUMBER = @Pin_PhoneNumber;

	--User does not exist 
	if(@v_Count > 0)
	begin
		set @Pout_Error = -3; -- AlreadyExistRecordFaild
		return;
	end	
	
	SET @v_Count = 0;

	BEGIN TRANSACTION    -- Start the transaction
	--Insert into user table
	INSERT INTO USERS
	(
		USER_TYPE_ID,
		APPLICATION_ID,
		PHONE_NUMBER,
		EMAIL,
		IS_ACTIVE,
		CREATED_DATE
	) 
	VALUES
	(
		@Pin_UserTypeId,
		@Pin_ApplicationId,
		@Pin_PhoneNumber,
		@Pin_Email,
		1, -- Is Active
		GETDATE()
	) 
	
	-- Select inserted user id
	SELECT @v_UserID = SCOPE_IDENTITY()

	--Insert into user table
	INSERT INTO USER_DETAILS
	(
		USER_ID,
		FULL_NAME,
		ADDRESS,
		AREA_ID,
		WILAYAT_ID,
		VILLAGE_ID,
		OTP_NUMBER,
		NO_OF_TIMES_OTP_SEND,
		DEVICE_ID,
		PREFERED_LANGUAGE_ID,
		CREATED_DATE
	) 
	VALUES
	(
		@v_UserID,
		@Pin_FullName,
		@Pin_Address,
		@Pin_AreaId,
		@Pin_WilayatId,
		@Pin_VillageId,
		@Pin_OTPNumber,
		1,
		@Pin_DeviceID,
		@Pin_PreferedLanguageID,
		GETDATE()
	) 
	
	--Returning Inserted UserID And Success Status
	set @Pout_UserID = @v_UserID;
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
					
		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
END


















GO
/****** Object:  StoredProcedure [dbo].[InsertNotificationLog]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert Ticket
-- =============================================
CREATE PROCEDURE [dbo].[InsertNotificationLog]
	-- Add the parameters for the stored procedure here
	@Pin_ApplicationID				int,
	@Pin_NotificationType			varchar(50),
	@Pin_RequestJSON				nvarchar(4000),
	@Pin_ResponseMessage			varchar(5000),
	@Pin_IsSentNotification			bit,
	@Pout_Error						int output
AS
BEGIN
DECLARE @v_ApplicationID		 int;

BEGIN TRY

	BEGIN TRANSACTION    -- Start the transaction	
	--Insert into application table
	INSERT INTO NOTIFICATION_LOGS
	(
		APPLICATION_ID,
		NOTIFICATION_TYPE,
		REQUEST_JSON,
		RESPONSE_MESSAGE,
		IS_SENT_NOTIFICATION,
		CREATED_DATE
	) 
	VALUES
	(
		@Pin_ApplicationID,
		@Pin_NotificationType,
		@Pin_RequestJSON,
		@Pin_ResponseMessage,
		@Pin_IsSentNotification,
		GETDATE()
	) ;

	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION

		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
END



GO
/****** Object:  StoredProcedure [dbo].[InsertTicket]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert Ticket
-- =============================================
CREATE PROCEDURE [dbo].[InsertTicket]
	-- Add the parameters for the stored procedure here
	@Pin_ApplicationId			int,
	@Pin_UserId					int,
	@Pin_TicketName				nvarchar(300),
	@Pin_TicketDesciption		nvarchar(4000),
	@Pin_DefaultImagePath		varchar(500) = null,
	@Pin_TicketCreatedPlatForm	int,
	@Pin_CreatedBy				int,
	@Pout_DeviceID				varchar(50) output,
	@Pout_TicketID				int output,
	@Pout_Error					int output
AS
BEGIN
DECLARE @v_TicketID		int;
Declare @v_UserTypeID	int;
BEGIN TRY
	
	--Check user status
	SELECT @v_UserTypeID = U.USER_TYPE_ID FROM USERS U WHERE ID = @Pin_UserId;

	IF @v_UserTypeID = 4 
	BEGIN
		DECLARE @v_Error int
		EXEC  @v_Error = fnCheckUserStatus @Pin_UserId = @Pin_UserId
		IF @v_Error < 1
		BEGIN
		 SET @Pout_Error = @v_Error
		 RETURN;
		END
	END

	BEGIN TRANSACTION    -- Start the transaction
	--Insert into ticket table
	INSERT INTO TICKETS
	(
		APPLICATION_ID,
		TICKET_NAME,
		TICKET_DESCRIPTION,
		DEFAULT_IMAGE,
		TICKET_STATUS_ID,
		IS_ACTIVE,
		TICKET_OWNER_USER_ID,
		TICKET_CREATED_PLATFORM,
		CREATED_BY,
		CREATED_DATE
	) 
	VALUES
	(
		@Pin_ApplicationId,
		@Pin_TicketName,
		@Pin_TicketDesciption,
		@Pin_DefaultImagePath,
		1,-- Status -> Open
		1, -- Is Active
		@Pin_UserId,
		@Pin_TicketCreatedPlatForm,
		@Pin_CreatedBy,
		GETDATE()
	) ;

	-- Select ticket id
	SELECT @v_TicketID = SCOPE_IDENTITY()
	
	-- Create default image file path 
	IF @Pin_DefaultImagePath IS NOT NULL
	BEGIN
		UPDATE TICKETS 
		SET DEFAULT_IMAGE = CONCAT(@Pin_ApplicationId,'/',@v_TicketID,'/',@Pin_DefaultImagePath)
		WHERE ID = @v_TicketID;
	END;


	--Insert into ticket participant table
	INSERT INTO TICKET_PARTICIPANTS
	(
		TICKET_ID,
		USER_ID,
		CREATED_BY,
		CREATED_DATE
	) 
	VALUES
	(
		@v_TicketID,
		@Pin_UserId,
		@Pin_CreatedBy,
		GETDATE()
	);

	-- Update last created ticket date into user table
	UPDATE USER_DETAILS
	SET LAST_TICKET_SUBMISSION_DATE = GETDATE()
	WHERE USER_ID = @Pin_UserId
	
	-- Mobile User DeviceID
	SELECT @Pout_DeviceID = UD.DEVICE_ID  
	FROM TICKET_PARTICIPANTS TP
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = TP.USER_ID
	INNER JOIN USERS  U ON U.ID = UD.USER_ID
	WHERE TP.TICKET_ID= @v_TicketID AND U.USER_TYPE_ID = 4 -- Mobile User;

	COMMIT TRANSACTION  -- Success!  Commit the transaction

	set @Pout_Error = 1;
	set @Pout_TicketID = @v_TicketID;
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION

		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
END

GO
/****** Object:  StoredProcedure [dbo].[InsertTicketChat]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert Ticket Chat
-- =============================================
CREATE PROCEDURE [dbo].[InsertTicketChat]
	-- Add the parameters for the stored procedure here
	@Pin_TicketId				int,
	@Pin_Ticket_Participant_Id	int,
	@Pin_ReplyMessage			nvarchar(max),
	@Pin_ReplyFilePath			varchar(500) = null,
	@Pin_TicketChatTypeId		int,
	@Pout_DeviceID				nvarchar(max) output,	
	@Pout_ChatID				int output,
	@Pout_Error					int output
AS
BEGIN
DECLARE @v_ParticipantTableID	int;
DECLARE @v_CountID				int;
Declare @v_UserTypeID			int;

BEGIN TRY
		--Check user status
	SELECT @v_UserTypeID = U.USER_TYPE_ID FROM USERS U WHERE ID = @Pin_Ticket_Participant_Id;

	IF @v_UserTypeID = 4 
	BEGIN
		DECLARE @v_Error int
		EXEC  @v_Error = fnCheckUserStatus @Pin_UserId = @Pin_Ticket_Participant_Id
		IF @v_Error < 1
		BEGIN
		 SET @Pout_Error = @v_Error
		 RETURN;
		END
	END

	--Select ParticipantTableID From Participant Table
	SET @v_CountID = (SELECT COUNT(*) FROM TICKET_PARTICIPANTS TP WHERE TP.USER_ID = @Pin_Ticket_Participant_Id AND TP.TICKET_ID = @Pin_TicketId);

	IF @v_CountID > 0
	BEGIN
		SET @v_ParticipantTableID = (SELECT TP.ID FROM TICKET_PARTICIPANTS TP WHERE TP.USER_ID = @Pin_Ticket_Participant_Id AND TP.TICKET_ID = @Pin_TicketId);
	END
	ELSE
	BEGIN
		--Insert into ticket participant table
		INSERT INTO TICKET_PARTICIPANTS
		(
			TICKET_ID,
			USER_ID,
			CREATED_BY,
			CREATED_DATE
		) 
		VALUES
		(
			@Pin_TicketId,
			@Pin_Ticket_Participant_Id,
			@Pin_Ticket_Participant_Id,
			GETDATE()
		);

		SET @v_ParticipantTableID = SCOPE_IDENTITY();
	END


	BEGIN TRANSACTION    -- Start the transaction
	--Insert into ticket table
	INSERT INTO TICKET_CHAT_DETAILS
	(
		TICKET_ID,
		REPLY_MESSAGE,
		REPLIED_DATE,
		REPLY_FILE_PATH,
		TICKET_PARTICIPANT_ID,
		TICKET_CHAT_TYPE_ID,
		CREATED_DATE
	) 
	VALUES
	(
		@Pin_TicketId,
		@Pin_ReplyMessage,
		GETDATE(),
		@Pin_ReplyFilePath,
		@v_ParticipantTableID,
		@Pin_TicketChatTypeId,
		GETDATE()
	) 
	SET @Pout_ChatID = (SELECT SCOPE_IDENTITY());

	-- Mobile User DeviceID
	SELECT @Pout_DeviceID = COALESCE(@Pout_DeviceID + ', ', '') + CAST(UD.DEVICE_ID AS nvarchar(max))   
	FROM TICKET_PARTICIPANTS TP
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = TP.USER_ID
	INNER JOIN USERS  U ON U.ID = UD.USER_ID
	WHERE TP.TICKET_ID= @Pin_TicketId AND U.USER_TYPE_ID = 4 -- Mobile User;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
	set @Pout_Error = 1;
END TRY
BEGIN CATCH
		IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION

		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 

END

GO
/****** Object:  StoredProcedure [dbo].[InsertTicketParticipant]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-07-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert a ticket participant
-- =============================================
CREATE PROCEDURE [dbo].[InsertTicketParticipant]
	-- Add the parameters for the stored procedure here
	@Pin_TicketId			int,
	@Pin_ParticipantID		int,
	@Pin_CreatedBy			int,
	@Pout_Error				int output
AS
DECLARE @v_Count		 int = 0;
BEGIN TRY

	-- Check Already exists or not
	SELECT @v_Count = COUNT(1)
	FROM TICKET_PARTICIPANTS
	WHERE USER_ID = @Pin_ParticipantID AND TICKET_ID = @Pin_TicketId;

	if(@v_Count > 0)
	begin
		set @Pout_Error = -3; -- AlreadyExistRecordFaild
		return;
	end	
	
	SET @v_Count = 0;

	SELECT @v_Count = COUNT(*)
	FROM TICKET_PARTICIPANTS
	WHERE TICKET_ID = @Pin_TicketId;

	--User does not exist 
	if(@v_Count >= 5)
	begin
		set @Pout_Error = -2; -- RelatedRecordFaild
		return;
	end	

	BEGIN TRANSACTION    -- Start the transaction

	INSERT INTO TICKET_PARTICIPANTS
	(
		TICKET_ID,
		USER_ID,
		CREATED_BY,
		CREATED_DATE
	)
	VALUES
	(
		@Pin_TicketId,
		@Pin_ParticipantID,
		@Pin_CreatedBy,
		GETDATE()
	);

	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction

END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH

GO
/****** Object:  StoredProcedure [dbo].[InsertUser]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert mobile user
-- =============================================
CREATE PROCEDURE [dbo].[InsertUser]
	-- Add the parameters for the stored procedure here
	@Pin_ApplicationId		int,
	@Pin_UserTypeId			int,
	@Pin_UserName			varchar(50),
	@Pin_Password			varchar(50),
	@Pin_FullName			nvarchar(100),
	@Pin_PhoneNumber		varchar(50),
	@Pin_Email				varchar(50) = null,
	@Pin_CivilID			varchar(50) = null,
	@Pin_Address			varchar(300) = null,
	@Pin_AreaId				int = null,
	@Pin_WilayatId			int = null,
	@Pin_VillageId			int = null,
	@Pin_CreatedBy			int = null,
	@Pout_UserID			int output,
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_UserID		 int;


BEGIN TRY
BEGIN TRANSACTION    -- Start the transaction	
	--Insert into user table
	INSERT INTO USERS
	(
		USER_NAME,
		PASSWORD,
		USER_TYPE_ID,
		APPLICATION_ID,
		PHONE_NUMBER,
		EMAIL,
		IS_ACTIVE,
		CREATED_BY,
		CREATED_DATE
	) 
	VALUES
	(
		@Pin_UserName,
		@Pin_Password,
		@Pin_UserTypeId,
		@Pin_ApplicationId,
		@Pin_PhoneNumber,
		@Pin_Email,
		1, -- Is Active
		@Pin_CreatedBy,
		GETDATE()
	) 
	
	-- Select inserted user id
	SELECT @v_UserID = SCOPE_IDENTITY()

	--Insert into user table
	INSERT INTO USER_DETAILS
	(
		USER_ID,
		FULL_NAME,
		ADDRESS,
		AREA_ID,
		WILAYAT_ID,
		VILLAGE_ID,
		CREATED_BY,
		CREATED_DATE
	) 
	VALUES
	(
		@v_UserID,
		@Pin_FullName,
		@Pin_Address,
		@Pin_AreaId,
		@Pin_WilayatId,
		@Pin_VillageId,
		@Pin_CreatedBy,
		GETDATE()
	) 
	
	--Returning Inserted UserID And Success Status
	set @Pout_UserID = @v_UserID;
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction

END TRY
BEGIN CATCH
		IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION

		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 

END

















GO
/****** Object:  StoredProcedure [dbo].[ResendOPTNumber]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Resend otp number
-- =============================================
CREATE PROCEDURE [dbo].[ResendOPTNumber]
	-- Add the parameters for the stored procedure here
	@Pin_PhoneNumber		varchar(50),
	@Pin_OTPNumber			int,
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_Count		 int;
DECLARE @v_UserId		 int;

BEGIN TRY
	SET @v_Count = 0;

	SELECT @v_Count = COUNT(1)
	FROM USERS
	WHERE PHONE_NUMBER = @Pin_PhoneNumber;

	--User does not exist 
	if(@v_Count <= 0)
	begin
		set @Pout_Error = -3; -- AlreadyExistRecordFaild
		return;
	end	
	else
	begin
		SELECT @v_UserId = ID
		FROM USERS
		WHERE PHONE_NUMBER = @Pin_PhoneNumber;
	end

	SET @v_Count = 0;

	SELECT @v_Count = NO_OF_TIMES_OTP_SEND
	FROM USER_DETAILS 
	WHERE USER_ID = @v_UserId;
	
	-- Maximum attempt 5 times exceeded
	if(@v_Count > 50)
	begin
		set @Pout_Error = -2; -- RelatedRecordFaild
		return;
	end

	BEGIN TRANSACTION    -- Start the transaction

	SELECT @v_Count = COUNT(1) 
	FROM USER_DETAILS 
	WHERE USER_ID = @v_UserId;

	--Update otp & verified status 
	UPDATE USER_DETAILS
	SET 
		OTP_NUMBER = @Pin_OTPNumber,
		IS_OTP_VALIDATED = 0,
		NO_OF_TIMES_OTP_SEND = NO_OF_TIMES_OTP_SEND + 1
	WHERE USER_ID = @v_UserId
	
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION

		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
END



















GO
/****** Object:  StoredProcedure [dbo].[ResolveTicket]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samh Khalid
-- Create date	: 18-05-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Resolve a ticket
-- =============================================
CREATE PROCEDURE [dbo].[ResolveTicket]
	-- Add the parameters for the stored procedure here
	@Pin_TicketId			int,
	@Pin_TicketStatusID		int,
	@Pin_ModifiedBy			int,	 
	@Pout_Error				int output
	
AS
BEGIN TRY
	BEGIN TRANSACTION    -- Start the transaction

	UPDATE TICKETS
	SET
		TICKET_STATUS_ID = @Pin_TicketStatusID,		 
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_TicketId;
	
	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH





GO
/****** Object:  StoredProcedure [dbo].[SendOTPOnAppReinstall]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Resend otp number
-- =============================================
CREATE PROCEDURE [dbo].[SendOTPOnAppReinstall]
	-- Add the parameters for the stored procedure here
	@Pin_Mobile			nvarchar(50),
	@Pin_OTPNumber			int,
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_Count		 int;

BEGIN TRANSACTION    -- Start the transaction

DECLARE @USERID INT;

SELECT @USERID = ID FROM USERS WHERE PHONE_NUMBER = @Pin_Mobile

BEGIN TRY
	SELECT @v_Count = NO_OF_TIMES_OTP_SEND
	FROM USER_DETAILS 
	WHERE USER_ID = @USERID;
	
	-- Maximum attempt 5 times exceeded
	if(@v_Count > 5)
	begin
		set @Pout_Error = -2;
		return;
	end

	SELECT @v_Count = COUNT(1) 
	FROM USER_DETAILS 
	WHERE USER_ID = @USERID;

	if(@v_Count > 0)
	begin
		--Update otp & verified status 
		UPDATE USER_DETAILS
		SET 
			OTP_NUMBER = @Pin_OTPNumber,
			IS_OTP_VALIDATED = 0,
			NO_OF_TIMES_OTP_SEND = (ISNULL(NO_OF_TIMES_OTP_SEND,0)) + 1
		WHERE USER_ID = @USERID
		
		set @Pout_Error = 1;
	end
	else
	begin
		set @Pout_Error = 0;
	end
END TRY
BEGIN CATCH
		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
IF @@ERROR <> 0
  ROLLBACK
ELSE
  COMMIT   -- Success!  Commit the transaction

END









GO
/****** Object:  StoredProcedure [dbo].[UpdateApplication]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert Ticket
-- =============================================
CREATE PROCEDURE [dbo].[UpdateApplication]
	-- Add the parameters for the stored procedure here
	@Pin_ApplicationId				int,
	@Pin_ApplicationName			varchar(200),
	@Pin_MemberUserID				int,
	@Pin_ApplicationLogoPath		varchar(300),
	@Pin_ApplicationExpiryDate		smalldatetime,
	@Pin_IsActive					bit,
	@Pin_ModifiedBy					int,
	@Pout_Error						int output
AS
BEGIN
DECLARE @v_ApplicationID		 int;

BEGIN TRANSACTION    -- Start the transaction
BEGIN TRY
	
	--Insert into application table
	UPDATE APPLICATIONS
	SET
		APPLICATION_NAME = @Pin_ApplicationName,
		APPLICATION_EXPIRY_DATE = @Pin_ApplicationExpiryDate,
		IS_ACTIVE = @Pin_IsActive,
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_ApplicationId;
	
	-- Create default image file path 
	IF @Pin_ApplicationLogoPath IS NOT NULL
	BEGIN
		UPDATE APPLICATIONS 
		SET APPLICATION_LOGO_PATH = CONCAT(@Pin_ApplicationId,'/',@Pin_ApplicationLogoPath)
		WHERE ID = @Pin_ApplicationId;
	END;

	UPDATE USERS 
	SET  APPLICATION_ID = @Pin_ApplicationId
	WHERE ID = @Pin_MemberUserID;

	
	set @Pout_Error = 1;
END TRY
BEGIN CATCH
		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
IF @@ERROR <> 0
  ROLLBACK
ELSE
  COMMIT   -- Success!  Commit the transaction

END




GO
/****** Object:  StoredProcedure [dbo].[UpdateApplicationSettings]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Update Application Settings
-- =============================================
CREATE PROCEDURE [dbo].[UpdateApplicationSettings]
	-- Add the parameters for the stored procedure here
	@Pin_ApplicationSettingsId		int,
	@Pin_SettingsValue				varchar(500),
	@Pin_ModifiedBy					int,
	@Pout_Error						int output
AS
BEGIN
DECLARE @v_ApplicationID		 int;

BEGIN TRANSACTION    -- Start the transaction
BEGIN TRY
	
	--Insert into application table
	UPDATE APPLICATION_SETTINGS
	SET
		SETTINGS_VALUE = @Pin_SettingsValue,
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_ApplicationSettingsId;
	
	set @Pout_Error = 1;
END TRY
BEGIN CATCH
		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
IF @@ERROR <> 0
  ROLLBACK
ELSE
  COMMIT   -- Success!  Commit the transaction

END




GO
/****** Object:  StoredProcedure [dbo].[UpdateOTPStatus]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samh Khalid
-- Create date	: 18-08-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Update SMS Sent status
-- =============================================
CREATE PROCEDURE [dbo].[UpdateOTPStatus]
	-- Add the parameters for the stored procedure here
	@Pin_UserId				int,
	@Pin_SmsSentStatus		bit,	 
	@Pout_Error				int output
AS
DECLARE @v_IsMobileUser		 int;
DECLARE @V_OTPSentTimes		 int;
BEGIN TRY
	BEGIN TRANSACTION    -- Start the transaction

	-- Update OTP Verified If mobile user type
	SET @v_IsMobileUser = (SELECT COUNT(*) FROM USERS U WHERE U.ID = @Pin_UserId AND U.USER_TYPE_ID = 4); -- Mobile User Type
	SET @V_OTPSentTimes = (SELECT NO_OF_TIMES_OTP_SEND FROM USER_DETAILS UD WHERE UD.USER_ID = @Pin_UserId);

	IF @v_IsMobileUser > 0
	BEGIN
		UPDATE USER_DETAILS
		SET			 
			SMS_SENT_STATUS = @Pin_SmsSentStatus,
			NO_OF_TIMES_OTP_SEND = @V_OTPSentTimes+1,
			SMS_SENT_TRANSACTION_DATE = GETDATE(),
			MODIFIED_DATE = GETDATE()			
		WHERE 
			USER_ID = @Pin_UserId
			 
	END
	
	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH





GO
/****** Object:  StoredProcedure [dbo].[UpdateProfileInformation]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert incident declaration
-- =============================================
CREATE PROCEDURE [dbo].[UpdateProfileInformation]
	-- Add the parameters for the stored procedure here
	@Pin_UserId				int,
	@Pin_FullName			nvarchar(100),
	@Pin_PhoneNumber		varchar(50),
	@Pin_Email				varchar(50) = null,
	@Pin_CivilID			varchar(50),
	@Pin_Address			nvarchar(300) = null,
	@Pin_AreaId				int = null,
	@Pin_WilayatId			int = null,
	@Pin_VillageId			int = null,
	@Pin_TicketSubmissionIntervalDays int = null,
	@Pin_IsTicketSubmissionRestricted int,
	@Pin_ModifiedBy			int = null,
	@Pout_Error				int output
AS
BEGIN TRY
	BEGIN TRANSACTION    -- Start the transaction
	
	--Insert into user table
	UPDATE USERS
	SET
		PHONE_NUMBER = @Pin_PhoneNumber,
		EMAIL = @Pin_Email,
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_UserId;

	UPDATE USER_DETAILS
	SET
		FULL_NAME = @Pin_FullName,
		CIVIL_ID = @Pin_CivilID,
		ADDRESS = @Pin_Address,
		AREA_ID = @Pin_AreaId,
		WILAYAT_ID = @Pin_WilayatId,
		VILLAGE_ID = @Pin_VillageId,
		IS_TICKET_SUBMISSION_RESTRICTED = @Pin_IsTicketSubmissionRestricted,
		TICKET_SUBMISSION_INTERVAL_DAYS = @Pin_TicketSubmissionIntervalDays,
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_UserId;
	
	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH





GO
/****** Object:  StoredProcedure [dbo].[UpdateTicket]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert incident declaration
-- =============================================
CREATE PROCEDURE [dbo].[UpdateTicket]
	-- Add the parameters for the stored procedure here
	@Pin_TicketId			int,
	@Pin_TicketStatusID		int,
	@Pin_IsActive			bit,
	@Pin_StatusRemark		varchar(1000) = null,
	@Pin_ModifiedBy			int = null,
	@Pout_Error				int output
AS
BEGIN TRY
	BEGIN TRANSACTION    -- Start the transaction

	UPDATE TICKETS
	SET
		TICKET_STATUS_ID = @Pin_TicketStatusID,
		IS_ACTIVE = @Pin_IsActive,
		TICKET_STATUS_REMARK = @Pin_StatusRemark,
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_TicketId;
	
	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH





GO
/****** Object:  StoredProcedure [dbo].[UpdateUserPassword]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert incident declaration
-- =============================================
CREATE PROCEDURE [dbo].[UpdateUserPassword]
	-- Add the parameters for the stored procedure here
	@Pin_UserId				int,
	@Pin_Password			varchar(50),
	@Pin_ModifiedBy			int = null,
	@Pout_Error				int output
AS
BEGIN TRY
	BEGIN TRANSACTION    -- Start the transaction

	UPDATE USERS
	SET
		PASSWORD = @Pin_Password,
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_UserId;
	
	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH





GO
/****** Object:  StoredProcedure [dbo].[UpdateUserStatus]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Insert incident declaration
-- =============================================
CREATE PROCEDURE [dbo].[UpdateUserStatus]
	-- Add the parameters for the stored procedure here
	@Pin_UserId				int,
	@Pin_IsActive			bit,
	@Pin_IsBlocked			bit,
	@Pin_IsOTPVerified		bit,
	@Pin_BlockedReason		varchar(1000),
	@Pin_ModifiedBy			int,
	@Pout_Error				int output
AS
DECLARE @v_IsMobileUser		 int;
BEGIN TRY
	BEGIN TRANSACTION    -- Start the transaction

	UPDATE USERS
	SET
		IS_ACTIVE = @Pin_IsActive,
		IS_BLOCKED = @Pin_IsBlocked,
		BLOCKED_REMARKS = @Pin_BlockedReason,
		MODIFIED_BY = @Pin_ModifiedBy,
		MODIFIED_DATE = GETDATE()
	WHERE 
		ID = @Pin_UserId;
	
	-- Update OTP Verified If mobile user type
	SET @v_IsMobileUser = (SELECT COUNT(*) FROM USERS U WHERE U.ID = @Pin_UserId AND U.USER_TYPE_ID = 4); -- Mobile User Type
	IF @v_IsMobileUser > 0
	BEGIN
		UPDATE USER_DETAILS
		SET
			IS_OTP_VALIDATED = @Pin_IsOTPVerified,
			MODIFIED_BY = @Pin_ModifiedBy,
			MODIFIED_DATE = GETDATE()
		WHERE 
			USER_ID = @Pin_UserId;
	END
	
	--Returning Success Status
	set @Pout_Error = 1;

	COMMIT TRANSACTION  -- Success!  Commit the transaction
END TRY
BEGIN CATCH
		 IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION
		
		-- Writing Error Log to database
		declare @errorProc nvarchar(500),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH





GO
/****** Object:  StoredProcedure [dbo].[UserLogin]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UserLogin] 
	-- Add the parameters for the stored procedure here
	@UserName as varchar(50), 
	@Password as varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
			U.ID as [ID], 
			USER_NAME ,
			UT.TYPE USER_TYPE_NAME,
		    U.USER_TYPE_ID,
			U.APPLICATION_ID,
			UD.FULL_NAME
	FROM DBO.USERS U
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	INNER JOIN dbo.USER_TYPES UT ON UT.ID = U.USER_TYPE_ID 
	WHERE U.USER_NAME= @UserName AND U.PASSWORD = @Password
END








GO
/****** Object:  StoredProcedure [dbo].[usp_LogErrors]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Database log insert
-- =============================================
CREATE PROCEDURE [dbo].[usp_LogErrors]
(
	@Pin_SPName  nvarchar(500),
	@Pin_Error_Desc  nvarchar(max)
)
AS
BEGIN
	INSERT INTO DB_Logs
	(
		SP_Name
		,Error_Desc
		,Created_Date
	)
	VALUES
	(
		@Pin_SPName
		,@Pin_Error_Desc
		,GETDATE()
	);		 
END;


















GO
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumber]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Arshad Ashraf
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Validate user entered otp number
-- =============================================
CREATE PROCEDURE [dbo].[ValidateOPTNumber]
	-- Add the parameters for the stored procedure here
	@Pin_PhoneNumber		varchar(50),
	@Pin_OTPNumber			int,
	@Pin_DeviceID			varchar(50),
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_Count		 int;
DECLARE @v_UserId		 int;

BEGIN TRY
	SET @v_Count = 0;

	SELECT @v_Count = COUNT(1)
	FROM USERS
	WHERE PHONE_NUMBER = @Pin_PhoneNumber;

	--User does not exist 
	if(@v_Count <= 0)
	begin
		set @Pout_Error = -3; -- AlreadyExistRecordFaild
		return;
	end	
	else
	begin
		SELECT @v_UserId = ID
		FROM USERS
		WHERE PHONE_NUMBER = @Pin_PhoneNumber;
	end
	
	SET @v_Count = 0;

	SELECT @v_Count = COUNT(1) 
	FROM USER_DETAILS 
	WHERE USER_ID = @v_UserId AND OTP_NUMBER = @Pin_OTPNumber

	if(@v_Count > 0)
	begin
		
		BEGIN TRANSACTION    -- Start the transaction
		--Update otp verified status 
		UPDATE USER_DETAILS
		SET 
			IS_OTP_VALIDATED = 1,
			DEVICE_ID = @Pin_DeviceID
		WHERE USER_ID = @v_UserId
		
		COMMIT TRANSACTION  -- Success!  Commit the transaction
		set @Pout_Error = 1;
	end
	else
	begin
		set @Pout_Error = 0;
	end

END TRY
BEGIN CATCH
		IF XACT_STATE() <> 0 
			ROLLBACK TRANSACTION

		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
END


















GO
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumberReinstall]    Script Date: 30/09/2017 11:59:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samh Khalid
-- Create date	: 18-01-2017
-- Modified date: --
-- Modified By	: --
-- Description	: Validate user entered otp number for App reinstallation context
-- =============================================
CREATE PROCEDURE [dbo].[ValidateOPTNumberReinstall]
	-- Add the parameters for the stored procedure here
	
	@Pin_OTPNumber			int,
	@Pin_MobNumber			varchar(50),
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_Count		 int;

BEGIN TRANSACTION    -- Start the transaction
BEGIN TRY
	
	SELECT @v_Count = COUNT(1) 
	FROM USER_DETAILS UD
	JOIN USERS U ON UD.USER_ID = U.ID
	WHERE UD.OTP_NUMBER = @Pin_OTPNumber
	AND 
	U.PHONE_NUMBER = @Pin_MobNumber

	if(@v_Count > 0)
	begin
		--Update otp verified status 
		UPDATE USER_DETAILS
		SET IS_OTP_VALIDATED = 1
		WHERE OTP_NUMBER = @Pin_OTPNumber
		
		SET @Pout_Error = 1;

		SELECT 
		U.ID,
		U.APPLICATION_ID,
		U.PHONE_NUMBER,
		U.EMAIL,
		U.IS_ACTIVE,
		U.IS_BLOCKED,
		U.BLOCKED_REMARKS,
		UD.FULL_NAME,
		UD.CIVIL_ID,
		UD.ADDRESS,
		UD.IS_OTP_VALIDATED,
		UD.SMS_SENT_STATUS,
		UD.IS_TICKET_SUBMISSION_RESTRICTED,
		UD.TICKET_SUBMISSION_INTERVAL_DAYS,
		UD.LAST_TICKET_SUBMISSION_DATE
		FROM USER_DETAILS UD
		JOIN USERS U ON UD.USER_ID = U.ID
		WHERE UD.OTP_NUMBER = @Pin_OTPNumber
		AND 
		U.PHONE_NUMBER = @Pin_MobNumber

	END
	ELSE
	BEGIN
		SET @Pout_Error = 0;
	end
END TRY
BEGIN CATCH
		-- Writing Error Log to database
		declare @errorProc nvarchar(200),@errroDesc nvarchar(max);
		select @errorProc = ERROR_PROCEDURE();
		select @errroDesc = ERROR_MESSAGE();
		EXEC usp_LogErrors @errorProc,@errroDesc;
		set @Pout_Error = 0;
END CATCH 
IF @@ERROR <> 0
  ROLLBACK
ELSE
  COMMIT   -- Success!  Commit the transaction

END

















GO
