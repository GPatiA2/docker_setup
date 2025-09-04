#! /usr/bin/env python3

import argparse
import os
import yaml

def options():
    parser = argparse.ArgumentParser(description="Customize a Docker Compose file.")
    parser.add_argument("-in", "--input_file", required=True, help="Path to the input Docker Compose YAML file.") 
    parser.add_argument("-n", "--name", help="Name of the output Docker Compose file.")
    parser.add_argument("-v", "--volumes", nargs='+', help="List of volume names to add to the services.")
    parser.add_argument("-i", "--image", help="Docker image to use for the base service.", default="aerostack2_gpu") 
    return parser.parse_args()

def main():
    args = options()

    docker_dir_path = os.getenv('DOCKER_CFG_DIR') + '/' + args.name

    with open(args.input_file, 'r') as file:
        compose_data = yaml.safe_load(file)

    compose_data['services']['base']['container_name'] = args.name

    if args.image is not None:
        compose_data['services']['base']['image'] = args.image

    for volume in args.volumes:
        print("Adding volume:", volume)
        if volume[-1] == '/':
            volume = volume[:-1]
        vol_base_name = volume.split('/')[-1]
        compose_data['services']['base']['volumes'].append(volume + ':/root/' + vol_base_name)

    compose_data['services']['base']['volumes'].append(docker_dir_path + '/.mybashrc' + ':/root/.mybashrc')

    out_path = docker_dir_path + '/docker-compose.yml' 
    with open(out_path, 'w') as file:
        yaml.dump(compose_data, file, default_flow_style=False)


if __name__ == '__main__':
    main()