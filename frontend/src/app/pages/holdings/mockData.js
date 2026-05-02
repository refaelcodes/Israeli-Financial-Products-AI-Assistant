// Mock data mirroring real fund_combined_db asset tables
// All fair_value in thousands ILS, matching real schema

export const tradedStocksData = [
  { row_id: 1, entity_id: "1011", security_name: "בנק לאומי לישראל", security_id: "IL0011284465", issuer_name: "בנק לאומי", market_type: "ישראל", exposure_country: "Israel", trading_venue: "TASE", industry_sector: "בנקאות", currency_code: "ILS", par_value: 850000, market_price: 28.82, fair_value: 24500, asset_class_weight: 5.2, total_portfolio_weight: 3.2, report_date: "2025-01" },
  { row_id: 2, entity_id: "1011", security_name: "בנק הפועלים", security_id: "IL0006625771", issuer_name: "בנק הפועלים", market_type: "ישראל", exposure_country: "Israel", trading_venue: "TASE", industry_sector: "בנקאות", currency_code: "ILS", par_value: 620000, market_price: 31.94, fair_value: 19800, asset_class_weight: 4.2, total_portfolio_weight: 2.6, report_date: "2025-01" },
  { row_id: 3, entity_id: "1013", security_name: "Apple Inc", security_id: "US0378331005", issuer_name: "Apple Inc", market_type: "חו\"ל", exposure_country: "USA", trading_venue: "NASDAQ", industry_sector: "טכנולוגיה", currency_code: "USD", par_value: 14500, market_price: 220.69, fair_value: 32000, asset_class_weight: 6.8, total_portfolio_weight: 4.2, report_date: "2025-01" },
  { row_id: 4, entity_id: "1013", security_name: "Microsoft Corp", security_id: "US5949181045", issuer_name: "Microsoft", market_type: "חו\"ל", exposure_country: "USA", trading_venue: "NASDAQ", industry_sector: "טכנולוגיה", currency_code: "USD", par_value: 6800, market_price: 411.76, fair_value: 28000, asset_class_weight: 5.9, total_portfolio_weight: 3.7, report_date: "2025-01" },
  { row_id: 5, entity_id: "1016", security_name: "ICL Group", security_id: "IL0011334120", issuer_name: "ICL", market_type: "ישראל", exposure_country: "Israel", trading_venue: "TASE", industry_sector: "כימיה", currency_code: "ILS", par_value: 200000, market_price: 6.0, fair_value: 12000, asset_class_weight: 2.5, total_portfolio_weight: 1.6, report_date: "2025-01" },
  { row_id: 6, entity_id: "1016", security_name: "Check Point Software", security_id: "IL0010811243", issuer_name: "Check Point", market_type: "חו\"ל", exposure_country: "Israel", trading_venue: "NASDAQ", industry_sector: "טכנולוגיה", currency_code: "USD", par_value: 8500, market_price: 176.47, fair_value: 15000, asset_class_weight: 3.2, total_portfolio_weight: 2.0, report_date: "2025-01" },
  { row_id: 7, entity_id: "1012", security_name: "Amazon.com Inc", security_id: "US0231351067", issuer_name: "Amazon", market_type: "חו\"ל", exposure_country: "USA", trading_venue: "NASDAQ", industry_sector: "צריכה מחזורית", currency_code: "USD", par_value: 13500, market_price: 200.0, fair_value: 27000, asset_class_weight: 5.7, total_portfolio_weight: 3.6, report_date: "2025-01" },
  { row_id: 8, entity_id: "1015", security_name: "טבע תעשיות פרמצבטיות", security_id: "IL0006290147", issuer_name: "טבע", market_type: "ישראל", exposure_country: "Israel", trading_venue: "TASE", industry_sector: "פארמה", currency_code: "ILS", par_value: 120000, market_price: 65.5, fair_value: 7860, asset_class_weight: 1.7, total_portfolio_weight: 1.0, report_date: "2025-01" },
]

