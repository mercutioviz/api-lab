# convert URL and parameter profiles
import json
import sys
import os
import re

waf_fields = (
    "allow-query-string",
    "allowed-content-types",
    "allowed-methods",
    "blocked-attack-types",
    "exception-patterns",
    "extended-match",
    "extended-match-sequence",
    "hidden-parameter-protection",
    "max-content-length",
    "maximum-parameter-name-length",
    "maximum-upload-files",
    "mode",
    "name",
    "status",
    "url"
)

field_map = {
    "allow-query-string": "allow_query_string",
    "allowed-content-types": "allowed_content_types",
    "allowed-methods": "allowed_methods",
    "exception-patterns": "exception_patterns",
    "extended-match": "extended_match",
    "extended-match-sequence": "priority",
    "hidden-parameter-protection": "hidden_parameter_protection",
    "max-content-length": "max_content_length",
    "maximum-parameter-name-length": "maximum_parameter_name_length",
    "maximum-upload-files": "maximum_upload_files",
    "mode": "mode",
    "name": "name",
    "status": "enabled",
    "url": "name"
}

blocked_attacks_map = {
    "SQL Injection": {"sql_injection": "normal"},
    "SQL Injection strict": {"sql_injection": "strict"},
    "OS Command Injection": {"os_command_injection": "normal"},
    "OS Command Injection strict": {"os_command_injection": "strict"},
    "Cross-Site Scripting": {"cross_site_scripting": "normal"},
    "Cross-Site Scripting strict": {"cross_site_scripting": "strict"},
    "Remote File Inclusion": {"remote_file_inclusion": "normal"},
    "Remote File Inclusion strict": {"remote_file_inclusion": "strict"},
    "LDAP Injection": {"ldap_injection": "normal"},
    "Python-PHP attacks": {"python_php_attacks": "normal"},
    "HTTP Specific Injection": {"http_specific_injection": "normal"},
    "Apache Struts attacks": {"apache_struts_attacks": "normal"},
    "Apache Struts attacks strict": {"apache_struts_attacks": "strict"}
}

base_waas_app_profile ={
      "allow_query_string": True,
      "allowed_content_types": [
        "application/x-www-form-urlencoded",
        "multipart/form-data",
        "text/xml"
      ],
      "allowed_methods": [
        "GET",
        "HEAD",
        "POST"
      ],
      "apache_struts_attacks": "none",
      "cross_site_scripting": "none",
      "csrf_prevention": "None",
      "enabled": True,
      "exception_patterns": [],
      "extended_match": "*",
      "hidden_parameter_protection": "Forms",
      "http_specific_injection": "none",
      "ldap_injection": "none",
      "max_content_length": 32768,
      "maximum_parameter_name_length": 64,
      "maximum_upload_files": 5,
      "mode": "Passive",
      "name": "",
      "os_command_injection": "none",
      "parameter_profiles": [],
      "priority": 1,
      "python_php_attacks": "none",
      "remote_file_inclusion": "none",
      "sql_injection": "none",
      "url": ""
}

if len(sys.argv) < 2:
    print("Please supply source json file as CLI argument")
    sys.exit()
else:
    infile = str(sys.argv[1])

#print('Using', infile, 'as source file')

if os.path.isfile(infile):
    #print('Looks like a real file')
    all_good = True
else:
    print('It seems', infile, 'is not a real file. Please try again.')
    sys.exit()

with open(infile) as f:
    data_dict = json.load(f)

#print(json.dumps(data_dict, indent = 2, sort_keys=True ))
target_dict = dict(base_waas_app_profile)

# Loop through WAF blocked attack types looking for 'Strict'
# If we find a 'stict' then remove the non-strict
# Example: if we have 'SQL Injection Strict' then remove 'SQL Injection'
# If we don't then we run the risk of setting SQL Injection to normal instead of strict on WaaS
temp_list = data_dict['blocked-attack-types']
print(temp_list)
# Title case all strings becuase of silly things like Apache Struts and Apache struts strict...
waf_attack_types = [re.sub('struts','Struts',item) for item in temp_list]
print("Before:\n", waf_attack_types)
for attack_type in waf_attack_types:
    is_strict = re.search("(.*?) Strict", attack_type, re.IGNORECASE)
    if is_strict:
        non_strict_attack_type = is_strict[1]
        non_strict_attack_type
        # Remove the non-strict attack type from blocked attack types list
        print(is_strict,is_strict[1])
        print("-= '" + non_strict_attack_type + "'")
        waf_attack_types.remove(non_strict_attack_type)
        print("Removed " + non_strict_attack_type + " from attack types")
        #data_dict['blocked-attack-types'].remove(non_strict_attack_type)
print("After:\n", waf_attack_types)
print("--==--")
print(waf_attack_types)
for field in waf_fields:
    # Check first to see if this node is the blocked attacks
    if field == 'blocked-attack-types':
        print("---=== Found blocked attack types ===---")
        #attack_types = data_dict[field]
        for attack_type in waf_attack_types:
            print(" ", attack_type)
            kv = blocked_attacks_map[attack_type]
            print("    attack map for",attack_type,"is:")
            print("      ", kv)
        print("--==--")
    else:
        print(field,':',data_dict[field])
        target_dict[field_map[field]] = data_dict[field]

print("Target dict:")
print(json.dumps(target_dict,indent=2))
