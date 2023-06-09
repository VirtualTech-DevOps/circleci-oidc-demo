locals {
  id_provider = "https://oidc.circleci.com/org/${var.circleci_org_id}"
  aws_region  = "ap-northeast-1"
}

provider "aws" {
  region = local.aws_region
}

resource "aws_iam_openid_connect_provider" "circleci" {
  url             = local.id_provider
  thumbprint_list = [data.tls_certificate.circleci.certificates[0].sha1_fingerprint]
  client_id_list  = [var.circleci_org_id]
}

data "tls_certificate" "circleci" {
  url = "${local.id_provider}/.well-known/openid-configuration"
}

resource "aws_iam_role" "circleci" {
  assume_role_policy = data.aws_iam_policy_document.assume.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.circleci.arn]
    }
  }
}
