output "aws_ec2_transit_gateway_peering_attachment_id" {
  value       = join("", aws_ec2_transit_gateway_peering_attachment.tgw_peering.*.id)
  description = "Transit Gateway Peering Attachment ID"
}
