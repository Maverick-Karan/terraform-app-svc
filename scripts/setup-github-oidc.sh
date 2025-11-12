#!/bin/bash

# Script to setup GitHub OIDC provider and IAM role in AWS
# Usage: ./setup-github-oidc.sh <environment> <github-org> <github-repo>
# Example: ./setup-github-oidc.sh dev myorg myrepo

set -e

if [ $# -ne 3 ]; then
    echo "Usage: $0 <environment> <github-org> <github-repo>"
    echo "Example: $0 dev myorg terraform-app-svc"
    exit 1
fi

ENV=$1
GITHUB_ORG=$2
GITHUB_REPO=$3
ROLE_NAME="github-actions-tf-${ENV}"

echo "========================================="
echo "Setting up GitHub OIDC for: $ENV"
echo "GitHub Repo: ${GITHUB_ORG}/${GITHUB_REPO}"
echo "========================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first."
    exit 1
fi

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "📋 AWS Account ID: $ACCOUNT_ID"

# Create OIDC provider
echo ""
echo "🔐 Creating GitHub OIDC provider..."
OIDC_PROVIDER_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN" 2>/dev/null; then
    echo "✅ OIDC provider already exists"
else
    aws iam create-open-id-connect-provider \
        --url https://token.actions.githubusercontent.com \
        --client-id-list sts.amazonaws.com \
        --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
        --tags Key=Environment,Value="$ENV" Key=ManagedBy,Value=Manual
    echo "✅ OIDC provider created"
fi

# Create trust policy
echo ""
echo "📝 Creating trust policy..."
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${OIDC_PROVIDER_ARN}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF
)

# Create IAM role
echo "🎭 Creating IAM role: $ROLE_NAME"
if aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null; then
    echo "✅ Role already exists, updating trust policy..."
    echo "$TRUST_POLICY" > /tmp/trust-policy.json
    aws iam update-assume-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-document file:///tmp/trust-policy.json
    rm /tmp/trust-policy.json
else
    echo "$TRUST_POLICY" > /tmp/trust-policy.json
    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/trust-policy.json \
        --description "Role for GitHub Actions to manage Terraform in ${ENV}" \
        --tags Key=Environment,Value="$ENV" Key=ManagedBy,Value=Manual
    rm /tmp/trust-policy.json
    echo "✅ Role created"
fi

# Create permissions policy
echo ""
echo "📋 Creating permissions policy..."
POLICY_NAME="terraform-ecr-${ENV}"
PERMISSIONS_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRFullAccess",
      "Effect": "Allow",
      "Action": [
        "ecr:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3StateManagement",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::company-tfstate-${ENV}",
        "arn:aws:s3:::company-tfstate-${ENV}/*"
      ]
    },
    {
      "Sid": "DynamoDBStateLocking",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/company-tf-locks-${ENV}"
    },
    {
      "Sid": "KMSAccess",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF
)

# Check if policy exists
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"
if aws iam get-policy --policy-arn "$POLICY_ARN" 2>/dev/null; then
    echo "✅ Policy already exists"
else
    echo "$PERMISSIONS_POLICY" > /tmp/permissions-policy.json
    aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document file:///tmp/permissions-policy.json \
        --description "Permissions for Terraform to manage ECR in ${ENV}"
    rm /tmp/permissions-policy.json
    echo "✅ Policy created"
fi

# Attach policy to role
echo ""
echo "🔗 Attaching policy to role..."
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "$POLICY_ARN"
echo "✅ Policy attached"

echo ""
echo "========================================="
echo "✅ GitHub OIDC setup complete!"
echo "========================================="
echo ""
echo "IAM Role ARN:"
echo "  arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
echo ""
echo "Add this to your GitHub Actions workflow:"
echo ""
echo "  - uses: aws-actions/configure-aws-credentials@v4"
echo "    with:"
echo "      role-to-assume: arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
echo "      aws-region: us-east-1"
echo ""
echo "Add this secret to your GitHub repository:"
echo "  AWS_ACCOUNT_ID_${ENV^^}: ${ACCOUNT_ID}"
echo ""

