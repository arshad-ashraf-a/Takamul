USE [Takamul]
GO
/****** Object:  Table [dbo].[APPLICATION_SETTINGS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[APPLICATION_USERS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[APPLICATIONS]    Script Date: 5/3/2017 12:06:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APPLICATIONS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[APPLICATION_NAME] [varchar](200) NULL,
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
/****** Object:  Table [dbo].[AREA_MASTER]    Script Date: 5/3/2017 12:06:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AREA_MASTER](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AREA_NAME] [varchar](100) NULL,
 CONSTRAINT [PK_AREA_MASTER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DB_LOGS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[EVENTS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[MEMBER_INFO]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[NEWS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[TICKET_CHAT_DETAILS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[TICKET_CHAT_TYPES]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[TICKET_PARTICIPANTS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[TICKET_STATUS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[TICKETS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	[TICKET_DESCRIPTION] [varchar](5000) NULL,
	[DEFAULT_IMAGE] [varchar](500) NULL,
	[IS_ACTIVE] [bit] NULL,
	[TICKET_STATUS_ID] [int] NULL,
	[TICKET_STATUS_REMARK] [varchar](1000) NULL,
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
/****** Object:  Table [dbo].[USER_DETAILS]    Script Date: 5/3/2017 12:06:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[USER_DETAILS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[USER_ID] [int] NULL,
	[FULL_NAME] [varchar](100) NULL,
	[CIVIL_ID] [varchar](50) NULL,
	[ADDRESS] [varchar](300) NULL,
	[AREA_ID] [int] NULL,
	[WILAYAT_ID] [int] NULL,
	[VILLAGE_ID] [int] NULL,
	[OTP_NUMBER] [int] NULL,
	[IS_OTP_VALIDATED] [bit] NULL,
	[SMS_SENT_STATUS] [bit] NULL,
	[LAST_LOGGED_IN_DATE] [smalldatetime] NULL,
	[LAST_TICKET_SUBMISSION_DATE] [smalldatetime] NULL,
	[IS_TICKET_SUBMISSION_RESTRICTED] [bit] NULL,
	[TICKET_SUBMISSION_INTERVAL_DAYS] [int] NULL,
	[NO_OF_TIMES_OTP_SEND] [int] NULL,
	[CREATED_BY] [int] NULL,
	[CREATED_DATE] [smalldatetime] NULL,
	[MODIFIED_BY] [int] NULL,
	[MODIFIED_DATE] [smalldatetime] NULL,
 CONSTRAINT [PK_USER_DETAILS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USER_TYPES]    Script Date: 5/3/2017 12:06:53 AM ******/
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
/****** Object:  Table [dbo].[USERS]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	[IS_ACTIVE] [bit] NULL,
	[IS_BLOCKED] [bit] NULL,
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
/****** Object:  Table [dbo].[VILLAGE_MASTER]    Script Date: 5/3/2017 12:06:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VILLAGE_MASTER](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VILLAGE_NAME] [varchar](100) NULL,
 CONSTRAINT [PK_VILLAGE_NAME] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WILAYAT_MASTER]    Script Date: 5/3/2017 12:06:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WILAYAT_MASTER](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WILAYAT_NAME] [varchar](100) NULL,
 CONSTRAINT [PK_WILAYAT_MASTER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[APPLICATIONS] ON 

INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO_PATH], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, N'Application 1', NULL, NULL, CAST(N'2017-01-01 00:00:00' AS SmallDateTime), NULL, 1, NULL, CAST(N'2017-01-01 00:00:00' AS SmallDateTime), NULL, NULL)
INSERT [dbo].[APPLICATIONS] ([ID], [APPLICATION_NAME], [APPLICATION_LOGO_PATH], [DEFAULT_THEME_COLOR], [APPLICATION_EXPIRY_DATE], [APPLICATION_TOKEN], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, N'Application 2', NULL, NULL, CAST(N'2017-01-01 00:00:00' AS SmallDateTime), NULL, 1, NULL, CAST(N'2017-01-01 00:00:00' AS SmallDateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[APPLICATIONS] OFF
SET IDENTITY_INSERT [dbo].[DB_LOGS] ON 

INSERT [dbo].[DB_LOGS] ([ERROR_ID], [SP_NAME], [ERROR_DESC], [CREATED_DATE]) VALUES (CAST(1 AS Numeric(18, 0)), N'InsertTicket', N'String or binary data would be truncated.', CAST(N'2017-04-07 01:08:00' AS SmallDateTime))
SET IDENTITY_INSERT [dbo].[DB_LOGS] OFF
SET IDENTITY_INSERT [dbo].[EVENTS] ON 

INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, 1, N'Mathrubhumi AR Rahman Show', N'AR Rahman perfroming live concert in Dubai', CAST(N'2017-04-22 00:00:00' AS SmallDateTime), N'Dubai', N'787878', N'54545', 1, 1, CAST(N'2017-04-22 00:00:00' AS SmallDateTime), 1, CAST(N'2017-04-22 00:00:00' AS SmallDateTime))
INSERT [dbo].[EVENTS] ([ID], [APPLICATION_ID], [EVENT_NAME], [EVENT_DESCRIPTION], [EVENT_DATE], [EVENT_LOCATION_NAME], [EVENT_LATITUDE], [EVENT_LONGITUDE], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, 1, N'Zig Zag Show', N'Mr.Pinky Live', CAST(N'2017-04-22 00:00:00' AS SmallDateTime), N'Dubai', N'787878', N'54545', 0, 1, CAST(N'2017-04-22 00:00:00' AS SmallDateTime), 2, CAST(N'2017-05-02 23:57:00' AS SmallDateTime))
SET IDENTITY_INSERT [dbo].[EVENTS] OFF
SET IDENTITY_INSERT [dbo].[NEWS] ON 

INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, 1, N'What is Lorem Ipsum?', NULL, N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[NEWS] ([ID], [APPLICATION_ID], [NEWS_TITLE], [NEWS_IMG_FILE_PATH], [NEWS_CONTENT], [IS_NOTIFY_USER], [IS_ACTIVE], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, 1, N'Where does it come from?', NULL, N'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.', 0, 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[NEWS] OFF
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_DETAILS] ON 

INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (1, 1, N'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using ''Content here, content here'', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for ''lorem ipsum'' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).

', CAST(N'2017-01-02 00:00:00' AS SmallDateTime), NULL, 1, 1, NULL, NULL)
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (2, 1, N'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using ''Content here, content here'', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for ''lorem ipsum'' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).', CAST(N'2017-01-02 00:00:00' AS SmallDateTime), NULL, 1, 1, NULL, NULL)
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (4, 1, NULL, CAST(N'2017-01-02 00:00:00' AS SmallDateTime), N'face1.jpg', 1, 3, NULL, NULL)
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (5, 1, NULL, CAST(N'2017-01-02 00:00:00' AS SmallDateTime), N'face2.jpg', 1, 3, NULL, NULL)
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (6, 1, NULL, CAST(N'2017-01-02 00:00:00' AS SmallDateTime), N'face3.jpg', 1, 3, NULL, NULL)
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (7, 1, N'sample string 4', CAST(N'2017-04-07 01:36:00' AS SmallDateTime), N'1/1/20170407013606698.jpg', 1, 3, NULL, CAST(N'2017-04-07 01:36:00' AS SmallDateTime))
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (8, 1, N'sample string 4', CAST(N'2017-04-07 01:37:00' AS SmallDateTime), N'1/1/20170407013725116.jpg', 1, 3, NULL, CAST(N'2017-04-07 01:37:00' AS SmallDateTime))
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (9, 1, N'sample string 4', CAST(N'2017-04-07 01:39:00' AS SmallDateTime), N'1/1/20170407013842896.jpg', 1, 3, NULL, CAST(N'2017-04-07 01:39:00' AS SmallDateTime))
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (10, 1, N'sample string 4', CAST(N'2017-04-07 01:39:00' AS SmallDateTime), N'1/1/20170407013919042.jpg', 1, 3, NULL, CAST(N'2017-04-07 01:39:00' AS SmallDateTime))
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (11, 1, N'sample string 4', CAST(N'2017-04-07 01:40:00' AS SmallDateTime), N'1/1/20170407013947177.jpg', 1, 3, NULL, CAST(N'2017-04-07 01:40:00' AS SmallDateTime))
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (12, 1, N'sample string 4', CAST(N'2017-04-07 01:40:00' AS SmallDateTime), N'1/1/20170407014022586.jpg', 1, 3, NULL, CAST(N'2017-04-07 01:40:00' AS SmallDateTime))
INSERT [dbo].[TICKET_CHAT_DETAILS] ([ID], [TICKET_ID], [REPLY_MESSAGE], [REPLIED_DATE], [REPLY_FILE_PATH], [TICKET_PARTICIPANT_ID], [TICKET_CHAT_TYPE_ID], [CREATED_BY], [CREATED_DATE]) VALUES (13, 1, N'sample string 4', CAST(N'2017-04-07 01:41:00' AS SmallDateTime), N'1/1/20170407014042409.jpg', 1, 3, NULL, CAST(N'2017-04-07 01:41:00' AS SmallDateTime))
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_DETAILS] OFF
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_TYPES] ON 

INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (1, N'text')
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (2, N'png')
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (3, N'jpg')
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (4, N'jpeg')
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (5, N'doc')
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (6, N'docx')
INSERT [dbo].[TICKET_CHAT_TYPES] ([ID], [CHAT_TYPE]) VALUES (7, N'pdf')
SET IDENTITY_INSERT [dbo].[TICKET_CHAT_TYPES] OFF
SET IDENTITY_INSERT [dbo].[TICKET_PARTICIPANTS] ON 

INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID]) VALUES (1, 1, 1)
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID]) VALUES (2, 1, 2)
INSERT [dbo].[TICKET_PARTICIPANTS] ([ID], [TICKET_ID], [USER_ID]) VALUES (3, 3, 1)
SET IDENTITY_INSERT [dbo].[TICKET_PARTICIPANTS] OFF
SET IDENTITY_INSERT [dbo].[TICKET_STATUS] ON 

INSERT [dbo].[TICKET_STATUS] ([ID], [STATUS_NAME]) VALUES (1, N'Open')
INSERT [dbo].[TICKET_STATUS] ([ID], [STATUS_NAME]) VALUES (2, N'Closed')
INSERT [dbo].[TICKET_STATUS] ([ID], [STATUS_NAME]) VALUES (3, N'Rejected')
SET IDENTITY_INSERT [dbo].[TICKET_STATUS] OFF
SET IDENTITY_INSERT [dbo].[TICKETS] ON 

INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, NULL, N'What is Lorem Ipsum?', N'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', N'face5.jpg', 1, 1, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, 1, N'sample string 3', N'sample string 4', N'/9j/4QAYRXhpZgAASUkqAAgAAAAAAAAAAAAAAP/sABFEdWNreQABAAQAAAAyAAD/4QMtaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLwA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA1LjMtYzAxMSA2Ni4xNDU2NjEsIDIwMTIvMDIvMDYtMTQ6NTY6MjcgICAgICAgICI+IDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAv', 1, 1, NULL, NULL, CAST(N'2017-04-07 01:08:00' AS SmallDateTime), NULL, NULL)
INSERT [dbo].[TICKETS] ([ID], [APPLICATION_ID], [TICKET_NAME], [TICKET_DESCRIPTION], [DEFAULT_IMAGE], [IS_ACTIVE], [TICKET_STATUS_ID], [TICKET_STATUS_REMARK], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (3, 1, N'sample string 3', N'sample string 4', N'1/3/20170407010957250.jpg', 1, 1, NULL, NULL, CAST(N'2017-04-07 01:10:00' AS SmallDateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[TICKETS] OFF
SET IDENTITY_INSERT [dbo].[USER_TYPES] ON 

INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (1, N'Admin')
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (2, N'Member')
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (3, N'Staff')
INSERT [dbo].[USER_TYPES] ([ID], [TYPE]) VALUES (4, N'MobileUser')
SET IDENTITY_INSERT [dbo].[USER_TYPES] OFF
SET IDENTITY_INSERT [dbo].[USERS] ON 

INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (1, N'admin', N'admin', 1, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[USERS] ([ID], [USER_NAME], [PASSWORD], [USER_TYPE_ID], [PHONE_NUMBER], [EMAIL], [APPLICATION_ID], [IS_ACTIVE], [IS_BLOCKED], [BLOCKED_REMARKS], [CREATED_BY], [CREATED_DATE], [MODIFIED_BY], [MODIFIED_DATE]) VALUES (2, N'admin', N'admin', 4, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[USERS] OFF
ALTER TABLE [dbo].[USER_DETAILS] ADD  CONSTRAINT [DF_USER_DETAILS_IS_OTP_VALIDATED]  DEFAULT ((0)) FOR [IS_OTP_VALIDATED]
GO
ALTER TABLE [dbo].[USER_DETAILS] ADD  CONSTRAINT [DF_USER_DETAILS_TICKET_SUBMISSION_INTERVAL_DAYS]  DEFAULT ((0)) FOR [TICKET_SUBMISSION_INTERVAL_DAYS]
GO
ALTER TABLE [dbo].[EVENTS]  WITH CHECK ADD  CONSTRAINT [FK_EVENTS_APPLICATIONS] FOREIGN KEY([APPLICATION_ID])
REFERENCES [dbo].[APPLICATIONS] ([ID])
GO
ALTER TABLE [dbo].[EVENTS] CHECK CONSTRAINT [FK_EVENTS_APPLICATIONS]
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
ALTER TABLE [dbo].[TICKETS]  WITH CHECK ADD  CONSTRAINT [FK_TICKETS_APPLICATIONS] FOREIGN KEY([APPLICATION_ID])
REFERENCES [dbo].[APPLICATIONS] ([ID])
GO
ALTER TABLE [dbo].[TICKETS] CHECK CONSTRAINT [FK_TICKETS_APPLICATIONS]
GO
/****** Object:  StoredProcedure [dbo].[GetAllActiveEvents]    Script Date: 5/3/2017 12:06:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetAllActiveEvents]
	@Pin_ApplicationId INT = NULL,
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
	IS_ACTIVE
	FROM dbo.EVENTS  EN
	WHERE ( EN.APPLICATION_ID = @Pin_ApplicationId OR @Pin_ApplicationId IS NULL ) AND
	( EN.ID = @Pin_EventId  OR @Pin_EventId IS NULL )

	
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllActiveNews]    Script Date: 5/3/2017 12:06:53 AM ******/
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
		N.IS_ACTIVE = 1 AND
		( N.ID = @Pin_NewsId  OR @Pin_NewsId IS NULL ) AND
		( N.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL )
	ORDER BY N.ID DESC
