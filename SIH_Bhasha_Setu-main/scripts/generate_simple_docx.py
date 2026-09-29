import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

def set_cell_background(cell, fill_hex):
    tcPr = cell._element.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), fill_hex)
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._element.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for side, value in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{side}')
        node.set(qn('w:w'), str(value))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def create_simple_report(output_path):
    doc = docx.Document()
    for s in doc.sections:
        s.top_margin = Inches(1.0)
        s.bottom_margin = Inches(1.0)
        s.left_margin = Inches(1.0)
        s.right_margin = Inches(1.0)

    PRIMARY = RGBColor(35, 139, 69)      # Green
    DARK = RGBColor(23, 33, 43)         # Dark text
    MUTED = RGBColor(102, 112, 133)     # Grey text

    # Header
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r1 = p.add_run("SMART INDIA HACKATHON (SIH)\n")
    r1.font.size = Pt(11)
    r1.font.bold = True
    r1.font.color.rgb = PRIMARY

    r2 = p.add_run("Bhasha Setu (भाषा | SETU)\n")
    r2.font.size = Pt(22)
    r2.font.bold = True
    r2.font.color.rgb = DARK

    r3 = p.add_run("Simple Project Report & Working Guide\nBridging Tribal Languages | Simple, Offline Translation for Teachers & Doctors\n")
    r3.font.size = Pt(11)
    r3.font.italic = True
    r3.font.color.rgb = MUTED

    def add_h1(text):
        h = doc.add_paragraph()
        h.paragraph_format.space_before = Pt(14)
        h.paragraph_format.space_after = Pt(4)
        r = h.add_run(text)
        r.font.size = Pt(13)
        r.font.bold = True
        r.font.color.rgb = PRIMARY

    def add_h2(text):
        h = doc.add_paragraph()
        h.paragraph_format.space_before = Pt(10)
        h.paragraph_format.space_after = Pt(3)
        r = h.add_run(text)
        r.font.size = Pt(11)
        r.font.bold = True
        r.font.color.rgb = DARK

    def add_p(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(5)
        p.paragraph_format.line_spacing = 1.15
        r = p.add_run(text)
        r.font.size = Pt(10)
        r.font.color.rgb = DARK

    def add_bullet(text):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(3)
        r = p.add_run(text)
        r.font.size = Pt(10)
        r.font.color.rgb = DARK

    add_h1("1. What is the Problem in Simple Words?")
    add_p(
        "In India, more than 10 crore (104 million) tribal people speak their own local languages like Santali, Ho, and Mundari. "
        "When new teachers go to teach in village schools, or when doctors and nurses (ASHA workers) visit tribal villages, they cannot understand each other. "
        "The teacher speaks Hindi, but the children speak Santali. As a result, children cannot learn and often leave school."
    )
    add_p(
        "Why can't they just use Google Translate? Because in remote forest villages, there is NO INTERNET connection. "
        "Also, Google and AI apps make big mistakes on tribal languages because they do not have the right words."
    )

    add_h1("2. Our Solution: What is Bhasha Setu?")
    add_p(
        "Bhasha Setu is an easy-to-use translation app built specifically for tribal languages. "
        "Its biggest superpower: IT WORKS 100% OFFLINE WITH NO INTERNET. You can turn on Airplane Mode, and the app still translates text, voice, and pictures instantly."
    )

    add_h1("3. Key Features Explained Simply")
    add_h2("A. Voice-to-Voice (Talking Like a Walkie-Talkie)")
    add_bullet("Two people can talk to each other directly.")
    add_bullet("A teacher speaks in Hindi into the phone microphone.")
    add_bullet("The app listens, stops automatically when the teacher finishes speaking, translates it into Santali, and speaks it out loud.")
    add_bullet("When the student or parent speaks in Santali, it translates back into Hindi.")

    add_h2("B. 1-Tap Emergency Button (For Snakebites & Hospital)")
    add_bullet("In emergency situations, typing is too slow.")
    add_bullet("ASHA health workers can just tap one button (like 'Snakebite' or 'High Fever').")
    add_bullet("The app instantly speaks loud emergency instructions in Santali to save lives.")

    add_h2("C. Teacher Classroom Mode")
    add_bullet("As the teacher teaches in Hindi, the screen shows live subtitles in Santali.")
    add_bullet("It automatically collects important words from the lesson and creates flashcards so kids can study at home.")

    add_h2("D. Camera Photo Translation (OCR)")
    add_bullet("Teachers can take a picture of a book, notice board, or poster.")
    add_bullet("The app reads the words from the photo and translates them on screen.")

    add_h2("E. Zero AI Mistakes (No Fake Words)")
    add_bullet("Normal AI apps guess words and give wrong medical or school answers.")
    add_bullet("Bhasha Setu uses a verified dictionary of 6,780 real Santali words, so it never invents fake words.")

    add_h2("F. Fun Learning Studio")
    add_bullet("Children can learn to write the Santali Ol Chiki script by drawing with their finger on the screen, playing vocabulary games, and earning points.")

    add_h1("4. Quick Comparison: Bhasha Setu vs Normal Apps")
    t = doc.add_table(rows=5, cols=3)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Feature", "Google Translate / Others", "Bhasha Setu"]
    for j, h in enumerate(headers):
        c = t.rows[0].cells[j]
        c.text = h
        c.paragraphs[0].runs[0].font.bold = True
        c.paragraphs[0].runs[0].font.size = Pt(9.5)
        set_cell_background(c, "238B45")
        c.paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)
        set_cell_margins(c, 80, 80, 100, 100)

    rows = [
        ("Internet Needed?", "Yes, requires 4G/Wi-Fi", "NO (Works in Airplane Mode)"),
        ("Speaks Santali Out Loud?", "Very poor / None", "Yes, with native voice guide"),
        ("Emergency Buttons?", "No", "Yes, 1-tap medical audio"),
        ("Phone Cost Required", "Expensive smartphone", "Works on any simple 2GB phone")
    ]
    for i, r in enumerate(rows):
        row_cells = t.rows[i+1].cells
        for j, val in enumerate(r):
            c = row_cells[j]
            c.text = val
            c.paragraphs[0].runs[0].font.size = Pt(9)
            set_cell_background(c, "F9F6F0" if i % 2 == 0 else "FFFFFF")
            set_cell_margins(c, 60, 60, 80, 80)

    add_h1("5. Conclusion in One Sentence")
    add_p(
        "Bhasha Setu is an offline helper that helps teachers teach, doctors treat, and tribal children learn in their own mother tongue without needing internet."
    )

    doc.save(output_path)
    print(f"Generated: {output_path}")

