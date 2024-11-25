import os
import stat
import requests
import sys
import subprocess
import docker
import json

GITHUB_BUILD_SCRIPT_BASE_REPO = "build-scripts"
GITHUB_BUILD_SCRIPT_BASE_OWNER = "ppc64le"
HOME = os.getcwd()

package_data = {}

def trigger_basic_validation_checks(file_name):
    key_checks = {
        "# Package": "package_name",
        "# Version": "package_version",
        "# Source repo": "package_url",
        "# Tested on": "",
        "# Maintainer": "maintainer",
        "# Language": "package_type",
        "# Travis-Check": "travis_check"
    }
    matched_keys = []
    file_parts = file_name.split('/')
    licence_file = "{}/{}/LICENSE".format(HOME, "/".join(file_parts[:-1]))
    if not os.path.exists(licence_file):
        raise ValueError("License file cannot be not found.")

    script_path = "{}/{}".format(HOME, file_name)

    eof = os.popen('file ' + script_path).read()
    if 'crlf' in eof.lower():
        raise EOFError("Build script {} contains windows line endings(CRLF), Please update build script with Linux based line endings.".format(file_name))

    if os.path.exists(script_path):
        all_lines = []
        with open(script_path) as script_file_handler:
            all_lines = script_file_handler.readlines()
        for line in all_lines:
            try:
                for key in key_checks:
                    if key == '# Tested on' and key in line:
                        matched_keys.append(key)
                        distro_data = line.split(':')[-1].strip()
                        distro_data = distro_data.split(' ')
                        package_data["distro_name"] = distro_data[0]
                        package_data["distro_version"] = distro_data[-1]
                    elif key in line:
                        matched_keys.append(key)
                        package_data[key_checks[key]] = line.split(':', 1)[-1].strip()
            except IndexError as ie:
                raise IndexError(str(ie))

        if set(matched_keys) == set(list(key_checks.keys())):
            print("Basic Checks passed")
            return True
        else:
            print("Basic Validation Checks Failed!!!")
            print("Required keys: {}".format(",".join(key_checks.keys())))
            print("Found keys: {}".format(",".join(matched_keys)))
            print("Missing required keys: {}".format(",".join(set(key_checks.keys()) - set(matched_keys))))
            raise ValueError(f"Basic Validation Checks Failed for {file_name} !!!")
    else:
        raise ValueError("Build script not found.")

def trigger_script_validation_checks(file_name, version, image_name):
    client = docker.DockerClient(base_url='unix://var/run/docker.sock')
    st = os.stat(file_name)
    current_dir = os.getcwd()
    os.chmod("{}/{}".format(current_dir, file_name), st.st_mode | stat.S_IEXEC)
    
    print(current_dir)
    print(file_name)
    package = file_name.split("/")[1]
    print(package)
    try:
        command = [
            "bash",
            "-c",
            f"cd /home/tester/ && ./{file_name} {version} "
        ]
        
        container = client.containers.run(
            image_name,
            command,
            network='host',
            detach=True,
            volumes={
                current_dir: {'bind': '/home/tester/', 'mode': 'rw'}
            },
            stderr=True,
        )
        result = container.wait()
    except Exception as e:
        print(f"Failed to created container: {e}")    
    try:
        print(container.logs().decode("utf-8"))
    except Exception:
        print(container.logs())
    container.remove()
    if int(result["StatusCode"]) != 0:
        raise Exception(f"Build script validation failed for {file_name} !")
    else:
        return True

def validate_build_info_file(file_name):
    try:
        script_path = os.path.join(HOME, file_name)
        mandatory_fields = ['package_name', 'github_url', 'version', 'default_branch', 'build_script', 'package_dir', 'maintainer']
        error_message = f"No `{{}}` field available in {file_name}."

        data = json.load(open(script_path, 'r'))
        for field in mandatory_fields:
            if field not in data:
                raise ValueError(error_message.format(field))
        print("Valid file")
        return True
    except Exception as e:
        print(str(e))
        print(f"Failed to load build_info file at {file_name} !")
        raise e

def trigger_build_validation_travis(pr_number):
    pull_request_file_url = "https://api.github.com/repos/{}/{}/pulls/{}/files".format(
        GITHUB_BUILD_SCRIPT_BASE_OWNER,
        GITHUB_BUILD_SCRIPT_BASE_REPO,
        pr_number
    )
    validated_file_list = []
    response = requests.get(pull_request_file_url).json()
    for i in response:
        file_name = i.get('filename', "")
        if not file_name:
            continue
        status = i.get('status', "")
        if file_name.endswith('.sh') and "dockerfile" not in file_name.lower() and status != "removed":
            trigger_basic_validation_checks(file_name)
            
            travis_check = package_data['travis_check'].lower()
            if travis_check == "true":
                trigger_script_validation_checks(file_name)
            else:
                print(f"Skipping Build script validation for {file_name} as Travis-Check flag is set to False")
            validated_file_list.append(file_name)
        elif file_name.lower().endswith('build_info.json') and status != "removed":
            validate_build_info_file(file_name)
            validated_file_list.append(file_name)

    if len(validated_file_list) == 0:
        print("No scripts available for validation.")
    else:
        print("Validated below scripts:")
        print(*validated_file_list, sep="\n")

# New Functionality: Create a Wheel and Upload to Artifactory
def create_wheel_and_upload(artifactory_url, repo_path, artifactory_user, artifactory_password):
    try:
        # Step 1: Create the wheel
        subprocess.check_call([sys.executable, 'setup.py', 'bdist_wheel'])

        # Step 2: Find the wheel file
        dist_dir = os.path.join(HOME, 'dist')
        wheel_files = [f for f in os.listdir(dist_dir) if f.endswith('.whl')]
        if not wheel_files:
            raise FileNotFoundError("No wheel file found in the dist directory.")
        wheel_file = wheel_files[0]

        # Step 3: Upload to Artifactory
        upload_url = f"{artifactory_url}/{repo_path}/{wheel_file}"
        with open(os.path.join(dist_dir, wheel_file), 'rb') as f:
            response = requests.put(upload_url, data=f, auth=(artifactory_user, artifactory_password))
        if response.status_code == 201:
            print(f"Successfully uploaded {wheel_file} to Artifactory.")
        else:
            print(f"Failed to upload {wheel_file}. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    # Example usage:
    # trigger_build_validation_travis(sys.argv[1])
    print("Inside python program")

    # Trigger build validation or script checks
    trigger_script_validation_checks(sys.argv[1], sys.argv[2], sys.argv[3])

    # Create wheel and upload to Artifactory
    # Example Artifactory parameters - replace these with actual values
    artifactory_url = "https://artifactory.example.com/artifactory"
    repo_path = "python-wheels-local"
    artifactory_user = "your-username"
    artifactory_password = "your-password"
    create_wheel_and_upload(artifactory_url, repo_path, artifactory_user, artifactory_password)
