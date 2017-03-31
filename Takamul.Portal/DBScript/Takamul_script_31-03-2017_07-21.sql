USE [Takamul]
GO
/****** Object:  Table [dbo].[APPLICATION_SETTINGS]    Script Date: 3/31/2017 7:22:16 PM ******/
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
	[SETTINGS_VALUE] [varchar](50) NULL,
 CONSTRAINT [PK_APPLICATION_SETTINGS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[APPLICATION_USERS]    Script Date: 3/31/2017 7:22:16 PM ******/
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
/****** Object:  Table [dbo].[APPLICATIONS]    Script Date: 3/31/2017 7:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APPLICATIONS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_NAME] [varchar](200) NULL,
	[APPLICATION_LOGO] [varchar](300) NULL,
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
/****** Object:  Table [dbo].[EVENTS]    Script Date: 3/31/2017 7:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENTS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[EVENT_NAME] [varchar](300) NULL,
	[EVENT_DESCRIPTION] [varchar](1000) NULL,
	[EVENT_DATE] [smalldatetime] NULL,
	[EVENT_LOCATION_NAME] [varchar](100) NULL,
	[EVENT_LATITUDE] [varchar](50) NULL,
	[EVENT_LONGITUDE] [varchar](50) NULL,
	[IS_ACTIVE] [bit] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_EVENTS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MEMBER_INFO]    Script Date: 3/31/2017 7:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MEMBER_INFO](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[USER_ID] [int] NULL,
	[MEMBER_INFO_TITLE] [varchar](50) NULL,
	[MEMBER_INFO_DESCRIPTION] [varchar](2000) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_MEMBER_INFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NEWS]    Script Date: 3/31/2017 7:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NEWS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[NEWS_TITLE] [varchar](300) NULL,
	[NEWS_IMG_FILE_PATH] [varchar](500) NULL,
	[NEWS_CONTENT] [varchar](max) NULL,
	[IS_NOTIFY_USER] [bit] NULL,
	[IS_ACTIVE] [bit] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_NEWS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TICKET_CHAT_DETAILS]    Script Date: 3/31/2017 7:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TICKET_CHAT_DETAILS](
	[ID] [int] NOT NULL,
	[SORT_ORDER] [int] NULL,
	[TICKET_ID] [int] NOT NULL,
	[REPLY_MESSAGE] [nvarchar](max) NULL,
	[REPLIED_DATE] [smalldatetime] NULL,
	[REPLY_IMG] [image] NULL,
	[REPLIED_BY] [int] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_TICKET_CHAT_DETAILS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TICKET_DETAILS]    Script Date: 3/31/2017 7:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TICKET_DETAILS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TICKET_ID] [int] NULL,
	[TICKET_PARTICIPANT_ID] [int] NULL,
	[MESSAGE_DATA_TYPE] [int] NULL,
	[FILE_PATH] [varchar](500) NULL,
	[REMARKS] [varchar](2000) NULL,
	[PARTICIPANT_LOCATION_NAME] [varchar](200) NULL,
	[PARTICIPANT_LATITUDE] [varchar](50) NULL,
	[PARTICIPANT_LONGITUDE] [varchar](50) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
 CONSTRAINT [PK_TICKET_DETAILS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TICKETS]    Script Date: 3/31/2017 7:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TICKETS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_ID] [int] NULL,
	[TICKET_NAME] [varchar](300) NULL,
	[TICKET_DESCRIPTION] [varchar](1000) NULL,
	[DEFAULT_IMAGE] [varchar](500) NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_ISSUES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USER_TYPES]    Script Date: 3/31/2017 7:22:16 PM ******/
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
/****** Object:  Table [dbo].[USERS]    Script Date: 3/31/2017 7:22:16 PM ******/
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
	[CIVIL_ID] [varchar](50) NULL,
	[ADDRESS] [varchar](300) NULL,
	[APPLICATION_ID] [int] NULL,
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
SET IDENTITY_INSERT [dbo].[APPLICATIONS] ON 

INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, N'Application 1', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, N'Application 2', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[APPLICATIONS] OFF
SET IDENTITY_INSERT [dbo].[NEWS] ON 

INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, 1, N'What is Lorem Ipsum?', NULL, N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, 1, N'Where does it come from?', NULL, N'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.', 0, 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[NEWS] OFF
SET IDENTITY_INSERT [dbo].[USER_TYPES] ON 

INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (1, N'Admin')
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (2, N'Member')
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (3, N'Staff')
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (4, N'MobileUser')
SET IDENTITY_INSERT [dbo].[USER_TYPES] OFF
SET IDENTITY_INSERT [dbo].[USERS] ON 

INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [CIVIL_ID], [ADDRESS], [APPLICATION_ID], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, N'admin', N'admin', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[USERS] OFF
ALTER TABLE [dbo].[NEWS]  WITH CHECK ADD  CONSTRAINT [FK_NEWS_APPLICATIONS] FOREIGN KEY([APPLICATION_ID])
REFERENCES [dbo].[APPLICATIONS] ([ID])
GO
ALTER TABLE [dbo].[NEWS] CHECK CONSTRAINT [FK_NEWS_APPLICATIONS]
GO
ALTER TABLE [dbo].[TICKET_CHAT_DETAILS]  WITH CHECK ADD  CONSTRAINT [FK_TICKET_CHAT_DETAILS_TICKETS] FOREIGN KEY([TICKET_ID])
REFERENCES [dbo].[TICKETS] ([ID])
GO
ALTER TABLE [dbo].[TICKET_CHAT_DETAILS] CHECK CONSTRAINT [FK_TICKET_CHAT_DETAILS_TICKETS]
GO
ALTER TABLE [dbo].[TICKET_DETAILS]  WITH CHECK ADD  CONSTRAINT [FK_TICKET_DETAILS_TICKETS] FOREIGN KEY([TICKET_ID])
REFERENCES [dbo].[TICKETS] ([ID])
GO
ALTER TABLE [dbo].[TICKET_DETAILS] CHECK CONSTRAINT [FK_TICKET_DETAILS_TICKETS]
GO
/****** Object:  StoredProcedure [dbo].[Inc_GetAllActiveNews]    Script Date: 3/31/2017 7:22:16 PM ******/
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
CREATE PROCEDURE [dbo].[Inc_GetAllActiveNews]
	@Pin_ApplicationId		int,
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
		N.NEWS_IMG_FILE_PATH
    FROM 
		 NEWS N
	WHERE
		N.APPLICATION_ID = @Pin_ApplicationId AND
		N.IS_ACTIVE = 1 AND
		( N.ID = @Pin_NewsId  OR @Pin_NewsId IS NULL )
	ORDER BY N.ID DESC
END







GO
/****** Object:  StoredProcedure [dbo].[UserLogin]    Script Date: 3/31/2017 7:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
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
			USER_ID as [ID], 
			USER_NAME ,
			UT.USER_TYPE_NAME
	FROM DBO.USERS U
	INNER JOIN USER_TYPE UT ON UT.USER_TYPE_ID = U.USER_TYPE_ID 
	WHERE USER_NAME= @UserName AND USER_PASSWORD = @Password
END









GO
