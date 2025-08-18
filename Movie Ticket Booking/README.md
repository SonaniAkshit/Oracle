## 🎬 Movie Ticket Booking System

### 📂 Repository Structure

The project is organized into the following key components:

* **Database Schema**: Contains SQL scripts for creating tables, sequences, and partitions.
* **Data Insertion**: Includes scripts to insert sample data into the tables.
* **Views**: Provides SQL views for reporting and querying.
* **Triggers**: Automates actions like seat availability checks and booking confirmations.
* **Sequences**: Ensures unique identifiers for primary keys.
* **Stored Procedures**: Handles complex operations like ticket booking and payment processing.

---

## 🛠️ Setup Instructions

### 1. **Database Setup**

* **Create Tablespaces**: Ensure the `USERS` and `USERS1` tablespaces are created in your Oracle database.

```sql
  CREATE TABLESPACE users
    DATAFILE 'C:\ORACLE21C\ORADATA\XE\USERS01.DBF'
    SIZE 50M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

  CREATE TABLESPACE users1
    DATAFILE 'C:\ORACLE21C\ORADATA\XE\USERS1.DBF'
    SIZE 50M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;
```



* **Execute SQL Scripts**: Run the provided SQL scripts to create tables, sequences, and other database objects.

```sql
  @create_tables.sql
  @create_sequences.sql
  @create_triggers.sql
  @create_views.sql
  @create_procedures.sql
```



### 2. **Data Insertion**

* **Insert Sample Data**: Use the `insert.sql` script to populate the tables with sample data.

```sql
  @insert.sql
```



### 3. **User Interface**

* **Admin Interface**: Access the admin dashboard to manage movies, screens, shows, and bookings.
* **User Interface**: Users can browse movies, view showtimes, and book tickets.

---

## 👥 User Functionalities

1. **Browse Movies**: View a list of available movies along with their details.
2. **Select Showtimes**: Choose a movie and select a preferred showtime.
3. **Book Tickets**: Select seats and confirm the booking.
4. **Make Payments**: Proceed to payment using the available methods.
5. **View Bookings**: Check booking history and ticket details.([GitHub][1], [GitHub][2])

---

## 🧑‍💼 Admin Functionalities

1. **Manage Movies**: Add, update, or remove movies from the system.
2. **Manage Screens**: Set up and configure cinema screens.
3. **Schedule Shows**: Create and manage showtimes for movies.
4. **Monitor Bookings**: View and manage user bookings.
5. **Generate Reports**: Access reports on sales, occupancy, and other metrics.([Oracle][3])

---

## 🔄 Example: Booking a Ticket

1. **Select Movie**: Choose a movie from the list.
2. **Choose Showtime**: Pick a date and time for the show.
3. **Select Seats**: Choose available seats from the seating chart.
4. **Confirm Booking**: Review selection and confirm.
5. **Make Payment**: Enter payment details and complete the transaction.
6. **Receive Confirmation**: Get a booking confirmation with ticket details.([Medium][4], [GitHub][1], [Oracle][3], [GitHub][5])

---

## 📊 Views and Reports

The system includes several SQL views for reporting purposes:([GitHub][6])

* **Available Shows**: Lists shows with available seats.
* **Booking History**: Displays user booking history.
* **Revenue Reports**: Shows sales and revenue metrics.([GitHub][2])

---

## ⚙️ Stored Procedures

Key stored procedures include:([Medium][7])

* **Book\_Ticket**: Handles the booking process, including seat allocation and payment processing.
* **Cancel\_Ticket**: Allows users to cancel bookings and release seats.
* **Generate\_Report**: Generates various reports for admin users.([GitHub][1], [GitHub][8])

---

## 🧪 Testing the System

To test the system:

1. **Login as User**: Use the provided credentials to log in.
2. **Browse Movies**: Navigate through the available movies.
3. **Book Tickets**: Select a movie, choose a showtime, and book tickets.
4. **Login as Admin**: Use admin credentials to access the admin dashboard.
5. **Manage Entities**: Add or modify movies, screens, and shows.([Oracle][3])

---

## 📄 ER Diagram

The Entity-Relationship Diagram (ERD) illustrates the relationships between the system's entities:

