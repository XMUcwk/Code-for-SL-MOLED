import numpy as np
import torch
from torch.utils.data import Dataset
import random

class CharlesDataset(Dataset):
    def __init__(
        self,
        file_list,
        in_C,
        out_C,
        H,
        W,
        crop_size,
        label_slices,
        input_slices=None,
        mode='train'
    ):

        self.files = file_list
        self.in_C = in_C
        self.out_C = out_C
        self.H = H
        self.W = W
        self.crop_size = crop_size
        self.label_slices = label_slices
        self.input_slices = input_slices
        self.mode = mode

    def __len__(self):
        return len(self.files)

    def _random_crop(self, x, y):

        if self.crop_size is None:
            return x, y

        h, w, _ = x.shape
        cs = self.crop_size

        if self.mode == 'train':
            top = random.randint(0, h - cs)
            left = random.randint(0, w - cs)
        else:
            top = (h - cs) // 2
            left = (w - cs) // 2

        x = x[top:top+cs, left:left+cs, :]
        y = y[top:top+cs, left:left+cs, :]
        return x, y

    def __getitem__(self, idx):
        data_in = np.fromfile(self.files[idx], dtype=np.float32)
        reshape_num = int(data_in.size / self.H / self.W)
        data_pairs = data_in.reshape(self.H, self.W, reshape_num)

        x = np.zeros((self.H, self.W, self.in_C), dtype=np.float32)
        y = np.zeros((self.H, self.W, self.out_C), dtype=np.float32)

        if self.input_slices:
            for i in range(self.in_C):
                x[..., i] = data_pairs[..., self.input_slices[i]]
        else:
            x = data_pairs[..., :self.in_C]

        for i in range(self.out_C):
            y[..., i] = data_pairs[..., self.label_slices[i]]

        if self.crop_size is not None:
            x, y = self._random_crop(x, y)

        x = torch.from_numpy(x).permute(2, 0, 1)
        y = torch.from_numpy(y).permute(2, 0, 1)

        return x, y
