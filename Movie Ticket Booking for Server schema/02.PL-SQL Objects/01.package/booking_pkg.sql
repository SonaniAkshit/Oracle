create or replace package booking_pkg as
    -- book ticket
    procedure book_ticket(
        p_customer_id in number,
        p_show_id     in number,
        p_seat_id     in number
    );

    -- make payment
    procedure make_payment(
        p_ticket_id in number,
        p_amount    in number
    );

    -- cancel ticket
    procedure cancel_ticket(
        p_ticket_id in number
    );
end booking_pkg;
/

create or replace package body booking_pkg as

    -- book ticket
    procedure book_ticket(
        p_customer_id in number,
        p_show_id     in number,
        p_seat_id     in number
    ) is
        v_count number;
    begin
        -- check if seat already booked for the show
        select count(*) into v_count
        from tickets
        where show_id = p_show_id
          and seat_id = p_seat_id
          and ticket_status = 'BOOKED';

        if v_count > 0 then
            raise_application_error(-20020, 'seat already booked for this show.');
        end if;

        -- insert ticket (default status = BOOKED)
        insert into tickets (ticket_id, customer_id, show_id, seat_id, booking_time, ticket_status)
        values (seq_tickets.nextval, p_customer_id, p_show_id, p_seat_id, systimestamp, 'BOOKED');

        dbms_output.put_line('ticket booked successfully.');
    end book_ticket;


    -- make payment
    procedure make_payment(
        p_ticket_id in number,
        p_amount    in number
    ) is
        v_price number;
    begin
        -- get show price
        select s.price
        into v_price
        from shows s
        join tickets t on s.show_id = t.show_id
        where t.ticket_id = p_ticket_id;

        if p_amount < v_price then
            raise_application_error(-20021, 'payment amount is less than ticket price.');
        end if;

        -- insert payment
        insert into payments (payment_id, ticket_id, amount, payment_date)
        values (seq_payments.nextval, p_ticket_id, p_amount, sysdate);

        dbms_output.put_line('payment successful for ticket ' || p_ticket_id);
    end make_payment;


    -- cancel ticket
    procedure cancel_ticket(
        p_ticket_id in number
    ) is
    begin
        -- update ticket status
        update tickets
        set ticket_status = 'CANCELLED'
        where ticket_id = p_ticket_id;

        dbms_output.put_line('ticket ' || p_ticket_id || ' cancelled.');
    end cancel_ticket;

end booking_pkg;
/

-- exec booking_pkg.book_ticket(&customer_id, &show_id, &seat_id);
-- exec booking_pkg.make_payment(&ticket_id, &amount);
-- exec booking_pkg.cancel_ticket(&ticket_id);
