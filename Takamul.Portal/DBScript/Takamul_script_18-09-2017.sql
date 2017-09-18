USE [Takamul]
GO
/****** Object:  UserDefinedFunction [dbo].[fnCheckUserStatus]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_ENTITIES]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_PRIVILLAGES]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_SETTINGS]    Script Date: 9/18/2017 11:32:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APPLICATION_SETTINGS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[SETTINGS_NAME] [varchar](50) NULL,
	[SETTINGS_VALUE] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[APPLICATION_USERS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[APPLICATIONS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[AREA_MASTER]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[DB_LOGS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[EVENTS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[LANGUAGES]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[MEMBER_INFO]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[NEWS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[TICKET_CHAT_DETAILS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[TICKET_CHAT_TYPES]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[TICKET_PARTICIPANTS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[TICKET_STATUS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[TICKETS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[USER_DETAILS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[USER_TYPES]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[USERS]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[VILLAGE_MASTER]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [dbo].[WILAYAT_MASTER]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  Table [nanocomp_production].[ABOUT_APP]    Script Date: 9/18/2017 11:32:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [nanocomp_production].[ABOUT_APP](
	[Title] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [nanocomp_production].[ABOUTAPP_LINKS]    Script Date: 9/18/2017 11:32:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [nanocomp_production].[ABOUTAPP_LINKS](
	[ID] [int] NOT NULL,
	[Howitworks] [nvarchar](50) NULL,
	[InstallationInstruction] [nvarchar](50) NULL,
	[FAQ] [nvarchar](50) NULL,
	[AppGuide] [nvarchar](50) NULL,
	[Privacyandpolicies] [nvarchar](50) NULL,
	[Termsandcondition] [nvarchar](50) NULL,
	[InformationSecurity] [nvarchar](50) NULL
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[APPLICATIONS] ON 

GO
INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO_PATH], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, N'Takamul', N'1/20170726205558114.png', NULL, CAST(N'2018-07-14 00:00:00' AS SmallDateTime), NULL, 1, 1, CAST(N'2017-07-14 00:34:00' AS SmallDateTime), 1068, CAST(N'2017-07-26 09:56:00' AS SmallDateTime))
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
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'cfd39215-669f-4ff7-b219-b72fdce65bd6', N'/LM/W3SVC/1/ROOT/Takamul.API', N'NANOCOMPLEX', N'System.DivideByZeroException', N'Takamul.API', N'Attempted to divide by zero.', N'', 0, CAST(N'2017-09-17 18:49:53.787' AS DateTime), 1, N'<error
  host="NANOCOMPLEX"
  type="System.DivideByZeroException"
  message="Attempted to divide by zero."
  source="Takamul.API"
  detail="System.DivideByZeroException: Attempted to divide by zero.&#xD;&#xA;   at Takamul.API.Controllers.NewsServiceController.GetAllNews(Int32 nApplicationID, Int32 nLanguageID) in G:\GitHub\Takamul\Takamul.API\Controllers\NewsServiceController.cs:line 73"
  time="2017-09-17T18:49:53.7868310Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'11ee00d5-8929-42fa-8779-92733366b61e', N'/LM/W3SVC/3/ROOT', N'Tj2Ej2Rw6', N'System.DivideByZeroException', N'Takamul.API', N'Attempted to divide by zero.', N'', 0, CAST(N'2017-09-17 19:26:43.530' AS DateTime), 2, N'<error
  host="Tj2Ej2Rw6"
  type="System.DivideByZeroException"
  message="Attempted to divide by zero."
  source="Takamul.API"
  detail="System.DivideByZeroException: Attempted to divide by zero.&#xD;&#xA;   at Takamul.API.Controllers.NewsServiceController.GetAllNews(Int32 nApplicationID, Int32 nLanguageID)"
  time="2017-09-17T19:26:43.5293715Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'cd7b580a-1005-43ca-a54a-2d6cf96faf16', N'/LM/W3SVC/3/ROOT', N'Tj2Ej2Rw6', N'System.DivideByZeroException', N'Takamul.API', N'Attempted to divide by zero.', N'', 0, CAST(N'2017-09-17 19:26:50.743' AS DateTime), 3, N'<error
  host="Tj2Ej2Rw6"
  type="System.DivideByZeroException"
  message="Attempted to divide by zero."
  source="Takamul.API"
  detail="System.DivideByZeroException: Attempted to divide by zero.&#xD;&#xA;   at Takamul.API.Controllers.NewsServiceController.GetAllNews(Int32 nApplicationID, Int32 nLanguageID)"
  time="2017-09-17T19:26:50.7423672Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'914b73d1-ede3-4a46-aebc-f0e29cdd9319', N'/LM/W3SVC/1/ROOT/Takamul.Portal', N'NANOCOMPLEX', N'System.Exception', N'', N'Could not send push notification.', N'admin', 0, CAST(N'2017-09-18 17:48:01.573' AS DateTime), 4, N'<error
  host="NANOCOMPLEX"
  type="System.Exception"
  message="Could not send push notification."
  detail="System.Exception: Could not send push notification."
  user="admin"
  time="2017-09-18T17:48:01.5728102Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'28b8dbaa-4d37-4610-9e62-891a05bae748', N'/LM/W3SVC/1/ROOT/Takamul.Portal', N'NANOCOMPLEX', N'System.Exception', N'', N'Could not send push notification.', N'admin', 0, CAST(N'2017-09-18 17:48:36.793' AS DateTime), 5, N'<error
  host="NANOCOMPLEX"
  type="System.Exception"
  message="Could not send push notification."
  detail="System.Exception: Could not send push notification."
  user="admin"
  time="2017-09-18T17:48:36.7933019Z" />')
GO
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'5192f7f9-0dfb-4319-a428-52812abc9f78', N'/LM/W3SVC/1/ROOT', N'NANOCOMPLEX', N'System.Web.HttpException', N'System.Web.Mvc', N'The controller for path ''/favicon.ico'' was not found or does not implement IController.', N'', 404, CAST(N'2017-09-18 19:22:20.607' AS DateTime), 6, N'<error
  host="NANOCOMPLEX"
  type="System.Web.HttpException"
  message="The controller for path ''/favicon.ico'' was not found or does not implement IController."
  source="System.Web.Mvc"
  detail="System.Web.HttpException (0x80004005): The controller for path ''/favicon.ico'' was not found or does not implement IController.&#xD;&#xA;   at System.Web.Mvc.DefaultControllerFactory.GetControllerInstance(RequestContext requestContext, Type controllerType)&#xD;&#xA;   at System.Web.Mvc.DefaultControllerFactory.CreateController(RequestContext requestContext, String controllerName)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.ProcessRequestInit(HttpContextBase httpContext, IController&amp; controller, IControllerFactory&amp; factory)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.BeginProcessRequest(HttpContextBase httpContext, AsyncCallback callback, Object state)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  time="2017-09-18T19:22:20.6075884Z"
  statusCode="404">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:image/webp,image/apng,image/*,*/*;q=0.8&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.8,ml;q=0.6&#xD;&#xA;HTTP_HOST:localhost&#xD;&#xA;HTTP_REFERER:http://localhost/Takamul.Portal/&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: image/webp,image/apng,image/*,*/*;q=0.8&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.8,ml;q=0.6&#xD;&#xA;Host: localhost&#xD;&#xA;Referer: http://localhost/Takamul.Portal/&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/1/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="G:\GitHub\Takamul\Takamul.Portal\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="1" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/1" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/favicon.ico" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="G:\GitHub\Takamul\Takamul.Portal\favicon.ico" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="54491" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/favicon.ico" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="80" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/favicon.ico" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="image/webp,image/apng,image/*,*/*;q=0.8" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.8,ml;q=0.6" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost/Takamul.Portal/" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36" />
    </item>
  </serverVariables>
