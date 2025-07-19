import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import os

class ChatBot:
    def __init__(self, model_path="trained_model"):
        self.model_path = model_path
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.tokenizer = None
        self.model = None
        self.load_model()
        
    def load_model(self):
        if not os.path.exists(self.model_path):
            print(f"❌ ไม่พบโมเดลที่: {self.model_path}")
            return
        try:
            print(f"📦 โหลดโมเดลจาก: {self.model_path}")
            self.tokenizer = AutoTokenizer.from_pretrained(self.model_path)
            self.model = AutoModelForSeq2SeqLM.from_pretrained(self.model_path)
            self.model.to(self.device)
            self.model.eval()
            print("✅ โหลดโมเดลเสร็จสิ้น")
        except Exception as e:
            print(f"❌ เกิดข้อผิดพลาดในการโหลดโมเดล: {e}")

    def generate_answer(self, input_text, max_length=128, num_beams=4, temperature=0.7):
        if not self.model or not self.tokenizer:
            return "❌ โมเดลยังไม่ได้โหลด"
        if not input_text.strip():
            return "⚠️ กรุณาใส่คำถาม"

        try:
            input_ids = self.tokenizer.encode(
                input_text, return_tensors="pt", truncation=True, max_length=512
            ).to(self.device)
            with torch.no_grad():
                outputs = self.model.generate(
                    input_ids, max_length=max_length,
                    num_beams=num_beams, temperature=temperature,
                    do_sample=True, pad_token_id=self.tokenizer.pad_token_id,
                    eos_token_id=self.tokenizer.eos_token_id
                )
            decoded = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            return decoded.strip()
        except Exception as e:
            return f"[Error]: {e}"

    def chat(self):
        print("🤖 ยินดีต้อนรับ! พิมพ์คำถามของคุณ")
        print("พิมพ์ 'exit' หรือ 'ออก' เพื่อจบ")
        print("-" * 40)
        while True:
            try:
                query = input("🧠 คุณ: ").strip()
                if query.lower() in ["exit", "ออก", "bye", "quit"]:
                    print("👋 ลาก่อน")
                    break
                answer = self.generate_answer(query)
                print(f"🤖 บอท: {answer}")
                print("-" * 40)
            except KeyboardInterrupt:
                print("\n👋 ลาก่อน")
                break

if __name__ == "__main__":
    bot = ChatBot()
    if bot.model:
        bot.chat()
