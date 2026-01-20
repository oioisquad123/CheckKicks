-- ============================================================================
-- COMPREHENSIVE DATABASE SCHEMA TEST REPORT
-- Task 3: Verify all aspects of the database implementation
-- Date: 2025-12-26
-- ============================================================================

\echo '============================================================================'
\echo 'TEST 1: VERIFY ALL TABLES EXIST'
\echo '============================================================================'

SELECT
    'TEST 1: Tables Existence' as test_name,
    COUNT(*) as tables_found,
    CASE
        WHEN COUNT(*) = 3 THEN '✅ PASS - All 3 tables exist'
        ELSE '❌ FAIL - Expected 3 tables, found ' || COUNT(*)
    END as result
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name IN ('authentications', 'subscriptions', 'free_checks');

\echo ''
\echo 'Table Details:'
SELECT
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name)::regclass)) as total_size,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
    AND table_name IN ('authentications', 'subscriptions', 'free_checks')
ORDER BY table_name;

\echo ''
\echo '============================================================================'
\echo 'TEST 2: VERIFY TABLE STRUCTURES (COLUMNS)'
\echo '============================================================================'

\echo ''
\echo 'authentications table columns:'
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name = 'authentications'
ORDER BY ordinal_position;

\echo ''
\echo 'subscriptions table columns:'
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name = 'subscriptions'
ORDER BY ordinal_position;

\echo ''
\echo 'free_checks table columns:'
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name = 'free_checks'
ORDER BY ordinal_position;

\echo ''
\echo '============================================================================'
\echo 'TEST 3: VERIFY ROW LEVEL SECURITY (RLS) IS ENABLED'
\echo '============================================================================'

SELECT
    'TEST 3: RLS Enabled' as test_name,
    tablename,
    rowsecurity as rls_enabled,
    CASE
        WHEN rowsecurity = true THEN '✅ PASS - RLS enabled'
        ELSE '❌ FAIL - RLS not enabled'
    END as result
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('authentications', 'subscriptions', 'free_checks')
ORDER BY tablename;

\echo ''
\echo '============================================================================'
\echo 'TEST 4: VERIFY RLS POLICIES EXIST'
\echo '============================================================================'

SELECT
    'TEST 4: RLS Policies Count' as test_name,
    COUNT(*) as total_policies,
    CASE
        WHEN COUNT(*) >= 9 THEN '✅ PASS - ' || COUNT(*) || ' policies found (expected 9+)'
        ELSE '❌ FAIL - Expected 9+ policies, found ' || COUNT(*)
    END as result
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN ('authentications', 'subscriptions', 'free_checks');

\echo ''
\echo 'RLS Policies Details:'
SELECT
    tablename,
    policyname,
    cmd as operation,
    CASE
        WHEN roles = '{public}' THEN 'public'
        ELSE array_to_string(roles, ', ')
    END as roles
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN ('authentications', 'subscriptions', 'free_checks')
ORDER BY tablename, policyname;

\echo ''
\echo '============================================================================'
\echo 'TEST 5: VERIFY CHECK CONSTRAINTS'
\echo '============================================================================'

SELECT
    'TEST 5: CHECK Constraints' as test_name,
    tc.table_name,
    tc.constraint_name,
    cc.check_clause,
    '✅ EXISTS' as result
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc
    ON tc.constraint_name = cc.constraint_name
WHERE tc.table_schema = 'public'
    AND tc.table_name IN ('authentications', 'subscriptions')
    AND tc.constraint_type = 'CHECK'
ORDER BY tc.table_name, tc.constraint_name;

\echo ''
\echo '============================================================================'
\echo 'TEST 6: VERIFY INDEXES'
\echo '============================================================================'

SELECT
    'TEST 6: Indexes' as test_name,
    tablename,
    indexname,
    '✅ EXISTS' as result
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename IN ('authentications', 'subscriptions', 'free_checks')
    AND indexname NOT LIKE '%_pkey'  -- Exclude primary key indexes
ORDER BY tablename, indexname;

\echo ''
\echo 'Index Count Summary:'
SELECT
    tablename,
    COUNT(*) as index_count
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename IN ('authentications', 'subscriptions', 'free_checks')
GROUP BY tablename
ORDER BY tablename;

\echo ''
\echo '============================================================================'
\echo 'TEST 7: VERIFY FOREIGN KEY CONSTRAINTS'
\echo '============================================================================'

SELECT
    'TEST 7: Foreign Keys' as test_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table,
    ccu.column_name AS foreign_column,
    '✅ EXISTS' as result
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
    AND tc.table_name IN ('authentications', 'subscriptions', 'free_checks')
ORDER BY tc.table_name;

\echo ''
\echo '============================================================================'
\echo 'TEST 8: VERIFY TRIGGERS'
\echo '============================================================================'

SELECT
    'TEST 8: Triggers' as test_name,
    event_object_table as table_name,
    trigger_name,
    event_manipulation as event,
    action_statement,
    '✅ EXISTS' as result
FROM information_schema.triggers
WHERE event_object_schema = 'public'
    AND event_object_table IN ('authentications', 'subscriptions', 'free_checks')
ORDER BY event_object_table, trigger_name;

\echo ''
\echo '============================================================================'
\echo 'TEST 9: TEST DATA INSERTION (Simulated - requires auth.users)'
\echo '============================================================================'

-- Note: Actual data insertion requires authenticated users which we cannot
-- create in this test. This would be tested in integration tests.

SELECT
    'TEST 9: Data Insertion' as test_name,
    'SKIPPED - Requires authenticated user session' as result,
    'ℹ️  This will be tested during integration testing with real auth' as note;

\echo ''
\echo '============================================================================'
\echo 'TEST 10: VERIFY UNIQUE CONSTRAINTS'
\echo '============================================================================'

SELECT
    'TEST 10: Unique Constraints' as test_name,
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    '✅ EXISTS' as result
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public'
    AND tc.table_name IN ('authentications', 'subscriptions', 'free_checks')
    AND tc.constraint_type = 'UNIQUE'
ORDER BY tc.table_name;

\echo ''
\echo '============================================================================'
\echo 'TEST SUMMARY'
\echo '============================================================================'

SELECT
    'COMPREHENSIVE TEST SUMMARY' as summary,
    (SELECT COUNT(*) FROM pg_tables
     WHERE schemaname = 'public'
     AND tablename IN ('authentications', 'subscriptions', 'free_checks')) as tables_created,
    (SELECT COUNT(*) FROM pg_policies
     WHERE schemaname = 'public'
     AND tablename IN ('authentications', 'subscriptions', 'free_checks')) as policies_created,
    (SELECT COUNT(*) FROM pg_indexes
     WHERE schemaname = 'public'
     AND tablename IN ('authentications', 'subscriptions', 'free_checks')) as indexes_created,
    (SELECT COUNT(*) FROM information_schema.table_constraints
     WHERE table_schema = 'public'
     AND table_name IN ('authentications', 'subscriptions', 'free_checks')
     AND constraint_type = 'FOREIGN KEY') as foreign_keys_created;

\echo ''
\echo '✅ Test execution complete!'
\echo 'Review the results above for any failures.'
