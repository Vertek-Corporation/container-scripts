function get_aws_major_version {
    echo $(aws --version 2>&1 | sed -E 's/aws-cli\/([0-9]).*/\1/')
}

function is_aws_version_two_or_later {
	if [[ $(get_aws_major_version) -ge "2" ]]; then
        return;
    fi
	false
}

function aws_ecr_login {
    if is_aws_version_two_or_later; then
		local aws_ecr_passwd=`aws ecr get-login-password --profile $env`
		echo $aws_ecr_passwd | docker login --username AWS \
                        --password-stdin $repo
	else
        aws_ecr_login_v1
	fi
}

function aws_ecr_login_v1 {
	eval `aws ecr get-login --profile $env --no-include-email`
}