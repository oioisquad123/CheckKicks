-- Migration: Create account exceptions table for permanent free trial accounts
-- Created: 2026-01-10
-- Description: Allows specific accounts to bypass credit requirements (for testing/dev purposes)

-- ============================================================================
-- TABLE: account_exceptions
-- Purpose: Store accounts that have permanent free trial (no credit deduction)
-- ============================================================================

CREATE TABLE IF NOT EXISTS account_exceptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email TEXT NOT NULL UNIQUE,
  exception_type TEXT NOT NULL DEFAULT 'permanent_free' CHECK (exception_type IN ('permanent_free', 'beta_tester', 'partner', 'developer')),
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  expires_at TIMESTAMPTZ, -- NULL means never expires
  is_active BOOLEAN DEFAULT true NOT NULL
);

-- Create index for faster email lookups
CREATE INDEX IF NOT EXISTS idx_account_exceptions_email ON account_exceptions(user_email);
CREATE INDEX IF NOT EXISTS idx_account_exceptions_active ON account_exceptions(is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE account_exceptions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: All authenticated users can check if their email is in exceptions
-- (This allows the app to check if current user has exception)
CREATE POLICY "Users can check own exception status" ON account_exceptions
  FOR SELECT USING (auth.jwt() ->> 'email' = user_email);

-- ============================================================================
-- INSERT: Add developer account exception
-- ============================================================================

INSERT INTO account_exceptions (user_email, exception_type, reason)
VALUES ('bayu.hidayat.byh@gmail.com', 'developer', 'Developer account - permanent free trial for testing')
ON CONFLICT (user_email) DO UPDATE SET
  is_active = true,
  exception_type = 'developer',
  reason = 'Developer account - permanent free trial for testing';

-- ============================================================================
-- FUNCTION: Check if user has active exception
-- ============================================================================

CREATE OR REPLACE FUNCTION has_account_exception(check_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM account_exceptions
    WHERE user_email = check_email
      AND is_active = true
      AND (expires_at IS NULL OR expires_at > now())
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
