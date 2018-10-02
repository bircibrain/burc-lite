FROM ubuntu:xenial
MAINTAINER <rhancock@gmail.com>

# apt installs
## essential packages
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ xenial universe" >> /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y nano curl ed file tcsh git wget emacs \
	build-essential pigz unzip pkg-config s3cmd s3fs \
	bzip2 unzip libxml2-dev libxslt-dev bc libssl-dev

## useful packages
#Install a system python (with patched paltform.dist()) here
#Anaconda will be installed later
RUN apt-get update && apt-get install -y parallel imagemagick graphviz xvfb python2.7

# Directories
## binds
RUN mkdir -p /bind/lib/cuda && \
	mkdir /bind/data && mkdir /bind/data_in && mkdir /bind/data_out && \
	mkdir /bind/freesurfer && mkdir /bind/resources && \
	mkdir /bind/scratch && mkdir /bind/work && \
	mkdir /bind/archive && mkdir /bind/scripts && \
	mkdir -p /bind/bin/matlab && mkdir /bind/matlablicense && \
	mkdir -p /bind/lib/mpich2 && mkdir -p /bind/lib/openmpi && \
	mkdir -p /bind/lib/storage && mkdir -p /bind/lib/fabric

##
ENV DOWNLOADS /tmp/downloads
RUN mkdir $DOWNLOADS
RUN mkdir /usr/local/share/matlab
ENV MFILES "/usr/local/share/matlab"

# recent cmake (required for dcm2niix)
WORKDIR $DOWNLOADS
RUN apt remove cmake && apt purge --auto-remove cmake
RUN curl -L -O https://cmake.org/files/v3.11/cmake-3.11.4-Linux-x86_64.sh && \
	mkdir /opt/cmake && \
	sh cmake-3.11.4-Linux-x86_64.sh --prefix=/opt/cmake --skip-license && \
	ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

# Software

## dcm2niix
WORKDIR $DOWNLOADS
RUN git clone https://github.com/rordenlab/dcm2niix.git && \
    	cd dcm2niix && mkdir build && cd build && \
        cmake -DBATCH_VERSION=ON -DUSE_OPENJPEG=ON .. && \
        make && make install


## AFNI
WORKDIR $DOWNLOADS
RUN apt-get update && apt-get install -y gsl-bin netpbm r-base-core libnlopt-dev \
libjpeg62 xvfb libglu1-mesa-dev libglw1-mesa libxm4 libnlopt0 && \
	curl -O https://afni.nimh.nih.gov/pub/dist/bin/linux_ubuntu_16_64/@update.afni.binaries && \
	tcsh @update.afni.binaries -package linux_ubuntu_16_64  \
	-do_extras -bindir /usr/local/afni
ENV PATH /usr/local/afni:${PATH}
# RUN curl https://afni.nimh.nih.gov/pub/dist/src/scripts_src/@add_rcran_ubuntu.tcsh |tcsh && \
# 	rPkgsInstall -pkgs ALL

## FSL
# WORKDIR $DOWNLOADS
# ENV FSLDIR /usr/local/fsl
#
# RUN curl -O https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
# 	chmod 755 fslinstaller.py && \
# 	./fslinstaller.py -d ${FSLDIR} -q
#
# ENV MATLABPATH "${FSLDIR}/etc/matlab/:${MATLABPATH}"
#
# RUN curl -O https://fsl.fmrib.ox.ac.uk/fsldownloads/patches/eddy-patch-fsl-5.0.11/centos6/eddy_cuda8.0 && \
# 	chmod 755 eddy_cuda8.0 && \
# 	mv eddy_cuda8.0 ${FSLDIR}/bin && \
# 	mv ${FSLDIR}/bin/eddy_cuda ${FSLDIR}/bin/eddy_cuda7.0 && \
# 	ln -s ${FSLDIR}/bin/eddy_cuda8.0 ${FSLDIR}/bin/eddy_cuda
#
# ENV PATH "${PATH}:${FSLDIR}/bin"
# RUN . ${FSLDIR}/etc/fslconf/fsl.sh
# RUN ${FSLDIR}/etc/fslconf/fslpython_install.sh

