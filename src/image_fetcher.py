"""
Fetches images
"""
import argparse
import lzma
import requests
from yaml_reader import YamlParser

def parse_input_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "image_name", help="The name for the RPI image.", type= str
    )
    args = parser.parse_args()
    return args


def main(args):

    yaml_reader = YamlParser("my_setups/default.yaml")
    image_path = yaml_reader.get_image_path()
    print(f"Downloading image {image_path}.")
    response = requests.get(url=image_path)
    print("Image downloaded, initiating decompression!")
    decompressed_content = lzma.decompress(response.content)
    print("Image decompressed!")



    with open(args.image_name, "wb") as fp:
        fp.write(decompressed_content)

    print("Image available for customization!")

if __name__ == "__main__":
    args = parse_input_arguments()
    main(args)
