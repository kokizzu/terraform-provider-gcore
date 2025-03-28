---
page_title: "gcore_inference_deployment Resource - terraform-provider-gcore"
subcategory: ""
description: |-
  Represent inference deployment
---

# gcore_inference_deployment (Resource)

Represent inference deployment

## Example Usage

##### Prerequisite

```terraform
provider gcore {
  permanent_api_token = "251$d3361.............1b35f26d8"
}

data "gcore_project" "project" {
  name = "Default"
}

data "gcore_region" "region" {
  name = "Luxembourg-2"
}
```

### Basic example

#### Creating inference deployment

```terraform
resource "gcore_inference_deployment" "inf" {
  project_id = data.gcore_project.project.id
  name = "my-inference-deployment"
  image = "nginx:latest"
  listening_port = 80
  flavor_name = "inference-4vcpu-16gib"
  containers {
    region_id  = data.gcore_region.region.id
    scale_min = 2
    scale_max = 2
    triggers_cpu_threshold = 80
  }

  # If you don't specify any probe, the container may be marked as "ready" too soon,
  # meaning it will start accepting requests before your application has fully initialized.
  # This can lead to errors, as the app might not be prepared to handle incoming traffic yet.
  liveness_probe {
    enabled = true
    failure_threshold = 3
    initial_delay_seconds = 10
    period_seconds = 10
    timeout_seconds = 1
    success_threshold = 1
    http_get_port = 80
    http_get_headers = {
      User-Agent = "my user agent"
    }
    http_get_host = "localhost"
    http_get_path = "/"
    http_get_schema = "HTTPS"
  }

  readiness_probe {
    enabled = false
  }

  startup_probe {
    enabled = false
  }
}
```

#### Creating inference deployment with sqs trigger

```terraform
resource "gcore_inference_secret" "aws" {
  project_id = data.gcore_project.project.id
  name = "my-aws-iam-secret"
  data_aws_access_key_id = "my-aws-access-key-id"
  data_aws_secret_access_key = "my-aws-access-key"
}

resource "gcore_inference_deployment" "inf" {
  project_id = data.gcore_project.project.id
  name = "my-inference-deployment"
  image = "nginx:latest"
  listening_port = 80
  flavor_name = "inference-4vcpu-16gib"
  timeout = 60
  containers {
    region_id  = data.gcore_region.region.id
    cooldown_period = 60
    polling_interval = 60
    scale_min = 0
    scale_max = 2
    triggers_cpu_threshold = 80

    triggers_sqs_secret_name = gcore_inference_secret.aws.name
    triggers_sqs_aws_region = "us-west-2"
    triggers_sqs_queue_url = "https://sqs.us-west-2.amazonaws.com/1234567890/my-queue"
    triggers_sqs_queue_length = 5
    triggers_sqs_activation_queue_length = 2
  }

  liveness_probe {
    enabled = false
  }

  readiness_probe {
    enabled = false
  }

  startup_probe {
    enabled = false
  }
}
```

<!-- schema generated by tfplugindocs -->
## Schema

### Required

