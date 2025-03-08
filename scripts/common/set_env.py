import os
import json

github_event_path = os.getenv("GITHUB_EVENT_PATH")

inputs = {}

# Load GitHub event data (for repository_dispatch)
if github_event_path and os.path.exists(github_event_path):
    with open(github_event_path, "r") as f:
        event_data = json.load(f)
    inputs.update(event_data.get("client_payload", {}))  # Extract payload data

# Capture workflow_dispatch inputs from environment variables
for key, value in os.environ.items():
    if key.startswith("INPUT_"):  # GitHub Actions passes inputs as INPUT_<NAME>
        inputs[key[6:].lower()] = value  # Convert to lowercase for consistency

# Write variables to GitHub Outputs
github_output_path = os.getenv("GITHUB_OUTPUT")
if github_output_path:
    with open(github_output_path, "a") as output_file:
        for key, value in inputs.items():
            output_file.write(f"{key}={value}\n")

# Debugging: Print final variables
print("Final Variables Set:")
for key, value in inputs.items():
    print(f"{key}={value}")
