alias acap='acap.pl -Dall --remain-linked-object -l synthesized/'
alias ise='ise >/dev/null 2>&1 &'

export PATH=${HOME}/opt/Vivado/2016.4/bin:$PATH

function clean-acap {
    local dir='.'
    if [ -d synthesized ]; then
        dir='synthesized'
    fi
    
    rm -f $dir/*.o
    rm -f $dir/*.s
    rm -f $dir/*.0
    rm -f $dir/user.obj
    rm -f $dir/*.out
    rm -f $dir/*.dmem
    rm -f $dir/*.txt
    rm -f $dir/*_i.mem
    rm -f $dir/*_d.mem
    rm -f $dir/*.low
    rm -f $dir/*.dfa
    rm -f $dir/*.sch
    rm -f $dir/*.bnd
    rm -f $dir/*.stl
    rm -f $dir/*.rtl
    rm -f $dir/*.v
}
