//
//  SupabaseClient.swift
//  Auntentic_AI
//
//  Created by Bayu Hidayat on 12/25/25.
//  Updated: Task 6 - Supabase Client Initialization
//

import Foundation
import Supabase
import OSLog

/// Supabase client singleton for the entire app
/// Automatically persists session across app launches
enum SupabaseClientManager {
    private static let logger = Logger(subsystem: "com.checkkicks.app", category: "SupabaseClient")
    /// The anon key loaded from Config.plist (exposed for Edge Function auth)
    static let anonKey: String = {
        guard let key = getConfigValue(for: "SUPABASE_ANON_KEY") else {
            fatalError("SUPABASE_ANON_KEY not found in Config.plist. Copy Config.plist.template to Config.plist and add your keys.")
        }
        return key
    }()

    /// Shared Supabase client instance
    static let shared: Supabase.SupabaseClient = {
        guard let url = getConfigValue(for: "SUPABASE_URL"),
              let supabaseURL = URL(string: url) else {
            fatalError("SUPABASE_URL not found in Config.plist. Copy Config.plist.template to Config.plist and add your keys.")
        }

        #if DEBUG
        logger.info("Supabase client initialized from Config.plist")
        #endif

        return Supabase.SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: anonKey
        )
    }()

    /// Read configuration values from Config.plist
    private static func getConfigValue(for key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let value = config[key] as? String else {
            return nil
        }
        return value
    }
}