END









GO
/****** Object:  StoredProcedure [dbo].[GetAllActiveTickets]    Script Date: 5/3/2017 12:06:53 AM ******/
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
		T.TICKET_STATUS_ID,
		T.DEFAULT_IMAGE,
		T.IS_ACTIVE,
		T.TICKET_DESCRIPTION,
		T.TICKET_STATUS_REMARK
    FROM 
		 TICKETS T
	INNER JOIN TICKET_PARTICIPANTS TP ON TP.TICKET_ID = T.ID
	WHERE
		T.IS_ACTIVE = 1 AND
		( T.ID = @Pin_TicketId  OR @Pin_TicketId IS NULL ) AND
		( TP.USER_ID = @Pin_UserId  OR @Pin_UserId IS NULL ) AND
		( T.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL )
	GROUP BY
		T.ID,
		T.APPLICATION_ID,
		T.TICKET_NAME,
		T.TICKET_STATUS_ID,
		T.DEFAULT_IMAGE,
		T.IS_ACTIVE,
		T.TICKET_DESCRIPTION,
		T.TICKET_STATUS_REMARK
	ORDER BY T.ID DESC
END









GO
/****** Object:  StoredProcedure [dbo].[GetApplicationDetails]    Script Date: 5/3/2017 12:06:53 AM ******/
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
create PROCEDURE [dbo].[GetApplicationDetails]
	@Pin_ApplicationId		int = NULL
