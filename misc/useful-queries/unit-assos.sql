select
	u.name AS unit_name,
	oua.id AS  outbreak_unit_asso_id
from outbreak_unit_asso oua
join outbreak o
  on o.id = oua.outbreak_id
join unit u
  on oua.unit_id = u.id
where o.id = '0e5fcd7c-5cc6-40c2-a68b-e8fa0bf2829d'