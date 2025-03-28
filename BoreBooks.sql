select b.title, b.author
from books b
join  editions e 
on b.title = e.title and b.author = e.author
join copies c on c.isbn = e.isbn
where not exists (
    select * from loans l
    where l.signature in (select c1.signature from copies c1 where c1.isbn = e.isbn)
)
group by b.title, b.author
having count(distinct e.language) >= 3;