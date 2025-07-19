import json
import torch
from torch.utils.data import Dataset, DataLoader
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, AdamW, get_linear_schedule_with_warmup
from tqdm import tqdm
import os

model_name = "google/mt5-small"
json_path = "data/intents_train.json"  # ✅ เปลี่ยนให้ตรง path ของคุณ
save_dir = "trained_model"

class Text2TextDataset(Dataset):
    def __init__(self, data, tokenizer, max_input_len=512, max_output_len=128):
        self.data = data
        self.tokenizer = tokenizer
        self.max_input_len = max_input_len
        self.max_output_len = max_output_len

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        item = self.data[idx]
        input_enc = self.tokenizer(
            item["input"], padding="max_length", truncation=True,
            max_length=self.max_input_len, return_tensors="pt"
        )
        output_enc = self.tokenizer(
            item["output"], padding="max_length", truncation=True,
            max_length=self.max_output_len, return_tensors="pt"
        )
        return {
            "input_ids": input_enc["input_ids"].squeeze(),
            "attention_mask": input_enc["attention_mask"].squeeze(),
            "labels": torch.where(
                output_enc["input_ids"] == self.tokenizer.pad_token_id,
                torch.tensor(-100),
                output_enc["input_ids"]
            ).squeeze()
        }

def validate_data(data):
    if not data:
        raise ValueError("❌ ข้อมูลว่าง")
    for i, item in enumerate(data):
        if "input" not in item or "output" not in item:
            raise ValueError(f"❌ แถวที่ {i} ขาด input หรือ output")
    print(f"✅ ตรวจสอบข้อมูลผ่าน จำนวน: {len(data)} แถว")
    return True

def train(model, dataset, tokenizer, epochs=3, batch_size=4, lr=5e-5, warmup_steps=100):
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)
    optimizer = AdamW(model.parameters(), lr=lr)
    total_steps = len(dataloader) * epochs
    scheduler = get_linear_schedule_with_warmup(
        optimizer, warmup_steps, total_steps
    )

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)
    model.train()

    best_loss = float("inf")
    for epoch in range(epochs):
        total_loss = 0
        pbar = tqdm(dataloader, desc=f"Epoch {epoch+1}/{epochs}")
        for batch in pbar:
            input_ids = batch["input_ids"].to(device)
            attention_mask = batch["attention_mask"].to(device)
            labels = batch["labels"].to(device)

            optimizer.zero_grad()
            outputs = model(input_ids=input_ids, attention_mask=attention_mask, labels=labels)
            loss = outputs.loss
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            optimizer.step()
            scheduler.step()

            total_loss += loss.item()
            pbar.set_postfix({"loss": f"{loss.item():.4f}"})

        avg_loss = total_loss / len(dataloader)
        print(f"\n📉 Avg Loss: {avg_loss:.4f}")

        if avg_loss < best_loss:
            best_loss = avg_loss
            model.save_pretrained(save_dir)
            tokenizer.save_pretrained(save_dir)
            print(f"✅ บันทึกโมเดลใหม่ที่ดีที่สุด (Loss={best_loss:.4f})")

if __name__ == "__main__":
    if not os.path.exists(json_path):
        print(f"❌ ไม่พบไฟล์ {json_path}")
        exit()

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    validate_data(data)

    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
    dataset = Text2TextDataset(data, tokenizer)

    print("🚀 เริ่มเทรนโมเดล...")
    train(model, dataset, tokenizer)
