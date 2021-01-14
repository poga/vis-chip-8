import haxe.ds.Vector;

class Boot extends hxd.App {
	private var pixelSize = 10;
	private var v_pos = [64 * 10 + 30, 30];
	private var mem_pos = [64 * 10 + 30, 30 + 60];
	private var c:Chip8;
	private var last_memory:Vector<UInt> = new Vector(4096);

	public static var ME:Boot;

	override function update(dt:Float) {
		var graphic = new h2d.Graphics(s2d);

		// clear last pc pointer
		var v = c.memory[c.pc];
		graphic.beginFill(v << 16 | v << 8 | v);
		graphic.drawRect(mem_pos[0] + (c.pc % 64) * pixelSize, mem_pos[1] + (Std.int(c.pc / 64) * pixelSize), pixelSize, pixelSize);
		graphic.endFill();

		c.cycle();
		if (c.drawFlag) {
			var graphic = new h2d.Graphics(s2d);
			// clear screen
			graphic.beginFill(0x000000);
			graphic.drawRect(0, 0, 64 * pixelSize, 32 * pixelSize);
			graphic.endFill();

			// draw gfx
			graphic.beginFill(0xEA8220);

			for (i in 0...c.gfx.length) {
				var x = i % 64;
				var y = Std.int(i / 64);

				if (c.gfx[i] == 1) {
					graphic.drawRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
				} else {}
			}
			graphic.endFill();

			c.drawFlag = false;
		}

		// clear sidebar
		graphic.beginFill(0x000000);
		graphic.drawRect(v_pos[0], v_pos[1], 200, 50);
		graphic.endFill();

		// draw registers
		// draw border
		graphic.beginFill(0xffffff);
		graphic.drawRect(v_pos[0] - 1, v_pos[1] - 1, pixelSize * c.V.length + 2, pixelSize + 2);
		graphic.endFill();
		for (i in 0...c.V.length) {
			var v = c.V[i];
			graphic.beginFill(v << 16 | v << 8 | v);
			graphic.drawRect(v_pos[0] + i * pixelSize, v_pos[1], pixelSize, pixelSize);
			graphic.endFill();
		}
		graphic.endFill();

		// draw memory
		for (i in 0...c.memory.length) {
			var v = c.memory[i];
			if (last_memory[i] != v) {
				graphic.beginFill(v << 16 | v << 8 | v);
				graphic.drawRect(mem_pos[0] + (i % 64) * pixelSize, mem_pos[1] + (Std.int(i / 64) * pixelSize), pixelSize, pixelSize);
				graphic.endFill();
				last_memory[i] = c.memory[i];
			}
		}

		// draw pc
		graphic.beginFill(0xFF0000);
		graphic.drawRect(mem_pos[0] + (c.pc % 64) * pixelSize, mem_pos[1] + (Std.int(c.pc / 64) * pixelSize), pixelSize, pixelSize);
		graphic.endFill();
		graphic.beginFill(v << 16 | v << 8 | v);
		graphic.drawRect((mem_pos[0] + (c.pc % 64) * pixelSize + 1), (mem_pos[1] + (Std.int(c.pc / 64) * pixelSize) + 1), pixelSize - 2, pixelSize - 2);
		graphic.endFill();

		// PC and I

		var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		tf.text = "PC = " + c.pc + ', I = ' + c.I;
		tf.setPosition(v_pos[0], v_pos[1] + 15);

		var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		tf.text = "Memory";
		tf.setPosition(v_pos[0], v_pos[1] + 40);
	}

	override function init() {
		var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		tf.text = "Register";
		tf.setPosition(v_pos[0], v_pos[1] - 20);
		ME = this;
		c = new Chip8();
		onResize();
		// draw memory border
		var graphic = new h2d.Graphics(s2d);
		graphic.beginFill(0xffffff);
		graphic.drawRect(mem_pos[0] - 1, mem_pos[1] - 1, pixelSize * 64 + 2, pixelSize * 64 + 2);
		graphic.beginFill(0x000000);
		graphic.drawRect(mem_pos[0], mem_pos[1], pixelSize * 64, pixelSize * 64);
		graphic.endFill();
	}

	static function main() {
		new Boot();
	}
}
