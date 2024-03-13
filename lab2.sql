#11 Показать идентификаторы и даты выдачи книг за первый год работы библиотеки 
#(первым годом работы библиотеки считать все даты с первой выдачи книги по 31-е декабря 
#(включительно) того года, когда библиотека начала работать).
select min(sb_start) into @minimal from subscriptions;
select sb_id,sb_start,sb_finish from subscriptions where year(sb_start)=year(@minimal);

#7. Показать, сколько читателей брало книги в библиотеке.
select count(*) from subscribers;

#6. Показать, сколько всего раз читателям выдавались книги.

select count(*) from subscriptions;

#3. Показать без повторений идентификаторы книг, которые были взяты читателями.

select distinct sb_book from subscriptions;

#14. Показать идентификатор «читателя-рекордсмена», взявшего в библиотеке больше книг, чем любой другой читатель
select sb_subscriber, count(*) as m from subscriptions group by sb_subscriber order by m desc limit 1;
