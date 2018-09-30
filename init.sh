#!/bin/sh 

DOCKER_MAJOR_VER=17
DOCKER_MINOR_VER=06
OC_MAJOR_VER="v3"
OC_MINOR_VER=7
OC_MINI_VER=9
OCP_VERSION="$OC_MAJOR_VER.$OC_MINOR_VER"
ISO_URL="https://github.com/boot2docker/boot2docker/releases/download/v1.13.1/boot2docker.iso"
ISO_CACHE="file://$HOME/.docker/machine/cache/boot2docker.iso"
VIRT_DRIVER="virtualbox"
STREAM_BRMS_63="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/decisionserver63-image-stream.json"
STREAM_BRMS_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/decisionserver64-image-stream.json"
STREAM_EAP_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/eap64-image-stream.json"
STREAM_EAP_70="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/eap70-image-stream.json"
STREAM_EAP_71="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/eap71-image-stream.json"
STREAM_FUSE="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/fis-image-streams.json"
STREAM_OPENJDK18="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/openjdk18-image-stream.json"
STREAM_BPMS_63="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/processserver63-image-stream.json"
STREAM_BPMS_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/processserver64-image-stream.json"
STREAM_DOTNET="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/image-streams/dotnet_imagestreams.json"
STREAM_RHEL="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/image-streams/image-streams-rhel7.json"
TEMPLATE_EAP70="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/eap71-basic-s2i.json"
TEMPLATE_EAP71="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/eap71-basic-s2i.json"
TEMPLATE_BRMS_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/decisionserver64-basic-s2i.json"
TEMPLATE_BPM_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/processserver64-postgresql-s2i.json"
TEMPLATE_BPM_DB_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/processserver64-postgresql-persistent-s2i.json"

# uncomment amount memory needed, sets RAM usage limit for OCP, default 6 GB.
#VM_MEMORY=10240    # 10GB
VM_MEMORY=9000    # 8GB
#VM_MEMORY=6144     # 6GB
#VM_MEMORY=4098     # 4GB
#VM_MEMORY=3072     # 3GB

# wipe screen.
clear 

echo
echo "##############################################################"
echo "##                                                          ##"   
echo "##  Setting up your very own                                ##"
echo "##                                                          ##"   
echo "##    ###  ####  ##### #   #  #### #   # ##### ##### #####  ##"
echo "##   #   # #   # #     ##  # #     #   #   #   #       #    ##"
echo "##   #   # ####  ###   # # #  ###  #####   #   ####    #    ##"
echo "##   #   # #     #     #  ##     # #   #   #   #       #    ##"
echo "##    ###  #     ##### #   # ####  #   # ##### #       #    ##"
echo "##                                                          ##"   
echo "##    ####  ###  #   # #####  ###  ##### #   # ##### #####  ##"
echo "##   #     #   # ##  #   #   #   #   #   ##  # #     #   #  ##"
echo "##   #     #   # # # #   #   #####   #   # # # ###   #####  ##"
echo "##   #     #   # #  ##   #   #   #   #   #  ## #     #  #   ##"
echo "##    ####  ###  #   #   #   #   # ##### #   # ##### #   #  ##"
echo "##                                                          ##"   
echo "##      ####  #      ###  ##### #####  ###  ##### #   #     ##"   
echo "##      #   # #     #   #   #   #     #   # #   # ## ##     ##"   
echo "##      ####  #     #####   #   ####  #   # ##### # # #     ##"   
echo "##      #     #     #   #   #   #     #   # #  #  #   #     ##"   
echo "##      #     ##### #   #   #   #      ###  #   # #   #     ##"   
echo "##                                                          ##"   
echo "##  https://github.com/redhatdemocentral/ocp-install-demo   ##"
echo "##                                                          ##"   
echo "##############################################################"
echo

# Ensure VirtualBox available.
#
if [ `uname` == 'Darwin' ]; then
		command -v VirtualBox -h >/dev/null 2>&1 || { echo >&2 "VirtualBox is required but not installed yet... download here: https://www.virtualbox.org/wiki/Downloads"; exit 1; }
		echo "VirtualBox is installed..."
		echo
