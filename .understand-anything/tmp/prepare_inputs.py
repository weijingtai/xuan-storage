import json
import os

batches_path = "/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.understand-anything/intermediate/batches.json"
project_root = "/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage"
output_dir = "/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.understand-anything/tmp/batch-inputs"

with open(batches_path, 'r') as f:
    data = json.load(f)

for batch in data['batches']:
    idx = batch['batchIndex']
    if idx in [9, 10, 11, 12]:
        input_data = {
            "projectRoot": project_root,
            "batchFiles": batch['files'],
            "batchImportData": batch['batchImportData']
        }
        with open(os.path.join(output_dir, f"batch-{idx}-input.json"), 'w') as f_out:
            json.dump(input_data, f_out, indent=2)
