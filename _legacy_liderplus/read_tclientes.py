import struct

with open(r'c:\GalepsoSync\DATA_KW\tclientes.dbf', 'rb') as f:
    f.seek(8)
    header_len = struct.unpack('<H', f.read(2))[0]
    num_fields = (header_len - 33) // 32
    
    f.seek(32)
    for _ in range(num_fields):
        field_data = f.read(32)
        field_name = field_data[:11].decode('ascii').rstrip('\x00')
        print(field_name)
