#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y

hostnamectl set-hostname AWS_Bastion
sed -i 's/ localhost/& AWS_Bastion/' /etc/hosts

test -d ~/snap
if [ $? -eq  1 ]; then
    sudo apt-get install snap -y
    sudo snap install amazon-ssm-agent --classic
    sudo systemctl stop snap.amazon-ssm-agent.amazon-ssm-agent.service
    sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
    sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
else
    sudo systemctl stop snap.amazon-ssm-agent.amazon-ssm-agent.service
    sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
    sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
fi