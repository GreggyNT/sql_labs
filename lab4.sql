#2.Отразить в базе данных информацию о том, 
#что каждый из троих добавленных читателей 20-го января 2016-го 
#года на месяц взял в библиотеке книгу «Курс теоретической физики».
insert into subscriptions()
values (null,1,6,'2016-01-20','2016-02-20','N'),
(null,2,6,'2016-01-20','2016-02-20','N'),
(null,3,6,'2016-01-20','2016-02-20','N');
#5.Для всех выдач, произведённых до 1-го января 2012-го года, уменьшить значение дня выдачи на 3.
update subscriptions
set sb_start = date_add(sb_start, interval 3 day)
where sb_start<'2012-01-01';
#8.Удалить все книги, относящиеся к жанру «Классика».
SET FOREIGN_KEY_CHECKS=0; 
delete from books 
where b_id = any(select b_id from m2m_books_genres where m2m_books_genres.g_id in (select g_id from genres where g_name = 'Классика'));
SET FOREIGN_KEY_CHECKS=1;
#10.Добавить в базу данных жанры «Политика», «Психология», «История».
insert into genres()
values (null,'Политика'),(null,'Психология'),(null,'История');
#13.Обновить все имена авторов, добавив в конец имени « [+]», 
#если в библиотеке есть более трёх книг этого автора, 
#или добавив в конец имени « [-]» в противном случае.
update authors 
set a_name = if (a_id in(select a_id from m2m_books_authors group by a_id having count(a_id)>=3), concat(a_name,'[+]'),concat(a_name,'[-]'));




