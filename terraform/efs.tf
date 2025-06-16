# resource "aws_efs_file_system" "fusionauth_efs" {
#   creation_token   = "fusionauth-efs"
#   performance_mode = "generalPurpose"
# }

# resource "aws_efs_mount_target" "fusionauth_mount_target_az1" {
#   file_system_id  = aws_efs_file_system.fusionauth_efs.id
#   subnet_id       = module.vpc.private_subnets[0]
#   security_groups = [aws_security_group.fusionauth_sg.id]
# }

# resource "aws_efs_mount_target" "fusionauth_mount_target_az2" {
#   file_system_id  = aws_efs_file_system.fusionauth_efs.id
#   subnet_id       = module.vpc.private_subnets[1]
#   security_groups = [aws_security_group.fusionauth_sg.id]
# }
# # EFS Access Point
# resource "aws_efs_access_point" "fusionauth_efs_ap" {
#   file_system_id = aws_efs_file_system.fusionauth_efs.id

#   posix_user {
#     gid = 0
#     uid = 0
#   }

#   root_directory {
#     path = "/"
#     creation_info {
#       owner_gid   = 0
#       owner_uid   = 0
#       permissions = "0755"
#     }
#   }

#   tags = {
#     Name = "${local.name_prefix}-fusionauth-efs-ap"
#   }
# }
