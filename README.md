# deepfacelab-docker-all
## Preapre
Need install `docker` and `docker-compose` for you distro
## Use
### Arch linux
1. nvidia-container-toolkit-1.12.0 from AUR not work, need use nvidia-container-toolkit-v1.13.0-rc.1 clone git repo from AUR and edit self or wait update. 
2. clone repo and edit `https://aur.archlinux.org/nvidia-container-toolkit.git`

`PKGBUILD`
```
# Maintainer: Kien Dang <mail at kien dot ai>
# Maintainer: Julie Shapiro <jshapiro at nvidia dot com>

pkgname=nvidia-container-toolkit

pkgver=1.13.0
pkgrel=1

pkgdesc='NVIDIA container runtime toolkit'
arch=('x86_64')
url='https://github.com/NVIDIA/nvidia-container-toolkit'
license=('Apache')

makedepends=('go')
depends=('libnvidia-container-tools>=1.9.0')
conflicts=('nvidia-container-runtime-hook' 'nvidia-container-runtime<2.0.0')
replaces=('nvidia-container-runtime-hook')
options=(!lto)

backup=('etc/nvidia-container-runtime/config.toml')

source=("v1.13.0-rc.1.tar.gz"::"${url}/archive/v1.13.0-rc.1.tar.gz")
sha256sums=('c8de674d4ff4c65f2125e5b822542f0222d8c11a43a000a62311b065a0bdbc55')

_srcdir="nvidia-container-toolkit-1.13.0-rc.1"

build() {
  cd "${_srcdir}"

  mkdir bin

  GO111MODULE=auto \
  GOPATH="${srcdir}/gopath" \
  go build -v \
    -modcacherw \
    -o bin \
    -ldflags "-s -w -extldflags=-Wl,-z,lazy" \
    "./..."
    # -trimpath \  # only go > 1.13
    #-ldflags " -s -w -extldflags=-Wl,-z,now,-z,relro" \

  # go leaves a bunch of local stuff with 0400, making it break future `makepkg -C` _grumble grumble_
  GO111MODULE=auto \
  GOPATH="${srcdir}/gopath" \
  go clean -modcache
}

package() {
  install -D -m755 "${_srcdir}/bin/nvidia-container-runtime-hook" "${pkgdir}/usr/bin/nvidia-container-runtime-hook"
  install -D -m755 "${_srcdir}/bin/nvidia-ctk" "${pkgdir}/usr/bin/nvidia-ctk"

  pushd "${pkgdir}/usr/bin/"
  ln -sf "nvidia-container-runtime-hook" "${pkgname}"
  popd
  install -D -m644 "${_srcdir}/config/config.toml.rpm-yum" "${pkgdir}/etc/nvidia-container-runtime/config.toml"
  install -D -m644 "${_srcdir}/oci-nvidia-hook.json" "${pkgdir}/usr/share/containers/oci/hooks.d/00-oci-nvidia-hook.json"

  install -D -m644 "${_srcdir}/LICENSE" "${pkgdir}/usr/share/licenses/$pkgname/LICENSE"
}
```
in cloned repo:
1. `makepkg`
2. `sudo pacman -U nvidia-container-toolkit-1.13.0-1-x86_64.pkg.tar.zst`

### Docker container use
1. If you be use image `git clone https://github.com/valador/deepfacelab-docker-all.git`
2. For download all and selfbuild `git clone --recurse-submodules https://github.com/valador/deepfacelab-docker-all.git`
3. Create folder `workspace` and copy `data_src` and `data_dst` videofiles, `model` or other stuff.
4. start `docker-compose run deepfacelab` or `make run-deepfacelab-nvidia`
5. Control scripts in workspace, folder `Scripts`


## Roadmap
1. Optimize size for deepfacelab conteiner, in this time 10.2gb, OMG! I update toolkits and now, container size... 13.41GB why? WHY!?
2. Test build for other options (vanilla jupyter). Now only tested Nvidia
3. ffmpeg dockerfiles similar with jupyter and without, need set ARG to image
4. Add build for gitlab
   
## Trouble
1. cannot connect to X server SAEHD model train
in host terminal run `xhost +`
---
# Pinned TF probability doesn't work with numpy >= 1.24
numpy>=1.21.0,<1.24.0; python_version < '3.8'
numpy>=1.22.0,<1.24.0; python_version >= '3.8'
tensorflow-gpu>=2.7.0,<2.11.0
pynvx==1.0.0 ; sys_platform == "darwin"

tqdm>=4.64
psutil>=5.9.0
numexpr>=2.7.3; python_version < '3.9'  # >=2.8.0 conflicts in Conda
numexpr>=2.8.3; python_version >= '3.9'
opencv-python>=4.6.0.0
pillow>=9.2.0
scikit-learn==1.0.2; python_version < '3.9'  # AMD needs version 1.0.2 and 1.1.0 not available in Python 3.7
scikit-learn>=1.1.0; python_version >= '3.9'
fastcluster>=1.2.6
matplotlib>=3.4.3,<3.6.0; python_version < '3.9'  # >=3.5.0 conflicts in Conda
matplotlib>=3.5.1,<3.6.0; python_version >= '3.9'
imageio>=2.19.3
imageio-ffmpeg>=0.4.7
ffmpy>=0.3.0
# Exclude badly numbered Python2 version of nvidia-ml-py
nvidia-ml-py>=11.515,<300
tensorflow-probability<0.17
typing-extensions>=4.0.0
pywin32>=228 ; sys_platform == "win32"