import torch
import torch.nn as nn


class ConvBNReLU(nn.Module):
    def __init__(self, in_channels: int, out_channels: int, kernel_size: int = 3, padding: int = 1):
        super().__init__()
        self.block = nn.Sequential(
            nn.Conv2d(in_channels, out_channels, kernel_size=kernel_size, padding=padding, bias=False),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.block(x)


class ConvBlock(nn.Module):
    def __init__(self, in_channels: int, out_channels: int, n_conv: int = 2):
        super().__init__()
        layers = [ConvBNReLU(in_channels, out_channels)]
        for _ in range(n_conv - 1):
            layers.append(ConvBNReLU(out_channels, out_channels))
        self.block = nn.Sequential(*layers)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.block(x)


class AttentionBlock(nn.Module):

    def __init__(self, F_g: int, F_l: int, F_int: int):
        super().__init__()
        self.W_g = nn.Sequential(
            nn.Conv2d(F_g, F_int, kernel_size=1, stride=1, padding=0, bias=True),
            nn.BatchNorm2d(F_int),
        )

        self.W_x = nn.Sequential(
            nn.Conv2d(F_l, F_int, kernel_size=1, stride=1, padding=0, bias=True),
            nn.BatchNorm2d(F_int),
        )

        self.psi = nn.Sequential(
            nn.Conv2d(F_int, 1, kernel_size=1, stride=1, padding=0, bias=True),
            nn.BatchNorm2d(1),
            nn.Sigmoid(),
        )

        self.relu = nn.ReLU(inplace=True)

    def forward(self, g: torch.Tensor, x: torch.Tensor) -> torch.Tensor:
        g1 = self.W_g(g)
        x1 = self.W_x(x)
        psi = self.relu(g1 + x1)
        psi = self.psi(psi)
        return x * psi


class AttUNet3Plus(nn.Module):

    def __init__(
        self,
        in_channels: int = 16,
        out_channels: int = 6,
        base_channels: int = 64,
    ):
        super().__init__()

        c1 = base_channels
        c2 = base_channels * 2
        c3 = base_channels * 4
        c4 = base_channels * 8
        c5 = base_channels * 8

        filters = [c1, c2, c3, c4, c5]

        self.pool = nn.MaxPool2d(kernel_size=2, stride=2)

        self.conv1 = ConvBlock(in_channels, c1, n_conv=2)
        self.conv2 = ConvBlock(c1, c2, n_conv=2)
        self.conv3 = ConvBlock(c2, c3, n_conv=3)
        self.conv4 = ConvBlock(c3, c4, n_conv=3)
        self.conv5 = ConvBlock(c4, c5, n_conv=3)

        self.CatChannels = c1
        self.CatBlocks = 5
        self.UpChannels = self.CatChannels * self.CatBlocks

        self.h1_PT_hd4 = nn.MaxPool2d(8, 8, ceil_mode=True)
        self.h1_PT_hd4_conv = ConvBNReLU(filters[0], self.CatChannels)

        self.h2_PT_hd4 = nn.MaxPool2d(4, 4, ceil_mode=True)
        self.h2_PT_hd4_conv = ConvBNReLU(filters[1], self.CatChannels)

        self.h3_PT_hd4 = nn.MaxPool2d(2, 2, ceil_mode=True)
        self.h3_PT_hd4_conv = ConvBNReLU(filters[2], self.CatChannels)

        self.h4_Cat_hd4_conv = ConvBNReLU(filters[3], self.CatChannels)

        self.hd5_UT_hd4 = nn.Upsample(scale_factor=2, mode="bilinear", align_corners=True)
        self.hd5_UT_hd4_conv = ConvBNReLU(filters[4], self.CatChannels)

        self.conv4d_1 = ConvBNReLU(self.UpChannels, self.UpChannels)


        self.h1_PT_hd3 = nn.MaxPool2d(4, 4, ceil_mode=True)
        self.h1_PT_hd3_conv = ConvBNReLU(filters[0], self.CatChannels)

        self.h2_PT_hd3 = nn.MaxPool2d(2, 2, ceil_mode=True)
        self.h2_PT_hd3_conv = ConvBNReLU(filters[1], self.CatChannels)

        self.h3_Cat_hd3_conv = ConvBNReLU(filters[2], self.CatChannels)

        self.hd4_UT_hd3 = nn.Upsample(scale_factor=2, mode="bilinear", align_corners=True)
        self.hd4_UT_hd3_conv = ConvBNReLU(self.UpChannels, self.CatChannels)

        self.hd5_UT_hd3 = nn.Upsample(scale_factor=4, mode="bilinear", align_corners=True)
        self.hd5_UT_hd3_conv = ConvBNReLU(filters[4], self.CatChannels)

        self.conv3d_1 = ConvBNReLU(self.UpChannels, self.UpChannels)


        self.h1_PT_hd2 = nn.MaxPool2d(2, 2, ceil_mode=True)
        self.h1_PT_hd2_conv = ConvBNReLU(filters[0], self.CatChannels)

        self.h2_Cat_hd2_conv = ConvBNReLU(filters[1], self.CatChannels)

        self.hd3_UT_hd2 = nn.Upsample(scale_factor=2, mode="bilinear", align_corners=True)
        self.hd3_UT_hd2_conv = ConvBNReLU(self.UpChannels, self.CatChannels)

        self.hd4_UT_hd2 = nn.Upsample(scale_factor=4, mode="bilinear", align_corners=True)
        self.hd4_UT_hd2_conv = ConvBNReLU(self.UpChannels, self.CatChannels)

        self.hd5_UT_hd2 = nn.Upsample(scale_factor=8, mode="bilinear", align_corners=True)
        self.hd5_UT_hd2_conv = ConvBNReLU(filters[4], self.CatChannels)

        self.conv2d_1 = ConvBNReLU(self.UpChannels, self.UpChannels)


        self.h1_Cat_hd1_conv = ConvBNReLU(filters[0], self.CatChannels)

        self.hd2_UT_hd1 = nn.Upsample(scale_factor=2, mode="bilinear", align_corners=True)
        self.hd2_UT_hd1_conv = ConvBNReLU(self.UpChannels, self.CatChannels)

        self.hd3_UT_hd1 = nn.Upsample(scale_factor=4, mode="bilinear", align_corners=True)
        self.hd3_UT_hd1_conv = ConvBNReLU(self.UpChannels, self.CatChannels)

        self.hd4_UT_hd1 = nn.Upsample(scale_factor=8, mode="bilinear", align_corners=True)
        self.hd4_UT_hd1_conv = ConvBNReLU(self.UpChannels, self.CatChannels)

        self.hd5_UT_hd1 = nn.Upsample(scale_factor=16, mode="bilinear", align_corners=True)
        self.hd5_UT_hd1_conv = ConvBNReLU(filters[4], self.CatChannels)

        self.conv1d_1 = ConvBNReLU(self.UpChannels, self.UpChannels)


        self.Att_c2_c1 = AttentionBlock(F_g=c2, F_l=c1, F_int=c1)
        self.Att_c3_c2 = AttentionBlock(F_g=c3, F_l=c2, F_int=c2)
        self.Att_c4_c3 = AttentionBlock(F_g=c4, F_l=c3, F_int=c3)
        self.Att_c5_c4 = AttentionBlock(F_g=c5, F_l=c4, F_int=c4)

        self.Att_up_c3 = AttentionBlock(F_g=self.UpChannels, F_l=c3, F_int=c3)
        self.Att_up_c2 = AttentionBlock(F_g=self.UpChannels, F_l=c2, F_int=c2)
        self.Att_up_c1 = AttentionBlock(F_g=self.UpChannels, F_l=c1, F_int=c1)


        self.outconv1 = nn.Conv2d(self.UpChannels, out_channels, kernel_size=3, padding=1)

        self._init_weights()

    def _init_weights(self) -> None:
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
                if m.bias is not None:
                    nn.init.zeros_(m.bias)
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.ones_(m.weight)
                nn.init.zeros_(m.bias)

    def forward(self, x: torch.Tensor) -> torch.Tensor:

        h1 = self.conv1(x)
        h2 = self.conv2(self.pool(h1))
        h3 = self.conv3(self.pool(h2))
        h4 = self.conv4(self.pool(h3))
        hd5 = self.conv5(self.pool(h4))

        up2_h2 = nn.functional.interpolate(h2, scale_factor=2, mode="bilinear", align_corners=True)
        up2_h3 = nn.functional.interpolate(h3, scale_factor=2, mode="bilinear", align_corners=True)
        up2_h4 = nn.functional.interpolate(h4, scale_factor=2, mode="bilinear", align_corners=True)
        up2_hd5 = nn.functional.interpolate(hd5, scale_factor=2, mode="bilinear", align_corners=True)


        h1_PT_hd4 = self.h1_PT_hd4_conv(
            self.h1_PT_hd4(self.Att_c2_c1(g=up2_h2, x=h1))
        )
        h2_PT_hd4 = self.h2_PT_hd4_conv(
            self.h2_PT_hd4(self.Att_c3_c2(g=up2_h3, x=h2))
        )
        h3_PT_hd4 = self.h3_PT_hd4_conv(
            self.h3_PT_hd4(self.Att_c4_c3(g=up2_h4, x=h3))
        )
        h4_Cat_hd4 = self.h4_Cat_hd4_conv(
            self.Att_c5_c4(g=up2_hd5, x=h4)
        )
        hd5_UT_hd4 = self.hd5_UT_hd4_conv(self.hd5_UT_hd4(hd5))

        hd4 = self.conv4d_1(
            torch.cat((h1_PT_hd4, h2_PT_hd4, h3_PT_hd4, h4_Cat_hd4, hd5_UT_hd4), dim=1)
        )


        h1_PT_hd3 = self.h1_PT_hd3_conv(
            self.h1_PT_hd3(self.Att_c2_c1(g=up2_h2, x=h1))
        )
        h2_PT_hd3 = self.h2_PT_hd3_conv(
            self.h2_PT_hd3(self.Att_c3_c2(g=up2_h3, x=h2))
        )
        h3_Cat_hd3 = self.h3_Cat_hd3_conv(
            self.Att_up_c3(
                g=nn.functional.interpolate(hd4, scale_factor=2, mode="bilinear", align_corners=True),
                x=h3,
            )
        )
        hd4_UT_hd3 = self.hd4_UT_hd3_conv(self.hd4_UT_hd3(hd4))
        hd5_UT_hd3 = self.hd5_UT_hd3_conv(self.hd5_UT_hd3(hd5))

        hd3 = self.conv3d_1(
            torch.cat((h1_PT_hd3, h2_PT_hd3, h3_Cat_hd3, hd4_UT_hd3, hd5_UT_hd3), dim=1)
        )


        h1_PT_hd2 = self.h1_PT_hd2_conv(
            self.h1_PT_hd2(self.Att_c2_c1(g=up2_h2, x=h1))
        )
        h2_Cat_hd2 = self.h2_Cat_hd2_conv(
            self.Att_up_c2(
                g=nn.functional.interpolate(hd3, scale_factor=2, mode="bilinear", align_corners=True),
                x=h2,
            )
        )
        hd3_UT_hd2 = self.hd3_UT_hd2_conv(self.hd3_UT_hd2(hd3))
        hd4_UT_hd2 = self.hd4_UT_hd2_conv(self.hd4_UT_hd2(hd4))
        hd5_UT_hd2 = self.hd5_UT_hd2_conv(self.hd5_UT_hd2(hd5))

        hd2 = self.conv2d_1(
            torch.cat((h1_PT_hd2, h2_Cat_hd2, hd3_UT_hd2, hd4_UT_hd2, hd5_UT_hd2), dim=1)
        )


        h1_Cat_hd1 = self.h1_Cat_hd1_conv(
            self.Att_up_c1(
                g=nn.functional.interpolate(hd2, scale_factor=2, mode="bilinear", align_corners=True),
                x=h1,
            )
        )
        hd2_UT_hd1 = self.hd2_UT_hd1_conv(self.hd2_UT_hd1(hd2))
        hd3_UT_hd1 = self.hd3_UT_hd1_conv(self.hd3_UT_hd1(hd3))
        hd4_UT_hd1 = self.hd4_UT_hd1_conv(self.hd4_UT_hd1(hd4))
        hd5_UT_hd1 = self.hd5_UT_hd1_conv(self.hd5_UT_hd1(hd5))

        hd1 = self.conv1d_1(
            torch.cat((h1_Cat_hd1, hd2_UT_hd1, hd3_UT_hd1, hd4_UT_hd1, hd5_UT_hd1), dim=1)
        )

        out = self.outconv1(hd1)
        return out