def create_simple_script(output_path):
    doc = docx.Document()
    for s in doc.sections:
        s.top_margin = Inches(1.0)
        s.bottom_margin = Inches(1.0)
        s.left_margin = Inches(1.0)
        s.right_margin = Inches(1.0)

    PRIMARY = RGBColor(35, 139, 69)
    DARK = RGBColor(23, 33, 43)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r1 = p.add_run("SMART INDIA HACKATHON — DEMO VIDEO SCRIPT\n")
    r1.font.bold = True
    r1.font.size = Pt(11)
    r1.font.color.rgb = PRIMARY
    r2 = p.add_run("Bhasha Setu — Easy to Speak Demo Script\n")
    r2.font.bold = True
    r2.font.size = Pt(20)
    r2.font.color.rgb = DARK

    t = doc.add_table(rows=7, cols=3)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Time", "What to Show on Screen", "What to Say (Simple Words)"]
    for j, h in enumerate(headers):
        c = t.rows[0].cells[j]
        c.text = h
        c.paragraphs[0].runs[0].font.bold = True
        c.paragraphs[0].runs[0].font.size = Pt(10)
        set_cell_background(c, "238B45")
        c.paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)
        set_cell_margins(c, 80, 80, 100, 100)

    steps = [
        ("0:00 - 0:30\n(The Problem)", 
         "Show home page + show a phone with 'No Internet Connection'", 
         "Hello everyone! In India, over 10 crore tribal people speak local languages like Santali. When a teacher goes to a village school, they speak Hindi, but the children only know Santali. This creates a big language problem. Normal translation apps don't work because there is NO INTERNET in these villages. That is why we built Bhasha Setu!"),

        ("0:30 - 1:00\n(Offline Proof)", 
         "Turn on Airplane Mode on your laptop or phone. Type Hindi: 'यह गाय है।' and click Translate.", 
         "Here is our biggest feature: look, I am turning on Airplane Mode. The Wi-Fi is completely OFF! Now I type in Hindi, and with one click, it translates into Santali Ol Chiki immediately. It needs zero internet because all 6,780 words are saved right inside the phone!"),

        ("1:00 - 1:40\n(Voice to Voice)", 
         "Open Voice-to-Voice page. Click Red Mic. Speak Hindi: 'आपका नाम क्या है?'. App translates and speaks Santali.", 
         "Now let's see two people talking. The teacher speaks Hindi into the phone: 'आपका नाम क्या है?' The app automatically listens, stops when you finish speaking, and speaks out the Santali translation: 'Amag nyutum ched?' And when the student speaks back in Santali, it translates back to Hindi. It is just like a live talkie!"),

        ("1:40 - 2:15\n(Emergency Mode)", 
         "Open Emergency Mode. Click 'Snakebite'. The app plays loud Santali voice.", 
         "In serious medical situations, like a snakebite, a doctor or ASHA nurse cannot waste time typing. With our 1-Tap Emergency button, they just tap 'Snakebite', and the phone immediately speaks loud Santali instructions to help save the patient's life."),

        ("2:15 - 2:50\n(Teacher & Camera)", 
         "Show Teacher Mode (live classroom subtitles + download notes) and show Camera OCR translating a photo.", 
         "For classrooms, our Teacher Mode writes live subtitles as the teacher speaks and automatically makes study flashcards for students. And with Camera OCR, teachers can simply take a photo of a textbook or blackboard to translate it instantly."),

        ("2:50 - 3:15\n(Closing)", 
         "Show the app running smoothly on mobile view. Presenter says thank you.", 
         "Bhasha Setu is free, 100% offline, and works on any simple phone. It connects teachers with students, and doctors with patients. Thank you so much!")
    ]

    for i, r in enumerate(steps):
        row_cells = t.rows[i+1].cells
        for j, val in enumerate(r):
            c = row_cells[j]
            c.text = val
            c.paragraphs[0].runs[0].font.size = Pt(9.5)
            set_cell_background(c, "F9F6F0" if i % 2 == 0 else "FFFFFF")
            set_cell_margins(c, 70, 70, 90, 90)

    doc.save(output_path)
    print(f"Generated: {output_path}")

if __name__ == "__main__":
    base = r"d:\BASHA SETU\SIH_Bhasha_Setu-main"
    create_simple_report(os.path.join(base, "SIH_Bhasha_Setu_Project_Report_Simple.docx"))
    create_simple_script(os.path.join(base, "SIH_Bhasha_Setu_Demo_Video_Script_Simple.docx"))
