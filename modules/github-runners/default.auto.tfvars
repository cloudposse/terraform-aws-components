enabled = false

name = "gh-runner"

wait_for_capacity_timeout = "10m"

block_device_mappings = [
  {
    "device_name" : "/dev/xvda",
    "no_device" : null,
    "virtual_name" : null,
    "ebs" : {
      "delete_on_termination" : null,
      "encrypted" : false,
      "iops" : null,
      "kms_key_id" : null,
      "snapshot_id" : null,
      "volume_size" : 100,
      "volume_type" : "gp2"
    }
  }
]
