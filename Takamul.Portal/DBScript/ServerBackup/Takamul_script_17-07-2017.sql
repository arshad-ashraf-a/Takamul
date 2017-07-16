USE [Takamul_Production]
GO
/****** Object:  UserDefinedFunction [dbo].[fnCheckUserStatus]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_ENTITIES]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_PRIVILLAGES]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_SETTINGS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[APPLICATION_USERS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[APPLICATIONS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[AREA_MASTER]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[DB_LOGS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[EVENTS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[MEMBER_INFO]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[NEWS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[TICKET_CHAT_DETAILS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[TICKET_CHAT_TYPES]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[TICKET_PARTICIPANTS]    Script Date: 7/16/2017 1:06:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TICKET_PARTICIPANTS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TICKET_ID] [int] NULL,
	[USER_ID] [int] NULL,
 CONSTRAINT [PK_TICKET_PARTICIPANTS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TICKET_STATUS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[TICKETS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
 CONSTRAINT [PK_ISSUES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USER_DETAILS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
	[LAST_LOGGED_IN_DATE] [smalldatetime] NULL,
	[IS_TICKET_SUBMISSION_RESTRICTED] [bit] NULL,
	[TICKET_SUBMISSION_INTERVAL_DAYS] [int] NULL CONSTRAINT [DF_USER_DETAILS_TICKET_SUBMISSION_INTERVAL_DAYS]  DEFAULT ((0)),
	[NO_OF_TIMES_OTP_SEND] [int] NULL,
	[DEVICE_ID] [nvarchar](max) NULL,
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
/****** Object:  Table [dbo].[USER_TYPES]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[USERS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[VILLAGE_MASTER]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [dbo].[WILAYAT_MASTER]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  Table [nanocomp_production].[ABOUT_APP]    Script Date: 7/16/2017 1:06:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [nanocomp_production].[ABOUT_APP](
	[Title] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [nanocomp_production].[ABOUTAPP_LINKS]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[DeleteTicket]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllActiveEvents]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllActiveNews]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllActiveTickets]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllApplications]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllAreas]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllMembers]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllTickets]    Script Date: 7/16/2017 1:06:00 PM ******/
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
		TS.STATUS_NAME TICKET_STATUS_NAME
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
		TS.STATUS_NAME
	ORDER BY T.ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY
END

















GO
/****** Object:  StoredProcedure [dbo].[GetAllTicketStatusLookup]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllVillages]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllWilayats]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationDetails]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationStatistics]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApplicationUsers]    Script Date: 7/16/2017 1:06:00 PM ******/
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
		A.APPLICATION_NAME
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
		A.APPLICATION_NAME
	ORDER BY U.ID DESC
OFFSET ((@Pin_PageNumber - 1) * @Pin_RowspPage) ROWS
FETCH NEXT @Pin_RowspPage ROWS ONLY
END

GO
/****** Object:  StoredProcedure [dbo].[GetEventDetails]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetEventsByDate]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetMemberInfo]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetMobileAppUserInfo]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetMoreTicketChats]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetNewsDetails]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTicketChats]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetTop5TicketsByStatus]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetUserDetails]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Inc_GetAllActiveEvents]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertApplication]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertMobileUser]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertTicket]    Script Date: 7/16/2017 1:06:00 PM ******/
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
	@Pin_ApplicationId		int,
	@Pin_UserId				int,
	@Pin_TicketName			nvarchar(300),
	@Pin_TicketDesciption	nvarchar(4000),
	@Pin_DefaultImagePath	varchar(500) = null,
	@Pout_DeviceID			varchar(50) output,
	@Pout_TicketID			int output,
	@Pout_Error				int output
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
		USER_ID
	) 
	VALUES
	(
		@v_TicketID,
		@Pin_UserId
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
/****** Object:  StoredProcedure [dbo].[InsertTicketChat]    Script Date: 7/16/2017 1:06:00 PM ******/
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
			USER_ID
		) 
		VALUES
		(
			@Pin_TicketId,
			@Pin_Ticket_Participant_Id
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
/****** Object:  StoredProcedure [dbo].[InsertUser]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ResendOPTNumber]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ResolveTicket]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SendOTPOnAppReinstall]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateApplication]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateProfileInformation]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateTicket]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateUserPassword]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateUserStatus]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UserLogin]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_LogErrors]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumber]    Script Date: 7/16/2017 1:06:00 PM ******/
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
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumberReinstall]    Script Date: 7/16/2017 1:06:00 PM ******/
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
