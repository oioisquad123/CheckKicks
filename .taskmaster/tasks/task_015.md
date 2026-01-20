# Task ID: 15

**Title:** Implement free credits for new users and credit verification

**Status:** pending

**Dependencies:** 3, 6, 13, 14

**Priority:** high

**Phase:** 1D - Monetization (implement AFTER Task 14 is complete)

**Description:** Give new users 3 free credits, verify credit balance before allowing authentication checks (FR-6.3, FR-6.6)

**Free Tier Strategy:**
- New users get 3 FREE credits (lifetime, one-time)
- Each authentication uses 1 credit
- When credits = 0, show purchase screen
- No cooldown, no daily limits

**Details:**

**1. Database Schema (Supabase)**

Create `user_credits` table:
```sql
CREATE TABLE user_credits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    credits INTEGER DEFAULT 3 NOT NULL,
    total_purchased INTEGER DEFAULT 0 NOT NULL,
    total_used INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;

-- Users can only read their own credits
CREATE POLICY "Users can read own credits"
ON user_credits FOR SELECT
USING (auth.uid() = user_id);

-- Users can update their own credits (for deduction)
CREATE POLICY "Users can update own credits"
ON user_credits FOR UPDATE
USING (auth.uid() = user_id);

-- Auto-create row for new users with 3 free credits
CREATE OR REPLACE FUNCTION create_user_credits()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_credits (user_id, credits)
    VALUES (NEW.id, 3);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION create_user_credits();
```

**2. Credit Check Flow**

```swift
// In CreditManager.swift
func checkCreditsBeforeAuth() async throws -> Bool {
    // 1. Fetch current credits from Supabase
    let response = try await supabase
        .from("user_credits")
        .select()
        .eq("user_id", currentUserId)
        .single()
        .execute()

    let userCredits = try JSONDecoder().decode(UserCredits.self, from: response.data)
    self.credits = userCredits.credits

    // 2. Check if sufficient credits
    if credits <= 0 {
        throw CreditError.insufficientCredits
    }

    return true
}
```

**3. Credit Deduction After Authentication**

```swift
func useCredit() async throws {
    // 1. Verify we have credits
    guard credits > 0 else {
        throw CreditError.insufficientCredits
    }

    // 2. Deduct locally first (optimistic)
    credits -= 1

    // 3. Update Supabase
    try await supabase
        .from("user_credits")
        .update([
            "credits": credits,
            "total_used": \.total_used + 1,
            "updated_at": Date()
        ])
        .eq("user_id", currentUserId)
        .execute()

    // 4. Cache locally
    UserDefaults.standard.set(credits, forKey: "cached_credits")
}
```

**4. Local Caching for Offline**

```swift
// Cache credits locally for offline access
@AppStorage("cached_credits") private var cachedCredits: Int = 0

func syncCredits() async {
    do {
        let serverCredits = try await fetchCreditsFromSupabase()
        self.credits = serverCredits
        cachedCredits = serverCredits
    } catch {
        // Use cached value if offline
        self.credits = cachedCredits
    }
}
```

**5. Integration Points**

- **On App Launch:** Sync credits from Supabase
- **Before Authentication:** Check credits > 0
- **After Authentication:** Deduct 1 credit
- **On Purchase:** Add purchased credits
- **Show Purchase Screen:** When credits = 0

**6. UI Integration**

```swift
// In PhotoReviewView or HomeView
Button("Authenticate") {
    Task {
        do {
            // Check credits first
            guard creditManager.credits > 0 else {
                showPurchaseScreen = true
                return
            }

            // Proceed with authentication
            await performAuthentication()

            // Deduct credit after success
            try await creditManager.useCredit()
        } catch CreditError.insufficientCredits {
            showPurchaseScreen = true
        }
    }
}
```

**Test Strategy:**

**Test Cases:**
- [ ] New user signup → automatically gets 3 credits
- [ ] Check credits balance displays correctly
- [ ] First authentication → credits = 2
- [ ] Second authentication → credits = 1
- [ ] Third authentication → credits = 0
- [ ] Fourth authentication attempt → shows purchase screen
- [ ] Credits sync correctly after app restart
- [ ] Offline mode uses cached credits
- [ ] Purchase adds credits correctly
- [ ] Multiple purchases accumulate

**Edge Cases:**
- [ ] User deletes app and reinstalls (credits in Supabase persist)
- [ ] Network error during deduction (rollback local change)
- [ ] Concurrent requests don't double-deduct

**Completion Criteria:**
- [ ] user_credits table created in Supabase
- [ ] Trigger auto-creates 3 credits for new users
- [ ] Credit check before authentication works
- [ ] Credit deduction after authentication works
- [ ] Local caching for offline access
- [ ] Purchase screen shown when credits = 0
- [ ] All test cases pass
