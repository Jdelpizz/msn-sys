import jinja2

j=""
with open("./template.j2") as file:
    j=file.read()

print(jinja2.Template(j).render())
