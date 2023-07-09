make_MSN-sys_dir:
  file.directory:
    - name: "c:\\Mission System"

deploy_schedule_task_xml:
  file.managed:
    - source: "salt://deploy/files/template.j2"
    - name: "c:\\Mission System\\scheduled task.xml"
    - template: jinja
    - defaults:
        grain: "mx_data"
{% if grains['os'] == 'Ubuntu' %}
    - context:
        grain: "mx_data"
{% endif %}

run_schedule_task_script:
  cmd.run:
    - name: 'schtasks.exe /Create /TN "\Mission System\server" /XML "C:\Mission System\scheduled task.xml" /ru SYSTEM'
    - cwd: "C:\\Mission System\\"