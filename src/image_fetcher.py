"""
Fetches images
"""

import lzma
import requests
from yaml_reader import YamlParser

def main():
    yaml_reader = YamlParser("my_setups/default.yaml")
    image_path = yaml_reader.get_image_path()
    print(f"Downloading image {image_path}.")
    response = requests.get(url=image_path)
    print("Image downloaded, initiating decompression!")
    decompressed_content = lzma.decompress(response.content)
    print("Image decompressed!")

    with open("2023-02-21-raspios-buster-armhf-lite.img", "wb") as fp:
        fp.write(decompressed_content)

    print("Image available for customization!")

if __name__ == "__main__":
    main()
