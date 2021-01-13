import haxe.Resource;
import haxe.ds.Vector;
import hxd.Key;

private typedef Reg = UInt;
private typedef Address = UInt;

class Chip8 {
	var fontset = [
		0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
		0x20, 0x60, 0x20, 0x20, 0x70, // 1
		0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
		0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
		0x90, 0x90, 0xF0, 0x10, 0x10, // 4
		0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
		0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
		0xF0, 0x10, 0x20, 0x40, 0x40, // 7
		0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
		0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
		0xF0, 0x90, 0xF0, 0x90, 0x90, // A
		0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
		0xF0, 0x80, 0x80, 0x80, 0xF0, // C
		0xE0, 0x90, 0x90, 0x90, 0xE0, // D
		0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
		0xF0, 0x80, 0xF0, 0x80, 0x80 // F
	];

	public var memory:Vector<UInt> = new Vector(4096);
	public var drawFlag:Bool = false;
	public var V:Vector<UInt> = new Vector(16);
	public var I:UInt = 0;
	public var pc:UInt = 0x200;

	public var gfx:Vector<UInt> = new Vector(64 * 32);
	public var delay_timer:UInt = 0;
	public var sound_timer:UInt = 0;

	var stack:Vector<UInt> = new Vector(16);
	var sp:UInt = 0;

	public var key:Vector<UInt> = new Vector(16);

	var rom = Resource.getBytes("test");

	public function new() {
		// load font
		for (i in 0...fontset.length) {
			memory[i] = fontset[i];
		}

		// load rom
		for (i in 0...rom.length) {
			memory[0x200 + i] = rom.get(i);
		}
	}

	public function cycle() {
		var op = memory.get(pc) << 8 | memory.get(pc + 1);
		execute(op);

		if (delay_timer > 0) {
			delay_timer--;
		}

		if (sound_timer > 0) {
			if (sound_timer == 1) {
				// TODO: beep
			}
			--sound_timer;
		}
	}