AS
BEGIN
	SELECT 
		A.ID,
		A.APPLICATION_NAME,
		A.APPLICATION_LOGO_PATH,
		A.APPLICATION_TOKEN,
		A.DEFAULT_THEME_COLOR,
		A.IS_ACTIVE
    FROM 
		 APPLICATIONS A
	WHERE
		( A.ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL )
END









GO
/****** Object:  StoredProcedure [dbo].[GetMemberInfo]    Script Date: 5/3/2017 12:06:53 AM ******/
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
CREATE PROCEDURE [dbo].[GetMemberInfo]
	@Pin_ApplicationId		int = NULL
AS
BEGIN
	SELECT 
		MI.ID,
		MI.APPLICATION_ID,
		MI.USER_ID,
		MI.MEMBER_INFO_TITLE,
		MI.MEMBER_INFO_DESCRIPTION
    FROM 
		 MEMBER_INFO MI
	WHERE
		( MI.APPLICATION_ID = @Pin_ApplicationId  OR @Pin_ApplicationId IS NULL )
END









GO
/****** Object:  StoredProcedure [dbo].[GetMobileAppUserInfo]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	@Pin_UserId		int = NULL
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
		( U.ID = @Pin_UserId  OR @Pin_UserId IS NULL )
END









GO
/****** Object:  StoredProcedure [dbo].[GetTicketChats]    Script Date: 5/3/2017 12:06:53 AM ******/
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
		TCD.TICKET_PARTICIPANT_ID,
		TCD.TICKET_CHAT_TYPE_ID,
		TCT.CHAT_TYPE,
		UD.FULL_NAME PARTICIPANT_FULL_NAME
    FROM 
		 TICKET_CHAT_DETAILS TCD
	INNER JOIN TICKET_CHAT_TYPES TCT ON TCT.ID = TCD.TICKET_CHAT_TYPE_ID
	INNER JOIN TICKET_PARTICIPANTS TP ON TP.ID = TCD.TICKET_PARTICIPANT_ID
	INNER JOIN USERS U ON U.ID = TP.USER_ID
	left JOIN USER_DETAILS UD ON UD.USER_ID = U.ID
	WHERE
		( TCD.TICKET_ID = @Pin_TicketId  OR @Pin_TicketId IS NULL )
	ORDER BY TCD.ID DESC
