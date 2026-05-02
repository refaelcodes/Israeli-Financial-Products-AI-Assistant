/**
 * API Service Layer
 * Connects React frontend to Flask backend (fund_ai_app.py)
 * Flask runs on port 5000, Vite proxies /api/* to it
 */

const API_BASE = "/api";

async function apiFetch(url, options = {}) {
  const res = await fetch(`${API_BASE}${url}`, {
    headers: { "Content-Type": "application/json", ...options.headers },
    ...options,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: res.statusText }));
    throw new Error(err.error || `API error ${res.status}`);
  }
  return res.json();
}

// ─── Direct SQL query ───────────────────────────────────────
export async function querySQL(sql) {
  return apiFetch("/query", {
    method: "POST",
    body: JSON.stringify({ sql }),
  });
}

// ─── AI-powered question → SQL → results ────────────────────
export async function askQuestion(question, history = []) {
  return apiFetch("/ask", {
    method: "POST",
    body: JSON.stringify({ question, history }),
  });
}

// ─── Database stats ─────────────────────────────────────────
export async function getStats() {
  return apiFetch("/stats");
}

// ─── Schema info ────────────────────────────────────────────
export async function getSchema() {
  return apiFetch("/schema");
}

// ─── Health check ───────────────────────────────────────────
export async function getHealth() {
  return apiFetch("/health");
}

// ─── Convenience: Funds ─────────────────────────────────────
export async function getPensiaFunds(limit = 500) {
  return querySQL(`
    SELECT FUND_ID, FUND_NAME, FUND_CLASSIFICATION,
           CONTROLLING_CORPORATION, MANAGING_CORPORATION,
           REPORT_PERIOD, INCEPTION_DATE, TOTAL_ASSETS,
           DEPOSITS, WITHDRAWLS, NET_MONTHLY_DEPOSITS,
           AVG_ANNUAL_MANAGEMENT_FEE, AVG_DEPOSIT_FEE,
           MONTHLY_YIELD, YEAR_TO_DATE_YIELD,
           AVG_ANNUAL_YIELD_TRAILING_3YRS, AVG_ANNUAL_YIELD_TRAILING_5YRS,
           STANDARD_DEVIATION, ALPHA, SHARPE_RATIO,
           LIQUID_ASSETS_PERCENT, STOCK_MARKET_EXPOSURE,
           FOREIGN_EXPOSURE, FOREIGN_CURRENCY_EXPOSURE
    FROM "Pensia"
    WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Pensia")
    ORDER BY TOTAL_ASSETS DESC
    LIMIT ${limit}
  `);
}

export async function getGemelFunds(limit = 500) {
  return querySQL(`
    SELECT FUND_ID, FUND_NAME, FUND_CLASSIFICATION,
           CONTROLLING_CORPORATION, MANAGING_CORPORATION,
           REPORT_PERIOD, INCEPTION_DATE, TARGET_POPULATION,
           SPECIALIZATION, TOTAL_ASSETS,
           DEPOSITS, WITHDRAWLS, NET_MONTHLY_DEPOSITS,
           AVG_ANNUAL_MANAGEMENT_FEE, AVG_DEPOSIT_FEE,
           MONTHLY_YIELD, YEAR_TO_DATE_YIELD,
           AVG_ANNUAL_YIELD_TRAILING_3YRS, AVG_ANNUAL_YIELD_TRAILING_5YRS,
           STANDARD_DEVIATION, ALPHA, SHARPE_RATIO,
           LIQUID_ASSETS_PERCENT, STOCK_MARKET_EXPOSURE,
           FOREIGN_EXPOSURE, FOREIGN_CURRENCY_EXPOSURE
    FROM "Gemel"
    WHERE REPORT_PERIOD = (SELECT MAX(REPORT_PERIOD) FROM "Gemel")
    ORDER BY TOTAL_ASSETS DESC
    LIMIT ${limit}
  `);
}

// ─── Convenience: Holdings / Assets ─────────────────────────
export async function getTradedStocks(limit = 500) {
  return querySQL(`
    SELECT row_id, entity_id, security_name, security_id,
           issuer_name, market_type, exposure_country,
           trading_venue, industry_sector, currency_code,
           par_value, market_price, fair_value,
           asset_class_weight, total_portfolio_weight, report_date
    FROM traded_stocks
    ORDER BY fair_value DESC
    LIMIT ${limit}
  `);
}

export async function getGovernmentBonds(limit = 500) {
  return querySQL(`
    SELECT row_id, entity_id, security_name, security_id,
           market_type, primary_attribute, rating, rating_agency,
           currency_code, duration, maturity_date,
           interest_rate, yield_to_maturity, fair_value,
           asset_class_weight, total_portfolio_weight, report_date
    FROM government_bonds
    ORDER BY fair_value DESC
    LIMIT ${limit}
  `);
}

export async function getCorporateBonds(limit = 500) {
  return querySQL(`
    SELECT row_id, entity_id, security_name, security_id,
           issuer_name, market_type, industry_sector,
           rating, rating_agency, currency_code,
           duration, maturity_date, interest_rate,
           yield_to_maturity, fair_value,
           asset_class_weight, total_portfolio_weight, report_date
    FROM corporate_bonds
    ORDER BY fair_value DESC
    LIMIT ${limit}
  `);
}

export async function getETFs(limit = 500) {
  return querySQL(`
    SELECT row_id, entity_id, security_name, security_id,
           market_type, exposure_country, trading_venue,
           fund_classification, currency_code,
           market_price, fair_value,
           asset_class_weight, total_portfolio_weight, report_date
    FROM etfs
    ORDER BY fair_value DESC
    LIMIT ${limit}
  `);
}

export async function getAllHoldings(limit = 500) {
  return querySQL(`
    SELECT 'Stocks' as asset_class, row_id, entity_id,
           security_name, security_id, issuer_name,
           market_type, exposure_country, currency_code,
           fair_value, asset_class_weight, total_portfolio_weight, report_date
    FROM traded_stocks
    UNION ALL
    SELECT 'Gov Bonds', row_id, entity_id,
           security_name, security_id, NULL,
           market_type, NULL, currency_code,
           fair_value, asset_class_weight, total_portfolio_weight, report_date
    FROM government_bonds
    UNION ALL
    SELECT 'Corp Bonds', row_id, entity_id,
           security_name, security_id, issuer_name,
           market_type, NULL, currency_code,
           fair_value, asset_class_weight, total_portfolio_weight, report_date
    FROM corporate_bonds
    UNION ALL
    SELECT 'ETFs', row_id, entity_id,
           security_name, security_id, NULL,
           market_type, exposure_country, currency_code,
           fair_value, asset_class_weight, total_portfolio_weight, report_date
    FROM etfs
    ORDER BY fair_value DESC
    LIMIT ${limit}
  `);
}

// ─── Convenience: Ingestion Log ─────────────────────────────
export async function getIngestionLog() {
  return querySQL(`
    SELECT * FROM _ingestion_log ORDER BY rowid DESC LIMIT 100
  `);
}

// ─── Convenience: DB metadata ───────────────────────────────
export async function getTableMetadata() {
  return querySQL(`SELECT * FROM _table_metadata ORDER BY table_name`);
}

export async function getColumnMetadata() {
  return querySQL(`SELECT * FROM _column_metadata ORDER BY table_name, column_name`);
}
