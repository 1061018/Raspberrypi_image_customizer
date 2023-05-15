from jinja2 import Template
from template_vars import data

template = Template(open('firstrun.sh.j2').read())
set_hostname = True
new_hostname = "test_hostname"
final_script = template.render(data)

with open('my_shell.sh', 'w') as f:
    f.write(final_script)
