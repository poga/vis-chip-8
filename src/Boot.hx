class Boot extends hxd.App {
	var pixelSize = 10;

	public static var ME:Boot;

	var c:Chip8;

	override function update(dt:Float) {
		c.cycle();

		if (c.drawFlag) {
			var graphic = new h2d.Graphics(s2d);
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
