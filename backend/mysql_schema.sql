SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =====================
-- users
-- =====================
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255),
  full_name VARCHAR(120) NOT NULL,
  gender ENUM('male','female','other'),
  avatar_url VARCHAR(1024),
  birth_date DATE,
  bio VARCHAR(255),
  role ENUM('user','admin') NOT NULL DEFAULT 'user',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  auth_provider ENUM('local','google') NOT NULL DEFAULT 'local',
  fcm_token VARCHAR(255),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- user_settings
-- =====================
CREATE TABLE user_settings (
  user_id BIGINT UNSIGNED PRIMARY KEY,
  notifications_enabled TINYINT(1) NOT NULL DEFAULT 1,
  privacy_mode ENUM('normal','strict') NOT NULL DEFAULT 'normal',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_settings_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- refresh_tokens
-- =====================
CREATE TABLE refresh_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  is_revoked TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_refresh_token_hash (token_hash),
  KEY fk_refresh_user (user_id),
  CONSTRAINT fk_refresh_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- qr_tokens
-- =====================
CREATE TABLE qr_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token CHAR(36) NOT NULL,
  expires_at DATETIME NOT NULL,
  is_used TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_qr_token (token),
  KEY fk_qr_user (user_id),
  CONSTRAINT fk_qr_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- couples
-- =====================
CREATE TABLE couples (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user1_id BIGINT UNSIGNED NOT NULL,
  user2_id BIGINT UNSIGNED NOT NULL,
  cover_image VARCHAR(1024),
  nickname_1 VARCHAR(120),
  nickname_2 VARCHAR(120),
  start_date DATE NOT NULL,
  end_date DATE,
  bubble_color VARCHAR(16) DEFAULT '#0084FF',
  quick_emoji VARCHAR(8) DEFAULT '?',
  background_theme VARCHAR(32) DEFAULT 'default',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY fk_couples_user1 (user1_id),
  KEY fk_couples_user2 (user2_id),
  CONSTRAINT fk_couples_user1 FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_couples_user2 FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- couple_requests
-- =====================
CREATE TABLE couple_requests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED,
  qr_token CHAR(36) NOT NULL,
  status ENUM('pending','accepted','rejected','expired') NOT NULL DEFAULT 'pending',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY fk_request_from (from_user_id),
  KEY fk_request_to (to_user_id),
  KEY fk_request_qr (qr_token),
  CONSTRAINT fk_request_from FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_request_to FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_request_qr FOREIGN KEY (qr_token) REFERENCES qr_tokens(token) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- messages
-- =====================
CREATE TABLE messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  couple_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,
  content TEXT,
  img_url TEXT,
  thumbnail_url TEXT,
  type ENUM('text','image','system') NOT NULL DEFAULT 'text',
  is_read TINYINT(1) DEFAULT 0,
  is_deleted TINYINT(1) DEFAULT 0,
  read_at TIMESTAMP NULL,
  edited_at TIMESTAMP NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY fk_msg_couple (couple_id),
  KEY fk_msg_sender (sender_id),
  CONSTRAINT fk_msg_couple FOREIGN KEY (couple_id) REFERENCES couples(id) ON DELETE CASCADE,
  CONSTRAINT fk_msg_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- message_reactions
-- =====================
CREATE TABLE message_reactions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  message_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  emoji VARCHAR(16) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_message_user_reaction (message_id, user_id),
  CONSTRAINT fk_reaction_message FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
  CONSTRAINT fk_reaction_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- memories
-- =====================
CREATE TABLE memories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  couple_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  title VARCHAR(120) NOT NULL,
  description TEXT,
  image_url VARCHAR(1024),
  memory_date DATE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_memories_couple FOREIGN KEY (couple_id) REFERENCES couples(id),
  CONSTRAINT fk_memories_user FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- moments
-- =====================
CREATE TABLE moments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  couple_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(1024) NOT NULL,
  caption VARCHAR(255),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_moments_couple FOREIGN KEY (couple_id) REFERENCES couples(id),
  CONSTRAINT fk_moments_user FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================
-- files
-- =====================
CREATE TABLE files (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  owner_id BIGINT UNSIGNED NOT NULL,
  url VARCHAR(1024) NOT NULL,
  file_type ENUM('image','video') NOT NULL,
  purpose ENUM('avatar','cover','chat','moment') NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_file_owner FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
