select b.title, b.author
from books b
join (
    select title, author, language from editions
    join
    select title, author, alt_languages from editions
) as langs 
on b.title = langs.title and b.author = langs.author
join copies c on c.isbn = langs.isbn
left join loans l on c.signature = l.signature
where l.signature is null
group by b.title, b.author
having count(langs.language) >= 3;