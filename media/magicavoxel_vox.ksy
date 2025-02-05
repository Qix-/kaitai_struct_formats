meta:
  id: magicavoxel_vox
  title: MagicaVoxel File
  application: MagicaVoxel
  file-extension: vox
  xref:
    pronom: fmt/976
    wikidata: Q50374901
  license: MIT
  ks-version: 0.9 # for doc-ref array
  endian: le
doc-ref:
  - https://ephtracy.github.io/ MagicaVoxel Homepage
  - https://github.com/ephtracy/voxel-model/blob/master/MagicaVoxel-file-format-vox.txt Format Description
seq:
  - id: magic
    contents: 'VOX '
  - id: version
    type: u4
    doc: 150 expected
  - id: main
    type: chunk
types:
  chunk:
    seq:
      - id: chunk_id
        type: u4be
        enum: chunk_type
      - id: num_bytes_of_chunk_content
        type: u4
      - id: num_bytes_of_children_chunks
        type: u4
      - id: chunk_content
        if: num_bytes_of_chunk_content != 0
        size: num_bytes_of_chunk_content
        type:
          switch-on: chunk_id
          cases:
            'chunk_type::pack': pack
            'chunk_type::size': size
            'chunk_type::xyzi': xyzi
            'chunk_type::rgba': rgba
            'chunk_type::matt': matt
            'chunk_type::ntrn': ntrn
            'chunk_type::nshp': nshp
            'chunk_type::ngrp': ngrp
      - id: children_chunks
        if: num_bytes_of_children_chunks != 0
        type: chunk
        repeat: eos
  pack:
    seq:
      - id: num_models
        type: u4
  size:
    seq:
      - id: size_x
        type: u4
      - id: size_y
        type: u4
      - id: size_z
        type: u4
  xyzi:
    seq:
      - id: num_voxels
        type: u4
      - id: voxels
        type: voxel
        repeat: expr
        repeat-expr: num_voxels
  rgba:
    seq:
      - id: colors
        type: color
        repeat: expr
        repeat-expr: 256
  voxel:
    seq:
      - id: x
        type: u1
      - id: y
        type: u1
      - id: z
        type: u1
      - id: color_index
        type: u1
  color:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
      - id: a
        type: u1
  matt:
    seq:
      - id: id
        type: u4
      - id: material_type
        type: u4
        enum: material_type
      - id: material_weight
        type: f4
      - id: property_bits
        type: u4
        # .to_i not implemented for C# runtime yet
        #enum: property_bits_type
      - id: plastic
        if: has_plastic
        type: f4
      - id: roughness
        if: has_roughness
        type: f4
      - id: specular
        if: has_specular
        type: f4
      - id: ior
        if: has_ior
        type: f4
      - id: attenuation
        if: has_attenuation
        type: f4
      - id: power
        if: has_power
        type: f4
      - id: glow
        if: has_glow
        type: f4
      - id: is_total_power
        if: has_is_total_power
        type: f4
    instances:
      has_plastic:
        value: '(property_bits & 1) != 0'
      has_roughness:
        value: '(property_bits & 2) != 0'
      has_specular:
        value: '(property_bits & 4) != 0'
      has_ior:
        value: '(property_bits & 8) != 0'
      has_attenuation:
        value: '(property_bits & 16) != 0'
      has_power:
        value: '(property_bits & 32) != 0'
      has_glow:
        value: '(property_bits & 64) != 0'
      has_is_total_power:
        value: '(property_bits & 128) != 0'
  ntrn:
    seq:
      - id: node_id
        type: u4
      - id: attributes
        type: dict
      - id: child_node_id
        type: u4
      - id: reserved_id
        type: u4
      - id: layer_id
        type: u4
      - id: num_frames
        type: u4
      - id: frames
        type: dict
        repeat: expr
        repeat-expr: num_frames
  nshp:
    seq:
      - id: node_id
        type: u4
      - id: attributes
        type: dict
      - id: num_models
        type: u4
      - id: models
        type: model
        repeat: expr
        repeat-expr: num_models
    types:
      model:
        seq:
          - id: model_id
            type: u4
          - id: attributes
            type: dict
  ngrp:
    seq:
      - id: node_id
        type: u4
      - id: attributes
        type: dict
      - id: num_children
        type: u4
      - id: children
        type: u4
        repeat: expr
        repeat-expr: num_children
  dict:
    seq:
      - id: num_pairs
        type: u4
      - id: pairs
        type: pair
        repeat: expr
        repeat-expr: num_pairs
    types:
      pair:
        seq:
          - id: key
            type: pstring
          - id: value
            type: pstring
  pstring:
    seq:
      - id: len
        type: u4
      - id: bytes
        type: str
        encoding: ascii
        size: len
enums:
  chunk_type:
    0x4d41494e: main
    0x5041434b: pack
    0x53495a45: size
    0x58595a49: xyzi
    0x52474241: rgba
    0x4d415454: matt
    0x6e54524e: ntrn
    0x6e534850: nshp
    0x6e475250: ngrp
  material_type:
    0: diffuse
    1: metal
    2: glass
    3: emissive
  property_bits_type:
    1: plastic
    2: roughness
    4: specular
    8: ior
    16: attenuation
    32: power
    64: glow
    128: is_total_power
