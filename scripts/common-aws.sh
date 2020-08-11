function is_aws_version_two_or_later {
    local aws_version=`aws --version 2>&1 | sed -E 's/aws-cli\/([0-9]).*/\1/'`
	
	if [[ "$aws_version" -ge "2" ]]; then
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
		eval `aws ecr get-login --profile $env --no-include-email`
	fi
}