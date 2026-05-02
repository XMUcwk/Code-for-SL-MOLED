import os
import os.path as osp
import json
import torch
import numpy as np
import scipy.io as scio

from argparse import ArgumentParser
from torch.utils.data import DataLoader
from torch.optim import Adam
from torch.cuda.amp import autocast, GradScaler
from model import AttUNet3Plus
from input import input
from datasets import CharlesDataset
import cv2


def get_checkpoint(path):
    if not osp.exists(path):
        return None
    for f in os.listdir(path):
        if f.endswith(".pkl"):
            return f
    return None


class L1_loss(torch.nn.Module):
    def __init__(self):
        super().__init__()

    def forward(self, X, Y):
        return torch.mean(torch.abs(X - Y))


def validate(model, loader, loss_fn, device, max_batches=50):
    model.eval()
    loss_sum = 0.0
    n = 0
    with torch.no_grad():
        for x, y in loader:
            x = x.to(device, dtype=torch.float32)
            y = y.to(device, dtype=torch.float32)
            with autocast():
                yp = model(x)
                loss = loss_fn(y, yp)
            loss_sum += loss.item()
            n += 1
            if max_batches and n >= max_batches:
                break
    return loss_sum / max(n, 1)

def visualize_during_train(model, loader, device, model_dir, epoch, displayrange):
    model.eval()

    num_imgs = len(loader)
    row = (num_imgs - 1) // 5 + 1
    all_img0 = np.zeros((256 * row, 256 * 5), dtype=np.uint8)
    all_img1 = np.zeros((256 * row, 256 * 5), dtype=np.uint8)
    all_img2 = np.zeros((256 * row, 256 * 5), dtype=np.uint8)
    all_img3 = np.zeros((256 * row, 256 * 5), dtype=np.uint8)
    all_img4 = np.zeros((256 * row, 256 * 5), dtype=np.uint8)
    all_img5 = np.zeros((256 * row, 256 * 5), dtype=np.uint8)

    g = 0
    with torch.no_grad():
        for x, _ in loader:
            x = x.to(device)

            y_pred = model(x)
            output = y_pred[0].detach().cpu().numpy()
            output0 = np.squeeze((output[0,:,:] * 255.0 / displayrange)).astype(np.uint8)
            output1 = np.squeeze((output[1,:, :] * 255.0 / displayrange)).astype(np.uint8)
            output2 = np.squeeze((output[2,:, :] * 255.0 / displayrange)).astype(np.uint8)
            output3 = np.squeeze((output[3,:,:] * 255.0 / displayrange)).astype(np.uint8)
            output4 = np.squeeze((output[4,:, :] * 255.0 / displayrange)).astype(np.uint8)
            output5 = np.squeeze((output[5,:, :] * 255.0 / displayrange)).astype(np.uint8)

            h = g // 5
            w = g % 5
            all_img0[h*256:(h+1)*256,w*256:(w+1)*256] = output0
            all_img1[h*256:(h+1)*256,w*256:(w+1)*256] = output1
            all_img2[h*256:(h+1)*256,w*256:(w+1)*256] = output2
            all_img3[h*256:(h+1)*256,w*256:(w+1)*256] = output3
            all_img4[h*256:(h+1)*256,w*256:(w+1)*256] = output4
            all_img5[h*256:(h+1)*256,w*256:(w+1)*256] = output5
            g += 1

    all_img0 = cv2.applyColorMap(all_img0, cv2.COLORMAP_JET)
    all_img1 = cv2.applyColorMap(all_img1, cv2.COLORMAP_JET)
    all_img2 = cv2.applyColorMap(all_img2, cv2.COLORMAP_JET)
    all_img3 = cv2.applyColorMap(all_img3, cv2.COLORMAP_JET)
    all_img4 = cv2.applyColorMap(all_img4, cv2.COLORMAP_JET)
    all_img5 = cv2.applyColorMap(all_img5, cv2.COLORMAP_JET)
    cv2.imwrite(osp.join(model_dir, f"T1rho{epoch}.jpg"), all_img0)
    cv2.imwrite(osp.join(model_dir, f"T2{epoch}.jpg"), all_img1)
    cv2.imwrite(osp.join(model_dir, f"T2star{epoch}.jpg"), all_img2)
    cv2.imwrite(osp.join(model_dir, f"PD{epoch}.jpg"), all_img3)
    cv2.imwrite(osp.join(model_dir, f"B0{epoch}.jpg"), all_img4)
    cv2.imwrite(osp.join(model_dir, f"B1{epoch}.jpg"), all_img5)

    model.train()


