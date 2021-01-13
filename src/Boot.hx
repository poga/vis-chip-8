class Boot extends hxd.App {
	private var pixelSize = 10;
	private var c:Chip8;

	public static var ME:Boot;

	override function update(dt:Float) {
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
	}

	override function init() {
		ME = this;
		c = new Chip8();
		onResize();
		var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		tf.text = "Hello World !";
	}

	static function main() {
		new Boot();
	}
}
