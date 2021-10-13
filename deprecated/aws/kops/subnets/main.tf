# Read more: <http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/>

data "null_data_source" "subnets" {
  count = "${var.subnet_count}"

  inputs = {
    cidr = "${cidrsubnet(var.iprange, var.newbits, var.netnum + count.index)}"
  }
}
