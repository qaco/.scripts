import sys
from os import walk
import os
import os.path
import epub_meta

path_sep = '/'
if os.name == 'nt':
    path_sep = '\\'

def is_integer(n):
    try:
        int(n)
    except ValueError:
        return False
    else:
        return True

def get_author(title, auth):
    auth = auth.replace(",", " ")
    auth = auth.replace("/", " ")
        
    auth_split = auth.split()
        
    print("Titre : " + title)
    print ("Nom de l'auteur (choix): ", end='')
    for idx,item in enumerate(auth_split):
        if idx == len(auth_split) - 1:
            print ("ou ", end='')
        print(item + "[" + str(idx) + "] ", end='')
        print

    real_name = str(len(auth_split))
    while not(is_integer(real_name) and int(real_name) < len(auth_split)):
        real_name = input("\nReponse: ")
    auth_smooth = auth_split[int(real_name)]
    return auth_smooth

def handle_epub(loc, name):
    mypath = loc + path_sep + name
    print(mypath)
    ext = os.path.splitext(mypath)[1]
    if ext == ".epub":
        try:
            data = epub_meta.get_epub_metadata(mypath, read_cover_image=False, read_toc=False)
            title = data['title']
            auth = data['authors'][0]
            auth = get_author(title, auth)
            mynewpath = loc + path_sep + auth + ' ' + title + ext
            os.rename(mypath,mynewpath)
        except KeyError:
            print(name + " corrompu")
            print
        
def handle_dir(mypath):
    for (dirpath, dirnames, filenames) in os.walk(mypath):
        for dn in dirnames:
            handle_dir(mypath + '/' + dn)
        for fn in filenames:
            handle_epub(mypath, fn)

assert(len(sys.argv) == 2)
ebooks = sys.argv[1]
handle_dir(ebooks)
