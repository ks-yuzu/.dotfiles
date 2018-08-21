## hls
export PATH=$HOME/bin/Xilinx/14.7/ISE_DS/ISE/bin/lin64:$PATH
export PATH=$HOME/tools/ccap/bin:$PATH
export LIBDIR=$HOME/tools/ccap/ccaplib 
export PATH=$HOME/tools/mips-elf/gcc-4.8.2/bin:$PATH
export LD_LIBRARY_PATH=$HOME/tools/mpc-1.0.2/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/tools/mpfr-3.1.2/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/tools/gmp-6.0.0/lib:$LD_LIBRARY_PATH
export SOFT_FP_DIR=$HOME/tools/gcc-4.8.2/tmp/mips-elf/soft-float/el/libgcc

## plenv
export PERL_CPANM_OPT="--local-lib=~/perl5"
export PATH=$HOME/.plenv/bin:$PATH
export PATH=$HOME/perl5/bin:$PATH
export PERL5LIB=$HOME/perl5/lib/perl5:$PERL5LIB
export PERL5LIB=$HOME/.plenv/versions/5.24.0/lib/perl5:$PERL5LIB
export PLENV_VERSION=$(plenv version | awk '{print $1}')

## cabal
export PATH=$HOME/.cabal/bin:$PATH

## java
# export TOMCAT_HOME=/usr/share/tomcat6
# export CATALINA_HOME=/usr/share/tomcat6
# export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
# export PATH=$PATH:$JAVA_HOME/bin
# export CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
# export CLASSPATH=$CLASSPATH:$CATALINA_HOME/common/lib:$CATALINA_HOME/common/lib/servlet-api.jar
# export CLASSPATH=$CLASSPATH:/usr/share/java/mysql-connector-java-5.1.28.jar # jdbc

## others
export PATH=$PATH:$HOME/.local/lib/python2.7/site-packages/powerline
export PATH=$PATH:/opt/ibm/ILOG/CPLEX_Studio1261/cplex/bin/x86-64_linux
export PATH=$HOME/bin:$PATH
export PATH=$HOME/opt:$PATH
export PATH=$HOME/bin/processing/:$PATH
