-- ============================================================
-- Study Buddy — Initial Schema Migration
-- Jalankan via: supabase db push atau Supabase dashboard SQL editor
-- ============================================================

-- Users (extend auth.users)
CREATE TABLE public.users (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       TEXT NOT NULL UNIQUE,
  full_name   TEXT NOT NULL,
  role        TEXT NOT NULL CHECK (role IN ('customer', 'tutor', 'management')),
  avatar_url  TEXT,
  fcm_token   TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Tutors (detail profil tutor)
CREATE TABLE public.tutors (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  full_name      TEXT NOT NULL,
  bio            TEXT,
  subjects       TEXT[] DEFAULT '{}',
  rating         NUMERIC(3,1) DEFAULT 0,
  total_sessions INT DEFAULT 0,
  total_reviews  INT DEFAULT 0,
  price_per_hour NUMERIC(10,2) NOT NULL DEFAULT 50000,
  gmeet_link     TEXT,
  university     TEXT,
  gpa            NUMERIC(3,2),
  is_online      BOOLEAN DEFAULT FALSE,
  last_seen      TIMESTAMPTZ,
  status         TEXT DEFAULT 'pending' CHECK (status IN ('pending','active','inactive')),
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Bookings
CREATE TABLE public.bookings (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id      UUID NOT NULL REFERENCES public.users(id),
  tutor_id         UUID NOT NULL REFERENCES public.tutors(id),
  session_time     TIMESTAMPTZ NOT NULL,
  duration_minutes INT NOT NULL DEFAULT 60,
  subject          TEXT NOT NULL,
  session_type     TEXT NOT NULL CHECK (session_type IN ('video','chat')),
  status           TEXT NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending','confirmed','ongoing','done','cancelled')),
  notes            TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Sessions
CREATE TABLE public.sessions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id      UUID NOT NULL REFERENCES public.bookings(id),
  start_time      TIMESTAMPTZ NOT NULL,
  end_time        TIMESTAMPTZ,
  status          TEXT DEFAULT 'active' CHECK (status IN ('active','ended')),
  gmeet_link      TEXT,
  elapsed_seconds INT DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews
CREATE TABLE public.reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id  UUID NOT NULL REFERENCES public.sessions(id),
  customer_id UUID NOT NULL REFERENCES public.users(id),
  tutor_id    UUID NOT NULL REFERENCES public.tutors(id),
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  subject     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies (aktifkan Row Level Security)
ALTER TABLE public.users    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutors   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews  ENABLE ROW LEVEL SECURITY;

-- Realtime: aktifkan untuk tabel yang perlu live update
ALTER PUBLICATION supabase_realtime ADD TABLE public.tutors;
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;