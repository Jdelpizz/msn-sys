{#- Set Command String #}
{% set src_path="salt://deploy/files/src"%}
{%- if "MSN_API" in grains['msn-sys'] -%}
  {%- set src = "msn_api_server" -%}
{%- elif "MX_API" in grains['msn-sys'] -%}
  {%- set src = "mx_api_server" %}
{%- elif "MSN_DATA" in grains['msn-sys'] -%}
  {%- set src = "msn_data_server" -%}
{%- elif "MX_DATA" in grains['msn-sys'] -%}
  {%- set src = "mx_data_server" -%}
{%- endif -%}

{%- macro full_src(src_path, src) -%}
{{src_path}}/{{src}}/
{%- endmacro-%}

{% set msn_sys_path = full_src(src_path, src) %}

make_MSN-sys_dir:
  file.directory:
    - name: "c:\\Mission System"

deploy_mission_system_src:
  file.recurse:
    - source: {{msn_sys_path}}
    - name: "c:\\Mission System"
    - keep_source: False

deploy_schedule_task_xml:
  file.managed:
    - source: "salt://deploy/files/template.j2"
    - name: "c:\\Mission System\\scheduled task.xml"
    - template: jinja

run_schedule_task_script:
  cmd.run:
    - name: 'schtasks.exe /Create /TN "\Mission System\server" /XML "C:\Mission System\scheduled task.xml" /ru SYSTEM'
    - cwd: "C:\\Mission System\\"