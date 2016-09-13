create table 'cats'
  (
    id serial,
    email text,
    hashed_password text,
    created_at timestamp,
    updated_at timestamp,
    last_sign_in timestamp,
    primary key(id)
  )
;
