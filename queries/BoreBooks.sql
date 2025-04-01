select b.title, b.author
from books b
--Join books with editions sharing title and author
join  editions e 
on b.title = e.title and b.author = e.author
--Join copies with editions sharing isbn
join copies c on c.isbn = e.isbn
--Select only those books that do not have any entry in table loans
where not exists (
    select * from loans l
    where l.signature in (select c1.signature from copies c1 where c1.isbn = e.isbn)
)
--Finally group by books with 3 or more languages
group by b.title, b.author
having count(distinct e.language) >= 3;