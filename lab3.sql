
#5.Показать список книг, которые когда-либо были взяты читателями.
select distinct subscriptions.sb_book,books.b_name from books
join subscriptions on sb_book = books.b_id;
#9.Показать книги, написанные Карнеги и Страуструпом в соавторстве.
select b_name from books
where (select b_id from m2m_books_authors where a_id =(select a_id from authors where authors.a_name like '%Карнеги')) = 
any (select b_id from m2m_books_authors where a_id =(select a_id from authors where authors.a_name like '%Страуструп')) and b_id = (select b_id from m2m_books_authors where a_id =(select a_id from authors where authors.a_name like '%Карнеги'));
#17.Показать читаемость жанров, т.е. все жанры и то количество раз, которое книги этих жанров были взяты читателями.
select genres.g_name, count(m2m_books_genres.g_id)as counter from genres
join m2m_books_genres on genres.g_id=m2m_books_genres.g_id
group by genres.g_name;
#7.Показать список книг, ни один экземпляр которых сейчас не находится на руках у читателей.
select books.b_name from books 
where books.b_id not in(select sb_book from subscriptions where sb_is_active = true);
#23.Показать читателя, последним взявшего в библиотеке книгу.
select s_name from subscribers
where (select sb_subscriber from subscriptions order by sb_start desc limit 1) = s_id;






