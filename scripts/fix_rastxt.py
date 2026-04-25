import re

def fix_rastxt_c(path):
    with open(path, 'r', encoding='latin-1') as f:
        content = f.read()

    # Replace #ifdef UNIX include signal.h
    content = content.replace('#ifdef UNIX\n#include <signal.h>\n#endif', '#include <signal.h>')

    # Replace the signal registration block
    old_block = """#ifdef UNIX
    signal(SIGINT,RasMolSignalExit);
    signal(SIGPIPE,SIG_IGN);
#endif"""
    new_block = """#ifdef SIGINT
    signal(SIGINT,RasMolSignalExit);
#endif
#ifdef SIGPIPE
    signal(SIGPIPE,SIG_IGN);
#endif"""
    content = content.replace(old_block, new_block)

    with open(path, 'w', encoding='latin-1') as f:
        f.write(content)

fix_rastxt_c('src/rastxt.c')
