#!/usr/bin/env python3
"""Genera .import files de Godot 4 para las texturas (nearest, sin mipmaps).

AVISO: Godot reimporta y reescribe estos ficheros solo al abrir el proyecto.
Generarlos a mano solo tiene sentido para fijar el modo de compresion antes
de la primera importacion. Si el formato no coincide EXACTAMENTE con el que
escribe el motor, el proyecto puede no arrancar (path= apuntando al propio
PNG provocaba recursion en el motor y abortaba).

Regla: `path` y `dest_files` apuntan al .ctex de .godot/imported/, y
`source_file` lleva el prefijo res://.
"""
import os, hashlib

PNG_PARAMS = """compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1"""

SVG_PARAMS = """svg/scale=1.0
editor/scale_with_editor_scale=false
editor/convert_colors_with_editor_theme=false"""


def import_stub(rel_path, res_path):
    """Crea un .import compatible con Godot 4.x (importador 'texture')."""
    is_png = os.path.splitext(rel_path)[1].lower() == '.png'
    importer = 'texture' if is_png else 'svg'
    # Godot deriva el nombre del .ctex del md5 de la RUTA res://, no del
    # contenido del fichero. El uid son los 13 primeros caracteres del mismo
    # md5, por eso ambos comparten prefijo.
    h = hashlib.md5(res_path.encode()).hexdigest()
    uid = 'uid://' + h[:13]
    base = os.path.basename(rel_path)
    ctex = f"res://.godot/imported/{base}-{h}.ctex"
    params = PNG_PARAMS if is_png else SVG_PARAMS
    out = f"""[remap]

importer="{importer}"
type="CompressedTexture2D"
uid="{uid}"
path="{ctex}"
metadata={{
"vram_texture": false
}}

[deps]

source_file="{res_path}"
dest_files=["{ctex}"]

[params]

{params}
"""
    with open(rel_path + '.import', 'w') as f:
        f.write(out)


if __name__ == '__main__':
    n = 0
    for root, _, files in os.walk('textures'):
        for fn in sorted(files):
            if fn.endswith('.png') or fn.endswith('.svg'):
                p = os.path.join(root, fn)
                import_stub(p, 'res://' + p.replace(os.sep, '/'))
                n += 1
    print(f"{n} archivos .import generados")
