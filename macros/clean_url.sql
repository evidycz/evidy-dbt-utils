{#
  clean_url_domain

  Cleans a raw URL column to extract the root domain.
  Compatible with: BigQuery, DuckDB.

  Parameters:
  - column_name: The SQL column or expression containing the URL string.

  Logic:
  1. Removes protocols (http://, https://) and subdomains (www., m.) from the beginning.
  2. Removes paths and query parameters (everything starting from the first forward slash).
#}
{% macro clean_url_domain(column_name) %}

    regexp_replace(
        regexp_replace(
            lower(trim({{ column_name }})),
            -- Regex 1: Match start (^) + optional protocol + optional 'www.' or 'm.'
            '^(https?://)?(www\\.|m\\.)?',
            ''
        ),
        -- Regex 2: Match the first forward slash and everything after it ($)
        '/.*$',
        ''
    )

{% endmacro %}