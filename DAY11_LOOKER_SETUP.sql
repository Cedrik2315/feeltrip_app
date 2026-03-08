-- Dia 11 - Vistas para dashboard Looker Studio
-- Reemplaza <PROJECT_ID> y <DATASET_ID>
-- Fuente GA4 export: `<PROJECT_ID>.<DATASET_ID>.events_*`

CREATE OR REPLACE VIEW `<PROJECT_ID>.<DATASET_ID>.vw_release_funnel_daily` AS
WITH base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS day,
    event_name,
    user_pseudo_id
  FROM `<PROJECT_ID>.<DATASET_ID>.events_*`
  WHERE event_name IN ('search_executed', 'trip_opened', 'add_to_cart', 'checkout_completed')
)
SELECT
  day,
  COUNT(DISTINCT IF(event_name = 'search_executed', user_pseudo_id, NULL)) AS users_search,
  COUNT(DISTINCT IF(event_name = 'trip_opened', user_pseudo_id, NULL)) AS users_trip_opened,
  COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS users_add_to_cart,
  COUNT(DISTINCT IF(event_name = 'checkout_completed', user_pseudo_id, NULL)) AS users_checkout,
  SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name = 'trip_opened', user_pseudo_id, NULL)),
    COUNT(DISTINCT IF(event_name = 'search_executed', user_pseudo_id, NULL))
  ) AS rate_search_to_trip,
  SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)),
    COUNT(DISTINCT IF(event_name = 'trip_opened', user_pseudo_id, NULL))
  ) AS rate_trip_to_cart,
  SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name = 'checkout_completed', user_pseudo_id, NULL)),
    COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL))
  ) AS rate_cart_to_checkout
FROM base
GROUP BY day;

CREATE OR REPLACE VIEW `<PROJECT_ID>.<DATASET_ID>.vw_release_auth_daily` AS
SELECT
  PARSE_DATE('%Y%m%d', event_date) AS day,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'state') AS auth_state,
  COUNT(*) AS events_count
FROM `<PROJECT_ID>.<DATASET_ID>.events_*`
WHERE event_name = 'auth_gate_state'
GROUP BY day, auth_state;

CREATE OR REPLACE VIEW `<PROJECT_ID>.<DATASET_ID>.vw_release_ai_daily` AS
WITH ai AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS day,
    event_name,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'duration_ms') AS duration_ms
  FROM `<PROJECT_ID>.<DATASET_ID>.events_*`
  WHERE event_name IN ('ai_request_start', 'ai_request_success', 'ai_request_error')
)
SELECT
  day,
  COUNTIF(event_name = 'ai_request_start') AS ai_start,
  COUNTIF(event_name = 'ai_request_success') AS ai_success,
  COUNTIF(event_name = 'ai_request_error') AS ai_error,
  SAFE_DIVIDE(COUNTIF(event_name = 'ai_request_success'), COUNTIF(event_name = 'ai_request_start')) AS ai_success_rate,
  APPROX_QUANTILES(IF(event_name = 'ai_request_success', duration_ms, NULL), 100)[OFFSET(95)] AS ai_duration_p95_ms
FROM ai
GROUP BY day;
