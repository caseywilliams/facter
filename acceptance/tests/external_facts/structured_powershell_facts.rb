require 'pp'
# This test is intended to demonstrate that powershell external facts can return
# YAML or JSON data, in addition to plain key-value pairs. If the output cannot be
# parsed as YAML, it will fall back to key-value pair parsing, and only fail if
# this is also invalid.
test_name "powershell facts can return structured data" do

    require 'facter/acceptance/user_fact_utils'
    extend Facter::Acceptance::UserFactUtils

    confine :to, :platform => /windows-/

    agents.each do |agent|
        os_version = on(agent, facter('kernelmajversion')).stdout.chomp.to_f
        factsd = get_factsd_dir(agent['platform'], os_version)

        yaml_output_file = File.join(factsd, "external_fact_ps1_yaml.ps1")
        yaml_output_content = <<EOM
$yaml_content = @'
---
PS1_YAML_FACT1: foo
PS1_yaml_fact2: 2
ps1_yaml_fact3: |
  one value
  but
  many lines
ps1_yaml_fact4:
  - one
  - two
ps1_yaml_fact5: [first, second, third]
ps1_yaml_fact6:
  red: green
  orange: blue
  yellow: purple
ps1_yaml_fact7: { key: value }
'@
Write-Output($yaml_content)
EOM

        json_output_file = File.join(factsd, "external_fact_ps1_json.ps1")
        json_output_content = <<EOM
Write-Output(@{
'PS1_JSON_FACT1' = 'value1'
'ps1_json_fact2' = 2
'ps1_json_fact3' = $true
'ps1_json_fact4' = @('first', 'second')
'ps1_json_fact5' = $Null
'ps1_json_fact6' = @{ 'a' = 'b'; 'c' = 'd' }
} | ConvertTo-JSON -Depth 1 -Compress)
EOM

        step "Agent #{agent}: set up external facts directory (facts.d)" do
            on(agent, "mkdir -p '#{factsd}'")
        end

        teardown do
            on(agent, "rm -rf '#{factsd}'")
        end

        step "Agent #{agent}: create an external powershell fact that outputs yaml in default facts.d" do
            create_remote_file(agent, yaml_output_file, yaml_output_content)
            on(agent, "chmod +x '#{yaml_output_file}'")

            step "YAML output should produce a structured fact" do
                on(agent, facter('yaml_fact')) do |facter_output|
                    pp facter_output
                    assert_match("YAML OUTPUT HERE", facter_output.stdout.chomp, 'Expected to resolve the external_fact')
                end
            end
        end

        step "Agent #{agent}: create an external powershell fact that outputs json in default facts.d" do
            create_remote_file(agent, json_output_file, json_output_content)
            on(agent, "chmod +x '#{json_output_file}'")

            step "JSON output should produce a structured fact" do
                on(agent, facter('json_fact')) do |facter_output|
                    pp facter_output
                    assert_match("JSON_OUTPUT_HERE", facter_output.stdout, 'Expected to resolve json_fact and parse output')
                end
            end
        end

    end
end
