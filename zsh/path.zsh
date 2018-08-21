## plenv
PERL_LOCAL_LIB="$HOME/perl5"
export PATH=${PERL_LOCAL_LIB}/bin:$PATH
export PERL5LIB=${PERL_LOCAL_LIB}/lib/perl5:$PERL5LIB

if [ -x "`which plenv`" ]; then
  export PLENV_VERSION=$(plenv version | awk '{print $1}')
  export PERL_CPANM_OPT="--local-lib=${PERL_LOCAL_LIB}"
  export PATH=${PLENV_ROOT}/bin:$PATH
  export PERL5LIB=${PLENV_ROOT}/versions/${PLENV_VERSION}/lib/perl5:$PERL5LIB
fi


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
