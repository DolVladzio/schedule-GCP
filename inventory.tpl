[all:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

project_id=${project_id}
jenkins_cluster_name=${jenkins_cluster_name}
jenkins_cluster_region=${jenkins_cluster_region}
repo_name=${repo_name}
gcr_name=${gcr_name}
service_account_email=${service_account_email}
github_user=${github_user}
github_auth_token=${github_auth_token}

db_host=${db_host}
db_user=${db_user}
db_password=${db_password}
db_port=${db_port}
db_name=${db_name}
cloud_sql_instance=${cloud_sql_instance}
%{ for name, ip in static_ips }
${name}=${ip}
%{ endfor }
[bastion_host]
bastion ansible_host=${bastion_host}