</error>')
GO
SET IDENTITY_INSERT [dbo].[ELMAH_Error] OFF
GO
SET IDENTITY_INSERT [dbo].[EVENTS] ON 

GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2023, 1, N'Summer surprise ', N'Summer surprise mega sale', CAST(N'2017-07-27 00:00:00' AS SmallDateTime), N'Ruwi', N'23.6137', N'58.5175', 1, 1068, CAST(N'2017-07-26 08:54:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170726085415589.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2024, 1, N'test', N'siya', CAST(N'2017-08-02 00:00:00' AS SmallDateTime), N'siya', N'23.2144', N'58.6883', 1, 1068, CAST(N'2017-08-02 11:44:00' AS SmallDateTime), NULL, NULL, NULL, 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2025, 1, N'asdf', N'asdfa', CAST(N'2017-09-16 16:22:00' AS SmallDateTime), N'asdfasdf', N'23.5615', N'58.5118', 0, 1068, CAST(N'2017-09-16 16:23:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170916162256976.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2026, 1, N'test', N'test', CAST(N'2017-09-16 16:06:00' AS SmallDateTime), N'asdfasdfasdf', N'23.5665', N'58.4740', 0, 1068, CAST(N'2017-09-16 16:25:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 16:26:00' AS SmallDateTime), N'1/Events/20170916162447558.jpg', 2)
GO
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [EVENT_IMG_FILE_PATH], [LANGUAGE_ID]) VALUES (2027, 1, N'dsfgsdfg', N'sdfgsdfg', CAST(N'2017-09-16 16:30:00' AS SmallDateTime), N'asdfasdf', N'23.5608', N'58.4294', 0, 1068, CAST(N'2017-09-16 05:31:00' AS SmallDateTime), NULL, NULL, N'1/Events/20170916053052931.jpg', 2)
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
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1010, 1, N'Supervisor', N'Supervisor is Hamed Alshemsi', 1068, CAST(N'2017-07-26 09:08:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[MEMBER_INFO] ([ID], [APPLICATION_ID], [MEMBER_INFO_TITLE], [MEMBER_INFO_DESCRIPTION], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (1011, 1, N'Manager', N'Manager is Shihab bin Humayoon', 1068, CAST(N'2017-07-26 09:08:00' AS SmallDateTime), NULL, NULL, 2)
GO
SET IDENTITY_INSERT [dbo].[MEMBER_INFO] OFF
GO
SET IDENTITY_INSERT [dbo].[NEWS] ON 

GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3101, 1, N'Mumbai building collapse', N'1/News/20170726085114468.jpg', N'Mumbai building collapse man arrested ', 1, 1, CAST(N'2017-07-26 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-07-26 08:51:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3102, 1, N'Global warming alert', N'1/News/20170726085846967.jpg', N'Global warming hits the world tragically. June marks as hottest month globally ', 0, 1, CAST(N'2017-07-26 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-07-26 08:59:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3103, 1, N'Image Size Test', N'1/News/20170726092451008.png', N'Image Size Test Desc', 1, 1, CAST(N'2017-07-26 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-07-26 09:25:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3104, 1, N'Image 2', N'1/News/20170726092822658.jpg', N'Image 2', 1, 1, CAST(N'2017-07-26 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-07-26 09:28:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3105, 1, N'Image 2', N'1/News/20170726205355691.jpg', N'Image 2 des', 1, 1, CAST(N'2017-07-26 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-07-26 20:54:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3106, 1, N'A41ZZ', N'1/News/20170729081833313.jpg', N'Khalid ', 1, 1, CAST(N'2017-07-29 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-07-29 08:19:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3107, 1, N'تجربة ', N'1/News/20170729205223808.jpg', N'خبر بالعربي ', 1, 1, CAST(N'2017-07-29 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-07-29 20:52:00' AS SmallDateTime), NULL, NULL, 1)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3108, 1, N'8', N'1/News/20170802123819959.jpg', N'test', 1, 1, CAST(N'2017-08-02 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-08-02 12:38:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3109, 1, N'Sawa.work', N'1/News/20170806065349744.jpg', N'New website for the App', 1, 1, CAST(N'2017-08-06 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-08-06 06:54:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3110, 1, N'Aljardani', N'1/News/20170807083357042.jpg', N'New App now', 1, 1, CAST(N'2017-08-07 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-08-07 08:34:00' AS SmallDateTime), 1068, CAST(N'2017-08-08 13:55:00' AS SmallDateTime), 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3111, 1, N'cx\c', N'1/News/20170916113918217.jpg', N'\zc\zxcdf', 0, 1, CAST(N'2017-09-16 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 11:39:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3112, 1, N'asdfasd', N'1/News/20170916113945556.jpg', N'fasdfasdf', 0, 1, CAST(N'2017-09-16 00:00:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 11:40:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3113, 1, N'asdfa', N'1/News/20170916114147388.jpg', N'sdfasadf', 0, 1, CAST(N'2017-09-16 11:57:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 11:42:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 16:08:00' AS SmallDateTime), 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3114, 1, N'asdfasd', N'1/News/20170916053133473.jpg', N'fadsfasfd', 0, 1, CAST(N'2017-09-16 16:31:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 05:32:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3115, 1, N'asdfasdf', N'1/News/20170916163833096.jpg', N'sadfasadf', 0, 0, CAST(N'2017-09-16 16:38:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 16:39:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3116, 1, N'adfasdfas', N'1/News/20170916054035994.jpg', N'fasfafasfd', 0, 0, CAST(N'2017-09-16 16:40:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 05:41:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3117, 1, N'asdfasdfasdf', N'1/News/20170916054116198.jpg', N'ddvadsf', 0, 0, CAST(N'2017-09-16 13:40:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 05:41:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3118, 1, N'sadfasdfasdf', N'1/News/20170916054131273.jpg', N'sfasdf', 0, 0, CAST(N'2017-09-16 13:40:00' AS SmallDateTime), 1068, CAST(N'2017-09-16 05:42:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3119, 1, N'test', N'1/News/20170917092556051.jpg', N'test', 0, 0, CAST(N'2017-09-17 20:47:00' AS SmallDateTime), 1068, CAST(N'2017-09-17 09:26:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3120, 1, N'test a', N'1/News/20170917093022474.jpg', N'adfasdf', 0, 0, CAST(N'2017-09-17 20:13:00' AS SmallDateTime), 1068, CAST(N'2017-09-17 09:30:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3121, 1, N'test b', N'1/News/20170917203353452.jpg', N'asdfasdf', 0, 0, CAST(N'2017-09-17 20:14:00' AS SmallDateTime), 1068, CAST(N'2017-09-17 20:35:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3122, 1, N'test c', N'1/News/20170917203539143.jpg', N'asdfasdf', 0, 0, CAST(N'2017-09-17 20:15:00' AS SmallDateTime), 1068, CAST(N'2017-09-17 20:36:00' AS SmallDateTime), NULL, NULL, 2)
GO
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [PUBLISHED_DATE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LANGUAGE_ID]) VALUES (3123, 1, N'test c', N'1/News/20170917204619318.jpg', N'adfasdf', 0, 0, CAST(N'2017-09-17 20:15:00' AS SmallDateTime), 1068, CAST(N'2017-09-17 20:46:00' AS SmallDateTime), NULL, NULL, 2)
GO
SET IDENTITY_INSERT [dbo].[NEWS] OFF
GO
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_DETAILS] ON 

GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3633, 3120, N'Test ticket chat ', CAST(N'2017-07-26 08:49:00' AS SmallDateTime), NULL, 3173, 1, NULL, CAST(N'2017-07-26 08:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3634, 3120, N'Today visit ', CAST(N'2017-07-26 08:49:00' AS SmallDateTime), NULL, 3173, 1, NULL, CAST(N'2017-07-26 08:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3635, 3120, N'Today is Wednesday', CAST(N'2017-07-26 08:49:00' AS SmallDateTime), NULL, 3173, 1, NULL, CAST(N'2017-07-26 08:49:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3636, 3120, N'So What', CAST(N'2017-07-26 08:54:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 08:54:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3637, 3120, N'Myra', CAST(N'2017-07-26 08:55:00' AS SmallDateTime), NULL, 3173, 1, NULL, CAST(N'2017-07-26 08:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3638, 3120, N'Entha mone ', CAST(N'2017-07-26 08:55:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 08:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3639, 3120, N'Notifications click cgeyimbo open akunika', CAST(N'2017-07-26 08:55:00' AS SmallDateTime), NULL, 3173, 1, NULL, CAST(N'2017-07-26 08:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3640, 3120, N'Varunille', CAST(N'2017-07-26 08:57:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 08:57:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3641, 3120, N'Onu koode message chwy', CAST(N'2017-07-26 08:58:00' AS SmallDateTime), NULL, 3173, 1, NULL, CAST(N'2017-07-26 08:58:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3642, 3120, N'hi', CAST(N'2017-07-26 09:02:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3643, 3120, N'hi', CAST(N'2017-07-26 09:02:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3644, 3120, N'this us rtf', CAST(N'2017-07-26 09:02:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3645, 3120, N'ithu automatic refresh chilapo enthekyo avenue', CAST(N'2017-07-26 09:03:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3646, 3120, N'ithu automatic refresh chilapo enthekyo avenue', CAST(N'2017-07-26 09:03:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:03:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3647, 3121, N'YEAH', CAST(N'2017-07-26 09:09:00' AS SmallDateTime), NULL, 3175, 1, NULL, CAST(N'2017-07-26 09:09:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3648, 3120, N'', CAST(N'2017-07-26 09:10:00' AS SmallDateTime), N'1/3120/20170726091007558.jpg', 3174, 3, NULL, CAST(N'2017-07-26 09:10:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3649, 3121, N'', CAST(N'2017-07-26 09:12:00' AS SmallDateTime), N'1/3121/20170726091145535.jpg', 3176, 3, NULL, CAST(N'2017-07-26 09:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3650, 3121, N'Funny things ', CAST(N'2017-07-26 09:12:00' AS SmallDateTime), NULL, 3175, 1, NULL, CAST(N'2017-07-26 09:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3651, 3121, N'really', CAST(N'2017-07-26 09:12:00' AS SmallDateTime), NULL, 3176, 1, NULL, CAST(N'2017-07-26 09:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3652, 3121, N'Absolutely right ', CAST(N'2017-07-26 09:12:00' AS SmallDateTime), NULL, 3175, 1, NULL, CAST(N'2017-07-26 09:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3653, 3121, N'zig zag', CAST(N'2017-07-26 09:12:00' AS SmallDateTime), NULL, 3176, 1, NULL, CAST(N'2017-07-26 09:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3654, 3121, N'emulsion', CAST(N'2017-07-26 09:13:00' AS SmallDateTime), NULL, 3176, 1, NULL, CAST(N'2017-07-26 09:13:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3655, 3120, N'athentha', CAST(N'2017-07-26 09:14:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:14:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3656, 3120, N'Ntha', CAST(N'2017-07-26 09:15:00' AS SmallDateTime), NULL, 3177, 1, NULL, CAST(N'2017-07-26 09:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3657, 3120, N'scroll nokiyo nee', CAST(N'2017-07-26 09:15:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3658, 3120, N'scroll ayi le', CAST(N'2017-07-26 09:15:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:15:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3659, 3122, N'Hello team admin , how are you 
Hope everything is going good 
This is very important ticket or issue we need to address immediately 
There is my water or electricity tin the wokayat of Adam
Prole are suffering like anything 
Tjjsnis not good faf animals djdbnf d HDjjndd.', CAST(N'2017-07-26 09:16:00' AS SmallDateTime), NULL, 3178, 1, NULL, CAST(N'2017-07-26 09:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3660, 3120, N'ipo bottothilek varunund le', CAST(N'2017-07-26 09:16:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3661, 3120, N'ipo bottothilek varunund le', CAST(N'2017-07-26 09:16:00' AS SmallDateTime), NULL, 3174, 1, NULL, CAST(N'2017-07-26 09:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3662, 3122, N'ok', CAST(N'2017-07-26 09:16:00' AS SmallDateTime), NULL, 3179, 1, NULL, CAST(N'2017-07-26 09:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3663, 3122, N'Hello team admin , how are you 
Hope everything is going good 
This is very important ticket or issue we need to address immediately 
There is my water or electricity tin the wokayat of Adam
Prole are suffering like anything 
Tjjsnis not good faf animals djdbnf d HDjjndd.', CAST(N'2017-07-26 09:16:00' AS SmallDateTime), NULL, 3178, 1, NULL, CAST(N'2017-07-26 09:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3664, 3122, N'dont repeat', CAST(N'2017-07-26 09:17:00' AS SmallDateTime), NULL, 3179, 1, NULL, CAST(N'2017-07-26 09:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3665, 3122, N'ok this hhjg uyu y', CAST(N'2017-07-26 09:17:00' AS SmallDateTime), NULL, 3179, 1, NULL, CAST(N'2017-07-26 09:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3666, 3122, N'Book one', CAST(N'2017-07-26 09:18:00' AS SmallDateTime), NULL, 3178, 1, NULL, CAST(N'2017-07-26 09:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3667, 3122, N'njkkjoiuiou', CAST(N'2017-07-26 09:18:00' AS SmallDateTime), NULL, 3179, 1, NULL, CAST(N'2017-07-26 09:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3668, 3122, N'Eufhcufjjg. Kbi', CAST(N'2017-07-26 09:18:00' AS SmallDateTime), NULL, 3178, 1, NULL, CAST(N'2017-07-26 09:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3669, 3122, N'hjhjhj', CAST(N'2017-07-26 09:18:00' AS SmallDateTime), NULL, 3179, 1, NULL, CAST(N'2017-07-26 09:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3670, 3122, N'yuyughgh y duty', CAST(N'2017-07-26 09:19:00' AS SmallDateTime), NULL, 3179, 1, NULL, CAST(N'2017-07-26 09:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3671, 3122, N'ioopopopoioiioi', CAST(N'2017-07-26 09:19:00' AS SmallDateTime), NULL, 3179, 1, NULL, CAST(N'2017-07-26 09:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3672, 3122, N'Okao', CAST(N'2017-07-26 09:20:00' AS SmallDateTime), NULL, 3178, 1, NULL, CAST(N'2017-07-26 09:20:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3673, 3124, N'                messageTitle = oTicketChatViewModel.REPLY_MESSAGE.Length > 25 ? oTicketChatViewModel.REPLY_MESSAGE.Substring(0, 100) + "..." : oTicketChatViewModel.REPLY_MESSAGE;', CAST(N'2017-07-26 09:22:00' AS SmallDateTime), NULL, 3182, 1, NULL, CAST(N'2017-07-26 09:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3674, 3124, N'Da ee codinu issue ille', CAST(N'2017-07-26 09:22:00' AS SmallDateTime), NULL, 3182, 1, NULL, CAST(N'2017-07-26 09:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3675, 3124, N'Nee nthna 25 enu nokune', CAST(N'2017-07-26 09:22:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-26 09:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3676, 3124, N'Enik error kitnu', CAST(N'2017-07-26 09:23:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-26 09:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3677, 3124, N'Greater than 100 anenkilale ath wrk akoo', CAST(N'2017-07-26 09:24:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-26 09:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3678, 3124, N'Right ?', CAST(N'2017-07-26 09:24:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-26 09:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3679, 3124, N'Jsjsjs', CAST(N'2017-07-29 08:17:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-29 08:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3680, 3124, N'Kshdje', CAST(N'2017-07-29 08:17:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-29 08:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3681, 3124, N'Jdhdhr', CAST(N'2017-07-29 08:17:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-29 08:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3682, 3124, N'', CAST(N'2017-07-29 08:17:00' AS SmallDateTime), N'1/3124/20170729081719452.jpg', 3183, 3, NULL, CAST(N'2017-07-29 08:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3683, 3124, N'Hello', CAST(N'2017-07-29 10:24:00' AS SmallDateTime), NULL, 3181, 1, NULL, CAST(N'2017-07-29 10:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3684, 3124, N'Hai', CAST(N'2017-07-30 09:25:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-30 09:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3685, 3124, N'Kooi', CAST(N'2017-07-30 09:25:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-30 09:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3686, 3124, N'Me so amh', CAST(N'2017-07-30 09:25:00' AS SmallDateTime), NULL, 3183, 1, NULL, CAST(N'2017-07-30 09:25:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3687, 3129, N'ثاني ', CAST(N'2017-08-01 11:22:00' AS SmallDateTime), NULL, 3188, 1, NULL, CAST(N'2017-08-01 11:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3688, 3129, N'هل من جديد ', CAST(N'2017-08-01 11:23:00' AS SmallDateTime), NULL, 3188, 1, NULL, CAST(N'2017-08-01 11:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3689, 3129, N'شكرا ', CAST(N'2017-08-01 11:23:00' AS SmallDateTime), NULL, 3189, 1, NULL, CAST(N'2017-08-01 11:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3690, 3129, N'هلا ', CAST(N'2017-08-01 11:24:00' AS SmallDateTime), NULL, 3188, 1, NULL, CAST(N'2017-08-01 11:24:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3691, 3129, N'Hi', CAST(N'2017-08-02 12:40:00' AS SmallDateTime), NULL, 3188, 1, NULL, CAST(N'2017-08-02 12:40:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3692, 3129, N'D', CAST(N'2017-08-02 13:50:00' AS SmallDateTime), NULL, 3188, 1, NULL, CAST(N'2017-08-02 13:50:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3693, 3130, N'Good', CAST(N'2017-08-02 13:51:00' AS SmallDateTime), NULL, 3190, 1, NULL, CAST(N'2017-08-02 13:51:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3694, 3130, N'59', CAST(N'2017-08-04 00:16:00' AS SmallDateTime), NULL, 3191, 1, NULL, CAST(N'2017-08-04 00:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3695, 3131, N'THANK', CAST(N'2017-08-06 12:02:00' AS SmallDateTime), NULL, 3192, 1, NULL, CAST(N'2017-08-06 12:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3696, 3131, N'Hi', CAST(N'2017-08-07 10:17:00' AS SmallDateTime), NULL, 3192, 1, NULL, CAST(N'2017-08-07 10:17:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3697, 3132, N'Siya', CAST(N'2017-08-07 10:18:00' AS SmallDateTime), NULL, 3193, 1, NULL, CAST(N'2017-08-07 10:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3698, 3132, N'Khalid ', CAST(N'2017-08-07 10:19:00' AS SmallDateTime), NULL, 3193, 1, NULL, CAST(N'2017-08-07 10:19:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3699, 3127, N'Hi', CAST(N'2017-08-07 10:21:00' AS SmallDateTime), NULL, 3186, 1, NULL, CAST(N'2017-08-07 10:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3700, 3133, N'Jzvs', CAST(N'2017-08-07 10:23:00' AS SmallDateTime), NULL, 3194, 1, NULL, CAST(N'2017-08-07 10:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3701, 3132, N'Hi ', CAST(N'2017-08-07 10:32:00' AS SmallDateTime), NULL, 3193, 1, NULL, CAST(N'2017-08-07 10:32:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3702, 3134, N'Test', CAST(N'2017-08-07 11:36:00' AS SmallDateTime), NULL, 3195, 1, NULL, CAST(N'2017-08-07 11:36:00' AS SmallDateTime))
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
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3173, 3120, 1069, 1069, CAST(N'2017-07-26 08:48:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3174, 3120, 1068, 1068, CAST(N'2017-07-26 08:54:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3175, 3121, 1069, 1068, CAST(N'2017-07-26 09:05:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3176, 3121, 1068, 1068, CAST(N'2017-07-26 09:12:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3177, 3120, 1070, 1068, CAST(N'2017-07-26 09:14:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3178, 3122, 1069, 1069, CAST(N'2017-07-26 09:14:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3179, 3122, 1068, 1068, CAST(N'2017-07-26 09:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3180, 3123, 1069, 1069, CAST(N'2017-07-26 09:20:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3181, 3124, 1069, 1069, CAST(N'2017-07-26 09:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3182, 3124, 1068, 1068, CAST(N'2017-07-26 09:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3183, 3124, 1070, 1068, CAST(N'2017-07-26 09:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3184, 3125, 1070, 1070, CAST(N'2017-07-26 09:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3185, 3126, 1070, 1070, CAST(N'2017-07-26 09:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3186, 3127, 1070, 1070, CAST(N'2017-07-26 09:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3187, 3128, 1070, 1070, CAST(N'2017-07-26 09:55:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3188, 3129, 56, 56, CAST(N'2017-08-01 11:22:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3189, 3129, 1068, 1068, CAST(N'2017-08-01 11:23:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3190, 3130, 56, 56, CAST(N'2017-08-02 13:50:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3191, 3130, 1068, 1068, CAST(N'2017-08-04 00:16:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3192, 3131, 56, 56, CAST(N'2017-08-06 12:02:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3193, 3132, 56, 56, CAST(N'2017-08-07 10:18:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3194, 3133, 1070, 1070, CAST(N'2017-08-07 10:21:00' AS SmallDateTime))
GO
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID], [CREATED_BY], [CREATED_DATE]) VALUES (3195, 3134, 1071, 1071, CAST(N'2017-08-07 11:35:00' AS SmallDateTime))
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
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3120, 1, N'Test', N'Test ticket ', N'1/3120/20170726084809914.jpg', 1, 4, NULL, 1069, CAST(N'2017-07-26 08:48:00' AS SmallDateTime), 1069, CAST(N'2017-07-26 09:19:00' AS SmallDateTime), N'3nI9B780', 1069, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3121, 1, N'summer', N'test', NULL, 1, 2, NULL, 1068, CAST(N'2017-07-26 09:05:00' AS SmallDateTime), 1069, CAST(N'2017-07-26 09:19:00' AS SmallDateTime), N'6rT61354', 1069, 2)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3122, 1, N'Manifesto of goodness', N'This is a manifesto of goodness campaign ', N'1/3122/20170726091411336.jpg', 1, 2, NULL, 1069, CAST(N'2017-07-26 09:14:00' AS SmallDateTime), 1069, CAST(N'2017-07-29 10:24:00' AS SmallDateTime), N'9nK85B33', 1069, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3123, 1, N'Testing gkjng kn ', N'This is something amazing ', NULL, 1, 1, NULL, 1069, CAST(N'2017-07-26 09:20:00' AS SmallDateTime), NULL, NULL, N'6iD02DBB', 1069, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3124, 1, N'Tickets are increausng ', N'Tickets count increasing kikenanythng ', N'1/3124/20170726092044932.jpg', 1, 1, NULL, 1069, CAST(N'2017-07-26 09:21:00' AS SmallDateTime), NULL, NULL, N'5eU7811C', 1069, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3125, 1, N'Hebe', N'Djsbe', NULL, 1, 1, NULL, 1070, CAST(N'2017-07-26 09:55:00' AS SmallDateTime), NULL, NULL, N'4oE42CE8', 1070, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3126, 1, N'Nxbxjd', N'Bxbdjd', NULL, 1, 1, NULL, 1070, CAST(N'2017-07-26 09:55:00' AS SmallDateTime), NULL, NULL, N'8iV4CEF0', 1070, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3127, 1, N'Cnbdjd', N'Djdndjd', NULL, 1, 2, NULL, 1070, CAST(N'2017-07-26 09:55:00' AS SmallDateTime), 1070, CAST(N'2017-08-07 12:50:00' AS SmallDateTime), N'1tM625AA', 1070, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3128, 1, N'Nxndjd', N'Djxjdjd', NULL, 1, 4, NULL, 1070, CAST(N'2017-07-26 09:55:00' AS SmallDateTime), 1070, CAST(N'2017-07-29 08:18:00' AS SmallDateTime), N'3nMEC6AD', 1070, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3129, 1, N'تجربة ', N'اول استفسارات', NULL, 1, 1, NULL, 56, CAST(N'2017-08-01 11:22:00' AS SmallDateTime), NULL, NULL, N'3vR71268', 56, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3130, 1, N'Test a41zz', N'20m is open', NULL, 1, 1, NULL, 56, CAST(N'2017-08-02 13:50:00' AS SmallDateTime), NULL, NULL, N'7aK048BE', 56, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3131, 1, N'Khalid', N'Hi there', NULL, 1, 1, NULL, 56, CAST(N'2017-08-06 12:02:00' AS SmallDateTime), NULL, NULL, N'2yD50D5B', 56, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3132, 1, N'Aljardani ', N'Test', NULL, 1, 1, NULL, 56, CAST(N'2017-08-07 10:18:00' AS SmallDateTime), NULL, NULL, N'7tC50F67', 56, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3133, 1, N'Test with khalid', N'Sbdbs', NULL, 1, 4, NULL, 1070, CAST(N'2017-08-07 10:21:00' AS SmallDateTime), 1070, CAST(N'2017-08-07 12:50:00' AS SmallDateTime), N'6aK6FED9', 1070, 1)
GO
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [TICKET_CODE], [TICKET_OWNER_USER_ID], [TICKET_CREATED_PLATFORM]) VALUES (3134, 1, N'New', N'Hi there', NULL, 1, 1, NULL, 1071, CAST(N'2017-08-07 11:35:00' AS SmallDateTime), NULL, NULL, N'4sSA05F1', 1071, 1)
GO
SET IDENTITY_INSERT [dbo].[TICKETS] OFF
GO
SET IDENTITY_INSERT [dbo].[USER_DETAILS] ON 

GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1068, 1068, N'Admin', N'89898', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1069, 1069, N'Samh', NULL, NULL, 3, 19, NULL, 23185, 1, NULL, NULL, NULL, NULL, 0, 8, N'2987b2af-5cbf-43a3-97d5-041c1f69b869', NULL, NULL, CAST(N'2017-07-26 08:42:00' AS SmallDateTime), NULL, NULL, CAST(N'2017-07-26 09:20:44.933' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1071, 1071, N'Khalid', NULL, NULL, 1, 6, 1056, 70006, 1, NULL, NULL, NULL, NULL, 0, 1, N'04d74090-da11-489d-8635-11a787476838', NULL, NULL, CAST(N'2017-08-07 11:34:00' AS SmallDateTime), NULL, NULL, CAST(N'2017-08-07 11:35:19.970' AS DateTime))
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1072, 1072, N'test', NULL, NULL, NULL, NULL, NULL, 57656, 0, NULL, NULL, NULL, NULL, 0, 1, N'test', NULL, NULL, CAST(N'2017-09-12 12:57:00' AS SmallDateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[USER_DETAILS] ([ID], [USER_ID], [FULL_NAME], [CIVIL_ID], [ADDRESS], [AREA_ID], [WILAYAT_ID], [VILLAGE_ID], [OTP_NUMBER], [IS_OTP_VALIDATED], [SMS_SENT_STATUS], [SMS_SENT_TRANSACTION_DATE], [LAST_LOGGED_IN_DATE], [IS_TICKET_SUBMISSION_RESTRICTED], [TICKET_SUBMISSION_INTERVAL_DAYS], [NO_OF_TIMES_OTP_SEND], [DEVICE_ID], [PREFERED_LANGUAGE_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE], [LAST_TICKET_SUBMISSION_DATE]) VALUES (1097, 1097, N'test', NULL, NULL, NULL, NULL, NULL, 47511, 0, 1, CAST(N'2017-09-18 21:53:00' AS SmallDateTime), NULL, NULL, 0, 2, N'test', 2, NULL, CAST(N'2017-09-18 21:53:00' AS SmallDateTime), NULL, CAST(N'2017-09-18 21:53:00' AS SmallDateTime), NULL)
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
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1069, NULL, NULL, 4, N'05447423', N'Samh@takamul.com', 1, 1, 0, NULL, NULL, CAST(N'2017-07-26 08:42:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1071, NULL, NULL, 4, N'99885080', N'K@k.k', 1, 1, 0, NULL, NULL, CAST(N'2017-08-07 11:34:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1072, NULL, NULL, 4, N'91534771', N'test@test.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-12 12:57:00' AS SmallDateTime), NULL, NULL)
GO
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1097, NULL, NULL, 4, N'98455049', N'test@test.com', 1, 1, 0, NULL, NULL, CAST(N'2017-09-18 21:53:00' AS SmallDateTime), NULL, NULL)
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
/****** Object:  StoredProcedure [dbo].[DeleteTicket]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[DeleteTicketParticipant]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 9/18/2017 11:32:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE[dbo].[ELMAH_GetErrorsXml]  
  
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
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllActiveEvents]    Script Date: 9/18/2017 11:32:44 PM ******/
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
	EVENT_IMG_FILE_PATH
	FROM dbo.EVENTS  EN
	WHERE 
		( EN.APPLICATION_ID = @Pin_ApplicationId OR @Pin_ApplicationId IS NULL ) AND
		( EN.ID = @Pin_EventId  OR @Pin_EventId IS NULL ) AND
		( EN.LANGUAGE_ID = @Pin_LanguageId )
	ORDER BY EN.ID DESC
	
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllActiveNews]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllActiveTickets]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllApplications]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllAreas]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllMembers]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllTickets]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllTicketStatusLookup]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllVillages]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllWilayats]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationDetails]    Script Date: 9/18/2017 11:32:44 PM ******/
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
		A.APPLICATION_EXPIRY_DATE
    FROM 
		 APPLICATIONS A
	WHERE
		( A.ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL )
END

GO
/****** Object:  StoredProcedure [dbo].[GetApplicationStatistics]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationUsers]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationUsersByUserTypes]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetEventDetails]    Script Date: 9/18/2017 11:32:44 PM ******/
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
	EVENT_IMG_FILE_PATH
	FROM EVENTS
	where 
		ID = @Pin_EventId

	
END








GO
/****** Object:  StoredProcedure [dbo].[GetEventsByDate]    Script Date: 9/18/2017 11:32:44 PM ******/
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
      ,[IS_ACTIVE]
	  FROM [Takamul].[dbo].[EVENTS]
		WHERE EVENT_DATE=@Pin_Eventdate AND APPLICATION_ID = @Pin_ApplicationId
		ORDER BY EVENT_DATE ASC
END









GO
/****** Object:  StoredProcedure [dbo].[GetMemberInfo]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetMobileAppUserInfo]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetMoreTicketChats]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNewsDetails]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTicketChats]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTicketParticipants]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTop5TicketsByStatus]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetUserDetails]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Inc_GetAllActiveEvents]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertApplication]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertMobileUser]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertTicket]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertTicketChat]    Script Date: 9/18/2017 11:32:44 PM ******/
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
	SELECT @Pout_DeviceID = UD.DEVICE_ID  
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
/****** Object:  StoredProcedure [dbo].[InsertTicketParticipant]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertUser]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ResendOPTNumber]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ResolveTicket]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SendOTPOnAppReinstall]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateApplication]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateOTPStatus]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateProfileInformation]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateTicket]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateUserPassword]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateUserStatus]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UserLogin]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_LogErrors]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumber]    Script Date: 9/18/2017 11:32:44 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumberReinstall]    Script Date: 9/18/2017 11:32:44 PM ******/
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
