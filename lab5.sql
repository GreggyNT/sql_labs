#5.Создать представление, возвращающее всю информацию из таблицы subscriptions, 
#преобразуя даты из полей sb_start и sb_finish в формат «ГГГГ-ММ-ДД НН», 
#где «НН» – день недели в виде своего полного названия (т.е. «Понедельник», «Вторник» и т.д.)
create or replace view new_subs as
select sb_id,sb_subscriber,
sb_book,
concat(sb_start,'-', case weekday(sb_start) 
						when 0 then 'Понедельник' 
                        when 1 then 'Вторник' 
                        when 2 then 'Среда'
                        when 3 then 'Четверг'
                        when 4 then 'Пятница'
                        when 5 then 'Суббота'
                        when 6 then 'Воскресенье'
                        end) as startdate,
concat(sb_finish,'-',case weekday(sb_finish) 
						when 0 then 'Понедельник' 
                        when 1 then 'Вторник' 
                        when 2 then 'Среда'
                        when 3 then 'Четверг'
                        when 4 then 'Пятница'
                        when 5 then 'Суббота'
                        when 6 then 'Воскресенье'
                        end) as finishdate,
sb_is_active from subscriptions;

#12.Модифицировать схему базы данных таким образом, чтобы таблица «subscribers» хранила информацию о том, сколько раз читатель 
#брал в библиотеке книги (этот счётчик должен инкрементироваться каждый раз, когда читателю выдаётся книга;
# уменьшение значения этого счётчика не предусмотрено).
alter table subscribers add s_count int default 0; 
update subscribers 
set s_count = (select count(sb_id) from subscriptions where subscribers.s_id = subscriptions.sb_id );

drop trigger update_s_count;
DELIMITER //
create trigger update_s_count
after update on subscriptions
for each row
begin
	update subscribers
	set s_count = s_count + 1
	where s_id = old.sb_subscriber;
end;
//




drop trigger subs//
#13.Создать триггер, не позволяющий добавить в базу данных информацию о выдаче книги, если выполняется хотя бы одно из условий:
	#• дата выдачи или возврата приходится на воскресенье;
    #• читатель брал за последние полгода более 100 книг;
    #• промежуток времени между датами выдачи и возврата менее трёх дней.
create trigger subs
before insert on subscriptions
for each row
begin 
	if weekday(new.sb_start)=6 or weekday(new.sb_finish)=6 or timestampdiff(day,sb_start,sb_finish)>3 or new.sb_subscriber=any(select sb_subscriber from subscriptions 
																														where timestampdiff(month,sb_start,curdate)<6 
																														group by sb_subscriber 
																														having count(sb_subscriber)<=100) 
	then
		signal sqlstate '45000';
	end if;
end;
//

#7. Создать представление, извлекающее информацию о датах выдачи и возврата книг и состоянии выдачи книги в виде единой строки в формате 
#«ГГГГ-ММ-ДД - ГГГГ-ММ-ДД - Возвращена» и при этом допускающее обновление информации в таблице subscriptions.
create or replace view better_subs as
select sb_id,sb_subscriber,sb_book,concat(sb_start,' - ',sb_finish,if(sb_is_active='Y',' - Возвращена','')) as sub_status from subscriptions//

#16.Создать триггер, корректирующий название книги таким образом, чтобы оно удовлетворяло следующим условиям:
        #a. не допускается наличие пробелов в начале и конце названия;
		#b. не допускается наличие повторяющихся пробелов;
        #c. первая буква в названии всегда должна быть заглавной.
create trigger on_new_book
before insert on books
for each row
begin
	if (left(new.b_name,1)=' ') then
		set new.b_name = ltrim(new.b_name);
	end if;
   if (right(new.b_name,1)=' ') then
		set new.b_name = rtrim(new.b_name);
	end if; 
    while (instr(new.b_name,'  ')!=0) do
		set @str = instr(b_name,'  '),
        new.b_name = concat(left(new.b_name,@str),right(new.b_name,length(new.b_name)-@str-1));
	end while;
    set new.b_name = concat(upper(left(new.b_name,1)),right(new.b_name,length(new.b_name)-1));
end;
//
    
	
		
