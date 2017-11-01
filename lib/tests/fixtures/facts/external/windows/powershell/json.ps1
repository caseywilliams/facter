Write-Output (@{ 'ps1_json_fact1'='value1'; 'PS1_JSON_fact2' = 'value2' } | ConvertTo-JSON -Depth 1 -Compress)
