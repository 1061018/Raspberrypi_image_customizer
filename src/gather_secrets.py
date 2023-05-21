"""
Read configuration yaml file from my_setups folder
Gathers all secrets and dumps them in to github actions env variable e.g.: user_name_password input will be converted into the password stored in the vault


"""

import os
from yaml_reader import YamlParser



def main():
    user_config_yaml = YamlParser.load_yaml_file("my_setups/default.yaml")

    host_name= user_config_yaml.get("host_name", "")
    user_name= user_config_yaml.get("user_name", "")
    user_name_password= user_config_yaml.get("user_name_password", "")
    wifi_ssid= user_config_yaml.get("wifi_ssid", "")
    wifi_password= user_config_yaml.get("wifi_password", "")
    ssh_public_key= user_config_yaml.get("ssh_public_key", "")

    env_file = os.getenv('GITHUB_ENV')

    with open(env_file, "a") as fp:
        fp.write(f'host_name={host_name}')
        fp.write("\n")
        fp.write(f'user_name={user_name}')
        fp.write("\n")
        fp.write(f'user_name_password={user_name_password}')
        fp.write("\n")
        fp.write(f'wifi_ssid={wifi_ssid}')
        fp.write("\n")
        fp.write(f'wifi_password={wifi_password}')
        fp.write("\n")
        fp.write(f'ssh_public_key={ssh_public_key}')

if __name__ == "__main__":
    main()