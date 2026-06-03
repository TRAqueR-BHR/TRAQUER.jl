delete from outbreak;
delete from contact_exposure;
update stay set  isolation_time = null where isolation_time is not null;
update event_requiring_attention set is_pending = 't',  responses_types = null
  where responses_types is not null;