elif [ `uname` == 'Linux' ]; then
		VIRT_DRIVER='kvm'
    echo "You are running on Linux."
    echo "This script assumes you are going to use KVM on Linux."
    echo "You'll need to install docker-machine and docker-machine-driver-kvm in your \$PATH manually."
    echo "Download them from https://github.com/docker/machine/releases and https://github.com/dhiltgen/docker-machine-kvm/releases, respectively."
fi

# Ensure docker-machine tool available.
#
command -v docker-machine -v >/dev/null 2>&1 || { echo >&2 "Docker-machine is required but not installed yet... instructions here: https://docs.docker.com/machine/install-machine/#install-machine-directly"; exit 1; }
echo "Docker-machine tooling installed..."
echo

# Ensure OpenShift command line tools available.
#
command -v oc help >/dev/null 2>&1 || { echo >&2 "OpenShift CLI tooling is required but not installed yet... download $OCP_VERSION here: https://access.redhat.com/downloads/content/290"; exit 1; }
echo "OpenShift command line tools installed... checking for valid version..."
echo

# Check oc version.
verfull=$(oc version | awk '/oc/{print $2}')
verone=$(echo $verfull | awk -F[=.] '{print $1}')
vertwo=$(echo $verfull | awk -F[=.] '{print $2}')
verthree=$(echo $verfull | awk -F[=.] '{print $3}')

# Check version elements, first is a string so using '==', the rest are integers.
#if [ $verone == $OC_MAJOR_VER ] && [ $vertwo -eq $OC_MINOR_VER ] && [ $verthree -ge $OC_MINI_VER ]; then
#	echo "Version of installed OpenShift command line tools correct... $verone.$vertwo.$verthree"
#	echo
#else
#	echo "Version of installed OpenShift command line tools is $verone.$vertwo.$verthree, must be $OC_MAJOR_VER.$OC_MINOR_VER.$OC_MINI_VER..."
#	echo
#	if [ `uname` == 'Darwin' ]; then
#		echo "Download for Mac here: https://access.redhat.com/downloads/content/290"
#		exit
#	else
#		echo "Download for Linux here: https://access.redhat.com/downloads/content/290/"
#		exit
#	fi
#fi

echo "Setting up OpenShift docker machine using $VIRT_DRIVER from cache..."
echo
docker-machine create --driver ${VIRT_DRIVER} --${VIRT_DRIVER}-cpu-count "2" --${VIRT_DRIVER}-memory "$VM_MEMORY" --engine-insecure-registry 172.30.0.0/16 --${VIRT_DRIVER}-boot2docker-url $ISO_CACHE openshift

if [ $? -ne 0 ]; then
		echo
		echo "Error occurred during openshift docker machine creation..."
		echo
		echo "Cleaning out existing 'openshift' machine..."
		echo
		docker-machine rm -f openshift

    echo "Setting up OpenShift docker machine using $VIRT_DRIVER from url..."
    echo
		docker-machine create --driver ${VIRT_DRIVER} --${VIRT_DRIVER}-cpu-count "2" --${VIRT_DRIVER}-memory "$VM_MEMORY" --engine-insecure-registry 172.30.0.0/16 --${VIRT_DRIVER}-boot2docker-url $ISO_URL openshift 

		if [ $? -ne 0 ]; then
				echo
				echo "Problem with docker machine creation that I can't resolve, please raise an issue and add error output:"
				echo
				echo "   https://github.com/redhatdemocentral/ocp-install-demo/issues/new"
				echo
				exit
		fi
fi

echo "Installing OCP with cluster up..."
echo
oc cluster up --image=registry.access.redhat.com/openshift3/ose --host-data-dir=/var/lib/boot2docker/ocp-data --docker-machine=openshift --host-config-dir=/var/lib/boot2docker/ocp-config --use-existing-config=true --version=$OCP_VERSION --host-pv-dir=/var/lib/boot2docker/ocp-pv


