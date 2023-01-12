DECLARE @Coluumns NVARCHAR(MAX)=''
DECLARE @script NVARCHAR(MAX)
DECLARE @firstColumn NVARCHAR(100)
DECLARE @table NVARCHAR(100)


SET @table='logentry_webuser'
SET @firstColumn=(SELECT Column_Name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@TABLE AND ORDINAL_POSITION=1)

SELECT @Coluumns +=
 COLUMN_NAME+',' FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME=@table
SET @Coluumns=LEFT(@Coluumns,LEN(@Coluumns)-1)


SET @script=N' 
WITH CTE AS (SELECT '+@Coluumns+', ROW_NUMBER() over (partition by '+@Coluumns+' ORDER BY '+@firstColumn+') Duplicates
FROM DBO.'+@table+')
DELETE FROM CTES 
WHERE DUPLICATES>1
'
PRINT @script 


PRINT @script 
