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

-- Insertar el administrador predefinido
INSERT INTO admins (username, email, password, role)
VALUES ('admin', 'admin@admin.com', 'admin', 'admin');

CREATE TABLE player_stats (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    tickets_game2 INTEGER DEFAULT 0,
    coins BIGINT DEFAULT 0,
    rename_tickets INTEGER DEFAULT 0,
    has_used_free_rename BOOLEAN DEFAULT FALSE,
    current_avatar VARCHAR(255) DEFAULT 'assets/avatar/defecto.png',
    unlocked_premium_avatars VARCHAR(1000) DEFAULT '',
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE game_history (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    game_type INTEGER NOT NULL,
    score INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);