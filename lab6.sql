DELIMITER //
#1. Создать хранимую функцию, получающую на вход идентификатор читателя и возвращающую 
#список идентификаторов книг, которые он уже прочитал и вернул в библиотеку.
drop procedure BooksList//
create procedure BooksList(in id int) 
begin
	select distinct sb_book from subscriptions where id = sb_subscriber; 
end//

call BooksList(1)//
#3.Создать хранимую функцию, получающую на вход идентификатор читателя и возвращающую 1, если у читателя на руках сейчас менее десяти книг, и 0 в противном случае.
drop function IfMoreThanTenBooks//
create function IfMoreThantenBooks(id int)
returns int deterministic
begin
	return if(id = any(select sb_subscriber from subscriptions where sb_is_active = 'Y' group by sb_subscriber having count(sb_subscriber)>=0),0,1);
end//

select IfMoreThanTenBooks(1)//
#5. Создать хранимую процедуру, обновляющую все поля типа DATE (если такие есть) всех записей указанной таблицы на значение текущей даты.
drop procedure if exists DateUpdate//
create procedure DateUpdate(in tablename varchar(255))
begin
	declare done int default false;
    declare columnName varchar(255);
    declare cursorchik cursor for
        select COLUMN_NAME
        from INFORMATION_SCHEMA.COLUMNS
        where TABLE_NAME = tableName and DATA_TYPE = 'date';
	declare continue handler for not found set done = true;
    
    open cursorchik;
    read_loop: loop
        fetch cursorchik into columnName;
        if done then
            leave read_loop;
        end if;
        
        set @query = CONCAT('update ', tableName, ' set ', columnName, ' = curdate()');
        prepare stmt from @query;
        execute stmt;
        deallocate prepare stmt;
    end loop;
    close cursorchik;
end //
call DateUpdate('subscriptions')//

#9. Создать хранимую процедуру, автоматически создающую и наполняющую данными таблицу «arrears», в которой должны быть представлены идентификаторы и имена читателей, 
#у которых до сих пор находится на руках хотя бы одна книга, по которой дата возврата установлена в прошлом относительно текущей даты.

drop procedure if exists CreateArrears//
drop table arrears//
create procedure CreateArrears()
begin
	create table arrears (
    select distinct sb_subscriber,s_name from subscriptions  
    join subscribers on s_id=sb_subscriber and sb_finish<=curdate()
    );
end//

call CreateArrears()//

#4.Создать хранимую функцию, получающую на вход год издания книги и возвращающую 1, если книга издана менее ста лет назад, и 0 в противном случае.
drop function f//
create function f(yearc int)
returns int deterministic
begin
	return if(year(curdate())-yearc<100,1,0);
end//