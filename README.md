
# Cascade Update

## Oracle SQL and PL/SQL solution to overwrite a primary or any other unique key column value

### Why? ###

Because sometimes we need to overwrite a primary or any other unique key column value.
This should not be easy, because there could be a lot of reference to this value from other tables.

### How? ###
The **F_CASCADE_UPDATE** function only generates a list of commands which can do this replace.
It does not execute them just returns with them. 
We have to check (and correct if necessary) before execute them.  

The function is very simple, so **it can manage only single and number or string type keys** such as ID, CODE etc.

See the code for more details!

Parameters:

    I_TABLE_NAME        the name of table where we want to update the value
    I_COLUMN_NAME       the name of the PK (or Unique) column (in the I_TABLE_NAME table)
    I_OLD_VALUE         (varchar2) the old value what you want to replace with 
    I_NEW_VALUE         (varchar2) this new value.

Sample:

    select * from  table( F_CASCADE_UPDATE ( 'PERSON', 'ID', '5399225', '999' ) );

Result (I used ..... to symbolize more commands behind ) :

    /* Disable Foreign key constraints */
    ALTER TABLE CONTRACTS DISABLE CONSTRAINT FK4_CONTRACTS;
    ALTER TABLE CONTRACTS DISABLE CONSTRAINT FK5_CONTRACTS;
    ALTER TABLE CRM_TAGS DISABLE CONSTRAINT FK8_CRM_TAGS;
    ALTER TABLE EMPLOYEE DISABLE CONSTRAINT FK2_EMPLOYEE;
    ALTER TABLE EMPLOYEE DISABLE CONSTRAINT FK5_EMPLOYEE;
    .....
    ALTER TABLE TRANSACTIONS DISABLE CONSTRAINT FK2_TRANSACTIONS;
    ALTER TABLE VACATION DISABLE CONSTRAINT FK1_VACATION;
    /* Replace the value */
    UPDATE CONTRACTS SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE CONTRACTS SET RESPONSIBLE_ID='999' where RESPONSIBLE_ID='5399225';
    UPDATE CRM_TAGS SET ASSIGNEE_ID='999' where ASSIGNEE_ID='5399225';
    UPDATE EMPLOYEE SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE EMPLOYEE SET SUPERIOR_ID='999' where SUPERIOR_ID='5399225';
    .....
    UPDATE TRANSACTIONS SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE VACATION SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE PERSON SET ID='999' where ID='5399225';
    /* Enable Foreign key constraints */
    ALTER TABLE CONTRACTS ENABLE CONSTRAINT FK4_CONTRACTS;
    ALTER TABLE CONTRACTS ENABLE CONSTRAINT FK5_CONTRACTS;
    ALTER TABLE CRM_TAGS ENABLE CONSTRAINT FK8_CRM_TAGS;
    ALTER TABLE EMPLOYEE ENABLE CONSTRAINT FK2_EMPLOYEE;
    ALTER TABLE EMPLOYEE ENABLE CONSTRAINT FK5_EMPLOYEE;
    .....
    ALTER TABLE TRANSACTIONS ENABLE CONSTRAINT FK2_TRANSACTIONS;
    ALTER TABLE VACATION ENABLE CONSTRAINT FK1_VACATION;
    /* ...Some more suspicious place */
    UPDATE TRAIN_PARTICIPANT SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE CONTRACTS SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE CHECKLIST SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE RIGHTS SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE PERSON_COST_CENTERS SET PERSON_ID='999' where PERSON_ID='5399225';
    .....
    UPDATE TRANSACTIONS_SAVE_20180608 SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE PERSON_KNOWLEDGE_TEMP SET PERSON_ID='999' where PERSON_ID='5399225';
    UPDATE PRODUCT_LINE SET PERSON_ID='999' where PERSON_ID='5399225';

