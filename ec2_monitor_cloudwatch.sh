if apt-get help 
then
	apt-get update;apt-get install wget glibc glibc-dev -y;test -d /opt/src/ec2_monitor || mkdir -p /opt/src/ec2_monitor;cd /opt/src/ec2_monitor
	wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip -O AmazonCloudWatchAgent.zip
        cd /opt/src/ec2_monitor;unzip AmazonCloudWatchAgent.zip
	cat >> /opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json <<EOF
'{
  "agent": {
    "metrics_collection_interval": 300,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 300
      },
      "disk": {
        "measurement": [
          "total",
          "used",
          "used_percent"
        ],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    }
  }
}'
EOF

	cd /opt/src/ec2_monitor;bash -x ./install.sh
	/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json -s;/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -a status || systemctl status amazon-cloudwatch-agent
	
else
	yum install -y glibc glibc-devel wget unzip;test -d /opt/src/ec2_monitor || mkdir -p /opt/src/ec2_monitor;cd /opt/src/ec2_monitor
	wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip -O AmazonCloudWatchAgent.zip
        cd /opt/src/ec2_monitor;unzip AmazonCloudWatchAgent.zip
        cat >> /opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json <<EOF
'{
  "agent": {
    "metrics_collection_interval": 300,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 300
      },
      "disk": {
        "measurement": [
          "total",
          "used",
          "used_percent"
        ],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    }
  }
}'
EOF

 	cd /opt/src/ec2_monitor;bash -x ./install.sh
        /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json -s;/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -a status || systemctl status amazon-cloudwatch-agent
fi
