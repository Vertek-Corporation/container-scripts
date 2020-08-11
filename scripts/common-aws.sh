# Finds the major version number of the AWS CLI.  For example, "1" or "2".
function get_aws_major_version {
    echo $(aws --version 2>&1 | sed -E 's/aws-cli\/([0-9]).*/\1/')
}

# Returns true if the major version of the AWS CLI is greater than 2.  Soley
# for syntactic sugar.
function is_aws_version_two_or_later {
    if [[ $(get_aws_major_version) -ge "2" ]]; then
        return;
    fi
    false
}

# Authenticates to the AWS ECR.  This method of authenticating requires version
# two or later of the AWS CLI.  
function aws_ecr_login {
    if is_aws_version_two_or_later; then
		local aws_ecr_passwd=`aws ecr get-login-password --profile $env`
		echo $aws_ecr_passwd | docker login --username AWS \
                        --password-stdin $repo
	else
        aws_ecr_login_v1
	fi
}

# Authenticates to the AWS ECR.  This method of authenticating is deprecated.  
# It's insecure to pass the password directly on the command line to docker.
function aws_ecr_login_v1 {
	eval `aws ecr get-login --profile $env --no-include-email`
}