# Support for constant lists would be useful here for the default color palette when the RGBA chunk is missing
# instances:
#   default_palette:
#     value: [
# 0x00000000, 0xffffffff, 0xffccffff, 0xff99ffff, 0xff66ffff, 0xff33ffff, 0xff00ffff, 0xffffccff, 0xffccccff, 0xff99ccff, 0xff66ccff, 0xff33ccff, 0xff00ccff, 0xffff99ff, 0xffcc99ff, 0xff9999ff,>
# 0xff6699ff, 0xff3399ff, 0xff0099ff, 0xffff66ff, 0xffcc66ff, 0xff9966ff, 0xff6666ff, 0xff3366ff, 0xff0066ff, 0xffff33ff, 0xffcc33ff, 0xff9933ff, 0xff6633ff, 0xff3333ff, 0xff0033ff, 0xffff00ff,>
#	0xffcc00ff, 0xff9900ff, 0xff6600ff, 0xff3300ff, 0xff0000ff, 0xffffffcc, 0xffccffcc, 0xff99ffcc, 0xff66ffcc, 0xff33ffcc, 0xff00ffcc, 0xffffcccc, 0xffcccccc, 0xff99cccc, 0xff66cccc, 0xff33cccc,>
#	0xff00cccc, 0xffff99cc, 0xffcc99cc, 0xff9999cc, 0xff6699cc, 0xff3399cc, 0xff0099cc, 0xffff66cc, 0xffcc66cc, 0xff9966cc, 0xff6666cc, 0xff3366cc, 0xff0066cc, 0xffff33cc, 0xffcc33cc, 0xff9933cc,>
#	0xff6633cc, 0xff3333cc, 0xff0033cc, 0xffff00cc, 0xffcc00cc, 0xff9900cc, 0xff6600cc, 0xff3300cc, 0xff0000cc, 0xffffff99, 0xffccff99, 0xff99ff99, 0xff66ff99, 0xff33ff99, 0xff00ff99, 0xffffcc99,>
#	0xffcccc99, 0xff99cc99, 0xff66cc99, 0xff33cc99, 0xff00cc99, 0xffff9999, 0xffcc9999, 0xff999999, 0xff669999, 0xff339999, 0xff009999, 0xffff6699, 0xffcc6699, 0xff996699, 0xff666699, 0xff336699,>
#	0xff006699, 0xffff3399, 0xffcc3399, 0xff993399, 0xff663399, 0xff333399, 0xff003399, 0xffff0099, 0xffcc0099, 0xff990099, 0xff660099, 0xff330099, 0xff000099, 0xffffff66, 0xffccff66, 0xff99ff66,>
#	0xff66ff66, 0xff33ff66, 0xff00ff66, 0xffffcc66, 0xffcccc66, 0xff99cc66, 0xff66cc66, 0xff33cc66, 0xff00cc66, 0xffff9966, 0xffcc9966, 0xff999966, 0xff669966, 0xff339966, 0xff009966, 0xffff6666,>
#	0xffcc6666, 0xff996666, 0xff666666, 0xff336666, 0xff006666, 0xffff3366, 0xffcc3366, 0xff993366, 0xff663366, 0xff333366, 0xff003366, 0xffff0066, 0xffcc0066, 0xff990066, 0xff660066, 0xff330066,>
#	0xff000066, 0xffffff33, 0xffccff33, 0xff99ff33, 0xff66ff33, 0xff33ff33, 0xff00ff33, 0xffffcc33, 0xffcccc33, 0xff99cc33, 0xff66cc33, 0xff33cc33, 0xff00cc33, 0xffff9933, 0xffcc9933, 0xff999933,>
#	0xff669933, 0xff339933, 0xff009933, 0xffff6633, 0xffcc6633, 0xff996633, 0xff666633, 0xff336633, 0xff006633, 0xffff3333, 0xffcc3333, 0xff993333, 0xff663333, 0xff333333, 0xff003333, 0xffff0033,>
#	0xffcc0033, 0xff990033, 0xff660033, 0xff330033, 0xff000033, 0xffffff00, 0xffccff00, 0xff99ff00, 0xff66ff00, 0xff33ff00, 0xff00ff00, 0xffffcc00, 0xffcccc00, 0xff99cc00, 0xff66cc00, 0xff33cc00,>
#	0xff00cc00, 0xffff9900, 0xffcc9900, 0xff999900, 0xff669900, 0xff339900, 0xff009900, 0xffff6600, 0xffcc6600, 0xff996600, 0xff666600, 0xff336600, 0xff006600, 0xffff3300, 0xffcc3300, 0xff993300,>
#	0xff663300, 0xff333300, 0xff003300, 0xffff0000, 0xffcc0000, 0xff990000, 0xff660000, 0xff330000, 0xff0000ee, 0xff0000dd, 0xff0000bb, 0xff0000aa, 0xff000088, 0xff000077, 0xff000055, 0xff000044,>
#	0xff000022, 0xff000011, 0xff00ee00, 0xff00dd00, 0xff00bb00, 0xff00aa00, 0xff008800, 0xff007700, 0xff005500, 0xff004400, 0xff002200, 0xff001100, 0xffee0000, 0xffdd0000, 0xffbb0000, 0xffaa0000,>
#	0xff880000, 0xff770000, 0xff550000, 0xff440000, 0xff220000, 0xff110000, 0xffeeeeee, 0xffdddddd, 0xffbbbbbb, 0xffaaaaaa, 0xff888888, 0xff777777, 0xff555555, 0xff444444, 0xff222222, 0xff111111>
#]
