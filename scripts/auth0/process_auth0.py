import json
import sys
import os

def process_auth0_data(src_env, dest_env, file_path):
    try:
        # Validate that the files exist
        for file in [src_env, dest_env, file_path]:
            if not os.path.isfile(file):
                print(f"❌ Error: File '{file}' not found!")
                sys.exit(1)

        # Load source JSON
        with open(src_env, 'r', encoding='utf-8') as f:
            src_json_config = json.load(f)

        # Load destination JSON
        with open(dest_env, 'r', encoding='utf-8') as f:
            dest_json_config = json.load(f)

        # Extract mappings
        src_mappings = src_json_config.get("AUTH0_KEYWORD_REPLACE_MAPPINGS", {})
        dest_mappings = dest_json_config.get("AUTH0_KEYWORD_REPLACE_MAPPINGS", {})

        # Read the file content
        with open(file_path, 'r', encoding='utf-8') as f:
            file_content = f.read()

        # Replace values
        for key in dest_mappings.keys():
            from_value = src_mappings.get(key)
            to_value = dest_mappings.get(key)

            if from_value is None:
                print(f"⚠️ Skipping: No source mapping found for '{key}'")
            elif to_value is None:
                print(f"⚠️ Skipping: No destination mapping found for '{key}'")
            else:
                print(f"🔄 Replacing '{from_value}' → '{to_value}'")
                file_content = file_content.replace(from_value, to_value)

        # Write updated content back to the file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(file_content)

        print("✅ Processing completed successfully!")

    except json.JSONDecodeError:
        print(f"❌ Error: Invalid JSON format in '{src_env}' or '{dest_env}'")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")
        sys.exit(1)

# Example usage
if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python process_auth0.py <source_json> <dest_json> <file>")
        sys.exit(1)

    process_auth0_data(sys.argv[1], sys.argv[2], sys.argv[3])
