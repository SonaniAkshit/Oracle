set serveroutput on;

-- create new package with updated name
create or replace package user_package as
    procedure register_user(
        p_name     in varchar2,
        p_email    in varchar2,
        p_password in varchar2,
        p_phone    in varchar2
    );

    procedure login_user(
        p_email    in varchar2,
        p_password in varchar2
    );
end user_package;
/

create or replace package body user_package as

    procedure register_user(
        p_name     in varchar2,
        p_email    in varchar2,
        p_password in varchar2,
        p_phone    in varchar2
    ) is
        v_count number;
    begin
        -- check if email already exists
        select count(*) into v_count 
        from customers 
        where email = p_email;

        if v_count > 0 then
            dbms_output.put_line('');
            dbms_output.put_line('');
            dbms_output.put_line('email already exists. please use a different email.');
        else
            insert into customers (customer_id, name, email, password, phone)
            values (seq_customers.nextval, p_name, p_email, p_password, p_phone);

            dbms_output.put_line('');
            dbms_output.put_line('');
            dbms_output.put_line('registration successfully!');

            commit;
        end if;
    exception
        when others then
            rollback;
            raise;
    end register_user;

    procedure login_user(
        p_email    in varchar2,
        p_password in varchar2
    ) is
        v_count number;
    begin
        select count(*) into v_count
        from customers
        where email = p_email
          and password = p_password;

        if v_count > 0 then
            dbms_output.put_line('');
            dbms_output.put_line('');
            dbms_output.put_line('login successful! welcome ' || p_email);
        else
            dbms_output.put_line('');
            dbms_output.put_line('');
            dbms_output.put_line('invalid email or password.');
        end if;
    exception
        when others then
            dbms_output.put_line('');
            dbms_output.put_line('');
            dbms_output.put_line('error during login: ' || sqlerrm);
    end login_user;

end user_package;
/


-- begin
--     user_package.register_user('&name', '&email', '&password', '&phone');
-- end;
-- /

-- exec user_package.register_user('&name', '&email', '&password', '&phone');