if [ $? -ne 0 ]; then
		echo
		echo "Error occurred during 'oc cluster up' command..."
		echo
		echo "Cleaning out existing 'openshift' machine..."
		echo
		docker-machine rm -f openshift

    echo "Setting up OpenShift docker machine using $VIRT_DRIVER from cache..."
    echo
		docker-machine create --driver ${VIRT_DRIVER} --${VIRT_DRIVER}-cpu-count "2" --${VIRT_DRIVER}-memory "$VM_MEMORY" --engine-insecure-registry 172.30.0.0/16 --${VIRT_DRIVER}-boot2docker-url $ISO_CACHE openshift 

		echo
		echo "Trying again to install OCP with cluster up..."
		echo
		echo "Using osX version of cluster up... installing second try OCP version: $OCP_VERSION"
		echo
    oc cluster up --image=registry.access.redhat.com/openshift3/ose --host-data-dir=/var/lib/boot2docker/ocp-data --docker-machine=openshift --host-config-dir=/var/lib/boot2docker/ocp-config --use-existing-config=true --version=$OCP_VERSION --host-pv-dir=/var/lib/boot2docker/ocp-pv

		if [ $? -ne 0 ]; then
				echo
				echo "Problem with installation that I can't resolve, please raise an issue and add error output:"
				echo
				echo "   https://github.com/redhatdemocentral/ocp-install-demo/issues/new"
				echo
				exit
		fi
fi

echo
echo "Logging in as admin user..."
echo
oc login -u system:admin

# capturing OCP IP address from status command.
OCP_IP=$(oc status | awk '/My Project/{print $8}')

echo 
echo "Set OCP IP to $OCP_IP..."
echo

# set console environment to openshift container.
eval "$(docker-machine env openshift)"

echo "Granting admin user full cluster-admin rights..."
echo
oc adm policy add-cluster-role-to-user cluster-admin admin

if [ $? -ne 0 ]; then
	echo
	echo "Problem granting admin user full cluster-admin rights!"
	echo
	exit
fi

echo
echo "Granting rights to service catalog access..."
echo
oc adm policy add-cluster-role-to-group system:openshift:templateservicebroker-client system:unauthenticated system:authenticated

if [ $? -ne 0 ]; then
	echo
	echo "Problem granting service catalog rights!"
	echo
	exit
fi

echo
echo "Updating JBoss image streams..."

# Updating JBoss BRMS 6.3 image stream.
#
oc delete -n openshift -f $STREAM_BRMS_63 >/dev/null 2>&1
oc create -n openshift -f $STREAM_BRMS_63

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss BRMS 63 stream for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_BRMS_63 >/dev/null 2>&1
  oc create -n openshift -f $STREAM_BRMS_63
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating JBoss BPMS 6.3 image stream.
#
oc delete -n openshift -f $STREAM_BPMS_63 >/dev/null 2>&1
oc create -n openshift -f $STREAM_BPMS_63

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss BPMS 63 stream for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_BPMS_63 >/dev/null 2>&1
  oc create -n openshift -f $STREAM_BPMS_63
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating JBoss BRMS 6.4 image stream.
#
oc delete -n openshift -f $STREAM_BRMS_64 >/dev/null 2>&1
oc create -n openshift -f $STREAM_BRMS_64

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss BRMS 64 stream for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_BRMS_64 >/dev/null 2>&1
  oc create -n openshift -f $STREAM_BRMS_64
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating JBoss BPMS 6.4 image stream.
#
oc delete -n openshift -f $STREAM_BPMS_64 >/dev/null 2>&1
oc create -n openshift -f $STREAM_BPMS_64

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss BPMS 64 stream for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_BPMS_64 >/dev/null 2>&1
  oc create -n openshift -f $STREAM_BPMS_64
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating JBoss EAP 7.0 image stream.
#
oc delete -n openshift -f $STREAM_EAP_70 >/dev/null 2>&1
oc create -n openshift -f $STREAM_EAP_70

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss EAP 70 stream for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_EAP_70 >/dev/null 2>&1
  oc create -n openshift -f $STREAM_EAP_70
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating JBoss EAP 7.1 image stream.
oc delete -n openshift -f $STREAM_EAP_71 >/dev/null 2>&1
oc create -n openshift -f $STREAM_EAP_71

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss EAP 71 stream for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_EAP_71 >/dev/null 2>&1
  oc create -n openshift -f $STREAM_EAP_71
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating Fuse image streams.
oc delete -n openshift -f $STREAM_FUSE >/dev/null 2>&1
oc create -n openshift -f $STREAM_FUSE

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing Fuse Integration product streams for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_FUSE >/dev/null 2>&1
  oc create -n openshift -f $STREAM_FUSE
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating OpenJDK18 image stream.
#
oc delete -n openshift -f $STREAM_OPENJDK18 >/dev/null 2>&1
oc create -n openshift -f $STREAM_OPENJDK18

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing OPENJDK18 stream for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_OPENJDK18 >/dev/null 2>&1
  oc create -n openshift -f $STREAM_OPENJDK18
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating EAP 7.0 template.
#
oc delete -n openshift -f $TEMPLATE_EAP70 >/dev/null 2>&1
oc create -n openshift -f $TEMPLATE_EAP70

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss EAP 70 template for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
	oc delete -n openshift -f $TEMPLATE_EAP70 >/dev/null 2>&1
  oc create -n openshift -f $TEMPLATE_EAP70
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating EAP 7.1 template.
#
oc delete -n openshift -f $TEMPLATE_EAP71 >/dev/null 2>&1
oc create -n openshift -f $TEMPLATE_EAP71

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss EAP 71 template for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
	oc delete -n openshift -f $TEMPLATE_EAP71 >/dev/null 2>&1
  oc create -n openshift -f $TEMPLATE_EAP71
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating Decision Server 6.4 template.
#
oc delete -n openshift -f $TEMPLATE_BRMS_64 >/dev/null 2>&1
oc create -n openshift -f $TEMPLATE_BRMS_64

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss BRMS 64 template for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $TEMPLATE_BRMS_64 >/dev/null 2>&1
  oc create -n openshift -f $TEMPLATE_BRMS_64
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating Process Server 6.4 template.
#
oc delete -n openshift -f $TEMPLATE_BPM_64 >/dev/null 2>&1
oc create -n openshift -f $TEMPLATE_BPM_64

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss BPM Suite 64 template for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $TEMPLATE_BPM_64 >/dev/null 2>&1
  oc create -n openshift -f $TEMPLATE_BPM_64
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

