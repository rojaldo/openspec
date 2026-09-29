#!/usr/bin/env python3
"""Genera fondos y elementos de HUD comic-pop-art para Tetris.
Dibujo procedural con PIL (mismo enfoque que gen_png.py)."""
import os, math, random
from PIL import Image, ImageDraw, ImageFont, ImageFilter

INK = (20,17,15,255)
PAPER = (253,246,227,255)
COLORS = {
    'I':(62,201,240),'O':(255,217,61),'T':(176,108,255),'S':(79,208,106),
    'Z':(232,67,47),'J':(47,125,232),'L':(255,159,47),
}
ACCENT = (232,67,47,255)   # rojo comic
YELLOW = (255,217,61,255)

def hex2rgba(h):
    h=h.lstrip('#')
    return (int(h[0:2],16),int(h[2:4],16),int(h[4:6],16),255)

def load_font(size, bold=True, italic=False):
    base='/usr/share/fonts/truetype/dejavu/'
    names=[]
    if bold and italic: names=['DejaVuSans-BoldOblique.ttf','DejaVuSans-BoldItalic.ttf']
    elif bold: names=['DejaVuSans-Bold.ttf']
    elif italic: names=['DejaVuSans-Oblique.ttf']
    else: names=['DejaVuSans.ttf']
    for n in names:
        p=base+n
        if os.path.exists(p): return ImageFont.truetype(p,size)
    return ImageFont.load_default()

def halftone(img, spacing=14, dot_r=2.0, color=(0,0,0), alpha=34):
    """Superpone trama de puntos (efecto impresión comic)."""
    d=ImageDraw.Draw(img,'RGBA')
    W,H=img.size
    for y in range(0,H+spacing,spacing):
        for x in range(0,W+spacing,spacing):
            ox = spacing//2 if (y//spacing)%2 else 0
            d.ellipse([x+ox-dot_r,y-dot_r,x+ox+dot_r,y+dot_r], fill=color+(alpha,))

def speed_lines(img, count=40, color=(0,0,0), alpha=26):
    """Líneas de velocidad radiales (acción comic), desde fuera hacia el centro."""
    d=ImageDraw.Draw(img,'RGBA')
    W,H=img.size
    cx,cy=W/2,H/2
    rnd=random.Random(42)
    for _ in range(count):
        ang=rnd.uniform(0,math.tau)
        r0=rnd.uniform(0.45,0.65)*max(W,H)
        r1=max(W,H)*1.1
        x0,y0=cx+math.cos(ang)*r0, cy+math.sin(ang)*r0
        x1,y1=cx+math.cos(ang)*r1, cy+math.sin(ang)*r1
        w=rnd.choice([2,3,4])
        d.line([x0,y0,x1,y1], fill=color+(alpha,), width=w)

