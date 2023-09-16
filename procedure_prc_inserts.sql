create or replace procedure prc_inserts()
as $$
declare
 a text;
begin
   for counter in 1..100000 loop
	select pg_sleep(.2) into a;
	raise notice 'counter: %', counter;
	--Insert new record
	insert into cloudwalk.orders(product_name, quantity, order_date)
    values('Nike AirJordan'||counter,100, now());
    --Commit at every 10 inserts
   	if mod(counter,10) = 0 then
	 commit;
	end if;
   end loop;
end; $$
LANGUAGE plpgsql;
