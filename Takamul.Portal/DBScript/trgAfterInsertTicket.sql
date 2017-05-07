USE [Takamul]
GO
/****** Object:  Trigger [dbo].[trgAfterInsertTicket]    Script Date: 5/7/2017 2:30:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trgAfterInsertTicket] ON [dbo].[TICKETS] 
FOR INSERT
AS
	declare @randomTicketCode varchar(10);
	SELECT @randomTicketCode = cast((Abs(Checksum(NewId()))%10) as varchar(1)) + 
       char(ascii('a')+(Abs(Checksum(NewId()))%25)) +
       char(ascii('A')+(Abs(Checksum(NewId()))%25)) +
       left(newid(),5);
	
	DECLARE @ticketID INT
	SELECT @ticketID = ID
	FROM INSERTED

	WHILE  EXISTS (SELECT * FROM TICKETS WHERE TICKET_CODE = @randomTicketCode)
    BEGIN

        SELECT @randomTicketCode = cast((Abs(Checksum(NewId()))%10) as varchar(1)) + 
       char(ascii('a')+(Abs(Checksum(NewId()))%25)) +
       char(ascii('A')+(Abs(Checksum(NewId()))%25)) +
       left(newid(),5);
    END

	UPDATE TICKETS
	SET
		TICKET_CODE = @randomTicketCode
	WHERE ID = @ticketID
