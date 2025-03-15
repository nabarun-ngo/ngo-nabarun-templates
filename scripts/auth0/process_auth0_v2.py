import json
import sys
import os
import shutil
import logging

# Configure logging
logging.basicConfig(format="%(levelname)s: %(message)s", level=logging.INFO)

def replace_values_with_keys(env_file, file_path, dry_run=False):
    try:
        # Validate that files exist
        for file in [env_file, file_path]:
            if not os.path.isfile(file):
                logging.error(f"File '{file}' not found!")
                sys.exit(1)

        # Load JSON config
        with open(env_file, 'r', encoding='utf-8') as f:
            json_config = json.load(f)

        # Extract mappings (value → key)
        mappings = json_config.get("AUTH0_KEYWORD_REPLACE_MAPPINGS", {})
        reverse_mappings = {v: k for k, v in mappings.items() if v}  # Reverse dictionary

        # Read file content
        with open(file_path, 'r', encoding='utf-8') as f:
            file_content = f.read()

        # Backup the file before modifying
        backup_file = file_path + ".bak"
        if not dry_run:
            shutil.copy(file_path, backup_file)
            logging.info(f"Backup created: {backup_file}")

        # Replace values with keys
        changes_made = False
        for value, key in reverse_mappings.items():
            if value in file_content:
                logging.info(f"Replacing '{value}' → '{key}'")
                file_content = file_content.replace(value, key)
                changes_made = True

        # Write updated content back if not in dry-run mode
        if changes_made:
            if dry_run:
                logging.info("Dry-run mode enabled. No changes were saved.")
            else:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(file_content)
                logging.info("✅ Processing completed successfully!")
        else:
            logging.info("No replacements were necessary.")

    except json.JSONDecodeError:
        logging.error(f"Invalid JSON format in '{env_file}'")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        sys.exit(1)

# Example usage
if __name__ == "__main__":
    if len(sys.argv) not in [3, 4]:
        print("Usage: python replace_values.py <env_json> <file> [--dry-run]")
        sys.exit(1)

    dry_run_flag = "--dry-run" in sys.argv
    replace_values_with_keys(sys.argv[1], sys.argv[2], dry_run=dry_run_flag)
