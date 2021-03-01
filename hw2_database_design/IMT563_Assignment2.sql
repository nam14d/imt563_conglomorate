-- 0. country --
CREATE TABLE country(
    country_id INT IDENTITY(95000,1) PRIMARY KEY,
    country_name VARCHAR(40) NOT NULL,
    country_population INT NOT NULL,
    modification_date DATETIME NOT NULL
);

-- 1. artist --
CREATE TABLE artist(
    artist_id INT IDENTITY(50000,1) PRIMARY KEY,
    country_id INT NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    modification_date DATETIME NOT NULL,
    CONSTRAINT country_id FOREIGN KEY (country_id) REFERENCES country (country_id)
);

-- 2. production_unit --
CREATE TABLE production_unit(
    production_unit_id INT IDENTITY(70000,1) PRIMARY KEY,
    unit_name VARCHAR(40) NOT NULL,
    founding_date DATE NOT NULL,
    modification_date DATETIME NOT NULL
);

-- 3. artist_production_unit --
CREATE TABLE artist_production_unit(
    artist_id INT NOT NULL,
    production_unit_id INT NOT NULL,
    artist_join_date DATE NOT NULL,
    artist_leave_date DATE,
    artist_role VARCHAR(20) NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY (artist_id,production_unit_id),
    CONSTRAINT artist_id FOREIGN KEY (artist_id) REFERENCES artist (artist_id),
    CONSTRAINT production_unit_id FOREIGN KEY (production_unit_id) REFERENCES production_unit (production_unit_id)
);

-- 4. record_company --
CREATE TABLE record_company(
    record_company_id INT IDENTITY(45000,1) PRIMARY KEY,
    record_company_name VARCHAR(40) NOT NULL,
    founding_date DATE NOT NULL,
    record_company_address VARCHAR(40) NOT NULL,
    modification_date DATETIME NOT NULL
);

-- 5. record_company_production_unit_collaboration --
CREATE TABLE record_company_production_unit_collaboration(
    record_company_id INT NOT NULL,
    production_unit_id INT NOT NULL,
    modification_date DATE NOT NULL,
    PRIMARY KEY (record_company_id,production_unit_id),
    CONSTRAINT record_company_id FOREIGN KEY (record_company_id) REFERENCES record_company (record_company_id),
    CONSTRAINT production_unit_id FOREIGN KEY (production_unit_id) REFERENCES production_unit (production_unit_id)
);

-- 6. album --
CREATE TABLE album(
    album_id INT IDENTITY(90000,1) PRIMARY KEY,
    production_unit_id INT NOT NULL,
    album_title VARCHAR(40) NOT NULL,
    release_date DATE NOT NULL,
    modification_date DATETIME NOT NULL,
    CONSTRAINT production_unit_id FOREIGN KEY (production_unit_id) REFERENCES production_unit (production_unit_id)
);

-- 7. track -- 
CREATE TABLE track(
    track_id INT IDENTITY(101000,1) PRIMARY KEY,
    album_id INT NOT NULL,
    track_name VARCHAR(40) NOT NULL,
    track_length_seconds INT NOT NULL,
    modification_date DATETIME NOT NULL,
    CONSTRAINT album_id FOREIGN KEY (album_id) REFERENCES album (album_id)
);

-- 8. genre --
CREATE TABLE genre(
    genre_id INT IDENTITY(30000,1) PRIMARY KEY,
    genre_name VARCHAR(40) NOT NULL,
    genre_desc VARCHAR(200) NOT NULL,
    modification_date DATETIME NOT NULL
);

-- 9. track_genre --
CREATE TABLE song_genre(
    genre_id INT NOT NULL,
    track_id INT NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY (genre_id,track_id),
    CONSTRAINT genre_id FOREIGN KEY (genre_id) REFERENCES genre (genre_id),
    CONSTRAINT track_id FOREIGN KEY (track_id) REFERENCES track (track_id)
);

-- 10. user --
CREATE TABLE user(
    user_id INT IDENTITY(100000,1) PRIMARY KEY,
    country_id INT NOT NULL,
    username VARCHAR(40) NOT NULL,
    account_number INT NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    age INT NOT NULL,
    email VARCHAR(40) NOT NULL,
    home_address VARCHAR(40) NOT NULL,
    last_active DATETIME NOT NULL,
    modification_date DATETIME NOT NULL,
    CONSTRAINT country_id FOREIGN KEY (country_id) REFERENCES country (country_id)
);

-- 11. user_track --
CREATE TABLE user_track(
    user_id INT NOT NULL,
    track_id INT NOT NULL,
    like_status BIT NOT NULL,
    rating INT NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY (user_id,track_id),
    CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES user (user_id),
    CONSTRAINT track_id FOREIGN KEY (track_id) REFERENCES track (track_id)
);

-- 12. device --
CREATE TABLE device(
    device_id INT IDENTITY(90000,1) PRIMARY KEY,
    device_name VARCHAR(40) NOT NULL,
    device_type VARCHAR(40) NOT NULL,
    modification_date DATETIME NOT NULL
);

-- 13. user_device --
CREATE TABLE user_device(
    user_id INT NOT NULL,
    device_id INT NOT NULL,
    device_nickname VARCHAR(40) NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY (user_id,device_id),
    CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES user (user_id),
    CONSTRAINT device_id FOREIGN KEY (device_id) REFERENCES device (device_id)
);

-- 14. playlist --
CREATE TABLE playlist(
    playlist_id INT IDENTITY(80000,1) PRIMARY KEY,
    playlist_name VARCHAR(20) NOT NULL,
    creation_date DATETIME NOT NULL,
    modification_date DATETIME NOT NULL
);

-- 15. user_playlist --
CREATE TABLE user_playlist(
    user_id INT NOT NULL,
    playlist_id INT NOT NULL,
    play_count INT NOT NULL,
    rating INT NOT NULL,
    follower_status BIT NOT NULL,
    like_status BIT NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY(user_id,playlist_id),
    CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES user (user_id),
    CONSTRAINT playlist_id FOREIGN KEY (playlist_id) REFERENCES playlist (playlist_id)
);

-- 16. playlist_track -- 
CREATE TABLE playlist_track(
    user_id INT NOT NULL,
    track_id INT NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY(user_id,track_id),
    CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES user (user_id),
    CONSTRAINT track_id FOREIGN KEY (track_id) REFERENCES track (track_id)
);

-- 17. user_user --
CREATE TABLE user_user(
    user_id INT NOT NULL,
    follower_id INT NOT NULL,
    follower_status BIT NOT NULL,
    like_status BIT NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY (user_id,follower_id),
    CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES user (user_id),
    CONSTRAINT follower_id FOREIGN KEY (follower_id) REFERENCES user (user_id)
);

-- 18. user_artist --
CREATE TABLE user_artist(
    user_id INT NOT NULL,
    artist_id INT NOT NULL,
    follower_status BIT NOT NULL,
    like_status BIT NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY (user_id,artist_id),
    CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES user (user_id)
    CONSTRAINT artist_id FOREIGN KEY (artist_id) REFERENCES artist (artist_id)
);

-- 19. user_album -- 
CREATE TABLE user_album(
    user_id INT NOT NULL,
    album_id INT NOT NULL,
    follower_status BIT NOT NULL,
    like_status BIT NOT NULL,
    modification_date DATETIME NOT NULL,
    PRIMARY KEY (user_id,album_id),
    CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES user (user_id),
    CONSTRAINT album_id FOREIGN KEY (album_id) REFERENCES album (album_id)
);