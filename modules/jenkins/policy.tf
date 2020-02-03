# Create an IAM role for eks kubectl
resource "aws_iam_role" "eks-full" {
  description = "Accessing all of account EKS cluster API endpoints"
  name               = "opsschool-eks-full"
  assume_role_policy = file("./policy/assume-policy.json")
}

# Create the policy
resource "aws_iam_policy" "eks-full" {
  description = "EKS Full access policy"
  name        = "opsschool-eks-full"
  policy      = file("./policy/eks-full.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "eks-full" {
  name       = "opsschool-eks-full"
  roles      = [aws_iam_role.eks-full.name]
  policy_arn = aws_iam_policy.eks-full.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "eks-kubectl" {
  name  = "opsschool-eks-full"
  role = aws_iam_role.eks-full.name
}