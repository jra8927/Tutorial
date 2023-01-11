
CREATE OR REPLACE TEMPORARY TABLE INFO_SCHEMA AS 
SELECT  TABLE_NAME, row_number() over (order by TABLE_NAME) as RW  from information_schema.tables WHERE table_schema = 'DBO' AND TABLE_TYPE IN ('VIEW','BASE TABLE');

CREATE OR REPLACE TEMPORARY TABLE Query_Times (table_name VARCHAR(100),Query_Start_Time TIMESTAMP_NTZ(9),Query_End_Time TIMESTAMP_NTZ(9),Query_Execution_Time_Seconds INT);

execute immediate $$
declare
    x int default 0;
    name varchar(200);
    query_start_time TIMESTAMP_NTZ(9);
    query_end_time TIMESTAMP_NTZ(9); 
    query_execution_time INT;
    num_of_itirations INT:= (select max(rw) from INFO_SCHEMA);
begin
    while (x < num_of_itirations) do
        x := x + 1;
        name := (SELECT TABLE_NAME FROM INFO_SCHEMA WHERE RW = :x);
        query_start_time := (select current_timestamp(2));
        execute immediate 'SELECT TOP 100000 * FROM (' || name || ')';
        query_end_time := (select current_timestamp(2));
        query_execution_time := (SELECT datediff(second, :query_start_time,:query_end_time));
        insert into Query_Times values (:name,:query_start_time,:query_end_time, :query_execution_time);
    end while;
end;
$$;

SELECT table_name,Query_Start_Time,Query_End_Time,Query_Execution_Time_Seconds FROM Query_Times
ORDER BY Query_Execution_Time_Seconds ASC
