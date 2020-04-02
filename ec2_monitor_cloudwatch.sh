if apt-get help 
then
	apt-get update;apt-get install wget glibc glibc-dev -y;test -d /opt/src/ec2_monitor || mkdir -p /opt/src/ec2_monitor;cd /opt/src/ec2_monitor;rm -f /opt/src/ec2_monitor/*
	wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip
        cd /opt/src/ec2_monitor;unzip AmazonCloudWatchAgent.zip
	cat >> /opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json <<EOF
{
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
}
EOF
	cat > detect-system.sh <<EOF
# Copyright 2017 Amazon.com, Inc. and its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#   http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

detect_system() {

    set +e
    rpmbin="$(which rpm 2>/dev/null)"
    found="$?"
    set -e
    if [ "${found}" -eq 0 ]; then
        # we have rpm binary, but was rpm used to install it?
	if rpm -qf "${rpmbin}" >/dev/null 2>&1; then
	    echo 'rpm'
	    return 0
	fi
    fi

    set +e
    dpkgbin="$(which dpkg 2>/dev/null)"
    found="$?"
    set -e
    if [ "${found}" -eq 0 ]; then
        # we have dpkg binary, but was dpkg used to install it?
	if dpkg-query -S "${dpkgbin}" >/dev/null 2>&1; then
	    echo 'dpkg'
	    return 0
	fi
    fi

    echo 'unknown'
    return 0
}
EOF

	cd /opt/src/ec2_monitor;bash -x ./install.sh
	/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json -s;/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -a status || systemctl status amazon-cloudwatch-agent
	
else
	yum install -y glibc glibc-devel wget unzip;test -d /opt/src/ec2_monitor || mkdir -p /opt/src/ec2_monitor;cd /opt/src/ec2_monitor;rm -f /opt/src/ec2_monitor/*
	wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip
        cd /opt/src/ec2_monitor;unzip AmazonCloudWatchAgent.zip
        cat >> /opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json <<EOF
{
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
}
EOF

	cat > detect-system.sh <<EOF
# Copyright 2017 Amazon.com, Inc. and its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#   http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

detect_system() {

    set +e
    rpmbin="$(which rpm 2>/dev/null)"
    found="$?"
    set -e
    if [ "${found}" -eq 0 ]; then
        # we have rpm binary, but was rpm used to install it?
        if rpm -qf "${rpmbin}" >/dev/null 2>&1; then
            echo 'rpm'
            return 0
        fi
    fi

    set +e
    dpkgbin="$(which dpkg 2>/dev/null)"
    found="$?"
    set -e
    if [ "${found}" -eq 0 ]; then
        # we have dpkg binary, but was dpkg used to install it?
        if dpkg-query -S "${dpkgbin}" >/dev/null 2>&1; then
            echo 'dpkg'
            return 0
        fi
    fi

    echo 'unknown'
    return 0
}
EOF
 	cd /opt/src/ec2_monitor;bash -x ./install.sh
        /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/doc/amazon-cloudwatch-agent-schema.json -s;/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -a status || systemctl status amazon-cloudwatch-agent
fi
