if apt-get help 
then
	apt-get update;apt-get install wget glibc glibc-dev -y;test -d /opt/src/ec2_monitor || mkdir -p /opt/src/ec2_monitor;cd /opt/src/ec2_monitor
	wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip -O AmazonCloudWatchAgent.zip
        cd /opt/src/ec2_monitor;unzip AmazonCloudWatchAgent.zip
	cd /opt/src/ec2_monitor;bash -x ./install.sh
	/bin/cp /opt/src/ec2_monitor_cloudwatch/amazon-cloudwatch-agent-schema.json /opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json 
	/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json -s;/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -a status || systemctl status amazon-cloudwatch-agent
	
else
	yum install -y glibc glibc-devel wget unzip;test -d /opt/src/ec2_monitor || mkdir -p /opt/src/ec2_monitor;cd /opt/src/ec2_monitor
	wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip -O AmazonCloudWatchAgent.zip
        cd /opt/src/ec2_monitor;unzip AmazonCloudWatchAgent.zip
 	cd /opt/src/ec2_monitor;bash -x ./install.sh
	/bin/cp /opt/src/ec2_monitor_cloudwatch/amazon-cloudwatch-agent-schema.json /opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json 
        /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json -s;/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -a status || systemctl status amazon-cloudwatch-agent
fi
