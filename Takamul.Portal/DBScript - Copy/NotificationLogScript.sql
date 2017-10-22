USE [Takamul]
GO
/****** Object:  Table [dbo].[NOTIFICATION_LOGS]    Script Date: 9/27/2017 12:58:38 PM ******/
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
	[REQUEST_JSON] [varchar](5000) NULL,
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
/****** Object:  StoredProcedure [dbo].[InsertNotificationLog]    Script Date: 9/27/2017 12:58:38 PM ******/
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
	@Pin_RequestJSON				varchar(5000),
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
