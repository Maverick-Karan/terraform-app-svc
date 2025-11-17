# IRSA (IAM Roles for Service Accounts) configuration

# OIDC Provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = var.tags
}

# IRSA Role for service accounts
resource "aws_iam_role" "irsa" {
  for_each = var.irsa_roles

  name = "${var.cluster_name}-irsa-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-irsa-${each.key}"
  })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = var.irsa_roles

  role       = aws_iam_role.irsa[each.key].name
  policy_arn = each.value.policy_arn
}