def starburst(size, color=YELLOW, ink=INK, points=12, inner=0.42):
    """Estrella/explosión tipo 'pow' rellena."""
    S=size
    img=Image.new('RGBA',(S,S),(0,0,0,0))
    d=ImageDraw.Draw(img)
    cx=cy=S/2
    R=S/2-4; r=R*inner
    pts=[]
    for i in range(points*2):
        ang=math.pi*i/points - math.pi/2
        rad=R if i%2==0 else r
        pts.append((cx+math.cos(ang)*rad, cy+math.sin(ang)*rad))
    d.polygon(pts, fill=color, outline=ink)
    # borde grueso
    d.line(pts+[pts[0]], fill=ink, width=max(3,S//60), joint='curve')
    return img

# ---------- FONDOS ----------
def bg_paper(w=480,h=720):
    """Fondo papel con halftone suave + bordes de viñeta."""
    img=Image.new('RGBA',(w,h),PAPER)
    halftone(img, spacing=13, dot_r=1.7, alpha=28)
    # borde doble de viñeta comic
    d=ImageDraw.Draw(img)
    m=10
    d.rectangle([m,m,w-m-1,h-m-1], outline=INK, width=6)
    d.rectangle([m+9,m+9,w-m-10,h-m-10], outline=(0,0,0,60), width=2)
    # esquinas con destello
    for (cx,cy) in [(m+16,m+16),(w-m-16,m+16),(m+16,h-m-16),(w-m-16,h-m-16)]:
        d.line([cx-7,cy,cx+7,cy], fill=YELLOW, width=4)
        d.line([cx,cy-7,cx,cy+7], fill=YELLOW, width=4)
    return img

def bg_sky_pop(w=480,h=720):
    """Cielo pop-art con rayos de sol y nubes halftone."""
    img=Image.new('RGBA',(w,h),hex2rgba('#8fd7f2'))
    d=ImageDraw.Draw(img)
    cx,cy=w/2,h*0.62
    # rayos
    for i in range(24):
        ang=math.tau*i/24
        x1,y1=cx+math.cos(ang)*max(w,h), cy+math.sin(ang)*max(w,h)
        if i%2==0:
            d.polygon([(cx,cy),(x1,y1),
                       (cx+math.cos(ang+0.12)*max(w,h), cy+math.sin(ang+0.12)*max(w,h))],
                      fill=(255,255,255,60))
    # sol
    d.ellipse([cx-90,cy-90,cx+90,cy+90], fill=YELLOW)
    halftone(img, 12, 1.6, alpha=22)
    # nubes comic
    def cloud(x,y,s):
        for dx,dy,rr in [(-s*0.5,0,s*0.45),(0,-s*0.2,s*0.55),(s*0.5,0,s*0.45),
                         (s*0.2,s*0.15,s*0.4),(-s*0.25,s*0.15,s*0.38)]:
            d.ellipse([x+dx-rr,y+dy-rr,x+dx+rr,y+dy+rr], fill=(255,255,255,235),
                      outline=INK, width=4)
    cloud(w*0.25,h*0.16,90); cloud(w*0.78,h*0.30,70)
    # borde viñeta
    d.rectangle([10,10,w-11,h-11], outline=INK, width=6)
    return img

def bg_action_burst(w=480,h=720):
    """Fondo oscuro con explosión central y líneas de velocidad."""
    img=Image.new('RGBA',(w,h),hex2rgba('#2a2438'))
    speed_lines(img, 70, color=(255,255,255), alpha=30)
    b=starburst(int(min(w,h)*0.9), color=YELLOW, points=14, inner=0.5)
    img.alpha_composite(b, ((w-b.width)//2,(h-b.height)//2))
    halftone(img, 12, 1.5, color=(255,255,255), alpha=18)
    d=ImageDraw.Draw(img)
    d.rectangle([10,10,w-11,h-11], outline=INK, width=6)
    return img

# ---------- HUD ----------
def panel(w,h,fill=(255,255,255,255), label=None, ink=INK, skew=0.0):
    """Panel con borde de tinta y sombra dura (estilo pegatina comic)."""
    img=Image.new('RGBA',(w+12,h+12),(0,0,0,0))
    d=ImageDraw.Draw(img)
    # sombra dura desplazada
    d.rounded_rectangle([8,8,8+w,8+h], radius=10, fill=(20,17,15,255))
    d.rounded_rectangle([0,0,w,h], radius=10, fill=fill, outline=ink, width=5)
    return img

def score_panel(w=220,h=96,fill=(255,255,255,255),accent=ACCENT,
                label="SCORE",value="042750"):
    img=panel(w,h,fill)
    d=ImageDraw.Draw(img)
    lf=load_font(20); d.text((16,10), label, font=lf, fill=INK)
    d.line([16,40,120,40], fill=accent, width=4)
    vf=load_font(40)
    d.text((16,44), value, font=vf, fill=INK)
    return img

def level_panel(w=150,h=96,fill=(20,17,15,255)):
    img=panel(w,h,fill)
    d=ImageDraw.Draw(img)
    lf=load_font(20)
    d.text((16,10),"LEVEL", font=lf, fill=(255,255,255,255))
    d.line([16,40,90,40], fill=YELLOW, width=4)
    vf=load_font(44)
    d.text((16,44),"07", font=vf, fill=YELLOW)
    return img

def lines_panel(w=170,h=80):
    img=panel(w,h,(255,255,255,255))
    d=ImageDraw.Draw(img)
    d.text((16,8),"LINES", font=load_font(18), fill=INK)
    d.text((16,36),"148", font=load_font(34), fill=ACCENT)
    return img

def next_panel(w=180,h=200):
    """Panel 'NEXT' con marco interior para la pieza siguiente."""
    img=panel(w,h,(255,255,255,255))
    d=ImageDraw.Draw(img)
    d.text((16,10),"NEXT", font=load_font(20), fill=INK)
    d.rectangle([16,46,w-16,h-16], outline=INK, width=4)
    halftone(img.crop((0,0,w,h)), 10, 1.4, alpha=22)  # no-op visual seguro
    return img

def game_over_banner(w=420,h=180):
    """Cartel GAME OVER estilo explosion."""
    img=Image.new('RGBA',(w,h),(0,0,0,0))
    burst=starburst(int(h*1.05), color=ACCENT, points=16, inner=0.45)
    img.alpha_composite(burst, ((w-burst.width)//2,(h-burst.height)//2))
    d=ImageDraw.Draw(img)
    f=load_font(int(h*0.34))
    t="GAME OVER"
    tw=d.textlength(t,font=f)
    # borde tinta + relleno amarillo
    d.text(((w-tw)/2, h*0.30), t, font=f, fill=YELLOW,
           stroke_width=max(5,int(h*0.03)), stroke_fill=INK)
    return img

def tetris_banner(w=440,h=180):
    img=Image.new('RGBA',(w,h),(0,0,0,0))
    d=ImageDraw.Draw(img)
    f=load_font(int(h*0.5))
    t="TETRIS!"
    tw=d.textlength(t,font=f)
    d.text(((w-tw)/2,h*0.20), t, font=f, fill=YELLOW,
           stroke_width=10, stroke_fill=INK)
    # chispas
    rnd=random.Random(7)
    for _ in range(18):
        x=rnd.uniform(w*0.1,w*0.9); y=rnd.uniform(h*0.05,h*0.5)
        s=rnd.uniform(4,9)
        d.line([x-s,y,x+s,y], fill=INK, width=4)
        d.line([x,y-s,x,y+s], fill=INK, width=4)
    return img

def bar(filled=0.6, w=200, h=26, fill=COLORS['S']):
    """Barra de progreso/tempo comic."""
    img=Image.new('RGBA',(w+8,h+8),(0,0,0,0))
    d=ImageDraw.Draw(img)
    d.rounded_rectangle([4,4,w+4,h+4], radius=8, fill=(255,255,255,255),
                        outline=INK, width=4)
    fw=int((w-4)*filled)
    if fw>0:
        d.rounded_rectangle([6,6,6+fw,h+2], radius=6, fill=fill+(255,) if len(fill)==3 else fill)
    return img

if __name__=='__main__':
    out='textures'
    os.makedirs(out,exist_ok=True)
    # Fondos 480x720 (viewport demo)
    bg_paper().save(f'{out}/bg_paper.png')
    bg_sky_pop().save(f'{out}/bg_sky_pop.png')
    bg_action_burst().save(f'{out}/bg_action_burst.png')
    # HUD
    score_panel().save(f'{out}/hud_score.png')
    level_panel().save(f'{out}/hud_level.png')
    lines_panel().save(f'{out}/hud_lines.png')
    next_panel().save(f'{out}/hud_next.png')
    game_over_banner().save(f'{out}/hud_gameover.png')
    tetris_banner().save(f'{out}/hud_tetris.png')
    bar(0.65,200,26).save(f'{out}/hud_bar.png')
    print("Fondos+HUD:", [f for f in sorted(os.listdir(out)) if f.startswith(('bg_','hud_'))])
