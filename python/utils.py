"""
Utils for Documentation Generation from UDT Yaml Files
"""
import os
import subprocess
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Union, OrderedDict

import yaml
from pyrasgo.rasgo import Rasgo
from pyrasgo.schemas import Transform

from python import constants

# ----------------------------------------------
#      Utils for Doc and Transform Creation
# ----------------------------------------------


def load_all_yaml_files() -> Dict[str, Dict[str, Dict]]:
    """
    Load and return all the yaml files in the dirs <root>/<transform_type>_transforms
    If new transform type/dir added be sure to add above in List TRANSFORM_TYPES
    """
    transform_yamls = defaultdict(dict)

    for transform_type in constants.TRANSFORM_TYPES:
        transform_type_dir_path = _get_udt_repo_dir() / f"{transform_type}_transforms"

        # Get list of all transform names of this type,
        # by looking at sub-directory names one level down
        transform_names = [
            x.name for x in transform_type_dir_path.iterdir() if x.is_dir()
        ]
        for transform_name in transform_names:
            transform_yaml_path = transform_type_dir_path / transform_name / f"{transform_name}.yaml"

            # If this Transform is a DW specific type, load the default
            transform_yaml_override_path = transform_type_dir_path / transform_name / constants.RASGO_DATAWAREHOUSE / f"{transform_name}.yaml"
            if transform_yaml_override_path.exists():
                transform_yaml_path = transform_yaml_override_path

            # Try to load yaml file for transform
            # If loaded successfully save in return dict
            try:
                transform_data = _read_yaml(transform_yaml_path)
                transform_yamls[transform_type][transform_name] = transform_data
            except Exception as e:
                print(f"Can't read YAML file for transform {transform_name}\n"
                      f"Error Msg: {e}\n")

    return transform_yamls

def override_path_exists(transform_type: str, transform_name: str, dw_type: str) -> bool:
    """
    Returns true is an override file exists for this dw for this transform
    """
    transform_type_dir_path = _get_udt_repo_dir() / f"{transform_type}_transforms"
    transform_override_path = transform_type_dir_path / transform_name / dw_type / f"{transform_name}.sql"
    if transform_override_path.exists():
        return True
    return False

def get_root_dir() -> Path:
    """
    Get and return the root directory absolute path of this git repo
    """
    cmd = ["git", "rev-parse", "--show-toplevel"]
    root_dir_bytes = subprocess.check_output(cmd)
    root_dir_str = root_dir_bytes.decode('utf-8').strip()
    return Path(root_dir_str)


# ----------------------------------------------
#         Utils for Transform Publishing
# ----------------------------------------------


def set_rasgo_domain_env(rasgo_domain: str) -> None:
    """
    From Rasgo Domain/Enum Name, return the rasgo url for it

    :param rasgo_domain: 'local', 'staging', or 'production
    """
    rasgo_domains = constants.PyRasgoEnvironment._member_map_
    rasgo_domain_url = rasgo_domains[rasgo_domain.upper()].value
    os.environ["RASGO_DOMAIN"] = rasgo_domain_url


def get_all_rasgo_transform_keyed_by_name(rasgo: Rasgo) -> Dict[str, Transform]:
    """
    Return a Dict of all transforms keyed by names the respective
    transform as their value
    """
    transform_in_rasgo = rasgo.get.transforms()
    return {t.name: t for t in transform_in_rasgo}


def transform_needs_versioning(
        transform: Transform,
        _type: str,
        source_code: str,
        arguments: List[Dict[str, str]],
        description: str,
        tags: List[str]
) -> bool:
    """
    Return true if any of the attributes for the transform has
    changed and it needs to be versioned

    This includes
      - description
      - transform type
      - source_code
      - all of the transform arguments and their attrs
      - set tags on the transform
    """
    transform_needs_versioning = description != transform.description or \
                                 source_code != transform.sourceCode or \
                                 _type != transform.type or \
                                 set(tags) != set(transform.tags) or \
                                 _transform_args_have_changed(transform, arguments)
    return transform_needs_versioning


