/****** Object:  Database [nexus_dev_store]   Script Date: 12/02/2020 10:46:01 AM ******/
CREATE DATABASE [nexus_dev_store] CONTAINMENT = PARTIAL COLLATE SQL_Latin1_General_CP1_CI_AS
GO

ALTER DATABASE [nexus_dev_store]SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [nexus_dev_store]SET ANSI_NULLS OFF 
GO

ALTER DATABASE [nexus_dev_store]SET ANSI_PADDING OFF 
GO

ALTER DATABASE [nexus_dev_store]SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [nexus_dev_store]SET ARITHABORT OFF 
GO

ALTER DATABASE [nexus_dev_store]SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [nexus_dev_store]SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [nexus_dev_store]SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [nexus_dev_store]SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [nexus_dev_store]SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [nexus_dev_store]SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [nexus_dev_store]SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [nexus_dev_store]SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [nexus_dev_store]SET ALLOW_SNAPSHOT_ISOLATION ON 
GO

ALTER DATABASE [nexus_dev_store]SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [nexus_dev_store]SET READ_COMMITTED_SNAPSHOT ON 
GO

ALTER DATABASE [nexus_dev_store]SET  MULTI_USER 
GO

--ALTER DATABASE [nexus_dev_store]SET ENCRYPTION ON
GO

ALTER DATABASE [nexus_dev_store]SET QUERY_STORE = ON
GO

ALTER DATABASE [nexus_dev_store]SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 100, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO

/*** The scripts of database scoped configurations in Azure should be executed inside the target database connection. ***/
GO

-- ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 2;
GO

ALTER DATABASE [nexus_dev_store]SET  READ_WRITE 
GO

USE [nexus_dev_store];
CREATE USER [nexus_dev_store_user] with password=N'devme@1234567';
ALTER ROLE db_owner ADD MEMBER [nexus_dev_store_user] ;
GO
CREATE TABLE [msg_audit] (

	transaction_id   VARCHAR(96)   NOT NULL		
	,conversation_id VARCHAR(96)   NOT NULL
 	,json_message    VARCHAR(MAX)  NOT NULL
        ,CONSTRAINT pk_msg_audit PRIMARY KEY(transaction_id,conversation_id)

);
GO	
CREATE TABLE [claim_check] (

	transaction_id   VARCHAR(96)  NOT NULL
	,conversation_id VARCHAR(96)  NOT NULL
 	,json_message    VARCHAR(MAX) NOT NULL
        ,CONSTRAINT pk_claim_check PRIMARY KEY(transaction_id)

);
GO


CREATE PROCEDURE dbo.setAuditTrail
	@transactionId varchar(96)
	, @conversationid varchar(96)
	, @jsonMsg varchar(max)
AS
SET NOCOUNT ON;
INSERT INTO dbo.msg_audit(
	transaction_id
	,conversation_id
	,json_message
) 
VALUES (
	@transactionid,
	@conversationid,
	@jsonMsg
);
GO

CREATE PROCEDURE dbo.setClaimCheck
	@transactionId varchar(96)
	, @conversationid varchar(96)
	, @jsonMsg varchar(max)
AS
SET NOCOUNT ON;
INSERT INTO dbo.claim_check(
	transaction_id
	,conversation_id
	,json_message
) 
VALUES (
	@transactionid,
	@conversationid,
	@jsonMsg
);
GO

CREATE PROCEDURE dbo.getClaimCheck
	@transactionId varchar(96)

AS
SET NOCOUNT ON;
SELECT 
	transaction_id
	, conversation_id
	, json_message 
FROM dbo.claim_check 
WHERE transaction_id = @transactionid;
GO

CREATE PROCEDURE dbo.deleteClaimCheck
	@transactionId varchar(96)

AS
SET NOCOUNT ON;
DELETE FROM dbo.claim_check WHERE transaction_id = @transactionid;
GO
ALTER TABLE msg_audit ADD created_on DATETIME NOT NULL DEFAULT GETDATE();
GO
ALTER TABLE msg_audit ADD msg_type VARCHAR(64) NULL;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[setAuditTrail]
	@transactionId varchar(96)
	, @conversationid varchar(96)
	, @jsonMsg varchar(max)
    , @msg_type varchar(64)
