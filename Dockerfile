# A docker image to provide a host to run the standard ebooks python scripts
# - run the python scripts inside the container
# - edit the files in the exported volume

# To build and run with a volume
#> docker build -t ebooks .
#> docker run -it -d --name ebooks ebooks --volume ~/Documents/created/ebooks:/tmp/ebooks
#> docker exec -it ebooks /bin/bash


# builder image for the fonts
FROM fedora:29 as fontbuilder

RUN dnf -y install git
RUN yum -y install unzip
RUN cd /tmp && \
curl -L -O https://github.com/theleagueof/league-spartan/releases/download/2.220/LeagueSpartan-2.220.zip && \
unzip /tmp/LeagueSpartan-2.220.zip 

RUN mkdir /tmp/fonts && \
mv /tmp/LeagueSpartan-2.220/static/TTF/*.ttf /tmp/fonts/ && \
mv /tmp/LeagueSpartan-2.220/static/OTF/*.otf /tmp/fonts/ && \
mv /tmp/LeagueSpartan-2.220/static/WOFF/* /tmp/fonts/ && \
mv /tmp/LeagueSpartan-2.220/variable/TTF/LeagueSpartan-VF.ttf /tmp/fonts/

RUN git clone git://github.com/theleagueof/sorts-mill-goudy.git && \
mv sorts-mill-goudy/*.ttf /tmp/fonts/


# build the actual image
FROM fedora:29

RUN dnf -y install calibre git java-1.8.0-openjdk  
RUN python3.7 -m pip install --user pipx 
RUN python3.7 -m pipx ensurepath 
RUN python3.7 -m pipx install standardebooks 
RUN ln -s $HOME/.local/pipx/venvs/standardebooks/lib/python3.*/site-packages/se/completions/bash/se /usr/share/bash-completion/completions/se

# fonts
COPY --from=fontbuilder /tmp/fonts/* /usr/local/share/fonts/ 
RUN fc-cache -f -v
