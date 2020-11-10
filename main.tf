resource "aws_sns_topic" "builds" {
  name = var.topic_name
}

data "aws_iam_policy_document" "builds" {
  statement {
    sid       = "TrustCloudWatchEvents"
    effect    = "Allow"
    resources = [aws_sns_topic.builds.arn]
    actions   = ["sns:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_sns_topic_policy" "builds_events" {
  arn    = aws_sns_topic.builds.arn
  policy = data.aws_iam_policy_document.builds.json
}

resource "aws_cloudwatch_event_rule" "builds" {
  name          = "codebuild-to-${var.topic_name}"
  event_pattern = <<PATTERN
{
    "source": ["aws.codebuild"],
    "detail-type": ["CodeBuild Build State Change"],
    "detail": {
        "build-status": [
            "IN_PROGRESS",
            "SUCCEEDED", 
            "FAILED",
            "STOPPED"
        ]
    }
}
PATTERN

}

resource "aws_cloudwatch_event_target" "builds" {
  target_id = "codebuild-to-${var.topic_name}"
  rule      = aws_cloudwatch_event_rule.builds.name
  arn       = aws_sns_topic.builds.arn
}
