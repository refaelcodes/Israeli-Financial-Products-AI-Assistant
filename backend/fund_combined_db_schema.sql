-- =============================================================================
-- FUND_COMBINED_DB - Unified SQLite Schema
-- =============================================================================
-- Version: 1.0
-- Description: Combined Israeli Pension & Provident Fund Database
--              Merges fund statistics (Gemel/Pensia) with fund asset holdings
-- Sources:
--   - fund_statistic_db_schema.sql (Gemel & Pensia tables)
--   - fund_asset_db_schema.sql (29 asset tables + 3 metadata tables)
-- =============================================================================

PRAGMA foreign_keys = ON;
PRAGMA encoding = 'UTF-8';


-- =============================================================================
-- PART 1: METADATA TABLES (shared across all data)
-- =============================================================================

-- Table registry - describes every table in the database
CREATE TABLE IF NOT EXISTS _table_metadata (
    table_name_en TEXT PRIMARY KEY,
    table_name_he TEXT NOT NULL,
    description_en TEXT,
    description_he TEXT
);

-- Column dictionary - describes every column in every table
CREATE TABLE IF NOT EXISTS _column_metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name_en TEXT NOT NULL,
    column_name_en TEXT NOT NULL,
    column_name_he TEXT NOT NULL,
    english_term TEXT,
    description_en TEXT,
    description_he TEXT,
    data_type TEXT,
    examples TEXT,
    UNIQUE(table_name_en, column_name_en)
);

-- Ingestion audit log - tracks every file load (statistics + assets)
CREATE TABLE IF NOT EXISTS _ingestion_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT (datetime('now')),
    source_file TEXT,
    sheet_name TEXT,
    target_table TEXT,
    rows_read INTEGER DEFAULT 0,
    rows_inserted INTEGER DEFAULT 0,
    rows_skipped INTEGER DEFAULT 0,
    errors INTEGER DEFAULT 0,
    fair_value_scaled INTEGER DEFAULT 0,
    notes TEXT
);


-- =============================================================================
-- PART 2: FUND STATISTICS TABLES (from fund_statistic_db_schema.sql)
-- =============================================================================
-- These tables store monthly fund-level KPIs loaded from Gemel-Net and
-- Pension-Net Excel extracts.
-- =============================================================================

-- ============================================================
-- Gemel (Provident Funds) / קופות גמל
-- ============================================================
-- EN: Gemel (Provident Funds) - Israeli savings and provident funds data.
--     Raw table mirroring the Excel extract from gemel-net system.
-- HE: גמל - קופות גמל וחיסכון ישראליות. טבלה גולמית המשקפת את קובץ האקסל ממערכת גמל-נט.
-- Source: Data Dictionary v3.2 | Record Count: ~2,500 funds
-- Excel columns: FUND_ID, FUND_NAME, FUND_CLASSIFICATION, CONTROLLING_CORPORATION,
--   MANAGING_CORPORATION, REPORT_PERIOD, INCEPTION_DATE, TARGET_POPULATION,
--   SPECIALIZATION, SUB_SPECIALIZATION, DEPOSITS, WITHDRAWLS, INTERNAL_TRANSFERS,
--   NET_MONTHLY_DEPOSITS, TOTAL_ASSETS, AVG_ANNUAL_MANAGEMENT_FEE, AVG_DEPOSIT_FEE,
--   MONTHLY_YIELD, YEAR_TO_DATE_YIELD, YIELD_TRAILING_3_YRS, YIELD_TRAILING_5_YRS,
--   AVG_ANNUAL_YIELD_TRAILING_3YRS, AVG_ANNUAL_YIELD_TRAILING_5YRS, STANDARD_DEVIATION,
--   ALPHA, SHARPE_RATIO, LIQUID_ASSETS_PERCENT, STOCK_MARKET_EXPOSURE,
--   FOREIGN_EXPOSURE, FOREIGN_CURRENCY_EXPOSURE, MANAGING_CORPORATION_LEGAL_ID, CURRENT_DATE

CREATE TABLE IF NOT EXISTS "Gemel" (
    "FUND_ID" REAL,
    "FUND_NAME" TEXT,
    "FUND_CLASSIFICATION" TEXT,
    "CONTROLLING_CORPORATION" TEXT,
    "MANAGING_CORPORATION" TEXT,
    "REPORT_PERIOD" REAL,
    "INCEPTION_DATE" TEXT,
    "TARGET_POPULATION" TEXT,
    "SPECIALIZATION" TEXT,
    "SUB_SPECIALIZATION" TEXT,
    "DEPOSITS" REAL,
    "WITHDRAWLS" REAL,
    "INTERNAL_TRANSFERS" REAL,
    "NET_MONTHLY_DEPOSITS" REAL,
    "TOTAL_ASSETS" REAL,
    "AVG_ANNUAL_MANAGEMENT_FEE" REAL,
    "AVG_DEPOSIT_FEE" REAL,
    "MONTHLY_YIELD" REAL,
    "YEAR_TO_DATE_YIELD" REAL,
    "YIELD_TRAILING_3_YRS" REAL,
    "YIELD_TRAILING_5_YRS" REAL,
    "AVG_ANNUAL_YIELD_TRAILING_3YRS" REAL,
    "AVG_ANNUAL_YIELD_TRAILING_5YRS" REAL,
    "STANDARD_DEVIATION" REAL,
    "ALPHA" REAL,
    "SHARPE_RATIO" REAL,
    "LIQUID_ASSETS_PERCENT" REAL,
    "STOCK_MARKET_EXPOSURE" REAL,
    "FOREIGN_EXPOSURE" REAL,
    "FOREIGN_CURRENCY_EXPOSURE" REAL,
    "MANAGING_CORPORATION_LEGAL_ID" REAL,
    "CURRENT_DATE" TEXT
);

-- ============================================================
-- Pensia (Pension Funds) / קרנות פנסיה
-- ============================================================
-- EN: Pensia (Pension Funds) - Israeli pension funds data with age-based
--     investment tracks. Raw table mirroring the Excel extract from pension-net system.
-- HE: פנסיה - קרנות פנסיה ישראליות עם מסלולי השקעה תלויי גיל.
--     טבלה גולמית המשקפת את קובץ האקסל ממערכת פנסיה-נט.
-- Source: Data Dictionary v3.2 | Record Count: ~500 funds
-- Excel columns: FUND_ID, FUND_NAME, PARENT_COMPANY_ID, PARENT_COMPANY_NAME,
--   FUND_CLASSIFICATION, CONTROLLING_CORPORATION, MANAGING_CORPORATION, REPORT_PERIOD,
--   INCEPTION_DATE, DEPOSITS, WITHDRAWLS, INTERNAL_TRANSFERS, NET_MONTHLY_DEPOSITS,
--   TOTAL_ASSETS, AVG_ANNUAL_MANAGEMENT_FEE, AVG_DEPOSIT_FEE, MONTHLY_YIELD,
--   YEAR_TO_DATE_YIELD, ACTUARIAL_ADJUSTMENT, YIELD_TRAILING_3_YRS, YIELD_TRAILING_5_YRS,
--   AVG_ANNUAL_YIELD_TRAILING_3YRS, AVG_ANNUAL_YIELD_TRAILING_5YRS, STANDARD_DEVIATION,
--   ALPHA, SHARPE_RATIO, LIQUID_ASSETS_PERCENT, STOCK_MARKET_EXPOSURE,
--   FOREIGN_EXPOSURE, FOREIGN_CURRENCY_EXPOSURE, MANAGING_CORPORATION_LEGAL_ID, CURRENT_DATE

CREATE TABLE IF NOT EXISTS "Pensia" (
    "FUND_ID" REAL,
    "FUND_NAME" TEXT,
    "PARENT_COMPANY_ID" REAL,
    "PARENT_COMPANY_NAME" TEXT,
    "FUND_CLASSIFICATION" TEXT,
    "CONTROLLING_CORPORATION" TEXT,
    "MANAGING_CORPORATION" TEXT,
    "MANAGING_CORPORATION_LEGAL_ID" REAL,
    "REPORT_PERIOD" REAL,
    "INCEPTION_DATE" TEXT,
    "DEPOSITS" REAL,
    "WITHDRAWLS" REAL,
    "INTERNAL_TRANSFERS" REAL,
    "NET_MONTHLY_DEPOSITS" REAL,
    "TOTAL_ASSETS" REAL,
    "AVG_ANNUAL_MANAGEMENT_FEE" REAL,
    "AVG_DEPOSIT_FEE" REAL,
    "MONTHLY_YIELD" REAL,
    "YEAR_TO_DATE_YIELD" REAL,
    "ACTUARIAL_ADJUSTMENT" REAL,
    "YIELD_TRAILING_3_YRS" REAL,
    "YIELD_TRAILING_5_YRS" REAL,
    "AVG_ANNUAL_YIELD_TRAILING_3YRS" REAL,
    "AVG_ANNUAL_YIELD_TRAILING_5YRS" REAL,
    "STANDARD_DEVIATION" REAL,
    "ALPHA" REAL,
    "SHARPE_RATIO" REAL,
    "LIQUID_ASSETS_PERCENT" REAL,
    "STOCK_MARKET_EXPOSURE" REAL,
    "FOREIGN_EXPOSURE" REAL,
    "FOREIGN_CURRENCY_EXPOSURE" REAL,
    "CURRENT_DATE" TEXT
);


-- =============================================================================
-- PART 3: FUND ASSET HOLDINGS TABLES (from fund_asset_db_schema.sql)
-- =============================================================================
-- These tables store detailed asset-level holdings loaded from regulatory
-- Excel reports via fund_asset_gui.py. 29 data tables covering all asset classes.
-- =============================================================================

-- ============================================================
-- Cash and Cash Equivalents / מזומנים ושווי מזומנים
-- ============================================================
CREATE TABLE IF NOT EXISTS cash_equivalents (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    bank_name TEXT,
    bank_id TEXT,
    bank_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    is_related_party INTEGER,
    bank_rating TEXT,
    rating_agency TEXT,
    currency_code TEXT,
    currency_value REAL,
    exchange_rate REAL,
    interest_rate REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, bank_id, currency_code, report_date)
);

