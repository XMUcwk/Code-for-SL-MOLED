import os.path as osp
import re
from glob import glob

def input(data_dir, type='train'):

    print("loading %s file list ......" % type)

    if type in ['train', 'val']:
        data_paths = glob(osp.join(data_dir, type, '*.Charles'))
    else:
        fns = lambda s: [(s, int(n)) for s, n in re.findall(r'(\D+)(\d+)', 'a%s0' % s)]
        data_paths = sorted(
            glob(osp.join(data_dir, type, '*.Charles')),
            key=fns
        )

    if len(data_paths) == 0:
        raise RuntimeError('There is no data in this direction !!!!!')

    print("found %d files\n" % len(data_paths))
    return data_paths