- `containers` (Block List, Min: 1) A required list of container definitions. Each entry represents a container configuration, and at least one container must be specified. See the nested schema below for further details. (see [below for nested schema](#nestedblock--containers))
- `flavor_name` (String) Specifies the resource flavor for the container, determining its allocated CPU, memory, and potentially GPU resources.
- `image` (String) The container image to be used for deployment. This should be a valid image reference, such as a public or private Docker image (registry.example.com/my-image:latest). Note: If the image is hosted in a private registry, you must specify credentials_name to provide authentication details.
- `listening_port` (Number) The port on which the container will accept incoming traffic. This should match the port your application is configured to listen on within the container.
- `name` (String) The name of the deployment. This should be unique within the scope of the project.

### Optional

- `auth_enabled` (Boolean) Set to true to enable API key authentication for the inference instance.
- `command` (String) Command to be executed when running a container from an image.
- `credentials_name` (String) Required if using a private image registry. Specifies the name of the credentials to authenticate with the registry where the container image is stored.
- `description` (String)
- `envs` (Map of String) Environment variables for the inference instance.
- `liveness_probe` (Block List, Max: 1) (see [below for nested schema](#nestedblock--liveness_probe))
- `logging` (Block List, Max: 1) (see [below for nested schema](#nestedblock--logging))
- `project_id` (Number)
- `project_name` (String)
- `readiness_probe` (Block List, Max: 1) (see [below for nested schema](#nestedblock--readiness_probe))
- `startup_probe` (Block List, Max: 1) (see [below for nested schema](#nestedblock--startup_probe))
- `timeout` (Number)

### Read-Only

- `address` (String) The address of the inference deployment. This is the URL that clients can use to access the inference deployment. This field is only populated when the deployment is in the RUNNING state. To retrieve the address after deployment, you may need to run terraform refresh.
- `created_at` (String) Datetime when the inference deployment was created. The format is 2025-12-28T19:14:44.180394
- `id` (String) The ID of this resource.
- `status` (String)

<a id="nestedblock--containers"></a>
### Nested Schema for `containers`

Required:

- `cooldown_period` (Number) Cooldown period between scaling actions in seconds
- `region_id` (Number) Region id for the container
- `scale_max` (Number) Maximum scale for the container
- `scale_min` (Number) Minimum scale for the container. It can be set to 0, in which case the container will be downscaled to 0 when there is no load.

Optional:

- `polling_interval` (Number) Polling interval for scaling triggers in seconds
- `triggers_cpu_threshold` (Number) CPU trigger threshold configuration
- `triggers_gpu_memory_threshold` (Number) GPU memory trigger threshold configuration. Calculated by DCGM_FI_DEV_MEM_COPY_UTIL metric
- `triggers_gpu_utilization_threshold` (Number) GPU utilization trigger threshold configuration. Calculated by DCGM_FI_DEV_GPU_UTIL metric
- `triggers_http_rate` (Number) Request count per 'window' seconds for the http trigger. Required if you use http trigger
- `triggers_http_window` (Number) Time window for rate calculation in seconds. Required if you use http trigger
- `triggers_memory_threshold` (Number) Memory trigger threshold configuration
- `triggers_sqs_activation_queue_length` (Number) Number of messages for activation
- `triggers_sqs_aws_endpoint` (String) Custom AWS endpoint, left empty to use default aws endpoint
- `triggers_sqs_aws_region` (String) AWS region. Required if you use SQS trigger
- `triggers_sqs_queue_length` (Number) Number of messages for one replica
- `triggers_sqs_queue_url` (String) URL of the SQS queue. Required if you use SQS trigger
- `triggers_sqs_scale_on_delayed` (Boolean) Scale on delayed messages
- `triggers_sqs_scale_on_flight` (Boolean) Scale on in-flight messages
- `triggers_sqs_secret_name` (String) Name of the secret with AWS credentials. Required if you use SQS trigger

Read-Only:

- `ready_containers` (Number) Status of the containers deployment. Number of ready instances
- `total_containers` (Number) Status of the containers deployment. Total number of instances


<a id="nestedblock--liveness_probe"></a>
### Nested Schema for `liveness_probe`

Required:

- `enabled` (Boolean) Enable or disable probe

Optional:

- `exec_command` (String) Command to execute in the container to determine the health
- `failure_threshold` (Number) Number of failed probes before the container is considered unhealthy
- `http_get_headers` (Map of String) HTTP headers to use when sending a HTTP GET request, valid only for HTTP probes
- `http_get_host` (String) Host name to connect to, valid only for HTTP probes
- `http_get_path` (String) Path to access on the HTTP server, valid only for HTTP probes
- `http_get_port` (Number) Number of the port to access on the HTTP server, valid only for HTTP probes
- `http_get_schema` (String) Scheme to use for connecting to the host, valid only for HTTP probes
- `initial_delay_seconds` (Number) Number of seconds after the container has started before liveness probes are initiated
- `period_seconds` (Number) How often (in seconds) to perform the probe
- `success_threshold` (Number) Minimum consecutive successes for the probe to be considered successful after having failed
- `tcp_socket_port` (Number) Port to connect to
- `timeout_seconds` (Number) Number of seconds after which the probe times out


<a id="nestedblock--logging"></a>
### Nested Schema for `logging`

Optional:

- `destination_region_id` (Number)
- `enabled` (Boolean)
- `retention_policy_period` (Number)
- `topic_name` (String)


<a id="nestedblock--readiness_probe"></a>
### Nested Schema for `readiness_probe`

Required:

- `enabled` (Boolean) Enable or disable probe

Optional:

- `exec_command` (String) Command to execute in the container to determine the health
- `failure_threshold` (Number) Number of failed probes before the container is considered unhealthy
- `http_get_headers` (Map of String) HTTP headers to use when sending a HTTP GET request, valid only for HTTP probes
- `http_get_host` (String) Host name to connect to, valid only for HTTP probes
- `http_get_path` (String) Path to access on the HTTP server, valid only for HTTP probes
- `http_get_port` (Number) Number of the port to access on the HTTP server, valid only for HTTP probes
- `http_get_schema` (String) Scheme to use for connecting to the host, valid only for HTTP probes
- `initial_delay_seconds` (Number) Number of seconds after the container has started before liveness probes are initiated
- `period_seconds` (Number) How often (in seconds) to perform the probe
- `success_threshold` (Number) Minimum consecutive successes for the probe to be considered successful after having failed
- `tcp_socket_port` (Number) Port to connect to
- `timeout_seconds` (Number) Number of seconds after which the probe times out


<a id="nestedblock--startup_probe"></a>
### Nested Schema for `startup_probe`

Required:

- `enabled` (Boolean) Enable or disable probe

Optional:

- `exec_command` (String) Command to execute in the container to determine the health
- `failure_threshold` (Number) Number of failed probes before the container is considered unhealthy
- `http_get_headers` (Map of String) HTTP headers to use when sending a HTTP GET request, valid only for HTTP probes
- `http_get_host` (String) Host name to connect to, valid only for HTTP probes
- `http_get_path` (String) Path to access on the HTTP server, valid only for HTTP probes
- `http_get_port` (Number) Number of the port to access on the HTTP server, valid only for HTTP probes
- `http_get_schema` (String) Scheme to use for connecting to the host, valid only for HTTP probes
- `initial_delay_seconds` (Number) Number of seconds after the container has started before liveness probes are initiated
- `period_seconds` (Number) How often (in seconds) to perform the probe
- `success_threshold` (Number) Minimum consecutive successes for the probe to be considered successful after having failed
- `tcp_socket_port` (Number) Port to connect to
- `timeout_seconds` (Number) Number of seconds after which the probe times out





## Import

Import is supported using the following syntax:

```shell
# import using <project_id>:<inference_deployment_name> format
terraform import gcore_inference_deployment.inf1 1:my-first-inference
```