CREATE INDEX IF NOT EXISTS idx_cash_equivalents_entity ON cash_equivalents(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_cash_equivalents_report ON cash_equivalents(report_date);

-- ============================================================
-- Government Bonds / איגרות חוב ממשלתיות
-- ============================================================
CREATE TABLE IF NOT EXISTS government_bonds (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    security_name TEXT,
    security_id TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    trading_venue TEXT,
    rating TEXT,
    rating_agency TEXT,
    currency_code TEXT,
    duration REAL,
    maturity_date TEXT,
    interest_rate REAL,
    yield_to_maturity REAL,
    amount_receivable REAL,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    accounting_method TEXT,
    pct_issued_par REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_government_bonds_entity ON government_bonds(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_government_bonds_security ON government_bonds(security_id);
CREATE INDEX IF NOT EXISTS idx_government_bonds_report ON government_bonds(report_date);

-- ============================================================
-- Commercial Papers / ניירות ערך מסחריים
-- ============================================================
CREATE TABLE IF NOT EXISTS commercial_papers (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    trading_venue TEXT,
    industry_sector TEXT,
    is_related_party INTEGER,
    rating TEXT,
    rating_agency TEXT,
    rating_target TEXT,
    currency_code TEXT,
    duration REAL,
    benchmark_rate TEXT,
    maturity_date TEXT,
    interest_rate REAL,
    yield_to_maturity REAL,
    subordination TEXT,
    is_troubled_debt INTEGER,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    amount_receivable REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    amortized_cost_curr REAL,
    accounting_method TEXT,
    pct_issued_par REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_commercial_papers_entity ON commercial_papers(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_commercial_papers_security ON commercial_papers(security_id);
CREATE INDEX IF NOT EXISTS idx_commercial_papers_report ON commercial_papers(report_date);

-- ============================================================
-- Corporate Bonds / איגרות חוב
-- ============================================================
CREATE TABLE IF NOT EXISTS corporate_bonds (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    tradability_status TEXT,
    trading_venue TEXT,
    industry_sector TEXT,
    is_related_party INTEGER,
    rating TEXT,
    rating_agency TEXT,
    rating_target TEXT,
    currency_code TEXT,
    duration REAL,
    maturity_date TEXT,
    interest_rate REAL,
    yield_to_maturity REAL,
    subordination TEXT,
    is_troubled_debt INTEGER,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    amount_receivable REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    amortized_cost_curr REAL,
    accounting_method TEXT,
    pct_issued_par REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_corporate_bonds_entity ON corporate_bonds(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_corporate_bonds_security ON corporate_bonds(security_id);
CREATE INDEX IF NOT EXISTS idx_corporate_bonds_report ON corporate_bonds(report_date);

-- ============================================================
-- Exchange-Traded Stocks / מניות מבכ ויהש
-- ============================================================
CREATE TABLE IF NOT EXISTS traded_stocks (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    tradability_status TEXT,
    trading_venue TEXT,
    industry_sector TEXT,
    is_related_party INTEGER,
    currency_code TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    amount_receivable REAL,
    fair_value REAL,
    pct_issued_par REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_traded_stocks_entity ON traded_stocks(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_traded_stocks_security ON traded_stocks(security_id);
CREATE INDEX IF NOT EXISTS idx_traded_stocks_report ON traded_stocks(report_date);

-- ============================================================
-- ETFs / קרנות סל
-- ============================================================
CREATE TABLE IF NOT EXISTS etfs (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    trading_venue TEXT,
    fund_classification TEXT,
    is_related_party INTEGER,
    currency_code TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    amount_receivable REAL,
    fair_value REAL,
    pct_issued_par REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_etfs_entity ON etfs(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_etfs_security ON etfs(security_id);
CREATE INDEX IF NOT EXISTS idx_etfs_report ON etfs(report_date);

-- ============================================================
-- Mutual Funds / קרנות נאמנות
-- ============================================================
CREATE TABLE IF NOT EXISTS mutual_funds (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    tradability_status TEXT,
    trading_venue TEXT,
    fund_classification TEXT,
    is_related_party INTEGER,
    currency_code TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    pct_issued_par REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_mutual_funds_entity ON mutual_funds(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_mutual_funds_security ON mutual_funds(security_id);
CREATE INDEX IF NOT EXISTS idx_mutual_funds_report ON mutual_funds(report_date);

-- ============================================================
-- Warrants / כתבי אופציה
-- ============================================================
CREATE TABLE IF NOT EXISTS warrants (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    market_type TEXT,
    exposure_country TEXT,
    tradability_status TEXT,
    trading_venue TEXT,
    underlying_asset_warrant TEXT,
    industry_sector TEXT,
    expiry_date TEXT,
    is_related_party INTEGER,
    currency_code TEXT,
    exercise_price REAL,
    conversion_ratio REAL,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_warrants_entity ON warrants(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_warrants_security ON warrants(security_id);
CREATE INDEX IF NOT EXISTS idx_warrants_report ON warrants(report_date);

-- ============================================================
-- Options / אופציות
-- ============================================================
CREATE TABLE IF NOT EXISTS options (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    trading_venue TEXT,
    industry_sector TEXT,
    underlying_asset TEXT,
    expiry_date TEXT,
    is_related_party INTEGER,
    currency_code TEXT,
    exercise_price REAL,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_options_entity ON options(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_options_security ON options(security_id);
CREATE INDEX IF NOT EXISTS idx_options_report ON options(report_date);

-- ============================================================
-- Futures Contracts / חוזים עתידיים
-- ============================================================
CREATE TABLE IF NOT EXISTS futures (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    market_type TEXT,
    exposure_country TEXT,
    trading_venue TEXT,
    underlying_asset TEXT,
    is_related_party INTEGER,
    currency_code TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_futures_entity ON futures(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_futures_security ON futures(security_id);
CREATE INDEX IF NOT EXISTS idx_futures_report ON futures(report_date);

-- ============================================================
-- Structured Products / מוצרים מובנים
-- ============================================================
CREATE TABLE IF NOT EXISTS structured_products (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    tradability_status TEXT,
    trading_venue TEXT,
    underlying_asset TEXT,
    is_related_party INTEGER,
    duration REAL,
    interest_rate REAL,
    yield_to_maturity REAL,
    rating TEXT,
    rating_agency TEXT,
    rating_target TEXT,
    currency_code TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_structured_products_entity ON structured_products(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_structured_products_security ON structured_products(security_id);
CREATE INDEX IF NOT EXISTS idx_structured_products_report ON structured_products(report_date);

-- ============================================================
-- Non-Tradable Government Bonds / לא סחיר איגרות חוב ממשלתיות
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_government_bonds (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    purchase_date TEXT,
    rating TEXT,
    rating_agency TEXT,
    currency_code TEXT,
    duration REAL,
    maturity_date TEXT,
    interest_rate REAL,
    yield_to_maturity REAL,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    accounting_method TEXT,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_government_bonds_entity ON nt_government_bonds(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_government_bonds_security ON nt_government_bonds(security_id);
CREATE INDEX IF NOT EXISTS idx_nt_government_bonds_report ON nt_government_bonds(report_date);

-- ============================================================
-- Non-Tradable Designated Bonds / לא סחיר איגרות חוב מיועדות
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_designated_bonds (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    primary_attribute TEXT,
    security_name TEXT,
    security_id TEXT,
    purchase_date TEXT,
    duration REAL,
    linkage_type TEXT,
    maturity_date TEXT,
    interest_rate REAL,
    yield_to_maturity REAL,
    par_value REAL,
    market_price REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    accounting_method TEXT,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_designated_bonds_entity ON nt_designated_bonds(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_designated_bonds_security ON nt_designated_bonds(security_id);
CREATE INDEX IF NOT EXISTS idx_nt_designated_bonds_report ON nt_designated_bonds(report_date);

-- ============================================================
-- Guaranteed Return Investment Channel / אפיק השקעה מובטח תשואה
-- ============================================================
CREATE TABLE IF NOT EXISTS guaranteed_return (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    fund_number TEXT,
    investment_track_id INTEGER,
    primary_attribute TEXT,
    layer_issuance_month TEXT,
    review_month TEXT,
    channel_asset_value REAL,
    total_portfolio_weight REAL,
    UNIQUE(fund_number, investment_track_id, primary_attribute, layer_issuance_month, report_date)
);

CREATE INDEX IF NOT EXISTS idx_guaranteed_return_fund ON guaranteed_return(fund_number, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_guaranteed_return_report ON guaranteed_return(report_date);

-- ============================================================
-- Non-Tradable Commercial Papers / לא סחיר ניירות ערך מסחריים
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_commercial_papers (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    industry_sector TEXT,
    is_related_party INTEGER,
    purchase_date TEXT,
    rating TEXT,
    rating_agency TEXT,
    rating_target TEXT,
    currency_code TEXT,
    duration REAL,
    linkage_type TEXT,
    benchmark_rate TEXT,
    maturity_date TEXT,
    interest_rate REAL,
    yield_to_maturity REAL,
    subordination TEXT,
    is_troubled_debt INTEGER,
    valuator_type TEXT,
    valuator_independence TEXT,
    valuator_name TEXT,
    last_valuation_date TEXT,
    last_impairment_date TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    amortized_cost_curr REAL,
    accounting_method TEXT,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_commercial_papers_entity ON nt_commercial_papers(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_commercial_papers_security ON nt_commercial_papers(security_id);
CREATE INDEX IF NOT EXISTS idx_nt_commercial_papers_report ON nt_commercial_papers(report_date);

-- ============================================================
-- Non-Tradable Corporate Bonds / לא סחיר איגרות חוב
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_corporate_bonds (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    tradability_status TEXT,
    industry_sector TEXT,
    is_related_party INTEGER,
    purchase_date TEXT,
    rating TEXT,
    rating_agency TEXT,
    rating_target TEXT,
    currency_code TEXT,
    duration REAL,
    maturity_date TEXT,
    yield_to_maturity REAL,
    interest_rate REAL,
    subordination TEXT,
    is_troubled_debt INTEGER,
    valuator_type TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    last_impairment_date TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    amortized_cost_curr REAL,
    accounting_method TEXT,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_corporate_bonds_entity ON nt_corporate_bonds(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_corporate_bonds_security ON nt_corporate_bonds(security_id);
CREATE INDEX IF NOT EXISTS idx_nt_corporate_bonds_report ON nt_corporate_bonds(report_date);

-- ============================================================
-- Non-Tradable Stocks / לא סחיר מניות מבכ ויהש
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_stocks (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    tradability_status TEXT,
    industry_sector TEXT,
    is_related_party INTEGER,
    purchase_date TEXT,
    currency_code TEXT,
    valuator_type TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    last_impairment_date TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_stocks_entity ON nt_stocks(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_stocks_security ON nt_stocks(security_id);
CREATE INDEX IF NOT EXISTS idx_nt_stocks_report ON nt_stocks(report_date);

-- ============================================================
-- Investment Funds / קרנות השקעה
-- ============================================================
CREATE TABLE IF NOT EXISTS investment_funds (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    gp_name TEXT,
    gp_id TEXT,
    gp_id_type TEXT,
    investment_fund_name TEXT,
    investment_fund_id TEXT,
    fund_inv_id_type TEXT,
    primary_attribute TEXT,
    fund_strategy TEXT,
    market_type TEXT,
    fund_incorporation_country TEXT,
    gp_office_location TEXT,
    exposure_country TEXT,
    is_related_party INTEGER,
    purchase_date TEXT,
    currency_code TEXT,
    valuator_type TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    exchange_rate REAL,
    nav_fund_currency REAL,
    fair_value REAL,
    fund_holding_pct REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, investment_fund_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_investment_funds_entity ON investment_funds(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_investment_funds_report ON investment_funds(report_date);

-- ============================================================
-- Non-Tradable Warrants / לא סחיר כתבי אופציה
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_warrants (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    market_type TEXT,
    exposure_country TEXT,
    tradability_status TEXT,
    underlying_asset_warrant TEXT,
    industry_sector TEXT,
    expiry_date TEXT,
    is_related_party INTEGER,
    purchase_date TEXT,
    currency_code TEXT,
    valuator_type TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    exercise_price REAL,
    conversion_ratio REAL,
    par_value REAL,
    market_price REAL,
    exchange_rate REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_warrants_entity ON nt_warrants(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_warrants_security ON nt_warrants(security_id);
CREATE INDEX IF NOT EXISTS idx_nt_warrants_report ON nt_warrants(report_date);

-- ============================================================
-- Non-Tradable Options / לא סחיר אופציות
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_options (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    industry_sector TEXT,
    underlying_asset TEXT,
    expiry_date TEXT,
    is_related_party INTEGER,
    purchase_date TEXT,
    currency_code TEXT,
    valuator_type TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    exercise_price REAL,
    conversion_ratio REAL,
    par_value REAL,
    market_price REAL,
    exchange_rate REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_options_entity ON nt_options(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_options_security ON nt_options(security_id);
CREATE INDEX IF NOT EXISTS idx_nt_options_report ON nt_options(report_date);

-- ============================================================
-- Non-Tradable Other Derivatives OTC / לא סחיר נגזרים אחרים
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_other_derivatives (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    primary_attribute TEXT,
    deal_number_leg1 TEXT,
    currency_leg1 TEXT,
    exchange_rate REAL,
    par_value_leg1 REAL,
    fair_value_leg1 REAL,
    asset_class_weight_leg1 REAL,
    total_weight_leg1 REAL,
    deal_number_leg2 TEXT,
    currency_leg2 TEXT,
    exchange_rate2 REAL,
    par_value_leg2 REAL,
    fair_value_leg2 REAL,
    asset_weight_leg2 REAL,
    total_weight_leg2 REAL,
    fair_value_net REAL,
    market_type TEXT,
    exposure_country TEXT,
    asset_type TEXT,
    leading_factor TEXT,
    additional_factor TEXT,
    ticker TEXT,
    is_related_party INTEGER,
    deal_date TEXT,
    contract_end_date TEXT,
    reset_frequency TEXT,
    clearing_type TEXT,
    csa TEXT,
    quoting_party TEXT,
    benchmark_rate TEXT,
    benchmark_period TEXT,
    benchmark_rate_value REAL,
    underlying_price_at_deal REAL,
    derivative_price_at_deal REAL,
    early_exit_penalty INTEGER,
    early_exit_penalty_rate REAL,
    counterparty TEXT,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, deal_number_leg1, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_other_derivatives_entity ON nt_other_derivatives(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_other_derivatives_report ON nt_other_derivatives(report_date);

-- ============================================================
-- Loans / הלוואות
-- ============================================================
CREATE TABLE IF NOT EXISTS loans (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    borrower_id TEXT,
    borrower_id_type TEXT,
    loan_name TEXT,
    loan_number TEXT,
    primary_attribute TEXT,
    real_estate_loan_attr TEXT,
    market_type TEXT,
    exposure_country TEXT,
    industry_sector TEXT,
    is_related_party INTEGER,
    consortium TEXT,
    consortium_number TEXT,
    loan_origination_date TEXT,
    rating TEXT,
    rating_agency TEXT,
    loan_rating_target TEXT,
    currency_code TEXT,
    duration REAL,
    rate_type TEXT,
    interest_rate REAL,
    linkage_type TEXT,
    benchmark_rate TEXT,
    spread REAL,
    yield_to_maturity REAL,
    maturity_date TEXT,
    subordination TEXT,
    collateral_type TEXT,
    collateral_value REAL,
    collateral_pct REAL,
    collateral_update_date TEXT,
    recourse TEXT,
    repayment_structure TEXT,
    loan_purpose TEXT,
    early_repayment TEXT,
    valuator_type TEXT,
    valuator_name TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    last_impairment_date TEXT,
    unused_credit_rate REAL,
    loan_par_value REAL,
    loan_price REAL,
    exchange_rate REAL,
    fair_value REAL,
    fair_value_curr REAL,
    amortized_cost_ils REAL,
    amortized_cost_curr REAL,
    is_troubled_debt INTEGER,
    accounting_method TEXT,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, loan_number, report_date)
);

CREATE INDEX IF NOT EXISTS idx_loans_entity ON loans(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_loans_report ON loans(report_date);

-- ============================================================
-- Non-Tradable Structured Products / לא סחיר מוצרים מובנים
-- ============================================================
CREATE TABLE IF NOT EXISTS nt_structured_products (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    is_related_party INTEGER,
    underlying_asset TEXT,
    purchase_date TEXT,
    rating TEXT,
    rating_agency TEXT,
    rating_target TEXT,
    currency_code TEXT,
    duration REAL,
    interest_rate REAL,
    yield_to_maturity REAL,
    valuator_type TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    par_value REAL,
    exchange_rate REAL,
    market_price REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_nt_structured_products_entity ON nt_structured_products(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_nt_structured_products_security ON nt_structured_products(security_id);
CREATE INDEX IF NOT EXISTS idx_nt_structured_products_report ON nt_structured_products(report_date);

-- ============================================================
-- Deposits Over 3 Months / פיקדונות מעל 3 חודשים
-- ============================================================
CREATE TABLE IF NOT EXISTS deposits_over_3m (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    bank_name TEXT,
    bank_id TEXT,
    bank_id_type TEXT,
    primary_attribute TEXT,
    deposit_expiry TEXT,
    market_type TEXT,
    exposure_country TEXT,
    is_related_party INTEGER,
    bank_rating TEXT,
    rating_agency TEXT,
    currency_code TEXT,
    duration REAL,
    interest_rate REAL,
    yield_to_maturity REAL,
    currency_value REAL,
    exchange_rate REAL,
    deposit_price REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, bank_id, currency_code, report_date)
);

CREATE INDEX IF NOT EXISTS idx_deposits_over_3m_entity ON deposits_over_3m(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_deposits_over_3m_report ON deposits_over_3m(report_date);

-- ============================================================
-- Real Estate Rights / זכויות מקרקעין
-- ============================================================
CREATE TABLE IF NOT EXISTS real_estate (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    property_name TEXT,
    primary_attribute TEXT,
    property_country TEXT,
    is_related_party INTEGER,
    purchase_date TEXT,
    property_use TEXT,
    property_lifecycle TEXT,
    property_address TEXT,
    quarterly_return REAL,
    valuation_method TEXT,
    valuator_type TEXT,
    valuator_name TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    currency_code TEXT,
    fair_value_curr REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    amortized_cost_curr REAL,
    accounting_method TEXT,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, property_name, report_date)
);

CREATE INDEX IF NOT EXISTS idx_real_estate_entity ON real_estate(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_real_estate_report ON real_estate(report_date);

-- ============================================================
-- Investment in Held Companies / השקעה בחברות מוחזקות
-- ============================================================
CREATE TABLE IF NOT EXISTS held_companies (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    issuer_name TEXT,
    issuer_id TEXT,
    issuer_id_type TEXT,
    security_name TEXT,
    security_id TEXT,
    security_id_type TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    industry_sector TEXT,
    is_related_party INTEGER,
    currency_code TEXT,
    valuator_type TEXT,
    valuator_independence TEXT,
    last_valuation_date TEXT,
    last_impairment_date TEXT,
    control_holding_pct REAL,
    balance_sheet_value REAL,
    fair_value REAL,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, security_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_held_companies_entity ON held_companies(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_held_companies_security ON held_companies(security_id);
CREATE INDEX IF NOT EXISTS idx_held_companies_report ON held_companies(report_date);

-- ============================================================
-- Other Assets / נכסים אחרים
-- ============================================================
CREATE TABLE IF NOT EXISTS other_assets (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    other_asset_name TEXT,
    other_asset_number TEXT,
    primary_attribute TEXT,
    market_type TEXT,
    exposure_country TEXT,
    is_related_party INTEGER,
    transaction_date TEXT,
    currency_code TEXT,
    last_valuation_date TEXT,
    currency_value REAL,
    exchange_rate REAL,
    fair_value REAL,
    amortized_cost_ils REAL,
    accounting_method TEXT,
    asset_class_weight REAL,
    total_portfolio_weight REAL,
    UNIQUE(entity_id, investment_track_id, other_asset_number, report_date)
);

CREATE INDEX IF NOT EXISTS idx_other_assets_entity ON other_assets(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_other_assets_report ON other_assets(report_date);

-- ============================================================
-- Credit Facilities / מסגרות אשראי
-- ============================================================
CREATE TABLE IF NOT EXISTS credit_facilities (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    borrower_id TEXT,
    borrower_id_type TEXT,
    loan_name TEXT,
    loan_number TEXT,
    credit_facility_date TEXT,
    market_type TEXT,
    exposure_country TEXT,
    is_related_party INTEGER,
    rating TEXT,
    rating_agency TEXT,
    loan_rating_target TEXT,
    currency_code TEXT,
    exchange_rate REAL,
    interest_rate REAL,
    rate_type TEXT,
    initial_credit_curr REAL,
    initial_credit_ils REAL,
    credit_balance_pct REAL,
    UNIQUE(entity_id, investment_track_id, loan_number, report_date)
);

CREATE INDEX IF NOT EXISTS idx_credit_facilities_entity ON credit_facilities(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_credit_facilities_report ON credit_facilities(report_date);

-- ============================================================
-- Investment Commitment Balances / יתרות התחייבות להשקעה
-- ============================================================
CREATE TABLE IF NOT EXISTS investment_commitments (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file TEXT,
    report_date TEXT NOT NULL,
    entity_id TEXT,
    investment_track_id INTEGER,
    primary_attribute TEXT,
    gp_name TEXT,
    gp_id TEXT,
    gp_id_type TEXT,
    investment_fund_name TEXT,
    investment_fund_id TEXT,
    fund_inv_id_type TEXT,
    currency_code TEXT,
    commitment_date TEXT,
    initial_commitment_curr REAL,
    initial_commitment_ils REAL,
    remaining_commitment_curr REAL,
    remaining_commitment_ils REAL,
    remaining_commitment_pct REAL,
    commitment_expiry_date TEXT,
    UNIQUE(entity_id, investment_track_id, investment_fund_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_investment_commitments_entity ON investment_commitments(entity_id, investment_track_id);
CREATE INDEX IF NOT EXISTS idx_investment_commitments_report ON investment_commitments(report_date);


-- =============================================================================
-- PART 4: POPULATE TABLE METADATA
-- =============================================================================

-- Fund Statistics tables
INSERT INTO _table_metadata VALUES ('Gemel', 'גמל', 'Gemel (Provident Funds) - Israeli savings and provident funds monthly statistics. Loaded from gemel-net Excel extracts.', 'גמל - קופות גמל וחיסכון ישראליות. נתונים סטטיסטיים חודשיים ממערכת גמל-נט.');
INSERT INTO _table_metadata VALUES ('Pensia', 'פנסיה', 'Pensia (Pension Funds) - Israeli pension funds monthly statistics with age-based investment tracks. Loaded from pension-net Excel extracts.', 'פנסיה - קרנות פנסיה ישראליות. נתונים סטטיסטיים חודשיים ממערכת פנסיה-נט.');

-- Fund Asset tables
INSERT INTO _table_metadata VALUES ('cash_equivalents', 'מזומנים ושווי מזומנים', 'Cash and cash equivalent holdings.', 'מזומנים ושווי מזומנים');
INSERT INTO _table_metadata VALUES ('government_bonds', 'איגרות חוב ממשלתיות', 'Government bond holdings.', 'איגרות חוב ממשלתיות');
INSERT INTO _table_metadata VALUES ('commercial_papers', 'ניירות ערך מסחריים', 'Commercial paper holdings.', 'ניירות ערך מסחריים');
INSERT INTO _table_metadata VALUES ('corporate_bonds', 'איגרות חוב', 'Corporate bond holdings.', 'איגרות חוב');
INSERT INTO _table_metadata VALUES ('traded_stocks', 'מניות מבכ ויהש', 'Exchange-traded equity holdings.', 'מניות מבכ ויהש');
INSERT INTO _table_metadata VALUES ('etfs', 'קרנות סל', 'ETF holdings.', 'קרנות סל');
INSERT INTO _table_metadata VALUES ('mutual_funds', 'קרנות נאמנות', 'Mutual fund holdings.', 'קרנות נאמנות');
INSERT INTO _table_metadata VALUES ('warrants', 'כתבי אופציה', 'Warrant holdings.', 'כתבי אופציה');
INSERT INTO _table_metadata VALUES ('options', 'אופציות', 'Option holdings.', 'אופציות');
INSERT INTO _table_metadata VALUES ('futures', 'חוזים עתידיים', 'Futures contract holdings.', 'חוזים עתידיים');
INSERT INTO _table_metadata VALUES ('structured_products', 'מוצרים מובנים', 'Structured product holdings.', 'מוצרים מובנים');
INSERT INTO _table_metadata VALUES ('nt_government_bonds', 'לא סחיר איגרות חוב ממשלתיות', 'Non-tradable government bonds.', 'לא סחיר איגרות חוב ממשלתיות');
INSERT INTO _table_metadata VALUES ('nt_designated_bonds', 'לא סחיר איגרות חוב מיועדות', 'Non-tradable designated bonds.', 'לא סחיר איגרות חוב מיועדות');
INSERT INTO _table_metadata VALUES ('guaranteed_return', 'אפיק השקעה מובטח תשואה', 'Guaranteed return investment channel.', 'אפיק השקעה מובטח תשואה');
INSERT INTO _table_metadata VALUES ('nt_commercial_papers', 'לא סחיר ניירות ערך מסחריים', 'Non-tradable commercial papers.', 'לא סחיר ניירות ערך מסחריים');
INSERT INTO _table_metadata VALUES ('nt_corporate_bonds', 'לא סחיר איגרות חוב', 'Non-tradable corporate bonds.', 'לא סחיר איגרות חוב');
INSERT INTO _table_metadata VALUES ('nt_stocks', 'לא סחיר מניות מבכ ויהש', 'Non-tradable stocks.', 'לא סחיר מניות מבכ ויהש');
INSERT INTO _table_metadata VALUES ('investment_funds', 'קרנות השקעה', 'Investment fund holdings.', 'קרנות השקעה');
INSERT INTO _table_metadata VALUES ('nt_warrants', 'לא סחיר כתבי אופציה', 'Non-tradable warrants.', 'לא סחיר כתבי אופציה');
INSERT INTO _table_metadata VALUES ('nt_options', 'לא סחיר אופציות', 'Non-tradable options.', 'לא סחיר אופציות');
INSERT INTO _table_metadata VALUES ('nt_other_derivatives', 'לא סחיר נגזרים אחרים', 'OTC derivatives.', 'לא סחיר נגזרים אחרים');
INSERT INTO _table_metadata VALUES ('loans', 'הלוואות', 'Loan holdings.', 'הלוואות');
INSERT INTO _table_metadata VALUES ('nt_structured_products', 'לא סחיר מוצרים מובנים', 'Non-tradable structured products.', 'לא סחיר מוצרים מובנים');
INSERT INTO _table_metadata VALUES ('deposits_over_3m', 'פיקדונות מעל 3 חודשים', 'Deposits over 3 months.', 'פיקדונות מעל 3 חודשים');
INSERT INTO _table_metadata VALUES ('real_estate', 'זכויות מקרקעין', 'Real estate rights.', 'זכויות מקרקעין');
INSERT INTO _table_metadata VALUES ('held_companies', 'השקעה בחברות מוחזקות', 'Investments in held companies.', 'השקעה בחברות מוחזקות');
INSERT INTO _table_metadata VALUES ('other_assets', 'נכסים אחרים', 'Other assets.', 'נכסים אחרים');
INSERT INTO _table_metadata VALUES ('credit_facilities', 'מסגרות אשראי', 'Credit facilities.', 'מסגרות אשראי');
INSERT INTO _table_metadata VALUES ('investment_commitments', 'יתרות התחייבות להשקעה', 'Investment commitment balances.', 'יתרות התחייבות להשקעה');


-- =============================================================================
-- PART 5: POPULATE COLUMN METADATA - Fund Statistics (Gemel)
-- =============================================================================

INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'FUND_ID', 'מספר קופה', 'Fund ID', 'Unique numeric identifier assigned by MoF to each provident fund.', 'מספר ייחודי שהוקצה על ידי משרד האוצר לכל קופת גמל.', 'Numeric', '1234567');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'FUND_NAME', 'שם קופה', 'Fund Name', 'Official marketing name of the provident fund.', 'שם שיווקי מלא של קופת הגמל.', 'Text', 'מיטב דש גמל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'FUND_CLASSIFICATION', 'סיווג קופה', 'Fund Classification', 'Regulatory classification defining the fund type.', 'סיווג רגולטורי המגדיר את סוג הקופה.', 'Categorical', 'גמל להשקעה, קג"מ');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'CONTROLLING_CORPORATION', 'תאגיד שולט', 'Controlling Corporation', 'Entity holding controlling interest in the fund.', 'תאגיד שולט בגוף המנהל.', 'Text', 'הראל השקעות');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'MANAGING_CORPORATION', 'חברה מנהלת', 'Managing Corporation', 'Company responsible for day-to-day fund management.', 'החברה האחראית על ניהול שוטף של הקופה.', 'Text', 'מיטב דש גמל ופנסיה בע"מ');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'REPORT_PERIOD', 'תקופת דיווח', 'Report Period', 'Month for which data is reported (YYYYMM).', 'תקופת הדיווח הספציפית (YYYYMM).', 'Numeric', '202312');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'INCEPTION_DATE', 'תאריך הקמה', 'Inception Date', 'Date when the fund was established.', 'התאריך בו הוקמה הקופה.', 'Date', '2008-01-01');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'TARGET_POPULATION', 'אוכלוסיית יעד', 'Target Population', 'Target demographic for the fund.', 'קהל יעד דמוגרפי לקופה.', 'Categorical', 'כלל האוכלוסייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'SPECIALIZATION', 'התמחות', 'Specialization', 'Fund specialization (e.g. general, bonds, stocks).', 'התמחות הקופה.', 'Categorical', 'כללי, אג"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'SUB_SPECIALIZATION', 'תת-התמחות', 'Sub-Specialization', 'Detailed fund sub-specialization.', 'תת-התמחות מפורטת של הקופה.', 'Categorical', 'אג"ח ממשלתי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'DEPOSITS', 'הפקדות', 'Deposits', 'Total new deposits in the month (NIS).', 'סך הפקדות חדשות בחודש.', 'Numeric', '1200000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'WITHDRAWLS', 'משיכות', 'Withdrawals', 'Total withdrawals in the month (NIS).', 'סך משיכות בחודש.', 'Numeric', '700000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'INTERNAL_TRANSFERS', 'העברות', 'Internal Transfers', 'Net transfers between funds (NIS).', 'העברות נטו בין קופות.', 'Numeric', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'NET_MONTHLY_DEPOSITS', 'צבירה נטו', 'Net Monthly Deposits', 'Net flow = Deposits - Withdrawals (NIS).', 'תזרים נטו = הפקדות פחות משיכות.', 'Numeric', '500000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'TOTAL_ASSETS', 'סך נכסים', 'Total Assets', 'Total market value of managed assets (NIS).', 'שווי שוק כולל של הנכסים המנוהלים.', 'Numeric', '5000000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'AVG_ANNUAL_MANAGEMENT_FEE', 'דמי ניהול ממוצעים מצבירה', 'Avg Annual Management Fee', 'Average annual management fee from balance (%).', 'דמי ניהול שנתיים ממוצעים מהצבירה.', 'Percentage', '0.52');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'AVG_DEPOSIT_FEE', 'דמי ניהול ממוצעים מהפקדה', 'Avg Deposit Fee', 'Average fee from monthly deposits (%).', 'עמלה ממוצעת מהפקדות חודשיות.', 'Percentage', '1.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'MONTHLY_YIELD', 'תשואה חודשית', 'Monthly Yield', 'Return earned in the current month (%).', 'תשואה שהושגה בחודש הנוכחי.', 'Percentage', '0.85');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'YEAR_TO_DATE_YIELD', 'תשואה מצטברת מתחילת השנה', 'Year to Date Yield', 'Accumulated return since January 1st (%).', 'תשואה מצטברת מ-1 בינואר.', 'Percentage', '4.2');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'YIELD_TRAILING_3_YRS', 'תשואה מצטברת 3 שנים', 'Yield Trailing 3 Years', 'Total return over the last 36 months (%).', 'תשואה כוללת ב-36 חודשים אחרונים.', 'Percentage', '18.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'YIELD_TRAILING_5_YRS', 'תשואה מצטברת 5 שנים', 'Yield Trailing 5 Years', 'Total return over the last 60 months (%).', 'תשואה כוללת ב-60 חודשים אחרונים.', 'Percentage', '32.1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'AVG_ANNUAL_YIELD_TRAILING_3YRS', 'תשואה שנתית ממוצעת 3 שנים', 'Avg Annual Yield 3 Years', 'Annualized return for last 3 years (%).', 'תשואה שנתית ממוצעת ל-3 שנים.', 'Percentage', '5.8');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'AVG_ANNUAL_YIELD_TRAILING_5YRS', 'תשואה שנתית ממוצעת 5 שנים', 'Avg Annual Yield 5 Years', 'Annualized return for last 5 years (%).', 'תשואה שנתית ממוצעת ל-5 שנים.', 'Percentage', '6.1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'STANDARD_DEVIATION', 'סטיית תקן', 'Standard Deviation', 'Historical volatility measure (%).', 'מדד לתנודתיות היסטורית.', 'Percentage', '3.8');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'ALPHA', 'אלפא', 'Alpha', 'Excess return relative to benchmark (%).', 'תשואה עודפת ביחס למדד.', 'Percentage', '1.2');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'SHARPE_RATIO', 'מדד שארפ', 'Sharpe Ratio', 'Risk-adjusted return ratio.', 'תשואה מתואמת סיכון.', 'Ratio', '0.92');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'LIQUID_ASSETS_PERCENT', 'נזילות', 'Liquid Assets %', 'Percentage of portfolio in liquid assets (%).', 'אחוז התיק בנכסים נזילים.', 'Percentage', '85.0');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'STOCK_MARKET_EXPOSURE', 'חשיפה למניות', 'Stock Market Exposure', 'Percentage invested in equities (%).', 'אחוז התיק המושקע במניות.', 'Percentage', '45.0');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'FOREIGN_EXPOSURE', 'חשיפה לחו"ל', 'Foreign Exposure', 'Percentage in non-domestic markets (%).', 'אחוז הנכסים בשווקים זרים.', 'Percentage', '30.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'FOREIGN_CURRENCY_EXPOSURE', 'חשיפה למט"ח', 'Foreign Currency Exposure', 'Assets exposed to FX fluctuations net of hedging (%).', 'חשיפה לתנודות מט"ח נטו מגידור.', 'Percentage', '18.2');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'MANAGING_CORPORATION_LEGAL_ID', 'מספר ח.פ חברה מנהלת', 'Managing Corp Legal ID', 'Legal entity identifier (H.P.) of managing company.', 'מספר ח.פ של הגוף המנהל.', 'Numeric', '510001234');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Gemel', 'CURRENT_DATE', 'תאריך שליפה', 'Current Date', 'Date when data was extracted from system.', 'התאריך בו הנתונים נשלפו מהמערכת.', 'Date', '2024-01-15');

-- =============================================================================
-- PART 6: POPULATE COLUMN METADATA - Fund Statistics (Pensia)
-- =============================================================================

INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'FUND_ID', 'מספר קרן', 'Fund ID', 'Unique numeric identifier assigned by MoF to each pension fund.', 'מספר ייחודי שהוקצה על ידי משרד האוצר לכל קרן פנסיה.', 'Numeric', '1234567');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'FUND_NAME', 'שם קרן', 'Fund Name', 'Official marketing name of the pension fund.', 'שם שיווקי מלא של קרן הפנסיה.', 'Text', 'הראל פנסיה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'PARENT_COMPANY_ID', 'מספר חברת אם', 'Parent Company ID', 'Identifier for the ultimate parent company owning the fund.', 'מזהה חברת האם הסופית המחזיקה בקרן.', 'Numeric', '510011223');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'PARENT_COMPANY_NAME', 'שם חברת אם', 'Parent Company Name', 'Legal name of the ultimate parent company.', 'השם המשפטי של חברת האם הסופית.', 'Text', 'מנורה מבטחים החזקות');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'FUND_CLASSIFICATION', 'סיווג קרן', 'Fund Classification', 'Regulatory classification defining asset allocation constraints.', 'סיווג רגולטורי המגדיר מגבלות הקצאת נכסים.', 'Categorical', 'פנסיה מקיפה חדשה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'CONTROLLING_CORPORATION', 'תאגיד שולט', 'Controlling Corporation', 'Entity holding controlling interest in the fund.', 'תאגיד שולט בגוף המנהל.', 'Text', 'קבוצת הראל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'MANAGING_CORPORATION', 'חברה מנהלת', 'Managing Corporation', 'Company responsible for day-to-day pension fund management.', 'החברה האחראית על ניהול שוטף של קרן הפנסיה.', 'Text', 'מנורה מבטחים פנסיה בע"מ');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'MANAGING_CORPORATION_LEGAL_ID', 'מספר ח.פ חברה מנהלת', 'Managing Corp Legal ID', 'Legal entity identifier (H.P.) of managing company.', 'מספר ח.פ של הגוף המנהל.', 'Numeric', '510001234');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'REPORT_PERIOD', 'תקופת דיווח', 'Report Period', 'Month for which data is reported (YYYYMM).', 'תקופת הדיווח (YYYYMM).', 'Numeric', '202312');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'INCEPTION_DATE', 'תאריך הקמה', 'Inception Date', 'Date when the pension fund was established.', 'התאריך בו הוקמה קרן הפנסיה.', 'Date', '1995-01-01');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'DEPOSITS', 'הפקדות', 'Deposits', 'Total deposits in the month including employer and employee contributions (NIS).', 'סך הפקדות בחודש כולל הפקדות מעסיק ועובד.', 'Numeric', '1200000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'WITHDRAWLS', 'משיכות', 'Withdrawals', 'Total funds withdrawn including pension payments and lump sums (NIS).', 'סך משיכות כולל תשלומי קצבה וסכומים חד-פעמיים.', 'Numeric', '700000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'INTERNAL_TRANSFERS', 'העברות', 'Internal Transfers', 'Net result of member transfers between age tracks (NIS).', 'תוצאה נטו של העברות עמיתים בין מסלולי גיל.', 'Numeric', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'NET_MONTHLY_DEPOSITS', 'צבירה נטו', 'Net Monthly Deposits', 'Net flow = Deposits - Withdrawals (NIS).', 'תזרים נטו = הפקדות פחות משיכות.', 'Numeric', '500000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'TOTAL_ASSETS', 'סך נכסים', 'Total Assets', 'Total market value of managed pension assets (NIS).', 'שווי שוק כולל של נכסי הפנסיה.', 'Numeric', '50000000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'AVG_ANNUAL_MANAGEMENT_FEE', 'דמי ניהול ממוצעים מצבירה', 'Avg Annual Management Fee', 'Average annual management fee from balance (%). Regulatory max 0.5%.', 'דמי ניהול שנתיים ממוצעים מהצבירה. מקסימום רגולטורי 0.5%.', 'Percentage', '0.52');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'AVG_DEPOSIT_FEE', 'דמי ניהול ממוצעים מהפקדה', 'Avg Deposit Fee', 'Average fee from monthly deposits (%). Regulatory max 4%.', 'עמלה ממוצעת מהפקדות חודשיות. מקסימום רגולטורי 4%.', 'Percentage', '1.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'MONTHLY_YIELD', 'תשואה חודשית', 'Monthly Yield', 'Return earned in the current month, net of fees (%).', 'תשואה בחודש הנוכחי, נטו מעמלות.', 'Percentage', '0.85');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'YEAR_TO_DATE_YIELD', 'תשואה מצטברת מתחילת השנה', 'Year to Date Yield', 'Accumulated return since January 1st (%).', 'תשואה מצטברת מ-1 בינואר.', 'Percentage', '4.2');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'ACTUARIAL_ADJUSTMENT', 'איזון אקטוארי', 'Actuarial Adjustment', 'Correction based on collective insurance balances. Only for pension funds with mutual guarantee (%).', 'התאמה המבוססת על יתרות ביטוח קולקטיביות. רלוונטי רק לקרנות עם ערבות הדדית.', 'Percentage', '0.15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'YIELD_TRAILING_3_YRS', 'תשואה מצטברת 3 שנים', 'Yield Trailing 3 Years', 'Total return over last 36 months (%).', 'תשואה כוללת ב-36 חודשים אחרונים.', 'Percentage', '18.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'YIELD_TRAILING_5_YRS', 'תשואה מצטברת 5 שנים', 'Yield Trailing 5 Years', 'Total return over last 60 months (%).', 'תשואה כוללת ב-60 חודשים אחרונים.', 'Percentage', '32.1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'AVG_ANNUAL_YIELD_TRAILING_3YRS', 'תשואה שנתית ממוצעת 3 שנים', 'Avg Annual Yield 3 Years', 'Annualized return for last 3 years (%).', 'תשואה שנתית ממוצעת ל-3 שנים.', 'Percentage', '5.8');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'AVG_ANNUAL_YIELD_TRAILING_5YRS', 'תשואה שנתית ממוצעת 5 שנים', 'Avg Annual Yield 5 Years', 'Annualized return for last 5 years (%).', 'תשואה שנתית ממוצעת ל-5 שנים.', 'Percentage', '6.1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'STANDARD_DEVIATION', 'סטיית תקן', 'Standard Deviation', 'Historical volatility measure (%).', 'מדד לתנודתיות היסטורית.', 'Percentage', '3.8');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'ALPHA', 'אלפא', 'Alpha', 'Excess return relative to benchmark (%).', 'תשואה עודפת ביחס למדד.', 'Percentage', '1.2');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'SHARPE_RATIO', 'מדד שארפ', 'Sharpe Ratio', 'Risk-adjusted return ratio.', 'תשואה מתואמת סיכון.', 'Ratio', '0.92');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'LIQUID_ASSETS_PERCENT', 'נזילות', 'Liquid Assets %', 'Percentage of portfolio in liquid assets (%).', 'אחוז התיק בנכסים נזילים.', 'Percentage', '85.0');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'STOCK_MARKET_EXPOSURE', 'חשיפה למניות', 'Stock Market Exposure', 'Percentage invested in equities (%).', 'אחוז התיק המושקע במניות.', 'Percentage', '45.0');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'FOREIGN_EXPOSURE', 'חשיפה לחו"ל', 'Foreign Exposure', 'Percentage in non-domestic markets (%).', 'אחוז הנכסים בשווקים זרים.', 'Percentage', '30.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'FOREIGN_CURRENCY_EXPOSURE', 'חשיפה למט"ח', 'Foreign Currency Exposure', 'Assets exposed to FX fluctuations net of hedging (%).', 'חשיפה לתנודות מט"ח נטו מגידור.', 'Percentage', '18.2');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('Pensia', 'CURRENT_DATE', 'תאריך שליפה', 'Current Date', 'Date when data was extracted from system.', 'התאריך בו הנתונים נשלפו מהמערכת.', 'Date', '2024-01-15');


-- =============================================================================
-- PART 7: POPULATE COLUMN METADATA - Fund Asset Tables
-- =============================================================================
-- (All INSERT statements from the original fund_asset_db_schema.sql)
-- =============================================================================

INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'bank_name', 'שם הבנק', 'Bank Name', 'Name of the bank holding the deposit.', 'שם הבנק בו מוחזק הפיקדון.', 'String', 'Bank Leumi');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'bank_id', 'מספר מזהה בנק', 'Bank ID', 'Official registration number of the bank.', 'מספר זיהוי רשמי של הבנק.', 'String', '520000054');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'bank_id_type', 'סוג מספר מזהה בנק', 'Bank ID Type', 'Category of the provided bank ID.', 'סיווג סוג המזהה של הבנק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'bank_rating', 'דירוג הבנק', 'Bank Rating', 'Credit rating assigned to the bank.', 'דירוג האשראי של הבנק.', 'String', 'Aa1, AA+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'currency_value', 'שווי מטבעי', 'Currency Value', 'Value in the original currency.', 'השווי במטבע המקורי.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('cash_equivalents', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');


-- =============================================================================
-- UTILITY VIEWS
-- =============================================================================

-- View: Summary of all tables and row counts (run after data is loaded)
-- SELECT name, (SELECT COUNT(*) FROM pragma_table_info(name)) as column_count
-- FROM sqlite_master WHERE type='table' AND name NOT LIKE '_%' ORDER BY name;

-- View: All column metadata for a specific table
-- SELECT * FROM _column_metadata WHERE table_name_en = 'Gemel' ORDER BY id;

-- View: All table descriptions
-- SELECT * FROM _table_metadata ORDER BY table_name_en;

-- View: Ingestion history
-- SELECT * FROM _ingestion_log ORDER BY timestamp DESC;

-- =============================================================================
-- NOTES ON COMBINING THE SCHEMAS
-- =============================================================================
-- 1. The _table_metadata, _column_metadata, and _ingestion_log tables are shared
--    infrastructure used by both the fund statistics and fund asset loading programs.
--
-- 2. The Gemel and Pensia tables retain their original column names and types exactly
--    as they appear in the source Excel files, preserving backward compatibility.
--
-- 3. All 29 asset tables retain their original structure with UNIQUE constraints,
--    indexes, and AUTOINCREMENT primary keys from fund_asset_db_schema.sql.
--
-- 4. The entity_id field in asset tables can be joined with FUND_ID in Gemel/Pensia
--    tables to link asset holdings to fund statistics.
--
-- 5. All _column_metadata INSERT statements from the original
--    fund_asset_db_schema.sql are included in PART 7 below.
-- =============================================================================
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'maturity_date', 'מועד פדיון', 'Maturity Date', 'Date when the instrument matures.', 'תאריך פירעון.', 'Date', '2030-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'amount_receivable', 'סכום לקבל (במטבע הפעילות)', 'Amount Receivable', 'Amount receivable in the activity currency.', 'סכום לקבל במטבע הפעילות.', 'Decimal', '100000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'pct_issued_par', 'שיעור מערך נקוב מונפק', '% of Issued Par Value', 'Percentage of total issued par value held.', 'שיעור מתוך סך הערך הנקוב שהונפק.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('government_bonds', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'rating_target', 'דירוג נייר הערך/המנפיק', 'Security/Issuer Rating', 'Whether the rating applies to the security or the issuer.', 'האם הדירוג הוא של נייר הערך או של המנפיק.', 'Categorical', 'נייר ערך, מנפיק');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'benchmark_rate', 'ריבית עוגן', 'Benchmark Rate', 'Reference benchmark interest rate.', 'ריבית העוגן (ריבית ייחוס).', 'String', 'SOFR, Prime');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'maturity_date', 'מועד פדיון', 'Maturity Date', 'Date when the instrument matures.', 'תאריך פירעון.', 'Date', '2030-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'subordination', 'נחיתות חוזית', 'Contractual Subordination', 'Whether the debt is contractually subordinated.', 'האם החוב נחות חוזית.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'is_troubled_debt', 'האם סווג כחוב בעייתי', 'Classified as Troubled Debt', 'Whether classified as troubled debt.', 'האם סווג כחוב בעייתי.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'amount_receivable', 'סכום לקבל (במטבע הפעילות)', 'Amount Receivable', 'Amount receivable in the activity currency.', 'סכום לקבל במטבע הפעילות.', 'Decimal', '100000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'fair_value', 'שווי הוגן (באלפי ש"ח)
שווי הוגן (בש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'amortized_cost_curr', 'עלות מופחתת (במטבע הפעילות)', 'Amortized Cost (Activity Currency)', 'Amortized cost in the activity currency.', 'עלות מופחתת במטבע הפעילות.', 'Decimal', '130000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'pct_issued_par', 'שיעור מערך נקוב מונפק', '% of Issued Par Value', 'Percentage of total issued par value held.', 'שיעור מתוך סך הערך הנקוב שהונפק.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('commercial_papers', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'tradability_status', 'סטאטוס סחירות', 'Tradability Status', 'Whether the instrument is tradable or non-tradable.', 'האם המכשיר סחיר או לא סחיר.', 'Categorical', 'סחיר, לא סחיר');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'rating_target', 'דירוג נייר הערך/המנפיק', 'Security/Issuer Rating', 'Whether the rating applies to the security or the issuer.', 'האם הדירוג הוא של נייר הערך או של המנפיק.', 'Categorical', 'נייר ערך, מנפיק');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'maturity_date', 'מועד פדיון', 'Maturity Date', 'Date when the instrument matures.', 'תאריך פירעון.', 'Date', '2030-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'subordination', 'נחיתות חוזית', 'Contractual Subordination', 'Whether the debt is contractually subordinated.', 'האם החוב נחות חוזית.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'is_troubled_debt', 'האם סווג כחוב בעייתי', 'Classified as Troubled Debt', 'Whether classified as troubled debt.', 'האם סווג כחוב בעייתי.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'amount_receivable', 'סכום לקבל (במטבע הפעילות)', 'Amount Receivable', 'Amount receivable in the activity currency.', 'סכום לקבל במטבע הפעילות.', 'Decimal', '100000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'amortized_cost_curr', 'עלות מופחתת (במטבע הפעילות)', 'Amortized Cost (Activity Currency)', 'Amortized cost in the activity currency.', 'עלות מופחתת במטבע הפעילות.', 'Decimal', '130000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'pct_issued_par', 'שיעור מערך נקוב מונפק', '% of Issued Par Value', 'Percentage of total issued par value held.', 'שיעור מתוך סך הערך הנקוב שהונפק.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('corporate_bonds', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'tradability_status', 'סטאטוס סחירות', 'Tradability Status', 'Whether the instrument is tradable or non-tradable.', 'האם המכשיר סחיר או לא סחיר.', 'Categorical', 'סחיר, לא סחיר');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'amount_receivable', 'סכום לקבל (במטבע הפעילות)', 'Amount Receivable', 'Amount receivable in the activity currency.', 'סכום לקבל במטבע הפעילות.', 'Decimal', '100000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'pct_issued_par', 'שיעור מערך נקוב מונפק', '% of Issued Par Value', 'Percentage of total issued par value held.', 'שיעור מתוך סך הערך הנקוב שהונפק.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('traded_stocks', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'fund_classification', 'סיווג הקרן', 'Fund Classification', 'Classification type of the fund.', 'סיווג הקרן.', 'Categorical', 'מנייתי, אג"חי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'amount_receivable', 'סכום לקבל (במטבע הפעילות)', 'Amount Receivable', 'Amount receivable in the activity currency.', 'סכום לקבל במטבע הפעילות.', 'Decimal', '100000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'pct_issued_par', 'שיעור מערך נקוב מונפק', '% of Issued Par Value', 'Percentage of total issued par value held.', 'שיעור מתוך סך הערך הנקוב שהונפק.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('etfs', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'tradability_status', 'סטאטוס סחירות', 'Tradability Status', 'Whether the instrument is tradable or non-tradable.', 'האם המכשיר סחיר או לא סחיר.', 'Categorical', 'סחיר, לא סחיר');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'fund_classification', 'סיווג הקרן', 'Fund Classification', 'Classification type of the fund.', 'סיווג הקרן.', 'Categorical', 'מנייתי, אג"חי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'pct_issued_par', 'שיעור מערך נקוב מונפק', '% of Issued Par Value', 'Percentage of total issued par value held.', 'שיעור מתוך סך הערך הנקוב שהונפק.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('mutual_funds', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'tradability_status', 'סטאטוס סחירות', 'Tradability Status', 'Whether the instrument is tradable or non-tradable.', 'האם המכשיר סחיר או לא סחיר.', 'Categorical', 'סחיר, לא סחיר');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'underlying_asset_warrant', 'נכס בסיס (כתב אופציה)', 'Underlying Asset (Warrant)', 'Underlying asset of the warrant.', 'נכס הבסיס של כתב האופציה.', 'String', 'מניית צ''ק פוינט');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'expiry_date', 'תאריך פקיעה', 'Expiry Date', 'Expiration date of the instrument.', 'תאריך פקיעה.', 'Date', '2026-12-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'exercise_price', 'שער מימוש', 'Exercise Price', 'Strike/exercise price.', 'מחיר המימוש.', 'Decimal', '150.00');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'conversion_ratio', 'יחס המרה', 'Conversion Ratio', 'Conversion ratio.', 'יחס ההמרה.', 'Decimal', '1.0');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('warrants', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'underlying_asset', 'נכס בסיס', 'Underlying Asset', 'Asset on which the derivative is based.', 'הנכס עליו מתבסס הנגזר.', 'String', 'Gold, TA-35');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'expiry_date', 'תאריך פקיעה', 'Expiry Date', 'Expiration date of the instrument.', 'תאריך פקיעה.', 'Date', '2026-12-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'exercise_price', 'שער מימוש', 'Exercise Price', 'Strike/exercise price.', 'מחיר המימוש.', 'Decimal', '150.00');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('options', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'underlying_asset', 'נכס בסיס', 'Underlying Asset', 'Asset on which the derivative is based.', 'הנכס עליו מתבסס הנגזר.', 'String', 'Gold, TA-35');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('futures', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'tradability_status', 'סטאטוס סחירות', 'Tradability Status', 'Whether the instrument is tradable or non-tradable.', 'האם המכשיר סחיר או לא סחיר.', 'Categorical', 'סחיר, לא סחיר');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'trading_venue', 'זירת מסחר', 'Trading Venue', 'The exchange or trading venue.', 'הבורסה או זירת המסחר.', 'String', 'TASE, CME');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'underlying_asset', 'נכס בסיס', 'Underlying Asset', 'Asset on which the derivative is based.', 'הנכס עליו מתבסס הנגזר.', 'String', 'Gold, TA-35');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'rating_target', 'דירוג נייר הערך/המנפיק', 'Security/Issuer Rating', 'Whether the rating applies to the security or the issuer.', 'האם הדירוג הוא של נייר הערך או של המנפיק.', 'Categorical', 'נייר ערך, מנפיק');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('structured_products', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'maturity_date', 'מועד פדיון', 'Maturity Date', 'Date when the instrument matures.', 'תאריך פירעון.', 'Date', '2030-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_government_bonds', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'linkage_type', 'סוג הצמדה', 'Linkage Type', 'Type of index linkage.', 'סוג ההצמדה.', 'Categorical', 'מדד, דולר, לא צמוד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'maturity_date', 'מועד פדיון', 'Maturity Date', 'Date when the instrument matures.', 'תאריך פירעון.', 'Date', '2030-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_designated_bonds', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('guaranteed_return', 'fund_number', 'מספר קרן', 'Fund Number', 'Fund identification number.', 'מספר מזהה הקרן.', 'String', '1234');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('guaranteed_return', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('guaranteed_return', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('guaranteed_return', 'layer_issuance_month', 'חודש הנפקת שכבה', 'Layer Issuance Month', 'Month when the guaranteed layer was issued.', 'חודש הנפקת השכבה.', 'Date', '2024-01');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('guaranteed_return', 'review_month', 'חודש הבדיקה', 'Review Month', 'Month of the review.', 'חודש הבדיקה.', 'Date', '2025-03');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('guaranteed_return', 'channel_asset_value', 'שווי הנכסים באפיק (באלפי ש"ח)', 'Asset Value in Channel (ILS thousands)', 'Asset value in the channel in ILS thousands.', 'שווי הנכסים באפיק באלפי שקלים.', 'Decimal', '50000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('guaranteed_return', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'rating_target', 'דירוג נייר הערך/המנפיק', 'Security/Issuer Rating', 'Whether the rating applies to the security or the issuer.', 'האם הדירוג הוא של נייר הערך או של המנפיק.', 'Categorical', 'נייר ערך, מנפיק');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'linkage_type', 'סוג הצמדה', 'Linkage Type', 'Type of index linkage.', 'סוג ההצמדה.', 'Categorical', 'מדד, דולר, לא צמוד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'benchmark_rate', 'ריבית עוגן', 'Benchmark Rate', 'Reference benchmark interest rate.', 'ריבית העוגן (ריבית ייחוס).', 'String', 'SOFR, Prime');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'maturity_date', 'מועד פדיון', 'Maturity Date', 'Date when the instrument matures.', 'תאריך פירעון.', 'Date', '2030-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'subordination', 'נחיתות חוזית', 'Contractual Subordination', 'Whether the debt is contractually subordinated.', 'האם החוב נחות חוזית.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'is_troubled_debt', 'האם סווג כחוב בעייתי', 'Classified as Troubled Debt', 'Whether classified as troubled debt.', 'האם סווג כחוב בעייתי.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'valuator_name', 'שם גורם משערך', 'Valuator Name', 'Name of the valuating entity.', 'שם הגורם המשערך.', 'String', 'Deloitte');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'last_impairment_date', 'תאריך אחרון בו נבחנה בפועל ירידת ערך', 'Last Impairment Review Date', 'Last date impairment was actually reviewed.', 'תאריך אחרון בו נבחנה ירידת ערך בפועל.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'amortized_cost_curr', 'עלות מופחתת (במטבע הפעילות)', 'Amortized Cost (Activity Currency)', 'Amortized cost in the activity currency.', 'עלות מופחתת במטבע הפעילות.', 'Decimal', '130000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_commercial_papers', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'tradability_status', 'סטאטוס סחירות', 'Tradability Status', 'Whether the instrument is tradable or non-tradable.', 'האם המכשיר סחיר או לא סחיר.', 'Categorical', 'סחיר, לא סחיר');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'rating_target', 'דירוג נייר הערך/המנפיק', 'Security/Issuer Rating', 'Whether the rating applies to the security or the issuer.', 'האם הדירוג הוא של נייר הערך או של המנפיק.', 'Categorical', 'נייר ערך, מנפיק');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'maturity_date', 'מועד פדיון', 'Maturity Date', 'Date when the instrument matures.', 'תאריך פירעון.', 'Date', '2030-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'subordination', 'נחיתות חוזית', 'Contractual Subordination', 'Whether the debt is contractually subordinated.', 'האם החוב נחות חוזית.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'is_troubled_debt', 'האם סווג כחוב בעייתי', 'Classified as Troubled Debt', 'Whether classified as troubled debt.', 'האם סווג כחוב בעייתי.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'last_impairment_date', 'תאריך אחרון בו נבחנה בפועל ירידת ערך', 'Last Impairment Review Date', 'Last date impairment was actually reviewed.', 'תאריך אחרון בו נבחנה ירידת ערך בפועל.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'amortized_cost_curr', 'עלות מופחתת (במטבע הפעילות)', 'Amortized Cost (Activity Currency)', 'Amortized cost in the activity currency.', 'עלות מופחתת במטבע הפעילות.', 'Decimal', '130000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_corporate_bonds', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'tradability_status', 'סטאטוס סחירות', 'Tradability Status', 'Whether the instrument is tradable or non-tradable.', 'האם המכשיר סחיר או לא סחיר.', 'Categorical', 'סחיר, לא סחיר');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'last_impairment_date', 'תאריך אחרון בו נבחנה בפועל ירידת ערך', 'Last Impairment Review Date', 'Last date impairment was actually reviewed.', 'תאריך אחרון בו נבחנה ירידת ערך בפועל.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_stocks', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'gp_name', 'שם שותף כללי קרן השקעות', 'General Partner Name', 'Name of the fund''s general partner.', 'שם השותף הכללי של קרן ההשקעות.', 'String', 'Viola Ventures');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'gp_id', 'מספר מזהה שותף כללי קרן השקעות', 'GP ID', 'Identifier of the general partner.', 'מספר מזהה השותף הכללי.', 'String', '520001111');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'gp_id_type', 'סוג מספר מזהה שותף כללי קרן השקעות', 'GP ID Type', 'Type of the GP identifier.', 'סוג המזהה של השותף הכללי.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'investment_fund_name', 'שם קרן השקעה', 'Investment Fund Name', 'Name of the investment fund.', 'שם קרן ההשקעה.', 'String', 'Viola Growth IV');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'investment_fund_id', 'מספר מזהה קרן השקעה', 'Investment Fund ID', 'Identifier of the investment fund.', 'מספר מזהה קרן ההשקעה.', 'String', '520002222');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'fund_inv_id_type', 'סוג מספר מזהה קרן השקעות', 'Investment Fund ID Type', 'Type of the fund identifier.', 'סוג המזהה של קרן ההשקעות.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'fund_strategy', 'אסטרטגיית קרן ההשקעה', 'Fund Strategy', 'Investment strategy of the fund.', 'אסטרטגיית ההשקעה של הקרן.', 'Categorical', 'VC, PE, Debt');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'fund_incorporation_country', 'מדינת התאגדות קרן השקעה', 'Fund Incorporation Country', 'Country where the fund is incorporated.', 'מדינת ההתאגדות של קרן ההשקעה.', 'String', 'Israel, Cayman');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'gp_office_location', 'מיקום משרד השותף הכללי', 'GP Office Location', 'Location of the general partner''s office.', 'מיקום משרד השותף הכללי.', 'String', 'Tel Aviv');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'nav_fund_currency', 'NAV (במטבע הדיווח של קרן ההשקעה)', 'NAV (Fund Reporting Currency)', 'Net asset value in the fund''s reporting currency.', 'שווי נכסי נקי במטבע הדיווח של הקרן.', 'Decimal', '50000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'fund_holding_pct', 'שיעור החזקה בקרן השקעה', '% Holding in Fund', 'Percentage holding in the investment fund.', 'שיעור ההחזקה בקרן ההשקעה.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_funds', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'tradability_status', 'סטאטוס סחירות', 'Tradability Status', 'Whether the instrument is tradable or non-tradable.', 'האם המכשיר סחיר או לא סחיר.', 'Categorical', 'סחיר, לא סחיר');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'underlying_asset_warrant', 'נכס בסיס (כתב אופציה)', 'Underlying Asset (Warrant)', 'Underlying asset of the warrant.', 'נכס הבסיס של כתב האופציה.', 'String', 'מניית צ''ק פוינט');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'expiry_date', 'תאריך פקיעה', 'Expiry Date', 'Expiration date of the instrument.', 'תאריך פקיעה.', 'Date', '2026-12-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'exercise_price', 'שער מימוש', 'Exercise Price', 'Strike/exercise price.', 'מחיר המימוש.', 'Decimal', '150.00');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'conversion_ratio', 'יחס המרה', 'Conversion Ratio', 'Conversion ratio.', 'יחס ההמרה.', 'Decimal', '1.0');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_warrants', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'underlying_asset', 'נכס בסיס', 'Underlying Asset', 'Asset on which the derivative is based.', 'הנכס עליו מתבסס הנגזר.', 'String', 'Gold, TA-35');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'expiry_date', 'תאריך פקיעה', 'Expiry Date', 'Expiration date of the instrument.', 'תאריך פקיעה.', 'Date', '2026-12-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'exercise_price', 'שער מימוש', 'Exercise Price', 'Strike/exercise price.', 'מחיר המימוש.', 'Decimal', '150.00');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'conversion_ratio', 'יחס המרה', 'Conversion Ratio', 'Conversion ratio.', 'יחס ההמרה.', 'Decimal', '1.0');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_options', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'deal_number_leg1', 'מספר עסקה (רגל 1)', 'Deal Number (Leg 1)', 'Transaction number for leg 1.', 'מספר העסקה לרגל 1.', 'String', 'DRV-001-L1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'currency_leg1', 'מטבע פעילות (רגל 1)', 'Currency (Leg 1)', 'Currency of leg 1.', 'מטבע רגל 1.', 'String', 'USD');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'exchange_rate', 'שער חליפין2', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'par_value_leg1', 'ערך נקוב (רגל 1)', 'Par Value (Leg 1)', 'Notional value of leg 1.', 'ערך נקוב רגל 1.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'fair_value_leg1', 'שווי הוגן במטבע הנסחר (רגל 1)', 'Fair Value in Currency (Leg 1)', 'Fair value of leg 1 in traded currency.', 'שווי הוגן רגל 1 במטבע הנסחר.', 'Decimal', '50000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'asset_class_weight_leg1', 'שיעור מנכסי אפיק ההשקעה (רגל 1)', '% of Asset Class (Leg 1)', 'Weight of leg 1 within asset class.', 'שיעור רגל 1 מנכסי האפיק.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'total_weight_leg1', 'שיעור מסך נכסי ההשקעה (רגל 1)', '% of Total Portfolio (Leg 1)', 'Weight of leg 1 in total portfolio.', 'שיעור רגל 1 מסך נכסי ההשקעה.', 'Percentage', '0.005');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'deal_number_leg2', 'מספר עסקה (רגל 2)', 'Deal Number (Leg 2)', 'Transaction number for leg 2.', 'מספר העסקה לרגל 2.', 'String', 'DRV-001-L2');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'currency_leg2', 'מטבע פעילות (רגל 2)', 'Currency (Leg 2)', 'Currency of leg 2.', 'מטבע רגל 2.', 'String', 'ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'exchange_rate2', 'שער חליפין2', 'Exchange Rate 2', 'Exchange rate for leg 2.', 'שער חליפין לרגל 2.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'par_value_leg2', 'ערך נקוב (רגל 2)', 'Par Value (Leg 2)', 'Notional value of leg 2.', 'ערך נקוב רגל 2.', 'Decimal', '3750000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'fair_value_leg2', 'שווי הוגן במטבע הנסחר (רגל 2)', 'Fair Value in Currency (Leg 2)', 'Fair value of leg 2.', 'שווי הוגן רגל 2 במטבע הנסחר.', 'Decimal', '45000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'asset_weight_leg2', 'שיעור מנכסי ההשקעה (רגל 2)', '% of Assets (Leg 2)', 'Weight of leg 2.', 'שיעור רגל 2 מנכסי ההשקעה.', 'Percentage', '0.018');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'total_weight_leg2', 'שיעור מסך אפיק ההשקעה (רגל 2)', '% of Channel (Leg 2)', 'Weight of leg 2 in channel.', 'שיעור רגל 2 מסך האפיק.', 'Percentage', '0.004');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'fair_value_net', 'שווי הוגן (נטו  באלפי ש"ח)', 'Fair Value Net (ILS thousands)', 'Net fair value in ILS thousands.', 'שווי הוגן נטו באלפי שקלים.', 'Decimal', '5000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'asset_type', 'סוג הנכס', 'Asset Type', 'Type of the underlying asset.', 'סוג הנכס.', 'Categorical', 'FX, IRS, CDS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'leading_factor', 'פקטור מוביל', 'Leading Factor', 'Primary risk factor.', 'פקטור הסיכון המוביל.', 'String', 'USD/ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'additional_factor', 'פקטור נוסף', 'Additional Factor', 'Secondary risk factor.', 'פקטור סיכון נוסף.', 'String', 'Prime');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'ticker', 'טיקר', 'Ticker', 'Ticker symbol.', 'סמל טיקר.', 'String', 'USDILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'deal_date', 'מועד ההתקשרות בעסקה', 'Deal Date', 'Date when the deal was entered.', 'מועד ההתקשרות בעסקה.', 'Date', '2024-06-01');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'contract_end_date', 'מועד סיום חוזי', 'Contract End Date', 'Contractual end date.', 'מועד סיום חוזי.', 'Date', '2026-06-01');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'reset_frequency', 'תדירות Reset', 'Reset Frequency', 'Frequency of rate reset.', 'תדירות איפוס הריבית.', 'Categorical', 'חודשי, רבעוני');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'clearing_type', 'סוג הסליקה', 'Clearing Type', 'Type of clearing.', 'סוג הסליקה.', 'Categorical', 'CCP, בילטרלי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'csa', 'נספח התחשבנות בטחונות - CSA', 'CSA', 'Credit Support Annex indicator.', 'נספח התחשבנות ביטחונות.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'quoting_party', 'גורם מצטט', 'Quoting Party', 'Entity providing the quote.', 'הגורם המצטט.', 'String', 'Bloomberg');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'benchmark_rate', 'ריבית עוגן', 'Benchmark Rate', 'Reference benchmark interest rate.', 'ריבית העוגן (ריבית ייחוס).', 'String', 'SOFR, Prime');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'benchmark_period', 'תקופת ריבית עוגן', 'Benchmark Period', 'Period of the benchmark rate.', 'תקופת ריבית העוגן.', 'String', '3M, 6M');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'benchmark_rate_value', 'שיעור ריבית עוגן', 'Benchmark Rate Value', 'Value of the benchmark rate.', 'שיעור ריבית העוגן.', 'Percentage', '0.053');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'underlying_price_at_deal', 'שער נכס הבסיס במועד ההתקשרות בעסקה', 'Underlying Price at Deal Date', 'Price of underlying at deal inception.', 'שער נכס הבסיס במועד ההתקשרות.', 'Decimal', '3.65');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'derivative_price_at_deal', 'שער הנגזר במועד ההתקשרות בעסקה', 'Derivative Price at Deal Date', 'Derivative price at deal inception.', 'שער הנגזר במועד ההתקשרות.', 'Decimal', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'early_exit_penalty', 'האם קיים קנס בגין יציאה מוקדמת', 'Early Exit Penalty Exists', 'Whether there is an early exit penalty.', 'האם קיים קנס ליציאה מוקדמת.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'early_exit_penalty_rate', 'שיעור הקנס בגין יציאה מוקדמת', 'Early Exit Penalty Rate', 'Rate of early exit penalty.', 'שיעור הקנס ליציאה מוקדמת.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'counterparty', 'צד נגדי - Counterparty', 'Counterparty', 'Name of the counterparty.', 'שם הצד הנגדי.', 'String', 'Bank Leumi');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_other_derivatives', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'borrower_id', 'מספר מזהה לווה', 'Borrower ID', 'Identifier of the borrower.', 'מספר מזהה הלווה.', 'String', '520003333');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'borrower_id_type', 'סוג מספר מזהה לווה', 'Borrower ID Type', 'Type of the borrower identifier.', 'סוג המזהה של הלווה.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'loan_name', 'שם הלוואה', 'Loan Name', 'Descriptive name of the loan.', 'שם ההלוואה.', 'String', 'הלוואה בכירה א');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'loan_number', 'מספר הלוואה', 'Loan Number', 'Unique loan identifier.', 'מספר מזהה ההלוואה.', 'String', 'LN-2024-001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'real_estate_loan_attr', 'מאפיין הלוואות מתואמות עבור זכויות מקרקעין', 'Real Estate Loan Attribute', 'Classification for real estate matched loans.', 'מאפיין הלוואות מתואמות לזכויות מקרקעין.', 'Categorical', 'מגורים, מסחרי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'consortium', 'קונסורציום/ סינדיקציה', 'Consortium/Syndication', 'Whether the loan is part of a consortium.', 'האם ההלוואה חלק מקונסורציום.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'consortium_number', 'מספר קונסורציום/ סינדיקציה', 'Consortium Number', 'Consortium identifier.', 'מספר הקונסורציום.', 'String', 'SYN-001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'loan_origination_date', 'תאריך העמדת הלוואה', 'Loan Origination Date', 'Date when the loan was originated.', 'תאריך העמדת ההלוואה.', 'Date', '2023-06-01');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'loan_rating_target', 'דירוג הלוואה/המנפיק', 'Loan/Issuer Rating', 'Whether rating applies to loan or issuer.', 'האם הדירוג של ההלוואה או המנפיק.', 'Categorical', 'הלוואה, מנפיק');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'rate_type', 'סוג הריבית', 'Rate Type', 'Fixed or variable rate.', 'סוג הריבית (קבועה/משתנה).', 'Categorical', 'קבועה, משתנה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'linkage_type', 'סוג הצמדה', 'Linkage Type', 'Type of index linkage.', 'סוג ההצמדה.', 'Categorical', 'מדד, דולר, לא צמוד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'benchmark_rate', 'ריבית עוגן', 'Benchmark Rate', 'Reference benchmark interest rate.', 'ריבית העוגן (ריבית ייחוס).', 'String', 'SOFR, Prime');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'spread', 'שיעור תוספת/הפחתה לריבית העוגן', 'Spread over Benchmark', 'Spread added or subtracted from benchmark.', 'תוספת או הפחתה מריבית העוגן.', 'Percentage', '0.015');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'maturity_date', 'מועד פדיון', 'Maturity Date', 'Date when the instrument matures.', 'תאריך פירעון.', 'Date', '2030-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'subordination', 'נחיתות חוזית', 'Contractual Subordination', 'Whether the debt is contractually subordinated.', 'האם החוב נחות חוזית.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'collateral_type', 'סוג בטוחה', 'Collateral Type', 'Type of collateral securing the loan.', 'סוג הבטוחה.', 'Categorical', 'נדל"ן, שעבוד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'collateral_value', 'שווי הבטוחות העומדות כנגד ההלוואה', 'Collateral Value', 'Value of collateral against the loan.', 'שווי הבטוחות כנגד ההלוואה.', 'Decimal', '2000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'collateral_pct', 'שיעור הבטוחות מהחוב', 'Collateral to Debt Ratio', 'Collateral as percentage of outstanding debt.', 'שיעור הבטוחות מהחוב.', 'Percentage', '1.20');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'collateral_update_date', 'מועד עדכון אחרון לשווי הבטוחות', 'Collateral Last Update', 'Last date collateral was revalued.', 'מועד עדכון אחרון לשווי הבטוחות.', 'Date', '2025-01-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'recourse', 'זכות חזרה', 'Recourse', 'Whether the loan has recourse.', 'האם קיימת זכות חזרה.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'repayment_structure', 'מבנה לוח סילוקין', 'Repayment Structure', 'Amortization schedule structure.', 'מבנה לוח הסילוקין.', 'Categorical', 'שפיצר, בלון');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'loan_purpose', 'יעוד הלוואה', 'Loan Purpose', 'Purpose of the loan.', 'ייעוד ההלוואה.', 'Categorical', 'רכישת נדל"ן');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'early_repayment', 'זכות פירעון מוקדם', 'Early Repayment Right', 'Whether early repayment is allowed.', 'האם קיימת זכות לפירעון מוקדם.', 'Categorical', 'כן, לא');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'valuator_name', 'שם גורם משערך', 'Valuator Name', 'Name of the valuating entity.', 'שם הגורם המשערך.', 'String', 'Deloitte');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'last_impairment_date', 'תאריך אחרון בו נבחנה בפועל ירידת ערך', 'Last Impairment Review Date', 'Last date impairment was actually reviewed.', 'תאריך אחרון בו נבחנה ירידת ערך בפועל.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'unused_credit_rate', 'שיעור ריבית בגין אי-ניצול מסגרת האשראי', 'Unused Credit Facility Rate', 'Rate charged on unused credit facility.', 'שיעור ריבית על אי-ניצול מסגרת.', 'Percentage', '0.005');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'loan_par_value', 'ערך נקוב', 'Par Value', 'Par value of the loan.', 'ערך נקוב של ההלוואה.', 'Decimal', '5000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'loan_price', 'שער הלוואה', 'Loan Price', 'Current price/rate of the loan.', 'שער ההלוואה.', 'Decimal', '98.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'fair_value_curr', 'שווי הוגן (במטבע הפעילות)', 'Fair Value (Activity Currency)', 'Fair value in activity currency.', 'שווי הוגן במטבע הפעילות.', 'Decimal', '4900000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'amortized_cost_curr', 'עלות מופחתת (במטבע הפעילות)', 'Amortized Cost (Activity Currency)', 'Amortized cost in the activity currency.', 'עלות מופחתת במטבע הפעילות.', 'Decimal', '130000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'is_troubled_debt', 'האם סווג כחוב בעייתי', 'Classified as Troubled Debt', 'Whether classified as troubled debt.', 'האם סווג כחוב בעייתי.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('loans', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'underlying_asset', 'נכס בסיס', 'Underlying Asset', 'Asset on which the derivative is based.', 'הנכס עליו מתבסס הנגזר.', 'String', 'Gold, TA-35');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'rating_target', 'דירוג נייר הערך/המנפיק', 'Security/Issuer Rating', 'Whether the rating applies to the security or the issuer.', 'האם הדירוג הוא של נייר הערך או של המנפיק.', 'Categorical', 'נייר ערך, מנפיק');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'par_value', 'ערך נקוב (יחידות)', 'Par Value (Units)', 'Face value or number of units held.', 'ערך נקוב או כמות יחידות.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'market_price', 'שער נייר הערך', 'Security Price', 'Current market price.', 'מחיר השוק.', 'Decimal', '102.5');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('nt_structured_products', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'bank_name', 'שם הבנק', 'Bank Name', 'Name of the bank holding the deposit.', 'שם הבנק בו מוחזק הפיקדון.', 'String', 'Bank Leumi');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'bank_id', 'מספר מזהה בנק', 'Bank ID', 'Official registration number of the bank.', 'מספר זיהוי רשמי של הבנק.', 'String', '520000054');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'bank_id_type', 'סוג מספר מזהה בנק', 'Bank ID Type', 'Category of the provided bank ID.', 'סיווג סוג המזהה של הבנק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'deposit_expiry', 'תאריך פקיעת פיקדון', 'Deposit Expiry Date', 'Date when the deposit expires.', 'תאריך פקיעת הפיקדון.', 'Date', '2025-09-30');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'bank_rating', 'דירוג הבנק', 'Bank Rating', 'Credit rating assigned to the bank.', 'דירוג האשראי של הבנק.', 'String', 'Aa1, AA+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'duration', 'מח"מ', 'Duration', 'Macaulay duration of the instrument.', 'מח"מ (משך חיים ממוצע).', 'Decimal', '5.3');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'yield_to_maturity', 'תשואה לפדיון', 'Yield to Maturity', 'Expected yield if held to maturity.', 'התשואה הצפויה עד הפדיון.', 'Percentage', '0.042');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'currency_value', 'שווי מטבעי', 'Currency Value', 'Value in the original currency.', 'השווי במטבע המקורי.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'deposit_price', 'שער פיקדון', 'Deposit Rate', 'Rate/price of the deposit.', 'שער הפיקדון.', 'Decimal', '100.0');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('deposits_over_3m', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'property_name', 'שם הנכס', 'Property Name', 'Name of the real estate property.', 'שם הנכס.', 'String', 'מגדל עזריאלי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'property_country', 'מדינת מיקום נדל"ן', 'Property Location Country', 'Country where the property is located.', 'מדינת מיקום הנדל"ן.', 'String', 'Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'purchase_date', 'תאריך רכישה', 'Purchase Date', 'Date when the instrument was acquired.', 'תאריך רכישת המכשיר.', 'Date', '2024-03-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'property_use', 'שימוש עיקרי בנכס', 'Primary Property Use', 'Main use of the property.', 'השימוש העיקרי בנכס.', 'Categorical', 'משרדים, מסחרי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'property_lifecycle', 'מחזור חיי הנכס', 'Property Lifecycle', 'Current lifecycle stage.', 'שלב מחזור החיים של הנכס.', 'Categorical', 'בנייה, תפעולי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'property_address', 'כתובת הנכס', 'Property Address', 'Address of the property.', 'כתובת הנכס.', 'String', 'דרך מנחם בגין 132');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'quarterly_return', 'שיעור תשואה בפועל במהלך הרבעון', 'Actual Quarterly Return', 'Actual return rate during the quarter.', 'שיעור התשואה בפועל ברבעון.', 'Percentage', '0.02');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'valuation_method', 'השיטה שבאמצעותה נקבע שווי הנכס', 'Property Valuation Method', 'Method used to determine property value.', 'השיטה לקביעת שווי הנכס.', 'Categorical', 'DCF, השוואתית');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'valuator_name', 'שם גורם משערך', 'Valuator Name', 'Name of the valuating entity.', 'שם הגורם המשערך.', 'String', 'Deloitte');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'fair_value_curr', 'שווי הוגן (במטבע הפעילות)', 'Fair Value (Activity Currency)', 'Fair value in activity currency.', 'שווי הוגן במטבע הפעילות.', 'Decimal', '4900000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'amortized_cost_curr', 'עלות מופחתת (במטבע הפעילות)', 'Amortized Cost (Activity Currency)', 'Amortized cost in the activity currency.', 'עלות מופחתת במטבע הפעילות.', 'Decimal', '130000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('real_estate', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'issuer_name', 'שם מנפיק', 'Issuer Name', 'Name of the entity that issued the instrument.', 'שם הגוף שהנפיק את המכשיר.', 'String', 'Israel Corp');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'issuer_id', 'מספר מנפיק', 'Issuer ID', 'Official registration number of the issuer.', 'מספר זיהוי רשמי של המנפיק.', 'String', '520000118');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'issuer_id_type', 'סוג מספר מזהה מנפיק', 'Issuer ID Type', 'Category of the provided issuer ID.', 'סיווג סוג המזהה של המנפיק.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'security_name', 'שם נייר ערך', 'Security Name', 'Descriptive name of the security.', 'שם נייר הערך.', 'String', 'גליל 1025');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'security_id', 'מספר נייר ערך', 'Security ID', 'Unique identifier (ISIN, Ticker, etc.).', 'קוד מזהה של נייר הערך.', 'String', 'IL0011301748');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'security_id_type', 'סוג מספר נייר ערך', 'Security ID Type', 'Standard used for the security identifier.', 'סוג הקוד המזהה.', 'Categorical', 'ISIN, Ticker');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'industry_sector', 'ענף מסחר', 'Industry Sector', 'Industry classification of the issuer.', 'ענף המסחר של המנפיק.', 'String', 'בנקאות, תעשייה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'valuator_type', 'סוג גורם משערך', 'Valuator Type', 'Type of valuation entity.', 'סוג הגורם המשערך.', 'Categorical', 'שמאי, רו"ח');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'valuator_independence', 'תלות/אי-תלות המשערך', 'Valuator Independence', 'Whether the valuator is independent.', 'האם המשערך בלתי תלוי.', 'Categorical', 'תלוי, בלתי תלוי');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'last_impairment_date', 'תאריך אחרון בו נבחנה בפועל ירידת ערך', 'Last Impairment Review Date', 'Last date impairment was actually reviewed.', 'תאריך אחרון בו נבחנה ירידת ערך בפועל.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'control_holding_pct', 'שיעור אחזקה באמצעי שליטה', 'Control Holding %', 'Holding percentage via control instruments.', 'שיעור החזקה באמצעי שליטה.', 'Percentage', '0.51');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'balance_sheet_value', 'שווי מאזני (באלפי ש"ח)', 'Balance Sheet Value (ILS thousands)', 'Balance sheet value in ILS thousands.', 'שווי מאזני באלפי שקלים.', 'Decimal', '100000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('held_companies', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'other_asset_name', 'שם הנכס האחר', 'Other Asset Name', 'Name of the other asset.', 'שם הנכס האחר.', 'String', 'זכויות נפט');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'other_asset_number', 'מספר הנכס האחר', 'Other Asset Number', 'Identifier of the other asset.', 'מספר מזהה הנכס.', 'String', 'OA-001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'transaction_date', 'תאריך עסקה', 'Transaction Date', 'Date of the transaction.', 'תאריך העסקה.', 'Date', '2024-06-15');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'last_valuation_date', 'תאריך שערוך אחרון', 'Last Valuation Date', 'Date of the most recent valuation.', 'תאריך השערוך האחרון.', 'Date', '2025-03-31');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'currency_value', 'שווי מטבעי', 'Currency Value', 'Value in the original currency.', 'השווי במטבע המקורי.', 'Decimal', '1000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'fair_value', 'שווי הוגן (באלפי ש"ח)', 'Fair Value (ILS thousands)', 'Market value in thousands of ILS.', 'שווי השוק באלפי שקלים.', 'Decimal', '150000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'amortized_cost_ils', 'עלות מופחתת (באלפי ש"ח)', 'Amortized Cost (ILS thousands)', 'Amortized cost in thousands of ILS.', 'עלות מופחתת באלפי שקלים.', 'Decimal', '980000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'accounting_method', 'השיטה שיושמה בדוח הכספי', 'Accounting Method', 'Accounting method applied in financial statements.', 'השיטה החשבונאית שיושמה בדוח הכספי.', 'Categorical', 'שווי הוגן, עלות מופחתת');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'asset_class_weight', 'שיעור מנכסי אפיק ההשקעה', '% of Asset Class', 'Weight within the specific asset class.', 'שיעור מתוך סך נכסי האפיק.', 'Percentage', '0.05');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('other_assets', 'total_portfolio_weight', 'שיעור מסך נכסי ההשקעה', '% of Total Portfolio', 'Weight within the total portfolio.', 'שיעור מתוך סך נכסי ההשקעה.', 'Percentage', '0.001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'borrower_id', 'מספר מזהה לווה', 'Borrower ID', 'Identifier of the borrower.', 'מספר מזהה הלווה.', 'String', '520003333');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'borrower_id_type', 'סוג מספר מזהה לווה', 'Borrower ID Type', 'Type of the borrower identifier.', 'סוג המזהה של הלווה.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'loan_name', 'שם הלוואה', 'Loan Name', 'Descriptive name of the loan.', 'שם ההלוואה.', 'String', 'הלוואה בכירה א');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'loan_number', 'מספר הלוואה', 'Loan Number', 'Unique loan identifier.', 'מספר מזהה ההלוואה.', 'String', 'LN-2024-001');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'credit_facility_date', 'תאריך העמדת מסגרת אשראי', 'Credit Facility Date', 'Date when credit facility was established.', 'תאריך העמדת מסגרת האשראי.', 'Date', '2023-01-01');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'market_type', 'ישראל/חו"ל', 'Market Type', 'Indication if the asset is local or foreign.', 'ציון אם הנכס בארץ או בחו"ל.', 'Categorical', 'ישראל, חו"ל');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'exposure_country', 'מדינה לפי חשיפה כלכלית', 'Country of Exposure', 'Country of economic risk exposure.', 'המדינה אליה קיימת חשיפה כלכלית.', 'String', 'USA, Israel');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'is_related_party', 'בעל עניין/צד קשור', 'Related Party', 'Indicates if the counterparty is a related party.', 'האם הצד הנגדי הוא צד קשור.', 'Boolean', '0, 1');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'rating', 'דירוג', 'Rating', 'Credit rating of the instrument.', 'דירוג האשראי.', 'String', 'Aa1, A+');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'rating_agency', 'שם מדרג', 'Rating Agency', 'Name of the credit rating agency.', 'שם סוכנות הדירוג.', 'String', 'Moody''s, S&P');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'loan_rating_target', 'דירוג הלוואה/המנפיק', 'Loan/Issuer Rating', 'Whether rating applies to loan or issuer.', 'האם הדירוג של ההלוואה או המנפיק.', 'Categorical', 'הלוואה, מנפיק');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'exchange_rate', 'שער חליפין', 'Exchange Rate', 'Conversion rate to ILS.', 'שער המרה לשקלים.', 'Decimal', '3.75');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'interest_rate', 'שיעור ריבית', 'Interest Rate', 'Annual interest or coupon rate.', 'שיעור הריבית השנתית.', 'Percentage', '0.045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'rate_type', 'סוג הריבית', 'Rate Type', 'Fixed or variable rate.', 'סוג הריבית (קבועה/משתנה).', 'Categorical', 'קבועה, משתנה');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'initial_credit_curr', 'סכום מסגרת האשראי הראשוני (במטבע הפעילות)', 'Initial Credit Amount (Activity Currency)', 'Initial credit facility amount in activity currency.', 'סכום מסגרת האשראי הראשונית במטבע הפעילות.', 'Decimal', '10000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'initial_credit_ils', 'סכום מסגרת האשראי הראשוני (באלפי ש"ח)', 'Initial Credit Amount (ILS thousands)', 'Initial credit amount in ILS thousands.', 'סכום מסגרת האשראי הראשונית באלפי שקלים.', 'Decimal', '37500');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('credit_facilities', 'credit_balance_pct', 'שיעור יתרת מסגרת אשראי', 'Credit Balance %', 'Remaining credit facility percentage.', 'שיעור יתרת מסגרת האשראי.', 'Percentage', '0.60');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'entity_id', 'מספר קופה/קרן/ח.פ. עבור חברת ביטוח', 'Fund/Entity ID', 'Unique identifier of the reporting fund or entity.', 'מזהה ייחודי של הקופה או הגוף המדווח.', 'String', '512345678');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'investment_track_id', 'מספר מסלול', 'Investment Track ID', 'The specific investment track or sub-fund number.', 'מספר המזהה את מסלול ההשקעה הספציפי.', 'Numeric', '101, 2045');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'primary_attribute', 'מאפיין עיקרי', 'Primary Attribute', 'Main classification characteristic of the holding.', 'מאפיין הסיווג העיקרי של ההחזקה.', 'Categorical', 'שקלי, צמוד מדד');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'gp_name', 'שם שותף כללי קרן השקעות', 'General Partner Name', 'Name of the fund''s general partner.', 'שם השותף הכללי של קרן ההשקעות.', 'String', 'Viola Ventures');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'gp_id', 'מספר מזהה שותף כללי קרן השקעות', 'GP ID', 'Identifier of the general partner.', 'מספר מזהה השותף הכללי.', 'String', '520001111');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'gp_id_type', 'סוג מספר מזהה שותף כללי קרן השקעות', 'GP ID Type', 'Type of the GP identifier.', 'סוג המזהה של השותף הכללי.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'investment_fund_name', 'שם קרן השקעה', 'Investment Fund Name', 'Name of the investment fund.', 'שם קרן ההשקעה.', 'String', 'Viola Growth IV');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'investment_fund_id', 'מספר מזהה קרן השקעה', 'Investment Fund ID', 'Identifier of the investment fund.', 'מספר מזהה קרן ההשקעה.', 'String', '520002222');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'fund_inv_id_type', 'סוג מספר מזהה קרן השקעות', 'Investment Fund ID Type', 'Type of the fund identifier.', 'סוג המזהה של קרן ההשקעות.', 'Categorical', 'ח.פ, LEI');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'currency_code', 'מטבע פעילות', 'Currency', 'Currency in which the instrument is denominated.', 'המטבע בו נקוב המכשיר.', 'String', 'USD, ILS');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'commitment_date', 'תאריך העמדת התחייבות לקרן השקעה', 'Commitment Date', 'Date when commitment to the fund was made.', 'תאריך העמדת ההתחייבות לקרן.', 'Date', '2022-01-01');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'initial_commitment_curr', 'סכום המחויבות הראשוני (במטבע הדיווח של קרן ההשקעה)', 'Initial Commitment (Fund Currency)', 'Initial commitment in fund reporting currency.', 'סכום המחויבות הראשוני במטבע הדיווח של הקרן.', 'Decimal', '5000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'initial_commitment_ils', 'סכום המחויבות הראשוני (באלפי ש"ח)', 'Initial Commitment (ILS thousands)', 'Initial commitment in ILS thousands.', 'סכום המחויבות הראשוני באלפי שקלים.', 'Decimal', '18750');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'remaining_commitment_curr', 'יתרת המחויבות לתקופת הדיווח (במטבע הדיווח של קרן ההשקעה)', 'Remaining Commitment (Fund Currency)', 'Remaining commitment for the reporting period.', 'יתרת המחויבות לתקופת הדיווח במטבע הקרן.', 'Decimal', '2000000');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'remaining_commitment_ils', 'יתרת המחויבות לתקופת הדיווח (באלפי ש"ח)', 'Remaining Commitment (ILS thousands)', 'Remaining commitment in ILS thousands.', 'יתרת המחויבות באלפי שקלים.', 'Decimal', '7500');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'remaining_commitment_pct', 'שיעור יתרת המחויבות', 'Remaining Commitment %', 'Percentage of remaining commitment.', 'שיעור יתרת המחויבות.', 'Percentage', '0.40');
INSERT INTO _column_metadata (table_name_en, column_name_en, column_name_he, english_term, description_en, description_he, data_type, examples) VALUES ('investment_commitments', 'commitment_expiry_date', 'תאריך פקיעת מחויבות להשקעה', 'Commitment Expiry Date', 'Date when the investment commitment expires.', 'תאריך פקיעת המחויבות להשקעה.', 'Date', '2030-12-31');
