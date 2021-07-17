#define ami
data "aws_ami" "example" {
  executable_users = ["self"]
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["********"]
  }

}

resource "aws_key" "pair" {
  key_name = "pair"
  public_key = "********8"
}


#define autosscaling launch config

resource "aws_launch_configuration" "as_conf" {
  name          = "as_conf"
  image_id      = data.aws_ami.example.id
  instance_type = var.instance

}
#define autoscaling group
resource "aws_autoscaling_group" "scale" {
  name                      = "scale"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.my_subnet.id]
}
#define autoscaling configuration policy
resource "aws_autoscaling_policy" "pol" {
  name                   = "pol"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.scale.name
}
#define cloud watch monitoring
resource "aws_cloudwatch_metric_alarm" "cloud" {
  alarm_name          = "cloud"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.scale.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.pol.arn]
}
#define auto descaling policy

resource "aws_autoscaling_policy" "down" {
  name                   = "down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.scale.name
}
#define descaling cloudwatch
resource "aws_cloudwatch_metric_alarm" "cloud" {
  alarm_name          = "cloud"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.scale.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.pol.arn]
}