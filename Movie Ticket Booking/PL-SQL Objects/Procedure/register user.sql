create or replace procedure register_user(
    p_name     in varchar2,
    p_email    in varchar2,
    p_password in varchar2,
    p_phone    in varchar2
) is
    v_count number;
begin
    -- check if email already exists
    select count(*) into v_count from customers where email = p_email;

    if v_count > 0 then
        -- raise a custom exception if email exists
        raise_application_error(-20001, 'email already exists. please use a different email.');
    else
        -- insert new customer record
        insert into customers (customer_id, name, email, password, phone)
        values (seq_customers.nextval, p_name, p_email, p_password, p_phone);

        commit;
    end if;
exception
    when others then
        rollback;
        raise;
end register_user;
/

begin
    register_user('&name', '&email', '&password', '&phone');
end;
/