def train(model, args, device):
    optimizer = Adam(model.parameters(), lr=args.lr)
    scheduler = torch.optim.lr_scheduler.StepLR(
        optimizer, step_size=20000, gamma=0.8
    )
    scaler = GradScaler()
    loss_fn = L1_loss()


    train_files = input(args.Data_Dir, "train")
    val_files = input(args.Data_Dir, "val")
    test_files = input(args.Data_Dir, "test")

    train_dataset = CharlesDataset(
        train_files,
        args.in_channel,
        args.out_channel,
        args.image_H,
        args.image_W,
        args.crop_size,
        args.label_slices,
        args.input_slices,
        mode="train",
    )

    val_dataset = CharlesDataset(
        val_files,
        args.in_channel,
        args.out_channel,
        args.image_H,
        args.image_W,
        args.crop_size,
        args.label_slices,
        args.input_slices,
        mode="val",
    )

    test_dataset = CharlesDataset(
        test_files,
        args.in_channel,
        args.out_channel,
        args.image_H,
        args.image_W,
        None,
        args.label_slices,
        args.input_slices,
        mode="test",
    )

    train_loader = DataLoader(
        train_dataset,
        batch_size=args.batch_size,
        shuffle=True,
        num_workers=4,
        pin_memory=True,
        drop_last=True,
        persistent_workers=True,
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=1,
        shuffle=False,
        num_workers=2,
        pin_memory=True,
    )

    test_loader = DataLoader(
        test_dataset,
        batch_size=1,
        shuffle=False,
        num_workers=2,
        pin_memory=True,
    )


    ckpt = get_checkpoint(args.model_dir)
    start_epoch = 1
    global_step = 0
    if ckpt:
        ckpt_path = osp.join(args.model_dir, ckpt)
        state = torch.load(ckpt_path,map_location=device)
        model.load_state_dict(state["model_state_dict"])
        optimizer.load_state_dict(state["optimizer_state_dict"])
        scheduler.load_state_dict(state["scheduler_state_dict"])
        start_epoch = int(state.get("epoch", state.get("step", 0))) + 1
        global_step = int(state.get("global_step", 0))
        print(f"[*] Resume from epoch {start_epoch},iter {global_step}")

    print(f"[*] Start training from epoch {start_epoch}")


    loss_sum = 0.0
    loss_count = 0
    for epoch in range(start_epoch, args.max_epochs + 1):
        model.train()

        for i, (x, y) in enumerate(train_loader):
            if i == 0:
                print(f"[epoch {epoch}] forward...")

            x = x.to(device, dtype=torch.float32)
            y = y.to(device, dtype=torch.float32)
            optimizer.zero_grad(set_to_none=True)
            with autocast():
                yp = model(x)
                loss = loss_fn(y, yp)

            scaler.scale(loss).backward()
            scaler.step(optimizer)
            scaler.update()

            scheduler.step()
            global_step += 1

            loss_sum += loss.item()
            loss_count += 1



        if epoch % args.epoch_view == 0:
            train_avg = loss_sum / max(loss_count,1)
            val_avg = validate(model, val_loader, loss_fn, device)
            print(
                f"epoch {epoch} | iter {global_step} | train {train_avg:.6f} | val {val_avg:.6f} | lr {optimizer.param_groups[0]['lr']:.2e}"
            )
            loss_sum = 0.0
            loss_count = 0

        if epoch % args.epoch_save == 0:
            os.makedirs(args.model_dir, exist_ok=True)
            torch.save(
                {
                    "model_state_dict": model.state_dict(),
                    "optimizer_state_dict": optimizer.state_dict(),
                    "scheduler_state_dict": scheduler.state_dict(),
                    "epoch": epoch,
                    "global_step": global_step,
                },
                osp.join(args.model_dir, "model.pkl"),
            )
            print(f"******** model {epoch} saved ********")


            visualize_during_train(
                model=model,
                loader=test_loader,
                device=device,
                model_dir=args.model_dir,
                epoch = epoch,
                displayrange=args.displayrange
            )


def test(model, args, device):
    ckpt_path = osp.join(args.model_dir, args.test_model_name)

    if not osp.isfile(ckpt_path):
        print(f"No checkpoint found: {ckpt_path}")
        return

    state = torch.load(ckpt_path, map_location=device)
    model.load_state_dict(state["model_state_dict"])

    step = state.get("epoch", state.get("step", 0))
    print(f"[*] Test using checkpoint epoch {step}")

    save_dir = osp.join(args.model_dir, f"{args.type}_{step}")
    os.makedirs(save_dir, exist_ok=True)

    test_files = input(args.Data_Dir, args.type)
    test_dataset = CharlesDataset(
        test_files,
        args.in_channel,
        args.out_channel,
        args.image_H,
        args.image_W,
        None,
        args.label_slices,
        args.input_slices,
        mode="test",
    )
    test_loader = DataLoader(test_dataset, batch_size=1, shuffle=False)

    loss_fn = L1_loss()
    model.eval()

    with torch.no_grad():
        for i, (x, y) in enumerate(test_loader, 1):
            x = x.to(device, dtype=torch.float32)
            y = y.to(device, dtype=torch.float32)

            with autocast():
                yp = model(x)
                loss = loss_fn(yp, y)

            print(f"[{i}] test loss {loss.item():.6f}")
            scio.savemat(
                osp.join(save_dir, f"result{i}.mat"),
                {
                    "input": x[0].cpu().numpy(),
                    "label": y[0].cpu().numpy(),
                    "output": yp[0].cpu().numpy(),
                    "loss": loss.item(),
                },
            )


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--config", type=str, default="SL-MOLED.txt")
    args_cli = parser.parse_args()

    with open(args_cli.config, "r") as f:
        args = json.load(f)
    args = type("Args", (), args)

    os.environ["CUDA_VISIBLE_DEVICES"] = args.gpu
    device = torch.device("cuda:0")

    args.model_dir = osp.join(args.Model_Dir, args.Model_name)
    os.makedirs(args.model_dir, exist_ok=True)

    model = AttUNet3Plus(args.in_channel, args.out_channel).to(device)

    if args.type == "train":
        train(model, args, device)
    else:
        test(model, args, device)
