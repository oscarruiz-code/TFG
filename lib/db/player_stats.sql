CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    role VARCHAR(20) NOT NULL DEFAULT 'admin'
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    is_blocked BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    role VARCHAR(20) NOT NULL DEFAULT 'user'
);

INSERT INTO admins (username, email, password, role)
VALUES ('superadmin', 'superadmin@admin.com', '0000', 'admin');

CREATE TABLE player_stats (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    tickets_game2 INTEGER DEFAULT 0,
    coins BIGINT DEFAULT 0,
    rename_tickets INTEGER DEFAULT 0,
    has_used_free_rename BOOLEAN DEFAULT FALSE,
    current_avatar VARCHAR(255) DEFAULT 'assets/avatar/defecto.png',
    unlocked_premium_avatars VARCHAR(1000) DEFAULT '',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE game_history (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    game_type INTEGER NOT NULL,
    score INTEGER NOT NULL,
    coins INTEGER DEFAULT 0,
    victory BOOLEAN DEFAULT FALSE,
    duration INTEGER NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE admin_stats (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    admin_id INTEGER NOT NULL,
    tickets_game2 INTEGER DEFAULT 0,
    coins BIGINT DEFAULT 0,
    rename_tickets INTEGER DEFAULT 0,
    has_used_free_rename BOOLEAN DEFAULT FALSE,
    current_avatar VARCHAR(255) DEFAULT 'assets/avatar/defecto.png',
    unlocked_premium_avatars VARCHAR(1000) DEFAULT '',
    FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE
);

CREATE TABLE admin_game_history (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    admin_id INTEGER NOT NULL,
    game_type INTEGER NOT NULL,
    score INTEGER NOT NULL,
    coins INTEGER DEFAULT 0,
    victory BOOLEAN DEFAULT FALSE,
    duration INTEGER NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE
);

CREATE TABLE game_saves (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    game_type INTEGER NOT NULL,
    position_x FLOAT NOT NULL,
    position_y FLOAT NOT NULL,
    current_level INTEGER NOT NULL,
    coins_collected INTEGER DEFAULT 0,
    health INTEGER DEFAULT 100,
    world_offset FLOAT DEFAULT 0,
    last_checkpoint VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE admin_game_saves (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    admin_id INTEGER NOT NULL,
    game_type INTEGER NOT NULL,
    position_x FLOAT NOT NULL,
    position_y FLOAT NOT NULL,
    current_level INTEGER NOT NULL,
    coins_collected INTEGER DEFAULT 0,
    health INTEGER DEFAULT 100,
    world_offset FLOAT DEFAULT 0,
    last_checkpoint VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE
);