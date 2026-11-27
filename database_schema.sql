-- ================================================================
-- FORREST APP — Database Schema v1.0
-- Jalankan di: Supabase Dashboard > SQL Editor > New Query
-- ================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================================
-- 1. catalog_items
-- ================================================================
CREATE TABLE IF NOT EXISTS catalog_items (
  id              TEXT PRIMARY KEY,
  type            TEXT NOT NULL CHECK (type IN ('tree', 'theme')),
  name_id         TEXT NOT NULL,
  name_en         TEXT NOT NULL,
  description_id  TEXT,
  description_en  TEXT,
  asset_key       TEXT NOT NULL,
  price_coins     INTEGER NOT NULL DEFAULT 0,
  is_default      BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order      INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO catalog_items (id, type, name_id, name_en, asset_key, price_coins, is_default, sort_order) VALUES
  ('tree_oak',       'tree',  'Pohon Oak',    'Oak Tree',       'oak',      0,   TRUE,  1),
  ('tree_cherry',    'tree',  'Pohon Sakura', 'Cherry Blossom', 'cherry',   150, FALSE, 2),
  ('tree_pine',      'tree',  'Pohon Pinus',  'Pine Tree',      'pine',     150, FALSE, 3),
  ('tree_bamboo',    'tree',  'Bambu',        'Bamboo',         'bamboo',   200, FALSE, 4),
  ('tree_cactus',    'tree',  'Kaktus',       'Cactus',         'cactus',   100, FALSE, 5),
  ('theme_default',  'theme', 'Hutan Hijau',  'Green Forest',   'default',  0,   TRUE,  1),
  ('theme_desert',   'theme', 'Gurun Pasir',  'Desert',         'desert',   300, FALSE, 2),
  ('theme_snow',     'theme', 'Hutan Salju',  'Snowy Forest',   'snow',     400, FALSE, 3),
  ('theme_tropical', 'theme', 'Hutan Tropis', 'Tropical',       'tropical', 350, FALSE, 4)
ON CONFLICT (id) DO NOTHING;

-- ================================================================
-- 2. profiles
-- ================================================================
CREATE TABLE IF NOT EXISTS profiles (
  id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username              TEXT UNIQUE,
  display_name          TEXT,
  avatar_color          TEXT DEFAULT '#2E7D32',
  coins                 INTEGER NOT NULL DEFAULT 0 CHECK (coins >= 0),
  streak_days           INTEGER NOT NULL DEFAULT 0,
  last_focus_date       DATE,
  equipped_tree_id      TEXT REFERENCES catalog_items(id) DEFAULT 'tree_oak',
  equipped_theme_id     TEXT REFERENCES catalog_items(id) DEFAULT 'theme_default',
  language              TEXT DEFAULT 'id' CHECK (language IN ('id', 'en')),
  notify_reminder       BOOLEAN DEFAULT TRUE,
  reminder_time         TIME DEFAULT '08:00:00',
  total_focus_seconds   BIGINT DEFAULT 0,
  total_sessions        INTEGER DEFAULT 0,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id, username, display_name)
  VALUES (NEW.id, SPLIT_PART(NEW.email, '@', 1), SPLIT_PART(NEW.email, '@', 1))
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ================================================================
-- 3. tags
-- ================================================================
CREATE TABLE IF NOT EXISTS tags (
  id          TEXT PRIMARY KEY,
  name_id     TEXT NOT NULL,
  name_en     TEXT NOT NULL,
  icon        TEXT NOT NULL DEFAULT '🏷️',
  color_hex   TEXT NOT NULL DEFAULT '#757575',
  is_custom   BOOLEAN NOT NULL DEFAULT FALSE,
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE,
  sort_order  INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO tags (id, name_id, name_en, icon, color_hex, is_custom, sort_order) VALUES
  ('belajar',   'Belajar',             'Study',      '📚', '#1565C0', FALSE, 1),
  ('tugas',     'Tugas / Proyek',      'Assignment', '📝', '#6A1B9A', FALSE, 2),
  ('membaca',   'Membaca',             'Reading',    '📖', '#00695C', FALSE, 3),
  ('olahraga',  'Olahraga',            'Exercise',   '🏃', '#E65100', FALSE, 4),
  ('freelance', 'Pekerjaan Sampingan', 'Freelance',  '💼', '#37474F', FALSE, 5),
  ('lainnya',   'Lainnya',             'Other',      '🌀', '#757575', FALSE, 6)
ON CONFLICT (id) DO NOTHING;

-- ================================================================
-- 4. focus_sessions
-- ================================================================
CREATE TABLE IF NOT EXISTS focus_sessions (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id                 UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  mode                    TEXT NOT NULL CHECK (mode IN ('timer', 'stopwatch')),
  tag_id                  TEXT REFERENCES tags(id) DEFAULT 'lainnya',
  tree_type_id            TEXT REFERENCES catalog_items(id) DEFAULT 'tree_oak',
  duration_target_seconds INTEGER,
  duration_actual_seconds INTEGER NOT NULL DEFAULT 0,
  is_completed            BOOLEAN NOT NULL DEFAULT FALSE,
  coins_earned            INTEGER NOT NULL DEFAULT 0,
  grid_x                  INTEGER,
  grid_y                  INTEGER,
  note                    TEXT,
  started_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at                TIMESTAMPTZ,
  created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sessions_user    ON focus_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_started ON focus_sessions(user_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_tag     ON focus_sessions(user_id, tag_id);

-- ================================================================
-- 5. user_inventory
-- ================================================================
CREATE TABLE IF NOT EXISTS user_inventory (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  item_id      TEXT NOT NULL REFERENCES catalog_items(id),
  purchased_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, item_id)
);

CREATE OR REPLACE FUNCTION grant_default_items()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO user_inventory (user_id, item_id)
  SELECT NEW.id, id FROM catalog_items WHERE is_default = TRUE
  ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_profile_created ON profiles;
CREATE TRIGGER on_profile_created
  AFTER INSERT ON profiles
  FOR EACH ROW EXECUTE FUNCTION grant_default_items();

-- ================================================================
-- 6. challenges
-- ================================================================
CREATE TABLE IF NOT EXISTS challenges (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  week_start  DATE NOT NULL,
  week_end    DATE NOT NULL,
  status      TEXT DEFAULT 'active' CHECK (status IN ('active', 'finished')),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS challenge_members (
  id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id         UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  user_id              UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  total_focus_seconds  INTEGER DEFAULT 0,
  rank                 INTEGER,
  joined_at            TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(challenge_id, user_id)
);

-- ================================================================
-- 7. ROW LEVEL SECURITY
-- ================================================================
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE focus_sessions    ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags              ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalog_items     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_inventory    ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges        ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_members ENABLE ROW LEVEL SECURITY;

-- profiles
DROP POLICY IF EXISTS "view_own_profile"   ON profiles;
DROP POLICY IF EXISTS "update_own_profile" ON profiles;
CREATE POLICY "view_own_profile"   ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "update_own_profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- focus_sessions
DROP POLICY IF EXISTS "own_sessions" ON focus_sessions;
CREATE POLICY "own_sessions" ON focus_sessions FOR ALL USING (auth.uid() = user_id);

-- tags
DROP POLICY IF EXISTS "read_tags"         ON tags;
DROP POLICY IF EXISTS "insert_custom_tag" ON tags;
DROP POLICY IF EXISTS "delete_custom_tag" ON tags;
CREATE POLICY "read_tags"         ON tags FOR SELECT USING (is_custom = FALSE OR auth.uid() = user_id);
CREATE POLICY "insert_custom_tag" ON tags FOR INSERT WITH CHECK (auth.uid() = user_id AND is_custom = TRUE);
CREATE POLICY "delete_custom_tag" ON tags FOR DELETE USING (auth.uid() = user_id AND is_custom = TRUE);

-- catalog_items (public read)
DROP POLICY IF EXISTS "public_catalog" ON catalog_items;
CREATE POLICY "public_catalog" ON catalog_items FOR SELECT USING (TRUE);

-- user_inventory
DROP POLICY IF EXISTS "own_inventory" ON user_inventory;
CREATE POLICY "own_inventory" ON user_inventory FOR ALL USING (auth.uid() = user_id);

-- challenges
DROP POLICY IF EXISTS "read_challenges"   ON challenges;
DROP POLICY IF EXISTS "create_challenges" ON challenges;
CREATE POLICY "read_challenges"   ON challenges FOR SELECT USING (TRUE);
CREATE POLICY "create_challenges" ON challenges FOR INSERT WITH CHECK (auth.uid() = creator_id);

-- challenge_members
DROP POLICY IF EXISTS "read_my_challenges" ON challenge_members;
DROP POLICY IF EXISTS "join_challenge"     ON challenge_members;
CREATE POLICY "read_my_challenges" ON challenge_members FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "join_challenge"     ON challenge_members FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ================================================================
-- VERIFIKASI — jalankan query ini setelah selesai:
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' ORDER BY table_name;
-- ================================================================
