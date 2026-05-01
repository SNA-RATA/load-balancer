CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    text VARCHAR(255) NOT NULL
);

INSERT INTO notes (text) VALUES ('Hello from Dockerized Postgres!');