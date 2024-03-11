#IAM role named "ReadOnlyS3AccessRole"
#This role will have a trust policy allowing any IAM user within your account to assume it.
#The AWS-managed policy "AmazonS3ReadOnlyAccess" will be attached to the role, granting it read-only access to S3 resources.
#Custom Policy for Role Assumption:

#Custom IAM policy named "AssumeReadOnlyS3RolePolicy"
#This policy allows IAM users to perform the "sts:AssumeRole" action specifically on the "ReadOnlyS3AccessRole".
#The policy will target the ARN (unique identifier) of the "ReadOnlyS3AccessRole".

#IAM user named "S3ReadOnlyUser" 

#The "AssumeReadOnlyS3RolePolicy" will be attached to this user.
#This allows the user to assume the "ReadOnlyS3AccessRole", indirectly granting them read-only access to S3.

#Output the ARN of the "ReadOnlyS3AccessRole".

#Output the name of the IAM user, "S3ReadOnlyUser".
