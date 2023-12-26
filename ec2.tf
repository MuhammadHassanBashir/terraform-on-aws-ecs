#resource "aws_iam_role" "ecsInstanceRole" {
#  name = "ecsInstanceRole"
  
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Principal": {
#        "Service": "ec2.amazonaws.com"
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#EOF
#}

# Attach policies to the IAM role as needed (e.g., AmazonEC2ContainerServiceforEC2Role)
#resource "aws_iam_role_policy_attachment" "ecsInstanceRoleAttachment" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceforEC2Role"
#  role       = aws_iam_role.ecsInstanceRole.name
#}



################################## ec2-template ################################

resource "aws_launch_template" "ecs_lt" {
 name_prefix   = "ecs-template"
 image_id      = "ami-079db87dc4c10ac91" #Amazon Linux AMI 2023
 instance_type = "t2.micro"

 key_name               = "Terraform-new"
 vpc_security_group_ids = [aws_security_group.security_group.id]
 iam_instance_profile {
   name = "ecsInstanceRole"
 }

 block_device_mappings {
   device_name = "/dev/xvda"
   ebs {
     volume_size = 30
     volume_type = "gp2"
   }
 }

 tag_specifications {
   resource_type = "instance"
   tags = {
     Name = "ecs-instance"
   }
 }

 user_data = filebase64("${path.module}/ecs.sh")
}

################################## ecs instance autoscaler ################################
resource "aws_autoscaling_group" "ecs_asg" {
 vpc_zone_identifier = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
 desired_capacity    = 2
 max_size            = 2
 min_size            = 1

 launch_template {
   id      = aws_launch_template.ecs_lt.id
   version = "$Latest"
 }

 tag {
   key                 = "AmazonECSManaged"
   value               = true
   propagate_at_launch = true
 }
}
