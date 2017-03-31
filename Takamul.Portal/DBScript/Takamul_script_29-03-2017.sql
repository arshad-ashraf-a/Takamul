USE [Takamul]
GO
/****** Object:  Table [dbo].[APPLICATION_SETTINGS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[APPLICATION_USERS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[APPLICATIONS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[EVENTS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[MEMBER_INFO]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[NEWS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
	[NEWS_IMG] [image] NULL,
	[NEWS_CONTENT] [varchar](max) NULL,
	[IS_NOTIFY_USER] [bit] NULL,
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
/****** Object:  Table [dbo].[TICKET_CHAT_DETAILS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[TICKET_DETAILS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[TICKETS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[USER_TYPES]    Script Date: 3/26/2017 8:07:09 AM ******/
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
/****** Object:  Table [dbo].[USERS]    Script Date: 3/26/2017 8:07:09 AM ******/
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
USE [master]
GO
ALTER DATABASE [Takamul] SET  READ_WRITE 
GO