# Updating Process Server DB 6.4 template.
#
oc delete -n openshift -f $TEMPLATE_BPM_DB_64 >/dev/null 2>&1
oc create -n openshift -f $TEMPLATE_BPM_DB_64

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing JBoss BPM Suite DB 64 template for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $TEMPLATE_BPM_DB_64 >/dev/null 2>&1
  oc create -n openshift -f $TEMPLATE_BPM_DB_64
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

echo
echo "Updating RHEL 7 image streams..."
oc delete -n openshift -f $STREAM_RHEL >/dev/null 2>&1
oc create -n openshift -f $STREAM_RHEL

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing RHEL product streams for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_RHEL >/dev/null 2>&1
  oc create -n openshift -f $STREAM_RHEL
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

echo
echo "Update .Net image streams..."
oc delete -n openshift -f $STREAM_DOTNET >/dev/null 2>&1
oc create -n openshift -f $STREAM_DOTNET

if [ $? -ne 0 ]; then
	echo
	echo "Problem with accessing .Net image streams for OCP..."
	echo
  echo "Trying again..."
	echo
	sleep 10
  oc delete -n openshift -f $STREAM_DOTNET >/dev/null 2>&1
  oc create -n openshift -f $STREAM_DOTNET
	
	if [ $? -ne 0 ]; then
		echo "Failed again, exiting, check output messages and network connectivity before running install again..."
		echo
		docker-machine rm -f openshift
		exit
	fi
fi

echo
echo "===================================================="
echo "=                                                  ="
echo "= Install complete, get ready to rock your Cloud.  ="
echo "= Look for information at end of OCP install.      ="
echo "=                                                  ="
echo "=  The server is accessible via web console at:    ="
echo "=                                                  ="
echo "=	  $OCP_IP              ="
echo "=                                                  ="
echo "=  Log in as user: openshift-dev                   ="
echo "=        password: devel                           ="
echo "=                                                  ="
echo "=  Admin log in as: admin                          ="
echo "=         password: admin                          ="
echo "=                                                  ="
echo "=  Now get your Red Hat Demo Central example       ="
echo "=  projects here:                                  ="
echo "=                                                  ="
echo "=     https://github.com/redhatdemocentral         ="
echo "=                                                  ="
echo "=  To stop and restart your OCP cluster with       ="
echo "=  installed containers, see Readme.md in the      ="
echo "=  NOTES section for details.                      ="
echo "=                                                  ="
echo "=  When finished, clean up your demo with:         ="
echo "=                                                  ="
echo "=     $ docker-machine rm -f openshift             ="
echo "=                                                  ="
echo "===================================================="
