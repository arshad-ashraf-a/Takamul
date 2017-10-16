USE [Takamul]
GO
/****** Object:  UserDefinedFunction [dbo].[fnCheckUserStatus]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_CATEGORIES]    Script Date: 10/16/2017 11:24:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APPLICATION_CATEGORIES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CATEGORY_NAME] [varchar](100) NULL,
	[APPLICATION_ID] [int] NULL,
	[LANGUAGE_ID] [int] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_APPLICATION_CATEGORIES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[APPLICATION_CHANGE_LOGS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_ENTITIES]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_INFO]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_MASTER_SETTINGS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_PRIVILLAGES]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_SETTINGS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_USERS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[APPLICATIONS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
	[ONE_SIGNAL_APP_ID] [varchar](50) NULL,
	[ONE_SIGNAL_AUTH_KEY] [varchar](500) NULL,
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
/****** Object:  Table [dbo].[AREA_MASTER]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[DB_LOGS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[EVENTS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[LANGUAGES]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[MEMBER_INFO]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[NEWS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[NOTIFICATION_LOGS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
	[MOBILE_NUMBERS] [varchar](5000) NULL,
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
/****** Object:  Table [dbo].[TICKET_CHAT_DETAILS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[TICKET_CHAT_TYPES]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[TICKET_PARTICIPANTS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[TICKET_STATUS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[TICKETS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[USER_DETAILS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[USER_TYPES]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[USERS]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[VILLAGE_MASTER]    Script Date: 10/16/2017 11:24:57 PM ******/
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
/****** Object:  Table [dbo].[WILAYAT_MASTER]    Script Date: 10/16/2017 11:24:57 PM ******/
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
INSERT [dbo].[APPLICATION_INFO] ([ID], [APPLICATION_ID], [TITLE], [DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (8, 1, N'تجربة', N'تجربة', 1068, CAST(N'2017-10-13 23:10:00' AS SmallDateTime), NULL, NULL)
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
INSERT [dbo].[APPLICATION_SETTINGS] ([ID], [APPLICATION_ID], [APPLICATION_MASTER_SETTING_ID], [SETTINGS_VALUE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (3, 1, 3, N'http://fileserver.sawa.work/Downloads/apk/1/AlJardani.1.1.apk', NULL, NULL, 1068, CAST(N'2017-10-10 22:16:00' AS SmallDateTime))
GO
INSERT [dbo].[APPLICATION_SETTINGS] ([ID], [APPLICATION_ID], [APPLICATION_MASTER_SETTING_ID], [SETTINGS_VALUE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (4, 2, 1, N'Coming Soon', NULL, NULL, 1068, CAST(N'2017-09-24 20:14:00' AS SmallDateTime))
GO
INSERT [dbo].[APPLICATION_SETTINGS] ([ID], [APPLICATION_ID], [APPLICATION_MASTER_SETTING_ID], [SETTINGS_VALUE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (5, 2, 2, N'Coming Soon', NULL, NULL, 1068, CAST(N'2017-09-24 20:14:00' AS SmallDateTime))
GO
INSERT [dbo].[APPLICATION_SETTINGS] ([ID], [APPLICATION_ID], [APPLICATION_MASTER_SETTING_ID], [SETTINGS_VALUE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (6, 2, 3, N'http://fileserver.sawa.work/Downloads/apk/2/Sawa-app2.1.0.apk', NULL, NULL, 1068, CAST(N'2017-10-10 20:32:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[APPLICATION_SETTINGS] OFF
GO
SET IDENTITY_INSERT [dbo].[APPLICATIONS] ON 

GO
INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO_PATH], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [ONE_SIGNAL_APP_ID], [ONE_SIGNAL_AUTH_KEY], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, N'الجرداني تجريبي', N'1/20170924204027416.png', NULL, CAST(N'2020-12-31 00:00:00' AS SmallDateTime), NULL, N'b585b63f-8254-46e5-93db-b450f87fed09', N'Mjg5ODAwZjktY2FiNy00NmY2LWI1YzEtYjllOTNlYzJlMGUx', 1, 1, CAST(N'2017-07-14 00:34:00' AS SmallDateTime), 1068, CAST(N'2017-10-13 23:04:00' AS SmallDateTime))
GO
INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO_PATH], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [ONE_SIGNAL_APP_ID], [ONE_SIGNAL_AUTH_KEY], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, N'محفوظ ال جمعة', N'2/20171008231323972.png', NULL, CAST(N'2018-10-10 00:00:00' AS SmallDateTime), NULL, N'6142738e-dd46-4ef6-8ac3-a30690d0f28d', N'ZWYzMjJjYTgtZWJhZC00YjRlLTgwOTQtZDQ2M2Y4NDI1Y2Nh', 1, 1068, CAST(N'2017-10-08 08:45:00' AS SmallDateTime), 1068, CAST(N'2017-10-14 18:57:00' AS SmallDateTime))
GO
INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO_PATH], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [ONE_SIGNAL_APP_ID], [ONE_SIGNAL_AUTH_KEY], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (3, N'جمعية المراة العُمانية بقريات ', N'3/20171013231653380.jpg', NULL, CAST(N'2018-10-13 00:00:00' AS SmallDateTime), NULL, NULL, NULL, 1, 1068, CAST(N'2017-10-13 23:17:00' AS SmallDateTime), 1068, CAST(N'2017-10-13 23:19:00' AS SmallDateTime))
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
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'7ecc7eb9-2749-4e7c-91e7-123400857baf', N'Takamul.WEB', N'Tj2Ej2Rw6', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-10-09 18:53:32.437' AS DateTime), 1042, N'<error
  host="Tj2Ej2Rw6"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification()"
  user="admin"
  time="2017-10-09T18:53:32.4364019Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'edde45ec-1c79-4493-b686-705dc9ac74a9', N'Takamul.WEB', N'Tj2Ej2Rw6', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-10-09 18:54:28.120' AS DateTime), 1043, N'<error
  host="Tj2Ej2Rw6"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification()"
  user="admin"
  time="2017-10-09T18:54:28.1193931Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'e061d921-b6f8-419e-b69b-ec4003432285', N'Takamul.WEB', N'NANOCOMPLEX', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'admin', 0, CAST(N'2017-10-09 18:58:08.500' AS DateTime), 1044, N'<error
  host="NANOCOMPLEX"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification() in G:\GitHub\Takamul\Takamul.Portal\Helpers\PushNotification.cs:line 162"
  user="admin"
  time="2017-10-09T18:58:08.5008565Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'335c3dfe-3c05-4d02-885d-aa2a37b34f30', N'Takamul.WEB', N'Tj2Ej2Rw6', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'm01', 0, CAST(N'2017-10-11 06:25:07.203' AS DateTime), 1045, N'<error
  host="Tj2Ej2Rw6"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification()"
  user="m01"
  time="2017-10-11T06:25:07.2038325Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'1677c22d-0daa-4ffa-844c-17c26c77bee2', N'Takamul.WEB', N'Tj2Ej2Rw6', N'System.Net.WebException', N'System', N'The remote server returned an error: (400) Bad Request.', N'Aljardani', 0, CAST(N'2017-10-13 10:09:08.407' AS DateTime), 1046, N'<error
  host="Tj2Ej2Rw6"
  type="System.Net.WebException"
  message="The remote server returned an error: (400) Bad Request."
  source="System"
  detail="System.Net.WebException: The remote server returned an error: (400) Bad Request.&#xD;&#xA;   at System.Net.HttpWebRequest.GetResponse()&#xD;&#xA;   at Takamul.Portal.Helpers.PushNotification.SendPushNotification()"
  user="Aljardani"
  time="2017-10-13T10:09:08.4076269Z" />')
GO
SET IDENTITY_INSERT [dbo].[ELMAH_Error] OFF
GO
SET IDENTITY_INSERT [dbo].[EVENTS] ON 

GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2046, 1, N'غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية', N'غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية', CAST(N'2017-10-02 19:23:00' AS SmallDateTime), N'locat', N'23.5596', N'58.5001', 1, 1, 1068, CAST(N'2017-10-02 19:29:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171002192849461.jpg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2047, 1, N'Event Name', N'Event Name Desc', CAST(N'2017-10-02 19:30:00' AS SmallDateTime), N'Mattrah', N'23.5545', N'58.4843', 1, 1, 1068, CAST(N'2017-10-02 19:31:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171002193049851.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2048, 1, N'Event 1', N'Event 1 Description', CAST(N'2017-10-02 19:34:00' AS SmallDateTime), N'Event 1 Location', N'23.5539', N'58.4624', 1, 1, 1068, CAST(N'2017-10-02 19:35:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171002193455201.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2049, 1, N'Event 2', N'Event 2 Desc', CAST(N'2017-10-02 19:43:00' AS SmallDateTime), N'Event 2 Location', N'23.5294', N'58.4555', 1, 1, 1068, CAST(N'2017-10-02 19:43:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171002194329679.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2050, 1, N'Event 3', N'Event 3 Desc', CAST(N'2017-10-02 22:51:00' AS SmallDateTime), N'Event 3 Location', N'23.5564', N'58.4603', 1, 1, 1068, CAST(N'2017-10-02 22:52:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171002225205374.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2051, 1, N'Event 4', N'Event 4 Desc', CAST(N'2017-10-02 22:53:00' AS SmallDateTime), N'Event 4 Desc', N'23.5791', N'58.4754', 1, 1, 1068, CAST(N'2017-10-02 22:54:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171002225341824.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2052, 1, N'tanveer test 1', N'tanveer desc 1', CAST(N'2017-10-03 22:32:00' AS SmallDateTime), N'hello', N'23.6162', N'58.5069', 1, 1, 1068, CAST(N'2017-10-03 21:02:00' AS SmallDateTime), NULL, NULL, NULL, 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2053, 1, N'tanveer test 1', N'tanveer desc 2', CAST(N'2017-10-03 22:32:00' AS SmallDateTime), N'hi', N'23.6165', N'58.5077', 1, 1, 1068, CAST(N'2017-10-03 21:04:00' AS SmallDateTime), NULL, NULL, NULL, 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2054, 1, N'test event h', N'ghjkl', CAST(N'2017-10-03 22:38:00' AS SmallDateTime), N'he', N'23.6017', N'58.4878', 1, 1, 1068, CAST(N'2017-10-03 21:08:00' AS SmallDateTime), NULL, NULL, NULL, 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2055, 1, N'عقد قران', N'يدعوكم خالي لعقد قرانة 

تجربة', CAST(N'2017-10-03 21:27:00' AS SmallDateTime), N'سبلة الجرادنة ', N'23.2144', N'58.6883', 1, 1, 1125, CAST(N'2017-10-03 21:31:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 00:23:00' AS SmallDateTime), N'1/Events/20171005002310544.jpg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2056, 1, N'المساحة ', N'من الأحد -الخميس: 7,30 صباحا – 2,30 بعد الظهر ( ما عدا شهر رمضان حيث يكون الدوام الرسمي من9 صباحا – 2 بعد الظهر) دوام القطاع الخاص من الأحد -الخميس(حسب نظام الشركات).', CAST(N'2017-10-03 22:03:00' AS SmallDateTime), N'لعيد الوطني', N'23.5495', N'58.4864', 1, 1, 1068, CAST(N'2017-10-03 22:04:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171003220400842.jpg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2057, 1, N'العملة', N'ا – 2,30 بعد الظهر ( ما عدا شهر رمضان حيث يكون الدوام الرسمي من9 صباحا – 2 بعد الظهر) دوام القطاع الخاص من الأحد -الخميس(حسب نظام الشركات).', CAST(N'2017-10-03 22:16:00' AS SmallDateTime), N'معدل النمو السكاني', N'23.5501', N'58.4871', 1, 1, 1068, CAST(N'2017-10-03 22:17:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171003221725208.jpg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2058, 1, N'test notify 3', N'test notify 3 desc', CAST(N'2017-10-04 23:27:00' AS SmallDateTime), N'location name', N'23.5936', N'58.5503', 1, 1, 1068, CAST(N'2017-10-04 23:28:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171004232812253.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2059, 1, N'محاضرة دينية', N'يقيم فريق الفرقان محاضرة دينية بعنوان التواصل وذلك يوم الجمعة بعد صلاة المغرب بجامع عرقي ، الدعوة عامة ( تجربة )', CAST(N'2017-10-06 18:00:00' AS SmallDateTime), N'جامع عرقي ', N'23.2351', N'58.7083', 1, 1, 1125, CAST(N'2017-10-05 15:11:00' AS SmallDateTime), NULL, NULL, NULL, 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2060, 1, N'الخارطة للوصول لموقع المناسبة', N'يمكنك الوصول الي مكان المناسبة من خلال الفتح في الخارطة وسوف يرشد التطبيق من خلال خرائط جوجل الى المكان . ( تجربة جديدة ) ', CAST(N'2017-10-05 15:20:00' AS SmallDateTime), N'دار المناسبات العقبة ', N'23.2213', N'58.7102', 1, 1, 1125, CAST(N'2017-10-05 15:24:00' AS SmallDateTime), 1125, CAST(N'2017-10-07 11:16:00' AS SmallDateTime), NULL, 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2063, 1, N'Siya', N'Khalid', CAST(N'2017-10-07 11:17:00' AS SmallDateTime), N' Test', N'23.8256', N'58.4404', 1, 1, 1125, CAST(N'2017-10-07 11:18:00' AS SmallDateTime), NULL, NULL, NULL, 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2064, 1, N'test ', N'asdfasdfasfd', CAST(N'2017-10-07 11:58:00' AS SmallDateTime), N'asadfasdfasdfasdf', N'23.5262', N'58.4569', 1, 1, 1068, CAST(N'2017-10-07 11:59:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171007115924190.jpg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2065, 1, N'tests aa', N'adsfasdfasdf', CAST(N'2017-10-07 12:01:00' AS SmallDateTime), N'asdfasdfasdfasdfasdf', N'23.5929', N'58.5029', 1, 1, 1068, CAST(N'2017-10-07 12:02:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171007120131368.jpg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2070, 1, N'تجربة تجربة', N'تجربة تجربة تجربة', CAST(N'2017-10-07 14:04:00' AS SmallDateTime), N'تجربة تجربة', N'23.5571', N'58.4981', 1, 1, 1125, CAST(N'2017-10-07 14:05:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171007140443174.jpg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2072, 1, N'تجربة', N'تجربة', CAST(N'2017-10-07 14:18:00' AS SmallDateTime), N'تجربة', N'23.5920', N'58.4674', 1, 1, 1125, CAST(N'2017-10-07 14:19:00' AS SmallDateTime), NULL, NULL, N'1/Events/20171007141835717.jpg', 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2073, 2, N'تجربة ', N'تدشين التطبيق ', CAST(N'2017-10-09 11:43:00' AS SmallDateTime), N'تجربة', N'23.5941', N'58.4723', 1, 1, 1068, CAST(N'2017-10-09 11:45:00' AS SmallDateTime), NULL, NULL, NULL, 1)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2075, 1, N'Siya', N'تجربة ', CAST(N'2017-10-31 20:44:00' AS SmallDateTime), N'تجربة', N'23.5797', N'58.4308', 1, 1, 1068, CAST(N'2017-10-11 20:46:00' AS SmallDateTime), NULL, NULL, NULL, 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [IS_NOTIFY_USER], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2076, 1, N'تجربة ', N'هل تصل اشعارات المناسبات ؟', CAST(N'2017-10-14 21:03:00' AS SmallDateTime), N'تجربة', N'23.7992', N'58.4136', 1, 1, 1068, CAST(N'2017-10-14 21:04:00' AS SmallDateTime), NULL, NULL, NULL, 1)
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
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1015, 1, N'تجربة', N'تجربة', 1125, CAST(N'2017-10-02 23:51:00' AS SmallDateTime), -99, CAST(N'2017-10-12 14:03:00' AS SmallDateTime), 1)
GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1016, 1, N'تجربة', N'تجربة', 1125, CAST(N'2017-10-02 23:51:00' AS SmallDateTime), -99, CAST(N'2017-10-12 14:04:00' AS SmallDateTime), 1)
GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1017, 1, N'تجربة', N'تجربة المحتوى', 1125, CAST(N'2017-10-02 23:52:00' AS SmallDateTime), -99, CAST(N'2017-10-12 14:04:00' AS SmallDateTime), 1)
GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1018, 2, N'الرؤية', N'تجربة ', 1068, CAST(N'2017-10-09 11:49:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1019, 2, N'الرسالة', N'تجربة ', 1068, CAST(N'2017-10-09 11:49:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1020, 2, N'الطموح', N'تجربة ', 1068, CAST(N'2017-10-09 11:50:00' AS SmallDateTime), NULL, NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[MEMBER_INFO] OFF
GO
SET IDENTITY_INSERT [dbo].[NEWS] ON 

GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4170, 1, N'tesr', N'1/News/20171002185442917.png', N'kiouj', 1, 1, CAST(N'2017-10-02 18:54:00' AS SmallDateTime), 1068, CAST(N'2017-10-02 18:55:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4173, 1, N'News 1', N'1/News/20171002225013188.jpg', N'News 1 Desc', 1, 1, CAST(N'2017-10-02 22:49:00' AS SmallDateTime), 1068, CAST(N'2017-10-02 22:50:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4174, 1, N'tanveer news1', N'1/News/20171003210521003.jpg', N'tanveer news 1', 1, 1, CAST(N'2017-10-03 22:35:00' AS SmallDateTime), 1068, CAST(N'2017-10-03 21:05:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4175, 1, N'انقطاع الكهرباء ', N'1/News/20171003212350478.jpg', N'تمت الافادة من شركة الكهرباء بنقطاع التيار الكربائي عن قرية صياء و عرقي يوم الخميس الموافق 5/10/2017 من التاسعة الثامنة صباحا الي الواحدة ظهرا 

يرجى اخذ الاحتياطات اللازمة', 1, 1, CAST(N'2017-10-03 21:21:00' AS SmallDateTime), 1125, CAST(N'2017-10-03 21:24:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4176, 1, N'Notification Test 1', N'1/News/20171003214051803.jpg', N'Notification Test 1 Desc', 1, 1, CAST(N'2017-10-03 21:40:00' AS SmallDateTime), 1068, CAST(N'2017-10-03 21:41:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4178, 1, N'النسخة التجريبية الجديدة ', N'1/News/20171005001834542.jpg', N'تم الانتهاء من النسخة التجريبية الجديدة وجاري فحصها ', 1, 1, CAST(N'2017-10-05 00:15:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 00:19:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4180, 1, N'مسجد صياء الحدرية الجديد', N'1/News/20171005135421863.jpg', N'الحمد لله تم اصدار ملكية الارض المخصصة للمسجد جنب سبلة الجرادنه ', 1, 1, CAST(N'2017-10-05 13:52:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 13:54:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4182, 1, N'التسجيل في ميزة التواصل', N'1/News/20171005142513342.jpg', N'ارجوا من جميع الأخوة الذين قامو بتنزيل التطبيق التسجيل في خانة التواصل لنتمكن من تجربة هذه الخاصية هل تعمل بشكل جيد من عدمه،

شكرا لكم جميعا على تعاونكم في فحص وتجربة التطبيق
', 1, 1, CAST(N'2017-10-05 14:24:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 14:25:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4183, 1, N'Test', N'1/News/20171005213332647.png', N'Test', 1, 1, CAST(N'2017-10-05 21:32:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 21:34:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4184, 1, N'تجربة الاشعارات ', N'1/News/20171005213430465.jpg', N'تجربة ', 1, 1, CAST(N'2017-10-05 21:33:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 21:35:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4187, 1, N'تجربة ', N'1/News/20171007111217185.jpg', N'تجربة الاشعارات ', 1, 1, CAST(N'2017-10-07 11:11:00' AS SmallDateTime), 1125, CAST(N'2017-10-07 11:12:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4188, 1, N'test 123', N'1/News/20171007115112385.jpg', N'test 1234 desc', 1, 1, CAST(N'2017-10-07 11:50:00' AS SmallDateTime), 1068, CAST(N'2017-10-07 11:51:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4189, 1, N'test', N'1/News/20171007134157326.jpg', N' asdfasdfasdf', 0, 1, CAST(N'2017-10-07 13:41:00' AS SmallDateTime), 1068, CAST(N'2017-10-07 13:42:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4190, 1, N'test sdfsdf', N'1/News/20171007134215924.jpg', N'adfasdfasdf', 1, 1, CAST(N'2017-10-07 13:42:00' AS SmallDateTime), 1068, CAST(N'2017-10-07 13:42:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4191, 1, N'test asdfasdf', N'1/News/20171007134255075.jpg', N'asdfasdfasdf', 1, 1, CAST(N'2017-10-07 13:42:00' AS SmallDateTime), 1068, CAST(N'2017-10-07 13:43:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4192, 1, N'Test', N'1/News/20171007134959457.png', N'Test again', 1, 1, CAST(N'2017-10-07 13:49:00' AS SmallDateTime), 1068, CAST(N'2017-10-07 13:50:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4193, 2, N'تطبيق الهواتف الذكية ', N'2/News/20171009104620750.png', N'نقوم حاليا فحص تطبيق الهواتف الذكية لنكون اقرب منكم ونسهل التواصل فيما بيننا ', 1, 1, CAST(N'2017-10-09 10:40:00' AS SmallDateTime), 1140, CAST(N'2017-10-09 10:46:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4194, 1, N'فحص التطبيق', N'1/News/20171009105928110.png', N'السلام عليكم جميعا 

شكرا على مشاركتكم فحص التطبيق ، اتوقع إن كل الميزات تعمل بشكل جيد ، 

سنقوم إن شاء الله بتعديل الترجمة قريبا ،
', 1, 1, CAST(N'2017-10-09 10:55:00' AS SmallDateTime), 1068, CAST(N'2017-10-09 10:59:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4196, 1, N'فحص الاشعارات', N'1/News/20171009222638486.jpg', N'تجربة', 1, 1, CAST(N'2017-10-09 22:26:00' AS SmallDateTime), 1068, CAST(N'2017-10-09 22:27:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4201, 1, N'test', N'1/News/20171009230500587.png', N'asdfasdfasdf', 1, 1, CAST(N'2017-10-09 23:04:00' AS SmallDateTime), 1068, CAST(N'2017-10-09 23:05:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4202, 1, N'test from web', N'1/News/20171010134156947.png', N'test from web desc', 1, 1, CAST(N'2017-10-10 13:42:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 13:42:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4203, 2, N'test asdfasdf', N'2/News/20171010202814363.png', N'asdfasdf', 1, 1, CAST(N'2017-10-10 20:28:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 20:28:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4204, 1, N'jhgjh', N'1/News/20171010225418203.jpg', N'yiuiu', 1, 1, CAST(N'2017-10-10 22:54:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 22:54:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4205, 1, N'testasdfasdf', N'1/News/20171010230130893.jpg', N'asdfasdfasdfasdf', 1, 1, CAST(N'2017-10-10 23:01:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 23:02:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4206, 2, N'تجربه', N'2/News/20171010231428106.jpg', N'تجربة ', 1, 1, CAST(N'2017-10-10 23:13:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 23:14:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4207, 2, N'سعادة الشيخ محفوظ آل جمعه ', N'2/News/20171011102505236.jpg', N'سعادة الشيخ أثناء مداخلة مع وزير الإسكان فى مجلس الشورى ', 1, 1, CAST(N'2017-10-11 10:20:00' AS SmallDateTime), 1140, CAST(N'2017-10-11 10:25:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (4208, 1, N'تجربة ', N'1/News/20171014205918325.png', N'هل تصل الاشعارات بشكل جيد ؟ تجربه ', 1, 1, CAST(N'2017-10-14 20:56:00' AS SmallDateTime), 1068, CAST(N'2017-10-14 20:59:00' AS SmallDateTime), NULL, NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[NEWS] OFF
GO
SET IDENTITY_INSERT [dbo].[NOTIFICATION_LOGS] ON 

GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1036, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"tesr"},"contents":{"en":"kiouj..."},"data":{"News":"News","NewsID":"4170","LanguageID":2},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"7f88e244-f94f-43f8-85c8-c9ca981bac5d","recipients":1}', NULL, 1, CAST(N'2017-10-02 18:55:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1037, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"fi ti","ar":"fi ti"},"contents":{"en":"Admin  تم إنشاء تذكرة","ar":"Admin  تم إنشاء تذكرة"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":1},"include_player_ids":["57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"237b7f97-4cf0-43d6-9d35-857bed778129","recipients":1}', NULL, 1, CAST(N'2017-10-02 19:15:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1038, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"fi ti","ar":"fi ti"},"contents":{"en":"Admin : hi","ar":"Admin : hi"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4190,"TicketChatID":-99,"ReplyMsg":"hi","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"199ef71b-4d9a-406c-bb34-137e1bfd7ca1","recipients":1}', NULL, 1, CAST(N'2017-10-02 19:16:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1039, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"مستوطنون يهود يقتحمون المسجد الأقصى","ar":"مستوطنون يهود يقتحمون المسجد الأقصى"},"contents":{"en":"القدس المحتلة في 2 أكتوبر/ العمانية / اقتحم عشرات من المستوطنين اليهود اليوم ،\r\nالمسجد الأقصى المبارك من جهة باب المغاربة بحراسات مشددة ومعززة من قوات...","ar":"القدس المحتلة في 2 أكتوبر/ العمانية / اقتحم عشرات من المستوطنين اليهود اليوم ،\r\nالمسجد الأقصى المبارك من جهة باب المغاربة بحراسات مشددة ومعززة من قوات..."},"data":{"News":"News","NewsID":"4171","LanguageID":1},"include_player_ids":["57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"8be489a5-2c52-4ed2-a0c7-9bd585d57d12","recipients":1}', NULL, 1, CAST(N'2017-10-02 19:22:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1040, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"ن المستوطنين ","ar":"ن المستوطنين "},"contents":{"en":"ن المستوطنين  ن المستوطنين ...","ar":"ن المستوطنين  ن المستوطنين ..."},"data":{"News":"News","NewsID":"2045","LanguageID":1},"included_segments":["All"]}', N'{"id":"ba1e1d9e-a6b0-457a-ac67-53b2c72e8ebc","recipients":16}', NULL, 1, CAST(N'2017-10-02 19:23:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1041, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية","ar":"غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية"},"contents":{"en":"غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية...","ar":"غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية غدا.. غرفة تجارة وصناعة عمان يسير وفدا تجاريا الى انطاليا التركية..."},"data":{"News":"News","NewsID":"2046","LanguageID":1},"included_segments":["All"]}', N'{"id":"23e7ccc4-44b4-4ada-862c-81728d26f30d","recipients":10}', NULL, 1, CAST(N'2017-10-02 19:29:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1042, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Event Name"},"contents":{"en":"Event Name Desc..."},"data":{"News":"News","NewsID":"2047","LanguageID":2},"included_segments":["All"]}', N'{"id":"c189c3f3-efd4-46d1-b47c-36090e912e63","recipients":10}', NULL, 1, CAST(N'2017-10-02 19:31:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1043, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Event 1"},"contents":{"en":"Event 1 Description..."},"data":{"News":"News","NewsID":"2048","LanguageID":2},"included_segments":["All"]}', N'{"id":"47c4c4db-c129-4e4f-bbe8-f2fd4c3c2f0e","recipients":10}', NULL, 1, CAST(N'2017-10-02 19:36:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1044, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Event 2"},"contents":{"en":"Event 2 Desc..."},"data":{"News":"News","NewsID":"2049","LanguageID":2},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"a04a27fa-55d1-4914-b224-360280f481ab","recipients":1}', NULL, 1, CAST(N'2017-10-02 19:44:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1045, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"Admin : ممتاز ","ar":"Admin : ممتاز "},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"ممتاز ","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"2e093168-7e1b-4897-9485-ea4280019a96","recipients":1}', NULL, 1, CAST(N'2017-10-02 21:03:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1046, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"Admin : Hi","ar":"Admin : Hi"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"Hi","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"24350fa6-a7d2-42cf-9424-2e4bd705cb4f","recipients":1}', NULL, 1, CAST(N'2017-10-02 22:10:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1047, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"Admin : Good","ar":"Admin : Good"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"Good","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"0d5557f2-31ef-4a5c-b1c1-555182d616f2","recipients":1}', NULL, 1, CAST(N'2017-10-02 22:11:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1048, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"الجرداني","ar":"الجرداني"},"contents":{"en":"تطبيق الجرداني الان تحت التجربة و الفحص ...","ar":"تطبيق الجرداني الان تحت التجربة و الفحص ..."},"data":{"News":"News","NewsID":"4172","LanguageID":1},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"679309df-0fb9-4b73-8398-92f4f8844cc5","recipients":2}', NULL, 1, CAST(N'2017-10-02 22:16:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1049, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"Admin : From the admin it''s OK","ar":"Admin : From the admin it''s OK"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"From the admin it''s OK","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"8d0d9c80-4957-4ed3-9e64-431fe1720069","recipients":1}', NULL, 1, CAST(N'2017-10-02 22:44:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1050, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة "},"contents":{"en":"Admin : From the admin it''s OK"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"From the admin it''s OK","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"1cc98075-a215-4f71-9c15-6009a9d9044a","recipients":1}', NULL, 1, CAST(N'2017-10-02 22:44:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1051, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"News 1"},"contents":{"en":"News 1 Desc..."},"data":{"News":"News","NewsID":"4173","LanguageID":2},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"e1d7beef-ff36-4e77-a9cf-4937881b0d74","recipients":1}', NULL, 1, CAST(N'2017-10-02 22:50:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1052, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Event 3"},"contents":{"en":"Event 3 Desc..."},"data":{"News":"News","NewsID":"2050","LanguageID":2},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"d53a542d-5305-468c-8bab-92314b3006e3","recipients":1}', NULL, 1, CAST(N'2017-10-02 22:52:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1053, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Hi"},"contents":{"en":"Admin : Test from web"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4189,"TicketChatID":-99,"ReplyMsg":"Test from web","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"32537625-e28e-48f5-bc49-ed1278ff7bb4","recipients":1}', NULL, 1, CAST(N'2017-10-02 22:53:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1054, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Event 4"},"contents":{"en":"Event 4 Desc..."},"data":{"News":"News","NewsID":"2051","LanguageID":2},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"0191ea26-71ba-4743-a173-4a937910c496","recipients":1}', NULL, 1, CAST(N'2017-10-02 22:54:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1055, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"المشرف العام : test","ar":"المشرف العام : test"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"test","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"86c1b970-4d4e-48c1-a6be-d6d0d75dbb95","recipients":1}', NULL, 1, CAST(N'2017-10-02 23:49:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1056, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة "},"contents":{"en":"المشرف العام : test"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"test","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"ea936e9d-c050-4a0d-86cd-6ae4f1a10f4e","recipients":1}', NULL, 1, CAST(N'2017-10-02 23:49:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1057, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"Admin : Hi all","ar":"Admin : Hi all"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"Hi all","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"d76ae131-feef-45c1-a77c-18a7033e9f4d","recipients":1}', NULL, 1, CAST(N'2017-10-03 00:03:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1058, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة "},"contents":{"en":"Admin : Hi all"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"Hi all","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"d05ff974-f58b-4ec9-b957-84ddbf7a7cef","recipients":1}', NULL, 1, CAST(N'2017-10-03 00:03:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1059, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"المشرف العام : from web its ok","ar":"المشرف العام : from web its ok"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"from web its ok","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"629cd157-7d16-4d40-ad09-8cc23c7e6512","recipients":1}', NULL, 1, CAST(N'2017-10-03 00:03:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1060, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة "},"contents":{"en":"المشرف العام : from web its ok"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"from web its ok","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"47972055-067f-416b-8a69-22f62e61f6f6","recipients":1}', NULL, 1, CAST(N'2017-10-03 00:03:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1061, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"فحص التطبيق","ar":"فحص التطبيق"},"contents":{"en":"المشرف العام  تم إنشاء تذكرة","ar":"المشرف العام  تم إنشاء تذكرة"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":1},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"a082b1cf-cf2e-4223-b9f3-abf873708a4f","recipients":1}', NULL, 1, CAST(N'2017-10-03 00:23:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1062, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Hahs","ar":"Hahs"},"contents":{"en":"Admin : hi","ar":"Admin : hi"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4195,"TicketChatID":-99,"ReplyMsg":"hi","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"3ffb2f1f-f802-42bb-aab0-60f79d5be4bc","recipients":1}', NULL, 1, CAST(N'2017-10-03 20:58:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1063, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"tanveer news1"},"contents":{"en":"tanveer news 1..."},"data":{"News":"News","NewsID":"4174","LanguageID":2},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"38117682-d5cb-4a06-9fde-4a2564d16de4","recipients":1}', NULL, 1, CAST(N'2017-10-03 21:05:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1064, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Hahs","ar":"Hahs"},"contents":{"en":"Admin : he","ar":"Admin : he"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4195,"TicketChatID":-99,"ReplyMsg":"he","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"0ed17dcd-3a6f-406f-9bb0-b9566dd05d19","recipients":1}', NULL, 1, CAST(N'2017-10-03 21:06:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1065, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"السلام عليكم ورحمة الله وبركاتة ","ar":"السلام عليكم ورحمة الله وبركاتة "},"contents":{"en":"المشرف العام : تجربة","ar":"المشرف العام : تجربة"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4196,"TicketChatID":-99,"ReplyMsg":"تجربة","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971"]}', N'{"id":"f436de8b-2aff-4a6a-98a1-347de5735fdb","recipients":1}', NULL, 1, CAST(N'2017-10-03 21:21:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1066, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"انقطاع الكهرباء ","ar":"انقطاع الكهرباء "},"contents":{"en":"تمت الافادة من شركة الكهرباء بنقطاع التيار الكربائي عن قرية صياء و عرقي يوم الخميس الموافق 5/10/2017 من التاسعة الثامنة صباحا الي الواحدة ظهرا \r\n\r\nيرج...","ar":"تمت الافادة من شركة الكهرباء بنقطاع التيار الكربائي عن قرية صياء و عرقي يوم الخميس الموافق 5/10/2017 من التاسعة الثامنة صباحا الي الواحدة ظهرا \r\n\r\nيرج..."},"data":{"News":"News","NewsID":"4175","LanguageID":1},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"294ec14f-8684-4eac-9e14-5005e30829f3","recipients":4}', NULL, 1, CAST(N'2017-10-03 21:24:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1067, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"السلام عليكم ورحمة الله وبركاتة ","ar":"السلام عليكم ورحمة الله وبركاتة "},"contents":{"en":"المشرف العام تحميل ملف.","ar":"المشرف العام تحميل ملف."},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4196,"TicketChatID":-99,"ReplyMsg":"","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"1/4196/20171003213738950.jpg","TicketChatType":3,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971"]}', N'{"id":"12b5fb6e-259f-42d1-8fc8-b4013ebd3863","recipients":1}', NULL, 1, CAST(N'2017-10-03 21:38:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1068, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"السلام عليكم ورحمة الله وبركاتة ","ar":"السلام عليكم ورحمة الله وبركاتة "},"contents":{"en":"المشرف العام : 1","ar":"المشرف العام : 1"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4196,"TicketChatID":-99,"ReplyMsg":"1","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971"]}', N'{"id":"9c465e7e-1eea-4f7d-917c-b49f3a1f63cb","recipients":1}', NULL, 1, CAST(N'2017-10-03 21:38:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1069, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"السلام عليكم ورحمة الله وبركاتة ","ar":"السلام عليكم ورحمة الله وبركاتة "},"contents":{"en":"المشرف العام : 2","ar":"المشرف العام : 2"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4196,"TicketChatID":-99,"ReplyMsg":"2","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971"]}', N'{"id":"516e8bcb-dec2-4f6d-9096-df0365a9b3ea","recipients":1}', NULL, 1, CAST(N'2017-10-03 21:38:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1070, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Notification Test 1"},"contents":{"en":"Notification Test 1 Desc..."},"data":{"News":"News","NewsID":"4176","LanguageID":2},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"4020b505-a195-422c-bfa4-36ad39a2c787","recipients":1}', NULL, 1, CAST(N'2017-10-03 21:41:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1071, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"اختتام أعمال حلقة العمل حول الإعلام وإدارة الأزمات","ar":"اختتام أعمال حلقة العمل حول الإعلام وإدارة الأزمات"},"contents":{"en":"مسقط في 3 أكتوبر /العمانية/ اُختتمت اليوم أعمال حلقة العمل \"الإعلام وإدارة\r\nالأزمات\" التي نظمتها جمعية الصحفيين العمانية وسلطت الضوء على المفاهيم الإع...","ar":"مسقط في 3 أكتوبر /العمانية/ اُختتمت اليوم أعمال حلقة العمل \"الإعلام وإدارة\r\nالأزمات\" التي نظمتها جمعية الصحفيين العمانية وسلطت الضوء على المفاهيم الإع..."},"data":{"News":"News","NewsID":"4177","LanguageID":1},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"4338bbee-5e66-42e3-a84f-a61da984c565","recipients":4}', NULL, 1, CAST(N'2017-10-03 21:57:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1072, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"المساحة ","ar":"المساحة "},"contents":{"en":"من الأحد -الخميس: 7,30 صباحا – 2,30 بعد الظهر ( ما عدا شهر رمضان حيث يكون الدوام الرسمي من9 صباحا – 2 بعد الظهر) دوام القطاع الخاص من الأحد -الخميس(حس...","ar":"من الأحد -الخميس: 7,30 صباحا – 2,30 بعد الظهر ( ما عدا شهر رمضان حيث يكون الدوام الرسمي من9 صباحا – 2 بعد الظهر) دوام القطاع الخاص من الأحد -الخميس(حس..."},"data":{"News":"News","NewsID":"2056","LanguageID":1},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"98f880d8-a264-4462-a3bd-7a115b9dfe60","recipients":4}', NULL, 1, CAST(N'2017-10-03 22:04:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1073, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"العملة","ar":"العملة"},"contents":{"en":"ا – 2,30 بعد الظهر ( ما عدا شهر رمضان حيث يكون الدوام الرسمي من9 صباحا – 2 بعد الظهر) دوام القطاع الخاص من الأحد -الخميس(حسب نظام الشركات)....","ar":"ا – 2,30 بعد الظهر ( ما عدا شهر رمضان حيث يكون الدوام الرسمي من9 صباحا – 2 بعد الظهر) دوام القطاع الخاص من الأحد -الخميس(حسب نظام الشركات)...."},"data":{"Events":"Events","EventID":"2057","LanguageID":1},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"22dc47ee-8533-4045-9264-f8428745dbc1","recipients":4}', NULL, 1, CAST(N'2017-10-03 22:17:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1074, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"المشرف العام  تم إنشاء تذكرة","ar":"المشرف العام  تم إنشاء تذكرة"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":1},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971"]}', N'{"id":"6ddaa00c-15ef-4fb7-aff3-c0cd9e11b5d2","recipients":1}', NULL, 1, CAST(N'2017-10-04 17:18:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1075, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"المشرف العام : تجربة ","ar":"المشرف العام : تجربة "},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4199,"TicketChatID":-99,"ReplyMsg":"تجربة ","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971"]}', N'{"id":"b87dc502-92dc-4f02-bf7a-de5ae70645ba","recipients":1}', NULL, 1, CAST(N'2017-10-04 17:26:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1076, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"المشرف العام : تجربة ","ar":"المشرف العام : تجربة "},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4199,"TicketChatID":-99,"ReplyMsg":"تجربة ","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"df151f25-b6a6-4e2e-9d4f-79dfadffed6d","recipients":1}', NULL, 1, CAST(N'2017-10-04 17:26:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1077, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Nwe "},"contents":{"en":"المشرف العام  has been created a ticket"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":2},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"7d5148fe-5a4f-4d8a-8cb8-ee731e1c2d56","recipients":1}', NULL, 1, CAST(N'2017-10-04 17:30:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1078, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Nwe "},"contents":{"en":"المشرف العام : Hi"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4200,"TicketChatID":-99,"ReplyMsg":"Hi","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["c2e160a8-0124-4555-a6d7-b492e5ed7128"]}', N'{"id":"089ea451-3bca-4afb-9655-4938479a053c","recipients":1}', NULL, 1, CAST(N'2017-10-04 17:30:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1079, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Nwe "},"contents":{"en":"Admin : hi"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4200,"TicketChatID":-99,"ReplyMsg":"hi","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["2dd5a29b-2c59-4789-8dbc-49208ecc5499"]}', N'{"id":"a2fed79a-831e-49f8-955e-8e3659f17f45","recipients":1}', NULL, 1, CAST(N'2017-10-04 23:24:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1080, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Nwe "},"contents":{"en":"Admin : hiii"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4200,"TicketChatID":-99,"ReplyMsg":"hiii","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["2dd5a29b-2c59-4789-8dbc-49208ecc5499"]}', N'{"id":"","recipients":0,"errors":{"invalid_player_ids":["2dd5a29b-2c59-4789-8dbc-49208ecc5499"]}}', NULL, 1, CAST(N'2017-10-04 23:24:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1081, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Tets"},"contents":{"en":"Admin : hii"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4201,"TicketChatID":-99,"ReplyMsg":"hii","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf"]}', N'{"id":"a20d4968-ffc1-4de0-b4d3-fde46e9221d7","recipients":1}', NULL, 1, CAST(N'2017-10-04 23:27:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1082, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"test notify 3"},"contents":{"en":"test notify 3 desc..."},"data":{"Events":"Events","EventID":"2058","LanguageID":2},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"cd8ca140-5112-482e-b98a-4083eaefb7ae","recipients":2}', NULL, 1, CAST(N'2017-10-04 23:28:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1083, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Ticket 1"},"contents":{"en":"Admin  has been created a ticket"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":2},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf"]}', N'{"id":"07046345-7c1f-443a-881a-7b3e18f1b581","recipients":1}', NULL, 1, CAST(N'2017-10-04 23:35:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1084, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"النسخة التجريبية الجديدة ","ar":"النسخة التجريبية الجديدة "},"contents":{"en":"تم الانتهاء من النسخة التجريبية الجديدة وجاري فحصها ...","ar":"تم الانتهاء من النسخة التجريبية الجديدة وجاري فحصها ..."},"data":{"News":"News","NewsID":"4178","LanguageID":1},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"7d987772-fc2a-4ecc-bbb4-b3446c1234f5","recipients":4}', NULL, 1, CAST(N'2017-10-05 00:19:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1085, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"جميل جدا","ar":"جميل جدا"},"contents":{"en":"المشرف العام : شكرا","ar":"المشرف العام : شكرا"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4203,"TicketChatID":-99,"ReplyMsg":"شكرا","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["ab9d0a4f-af0b-42e6-a76b-72560c619971"]}', N'{"id":"5190afbc-bde3-4780-a780-bc91e6219f97","recipients":1}', NULL, 1, CAST(N'2017-10-05 00:53:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1086, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"تجربة الاخبار و الاشعارات ...","ar":"تجربة الاخبار و الاشعارات ..."},"data":{"News":"News","NewsID":"4179","LanguageID":1},"include_player_ids":["0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"065d8131-ccdc-4862-b128-12b84cc184b9","recipients":6}', NULL, 1, CAST(N'2017-10-05 08:58:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1087, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة التطبيق ","ar":"تجربة التطبيق "},"contents":{"en":"المشرف العام  تم إنشاء تذكرة","ar":"المشرف العام  تم إنشاء تذكرة"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":1},"include_player_ids":["0bf656a3-6f1a-49df-b51f-c5420e7608c4"]}', N'{"id":"95740ff0-0427-4dc3-bda7-4a89ea4588c1","recipients":1}', NULL, 1, CAST(N'2017-10-05 13:42:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1088, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة التطبيق ","ar":"تجربة التطبيق "},"contents":{"en":"المشرف العام  تم إنشاء تذكرة","ar":"المشرف العام  تم إنشاء تذكرة"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":1},"include_player_ids":["ff96c122-411f-4280-bf89-3c1c829d79c6"]}', N'{"id":"f854a603-b735-48c5-b7d1-7c7b1b086bfd","recipients":1}', NULL, 1, CAST(N'2017-10-05 13:42:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1089, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة التطبيق ","ar":"تجربة التطبيق "},"contents":{"en":"Admin : asfdbgkjbfdsaj","ar":"Admin : asfdbgkjbfdsaj"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4206,"TicketChatID":-99,"ReplyMsg":"asfdbgkjbfdsaj","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["ff96c122-411f-4280-bf89-3c1c829d79c6"]}', N'{"id":"eddcc47d-f4be-4c0e-ab7e-659a1a1249e9","recipients":1}', NULL, 1, CAST(N'2017-10-05 13:49:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1090, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"مسجد صياء الحدرية الجديد","ar":"مسجد صياء الحدرية الجديد"},"contents":{"en":"الحمد لله تم اصدار ملكية الارض المخصصة للمسجد جنب سبلة الجرادنه ...","ar":"الحمد لله تم اصدار ملكية الارض المخصصة للمسجد جنب سبلة الجرادنه ..."},"data":{"News":"News","NewsID":"4180","LanguageID":1},"include_player_ids":["0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"68b903e9-4f54-42ca-9bea-5267ea493fca","recipients":6}', NULL, 1, CAST(N'2017-10-05 13:54:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1091, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"التسجيل في ميزة التواصل","ar":"التسجيل في ميزة التواصل"},"contents":{"en":"ارجوا من جميع الأخوة الذين قامو بتنزيل التطبيق التسجيل في خانة التواصل لنتمكن من تجربة هذه المزية هل تعمل بشكل جيد من عدمه،\r\n\r\nشكرا لكم جميعا على تعاو...","ar":"ارجوا من جميع الأخوة الذين قامو بتنزيل التطبيق التسجيل في خانة التواصل لنتمكن من تجربة هذه المزية هل تعمل بشكل جيد من عدمه،\r\n\r\nشكرا لكم جميعا على تعاو..."},"data":{"News":"News","NewsID":"4181","LanguageID":1},"include_player_ids":["0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"45bd1e9f-b39e-44b4-bec0-b141013e0455","recipients":6}', NULL, 1, CAST(N'2017-10-05 14:21:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1092, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"التسجيل في ميزة التواصل","ar":"التسجيل في ميزة التواصل"},"contents":{"en":"ارجوا من جميع الأخوة الذين قامو بتنزيل التطبيق التسجيل في خانة التواصل لنتمكن من تجربة هذه الخاصية هل تعمل بشكل جيد من عدمه،\r\n\r\nشكرا لكم جميعا على تعا...","ar":"ارجوا من جميع الأخوة الذين قامو بتنزيل التطبيق التسجيل في خانة التواصل لنتمكن من تجربة هذه الخاصية هل تعمل بشكل جيد من عدمه،\r\n\r\nشكرا لكم جميعا على تعا..."},"data":{"News":"News","NewsID":"4182","LanguageID":1},"include_player_ids":["0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"766660f9-eb29-4833-8ab2-724361a3b29f","recipients":6}', NULL, 1, CAST(N'2017-10-05 14:25:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1093, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Test"},"contents":{"en":"Test..."},"data":{"News":"News","NewsID":"4183","LanguageID":2},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"980959ad-f47e-46ec-8a6b-a5ca734658ec","recipients":2}', NULL, 1, CAST(N'2017-10-05 21:34:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1094, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة الاشعارات ","ar":"تجربة الاشعارات "},"contents":{"en":"تجربة ...","ar":"تجربة ..."},"data":{"News":"News","NewsID":"4184","LanguageID":1},"include_player_ids":["6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"9044570b-f153-4642-9ad7-af176aedb355","recipients":7}', NULL, 1, CAST(N'2017-10-05 21:35:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1095, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربه","ar":"تجربه"},"contents":{"en":"المشرف العام  تم إنشاء تذكرة","ar":"المشرف العام  تم إنشاء تذكرة"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":1},"include_player_ids":["34671413-e78e-4169-bbe0-026f161c05d8"]}', N'{"id":"e1c7fc6c-8225-495d-88c9-ca59b022abb5","recipients":1}', NULL, 1, CAST(N'2017-10-05 22:06:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1096, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربه","ar":"تجربه"},"contents":{"en":"المشرف العام : شكرا لتجربتك التطبيق ","ar":"المشرف العام : شكرا لتجربتك التطبيق "},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4209,"TicketChatID":-99,"ReplyMsg":"شكرا لتجربتك التطبيق ","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["34671413-e78e-4169-bbe0-026f161c05d8"]}', N'{"id":"34b46e26-6dce-42c0-849d-e3fe430565f0","recipients":1}', NULL, 1, CAST(N'2017-10-05 22:07:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1097, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة الاشعارات ","ar":"تجربة الاشعارات "},"contents":{"en":"إلى يوصلة اشعار يبلغني من فضلكم ...","ar":"إلى يوصلة اشعار يبلغني من فضلكم ..."},"data":{"News":"News","NewsID":"4185","LanguageID":1},"include_player_ids":["665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"a3116b93-400d-45a8-a5b1-aeaf21b689cd","recipients":9}', NULL, 1, CAST(N'2017-10-05 22:17:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1098, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"مكرمه صاحب الجلاله ب 25 الف وظيفه ","ar":"مكرمه صاحب الجلاله ب 25 الف وظيفه "},"contents":{"en":"المشرف العام : تجربة الاشعارات للموضوع ","ar":"المشرف العام : تجربة الاشعارات للموضوع "},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4211,"TicketChatID":-99,"ReplyMsg":"تجربة الاشعارات للموضوع ","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["665c644a-f9ee-4371-972e-898638a7b7ba"]}', N'{"id":"4dcfa9a5-8579-4148-83de-6f03f4431233","recipients":1}', NULL, 1, CAST(N'2017-10-05 22:48:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1099, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"اسف على ازعاجكم فقط للتجربه ...","ar":"اسف على ازعاجكم فقط للتجربه ..."},"data":{"News":"News","NewsID":"4186","LanguageID":1},"include_player_ids":["23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"debec3ee-99e3-45a2-98a7-5b08950a9446","recipients":10}', NULL, 1, CAST(N'2017-10-05 22:55:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1100, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"تجربة الاشعارات ...","ar":"تجربة الاشعارات ..."},"data":{"News":"News","NewsID":"4187","LanguageID":1},"include_player_ids":["23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"7228d244-816a-49b8-a1a5-7bf3571ff3d3","recipients":10}', NULL, 1, CAST(N'2017-10-07 11:12:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1101, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"test 123","ar":"test 123"},"contents":{"en":"test 1234 desc...","ar":"test 1234 desc..."},"data":{"News":"News","NewsID":"4188","LanguageID":1},"include_player_ids":["23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141","57a8d6a9-a5db-48e6-9580-1e0639677596"]}', N'{"id":"648d3aec-e567-4d71-ae32-133b7ba01cad","recipients":9,"errors":{"invalid_player_ids":["57a8d6a9-a5db-48e6-9580-1e0639677596"]}}', NULL, 1, CAST(N'2017-10-07 11:52:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1102, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"test ","ar":"test "},"contents":{"en":"asdfasdfasfd...","ar":"asdfasdfasfd..."},"data":{"Events":"Events","EventID":"2064","LanguageID":1},"include_player_ids":["edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"7472740c-3080-48b0-adfb-e29e7b6c0898","recipients":10}', NULL, 1, CAST(N'2017-10-07 12:00:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1103, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"tests aa","ar":"tests aa"},"contents":{"en":"adsfasdfasdf...","ar":"adsfasdfasdf..."},"data":{"Events":"Events","EventID":"2065","LanguageID":1},"include_player_ids":["edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"173bd967-a135-4618-af06-979bb4a5ca4b","recipients":10}', NULL, 1, CAST(N'2017-10-07 12:02:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1104, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"test sdfsdf"},"contents":{"en":"adfasdfasdf..."},"data":{"News":"News","NewsID":"4190","LanguageID":2},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"989b0cf0-8379-4ca1-a0e9-08707f684bd5","recipients":2}', N'98455049,96528555', 1, CAST(N'2017-10-07 13:42:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1105, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"test asdfasdf"},"contents":{"en":"asdfasdfasdf..."},"data":{"News":"News","NewsID":"4191","LanguageID":2},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"a256f0a7-04e1-457d-8578-a0e7e8e07050","recipients":2}', N'98455049,96528555', 1, CAST(N'2017-10-07 13:43:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1106, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Test","ar":"Test"},"contents":{"en":"Test again...","ar":"Test again..."},"data":{"News":"News","NewsID":"4192","LanguageID":1},"include_player_ids":["edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"1a301e63-15e4-4a19-8483-c08b376d2b0e","recipients":10}', N'91534771,95405050,99795221,95727318,93210909,99115995,93293332,94771559,44444444,59595959,99885080', 1, CAST(N'2017-10-07 13:50:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1107, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة تجربة","ar":"تجربة تجربة"},"contents":{"en":"تجربة تجربة تجربة...","ar":"تجربة تجربة تجربة..."},"data":{"Events":"Events","EventID":"2070","LanguageID":1},"include_player_ids":["edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"da3efcd0-dfa1-4199-9d69-a807482015a4","recipients":10}', N'91534771,95405050,99795221,95727318,93210909,99115995,93293332,94771559,44444444,59595959,99885080', 1, CAST(N'2017-10-07 14:05:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1108, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة","ar":"تجربة"},"contents":{"en":"تجربة...","ar":"تجربة..."},"data":{"Events":"Events","EventID":"2072","LanguageID":1},"include_player_ids":["edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"6a987d98-dcc5-4acb-bd1f-a2eda957be16","recipients":10}', N'91534771,95405050,99795221,95727318,93210909,99115995,93293332,94771559,44444444,59595959,99885080', 1, CAST(N'2017-10-07 14:19:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1109, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"Admin : هلا","ar":"Admin : هلا"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4192,"TicketChatID":-99,"ReplyMsg":"هلا","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"5f3e9f49-bea2-44d0-b28c-d5c848d929a0","recipients":1}', N'99885080', 1, CAST(N'2017-10-09 03:40:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1110, 2, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"محمد : ممتاز ","ar":"محمد : ممتاز "},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4215,"TicketChatID":-99,"ReplyMsg":"ممتاز ","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"1726e0bf-315c-4abb-ad2b-aca2633250ce","recipients":1}', N'99885080', 1, CAST(N'2017-10-09 10:39:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1111, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"فحص التطبيق","ar":"فحص التطبيق"},"contents":{"en":"السلام عليكم جميعا \r\n\r\nشكرا على مشاركتكم فحص التطبيق ، اتوقع إن كل الميزات تعمل بشكل جيد ، \r\n\r\nسنقوم إن شاء الله بتعديل الترجمة قريبا ،\r\n...","ar":"السلام عليكم جميعا \r\n\r\nشكرا على مشاركتكم فحص التطبيق ، اتوقع إن كل الميزات تعمل بشكل جيد ، \r\n\r\nسنقوم إن شاء الله بتعديل الترجمة قريبا ،\r\n..."},"data":{"News":"News","NewsID":"4194","LanguageID":1},"include_player_ids":["744b3fa4-f0d1-4861-be7a-89b483feeefe","46997f76-b3f4-4da3-b730-a39ead65e8fc","edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"004533ed-db20-430a-a8d1-259ca6b34bf8","recipients":12}', N'71719993,98800133,91534771,95405050,99795221,95727318,93210909,99115995,93293332,94771559,44444444,59595959,99885080', 1, CAST(N'2017-10-09 10:59:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1112, 2, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"محمد : اجتماع جيد","ar":"محمد : اجتماع جيد"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4215,"TicketChatID":-99,"ReplyMsg":"اجتماع جيد","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"73fffafe-382a-44a4-84b8-081cfd6bbda4","recipients":1}', N'99885080', 1, CAST(N'2017-10-09 19:23:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1113, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة","ar":"تجربة"},"contents":{"en":"المشرف العام  تم إنشاء تذكرة","ar":"المشرف العام  تم إنشاء تذكرة"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":1},"include_player_ids":["46997f76-b3f4-4da3-b730-a39ead65e8fc"]}', N'{"id":"dc7237df-f482-4b41-9622-843c2100c03e","recipients":1}', N'98800133', 1, CAST(N'2017-10-09 22:12:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1114, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"فحص التطبيق","ar":"فحص التطبيق"},"contents":{"en":"Admin : فحص الاشعارات","ar":"Admin : فحص الاشعارات"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4193,"TicketChatID":-99,"ReplyMsg":"فحص الاشعارات","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"","recipients":0,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'99885080', 1, CAST(N'2017-10-09 22:21:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1115, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Zz","ar":"Zz"},"contents":{"en":"Admin : 59","ar":"Admin : 59"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4218,"TicketChatID":-99,"ReplyMsg":"59","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"","recipients":0,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'99885080', 1, CAST(N'2017-10-09 22:23:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1116, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Hii"},"contents":{"en":"Admin : Notification"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4213,"TicketChatID":-99,"ReplyMsg":"Notification","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf"]}', N'{"id":"bdb738c8-38e3-4a61-979e-02ef106be8ab","recipients":1}', N'98455049', 1, CAST(N'2017-10-09 22:25:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1117, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"مكرمه صاحب الجلاله ب 25 الف وظيفه ","ar":"مكرمه صاحب الجلاله ب 25 الف وظيفه "},"contents":{"en":"Admin : Notification","ar":"Admin : Notification"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4211,"TicketChatID":-99,"ReplyMsg":"Notification","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["665c644a-f9ee-4371-972e-898638a7b7ba"]}', N'{"id":"a8dae07d-8910-42cd-85db-3c1e4e37bd54","recipients":1}', N'99795221', 1, CAST(N'2017-10-09 22:26:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1118, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"فحص الاشعارات","ar":"فحص الاشعارات"},"contents":{"en":"تجربة...","ar":"تجربة..."},"data":{"News":"News","NewsID":"4196","LanguageID":1},"include_player_ids":["744b3fa4-f0d1-4861-be7a-89b483feeefe","46997f76-b3f4-4da3-b730-a39ead65e8fc","edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"39d45567-9ad6-4c0d-9995-00c08e8b1816","recipients":11,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'71719993,98800133,91534771,95405050,99795221,95727318,93210909,99115995,93293332,94771559,44444444,59595959,99885080', 1, CAST(N'2017-10-09 22:27:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1119, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Zz","ar":"Zz"},"contents":{"en":"Admin : 88","ar":"Admin : 88"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4218,"TicketChatID":-99,"ReplyMsg":"88","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"","recipients":0,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'99885080', 1, CAST(N'2017-10-09 22:31:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1120, 2, N'news', N'{"app_id":null,"headings":{"en":"test"},"contents":{"en":"asdfasdf..."},"data":{"News":"News","NewsID":"4197","LanguageID":2},"include_player_ids":["67de2a95-adb0-4e2f-b492-3ce1173566a4","f9a9ba4c-4bd8-4e73-a498-bd41c10f74aa"]}', NULL, N'98455042,64676767', 0, CAST(N'2017-10-09 22:54:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1121, 2, N'news', N'{"app_id":"","headings":{"en":"asdfasdf"},"contents":{"en":"asdfasdf..."},"data":{"News":"News","NewsID":"4198","LanguageID":2},"include_player_ids":["67de2a95-adb0-4e2f-b492-3ce1173566a4","f9a9ba4c-4bd8-4e73-a498-bd41c10f74aa"]}', NULL, N'98455042,64676767', 0, CAST(N'2017-10-09 22:54:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1122, 2, N'news', N'{"app_id":"","headings":{"en":"testasdfasdf"},"contents":{"en":"adsfasdfasdf..."},"data":{"News":"News","NewsID":"4199","LanguageID":2},"include_player_ids":["67de2a95-adb0-4e2f-b492-3ce1173566a4","f9a9ba4c-4bd8-4e73-a498-bd41c10f74aa"]}', NULL, N'98455042,64676767', 0, CAST(N'2017-10-09 22:58:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1123, 2, N'news', N'{"app_id":"6142738e-dd46-4ef6-8ac3-a30690d0f28d","headings":{"en":"teawfdasdf"},"contents":{"en":"adfasdfasdf..."},"data":{"News":"News","NewsID":"4200","LanguageID":2},"include_player_ids":["67de2a95-adb0-4e2f-b492-3ce1173566a4","f9a9ba4c-4bd8-4e73-a498-bd41c10f74aa"]}', N'{"id":"8f08c375-89e1-456a-ab45-111cdacdd269","recipients":2}', N'98455042,64676767', 1, CAST(N'2017-10-09 23:00:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1124, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"test"},"contents":{"en":"asdfasdfasdf..."},"data":{"News":"News","NewsID":"4201","LanguageID":2},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"0881c277-64f2-4f8b-a82c-e153e1cebdc6","recipients":2}', N'98455049,96528555', 1, CAST(N'2017-10-09 23:05:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1125, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"مجد التاريخ ","ar":"مجد التاريخ "},"contents":{"en":"Admin : ممتاز ","ar":"Admin : ممتاز "},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4219,"TicketChatID":-99,"ReplyMsg":"ممتاز ","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["665c644a-f9ee-4371-972e-898638a7b7ba"]}', N'{"id":"4cd0cb56-5588-44e6-9fbb-f9a96c1c3592","recipients":1}', N'99795221', 1, CAST(N'2017-10-10 01:23:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1126, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Zz","ar":"Zz"},"contents":{"en":"Admin : Zz","ar":"Admin : Zz"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4218,"TicketChatID":-99,"ReplyMsg":"Zz","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"","recipients":0,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'99885080', 1, CAST(N'2017-10-10 13:35:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1127, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Zz","ar":"Zz"},"contents":{"en":"Admin : 0000000000","ar":"Admin : 0000000000"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4218,"TicketChatID":-99,"ReplyMsg":"0000000000","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"","recipients":0,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'99885080', 1, CAST(N'2017-10-10 13:41:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1128, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"test from web"},"contents":{"en":"test from web desc..."},"data":{"News":"News","NewsID":"4202","LanguageID":2},"include_player_ids":["200fbba0-7571-468e-b646-ce483ee8fdbf","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"7148c29f-2d80-4db2-80e7-a289ca4ec301","recipients":2}', N'98455049,96528555', 1, CAST(N'2017-10-10 13:42:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1129, 2, N'tickets', N'{"app_id":"6142738e-dd46-4ef6-8ac3-a30690d0f28d","headings":{"en":"test asdfasdf"},"contents":{"en":"Admin  has been created a ticket"},"data":{"Tickets":"Tickets","TicketID":"","LanguageID":2},"include_player_ids":["3990667e-37ed-4386-873c-7949e835057d"]}', N'{"id":"ebee07de-8f13-4372-8b3a-384cffc80754","recipients":1}', N'98455049', 1, CAST(N'2017-10-10 20:28:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1130, 2, N'news', N'{"app_id":"6142738e-dd46-4ef6-8ac3-a30690d0f28d","headings":{"en":"test asdfasdf"},"contents":{"en":"asdfasdf..."},"data":{"News":"News","NewsID":"4203","LanguageID":2},"include_player_ids":["3990667e-37ed-4386-873c-7949e835057d","67de2a95-adb0-4e2f-b492-3ce1173566a4","f9a9ba4c-4bd8-4e73-a498-bd41c10f74aa"]}', N'{"id":"70229890-4983-42d2-b03f-dfc9ccfcc209","recipients":3}', N'98455049,98455042,64676767', 1, CAST(N'2017-10-10 20:28:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1131, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"jhgjh"},"contents":{"en":"yiuiu..."},"data":{"News":"News","NewsID":"4204","LanguageID":2},"include_player_ids":["72769a78-099e-4610-a928-889be3560f5d","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"64eb2364-8c3f-415d-888e-73f08d5bbbb4","recipients":1}', N'98455049,96528555', 1, CAST(N'2017-10-10 22:54:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1132, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"testasdfasdf"},"contents":{"en":"asdfasdfasdfasdf..."},"data":{"News":"News","NewsID":"4205","LanguageID":2},"include_player_ids":["72769a78-099e-4610-a928-889be3560f5d","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"8d2a42e4-a131-4210-81c9-b349b9121feb","recipients":1}', N'98455049,96528555', 1, CAST(N'2017-10-10 23:02:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1133, 2, N'news', N'{"app_id":"6142738e-dd46-4ef6-8ac3-a30690d0f28d","headings":{"en":"تجربه","ar":"تجربه"},"contents":{"en":"تجربة ...","ar":"تجربة ..."},"data":{"News":"News","NewsID":"4206","LanguageID":1},"include_player_ids":["7a1ac1a1-fd65-4fb1-b007-7da1d5ce96e2"]}', N'{"id":"0eb0014c-d3fc-41a6-b91c-10638b0db964","recipients":1}', N'99885080', 1, CAST(N'2017-10-10 23:14:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1134, 2, N'news', N'{"app_id":"","headings":{"en":"سعادة الشيخ محفوظ آل جمعه ","ar":"سعادة الشيخ محفوظ آل جمعه "},"contents":{"en":"سعادة الشيخ أثناء مداخلة مع وزير الإسكان فى مجلس الشورى ...","ar":"سعادة الشيخ أثناء مداخلة مع وزير الإسكان فى مجلس الشورى ..."},"data":{"News":"News","NewsID":"4207","LanguageID":1},"include_player_ids":["7a1ac1a1-fd65-4fb1-b007-7da1d5ce96e2"]}', NULL, N'99885080', 0, CAST(N'2017-10-11 10:25:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1135, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Siya"},"contents":{"en":"تجربة ..."},"data":{"Events":"Events","EventID":"2075","LanguageID":2},"include_player_ids":["72769a78-099e-4610-a928-889be3560f5d","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154"]}', N'{"id":"b1f547ee-a204-47b5-80e7-02bbf6f5b8e8","recipients":1}', N'98455049,96528555', 1, CAST(N'2017-10-11 20:46:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1136, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"مجد التاريخ ","ar":"مجد التاريخ "},"contents":{"en":"Admin : هل توصلك اشعارات ؟","ar":"Admin : هل توصلك اشعارات ؟"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4219,"TicketChatID":-99,"ReplyMsg":"هل توصلك اشعارات ؟","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["665c644a-f9ee-4371-972e-898638a7b7ba"]}', N'{"id":"3a50755c-4352-473f-bba3-804db3486bb2","recipients":1}', N'99795221', 1, CAST(N'2017-10-13 01:55:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1137, 1, N'tickets', N'{"app_id":"","headings":{"en":"مجد التاريخ ","ar":"مجد التاريخ "},"contents":{"en":"الجرداني : ممتاز الحمد لله","ar":"الجرداني : ممتاز الحمد لله"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4219,"TicketChatID":-99,"ReplyMsg":"ممتاز الحمد لله","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["665c644a-f9ee-4371-972e-898638a7b7ba"]}', NULL, N'99795221', 0, CAST(N'2017-10-13 14:09:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1138, 1, N'news', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"هل تصل الاشعارات بشكل جيد ؟ تجربه ...","ar":"هل تصل الاشعارات بشكل جيد ؟ تجربه ..."},"data":{"News":"News","NewsID":"4208","LanguageID":1},"include_player_ids":["744b3fa4-f0d1-4861-be7a-89b483feeefe","46997f76-b3f4-4da3-b730-a39ead65e8fc","edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"5d7a42be-2da9-43ef-a7a9-ac2ec938f927","recipients":11,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'71719993,98800133,91534771,95405050,99795221,95727318,93210909,99115995,93293332,94771559,44444444,59595959,99885080', 1, CAST(N'2017-10-14 20:59:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1139, 1, N'events', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة ","ar":"تجربة "},"contents":{"en":"هل تصل اشعارات المناسبات ؟...","ar":"هل تصل اشعارات المناسبات ؟..."},"data":{"Events":"Events","EventID":"2076","LanguageID":1},"include_player_ids":["744b3fa4-f0d1-4861-be7a-89b483feeefe","46997f76-b3f4-4da3-b730-a39ead65e8fc","edbe4b31-aa08-4771-b132-e15aac91deea","23908131-18d8-4b70-b100-211d6de00c89","665c644a-f9ee-4371-972e-898638a7b7ba","34671413-e78e-4169-bbe0-026f161c05d8","6a6f16fa-47fc-46e8-930c-df63dbbbea2e","0bf656a3-6f1a-49df-b51f-c5420e7608c4","ff96c122-411f-4280-bf89-3c1c829d79c6","ab9d0a4f-af0b-42e6-a76b-72560c619971","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154","393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"6392d856-2400-423d-9468-0ade7c9088ad","recipients":11,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'71719993,98800133,91534771,95405050,99795221,95727318,93210909,99115995,93293332,94771559,44444444,59595959,99885080', 1, CAST(N'2017-10-14 21:04:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1140, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"تجربة جديدة في الاصدار الجديد ","ar":"تجربة جديدة في الاصدار الجديد "},"contents":{"en":"Admin : Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the ...","ar":"Admin : Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the ..."},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4223,"TicketChatID":-99,"ReplyMsg":"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}', N'{"id":"","recipients":0,"errors":{"invalid_player_ids":["393e72dd-bb3b-4958-a793-75c0cf981141"]}}', N'99885080', 1, CAST(N'2017-10-16 20:42:00' AS SmallDateTime))
GO
INSERT [dbo].[NOTIFICATION_LOGS] ([ID], [APPLICATION_ID], [NOTIFICATION_TYPE], [REQUEST_JSON], [RESPONSE_MESSAGE], [MOBILE_NUMBERS], [IS_SENT_NOTIFICATION], [CREATED_DATE]) VALUES (1141, 1, N'tickets', N'{"app_id":"b585b63f-8254-46e5-93db-b450f87fed09","headings":{"en":"Hii"},"contents":{"en":"Admin : test"},"content_available":true,"data":{"TicketChats":"TicketChats","TicketID":4213,"TicketChatID":-99,"ReplyMsg":"test","ReplyDate":"0001-01-01T00:00:00","RemoteFilePath":"","TicketChatType":1,"UserId":1,"Username":"Admin123","Typename":""},"include_player_ids":["72769a78-099e-4610-a928-889be3560f5d"]}', N'{"id":"","recipients":0,"errors":["All included players are not subscribed"]}', N'98455049', 1, CAST(N'2017-10-16 20:47:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[NOTIFICATION_LOGS] OFF
GO
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_DETAILS] ON 

GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4897, 4190, N'hi', CAST(N'2017-10-02 19:16:00' AS SmallDateTime), NULL, 4270, 1, NULL, CAST(N'2017-10-02 19:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4898, 4191, N'RR', CAST(N'2017-10-02 20:51:00' AS SmallDateTime), NULL, 4272, 1, NULL, CAST(N'2017-10-02 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4899, 4191, N'No name', CAST(N'2017-10-02 20:52:00' AS SmallDateTime), NULL, 4271, 1, NULL, CAST(N'2017-10-02 20:52:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4900, 4192, N'ممتاز ', CAST(N'2017-10-02 21:03:00' AS SmallDateTime), NULL, 4274, 1, NULL, CAST(N'2017-10-02 21:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4901, 4192, N'لم يصل الاشعار ', CAST(N'2017-10-02 21:04:00' AS SmallDateTime), NULL, 4273, 1, NULL, CAST(N'2017-10-02 21:04:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4902, 4192, N'Hi', CAST(N'2017-10-02 22:10:00' AS SmallDateTime), NULL, 4274, 1, NULL, CAST(N'2017-10-02 22:10:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4903, 4192, N'Good', CAST(N'2017-10-02 22:11:00' AS SmallDateTime), NULL, 4274, 1, NULL, CAST(N'2017-10-02 22:11:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4904, 4192, N'Test the push notifications', CAST(N'2017-10-02 22:20:00' AS SmallDateTime), NULL, 4273, 1, NULL, CAST(N'2017-10-02 22:20:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4905, 4192, N'From the admin it''s OK', CAST(N'2017-10-02 22:44:00' AS SmallDateTime), NULL, 4274, 1, NULL, CAST(N'2017-10-02 22:44:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4906, 4189, N'Test from web', CAST(N'2017-10-02 22:53:00' AS SmallDateTime), NULL, 4276, 1, NULL, CAST(N'2017-10-02 22:53:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4907, 4192, N'test', CAST(N'2017-10-02 23:49:00' AS SmallDateTime), NULL, 4277, 1, NULL, CAST(N'2017-10-02 23:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4908, 4192, N'Brother did you get any push notifications', CAST(N'2017-10-02 23:50:00' AS SmallDateTime), NULL, 4273, 1, NULL, CAST(N'2017-10-02 23:50:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4909, 4192, N'Hi', CAST(N'2017-10-03 00:00:00' AS SmallDateTime), NULL, 4273, 1, NULL, CAST(N'2017-10-03 00:00:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4910, 4192, N'Hi all', CAST(N'2017-10-03 00:03:00' AS SmallDateTime), NULL, 4274, 1, NULL, CAST(N'2017-10-03 00:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4911, 4192, N'from web its ok', CAST(N'2017-10-03 00:03:00' AS SmallDateTime), NULL, 4277, 1, NULL, CAST(N'2017-10-03 00:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4912, 4193, N'جيد ', CAST(N'2017-10-03 00:23:00' AS SmallDateTime), NULL, 4278, 1, NULL, CAST(N'2017-10-03 00:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4913, 4194, N'hi', CAST(N'2017-10-03 20:47:00' AS SmallDateTime), NULL, 4280, 1, NULL, CAST(N'2017-10-03 20:47:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4914, 4194, N'hello', CAST(N'2017-10-03 20:48:00' AS SmallDateTime), NULL, 4280, 1, NULL, CAST(N'2017-10-03 20:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4915, 4195, N'hi', CAST(N'2017-10-03 20:58:00' AS SmallDateTime), NULL, 4282, 1, NULL, CAST(N'2017-10-03 20:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4916, 4195, N'he', CAST(N'2017-10-03 21:06:00' AS SmallDateTime), NULL, 4282, 1, NULL, CAST(N'2017-10-03 21:06:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4917, 4196, N'شكرا خالي على تجربة التطبيق', CAST(N'2017-10-03 21:19:00' AS SmallDateTime), NULL, 4284, 1, NULL, CAST(N'2017-10-03 21:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4918, 4196, N'تجربة', CAST(N'2017-10-03 21:21:00' AS SmallDateTime), NULL, 4284, 1, NULL, CAST(N'2017-10-03 21:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4919, 4196, N'', CAST(N'2017-10-03 21:38:00' AS SmallDateTime), N'1/4196/20171003213738950.jpg', 4284, 3, NULL, CAST(N'2017-10-03 21:38:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4920, 4196, N'1', CAST(N'2017-10-03 21:38:00' AS SmallDateTime), NULL, 4284, 1, NULL, CAST(N'2017-10-03 21:38:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4921, 4196, N'2', CAST(N'2017-10-03 21:38:00' AS SmallDateTime), NULL, 4284, 1, NULL, CAST(N'2017-10-03 21:38:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4922, 4196, N'1', CAST(N'2017-10-03 21:39:00' AS SmallDateTime), NULL, 4283, 1, NULL, CAST(N'2017-10-03 21:39:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4923, 4196, N'هلا خالي ', CAST(N'2017-10-03 21:41:00' AS SmallDateTime), NULL, 4285, 1, NULL, CAST(N'2017-10-03 21:41:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4924, 4199, N'تجربة ', CAST(N'2017-10-04 17:26:00' AS SmallDateTime), NULL, 4289, 1, NULL, CAST(N'2017-10-04 17:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4925, 4199, N'جيد توصل الاشعارات من المشرف العام ', CAST(N'2017-10-04 17:27:00' AS SmallDateTime), NULL, 4290, 1, NULL, CAST(N'2017-10-04 17:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4926, 4200, N'Hi', CAST(N'2017-10-04 17:30:00' AS SmallDateTime), NULL, 4292, 1, NULL, CAST(N'2017-10-04 17:30:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4927, 4200, N'Jgh', CAST(N'2017-10-04 22:56:00' AS SmallDateTime), NULL, 4291, 1, NULL, CAST(N'2017-10-04 22:56:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4928, 4190, N'Hi', CAST(N'2017-10-04 22:57:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-04 22:57:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4929, 4200, N'hi', CAST(N'2017-10-04 23:24:00' AS SmallDateTime), NULL, 4293, 1, NULL, CAST(N'2017-10-04 23:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4930, 4200, N'hiii', CAST(N'2017-10-04 23:24:00' AS SmallDateTime), NULL, 4293, 1, NULL, CAST(N'2017-10-04 23:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4931, 4201, N'hii', CAST(N'2017-10-04 23:27:00' AS SmallDateTime), NULL, 4295, 1, NULL, CAST(N'2017-10-04 23:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4932, 4202, N'Hii', CAST(N'2017-10-04 23:35:00' AS SmallDateTime), NULL, 4296, 1, NULL, CAST(N'2017-10-04 23:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4933, 4202, N'', CAST(N'2017-10-04 23:36:00' AS SmallDateTime), N'1/4202/20171004233540573.png', 4296, 2, NULL, CAST(N'2017-10-04 23:36:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4934, 4203, N'شكرا', CAST(N'2017-10-05 00:53:00' AS SmallDateTime), NULL, 4298, 1, NULL, CAST(N'2017-10-05 00:53:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4935, 4204, N'Hii', CAST(N'2017-10-05 07:18:00' AS SmallDateTime), NULL, 4299, 1, NULL, CAST(N'2017-10-05 07:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4936, 4206, N'شكرا بدر على مشاركتنا تجربة فحص التطبيق', CAST(N'2017-10-05 13:43:00' AS SmallDateTime), NULL, 4302, 1, NULL, CAST(N'2017-10-05 13:43:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4937, 4205, N'شكرا عمر على مشاركتنا تجربة فحص التطبيق', CAST(N'2017-10-05 13:44:00' AS SmallDateTime), NULL, 4303, 1, NULL, CAST(N'2017-10-05 13:44:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4938, 4206, N'asfdbgkjbfdsaj', CAST(N'2017-10-05 13:49:00' AS SmallDateTime), NULL, 4304, 1, NULL, CAST(N'2017-10-05 13:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4939, 4206, N'العفوا ولد العم', CAST(N'2017-10-05 14:11:00' AS SmallDateTime), NULL, 4301, 1, NULL, CAST(N'2017-10-05 14:11:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4940, 4205, N'اهلا', CAST(N'2017-10-05 14:29:00' AS SmallDateTime), NULL, 4300, 1, NULL, CAST(N'2017-10-05 14:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4941, 4206, N'ممتاز بدر حاول تجرب كل شي اذا صادفتك مشكلة خبرني ', CAST(N'2017-10-05 14:39:00' AS SmallDateTime), NULL, 4302, 1, NULL, CAST(N'2017-10-05 14:39:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4942, 4205, N'جرب من فضلك كل الميزات و خبرني اذا صادفك اي شي ما شغال بشكل جيد ', CAST(N'2017-10-05 14:45:00' AS SmallDateTime), NULL, 4303, 1, NULL, CAST(N'2017-10-05 14:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4943, 4207, N'شكرا اخي حمد على المشاركة في فريق عمل الجرداني ', CAST(N'2017-10-05 14:48:00' AS SmallDateTime), NULL, 4306, 1, NULL, CAST(N'2017-10-05 14:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4944, 4207, N'كل التوفيق', CAST(N'2017-10-05 14:48:00' AS SmallDateTime), NULL, 4305, 1, NULL, CAST(N'2017-10-05 14:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4945, 4207, N'بجودكم نصنع الكثير ان شاء الله ', CAST(N'2017-10-05 14:49:00' AS SmallDateTime), NULL, 4306, 1, NULL, CAST(N'2017-10-05 14:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4946, 4207, N'هل يوصلك اشعار ولا بعده فيه مشكلة ؟؟', CAST(N'2017-10-05 14:50:00' AS SmallDateTime), NULL, 4306, 1, NULL, CAST(N'2017-10-05 14:50:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4947, 4208, N'شكرا اخي خالد على مشاركتنا فحص التطبيق ، بتعاونكم سنطور هذا التطبيق ', CAST(N'2017-10-05 15:13:00' AS SmallDateTime), NULL, 4308, 1, NULL, CAST(N'2017-10-05 15:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4948, 4208, N'بارك الله فيكم
وإلي الإمام دوما ', CAST(N'2017-10-05 15:14:00' AS SmallDateTime), NULL, 4307, 1, NULL, CAST(N'2017-10-05 15:14:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4949, 4208, N'حاول من تفضلك تجرب كل الميزات وخبرني اذا فيه شي ما يعمل بشكل جيد  ', CAST(N'2017-10-05 15:15:00' AS SmallDateTime), NULL, 4308, 1, NULL, CAST(N'2017-10-05 15:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4950, 4207, N'لا تصل للأسف ', CAST(N'2017-10-05 15:45:00' AS SmallDateTime), NULL, 4305, 1, NULL, CAST(N'2017-10-05 15:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4951, 4207, N'تجربة الاشعارات ', CAST(N'2017-10-05 21:31:00' AS SmallDateTime), NULL, 4306, 1, NULL, CAST(N'2017-10-05 21:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4952, 4209, N'شكرا لتجربتك التطبيق ', CAST(N'2017-10-05 22:07:00' AS SmallDateTime), NULL, 4311, 1, NULL, CAST(N'2017-10-05 22:07:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4953, 4210, N'هلا حسن هل توصلك اشعارات الان ؟', CAST(N'2017-10-05 22:09:00' AS SmallDateTime), NULL, 4312, 1, NULL, CAST(N'2017-10-05 22:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4954, 4210, N'مشاركتك أخي حسن إضافة لتطوير التطبيق ', CAST(N'2017-10-05 22:27:00' AS SmallDateTime), NULL, 4312, 1, NULL, CAST(N'2017-10-05 22:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4955, 4207, N'هل تصل الاشعارات ؟', CAST(N'2017-10-05 22:28:00' AS SmallDateTime), NULL, 4306, 1, NULL, CAST(N'2017-10-05 22:28:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4956, 4210, N'تجربه ', CAST(N'2017-10-05 22:42:00' AS SmallDateTime), NULL, 4313, 1, NULL, CAST(N'2017-10-05 22:42:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4957, 4211, N'السلام عليكم ', CAST(N'2017-10-05 22:48:00' AS SmallDateTime), NULL, 4314, 1, NULL, CAST(N'2017-10-05 22:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4958, 4211, N'تجربة الاشعارات للموضوع ', CAST(N'2017-10-05 22:48:00' AS SmallDateTime), NULL, 4315, 1, NULL, CAST(N'2017-10-05 22:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4959, 4201, N'Ffff', CAST(N'2017-10-06 00:37:00' AS SmallDateTime), NULL, 4294, 1, NULL, CAST(N'2017-10-06 00:37:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4960, 4201, N'Cfvfcff ft ft ggg', CAST(N'2017-10-06 00:38:00' AS SmallDateTime), NULL, 4294, 1, NULL, CAST(N'2017-10-06 00:38:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4961, 4190, N'Hiii', CAST(N'2017-10-06 00:39:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:39:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4962, 4201, N'Hiii', CAST(N'2017-10-06 00:40:00' AS SmallDateTime), NULL, 4294, 1, NULL, CAST(N'2017-10-06 00:40:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4963, 4190, N'Hiii', CAST(N'2017-10-06 00:40:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:40:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4964, 4190, N'Hii', CAST(N'2017-10-06 00:42:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:42:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4965, 4190, N'Hiii', CAST(N'2017-10-06 00:45:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4966, 4190, N'Hi', CAST(N'2017-10-06 00:45:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4967, 4190, N'How are you', CAST(N'2017-10-06 00:45:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4968, 4190, N'From me', CAST(N'2017-10-06 00:45:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4969, 4190, N'Hfgh', CAST(N'2017-10-06 00:45:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4970, 4190, N'Hggh', CAST(N'2017-10-06 00:45:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4971, 4190, N'Fded', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4972, 4190, N'Jgggg', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4973, 4190, N'Fdeff', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4974, 4190, N'Ugghh', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4975, 4190, N'Fewee', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4976, 4190, N'Hgfu', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4977, 4190, N'Hgggh', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4978, 4190, N'Fsee', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4979, 4190, N'Ucyhch', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4980, 4190, N'Gssdf', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4981, 4190, N'Ughiii', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4982, 4190, N'Fdsdg', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4983, 4190, N'Igguhf', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4269, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4984, 4190, N'Fssfgy', CAST(N'2017-10-06 00:46:00' AS SmallDateTime), NULL, 4316, 1, NULL, CAST(N'2017-10-06 00:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4985, 4205, N'الخريطة شغاله', CAST(N'2017-10-07 14:08:00' AS SmallDateTime), NULL, 4300, 1, NULL, CAST(N'2017-10-07 14:08:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4986, 4213, N'Ggff', CAST(N'2017-10-07 16:12:00' AS SmallDateTime), NULL, 4318, 1, NULL, CAST(N'2017-10-07 16:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4987, 4213, N'Hfrg', CAST(N'2017-10-07 16:12:00' AS SmallDateTime), NULL, 4318, 1, NULL, CAST(N'2017-10-07 16:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4988, 4213, N'Gfrd', CAST(N'2017-10-07 16:12:00' AS SmallDateTime), NULL, 4318, 1, NULL, CAST(N'2017-10-07 16:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4989, 4213, N'Gehhu', CAST(N'2017-10-07 16:12:00' AS SmallDateTime), NULL, 4318, 1, NULL, CAST(N'2017-10-07 16:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4990, 4213, N'Feet thief', CAST(N'2017-10-07 16:12:00' AS SmallDateTime), NULL, 4318, 1, NULL, CAST(N'2017-10-07 16:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4991, 4213, N'', CAST(N'2017-10-07 16:13:00' AS SmallDateTime), N'1/4213/20171007161246616.png', 4318, 2, NULL, CAST(N'2017-10-07 16:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4992, 4213, N'Gg', CAST(N'2017-10-07 16:13:00' AS SmallDateTime), NULL, 4318, 1, NULL, CAST(N'2017-10-07 16:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4993, 4213, N'Gregf', CAST(N'2017-10-07 16:13:00' AS SmallDateTime), NULL, 4318, 1, NULL, CAST(N'2017-10-07 16:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4994, 4213, N'Bvffg', CAST(N'2017-10-07 16:13:00' AS SmallDateTime), NULL, 4318, 1, NULL, CAST(N'2017-10-07 16:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4995, 4192, N'هلا', CAST(N'2017-10-09 03:40:00' AS SmallDateTime), NULL, 4274, 1, NULL, CAST(N'2017-10-09 03:40:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4996, 4215, N'ممتاز ', CAST(N'2017-10-09 10:39:00' AS SmallDateTime), NULL, 4321, 1, NULL, CAST(N'2017-10-09 10:39:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4997, 4215, N'شكرا ', CAST(N'2017-10-09 10:40:00' AS SmallDateTime), NULL, 4320, 1, NULL, CAST(N'2017-10-09 10:40:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4998, 4215, N'اجتماع جيد', CAST(N'2017-10-09 19:23:00' AS SmallDateTime), NULL, 4321, 1, NULL, CAST(N'2017-10-09 19:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4999, 4217, N'شكرا على مشاركتنا تجربة وفحص التطبيق ', CAST(N'2017-10-09 22:13:00' AS SmallDateTime), NULL, 4324, 1, NULL, CAST(N'2017-10-09 22:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5000, 4210, N'هل تصلك اشعارات من التطبيق ؟', CAST(N'2017-10-09 22:17:00' AS SmallDateTime), NULL, 4312, 1, NULL, CAST(N'2017-10-09 22:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5001, 4208, N'هل تصلك اشعارات من التطبيق ؟', CAST(N'2017-10-09 22:18:00' AS SmallDateTime), NULL, 4308, 1, NULL, CAST(N'2017-10-09 22:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5002, 4193, N'هل تصلك اشعارات من التطبيق ؟', CAST(N'2017-10-09 22:19:00' AS SmallDateTime), NULL, 4325, 1, NULL, CAST(N'2017-10-09 22:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5003, 4193, N'فحص الاشعارات', CAST(N'2017-10-09 22:21:00' AS SmallDateTime), NULL, 4326, 1, NULL, CAST(N'2017-10-09 22:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5004, 4218, N'59', CAST(N'2017-10-09 22:23:00' AS SmallDateTime), NULL, 4328, 1, NULL, CAST(N'2017-10-09 22:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5005, 4213, N'Notification', CAST(N'2017-10-09 22:25:00' AS SmallDateTime), NULL, 4329, 1, NULL, CAST(N'2017-10-09 22:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5006, 4211, N'Notification', CAST(N'2017-10-09 22:26:00' AS SmallDateTime), NULL, 4330, 1, NULL, CAST(N'2017-10-09 22:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5007, 4210, N'نعم تصل لاخ خالد', CAST(N'2017-10-09 22:31:00' AS SmallDateTime), NULL, 4310, 1, NULL, CAST(N'2017-10-09 22:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5008, 4218, N'88', CAST(N'2017-10-09 22:31:00' AS SmallDateTime), NULL, 4328, 1, NULL, CAST(N'2017-10-09 22:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5009, 4217, N'هل تصلك اشعارات من التطبيق ؟', CAST(N'2017-10-09 22:34:00' AS SmallDateTime), NULL, 4331, 1, NULL, CAST(N'2017-10-09 22:34:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5010, 4219, N'ممتاز ', CAST(N'2017-10-10 01:23:00' AS SmallDateTime), NULL, 4333, 1, NULL, CAST(N'2017-10-10 01:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5011, 4218, N'Zz', CAST(N'2017-10-10 13:35:00' AS SmallDateTime), NULL, 4328, 1, NULL, CAST(N'2017-10-10 13:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5012, 4218, N'0000000000', CAST(N'2017-10-10 13:41:00' AS SmallDateTime), NULL, 4328, 1, NULL, CAST(N'2017-10-10 13:41:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5013, 4215, N'السلام عليكم ', CAST(N'2017-10-10 22:45:00' AS SmallDateTime), NULL, 4321, 1, NULL, CAST(N'2017-10-10 22:45:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5014, 4215, N'كيف الحال ', CAST(N'2017-10-10 22:50:00' AS SmallDateTime), NULL, 4321, 1, NULL, CAST(N'2017-10-10 22:50:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5015, 4222, N'كيف الحال ', CAST(N'2017-10-10 23:28:00' AS SmallDateTime), NULL, 4336, 1, NULL, CAST(N'2017-10-10 23:28:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5016, 4222, N'تجربة', CAST(N'2017-10-10 23:29:00' AS SmallDateTime), NULL, 4337, 1, NULL, CAST(N'2017-10-10 23:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5017, 4222, N'هي بتظهر  هنا', CAST(N'2017-10-10 23:31:00' AS SmallDateTime), NULL, 4336, 1, NULL, CAST(N'2017-10-10 23:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5018, 4222, N'بدون اشعارات ؟
', CAST(N'2017-10-10 23:31:00' AS SmallDateTime), NULL, 4337, 1, NULL, CAST(N'2017-10-10 23:31:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5019, 4222, N'لا بدون ', CAST(N'2017-10-10 23:32:00' AS SmallDateTime), NULL, 4336, 1, NULL, CAST(N'2017-10-10 23:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5020, 4218, N'تجربة ', CAST(N'2017-10-12 16:25:00' AS SmallDateTime), NULL, 4327, 1, NULL, CAST(N'2017-10-12 16:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5021, 4219, N'هل توصلك اشعارات ؟', CAST(N'2017-10-13 01:55:00' AS SmallDateTime), NULL, 4333, 1, NULL, CAST(N'2017-10-13 01:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5022, 4219, N'ايوا توصل ', CAST(N'2017-10-13 09:02:00' AS SmallDateTime), NULL, 4332, 1, NULL, CAST(N'2017-10-13 09:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5023, 4219, N'ممتاز الحمد لله', CAST(N'2017-10-13 14:09:00' AS SmallDateTime), NULL, 4340, 1, NULL, CAST(N'2017-10-13 14:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5024, 4223, N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', CAST(N'2017-10-16 20:42:00' AS SmallDateTime), NULL, 4341, 1, NULL, CAST(N'2017-10-16 20:42:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5025, 4213, N'test', CAST(N'2017-10-16 20:47:00' AS SmallDateTime), NULL, 4329, 1, NULL, CAST(N'2017-10-16 20:47:00' AS SmallDateTime))
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
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4268, 4189, 1120, 1120, CAST(N'2017-10-02 18:54:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4269, 4190, 1123, 1068, CAST(N'2017-10-02 19:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4270, 4190, 1068, 1068, CAST(N'2017-10-02 19:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4271, 4191, 1119, 1119, CAST(N'2017-10-02 19:43:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4272, 4191, 1068, 1068, CAST(N'2017-10-02 20:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4273, 4192, 1124, 1124, CAST(N'2017-10-02 21:00:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4274, 4192, 1068, 1068, CAST(N'2017-10-02 21:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4275, 4192, 1120, 1068, CAST(N'2017-10-02 22:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4276, 4189, 1068, 1068, CAST(N'2017-10-02 22:53:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4277, 4192, 1125, 1125, CAST(N'2017-10-02 23:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4278, 4193, 1124, 1125, CAST(N'2017-10-03 00:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4279, 4194, 1110, 1110, CAST(N'2017-10-03 20:47:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4280, 4194, 1068, 1068, CAST(N'2017-10-03 20:47:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4281, 4195, 1127, 1127, CAST(N'2017-10-03 20:57:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4282, 4195, 1068, 1068, CAST(N'2017-10-03 20:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4283, 4196, 1128, 1128, CAST(N'2017-10-03 21:14:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4284, 4196, 1125, 1125, CAST(N'2017-10-03 21:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4285, 4196, 1124, 1125, CAST(N'2017-10-03 21:40:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4286, 4197, 1128, 1128, CAST(N'2017-10-03 21:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4287, 4198, 1128, 1128, CAST(N'2017-10-03 22:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4288, 4199, 1128, 1125, CAST(N'2017-10-04 17:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4289, 4199, 1125, 1125, CAST(N'2017-10-04 17:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4290, 4199, 1124, 1125, CAST(N'2017-10-04 17:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4291, 4200, 1120, 1125, CAST(N'2017-10-04 17:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4292, 4200, 1125, 1125, CAST(N'2017-10-04 17:30:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4293, 4200, 1068, 1068, CAST(N'2017-10-04 23:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4294, 4201, 1130, 1130, CAST(N'2017-10-04 23:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4295, 4201, 1068, 1068, CAST(N'2017-10-04 23:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4296, 4202, 1130, 1068, CAST(N'2017-10-04 23:35:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4297, 4203, 1128, 1128, CAST(N'2017-10-05 00:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4298, 4203, 1125, 1125, CAST(N'2017-10-05 00:53:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4299, 4204, 1130, 1130, CAST(N'2017-10-05 07:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4300, 4205, 1132, 1125, CAST(N'2017-10-05 13:42:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4301, 4206, 1131, 1125, CAST(N'2017-10-05 13:42:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4302, 4206, 1125, 1125, CAST(N'2017-10-05 13:43:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4303, 4205, 1125, 1125, CAST(N'2017-10-05 13:44:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4305, 4207, 1133, 1133, CAST(N'2017-10-05 14:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4306, 4207, 1125, 1125, CAST(N'2017-10-05 14:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4307, 4208, 1134, 1134, CAST(N'2017-10-05 15:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4308, 4208, 1125, 1125, CAST(N'2017-10-05 15:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4309, 4209, 1135, 1125, CAST(N'2017-10-05 22:06:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4310, 4210, 1135, 1135, CAST(N'2017-10-05 22:06:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4311, 4209, 1125, 1125, CAST(N'2017-10-05 22:07:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4312, 4210, 1125, 1125, CAST(N'2017-10-05 22:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4313, 4210, 1124, 1125, CAST(N'2017-10-05 22:41:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4314, 4211, 1136, 1136, CAST(N'2017-10-05 22:46:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4315, 4211, 1125, 1125, CAST(N'2017-10-05 22:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4316, 4190, 1130, 1068, CAST(N'2017-10-06 00:41:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4317, 4212, 1123, 1123, CAST(N'2017-10-07 11:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4318, 4213, 1130, 1130, CAST(N'2017-10-07 16:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4319, 4214, 1124, 1124, CAST(N'2017-10-07 21:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4320, 4215, 1124, 1124, CAST(N'2017-10-09 10:37:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4321, 4215, 1140, 1140, CAST(N'2017-10-09 10:39:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4322, 4216, 1124, 1124, CAST(N'2017-10-09 18:30:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4323, 4217, 1139, 1125, CAST(N'2017-10-09 22:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4324, 4217, 1125, 1125, CAST(N'2017-10-09 22:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4325, 4193, 1125, 1125, CAST(N'2017-10-09 22:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4326, 4193, 1068, 1068, CAST(N'2017-10-09 22:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4327, 4218, 1124, 1124, CAST(N'2017-10-09 22:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4328, 4218, 1068, 1068, CAST(N'2017-10-09 22:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4329, 4213, 1068, 1068, CAST(N'2017-10-09 22:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4330, 4211, 1068, 1068, CAST(N'2017-10-09 22:26:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4331, 4217, 1068, 1068, CAST(N'2017-10-09 22:34:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4332, 4219, 1136, 1136, CAST(N'2017-10-10 01:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4333, 4219, 1068, 1068, CAST(N'2017-10-10 01:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4334, 4220, 1148, 1148, CAST(N'2017-10-10 20:27:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4335, 4221, 1148, 1068, CAST(N'2017-10-10 20:28:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4336, 4222, 1140, 1140, CAST(N'2017-10-10 23:28:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4337, 4222, 1068, 1068, CAST(N'2017-10-10 23:29:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4338, 4223, 1124, 1124, CAST(N'2017-10-12 16:30:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4339, 4224, 1124, 1124, CAST(N'2017-10-12 19:06:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4340, 4219, 1144, 1144, CAST(N'2017-10-13 14:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4341, 4223, 1068, 1068, CAST(N'2017-10-16 20:42:00' AS SmallDateTime))
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
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4189, 1, N'Hi', N'Jbvh', NULL, 1, 1, NULL, 1120, CAST(N'2017-10-02 18:54:00' AS SmallDateTime), NULL, NULL, N'3bT08475', 1120, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4190, 1, N'fi ti', N'fi ti', N'1/4190/20171002191449996.png', 1, 2, NULL, 1068, CAST(N'2017-10-02 19:15:00' AS SmallDateTime), 1130, CAST(N'2017-10-07 10:27:00' AS SmallDateTime), N'1cT198EA', 1123, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4191, 1, N'1', N'ضبط', NULL, 1, 1, NULL, 1119, CAST(N'2017-10-02 19:43:00' AS SmallDateTime), NULL, NULL, N'1fJB7129', 1119, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4192, 1, N'تجربة ', N'اول موضوع ', NULL, 1, 1, NULL, 1124, CAST(N'2017-10-02 21:00:00' AS SmallDateTime), NULL, NULL, N'9vI8A40D', 1124, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4193, 1, N'فحص التطبيق', N'تجربة', NULL, 1, 1, NULL, 1125, CAST(N'2017-10-03 00:23:00' AS SmallDateTime), NULL, NULL, N'7bG10126', 1124, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4194, 1, N'Hello', N'Hi', NULL, 1, 1, NULL, 1110, CAST(N'2017-10-03 20:47:00' AS SmallDateTime), NULL, NULL, N'4oDD7263', 1110, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4195, 1, N'Hahs', N'Hdhdhdhd', NULL, 1, 1, NULL, 1127, CAST(N'2017-10-03 20:57:00' AS SmallDateTime), NULL, NULL, N'2rP39B26', 1127, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4196, 1, N'السلام عليكم ورحمة الله وبركاتة ', N'مرحبا', N'1/4196/20171003211416294.jpg', 1, 4, NULL, 1128, CAST(N'2017-10-03 21:14:00' AS SmallDateTime), 1128, CAST(N'2017-10-03 22:03:00' AS SmallDateTime), N'5qSBC9FC', 1128, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4197, 1, N'تيتويويو', N'ود', NULL, 1, 4, NULL, 1128, CAST(N'2017-10-03 21:51:00' AS SmallDateTime), 1128, CAST(N'2017-10-03 22:03:00' AS SmallDateTime), N'7rD9795D', 1128, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4198, 1, N'بفببقرقل', N'فرفرفر', NULL, 1, 4, N'121', 1128, CAST(N'2017-10-03 22:03:00' AS SmallDateTime), 1128, CAST(N'2017-10-03 22:05:00' AS SmallDateTime), N'7fM4A5A0', 1128, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4199, 1, N'تجربة ', N'هلا خالي ', NULL, 1, 1, NULL, 1125, CAST(N'2017-10-04 17:18:00' AS SmallDateTime), NULL, NULL, N'6xI5A8AA', 1128, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4200, 1, N'Nwe ', N'Test', NULL, 1, 1, NULL, 1125, CAST(N'2017-10-04 17:29:00' AS SmallDateTime), NULL, NULL, N'9bE24474', 1120, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4201, 1, N'Tets', N'Shzh', NULL, 1, 2, NULL, 1130, CAST(N'2017-10-04 23:27:00' AS SmallDateTime), 1130, CAST(N'2017-10-07 10:27:00' AS SmallDateTime), N'1hT3D9AE', 1130, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4202, 1, N'Ticket 1', N'Ticket 1 Desc', N'1/4202/20171004233436384.png', 1, 2, NULL, 1068, CAST(N'2017-10-04 23:35:00' AS SmallDateTime), 1130, CAST(N'2017-10-07 10:26:00' AS SmallDateTime), N'8cP31DC5', 1130, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4203, 1, N'جميل جدا', N'تجريبي
', NULL, 1, 1, NULL, 1128, CAST(N'2017-10-05 00:51:00' AS SmallDateTime), NULL, NULL, N'6dLFF1E4', 1128, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4204, 1, N'Hi', N'Dxc', NULL, 1, 4, NULL, 1130, CAST(N'2017-10-05 07:17:00' AS SmallDateTime), 1130, CAST(N'2017-10-07 10:26:00' AS SmallDateTime), N'6aQCEC7B', 1130, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4205, 1, N'تجربة التطبيق ', N'شكرا عمر علي مشاركتنا تجربة فحص التطبيق', NULL, 1, 1, NULL, 1125, CAST(N'2017-10-05 13:42:00' AS SmallDateTime), NULL, NULL, N'5jF3C733', 1132, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4206, 1, N'تجربة التطبيق ', N'شكرا بدرعلى مشاركتنا تجربة فحص التطبيق', NULL, 1, 1, NULL, 1125, CAST(N'2017-10-05 13:42:00' AS SmallDateTime), NULL, NULL, N'5gY026A8', 1131, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4207, 1, N'خانة تواصل', N'تم التسجيل ولله الحمد ', NULL, 1, 1, NULL, 1133, CAST(N'2017-10-05 14:46:00' AS SmallDateTime), NULL, NULL, N'5eVED945', 1133, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4208, 1, N'تطبيق جميل', N'تطبيق جميل يقدم المفيد والجديد ويوثق المناسبات والأعياد..
نتمني القائمين عليه بالتقدم والرقي..', NULL, 1, 1, NULL, 1134, CAST(N'2017-10-05 15:12:00' AS SmallDateTime), NULL, NULL, N'6xL338FC', 1134, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4209, 1, N'تجربه', N'تجربه', NULL, 1, 1, NULL, 1125, CAST(N'2017-10-05 22:06:00' AS SmallDateTime), NULL, NULL, N'2bW1F923', 1135, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4210, 1, N'شكر', N'مشروع جميل جدا 

موفق اخي خالد ', NULL, 1, 1, NULL, 1135, CAST(N'2017-10-05 22:06:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 22:09:00' AS SmallDateTime), N'0mA0789C', 1135, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4211, 1, N'مكرمه صاحب الجلاله ب 25 الف وظيفه ', N'كيف تقدر هذي المكرمه الساميه للباحثين عن عمل وهل هذي المكرمه بسبب ضغط برامج التواصل الاجتماعي 
ننتظر آراءكم  وتعليقاتكم ؟', NULL, 1, 1, NULL, 1136, CAST(N'2017-10-05 22:46:00' AS SmallDateTime), NULL, NULL, N'3iD6CA95', 1136, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4212, 1, N'Jdbs', N'Syshs', NULL, 1, 1, NULL, 1123, CAST(N'2017-10-07 11:55:00' AS SmallDateTime), NULL, NULL, N'5kXA85E5', 1123, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4213, 1, N'Hii', N'Ggg', NULL, 1, 1, NULL, 1130, CAST(N'2017-10-07 16:12:00' AS SmallDateTime), NULL, NULL, N'9qJE84F4', 1130, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4214, 1, N'كم كلمة يسمح للكتابة في خانة العنوان هل يمكن كتابة غير محدودة من الكلمات او يوجد حد معين للكتابة اعتقد ان العنوان يجب ان يكون محدد وغير مفتوح العدد ', N'تجربة ', NULL, 1, 4, NULL, 1124, CAST(N'2017-10-07 21:23:00' AS SmallDateTime), 1124, CAST(N'2017-10-08 00:19:00' AS SmallDateTime), N'9iD973F5', 1124, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4215, 2, N'تجربة ', N'تجربة ', NULL, 1, 4, NULL, 1124, CAST(N'2017-10-09 10:37:00' AS SmallDateTime), 1140, CAST(N'2017-10-10 22:52:00' AS SmallDateTime), N'7iM678D4', 1124, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4216, 2, N'تجربة ', N'موضوع جديد مع محمد ', NULL, 1, 2, NULL, 1124, CAST(N'2017-10-09 18:30:00' AS SmallDateTime), 1124, CAST(N'2017-10-09 18:31:00' AS SmallDateTime), N'5kP8293E', 1124, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4217, 1, N'تجربة', N'شكرا علي مشاركتنا فحص الطتبيق ', N'1/4217/20171009221219421.jpg', 1, 1, NULL, 1125, CAST(N'2017-10-09 22:12:00' AS SmallDateTime), NULL, NULL, N'0iLCB166', 1139, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4218, 1, N'Zz', N'Teat', N'1/4218/20171009222216877.jpg', 1, 1, NULL, 1124, CAST(N'2017-10-09 22:22:00' AS SmallDateTime), NULL, NULL, N'6lC90338', 1124, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4219, 1, N'مجد التاريخ ', N'مجد التاريخ ..... تجربه ', N'1/4219/20171010011558224.jpg', 1, 1, NULL, 1136, CAST(N'2017-10-10 01:16:00' AS SmallDateTime), NULL, NULL, N'1gID0EF6', 1136, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4220, 2, N'Hai', N'Hshhs', NULL, 1, 1, NULL, 1148, CAST(N'2017-10-10 20:27:00' AS SmallDateTime), NULL, NULL, N'7oO6472C', 1148, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4221, 2, N'test asdfasdf', N'asdfasdfasdf', NULL, 1, 1, NULL, 1068, CAST(N'2017-10-10 20:28:00' AS SmallDateTime), NULL, NULL, N'4lX65848', 1148, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4222, 2, N'،1234', N'بسم الله الرحمن الرحيم ', NULL, 1, 4, NULL, 1140, CAST(N'2017-10-10 23:28:00' AS SmallDateTime), 1140, CAST(N'2017-10-10 23:36:00' AS SmallDateTime), N'7lM9881F', 1140, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4223, 1, N'تجربة جديدة في الاصدار الجديد ', N'تجربة جديدة ', NULL, 1, 1, NULL, 1124, CAST(N'2017-10-12 16:30:00' AS SmallDateTime), NULL, NULL, N'8wG0AE75', 1124, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (4224, 1, N'112', N'4444', NULL, 1, 3, N'????? ????', 1124, CAST(N'2017-10-12 19:06:00' AS SmallDateTime), 1068, CAST(N'2017-10-13 02:45:00' AS SmallDateTime), N'0fRB9B19', 1124, 1)
GO
SET IDENTITY_INSERT [dbo].[TICKETS] OFF
GO
SET IDENTITY_INSERT [dbo].[USER_DETAILS] ON 

GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1068, 1068, N'Admin', N'89898', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1124, 1124, N'خالد بن ناصر بن علي الجرداني', N'0', NULL, 1, 1, 1000, 12212, 1, 1, CAST(N'2017-10-02 20:53:00' AS SmallDateTime), NULL, 0, 0, 2, N'393e72dd-bb3b-4958-a793-75c0cf981141', 1, NULL, CAST(N'2017-10-02 20:53:00' AS SmallDateTime), 1068, CAST(N'2017-10-09 03:44:00' AS SmallDateTime), CAST(N'2017-10-12 19:06:23.167' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1125, 1125, N'المشرف العام', NULL, NULL, NULL, NULL, NULL, 9694, 1, NULL, NULL, NULL, NULL, 0, NULL, N'5ffbe44a-b354-4a35-9017-907c75f8f4a9', NULL, 1068, CAST(N'2017-10-02 23:47:00' AS SmallDateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1126, 1126, N'Tanveer', NULL, NULL, NULL, NULL, NULL, 39983, 0, 1, CAST(N'2017-10-03 20:49:00' AS SmallDateTime), NULL, NULL, 0, 2, N'4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154', 1, NULL, CAST(N'2017-10-03 20:49:00' AS SmallDateTime), NULL, CAST(N'2017-10-03 20:49:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1127, 1127, N'Dbdjd', NULL, NULL, NULL, NULL, NULL, 11320, 0, 1, CAST(N'2017-10-03 20:56:00' AS SmallDateTime), NULL, NULL, 0, 7, N'4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154', 1, NULL, CAST(N'2017-10-03 20:56:00' AS SmallDateTime), NULL, CAST(N'2017-10-03 20:56:00' AS SmallDateTime), CAST(N'2017-10-03 20:57:24.230' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1128, 1128, N'hilal', N'0', NULL, 1, 6, 1056, 53329, 1, 1, CAST(N'2017-10-03 21:13:00' AS SmallDateTime), NULL, 0, 0, 2, N'ab9d0a4f-af0b-42e6-a76b-72560c619971', 1, NULL, CAST(N'2017-10-03 21:13:00' AS SmallDateTime), 1125, CAST(N'2017-10-03 22:02:00' AS SmallDateTime), CAST(N'2017-10-05 00:51:07.360' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1129, 1129, N'Ggg', NULL, NULL, NULL, NULL, NULL, 34785, 0, 1, CAST(N'2017-10-04 22:01:00' AS SmallDateTime), NULL, NULL, 0, 2, N'4e5766b9-b18e-4c6e-8ca2-a47ed4d4f154', 2, NULL, CAST(N'2017-10-04 22:01:00' AS SmallDateTime), NULL, CAST(N'2017-10-04 22:01:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1130, 1130, N'Arshad', NULL, NULL, NULL, NULL, NULL, 8290, 1, 1, CAST(N'2017-10-04 23:27:00' AS SmallDateTime), NULL, NULL, 0, 10, N'72769a78-099e-4610-a928-889be3560f5d', 2, NULL, CAST(N'2017-10-04 23:27:00' AS SmallDateTime), NULL, CAST(N'2017-10-10 23:59:00' AS SmallDateTime), CAST(N'2017-10-07 16:11:48.483' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1131, 1131, N'بدر بن سيف بن علي الجرداني', N'0', NULL, 1, 6, 1056, 65761, 1, 1, CAST(N'2017-10-05 03:54:00' AS SmallDateTime), NULL, 0, 0, 2, N'ff96c122-411f-4280-bf89-3c1c829d79c6', 1, NULL, CAST(N'2017-10-05 03:54:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 13:59:00' AS SmallDateTime), CAST(N'2017-10-05 13:42:18.877' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1132, 1132, N'Ammar', NULL, NULL, 1, 5, 1013, 46764, 1, 1, CAST(N'2017-10-05 08:31:00' AS SmallDateTime), NULL, NULL, 0, 2, N'0bf656a3-6f1a-49df-b51f-c5420e7608c4', 1, NULL, CAST(N'2017-10-05 08:31:00' AS SmallDateTime), NULL, CAST(N'2017-10-05 08:31:00' AS SmallDateTime), CAST(N'2017-10-05 13:41:40.970' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1133, 1133, N'حمد بن مهنا الجرداني', N'0', NULL, 1, 6, 1057, 16456, 1, NULL, NULL, NULL, 0, 0, NULL, N'3b3299f3-4d3d-4362-8f2e-f7ac39ac48d9', NULL, 1125, CAST(N'2017-10-05 14:41:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 14:43:00' AS SmallDateTime), CAST(N'2017-10-05 14:46:01.193' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1134, 1134, N'Khalid abdullah', NULL, NULL, 1, 6, 1056, 71828, 1, 1, CAST(N'2017-10-05 14:55:00' AS SmallDateTime), NULL, NULL, 0, 2, N'6a6f16fa-47fc-46e8-930c-df63dbbbea2e', 1, NULL, CAST(N'2017-10-05 14:55:00' AS SmallDateTime), NULL, CAST(N'2017-10-05 14:55:00' AS SmallDateTime), CAST(N'2017-10-05 15:12:05.700' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1135, 1135, N'حسن بن سالم', NULL, NULL, 1, 6, 1057, 50702, 1, 1, CAST(N'2017-10-05 21:59:00' AS SmallDateTime), NULL, NULL, 0, 7, N'34671413-e78e-4169-bbe0-026f161c05d8', 1, NULL, CAST(N'2017-10-05 21:59:00' AS SmallDateTime), NULL, CAST(N'2017-10-05 21:59:00' AS SmallDateTime), CAST(N'2017-10-05 22:05:39.903' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1136, 1136, N'هاني احمد ', NULL, NULL, 1, 6, 1056, 83172, 1, 1, CAST(N'2017-10-05 22:11:00' AS SmallDateTime), NULL, NULL, 0, 2, N'665c644a-f9ee-4371-972e-898638a7b7ba', 1, NULL, CAST(N'2017-10-05 22:11:00' AS SmallDateTime), NULL, CAST(N'2017-10-05 22:11:00' AS SmallDateTime), CAST(N'2017-10-10 01:15:58.257' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1137, 1137, N'احمد البوسعيدي', NULL, NULL, NULL, NULL, NULL, 62083, 1, 1, CAST(N'2017-10-05 22:53:00' AS SmallDateTime), NULL, NULL, 0, 2, N'23908131-18d8-4b70-b100-211d6de00c89', 1, NULL, CAST(N'2017-10-05 22:53:00' AS SmallDateTime), NULL, CAST(N'2017-10-05 22:53:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1138, 1138, N'Fiii', NULL, NULL, NULL, NULL, NULL, 1812, 0, 1, CAST(N'2017-10-07 11:58:00' AS SmallDateTime), NULL, NULL, 0, 6, N'edbe4b31-aa08-4771-b132-e15aac91deea', 1, NULL, CAST(N'2017-10-07 11:58:00' AS SmallDateTime), NULL, CAST(N'2017-10-07 11:58:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1139, 1139, N'يونس', NULL, NULL, 1, 5, NULL, 46394, 1, 1, CAST(N'2017-10-08 18:46:00' AS SmallDateTime), NULL, NULL, 0, 2, N'46997f76-b3f4-4da3-b730-a39ead65e8fc', 1, NULL, CAST(N'2017-10-08 18:46:00' AS SmallDateTime), NULL, CAST(N'2017-10-08 18:46:00' AS SmallDateTime), CAST(N'2017-10-09 22:12:19.423' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1140, 1140, N'محمد', N'0', NULL, 1, 6, 1052, 1797, 1, NULL, NULL, NULL, 0, 0, NULL, N'460b0c09-a3eb-4b51-bc9c-4bf5577a3064', NULL, 1068, CAST(N'2017-10-09 02:16:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 23:32:00' AS SmallDateTime), CAST(N'2017-10-10 23:27:45.670' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1141, 1141, N'    pmrnet', NULL, NULL, NULL, NULL, NULL, 8004, 1, 1, CAST(N'2017-10-09 02:37:00' AS SmallDateTime), NULL, NULL, 0, 2, N'744b3fa4-f0d1-4861-be7a-89b483feeefe', 1, NULL, CAST(N'2017-10-09 02:37:00' AS SmallDateTime), NULL, CAST(N'2017-10-09 02:37:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1142, 1142, N'خالد الجرداني', N'0', NULL, 1, 6, 1056, NULL, 0, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 1140, CAST(N'2017-10-09 19:19:00' AS SmallDateTime), 1140, CAST(N'2017-10-09 19:20:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1143, 1143, N'تجربة', N'0', NULL, NULL, NULL, NULL, 3321, 0, 1, CAST(N'2017-10-09 21:11:00' AS SmallDateTime), NULL, 0, 0, 2, N'f9a9ba4c-4bd8-4e73-a498-bd41c10f74aa', 2, NULL, CAST(N'2017-10-09 21:11:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 20:46:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1144, 1144, N'الجرداني', N'0', NULL, 1, 6, 1056, 9027, 1, NULL, NULL, NULL, 0, 0, NULL, N'ab86a8a1-769c-43d4-93a2-ebec63d3b29c', NULL, 1068, CAST(N'2017-10-09 21:55:00' AS SmallDateTime), 1068, CAST(N'2017-10-12 18:59:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1145, 1145, N'Test', NULL, NULL, NULL, NULL, NULL, 4671, 0, 1, CAST(N'2017-10-09 21:59:00' AS SmallDateTime), NULL, NULL, 0, 3, N'67de2a95-adb0-4e2f-b492-3ce1173566a4', 2, NULL, CAST(N'2017-10-09 21:59:00' AS SmallDateTime), NULL, CAST(N'2017-10-09 21:59:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1149, 1149, N'خالد بن ناصر بن علي الجرداني ', NULL, NULL, 1, 6, 1056, 8390, 1, 1, CAST(N'2017-10-10 20:41:00' AS SmallDateTime), NULL, NULL, 0, 2, N'7a1ac1a1-fd65-4fb1-b007-7da1d5ce96e2', 1, NULL, CAST(N'2017-10-10 20:41:00' AS SmallDateTime), NULL, CAST(N'2017-10-10 20:41:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1150, 1150, N'47 user', NULL, NULL, NULL, NULL, NULL, 4367, 0, 1, CAST(N'2017-10-10 21:44:00' AS SmallDateTime), NULL, NULL, 0, 2, N'3990667e-37ed-4386-873c-7949e835057d', 2, NULL, CAST(N'2017-10-10 21:43:00' AS SmallDateTime), NULL, CAST(N'2017-10-10 21:44:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1151, 1151, N'Arshad', NULL, NULL, NULL, NULL, NULL, 6978, 1, 1, CAST(N'2017-10-10 21:49:00' AS SmallDateTime), NULL, NULL, 0, 3, N'3990667e-37ed-4386-873c-7949e835057d', 2, NULL, CAST(N'2017-10-10 21:49:00' AS SmallDateTime), NULL, CAST(N'2017-10-10 21:49:00' AS SmallDateTime), NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1152, 1152, N'جمعية المراة العمانية بقريات', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 1068, CAST(N'2017-10-13 23:13:00' AS SmallDateTime), NULL, NULL, NULL)
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
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1068, N'admin', N'sawa@oman', 1, N'123456', N'admin@takamul.com', NULL, 1, 0, NULL, 1, CAST(N'2017-07-14 00:00:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1124, NULL, NULL, 4, N'99885080', N'K@k.k', 1, 1, 0, NULL, NULL, CAST(N'2017-10-02 20:53:00' AS SmallDateTime), 1068, CAST(N'2017-10-09 03:44:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1125, N'a41zz', N'598873', 3, N'99885080', N'khalid@sawa.om', 1, 1, 0, NULL, 1068, CAST(N'2017-10-02 23:47:00' AS SmallDateTime), 1068, CAST(N'2017-10-02 23:49:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1126, NULL, NULL, 4, N'59595959', N'Kkkk@jj.nn', 1, 1, 0, NULL, NULL, CAST(N'2017-10-03 20:49:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1127, NULL, NULL, 4, N'44444444', N'Dndjdjj@jdjd.dd', 1, 1, 0, NULL, NULL, CAST(N'2017-10-03 20:56:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1128, NULL, NULL, 4, N'94771559', N'alwhm672@gmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-03 21:13:00' AS SmallDateTime), 1125, CAST(N'2017-10-03 22:02:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1129, NULL, NULL, 4, N'96528555', N'Fdd@hhh.kk', 1, 1, 0, NULL, NULL, CAST(N'2017-10-04 22:01:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1130, NULL, NULL, 4, N'98455049', N'T@t.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-04 23:27:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1131, NULL, NULL, 4, N'93293332', N'brr8820@hotmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-05 03:54:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 13:59:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1132, NULL, NULL, 4, N'99115995', N'amaromar70@gmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-05 08:31:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1133, NULL, NULL, 4, N'99450903', N'englishsqu2010@gmail.com', 1, 1, 0, NULL, 1125, CAST(N'2017-10-05 14:41:00' AS SmallDateTime), 1125, CAST(N'2017-10-05 14:43:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1134, NULL, NULL, 4, N'93210909', N'Khalid.jardani@omantel.om', 1, 1, 0, NULL, NULL, CAST(N'2017-10-05 14:55:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1135, NULL, NULL, 4, N'95727318', N'hassanaljardani@gmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-05 21:59:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1136, NULL, NULL, 4, N'99795221', N'siya18@hotmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-05 22:11:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1137, NULL, NULL, 4, N'95405050', N'Whicrm@gmail.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-05 22:53:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1138, NULL, NULL, 4, N'91534771', N'Fo@fi.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-07 11:58:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1139, NULL, NULL, 4, N'98800133', N'yonis2016@hotmil.com', 1, 1, 0, NULL, NULL, CAST(N'2017-10-08 18:46:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1140, N'm01', N'm123456', 3, N'92525555', NULL, 2, 1, 0, NULL, 1068, CAST(N'2017-10-09 02:16:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 23:32:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1141, NULL, NULL, 4, N'71719993', N'k@k.k', 1, 1, 0, NULL, NULL, CAST(N'2017-10-09 02:37:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1142, NULL, NULL, 4, N'71719993', N'k@k.k', 2, 1, 0, NULL, 1140, CAST(N'2017-10-09 19:19:00' AS SmallDateTime), 1140, CAST(N'2017-10-09 19:20:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1143, NULL, NULL, 4, N'64676767', N'kkk', 2, 1, 0, NULL, NULL, CAST(N'2017-10-09 21:11:00' AS SmallDateTime), 1068, CAST(N'2017-10-10 20:46:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1144, N'aljardani', N'598873', 2, N'99885080', N'KHALID.JARDANI@GMAIL.COM', 2, 1, 0, NULL, 1068, CAST(N'2017-10-09 21:55:00' AS SmallDateTime), 1068, CAST(N'2017-10-09 21:59:00' AS SmallDateTime))
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1145, NULL, NULL, 4, N'98455042', NULL, 2, 1, 0, NULL, NULL, CAST(N'2017-10-09 21:59:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1149, NULL, NULL, 4, N'99885080', NULL, 2, 1, 0, NULL, NULL, CAST(N'2017-10-10 20:41:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1150, NULL, NULL, 4, N'98455047', NULL, 2, 1, 0, NULL, NULL, CAST(N'2017-10-10 21:43:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1151, NULL, NULL, 4, N'98455049', NULL, 2, 1, 0, NULL, NULL, CAST(N'2017-10-10 21:49:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1152, N'owaq', N'Takamul$123', 2, N'94094852', N'QURIYAT12@GMAIL.COM', 3, 1, 0, NULL, 1068, CAST(N'2017-10-13 23:13:00' AS SmallDateTime), NULL, NULL)
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
/****** Object:  StoredProcedure [dbo].[DeleteTicket]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[DeleteTicketParticipant]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllActiveEvents]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllActiveNews]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllActiveTickets]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllApplications]    Script Date: 10/16/2017 11:24:58 PM ******/
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
		A.CREATED_DATE,
		A.ONE_SIGNAL_APP_ID,
		A.ONE_SIGNAL_AUTH_KEY
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
		A.CREATED_DATE,		
		A.ONE_SIGNAL_APP_ID,
		A.ONE_SIGNAL_AUTH_KEY
	ORDER BY A.ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY	
END


















GO
/****** Object:  StoredProcedure [dbo].[GetAllAreas]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllMembers]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllTickets]    Script Date: 10/16/2017 11:24:58 PM ******/
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
		) TicketParticipantNos,
		(
			SELECT top 1 UD.FULL_NAME FROM TICKET_CHAT_DETAILS TD
			INNER JOIN TICKET_PARTICIPANTS TP ON TP.ID = TD.TICKET_PARTICIPANT_ID --AND TP.TICKET_ID = T.ID
			INNER JOIN USERS U ON U.ID = TP.USER_ID
			INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID			
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
	ORDER BY LastTicketChatCreatedDate DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY
END


GO
/****** Object:  StoredProcedure [dbo].[GetAllTicketStatusLookup]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllVillages]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllWilayats]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationDetails]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationInfo]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationSettings]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationStatistics]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationUsers]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationUsersByUserTypes]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetEventDetails]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetEventsByDate]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetMemberInfo]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetMobileAppUserInfo]    Script Date: 10/16/2017 11:24:58 PM ******/
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
	@Pin_ApplicationId	int,
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
		( U.APPLICATION_ID = @Pin_ApplicationId ) AND
		( U.ID = @Pin_UserId  OR @Pin_UserId IS NULL ) AND
		( U.PHONE_NUMBER = @Pin_PhoneNumber  OR @Pin_PhoneNumber IS NULL )
END








GO
/****** Object:  StoredProcedure [dbo].[GetMoreTicketChats]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNewsDetails]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetPushNotificationLogs]    Script Date: 10/16/2017 11:24:58 PM ******/
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
CREATE PROCEDURE [dbo].[GetPushNotificationLogs]
	@Pin_ApplicationId		int = NULL,
	@Pin_PageNumber			INT = 1,
	@Pin_RowspPage			INT = 10
AS
BEGIN
	SELECT 
		TotalCount = COUNT(*) OVER(),
		L.*
    FROM 
		 NOTIFICATION_LOGS L
	WHERE
		( L.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL ) 
	GROUP BY
		L.ID,
		L.APPLICATION_ID,
		L.NOTIFICATION_TYPE,
		L.REQUEST_JSON,
		L.RESPONSE_MESSAGE,
		L.IS_SENT_NOTIFICATION,
		L.CREATED_DATE,
		L.MOBILE_NUMBERS
	ORDER BY L.ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY
END


GO
/****** Object:  StoredProcedure [dbo].[GetTicketChats]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTicketMObileUserParticipants]    Script Date: 10/16/2017 11:24:58 PM ******/
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
		U.PHONE_NUMBER,
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
/****** Object:  StoredProcedure [dbo].[GetTicketParticipants]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTop5TicketsByStatus]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetUserDetails]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Inc_GetAllActiveEvents]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertApplication]    Script Date: 10/16/2017 11:24:58 PM ******/
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
	@Pin_ApplicationName			nvarchar(200),
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
/****** Object:  StoredProcedure [dbo].[InsertMobileUser]    Script Date: 10/16/2017 11:24:58 PM ******/
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
	WHERE PHONE_NUMBER = @Pin_PhoneNumber AND APPLICATION_ID = @Pin_ApplicationId;

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
/****** Object:  StoredProcedure [dbo].[InsertNotificationLog]    Script Date: 10/16/2017 11:24:58 PM ******/
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
	@Pin_MobileNumbers				varchar(5000),
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
		MOBILE_NUMBERS,
		CREATED_DATE
	) 
	VALUES
	(
		@Pin_ApplicationID,
		@Pin_NotificationType,
		@Pin_RequestJSON,
		@Pin_ResponseMessage,
		@Pin_IsSentNotification,
		@Pin_MobileNumbers,
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
/****** Object:  StoredProcedure [dbo].[InsertTicket]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertTicketChat]    Script Date: 10/16/2017 11:24:58 PM ******/
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
			IF @v_Error <> -8 AND @v_Error <> -9 -- Ticket Restriction Status && Ticket Submission Interval Days Status
			BEGIN
			 SET @Pout_Error = @v_Error
			 RETURN;
			END
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
/****** Object:  StoredProcedure [dbo].[InsertTicketParticipant]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertUser]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ResendOPTNumber]    Script Date: 10/16/2017 11:24:58 PM ******/
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
	@Pin_ApplicationId		int,
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
	WHERE PHONE_NUMBER = @Pin_PhoneNumber AND APPLICATION_ID = @Pin_ApplicationId;

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
		WHERE PHONE_NUMBER = @Pin_PhoneNumber AND APPLICATION_ID = @Pin_ApplicationId;
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
		NO_OF_TIMES_OTP_SEND = NO_OF_TIMES_OTP_SEND + 1,
		MODIFIED_DATE = GETDATE()
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
/****** Object:  StoredProcedure [dbo].[ResolveTicket]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SendOTPOnAppReinstall]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateApplication]    Script Date: 10/16/2017 11:24:58 PM ******/
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
	@Pin_ApplicationName			nvarchar(200),
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
/****** Object:  StoredProcedure [dbo].[UpdateApplicationSettings]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateOTPStatus]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateProfileInformation]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateTicket]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateUserPassword]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateUserStatus]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UserLogin]    Script Date: 10/16/2017 11:24:58 PM ******/
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
			UD.FULL_NAME,
			A.ONE_SIGNAL_APP_ID,
			A.ONE_SIGNAL_AUTH_KEY
	FROM USERS U
	INNER JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	INNER JOIN dbo.USER_TYPES UT ON UT.ID = U.USER_TYPE_ID 
	LEFT JOIN APPLICATIONS A ON A.ID = U.APPLICATION_ID
	WHERE U.USER_NAME= @UserName AND U.PASSWORD = @Password
END









GO
/****** Object:  StoredProcedure [dbo].[usp_LogErrors]    Script Date: 10/16/2017 11:24:58 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumber]    Script Date: 10/16/2017 11:24:58 PM ******/
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
	@Pin_ApplicationId		int,
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
	WHERE PHONE_NUMBER = @Pin_PhoneNumber AND APPLICATION_ID = @Pin_ApplicationId;

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
		WHERE PHONE_NUMBER = @Pin_PhoneNumber AND APPLICATION_ID = @Pin_ApplicationId;
	end
	
	SET @v_Count = 0;

	SELECT @v_Count = COUNT(1) 
	FROM USER_DETAILS 
	WHERE USER_ID = @v_UserId AND OTP_NUMBER = @Pin_OTPNumber;

	if(@v_Count > 0)
	begin
		
		BEGIN TRANSACTION    -- Start the transaction
		--Update otp verified status 
		UPDATE USER_DETAILS
		SET 
			IS_OTP_VALIDATED = 1,
			DEVICE_ID = @Pin_DeviceID,
			MODIFIED_DATE = GETDATE()
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
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumberReinstall]    Script Date: 10/16/2017 11:24:58 PM ******/
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
