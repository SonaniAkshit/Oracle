set serveroutput on;

create or replace package admin_package as
    procedure login_admin(
        p_username in varchar2,
        p_password in varchar2
    );
end admin_package;
/

create or replace package body admin_package as

    procedure login_admin(
        p_username in varchar2,
        p_password in varchar2
    ) is
        v_count number;
    begin
        select count(*) into v_count
        from admins
        where username = p_username
          and password = p_password;

        if v_count > 0 then
            dbms_output.put_line('');
            dbms_output.put_line('');
            dbms_output.put_line('login successful! welcome ' || p_username);
        else
            dbms_output.put_line('');
            dbms_output.put_line('');
            dbms_output.put_line('invalid username or password.');
        end if;
    exception
        when others then
            dbms_output.put_line('');
            dbms_output.put_line('');
            dbms_output.put_line('error during login: ' || sqlerrm);
    end login_admin;

end admin_package;
/
