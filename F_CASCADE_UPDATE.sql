create or replace type T_STRING_LIST as table of varchar2( 32000 );
/


create or replace function F_CASCADE_UPDATE ( I_TABLE_NAME   in varchar2
                                            , I_COLUMN_NAME  in varchar2
                                            , I_OLD_VALUE    in varchar2 
                                            , I_NEW_VALUE    in varchar2
                                            ) return T_STRING_LIST is

/* ********************************************************************************************************

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

******************************************************************************************************** */

    V_CONSTS_D          T_STRING_LIST := T_STRING_LIST();
    V_CONSTS_E          T_STRING_LIST := T_STRING_LIST();
    V_UPDATES           T_STRING_LIST := T_STRING_LIST();
    V_RESULT            T_STRING_LIST := T_STRING_LIST();
    V_COLUMN_NAME       varchar2( 500 );
begin

    V_CONSTS_D.extend;
    V_CONSTS_D( V_CONSTS_D.count ) := '/* Disable Foreign key constraints */';

    V_UPDATES.extend;
    V_UPDATES( V_UPDATES.count ) := '/* Replace the value */';

    V_CONSTS_E.extend;
    V_CONSTS_E( V_CONSTS_E.count ) := '/* Enable Foreign key constraints */';

    for L_R in ( select UC.TABLE_NAME
                      , DBC.COLUMN_NAME
                      , UC.CONSTRAINT_NAME
                   from USER_CONSTRAINTS   UC
                      , USER_CONS_COLUMNS DBC
                  where UC.CONSTRAINT_TYPE  = 'R' 
                    and UC.STATUS           = 'ENABLED'               
                    and DBC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
                    and R_CONSTRAINT_NAME in ( select UCB.CONSTRAINT_NAME
                                                 from USER_CONSTRAINTS   UCB
                                                    , USER_CONS_COLUMNS DBCB
                                                where DBCB.CONSTRAINT_NAME = UCB.CONSTRAINT_NAME 
                                                  and UCB.TABLE_NAME       = upper( I_TABLE_NAME )
                                                  and DBCB.COLUMN_NAME     = upper( I_COLUMN_NAME )
                                             )
                   order by 1,2
                )
    loop

        V_CONSTS_D.extend;
        V_CONSTS_D( V_CONSTS_D.count ) := 'ALTER TABLE '||L_R.TABLE_NAME||' DISABLE CONSTRAINT '||L_R.CONSTRAINT_NAME||';';

        V_CONSTS_E.extend;
        V_CONSTS_E( V_CONSTS_E.count ) := 'ALTER TABLE '||L_R.TABLE_NAME||' ENABLE CONSTRAINT '||L_R.CONSTRAINT_NAME||';';

        V_UPDATES.extend;
        V_UPDATES( V_UPDATES.count ) := 'UPDATE '||L_R.TABLE_NAME||' SET '||L_R.COLUMN_NAME||'='''||I_NEW_VALUE||''' where '||L_R.COLUMN_NAME||'='''||I_OLD_VALUE||''';';

    end loop;

    V_UPDATES.extend;
    V_UPDATES( V_UPDATES.count ) := 'UPDATE '||I_TABLE_NAME||' SET '||I_COLUMN_NAME||'='''||I_NEW_VALUE||''' where '||I_COLUMN_NAME||'='''||I_OLD_VALUE||''';';

    for L_I in 1..V_CONSTS_D.count
    loop
        V_RESULT.extend;
        V_RESULT( V_RESULT.count ) := V_CONSTS_D( L_I );
    end loop;

    for L_I in 1..V_UPDATES.count
    loop
        V_RESULT.extend;
        V_RESULT( V_RESULT.count ) := V_UPDATES( L_I );
    end loop;

    for L_I in 1..V_CONSTS_E.count
    loop
        V_RESULT.extend;
        V_RESULT( V_RESULT.count ) := V_CONSTS_E( L_I );
    end loop;


    V_RESULT.extend;
    V_RESULT( V_RESULT.count ) := '/* ...Some more suspicious place */';

    V_COLUMN_NAME := upper( I_TABLE_NAME||'_'||I_COLUMN_NAME );

    for L_R in ( select table_name
                   from user_tab_columns 
                  where column_name = V_COLUMN_NAME 
                    and table_name in (select ut.table_name from user_tables ut ) 
                    and upper ( 'UPDATE '||table_name||' SET '||V_COLUMN_NAME||'='''||I_NEW_VALUE||''' where '||V_COLUMN_NAME||'='''||I_OLD_VALUE||''';' ) not in ( select * from table( V_UPDATES ) )
               )
    loop
        V_RESULT.extend;
        V_RESULT( V_RESULT.count ) := 'UPDATE '||L_R.TABLE_NAME||' SET '||V_COLUMN_NAME||'='''||I_NEW_VALUE||''' where '||V_COLUMN_NAME||'='''||I_OLD_VALUE||''';';
    end loop;

    -- standard singular from plural
    if substr( upper (I_TABLE_NAME) , -1 ) = 'S' then
        V_COLUMN_NAME := upper( substr( I_TABLE_NAME,1,length(I_TABLE_NAME)-1)||'_'||I_COLUMN_NAME );
        for L_R in ( select table_name
                       from user_tab_columns 
                      where column_name = V_COLUMN_NAME 
                        and table_name in (select table_name from user_tables ) 
                        and upper ( 'UPDATE '||table_name||' SET '||V_COLUMN_NAME||'='''||I_NEW_VALUE||''' where '||V_COLUMN_NAME||'='''||I_OLD_VALUE||''';' ) not in ( select * from table( V_UPDATES ) )
                   )
        loop
            V_RESULT.extend;
            V_RESULT( V_RESULT.count ) := 'UPDATE '||L_R.TABLE_NAME||' SET '||V_COLUMN_NAME||'='''||I_NEW_VALUE||''' where '||V_COLUMN_NAME||'='''||I_OLD_VALUE||''';';
        end loop;
    end if;

    return V_RESULT;

end;
/
