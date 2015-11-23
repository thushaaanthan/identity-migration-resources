DECLARE @COMMAND NVARCHAR(200);SELECT @COMMAND= 'ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN DROP CONSTRAINT ' + RC.CONSTRAINT_NAME + ';' FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KF ON RC.CONSTRAINT_NAME = KF.CONSTRAINT_NAME JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KP ON RC.UNIQUE_CONSTRAINT_NAME = KP.CONSTRAINT_NAME WHERE KF.TABLE_NAME = 'IDN_OAUTH1A_REQUEST_TOKEN';EXEC (@COMMAND);

DECLARE @COMMAND NVARCHAR(200);SELECT @COMMAND='ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN DROP CONSTRAINT ' + RC.CONSTRAINT_NAME + ';' FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KF ON RC.CONSTRAINT_NAME = KF.CONSTRAINT_NAME JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KP ON RC.UNIQUE_CONSTRAINT_NAME = KP.CONSTRAINT_NAME WHERE KF.TABLE_NAME = 'IDN_OAUTH1A_ACCESS_TOKEN';EXEC (@COMMAND);

DECLARE @COMMAND NVARCHAR(200);SELECT @COMMAND='ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP CONSTRAINT ' + RC.CONSTRAINT_NAME  + ';' FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KF ON RC.CONSTRAINT_NAME = KF.CONSTRAINT_NAME JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KP ON RC.UNIQUE_CONSTRAINT_NAME = KP.CONSTRAINT_NAME WHERE KF.TABLE_NAME = 'IDN_OAUTH2_ACCESS_TOKEN';EXEC (@COMMAND);

DECLARE @COMMAND NVARCHAR(200);SELECT @COMMAND='ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE DROP CONSTRAINT ' + RC.CONSTRAINT_NAME + ';' FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KF ON RC.CONSTRAINT_NAME = KF.CONSTRAINT_NAME JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KP ON RC.UNIQUE_CONSTRAINT_NAME = KP.CONSTRAINT_NAME WHERE KF.TABLE_NAME = 'IDN_OAUTH2_AUTHORIZATION_CODE';EXEC (@COMMAND);

DECLARE @COMMAND NVARCHAR(200);SELECT @COMMAND='ALTER TABLE IDN_OAUTH_CONSUMER_APPS DROP CONSTRAINT ' + NAME + ';' FROM   sys.key_constraints WHERE  [type] = 'PK' AND [parent_object_id] = Object_id('dbo.IDN_OAUTH_CONSUMER_APPS');EXEC (@COMMAND);

DECLARE @COMMAND NVARCHAR(200);SELECT @COMMAND='ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP CONSTRAINT ' + NAME + ';' FROM   sys.key_constraints WHERE  [type] = 'PK' AND [parent_object_id] = Object_id('dbo.IDN_OAUTH2_ACCESS_TOKEN');EXEC (@COMMAND);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_METADATA]') AND TYPE IN (N'U'))
  CREATE TABLE IDP_METADATA (
    ID INTEGER IDENTITY,
    IDP_ID INTEGER,
    NAME VARCHAR(255) NOT NULL,
    VALUE VARCHAR(255) NOT NULL,
    DISPLAY_NAME VARCHAR(255),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (ID),
    CONSTRAINT IDP_METADATA_CONSTRAINT UNIQUE (IDP_ID, NAME),
    FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

INSERT INTO IDP_METADATA (IDP_ID, NAME, VALUE, DISPLAY_NAME, TENANT_ID) VALUES (1, 'SessionIdleTimeout', '15', 'Session Idle Timeout', -1234);
INSERT INTO IDP_METADATA (IDP_ID, NAME, VALUE, DISPLAY_NAME, TENANT_ID) VALUES (1, 'RememberMeTimeout', '20160', 'RememberMe Timeout', -1234);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_METADATA]') AND TYPE IN (N'U'))
  CREATE TABLE SP_METADATA (
    ID INTEGER IDENTITY,
    SP_ID INTEGER,
    NAME VARCHAR(255) NOT NULL,
    VALUE VARCHAR(255) NOT NULL,
    DISPLAY_NAME VARCHAR(255),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (ID),
    CONSTRAINT SP_METADATA_CONSTRAINT UNIQUE (SP_ID, NAME),
    FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE);

