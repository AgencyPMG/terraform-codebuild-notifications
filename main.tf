resource "aws_sns_topic" "builds" {
    name = "${var.topic_name}"
}

resource "aws_cloudwatch_event_rule" "builds" {
    name = "codebuild-to-${var.topic_name}"
    event_pattern = <<PATTERN
{
    "source": ["aws.codebuild"]
    "detail-type": ["CodeBuild Build State Change"]
    "detail": {
        "build-status": [
            "IN_PROGRESS",
            "SUCCEEDED", 
            "FAILED",
            "STOPPED",
        ]
    }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "builds" {
    target_id = "codebuild-to-${var.topic_name}"
    rule = "${aws_cloudwatch_event_rule.builds.name}"
    arn = "${aws_sns_topic.builds.arn}"
}
