select
	u.name,
	s.room,
	string_agg(distinct s.sector,', ')
from stay s
join unit u
  on s.unit_id = u.id
group by u.id,s.room
having  count(distinct s.sector) >= 1
