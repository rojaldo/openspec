#!/usr/bin/env python3
"""Genera assets PNG comic-pop-art para Tetris (Godot) dibujando con PIL.
Sin dependencia del renderizador SVG roto de ImageMagick."""
import os, math
from PIL import Image, ImageDraw, ImageFont

COLORS = {'I':'#3ec9f0','O':'#ffd93d','T':'#b06cff','S':'#4fd06a',
          'Z':'#e8432f','J':'#2f7de8','L':'#ff9f2f'}
INK = (20,17,15,255)
SHAPES = {
 'I':[[0,0,0,0],[1,1,1,1],[0,0,0,0],[0,0,0,0]],
 'O':[[1,1],[1,1]],
 'T':[[0,1,0],[1,1,1],[0,0,0]],
 'S':[[0,1,1],[1,1,0],[0,0,0]],
 'Z':[[1,1,0],[0,1,1],[0,0,0]],
 'J':[[1,0,0],[1,1,1],[0,0,0]],
 'L':[[0,0,1],[1,1,1],[0,0,0]],
}
LBL = {'blam':'BLAM!','boom':'BOOM!','wham':'WHAM!','zap':'ZAP!',
       'krak':'KRAK!','bam':'BAM!','tetris':'TETRIS!'}
SFXC = {'blam':'#e8432f','boom':'#ff9f2f','wham':'#b06cff','zap':'#3ec9f0',
        'krak':'#4fd06a','bam':'#ffd93d','tetris':'#2f7de8'}

def hex2rgba(h):
    h=h.lstrip('#')
    return (int(h[0:2],16),int(h[2:4],16),int(h[4:6],16),255)

def ss(size):
    return size*4  # supersample 4x para bordes suaves

def draw_block(draw, x, y, s, color, radius_frac=0.14, ink_w=None):
    """Dibuja un bloque glossy con borde de tinta. Coordenadas en px (ya supersampleados)."""
    c = hex2rgba(color)
    r = s*radius_frac
    ink_w = ink_w if ink_w else max(2, s*0.06)
    # base sólida (el gradiente se aplica luego pixel a pixel)
    draw.rounded_rectangle([x, y, x+s, y+s], radius=r, fill=c,
                           outline=INK, width=int(ink_w))
    # sombra inferior suave (banda)
    # highlight glossy (rect redondeado blanco, arriba-izq)
    pad = s*0.13
    hw, hh = s*0.30, s*0.24
    draw.rounded_rectangle([x+pad, y+pad, x+pad+hw, y+pad+hh],
                           radius=s*0.07, fill=(255,255,255,190))
    # destello puntual
    draw.ellipse([x+s*0.68, y+s*0.70, x+s*0.76, y+s*0.78], fill=(0,0,0,45))

def apply_gradient(canvas, x, y, s, color):
    """Aplica gradiente diagonal claro->oscuro sobre la zona del bloque (dentro del borde)."""
    base = hex2rgba(color)[:3]
    px = canvas.load()
    xi, yi = int(x), int(y)
    inset = int(s*0.09)
    for j in range(yi+inset, yi+int(s)-inset):
        for i in range(xi+inset, xi+int(s)-inset):
            if i<0 or j<0 or i>=canvas.width or j>=canvas.height: continue
            fx = (i-xi)/s; fy=(j-yi)/s
            t = (fx+fy)/2.0  # 0 arriba-izq -> 1 abajo-der
            if t<0.45:
                k = t/0.45*0.45  # hacia blanco
                rr = base[0]+(255-base[0])*k*0.55
                gg = base[1]+(255-base[1])*k*0.55
                bb = base[2]+(255-base[2])*k*0.55
            else:
                k = (t-0.45)/0.55
                rr = base[0]*(1-k*0.35)
                gg = base[1]*(1-k*0.35)
                bb = base[2]*(1-k*0.35)
            a = px[i,j][3]
            if a>0:  # solo donde hay bloque
                px[i,j] = (int(rr),int(gg),int(bb), a)

def make_block(color, out_size):
    S = ss(out_size)
    img = Image.new('RGBA', (S, S), (0,0,0,0))
    d = ImageDraw.Draw(img)
    draw_block(d, 0, 0, S, color)
    apply_gradient(img, 0, 0, S, color)
    img = img.resize((out_size, out_size), Image.LANCZOS)
    return img

