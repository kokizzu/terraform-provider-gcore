---
# generated by https://github.com/hashicorp/terraform-plugin-docs
page_title: "gcore_storage_s3 Data Source - terraform-provider-gcore"
subcategory: ""
description: |-
  Represent s3 storage resource. https://storage.gcore.com/storage/list
---

# gcore_storage_s3 (Data Source)

Represent s3 storage resource. https://storage.gcore.com/storage/list

## Example Usage

```terraform
provider gcore {
  permanent_api_token = "251$d3361.............1b35f26d8"
}

data "gcore_storage_s3" "example_s3" {
  name = "example"
}
```

<!-- schema generated by tfplugindocs -->
## Schema

### Optional

- `name` (String) A name of new storage resource.
- `storage_id` (Number) An id of new storage resource.

### Read-Only

- `client_id` (Number) An client id of new storage resource.
- `generated_endpoint` (String) A s3 entry point for new storage resource.
- `generated_http_endpoint` (String) A http s3 entry point for new storage resource.
- `generated_s3_endpoint` (String) A s3 endpoint for new storage resource.
- `id` (String) The ID of this resource.
- `location` (String) A location of new storage resource. One of (s-ed1, s-darz, s-darz1, s-ws1, s-dt2, s-drc2)
