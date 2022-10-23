KubernetesRepo ?= docker.io/labring/kubernetes
KubernetesVersion ?= v1.24.0
SealosVersion?= 4.1.3
ClusterImages ?=
Debug ?=true
UseBuildah ?=false

get-debug:
ifeq (false, $(Debug))
DEBUG_FLAG=""
else
DEBUG_FLAG="--debug"
endif

buildah:
	$(call uninstallBuildah)
ifeq (true, $(UseBuildah))
	$(call installBuildah)
endif


test-flag: get-debug
	echo $(DEBUG_FLAG)

install-sealos: buildah
	$(call uninstallCRI)
	$(call downloadBin,sealos,$(SealosVersion))

install-sealctl:
	$(call downloadBin,sealctl,$(SealosVersion))

run-k8s: get-debug
	sudo -u root sealos run $(KubernetesRepo):$(KubernetesVersion) --single $(DEBUG_FLAG)
	$(call tainitNode)
	$(call getNodes)

define installBuildah
	@echo "download buildah in https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
	@wget -qO "buildah" "https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
    @chmod a+x buildah
    @sudo mv buildah /usr/bin
endef

define uninstallBuildah
	@sudo apt remove buildah -y || true
endef

define downloadBin
	@echo "download $(1) in https://github.com/labring/sealos/releases/download/v$(2)/sealos_$(2)_linux_amd64.tar.gz"
	@sudo wget -q https://github.com/labring/sealos/releases/download/v$(2)/sealos_$(2)_linux_amd64.tar.gz
    @sudo tar -zxvf sealos_$(2)_linux_amd64.tar.gz $(1) &&  chmod +x $(1) && mv $(1) /usr/bin
endef

define uninstallCRI
	@sudo apt-get remove docker docker-engine docker.io containerd runc
    @sudo apt-get purge docker-ce docker-ce-cli containerd.io # docker-compose-plugin
    @sudo apt-get remove -y moby-engine moby-cli moby-buildx moby-compose
endef

define getNodes
	@sudo kubectl get nodes
endef

define tainitNode
	NodeName=$(shell kubectl get nodes -ojsonpath='{.items[0].metadata.name}')
	@echo "NodeName=$(NodeName)"
	@sudo -u root kubectl taint node $(NodeName) node-role.kubernetes.io/master-
	@sudo -u root kubectl kubectl taint node $(NodeName) node-role.kubernetes.io/control-plane-
endef
