CREATE TABLE nmarangi_spookymovies(
    movie_id INT IDENTITY(35000, 1) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    release_year INT NOT NULL,
    age_rating VARCHAR(10) NOT NULL,
    runtime INT NOT NULL,
    rating FLOAT NOT NULL,
    metascore INT NOT NULL,
    director VARCHAR(50) NOT NULL,
    votes INT NOT NULL,
    gross_profit INT NOT NULL,
    CONSTRAINT check_runtime CHECK (runtime <= 51240),
    CONSTRAINT title UNIQUE (title, release_year),
    CONSTRAINT check_rating CHECK (rating <= 10.0),
    CONSTRAINT check_metascore CHECK (metascore <= 100),
    CONSTRAINT check_release_year CHECK (release_year >= 1878)
);