AS
SET NOCOUNT ON;
INSERT INTO dbo.msg_audit(
	transaction_id
	,conversation_id
	,json_message
    ,msg_type
) 
VALUES (
	@transactionid,
	@conversationid,
	@jsonMsg,
    @msg_type
);

GO
CREATE UNIQUE INDEX ui_transaction_id ON msg_audit(transaction_id);
GO
CREATE FULLTEXT CATALOG ftcat_json_msg AS DEFAULT;
GO
CREATE FULLTEXT INDEX ON msg_audit(json_message)
   KEY INDEX ui_transaction_id
   WITH STOPLIST = SYSTEM;
GO
ALTER TABLE msg_audit ADD work_order_id VARCHAR(128) NULL;
GO
ALTER TABLE msg_audit ADD flow_direction VARCHAR(64) NULL;
GO
EXEC sp_RENAME 'msg_audit.work_order_id' , 'object_id', 'COLUMN';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[setAuditTrail]
	@transactionid varchar(96)
	, @conversationid varchar(96)
	, @jsonMsg varchar(max)
    , @msg_type varchar(64)
    , @objectid varchar(128)
    , @flowdirection varchar(64)
AS
SET NOCOUNT ON;
INSERT INTO dbo.msg_audit
(
	transaction_id
	,conversation_id
	,json_message   
	,msg_type
	,object_id
    ,flow_direction
) 
VALUES 
(

	@transactionid,
	@conversationid,
	@jsonMsg,
	@msg_type,
	@objectid,
	@flowdirection
);


GO
DROP FULLTEXT INDEX ON msg_audit;
GO
DROP FULLTEXT CATALOG ftcat_json_msg;
GO
DROP INDEX ui_transaction_id ON msg_audit;
GO
CREATE NONCLUSTERED INDEX [idx_transaction_id] ON [dbo].[msg_audit]
(
	[transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE msg_audit  
    DROP CONSTRAINT pk_msg_audit ;
GO  
ALTER TABLE msg_audit
  ADD audit_id INT IDENTITY(1,1) NOT NULL;
GO
ALTER TABLE [dbo].[msg_audit] ADD  CONSTRAINT [pk_msg_audit] PRIMARY KEY NONCLUSTERED
(
	[audit_id] ASC
	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX cid_msg_audit_transaction_id_con_id_msg_type ON msg_audit(msg_type, conversation_id,transaction_id) ON [PRIMARY]
GO
ALTER TABLE [claim_check] ADD  claim_state VARCHAR(32) NOT NULL DEFAULT 'OPEN';
GO
ALTER TABLE [claim_check] ADD  created_on DATETIME NOT NULL DEFAULT GETDATE();
GO
ALTER TABLE claim_check
    DROP CONSTRAINT pk_claim_check ;
GO
ALTER TABLE claim_check
    ADD claim_id INT IDENTITY(1,1) NOT NULL;
GO
ALTER TABLE [dbo].[claim_check] ADD  CONSTRAINT [pk_claim_check] PRIMARY KEY NONCLUSTERED
    (
     [claim_id] ASC

        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE claim_check
    ADD failed_msg VARCHAR(MAX) NULL;
GO
CREATE CLUSTERED INDEX cid_claim_check_transaction_id_con_id ON claim_check(conversation_id,transaction_id) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[setClaimCheck]
    @transactionId varchar(96)
    , @conversationid varchar(96)
    , @jsonMsg varchar(max)
AS
    SET NOCOUNT ON;
INSERT INTO dbo.claim_check(
    transaction_id
    ,conversation_id
    ,json_message
    ,claim_state
)
VALUES (
    @transactionid
    ,@conversationid
    ,@jsonMsg
    ,'OPEN'
);
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC sp_RENAME 'claim_check.failed_msg' , 'response_msg', 'COLUMN';
GO
ALTER PROCEDURE [dbo].[deleteClaimCheck]
@conversationid varchar(96)
,@claim_state varchar(32)
,@failed_msg varchar(MAX)

AS
    SET NOCOUNT ON;
UPDATE dbo.claim_check
SET claim_state = @claim_state
  ,response_msg  = @failed_msg
WHERE conversation_id = @conversationid;


GO