### eddy qc
# WORKDIR $DOWNLOADS
# RUN git clone https://git.fmrib.ox.ac.uk/matteob/eddy_qc_release.git && \
# 	cd eddy_qc_release && \
# 	fslpython setup.py install
#
# ENV PATH "${PATH}:/usr/local/fsl/fslpython/envs/fslpython/bin"


# Python
## Anaconda 2
WORKDIR $DOWNLOADS
RUN curl -O https://repo.continuum.io/archive/Anaconda2-5.0.1-Linux-x86_64.sh && \
	bash Anaconda2-5.0.1-Linux-x86_64.sh -b -p /usr/local/anaconda2
ENV PATH "/usr/local/anaconda2/bin:${PATH}"

### DICOM tools
RUN conda install --channel conda-forge -y nibabel nipype pydicom
RUN pip install git+https://github.com/moloney/dcmstack.git
RUN pip install https://github.com/nipy/heudiconv/archive/master.zip
RUN pip install https://github.com/cbedetti/Dcm2Bids/archive/master.zip

RUN git clone https://github.com/jmtyszka/bidskit.git && mv bidskit /usr/local/
ENV PATH "${PATH}":/usr/local/bidskit

# RUN conda create --channel conda-forge -y -n python3 python=3.6 anaconda nibabel nipype pydicom
# RUN conda create -y -n poldrack python=3.6

## mriqc
SHELL ["/bin/bash", "-c"]

# RUN source activate poldrack && \
# 	pip install -r https://raw.githubusercontent.com/poldracklab/mriqc/master/requirements.txt && \
# 	pip install git+https://github.com/poldracklab/mriqc.git
# RUN source deactivate
#
# ## fmriprep
# RUN source activate poldrack && \
# 	pip install fmriprep pydicom
# RUN source deactivate


# JAVA
RUN apt-get update && apt-get install -y default-jre
ENV MATLAB_JAVA /usr/lib/jvm/default-java/jre/
ENV JAVA_HOME /usr/lib/jvm/default-java/jre/

# Mango - since FSL gui may not work
WORKDIR $DOWNLOADS
RUN curl -O http://ric.uthscsa.edu/mango/downloads/mango_unix.zip && \
	unzip mango_unix.zip && \
	mv Mango /usr/local
ENV PATH=${PATH}:/usr/local/Mango

# Cleanup
RUN apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y
RUN rm -rf $DOWNLOADS
RUN ldconfig

# Configuration

## PREpend user scripts to the path
ENV PATH /bind/scripts:$PATH

## Other ENVs
#ENV FSLDIR=/usr/local/fsl
#ENV PATH=${PATH}:/usr/local/fsl/bin:/usr/local/fsl/fslpython/envs/fslpython/bin

ENV TMPDIR=/tmp
ENV JOBLIB_TEMP_FOLDER=$TMPDIR


#setup singularity compatible entry points to run the initialization script
#by default, run the user runtime.sh, but user can override
#e.g. docker run birc myscript.sh
ENTRYPOINT ["/usr/bin/env","/singularity"]
#not singularity compatible
#CMD ["/bind/scripts/runtime.sh"]

COPY entry_init.sh /singularity
RUN chmod 755 /singularity

RUN /usr/bin/env |sed  '/^HOME/d' | sed '/^HOSTNAME/d' | sed  '/^USER/d' | sed '/^PWD/d' > /environment && \
	chmod 755 /environment


RUN echo "Welcome to the BURC!\nDocumentation is available at \n*http://birc-int.psy.uconn.edu/wiki/Containers\n*https://github.com/bircibrain/containers" > /etc/motd


#locale
#RUN apt-get install -y apt-utils locales
#RUN echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
#RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8


# tcsh/csh  prompt
RUN cat /etc/csh.cshrc | sed -e 's/prompt.*=.*/prompt = "[%n@%m(burc-lite):%c]%# "/' > /tmp/tmp.cshrc && \
mv /tmp/tmp.cshrc /etc/csh.cshrc

# bash prompt
RUN cat /etc/bash.bashrc | sed -e "s/PS1=.*/PS1='\${debian_chroot:+(\$debian_chroot)}\\\u@\\\h(burc-lite):\\\w\\\\$ '/" > /tmp/tmp.bashrc && \
mv /tmp/tmp.bashrc /etc/bash.bashrc


# USER
RUN useradd --create-home -s /bin/bash birc
# testing for docker hub
# USER birc

RUN conda install -y pyqt=4
