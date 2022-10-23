k8sRepo ?= docker.io/labring/kubernetes-docker
k8sVersion ?= v1.24.0
clusterImages ?=
debug ?=

install-buildah:
	sudo apt remove buildah -y || true
	wget -qO "buildah" "https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
	chmod a+x "buildah"
	sudo cp -a "buildah" /usr/bin

install-sealos:
	echo "deb [trusted=yes] https://apt.fury.io/labring/ /" | sudo tee /etc/apt/sources.list.d/labring.list
	sudo apt update
	sudo apt install sealos
	sudo sealos version

install-sealctl:
	sudo wget  https://github.com/labring/sealos/releases/download/v4.1.3/sealos_4.1.3_linux_amd64.tar.gz
	sudo tar -zxvf sealos_4.1.3_linux_amd64.tar.gz sealctl &&  chmod +x sealctl && mv sealctl /usr/bin


install-k8s:
	#sudo -u root sealos run $(k8sRepo):$(k8sVersion) --single --debug
	sudo -u root sealctl cri socket

taint-k8s:
	sudo -u root kubectl taint node $NAME node-role.kubernetes.io/master-
	sudo -u root kubectl kubectl taint node $NAME node-role.kubernetes.io/control-plane-

nodes:
	sudo kubectl get nodes