ALTER TABLE IDN_OAUTH_CONSUMER_APPS ADD ID INTEGER NOT NULL IDENTITY PRIMARY KEY;
ALTER TABLE IDN_OAUTH_CONSUMER_APPS ALTER COLUMN CONSUMER_KEY VARCHAR (255)  NOT NULL;
ALTER TABLE IDN_OAUTH_CONSUMER_APPS ADD CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY);

ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN ADD CONSUMER_KEY_ID INTEGER;
UPDATE IDN_OAUTH1A_REQUEST_TOKEN set IDN_OAUTH1A_REQUEST_TOKEN.CONSUMER_KEY_ID = (select IDN_OAUTH_CONSUMER_APPS.ID from IDN_OAUTH_CONSUMER_APPS where IDN_OAUTH_CONSUMER_APPS.CONSUMER_KEY = IDN_OAUTH1A_REQUEST_TOKEN.CONSUMER_KEY);
ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN DROP COLUMN CONSUMER_KEY;
ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN ADD FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE;
ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN ADD TENANT_ID INTEGER DEFAULT -1;

ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN ADD CONSUMER_KEY_ID INTEGER;
UPDATE IDN_OAUTH1A_ACCESS_TOKEN set IDN_OAUTH1A_ACCESS_TOKEN.CONSUMER_KEY_ID = (select IDN_OAUTH_CONSUMER_APPS.ID from IDN_OAUTH_CONSUMER_APPS where IDN_OAUTH_CONSUMER_APPS.CONSUMER_KEY = IDN_OAUTH1A_ACCESS_TOKEN.CONSUMER_KEY);
ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN DROP COLUMN CONSUMER_KEY;
ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN ADD FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE;
ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN ADD TENANT_ID INTEGER DEFAULT -1;

ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD TOKEN_ID VARCHAR (255);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD CONSUMER_KEY_ID INTEGER;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD GRANT_TYPE VARCHAR (50);
UPDATE IDN_OAUTH2_ACCESS_TOKEN set IDN_OAUTH2_ACCESS_TOKEN.CONSUMER_KEY_ID = (select IDN_OAUTH_CONSUMER_APPS.ID from IDN_OAUTH_CONSUMER_APPS where IDN_OAUTH_CONSUMER_APPS.CONSUMER_KEY = IDN_OAUTH2_ACCESS_TOKEN.CONSUMER_KEY);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP CONSTRAINT CON_APP_KEY;
DROP INDEX IDN_OAUTH2_ACCESS_TOKEN.IDX_AT_CK_AU;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP COLUMN CONSUMER_KEY;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD TENANT_ID INTEGER;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD USER_DOMAIN VARCHAR(50);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD REFRESH_TOKEN_TIME_CREATED DATETIME;
UPDATE IDN_OAUTH2_ACCESS_TOKEN SET REFRESH_TOKEN_TIME_CREATED = TIME_CREATED;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD REFRESH_TOKEN_VALIDITY_PERIOD BIGINT;
UPDATE IDN_OAUTH2_ACCESS_TOKEN SET REFRESH_TOKEN_VALIDITY_PERIOD = 84600000;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD TOKEN_SCOPE_HASH VARCHAR (32);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ALTER COLUMN TOKEN_STATE_ID VARCHAR (128);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,TOKEN_STATE,TOKEN_STATE_ID);
CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);
CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE;

