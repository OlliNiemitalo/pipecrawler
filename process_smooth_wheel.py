from gcodeparser import GcodeParser

with open('smooth wheel_0.2mm_FLEX_MK3S_8m.gcode', mode='r', encoding='UTF-8') as f:
  gcode = f.read()

bearing_height = 7
bearing_od = 22
bearing_bevel = 0.5
extra_bevel = 0.75

min_z = extra_bevel + bearing_bevel
max_z = extra_bevel + bearing_height - extra_bevel - bearing_bevel

n = 0
center_x = 0
center_y = 0

for line in GcodeParser(gcode, include_comments=True).lines:
    if line.command[0] == "G" and line.command[1] == 1 and 'X' in line.params and 'Y' in line.params and 'E' in line.params:
        z = line.get_param('Z')
        n += line.get_param('E')
        center_x += line.get_param('X')*line.get_param('E')
        center_y += line.get_param('Y')*line.get_param('E')

center_x = center_x/n
center_y = center_y/n

print(f"Means: x={center_x}, y={center_y}")
          
print(f"Changing extrusion within this z interval:")
print(f"min_z: {min_z}")
print(f"max_z: {max_z}")

max_e = 0
max_new_e = 0

def calc_thickness(rel_z) = (rel_z < 0 || rel_z > 1) ? min_thickness : min_thickness + (max_thickness - min_thickness)*4*rel_z*(1 - rel_z);

with open('smooth wheel_0.2mm_FLEX_MK3S_8m_processed.gcode', mode='w', encoding='UTF-8') as wf:
    for line in GcodeParser(gcode, include_comments=True).lines:
        if line.command[0] == "G" and line.command[1] == 1 and 'X' in line.params and 'Y' in line.params and 'Z' in line.params and 'E' in line.params:        
            z = line.get_param('Z')
            rel_z = (z - min_z)/(max_z - min_z)        
            
            # Better safe than sorry
            if rel_z < 0: 
                rel_z = 0
            if rel_z > 1:
                rel_z = 1
                
            extra = 4*rel_z*(1 - rel_z) # 0 <= extra <= 1
            extra = extra*extra # 0 <= extra <= 1
            multiplier = 0.25 + extra*0.75 # 0.5 <= multiplier <= 1.5
            e = line.get_param('E')
            if e > max_e:
                max_e = e
            new_e = e*multiplier
            if new_e > max_new_e:
                max_new_e = new_e
            print(f"{rel_z} {e} {new_e}")
            line.update_param('E', new_e)
        wf.write(line.gcode_str)
        wf.write("\n")        
        
print(f"Max E: {max_e} -> {max_new_e}")