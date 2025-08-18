create table movies (
    movie_id     number primary key,
    title        varchar2(150),
    duration     number,
    release_date date
)
partition by range (release_date) (
    partition old_movies values less than (date '2020-01-01')
        tablespace temp,   -- old movies before 2020 in TEMP tablespace
    partition new_movies values less than (maxvalue)
        tablespace users   -- movies from 2020 onwards in USERS tablespace
);