![ER Diagram](https://1000projects.org/wp-content/uploads/2019/05/ER-Diagram-1.jpg)

---

## 📌 Notes

* **Database Compatibility**: Ensure compatibility with Oracle Database.
* **Data Integrity**: Referential integrity is maintained through foreign keys.
* **Performance**: Indexes and partitions are used to optimize performance.

---


## 🎬 How to Run Objects in Oracle Movie Ticket Booking Project

---

## 🔹 1. Run **Procedures** from Packages

### 📌 Admin Side

**Add Movie**

```sql
exec admin_mgmt_pkg.add_movie('Avatar 2',192,date'2022-12-16');
```

**Add Screen**

```sql
exec admin_mgmt_pkg.add_screen('Screen 4','PVR Rajkot',30);
```

**Add Show**

```sql
exec admin_mgmt_pkg.add_show(5,4,timestamp'2025-08-23 20:00:00',500);
```

---

### 📌 User Side

**Register User**

```sql
exec user_reg_pkg.register_user('Ravi','ravi@example.com','ravi123','9876543210');
```

**Login User**

```sql
exec user_reg_pkg.login_user('ravi@example.com','ravi123');
```

**Book Ticket**

```sql
exec booking_pkg.book_ticket(1,2,6); -- customer_id=1, show_id=2, seat_id=6
```

**Make Payment**

```sql
exec booking_pkg.make_payment(6,350); -- ticket_id=6, amount=350
```

**Cancel Ticket**

```sql
exec booking_pkg.cancel_ticket(6);
```

---

## 🔹 2. Run **Functions**

**Check Available Seats**

```sql
select booking_pkg.check_available_seats(2) as available_seats from dual;
-- where 2 = show_id
```

**Get Ticket Price**

```sql
select booking_pkg.get_ticket_price(2) as ticket_price from dual;
```

**Login Admin**

```sql
select admin_package.login_admin('admin','admin123') from dual;
```

---

## 🔹 3. Run **Views**

**View All Available Shows**

```sql
select * from v_available_shows;
```

**View Customer Bookings**

```sql
select * from v_customer_bookings where customer_id=1;
```

**View Payments**

```sql
select * from v_payment_details;
```

**View Upcoming Movies**

```sql
select * from v_upcoming_movies;
```

---

## 🔹 4. Run **Triggers**

You don’t run triggers directly — they run **automatically**.
For example:

* **Seat Booking Trigger** (`trg_check_booking`)
  → Fires when inserting into `tickets`.
  Example:

  ```sql
  exec booking_pkg.book_ticket(1,1,1); -- If seat already booked → error
  ```

* **Payment Validation Trigger**
  → Fires when inserting into `payments`.
  Example:

  ```sql
  exec booking_pkg.make_payment(1,100); -- If wrong amount → error
  ```

---

## 🔹 5. Example Full Flow (User Journey)

1. **User Registration**

```sql
exec user_reg_pkg.register_user('Neha','neha@example.com','neha123','9876541230');
```

2. **Login**

```sql
exec user_reg_pkg.login_user('neha@example.com','neha123');
```

3. **View Available Shows**

```sql
select * from v_available_shows;
```

4. **Book Ticket**

```sql
exec booking_pkg.book_ticket(2,2,7);
```

5. **Make Payment**

```sql
exec booking_pkg.make_payment(7,350);
```

6. **Check Bookings**

```sql
select * from v_customer_bookings where customer_id=2;
```

7. **Cancel Ticket**

```sql
exec booking_pkg.cancel_ticket(7);
```

---

## 🔹 6. Example Full Flow (Admin Journey)

1. **Login**

```sql
select admin_package.login_admin('admin','admin123') from dual;
```

2. **Add Movie**

```sql
exec admin_mgmt_pkg.add_movie('Dune 2',170,date'2023-11-03');
```

3. **Add Screen**

```sql
exec admin_mgmt_pkg.add_screen('Screen 5','PVR Mumbai',80);
```

4. **Add Show**

```sql
exec admin_mgmt_pkg.add_show(6,5,timestamp'2025-08-30 18:00:00',600);
```

5. **View All Shows**

```sql
select * from v_available_shows;
```

---

👉 This way you can **run all objects** (procedures, functions, views, triggers) without re-creating them.

---