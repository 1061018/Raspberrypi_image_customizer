import os
from jinja2 import Template
from template_vars import data
from yaml_reader import YamlParser

def main():
    template = Template(open('src/firstrun.sh.j2').read())
    user_config_yaml = YamlParser.load_yaml_file("my_setups/default.yaml")

    data["new_hostname"] = os.getenv('HOSTNAME')
    data["user_name"] = os.getenv('USERNAME')
    data["user_password"] = os.getenv('USERNAMEPASSWORD')
    if data["user_name"] and data["user_password"]:
        data["set_user"] = True #create assertion for if username and password???
    data["ssh_public_key"] = os.getenv('SSHPUBLICKEY')
    data["ssh_password_authentication"] = user_config_yaml.get("ssh_password_authentication", False)
    if data["ssh_password_authentication"] or data["ssh_public_key"]:
        data["enable_ssh"] = True
    data["wifi_ssid"] = os.getenv('WIFISSID')
    data["wifi_pass"] = os.getenv('WIFIPASSWORD')
    data["wifi_country"] = user_config_yaml.get("wifi_country")
    data["hidden_ssid"] = user_config_yaml.get("hidden_ssid", data["hidden_ssid"])
    if data["wifi_ssid"] and data["wifi_pass"] and data["wifi_country"]:
        data["enable_wifi"] = True
    data["set_local"] = user_config_yaml.get("set_local")
    data["keyboard"] = user_config_yaml.get("keyboard")
    data["timezone"] = user_config_yaml.get("timezone")




# fazer assert de coisas que nao podem estar em conjunto


# set_hostname = True
# new_hostname = "test_hostname"
    final_script = template.render(data)

    with open('firstrun.sh', 'w') as f:
        f.write(final_script)

if __name__ == "__main__":
    main()
