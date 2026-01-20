-- Confirm all existing users to allow immediate sign-in
-- This bypasses the email confirmation requirement for existing accounts

UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;
