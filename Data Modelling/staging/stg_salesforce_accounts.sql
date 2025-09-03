CREATE TABLE stg_salesforce_accounts AS (
SELECT
  SALESFORCE_ACCOUNT_ID AS salesforce_account_id,
  SALESFORCE_ACCOUNT_SIRET AS salesforce_account_siret,
  SALESFORCE_ACTIVITY_CODE AS salesforce_activity_code,
  SALESFORCE_POSTAL_CODE_ID AS salesforce_postal_code_id,
  SALESFORCE_ACCOUNT_TEAM_DYNAMIC AS salesforce_account_team_dynamic
FROM migration_data.sf_accounts
)