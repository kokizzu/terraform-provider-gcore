---
# generated by https://github.com/hashicorp/terraform-plugin-docs
page_title: "gcore_waap_security_insight_type Data Source - terraform-provider-gcore"
subcategory: ""
description: |-
  Represent WAAP security insight type
---

# gcore_waap_security_insight_type (Data Source)

Represent WAAP security insight type

## Example Usage

```terraform
provider gcore {
  permanent_api_token = "251$d3361.............1b35f26d8"
}

data "gcore_waap_security_insight_type" "attack_on_disabled_policy" {
  name = "Attack on disabled policy"
}

output "insight_type" {
  value = data.gcore_waap_security_insight_type.attack_on_disabled_policy.id
}
```

<!-- schema generated by tfplugindocs -->
## Schema

### Required

- `name` (String) The name of the insight type

### Read-Only

- `id` (String) The ID of this resource.
