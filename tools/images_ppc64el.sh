#!/bin/bash -ex
# Download ppc64el images and add to glance.

# Download images if not already present
: ${WGET_MODE}:=""
: ${TEST_IMAGE_URL_XENIAL:="http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-ppc64el-disk1.img"}
: ${TEST_IMAGE_URL_CIRROS:="http://download.cirros-cloud.net/daily/20150923/cirros-d150923-ppc64le-disk.img"}
: ${TEST_IMAGE_NAME_XENIAL:="xenial-ppc64el"}
: ${TEST_IMAGE_NAME_CIRROS:="cirros-ppc64el"}

if [ ! -d ~/images ] ; then
        mkdir -p ~/images
fi

if juju status nova-compute|grep lxd ; then
        openstack image show bionic-ppc64el || \
        ([ -f ~/images/bionic-server-cloudimg-ppc64el-lxd.tar.xz ] || {
            export http_proxy=http://squid.internal:3128
            wget ${WGET_MODE} -O ~/images/bionic-server-cloudimg-ppc64el-lxd.tar.xz http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-ppc64el-lxd.tar.xz
            export http_proxy=''
        }
        openstack image create --public --container-format bare --disk-format raw --property architecture=ppc64 --property hypervisor_type=lxc --file ~/images/bionic-server-cloudimg-ppc64el-lxd.tar.xz bionic-ppc64el
        ) 
else
        openstack image show bionic-ppc64el || \
        ([ -f ~/images/bionic-server-cloudimg-ppc64el.img ] || {
            export http_proxy=http://squid.internal:3128
            wget ${WGET_MODE} -O ~/images/bionic-server-cloudimg-ppc64el.img http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-ppc64el.img
            export http_proxy=''
        }
        openstack image create --public --container-format bare --disk-format qcow2 --property architecture=ppc64 --file ~/images/bionic-server-cloudimg-ppc64el.img bionic-ppc64el
        )
fi

openstack image show ${TEST_IMAGE_NAME_XENIAL} ||
([ -f ~/images/xenial-server-cloudimg-ppc64el-disk1.img ] || {
    wget ${WGET_MODE} -O ~/images/xenial-server-cloudimg-ppc64el-disk1.img $TEST_IMAGE_URL_XENIAL
}
openstack image create --public --container-format bare --disk-format qcow2 --property architecture=ppc64 --file ~/images/xenial-server-cloudimg-ppc64el-disk1.img xenial-ppc64el
)

openstack image show ${TEST_IMAGE_NAME_CIRROS} ||
([ -f ~/images/cirros-d150923-ppc64le-disk.img ] || {
    export http_proxy=http://squid.internal:3128
    wget ${WGET_MODE} -O ~/images/cirros-d150923-ppc64le-disk.img $TEST_IMAGE_URL_CIRROS
    export http_proxy=''
}
openstack image create --public --container-format bare --disk-format qcow2 --property architecture=ppc64 --file ~/images/cirros-d150923-ppc64le-disk.img cirros-ppc64el
)




