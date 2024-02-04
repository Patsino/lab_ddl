create or replace view public.sales_revenue_by_category_qtr as
select c.name as category,
extract(quarter from p.payment_date) as quarter,
coalesce(sum(p.amount), 0::numeric) as total_sales_revenue
from payment p join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
where extract(quarter from p.payment_date) = extract(quarter from current_date) and
extract(year from p.payment_date) = extract(year from current_date)
group by c.name, extract(quarter from p.payment_date) having count(distinct p.payment_id) > 0;
--////////////
create or replace function get_sales_revenue_by_category_qtr(current_qtr numeric)
returns table(category_result text, quarter_result numeric, total_sales_revenue_result numeric)
language 'plpgsql'
as $$ begin return query select * from sales_revenue_by_category_qtr
where quarter = current_qtr;
end;
$$;
select * from get_sales_revenue_by_category_qtr(extract(quarter from current_date));
--///////////////////
create or replace procedure new_movie(movie_title varchar)
language plpgsql
as $$ declare
s_language_id int;
new_film_id int;
begin
select language_id into s_language_id
from language
where name = 'Klingon';
if s_language_id is null then
raise exception 'Language "Klingon" does not exist in the language table.';
end if;
select coalesce(max(film_id), 0) + 1 into new_film_id
from film;
insert into film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
values (new_film_id, movie_title, 4.99, 3, 19.99, extract(year from current_date), s_language_id);
end;
$$;
call new_movie('The Goodfellas');