def make_piece(key, cell_out):
    m = SHAPES[key]; color=COLORS[key]
    rows=len(m); cols=len(m[0])
    cs = ss(cell_out)      # celda supersampleada
    gap = ss(3)            # separación entre bloques (px supersampleados)
    W = cols*cs + ss(6); H = rows*cs + ss(6)
    img = Image.new('RGBA', (W,H), (0,0,0,0))
    d = ImageDraw.Draw(img)
    for r in range(rows):
        for q in range(cols):
            if m[r][q]:
                x=q*cs+ss(3); y=r*cs+ss(3)
                draw_block(d, x, y, cs-gap*2, color)
    for r in range(rows):
        for q in range(cols):
            if m[r][q]:
                x=q*cs+ss(3); y=r*cs+ss(3)
                apply_gradient(img, x, y, cs-gap*2, color)
    outW = int(cols*cell_out + 6); outH = int(rows*cell_out + 6)
    return img.resize((outW, outH), Image.LANCZOS)

def load_font(size):
    paths = [
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-BoldItalic.ttf',
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
    ]
    for p in paths:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()

def make_sfx(key, w=512, h=214):
    text = LBL[key]; color = hex2rgba(SFXC[key])[:3]
    S = 2  # supersample
    W, H = w*S, h*S
    img = Image.new('RGBA',(W,H),(0,0,0,0))
    d = ImageDraw.Draw(img)
    # texto rotado: dibujamos en capa aparte y rotamos
    layer = Image.new('RGBA',(W,H),(0,0,0,0))
    ld = ImageDraw.Draw(layer)
    fs = int(H*0.66)
    font = load_font(fs)
    bbox = ld.textbbox((0,0), text, font=font)
    tw, th = bbox[2]-bbox[0], bbox[3]-bbox[1]
    tx = (W-tw)//2 - bbox[0]; ty=(H-th)//2 - bbox[1]
    # borde de tinta (stroke grueso simulado con offsets)
    stroke = max(6, int(H*0.045))
    for dx in range(-stroke, stroke+1, max(1,stroke//3)):
        for dy in range(-stroke, stroke+1, max(1,stroke//3)):
            if dx*dx+dy*dy <= stroke*stroke:
                ld.text((tx+dx, ty+dy), text, font=font, fill=INK)
    # relleno degradado simple por bandas (arriba claro, abajo oscuro)
    fill_layer = Image.new('RGBA',(W,H),(0,0,0,0))
    fd = ImageDraw.Draw(fill_layer)
    fd.text((tx,ty), text, font=font, fill=color+(255,))
    apply_text_gradient(fill_layer, color)
    layer.alpha_composite(fill_layer)
    layer = layer.rotate(-4, resample=Image.BICUBIC, expand=False)
    img.alpha_composite(layer)
    return img.resize((w,h), Image.LANCZOS)

def apply_text_gradient(img, base):
    px = img.load()
    W,H = img.size
    for y in range(H):
        t = y/H
        k = 0.30 if t<0.5 else -0.30
        for x in range(0, W):
            r,g,b,a = px[x,y]
            if a>0:
                nr = min(255,max(0, int(r + (255-r)*k if k>0 else r*(1+k))))
                ng = min(255,max(0, int(g + (255-g)*k if k>0 else g*(1+k))))
                nb = min(255,max(0, int(b + (255-b)*k if k>0 else b*(1+k))))
                px[x,y]=(nr,ng,nb,a)

if __name__ == '__main__':
    out='textures'
    os.makedirs(out, exist_ok=True)
    for k,c in COLORS.items():
        make_block(c,128).save(f'{out}/block_{k}_128.png')
        make_block(c,64).save(f'{out}/block_{k}_64.png')
        make_block(c,64).save(f'{out}/block_{k}.png')
        make_block(c,32).save(f'{out}/block_{k}_32.png')
    for k in SHAPES:
        make_piece(k,64).save(f'{out}/piece_{k}.png')
    for k in LBL:
        make_sfx(k).save(f'{out}/sfx_{k}.png')
    print("Hecho:", sorted(os.listdir(out)))
