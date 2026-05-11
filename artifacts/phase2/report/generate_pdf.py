#!/usr/bin/env python3
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
import os

md_file = os.path.join(os.path.dirname(__file__), 'report.md')
pdf_file = os.path.join(os.path.dirname(__file__), 'phase2_report.pdf')

def md_to_text(md_path):
    with open(md_path, 'r') as f:
        return f.read()

def generate_pdf(text, out_path):
    c = canvas.Canvas(out_path, pagesize=letter)
    width, height = letter
    margin = 40
    y = height - margin
    for line in text.splitlines():
        if y < margin:
            c.showPage()
            y = height - margin
        c.setFont('Helvetica', 10)
        c.drawString(margin, y, line[:120])
        y -= 12
    c.save()

if __name__ == '__main__':
    text = md_to_text(md_file)
    generate_pdf(text, pdf_file)
    print('Generated', pdf_file)