ALTER TABLE IDN_OAUTH2_RESOURCE_SCOPE ADD TENANT_ID INTEGER DEFAULT -1;
ALTER TABLE IDN_OPENID_ASSOCIATIONS ADD TENANT_ID INTEGER DEFAULT -1;
ALTER TABLE IDN_THRIFT_SESSION ADD TENANT_ID INTEGER DEFAULT -1;

ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD CONSUMER_KEY_ID INTEGER;
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD TENANT_ID INTEGER;
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD USER_DOMAIN VARCHAR(50);
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD STATE VARCHAR (25) DEFAULT 'ACTIVE';
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD TOKEN_ID VARCHAR(255);
UPDATE IDN_OAUTH2_AUTHORIZATION_CODE set IDN_OAUTH2_AUTHORIZATION_CODE.CONSUMER_KEY_ID = (select IDN_OAUTH_CONSUMER_APPS.ID from IDN_OAUTH_CONSUMER_APPS where IDN_OAUTH_CONSUMER_APPS.CONSUMER_KEY = IDN_OAUTH2_AUTHORIZATION_CODE.CONSUMER_KEY);
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE DROP COLUMN CONSUMER_KEY;
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE;

DROP TABLE IDN_SCIM_PROVIDER;

ALTER TABLE IDN_IDENTITY_USER_DATA ALTER COLUMN DATA_VALUE VARCHAR(255) NULL;

DECLARE @COMMAND NVARCHAR(200);SELECT @COMMAND='ALTER TABLE IDN_ASSOCIATED_ID DROP CONSTRAINT ' + NAME + ';' FROM sys.key_constraints WHERE  [type] = 'UQ' AND [parent_object_id] = Object_id('dbo.IDN_ASSOCIATED_ID');EXEC (@COMMAND);
UPDATE IDN_ASSOCIATED_ID set IDN_ASSOCIATED_ID.IDP_ID = (SELECT IDP.ID FROM IDP WHERE IDP.NAME = IDN_ASSOCIATED_ID.IDP_ID AND IDP.TENANT_ID = IDN_ASSOCIATED_ID.TENANT_ID );
ALTER TABLE IDN_ASSOCIATED_ID ALTER COLUMN IDP_ID INTEGER;
ALTER TABLE IDN_ASSOCIATED_ID ADD UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID);
ALTER TABLE IDN_ASSOCIATED_ID ADD FOREIGN KEY (IDP_ID ) REFERENCES IDP (ID) ON DELETE CASCADE;

DELETE FROM IDN_AUTH_SESSION_STORE;
ALTER TABLE IDN_AUTH_SESSION_STORE ALTER COLUMN SESSION_ID VARCHAR (100) NOT NULL;
ALTER TABLE IDN_AUTH_SESSION_STORE ALTER COLUMN SESSION_TYPE VARCHAR(100) NOT NULL;
ALTER TABLE IDN_AUTH_SESSION_STORE ALTER COLUMN TIME_CREATED BIGINT;
ALTER TABLE IDN_AUTH_SESSION_STORE ADD OPERATION VARCHAR(10) NOT NULL;
ALTER TABLE IDN_AUTH_SESSION_STORE ADD TENANT_ID INTEGER DEFAULT -1;
DECLARE @COMMAND NVARCHAR(200);SELECT @COMMAND='ALTER TABLE IDN_AUTH_SESSION_STORE DROP CONSTRAINT ' + NAME + ';' FROM   sys.key_constraints WHERE  [type] = 'PK' AND [parent_object_id] = Object_id('dbo.IDN_AUTH_SESSION_STORE');EXEC (@COMMAND);
ALTER TABLE IDN_AUTH_SESSION_STORE ADD PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION);

ALTER TABLE SP_APP ADD IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1' NOT NULL;
ALTER TABLE SP_APP ADD IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1' NOT NULL;
ALTER TABLE SP_APP ADD IS_DUMB_MODE CHAR(1) DEFAULT '0';

INSERT INTO IDP_AUTHENTICATOR (TENANT_ID, IDP_ID, NAME) VALUES (-1234, 1, 'IDPProperties');
INSERT INTO IDP_AUTHENTICATOR (TENANT_ID, IDP_ID, NAME) VALUES (-1234, 1, 'passivests');

INSERT INTO  IDP_AUTHENTICATOR_PROPERTY (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY,PROPERTY_VALUE, IS_SECRET ) VALUES (-1234, 3 , 'IdPEntityId', 'localhost', '0');

ALTER TABLE IDP_PROVISIONING_ENTITY ADD LOCAL_ID VARCHAR(255);

CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN_SCOPE (
  TOKEN_ID VARCHAR (255),
  TOKEN_SCOPE VARCHAR (60),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_USER_ACCOUNT_ASSOCIATION]') AND TYPE IN (N'U'))
  CREATE TABLE IDN_USER_ACCOUNT_ASSOCIATION (
    ASSOCIATION_KEY VARCHAR(255) NOT NULL,
    TENANT_ID INTEGER,
    DOMAIN_NAME VARCHAR(255) NOT NULL,
    USER_NAME VARCHAR(255) NOT NULL,
    PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME));

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[FIDO_DEVICE_STORE]') AND TYPE IN (N'U'))
  CREATE TABLE FIDO_DEVICE_STORE (
    TENANT_ID INTEGER,
    DOMAIN_NAME VARCHAR(255) NOT NULL,
    USER_NAME VARCHAR(45) NOT NULL,
    TIME_REGISTERED DATETIME,
    KEY_HANDLE VARCHAR(200) NOT NULL,
    DEVICE_DATA VARCHAR(2048) NOT NULL,
    PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE));

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_REQUEST]') AND TYPE IN (N'U'))
  CREATE TABLE WF_REQUEST (
    UUID VARCHAR (45),
    CREATED_BY VARCHAR (255),
    TENANT_ID INTEGER DEFAULT -1,
    OPERATION_TYPE VARCHAR (50),
    CREATED_AT DATETIME,
    UPDATED_AT DATETIME,
    STATUS VARCHAR (30),
    REQUEST VARBINARY(MAX),
    PRIMARY KEY (UUID)
  );

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_BPS_PROFILE]') AND TYPE IN (N'U'))
  CREATE TABLE WF_BPS_PROFILE (
    PROFILE_NAME VARCHAR(45),
    HOST_URL_MANAGER VARCHAR(45),
    HOST_URL_WORKER VARCHAR(45),
    USERNAME VARCHAR(45),
    PASSWORD VARCHAR(255),
    CALLBACK_HOST VARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (PROFILE_NAME, TENANT_ID)
  );

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_WORKFLOW]') AND TYPE IN (N'U'))
  CREATE TABLE WF_WORKFLOW(
    ID VARCHAR (45),
    WF_NAME VARCHAR (45),
    DESCRIPTION VARCHAR (255),
    TEMPLATE_ID VARCHAR (45),
    IMPL_ID VARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (ID)
  );

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_WORKFLOW_ASSOCIATION]') AND TYPE IN (N'U'))
  CREATE TABLE WF_WORKFLOW_ASSOCIATION(
    ID INTEGER NOT NULL IDENTITY ,
    ASSOC_NAME VARCHAR (45),
    EVENT_ID VARCHAR(45),
    ASSOC_CONDITION VARCHAR (2000),
    WORKFLOW_ID VARCHAR (45),
    IS_ENABLED CHAR (1) DEFAULT '1',
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY(ID),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
  );

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_WORKFLOW_CONFIG_PARAM]') AND TYPE IN (N'U'))
  CREATE TABLE WF_WORKFLOW_CONFIG_PARAM(
    WORKFLOW_ID VARCHAR (45),
    PARAM_NAME VARCHAR (45),
    PARAM_VALUE VARCHAR (1000),
    PARAM_QNAME VARCHAR (45),
    PARAM_HOLDER VARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
  );

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_REQUEST_ENTITY_RELATIONSHIP]') AND TYPE IN (N'U'))
  CREATE TABLE WF_REQUEST_ENTITY_RELATIONSHIP(
    REQUEST_ID VARCHAR (45),
    ENTITY_NAME VARCHAR (255),
    ENTITY_TYPE VARCHAR (50),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),
    FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
  );

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_WORKFLOW_REQUEST_RELATION]') AND TYPE IN (N'U'))
  CREATE TABLE WF_WORKFLOW_REQUEST_RELATION(
    RELATIONSHIP_ID VARCHAR (45),
    WORKFLOW_ID VARCHAR (45),
    REQUEST_ID VARCHAR (45),
    UPDATED_AT DATETIME,
    STATUS VARCHAR (30),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (RELATIONSHIP_ID),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,
    FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
  );