def get_transform_source_code(transform_type: str, transform_name: str) -> str:
    """
    From a transform name and type load and return it's source code as a string
    """
    transform_type_dir = _get_udt_repo_dir() / f"{transform_type}_transforms"
    source_code_path = transform_type_dir / transform_name / f"{transform_name}.sql"
    source_code_override_path = transform_type_dir / transform_name / constants.RASGO_DATAWAREHOUSE / f"{transform_name}.sql"
    if source_code_override_path.exists():
        source_code_path = source_code_override_path
    with open(source_code_path) as fp:
        source_code = fp.read()
    return source_code


def parse_transform_args_from_yaml(transform_yaml: Dict) -> List[Dict[str, str]]:
    """
    From a loaded Transform Yaml File parse the
    Transform args in proper format, return the args
    in proper format for transform creation in PyRasgo
    """
    transform_args = []
    for arg_name, arg_meta_data in transform_yaml['arguments'].items():
        transform_args.append(
            {**{'name': arg_name}, **arg_meta_data}
        )
    return transform_args


def listify_tags(tags: Optional[Union[str, List[str]]]) -> List[str]:
    """
    Convert a dn return the the the possible values of a tag
    when parsed from a Yaml to a List of strings, so we can compare
    if the transform needs updating or not
    """
    if tags is None:
        return []
    elif isinstance(tags, str):
        return [tags]
    else:
        return tags


# ----------------------------------------------
#          Utils for Docs Generation
# ----------------------------------------------


def get_table_values(transform_args: Dict) -> List[List[str]]:
    """
    From a Transform Args Dict derived from YML file,
    generated a nested list of values to populate for the
    Markdown table describing each argument
    """
    all_data = []
    for arg_name, arg_info in transform_args.items():
        row_data = [
            arg_name,
            arg_info['type'],
            arg_info['description'],
            arg_info.get('is_optional', '')
        ]
        all_data.append(row_data)
    return all_data


# ----------------------------------------------
#    Utils for Gitbook SUMMARY.md Generation
# ----------------------------------------------

def get_transforms_grouped_by_tags() -> Dict[str, List[str]]:
    """
    Return a mapping of `transform_tag` to a list of
    transform names with that tag based off of the YAMLs
    in this repo
    """
    transforms_by_tags = defaultdict(list)
    for _, transform_type_yamls in load_all_yaml_files().items():
        for transform_name, transform_yaml in transform_type_yamls.items():
            transform_tags = listify_tags(
                tags=transform_yaml.get('tags')
            )
            # For each transform mark it as apart of that tag
            # also mark it with a 'all' tag
            for tag in transform_tags:
                transforms_by_tags[tag].append(transform_name)
            transforms_by_tags['all'].append(transform_name)
    return transforms_by_tags


def snack_case_to_title(string: str) -> str:
    """
    Title case a string from snake case

    Example: 'min_max_scaler' -> 'Min Max Scaler'
    """
    string = string.replace('_', ' ').title()
    return string.title()


# ----------------------------------------------
#      Private Helper Funcs for this File
# ----------------------------------------------


def _transform_args_have_changed(
        transform: Transform,
        arguments: List[Dict[str, str]]
) -> bool:
    """
    Return true if any of the transform arguments have changed
    false otherwise
    """
    # If number of args changed transform, transform needs versioning
    if len(transform.arguments) != len(arguments):
        return True
    # For each arg in yaml, see if anything changed compared to db
    for yaml_arg in arguments:
        db_args_w_name = [a for a in transform.arguments if a.name == yaml_arg['name']]

        # If a arg with this name isn't in db, transform needs versioning
        if not db_args_w_name:
            return True

        # Lastly check if any of the transform arg attrs have change
        # if so, transform needs versioning
        db_arg = db_args_w_name[0]
        if db_arg.description != yaml_arg['description'] or \
                db_arg.is_optional != yaml_arg.get('is_optional', False) or \
                db_arg.type != yaml_arg['type']:
            return True

    # If nothing changed in transform arguments return False
    return False


def _read_yaml(yaml_path: Path) -> Dict:
    """
    Read and load a YAML file into a dictionary
    """
    with open(yaml_path, "r") as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"Error Parsing YAML file at {yaml_path}"
                  f"\n\nError Msg: {e}")


def _get_udt_repo_dir() -> Path:
    """
    Get and return the absolute path of the directory
    containing all transform Jinja and Yaml files
    """
    return get_root_dir() / "rasgotransforms" / "rasgotransforms"