export const governmentBondsData = [
  { row_id: 1, entity_id: "1011", security_name: "גליל 1025", security_id: "IL0060001943", issuer_name: "ממשלת ישראל", market_type: "ישראל", primary_attribute: "צמוד מדד", rating: "AA-", rating_agency: "S&P", currency_code: "ILS", duration: 3.2, maturity_date: "2027-10-31", interest_rate: 0.01, yield_to_maturity: 0.028, fair_value: 50000, asset_class_weight: 12.5, total_portfolio_weight: 6.6, report_date: "2025-01" },
  { row_id: 2, entity_id: "1012", security_name: "גליל 0330", security_id: "IL0060002750", issuer_name: "ממשלת ישראל", market_type: "ישראל", primary_attribute: "שקלי", rating: "AA-", rating_agency: "S&P", currency_code: "ILS", duration: 4.8, maturity_date: "2030-03-31", interest_rate: 0.035, yield_to_maturity: 0.042, fair_value: 42000, asset_class_weight: 10.5, total_portfolio_weight: 5.5, report_date: "2025-01" },
  { row_id: 3, entity_id: "1014", security_name: "US Treasury 10Y", security_id: "US9128283W71", issuer_name: "US Government", market_type: "חו\"ל", primary_attribute: "שקלי", rating: "AA+", rating_agency: "S&P", currency_code: "USD", duration: 8.5, maturity_date: "2034-02-15", interest_rate: 0.04, yield_to_maturity: 0.045, fair_value: 35000, asset_class_weight: 8.8, total_portfolio_weight: 4.6, report_date: "2025-01" },
]

export const corporateBondsData = [
  { row_id: 1, entity_id: "1011", security_name: "לאומי אגח 6", security_id: "IL0011458200", issuer_name: "בנק לאומי", market_type: "ישראל", industry_sector: "בנקאות", rating: "Aa1", rating_agency: "Moody's", currency_code: "ILS", duration: 2.8, maturity_date: "2028-06-30", interest_rate: 0.03, yield_to_maturity: 0.035, fair_value: 20000, asset_class_weight: 8.2, total_portfolio_weight: 2.6, report_date: "2025-01" },
  { row_id: 2, entity_id: "1013", security_name: "אלקטרה נדלן אגח ב", security_id: "IL0011601122", issuer_name: "אלקטרה נדלן", market_type: "ישראל", industry_sector: "נדל\"ן", rating: "A+", rating_agency: "מעלות", currency_code: "ILS", duration: 3.5, maturity_date: "2029-01-15", interest_rate: 0.045, yield_to_maturity: 0.048, fair_value: 8500, asset_class_weight: 3.5, total_portfolio_weight: 1.1, report_date: "2025-01" },
]

export const etfsData = [
  { row_id: 1, entity_id: "1016", security_name: "Amundi MSCI World ETF", security_id: "LU0274208692", issuer_name: "Amundi", market_type: "חו\"ל", exposure_country: "Global", trading_venue: "Euronext", fund_classification: "מנייתי", currency_code: "EUR", market_price: 375.0, fair_value: 45000, asset_class_weight: 18.5, total_portfolio_weight: 5.9, report_date: "2025-01" },
  { row_id: 2, entity_id: "1011", security_name: "iShares Core S&P 500", security_id: "US4642872000", issuer_name: "BlackRock", market_type: "חו\"ל", exposure_country: "USA", trading_venue: "NYSE", fund_classification: "מנייתי", currency_code: "USD", market_price: 520.0, fair_value: 38000, asset_class_weight: 15.6, total_portfolio_weight: 5.0, report_date: "2025-01" },
]

// Combine all for the "all assets" view
export const allHoldingsData = [
  ...tradedStocksData.map(d => ({ ...d, asset_class: "Stocks" })),
  ...governmentBondsData.map(d => ({ ...d, asset_class: "Gov Bonds" })),
  ...corporateBondsData.map(d => ({ ...d, asset_class: "Corp Bonds" })),
  ...etfsData.map(d => ({ ...d, asset_class: "ETFs" })),
]
