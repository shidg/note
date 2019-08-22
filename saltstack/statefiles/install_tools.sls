{% for tool in pillar['tools_list']  %}
{{ tool }} install:
  pkg.installed:
    - name: {{ tool }}
{% endfor %}
