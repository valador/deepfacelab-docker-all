# deepfacelab-docker-all
## Preapre
Need install `docker` and `docker-compose` for you distro
## Use
1. If you be use image `git clone https://github.com/valador/deepfacelab-docker-all.git`
2. For download all and selfbuild `git clone --recurse-submodules https://github.com/valador/deepfacelab-docker-all.git`
3. Create folder `workspace` and copy `data_src` and `data_dst` videofiles, `model` or other stuff.
4. start `docker-compose run deepfacelab`
5. Control scripts in workspace, folder `Scripts`


### Roadmap
1. Optimize size for deepfacelab conteiner, in this time 10.2gb, OMG!
2. Test build for other options (vanilla jupyter). Now only tested Nvidia
3. Add build for gitlab