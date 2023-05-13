"""
Configurations options Yaml File Parser
"""
import yaml

class YamlParser:
    """
    Class designed to parse the setup created by the user in a .yaml file inside /my_setups folder
    On object creation specify the path to chosen .yaml file
    as an argument so the constructor populates a class variable
    """
    def __init__(self, file_path):
        """
        Args:
            file_path (string): path to file
        """
        self.user_config_yaml = self.load_yaml_file(file_path)

    def get_image_path(self):
        """_summary_

        Returns:
            _type_: _description_
        """
        rpi_conf_yaml =self.user_config_yaml["raspberry_py_image"]
        return rpi_conf_yaml

    @staticmethod
    def load_yaml_file(file_path):
        """
        :param file_path: [path to .yaml]
        :type file_path: [type:string]
        """
        with open(file_path) as file:
            return yaml.load(file, Loader=yaml.FullLoader)
