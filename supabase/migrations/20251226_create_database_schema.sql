-- Migration: Create database schema for Auntentic app
-- Task ID: 3
-- Created: 2025-12-26
-- Description: Create authentications, subscriptions, and free_checks tables with RLS policies

-- ============================================================================
-- TABLE: authentications
-- Purpose: Store AI authentication check results for each user
-- ============================================================================

CREATE TABLE IF NOT EXISTS authentications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  verdict TEXT NOT NULL CHECK (verdict IN ('authentic', 'fake', 'inconclusive')),
  confidence INTEGER NOT NULL CHECK (confidence >= 0 AND confidence <= 100),
  observations JSONB, -- AI observations array
  image_urls TEXT[] NOT NULL, -- Supabase Storage paths
  sneaker_model TEXT -- Detected or user-provided
);

-- Create index for faster user queries
CREATE INDEX IF NOT EXISTS idx_authentications_user_id ON authentications(user_id);
CREATE INDEX IF NOT EXISTS idx_authentications_created_at ON authentications(created_at DESC);

-- Enable Row Level Security
ALTER TABLE authentications ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own authentications
CREATE POLICY "Users can view own authentications" ON authentications
  FOR SELECT USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own authentications
CREATE POLICY "Users can insert own authentications" ON authentications
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- TABLE: subscriptions
-- Purpose: Track user subscription status (supplements StoreKit)
-- ============================================================================

CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  product_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'cancelled')),
  original_transaction_id TEXT,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create index for faster user queries
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);

-- Enable Row Level Security
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own subscription
CREATE POLICY "Users can view own subscription" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- RLS Policy: Users can update their own subscription
CREATE POLICY "Users can update own subscription" ON subscriptions
  FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own subscription
CREATE POLICY "Users can insert own subscription" ON subscriptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- TABLE: free_checks
-- Purpose: Track free check usage (1 free check per user)
-- ============================================================================

CREATE TABLE IF NOT EXISTS free_checks (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  checks_used INTEGER DEFAULT 0 NOT NULL,
  last_check_at TIMESTAMPTZ
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_free_checks_user_id ON free_checks(user_id);

-- Enable Row Level Security
ALTER TABLE free_checks ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own free checks
CREATE POLICY "Users can view own free checks" ON free_checks
  FOR SELECT USING (auth.uid() = user_id);

-- RLS Policy: Users can update their own free checks
CREATE POLICY "Users can update own free checks" ON free_checks
  FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own free check record
CREATE POLICY "Users can insert own free checks" ON free_checks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- FUNCTION: Auto-update updated_at timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for subscriptions table
CREATE TRIGGER update_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Initial data / seed (optional)
-- ============================================================================

-- No seed data needed for production tables