	function execute(op:UInt) {
		var bytes = StringTools.lpad(StringTools.hex(op), '0', 4).split(''); // convert to strings for readability
		var x = (op & 0x0f00) >> 8;
		var y = (op & 0x00f0) >> 4;
		var nnn = op & 0x0fff;
		var nn = op & 0x00ff;
		var n = op & 0x000f;
		// trace('exec', pc, bytes.join(''));

		return switch (bytes) {
			case ['0', '0', 'E', '0']: {
					gfx = new Vector(64 * 32);
					drawFlag = true;
					pc += 2;
				};
			case ['0', '0', 'E', 'E']: {
					sp--;
					pc = stack[sp];
					pc += 2;
				};
			case ['0', _, _, _]: {
					// call machine code
					// ignored
					pc += 2;
				};
			case ['1', _, _, _]: {
					// go to
					pc = nnn;
				}
			case ['2', _, _, _]: {
					// call subroutine
					stack[sp] = pc;
					sp++;
					pc = nnn;
				};
			case ['3', _, _, _]: {
					if (V[x] == nn) {
						pc += 4;
					} else {
						pc += 2;
					}
				};
			case ['4', _, _, _]: {
					if (V[x] != nn) {
						pc += 4;
					} else {
						pc += 2;
					}
				};
			case ['5', _, _, '0']: {
					if (V[x] == V[y]) {
						pc += 4;
					} else {
						pc += 2;
					}
				};
			case ['6', _, _, _]: {
					V[x] = nn;
					pc += 2;
				};
			case ['7', _, _, _]: {
					V[x] += nn;
					V[x] = V[x] % 256;
					pc += 2;
				};
			case ['8', _, _, '0']: {
					V[x] = V[y];
					pc += 2;
				};
			case ['8', _, _, '1']: {
					V[x] = V[x] | V[y];
					pc += 2;
				};
			case ['8', _, _, '2']: {
					V[x] = V[x] & V[y];
					pc += 2;
				};
			case ['8', _, _, '3']: {
					V[x] = V[x] ^ V[y];
					pc += 2;
				};
			case ['8', _, _, '4']: {
					V[x] += V[y];
					V[x] = V[x] % 256;
					if (V[y] > (0xFF - V[x])) {
						V[0xF] = 1; // carry
					} else {
						V[0xF] = 0;
					}
					pc += 2;
				};
			case ['8', _, _, '5']: {
					if (V[y] > V[x]) {
						V[0xF] = 0; // borrow
					} else {
						V[0xF] = 1;
					}
					V[x] -= V[y];
					V[x] &= 0xff;
					trace(V[x]);
					pc += 2;
				};
			case ['8', _, _, '6']: {
					V[0xF] = V[x] & 0x1;
					V[x] = V[x] >> 1;
					pc += 2;
				}
			case ['8', _, _, '7']: {
					if (V[x] > V[y]) // VY-VX
						V[0xF] = 0; // there is a borrow
					else
						V[0xF] = 1;
					V[x] = V[y] - V[x];
					V[x] &= 0xff;
					pc += 2;
				};
			case ['8', _, _, 'E']: {
					V[0xF] = V[x] >> 7;
					V[x] = V[x] << 1;
					V[x] = V[x] % 256;
					pc += 2;
				};
			case ['9', _, _, '0']: {
					if (V[x] != V[y]) {
						pc += 4;
					} else {
						pc += 2;
					}
				};
			case ['A', _, _, _]: {
					I = nnn;
					pc += 2;
				};
			case ['B', _, _, _]: {
					pc = V[0] + nnn;
				};
			case ['C', _, _, _]: {
					V[x] = Std.random(255) & nn;
					pc += 2;
				};
			case ['D', _, _, _]: { //  draw
					V[0xf] = 0;
					var height = n;
					for (ypos in 0...height) {
						var pixel = memory[I + ypos];
						for (xpos in 0...8) {
							if (pixel & (0x80 >> xpos) != 0) {
								var xx = (V[x] + xpos) % 64;
								var yy = (V[y] + ypos) % 32;
								var addr = (xx + yy * 64);
								if (gfx[addr] == 1) {
									V[0xF] = 1;
								}

								gfx[addr] ^= 1;
							}
						}
					}

					drawFlag = true;
					pc += 2;
				};
			case ['E', _, '9', 'E']: {
					if (key[V[x]] == 1) {
						pc += 4;
					} else {
						pc += 2;
					}
				};
			case ['E', _, 'A', '1']: {
					if (key[V[x]] == 0) {
						pc += 4;
					} else {
						pc += 2;
					}
				};
			case ['F', _, '0', '7']: {
					V[x] = delay_timer;
					pc += 2;
				};
			case ['F', _, '0', 'A']: {
					// wait key press
					var keyPressed = false;
					for (i in 0...key.length) {
						if (key[i] == 1) {
							V[x] = i;
							keyPressed = true;
						}
					}

					if (!keyPressed) // loop if no key pressed
						return 0;

					pc += 2;
				}
			case ['F', _, '1', '5']: {
					delay_timer = V[x];
					pc += 2;
				};
			case ['F', _, '1', '8']: {
					sound_timer = V[x];
					pc += 2;
				};
			case ['F', _, '1', 'E']: {
					if (I + V[x] > 0xfff) {
						V[0xF] = 1;
					} else {
						V[0xF] = 0;
					}
					I += V[x];
					I = I % 256;
					pc += 2;
				};
			case ['F', _, '2', '9']: {
					// Sets I to the location of the sprite for the character in VX.
					// Characters 0-F (in hexadecimal) are represented by a 4x5 font
					I = V[x] * 0x5;
					pc += 2;
				};
			case ['F', _, '3', '3']: {
					memory[I] = Std.int(V[x] / 100);
					memory[I + 1] = Std.int(V[x] / 10) % 10;
					memory[I + 2] = V[x] % 10;
					pc += 2;
				};
			case ['F', _, '5', '5']: {
					// dump reg to memory
					for (i in 0...x) {
						memory[i] = V[i];
					}
					pc += 2;
				};
			case ['F', _, '6', '5']: {
					// load memory to reg
					for (i in 0...x) {
						V[i] = memory[I + i];
					}
					pc += 2;
				};
			case _: throw "Unknown OPCode: " + bytes.join('');
		}
	}
}