END









GO
/****** Object:  StoredProcedure [dbo].[InsertMobileUser]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	@Pin_FullName			varchar(100),
	@Pin_PhoneNumber		varchar(50),
	@Pin_Email				varchar(50) = null,
	@Pin_CivilID			varchar(50) = null,
	@Pin_Address			varchar(300) = null,
	@Pin_AreaId				int = null,
	@Pin_WilayatId			int = null,
	@Pin_VillageId			int = null,
	@Pin_OTPNumber			int,
	@Pout_UserID			int output,
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_UserID		 int;

BEGIN TRANSACTION    -- Start the transaction
BEGIN TRY
	
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
		GETDATE()
	) 
	
	--Returning Inserted UserID And Success Status
	set @Pout_UserID = @v_UserID;
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
/****** Object:  StoredProcedure [dbo].[InsertTicket]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	@Pin_TicketName			varchar(300),
	@Pin_TicketDesciption	varchar(5000),
	@Pin_DefaultImagePath	varchar(500) = null,
	@Pout_TicketID			int output,
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_TicketID		 int;

BEGIN TRANSACTION    -- Start the transaction
BEGIN TRY
	
	--Insert into ticket table
	INSERT INTO TICKETS
	(
		APPLICATION_ID,
		TICKET_NAME,
		TICKET_DESCRIPTION,
		DEFAULT_IMAGE,
		TICKET_STATUS_ID,
		IS_ACTIVE,
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
	
	set @Pout_Error = 1;
	set @Pout_TicketID = @v_TicketID;
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
/****** Object:  StoredProcedure [dbo].[InsertTicketChat]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	@Pout_Error					int output
AS
BEGIN
DECLARE @v_UserID		 int;

BEGIN TRANSACTION    -- Start the transaction
BEGIN TRY
	
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
		@Pin_Ticket_Participant_Id,
		@Pin_TicketChatTypeId,
		GETDATE()
	) 

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
/****** Object:  StoredProcedure [dbo].[ResendOPTNumber]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	@Pin_UserId				int,
	@Pin_OTPNumber			int,
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_Count		 int;

BEGIN TRANSACTION    -- Start the transaction
BEGIN TRY
	SELECT @v_Count = NO_OF_TIMES_OTP_SEND
	FROM USER_DETAILS 
	WHERE USER_ID = @Pin_UserId;
	
	-- Maximum attempt 5 times exceeded
	if(@v_Count > 5)
	begin
		set @Pout_Error = -2;
		return;
	end

	SELECT @v_Count = COUNT(1) 
	FROM USER_DETAILS 
	WHERE USER_ID = @Pin_UserId AND OTP_NUMBER = @Pin_OTPNumber

	if(@v_Count > 0)
	begin
		--Update otp & verified status 
		UPDATE USER_DETAILS
		SET 
			OTP_NUMBER = @Pin_OTPNumber,
			IS_OTP_VALIDATED = 0,
			NO_OF_TIMES_OTP_SEND = NO_OF_TIMES_OTP_SEND + 1
		WHERE USER_ID = @Pin_UserId
		
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
/****** Object:  StoredProcedure [dbo].[UserLogin]    Script Date: 5/3/2017 12:06:53 AM ******/
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
			UT.TYPE USER_TYPE_NAME
	FROM DBO.USERS U
	INNER JOIN dbo.USER_TYPES UT ON UT.ID = U.USER_TYPE_ID 
	WHERE U.USER_NAME= @UserName AND U.PASSWORD = @Password
END

GO
/****** Object:  StoredProcedure [dbo].[usp_LogErrors]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	@Pin_SPName  nvarchar(20),
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
/****** Object:  StoredProcedure [dbo].[ValidateOPTNumber]    Script Date: 5/3/2017 12:06:53 AM ******/
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
	@Pin_UserId				int,
	@Pin_OTPNumber			int,
	@Pout_Error				int output
AS
BEGIN
DECLARE @v_Count		 int;

BEGIN TRANSACTION    -- Start the transaction
BEGIN TRY
	
	SELECT @v_Count = COUNT(1) 
	FROM USER_DETAILS 
	WHERE USER_ID = @Pin_UserId AND OTP_NUMBER = @Pin_OTPNumber

	if(@v_Count > 0)
	begin
		--Update otp verified status 
		UPDATE USER_DETAILS
		SET IS_OTP_VALIDATED = 1
		WHERE USER_ID = @Pin_UserId
		
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
